//! Element-wise operations fused into the operation that uses them, as
//! upstream's `linalg-fuse-elementwise-ops` does: a `linalg.generic` whose
//! result only one other `linalg.generic` reads, as an input, is worked out
//! inside it, element by element as that one reads it, rather than written
//! to a tensor of its own and read back. A language model's layer is a
//! chain of such steps (GELU's multiplies, powers and `tanh`; layer norm's
//! differences and scaling; softmax's difference and `exp`), each a pass
//! over memory of its own unless fused.
//!
//! The producer has only parallel loops, one result, an output that it
//! does not read, the identity for its output's map, and no `linalg.index`.
//! The consumer has only parallel loops, or it is a reduction of one input
//! (a sum, a maximum): a product of two (a matrix product) is left alone,
//! for `linalg-to-kernels`. The producer's inputs are read through their
//! maps composed with the consumer's for the producer's result; its body
//! goes before the consumer's, its yield standing for that input. The pass
//! fuses one producer into each consumer at a time, as often as it can.
//! Runs on tensors, after `linalg-fold-constants`.

use std::collections::HashMap;

use crate::affine::{Expr, Map};
use crate::build::OpSpec;
use crate::ir::*;

/// Fuses what can be fused in every function of `src`.
pub fn run(src: &Module) -> Result<Module, String> {
    let (mut m, mut fused) = round(src)?;
    for _ in 0..32 {
        if fused == 0 {
            break;
        }
        (m, fused) = round(&m)?;
    }
    Ok(m)
}

fn dict(m: &Module, d: Option<AttrId>) -> Vec<(String, AttrId)> {
    match d.map(|d| m.attr(d)) {
        Some(Attr::Dict(es)) => es.clone(),
        _ => Vec::new(),
    }
}

fn maps_of(m: &Module, op: OpId) -> Option<Vec<Map>> {
    let Some(Attr::Array(ms)) = m.op_attr(op, "indexing_maps").map(|a| m.attr(m.resolve_attr(a))) else {
        return None;
    };
    ms.iter()
        .map(|&a| match m.attr(m.resolve_attr(a)) {
            Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]).ok(),
            _ => None,
        })
        .collect()
}

fn all_parallel(m: &Module, op: OpId) -> Option<bool> {
    match m.op_attr(op, "iterator_types").map(|a| m.attr(m.resolve_attr(a))) {
        Some(Attr::Array(es)) => {
            Some(es.iter().all(|&e| matches!(m.attr(e), Attr::Dialect { body: Some(b), .. } if b.contains("parallel"))))
        }
        _ => None,
    }
}

fn body_of(m: &Module, op: OpId) -> BlockId {
    m.regions[m.ops[op.index()].regions[0].index()].blocks[0]
}

/// Whether `op` can be fused into what reads it.
fn producer(m: &Module, op: OpId) -> bool {
    if m.op_name(op) != "linalg.generic" {
        return false;
    }
    let o = &m.ops[op.index()];
    let n_ins = crate::bufferize::inputs_of(m, op);
    if o.results.len() != 1 || o.operands.len() != n_ins + 1 || all_parallel(m, op) != Some(true) {
        return false;
    }
    let Some(maps) = maps_of(m, op) else { return false };
    let out = &maps[n_ins];
    if *out != Map::identity(out.dims) || maps.iter().any(|mp| mp.syms > 0) {
        return false;
    }
    let body = body_of(m, op);
    let args = &m.blocks[body.index()].args;
    let ops = &m.blocks[body.index()].ops;
    // The output not read, no indices, nothing nested.
    !ops.iter().any(|&b| {
        let bo = &m.ops[b.index()];
        m.op_name(b) == "linalg.index" || !bo.regions.is_empty() || bo.operands.contains(&args[n_ins])
    })
}

/// Whether `op` can take a producer into it: parallel, or a reduction of
/// one input.
fn consumer(m: &Module, op: OpId) -> bool {
    if m.op_name(op) != "linalg.generic" || maps_of(m, op).is_none_or(|ms| ms.iter().any(|mp| mp.syms > 0)) {
        return false;
    }
    let n_ins = crate::bufferize::inputs_of(m, op);
    match all_parallel(m, op) {
        Some(true) => true,
        Some(false) => n_ins == 1,
        None => false,
    }
}

/// `e` with each dimension `k` replaced by `to[k]`.
fn substitute(e: &Expr, to: &[Expr]) -> Expr {
    let two = |a: &Expr, b: &Expr| (Box::new(substitute(a, to)), Box::new(substitute(b, to)));
    match e {
        Expr::Dim(k) => to[*k].clone(),
        Expr::Sym(_) | Expr::Const(_) => e.clone(),
        Expr::Add(a, b) => {
            let (a, b) = two(a, b);
            Expr::Add(a, b)
        }
        Expr::Mul(a, b) => {
            let (a, b) = two(a, b);
            Expr::Mul(a, b)
        }
        Expr::FloorDiv(a, b) => {
            let (a, b) = two(a, b);
            Expr::FloorDiv(a, b)
        }
        Expr::CeilDiv(a, b) => {
            let (a, b) = two(a, b);
            Expr::CeilDiv(a, b)
        }
        Expr::Mod(a, b) => {
            let (a, b) = two(a, b);
            Expr::Mod(a, b)
        }
    }
}

/// One round: each consumer takes at most one producer.
fn round(src: &Module) -> Result<(Module, usize), String> {
    // The uses of each value.
    let mut uses: HashMap<ValueId, usize> = HashMap::new();
    for o in &src.ops {
        for &v in &o.operands {
            *uses.entry(v).or_default() += 1;
        }
    }
    // Which producer each consumer takes, and at which input.
    let mut takes: HashMap<OpId, (usize, OpId)> = HashMap::new();
    let mut taken: std::collections::HashSet<OpId> = Default::default();
    for (k, o) in src.ops.iter().enumerate() {
        let c = OpId(k as u32);
        if o.parent.is_none() || !consumer(src, c) {
            continue;
        }
        let n_ins = crate::bufferize::inputs_of(src, c);
        for (i, &v) in o.operands[..n_ins].iter().enumerate() {
            let ValueDef::Result { op: p, .. } = src.values[v.index()].def else { continue };
            if uses.get(&v) == Some(&1)
                && !taken.contains(&p)
                // (Not one taking a producer itself this round: that is
                // fused in the next.)
                && !takes.contains_key(&p)
                && src.ops[p.index()].parent == o.parent
                && producer(src, p)
                && src.shaped(src.value_type(v)).is_some_and(|(s, _)| s.len() == maps_of(src, p).unwrap()[0].dims)
            {
                takes.insert(c, (i, p));
                taken.insert(p);
                break;
            }
        }
    }
    let fused = takes.len();
    let mut out = src.empty_like();
    let mut map = HashMap::new();
    for top in src.top_ops().collect::<Vec<_>>() {
        copy(src, top, &mut out, None, &mut map, &takes, &taken)?;
    }
    Ok((out, fused))
}

fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    map: &mut HashMap<ValueId, ValueId>,
    takes: &HashMap<OpId, (usize, OpId)>,
    taken: &std::collections::HashSet<OpId>,
) -> Result<(), String> {
    if taken.contains(&op) {
        return Ok(());
    }
    if let (Some(&(i, p)), Some(block)) = (takes.get(&op), block) {
        return fuse(src, p, op, i, out, block, map);
    }
    let o = &src.ops[op.index()];
    if o.regions.is_empty() {
        out.clone_op(src, op, block, map)?;
        return Ok(());
    }
    let operands = o
        .operands
        .iter()
        .map(|v| map.get(v).copied().ok_or("an operand from outside"))
        .collect::<Result<Vec<_>, _>>()?;
    let results: Vec<TypeId> = o.results.iter().map(|&r| src.value_type(r)).collect();
    let mut spec = OpSpec::new(src.op_name(op))
        .operands(&operands)
        .results(&results)
        .successors(&o.successors)
        .regions(o.regions.len())
        .loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = spec.prop(&k, v);
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, block);
    for (&old, &n) in o.results.iter().zip(&out.ops[new.index()].results.clone()) {
        map.insert(old, n);
    }
    for (k, &r) in o.regions.iter().enumerate() {
        let region = out.region_of(new, k);
        let blocks = src.regions[r.index()].blocks.clone();
        if blocks.len() > 1 {
            // (Branches between blocks: copied whole.)
            out.clone_region_into(src, r, region, map)?;
            continue;
        }
        for &b in &blocks {
            let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
            let nb = out.add_block(region, &types);
            for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
                map.insert(a, n);
            }
            for &inner in &src.blocks[b.index()].ops {
                copy(src, inner, out, Some(nb), map, takes, taken)?;
            }
        }
    }
    Ok(())
}

/// Consumer `c` with producer `p` (its input `i`) worked out inside it.
fn fuse(
    src: &Module,
    p: OpId,
    c: OpId,
    i: usize,
    out: &mut Module,
    block: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let (po, co) = (&src.ops[p.index()], &src.ops[c.index()]);
    let (p_ins, c_ins) = (crate::bufferize::inputs_of(src, p), crate::bufferize::inputs_of(src, c));
    let (pmaps, cmaps) = (maps_of(src, p).unwrap(), maps_of(src, c).unwrap());
    // The producer's inputs, through its maps composed with the consumer's
    // for its result, in place of input i.
    let through = &cmaps[i].results;
    let mut operands = Vec::new();
    let mut maps = Vec::new();
    for k in 0..co.operands.len() {
        if k == i {
            for j in 0..p_ins {
                operands.push(po.operands[j]);
                let results: Vec<Expr> = pmaps[j].results.iter().map(|e| substitute(e, through)).collect();
                maps.push(Map { dims: cmaps[i].dims, syms: 0, results });
            }
        } else {
            operands.push(co.operands[k]);
            maps.push(cmaps[k].clone());
        }
    }
    // The block arguments the operands stand for: the producer's inputs'
    // in place of input i.
    let (pb, cb) = (body_of(src, p), body_of(src, c));
    let (pargs, cargs) = (&src.blocks[pb.index()].args, &src.blocks[cb.index()].args);
    let mut arg_srcs: Vec<ValueId> = Vec::new();
    for (k, &a) in cargs.iter().enumerate() {
        if k == i {
            arg_srcs.extend(&pargs[..p_ins]);
        } else {
            arg_srcs.push(a);
        }
    }
    // An input read twice through the same map (the producer's and the
    // consumer's both of x) is read once: later ones stand for the first.
    let all_ins = c_ins - 1 + p_ins;
    let mut same_as: Vec<Option<usize>> = vec![None; operands.len()];
    for k in 0..all_ins {
        same_as[k] = (0..k).find(|&j| same_as[j].is_none() && operands[j] == operands[k] && maps[j] == maps[k]);
    }
    let kept: Vec<usize> = (0..operands.len()).filter(|&k| same_as[k].is_none()).collect();
    let new_ins = kept.iter().filter(|&&k| k < all_ins).count();
    let maps: Vec<Map> = kept.iter().map(|&k| maps[k].clone()).collect();
    let operands: Vec<ValueId> = kept
        .iter()
        .map(|&k| map.get(&operands[k]).copied().ok_or("an operand from outside"))
        .collect::<Result<_, _>>()?;
    let results: Vec<TypeId> = co.results.iter().map(|&r| src.value_type(r)).collect();
    let mut spec = OpSpec::new("linalg.generic").operands(&operands).results(&results).regions(1).loc(co.loc);
    for (k, v) in dict(src, co.properties) {
        spec = spec.prop(
            &k,
            match k.as_str() {
                "indexing_maps" => {
                    let attrs = maps.iter().map(|mp| out.affine_map_attr(&mp.to_string())).collect();
                    out.array_attr(attrs)
                }
                "operandSegmentSizes" => {
                    out.dense_array_attr("i32", &[new_ins as i64, (co.operands.len() - c_ins) as i64])
                }
                _ => v,
            },
        );
    }
    for (k, v) in dict(src, co.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, Some(block));
    for (&old, &n) in co.results.iter().zip(&out.ops[new.index()].results.clone()) {
        map.insert(old, n);
    }
    // The body: the producer's, then the consumer's.
    let types: Vec<TypeId> = kept.iter().map(|&k| src.value_type(arg_srcs[k])).collect();
    let region = out.region_of(new, 0);
    let nb = out.add_block(region, &types);
    let new_args = out.blocks[nb.index()].args.clone();
    for (n, &k) in kept.iter().enumerate() {
        map.insert(arg_srcs[k], new_args[n]);
    }
    for k in 0..arg_srcs.len() {
        if let Some(j) = same_as[k] {
            let v = map[&arg_srcs[j]];
            map.insert(arg_srcs[k], v);
        }
    }
    for &b in &src.blocks[pb.index()].ops {
        if src.op_name(b) == "linalg.yield" {
            let y = src.ops[b.index()].operands[0];
            let v = *map.get(&y).ok_or("a yield of an unknown value")?;
            map.insert(cargs[i], v);
        } else {
            out.clone_op(src, b, Some(nb), map)?;
        }
    }
    for &b in &src.blocks[cb.index()].ops {
        out.clone_op(src, b, Some(nb), map)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    #[test]
    fn a_chain_fused_into_a_sum() {
        // exp(x - 1) * 2, then the sum of each row: one operation.
        let src = r#""builtin.module"() ({
  "func.func"() <{function_type = (tensor<4x8xf32>) -> tensor<4xf32>, sym_name = "f"}> ({
  ^bb0(%x: tensor<4x8xf32>):
    %one = "arith.constant"() <{value = 1.000000e+00 : f32}> : () -> f32
    %two = "arith.constant"() <{value = 2.000000e+00 : f32}> : () -> f32
    %e1 = "tensor.empty"() : () -> tensor<4x8xf32>
    %a = "linalg.generic"(%x, %e1) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%p: f32, %q: f32):
      %0 = "arith.subf"(%p, %one) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %1 = "math.exp"(%0) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
      "linalg.yield"(%1) : (f32) -> ()
    }) : (tensor<4x8xf32>, tensor<4x8xf32>) -> tensor<4x8xf32>
    %e2 = "tensor.empty"() : () -> tensor<4x8xf32>
    %b = "linalg.generic"(%a, %e2) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%p: f32, %q: f32):
      %0 = "arith.mulf"(%p, %two) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%0) : (f32) -> ()
    }) : (tensor<4x8xf32>, tensor<4x8xf32>) -> tensor<4x8xf32>
    %z = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %e3 = "tensor.empty"() : () -> tensor<4xf32>
    %f = "linalg.fill"(%z, %e3) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%p: f32, %q: f32):
      "linalg.yield"(%p) : (f32) -> ()
    }) : (f32, tensor<4xf32>) -> tensor<4xf32>
    %s = "linalg.generic"(%b, %f) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%p: f32, %acc: f32):
      %0 = "arith.addf"(%p, %acc) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%0) : (f32) -> ()
    }) : (tensor<4x8xf32>, tensor<4xf32>) -> tensor<4xf32>
    "func.return"(%s) : (tensor<4xf32>) -> ()
  }) : () -> ()
}) : () -> ()
"#;
        let text = super::run(&crate::parse_module(src).unwrap()).unwrap().to_string();
        assert_eq!(text.matches("\"linalg.generic\"").count(), 1, "{text}");
        for op in ["arith.subf", "math.exp", "arith.mulf", "arith.addf"] {
            assert!(text.contains(op), "{op} gone:\n{text}");
        }
        crate::parse_module(&text).unwrap();
    }
}
