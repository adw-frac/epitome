//! Constants folded through `linalg`: a `linalg.generic` that only moves
//! the elements of a constant (a transpose) is worked out when compiling,
//! and becomes a constant itself, as upstream's
//! `populateConstantFoldLinalgOperations` folds them.
//!
//! torch-mlir writes each `nn.Linear` as a `linalg.transpose` of its weight
//! and a `linalg.matmul`; a language model's weights are constants, so
//! without this every call transposes all of them (SmolLM2-135M's half a
//! gigabyte). Runs on tensors, after `linalg-generalize-named-ops`.
//!
//! Results of a `linalg.generic` that nothing uses are dropped too, with
//! their outputs and the work in the body for them, as upstream's
//! canonicalization does: torch-mlir's `max` along a dimension works out
//! where each maximum is as well, which softmax never reads.
//!
//! An element-wise `linalg.generic` whose result is only sliced
//! (`tensor.extract_slice`, perhaps of a slice) works out only the slice,
//! on slices of its inputs: GPT-2's and GPT-Neo's causal masks are 2048 x
//! 2048 buffers, compared with zero and then cut to the sequence's length.
//!
//! An operation is folded when it has one input, a constant
//! (`arith.constant` of `dense_resource`), an output from `tensor.empty`, a
//! body that yields the input's element, an identity map for the output and
//! a permutation of the loops for the input. The result is a new blob of
//! `dialect_resources` (`Item::Blob`). Constants no longer used afterwards
//! are dropped.

use std::collections::{HashMap, HashSet};
use std::sync::Arc;

use crate::affine::{Expr, Map};
use crate::build::OpSpec;
use crate::ir::*;

/// Folds what can be folded in every function of `src`.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
    let resources = src.resources();
    let mut made = 0usize;
    let mut map = HashMap::new();
    let mut blobs = Vec::new();
    let used: HashSet<ValueId> = src.ops.iter().flat_map(|o| o.operands.iter().copied()).collect();
    let mut users: HashMap<ValueId, Vec<OpId>> = HashMap::new();
    for (k, o) in src.ops.iter().enumerate() {
        for &v in &o.operands {
            users.entry(v).or_default().push(OpId(k as u32));
        }
    }
    let mut cx = Cx {
        resources: &resources,
        used: &used,
        users: &users,
        skip: HashSet::new(),
        made: &mut made,
        blobs: &mut blobs,
    };
    for top in src.top_ops().collect::<Vec<_>>() {
        copy(src, top, &mut out, None, &mut map, &mut cx)?;
    }
    // The new blobs, before the file's own resources.
    let at = out.items.iter().position(|i| matches!(i, Item::Resources(_))).unwrap_or(out.items.len());
    for (k, b) in blobs.into_iter().enumerate() {
        out.items.insert(at + k, b);
    }
    drop_unused_constants(&mut out);
    Ok(out)
}

/// What folding needs as it goes.
struct Cx<'a> {
    resources: &'a Resources<'a>,
    /// Every value some operation uses.
    used: &'a HashSet<ValueId>,
    /// The operations that use each value.
    users: &'a HashMap<ValueId, Vec<OpId>>,
    /// Slices already worked out by the operations they slice.
    skip: HashSet<OpId>,
    /// Blobs made so far, for their names.
    made: &'a mut usize,
    blobs: &'a mut Vec<Item>,
}

fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    map: &mut HashMap<ValueId, ValueId>,
    cx: &mut Cx<'_>,
) -> Result<(), String> {
    if cx.skip.contains(&op) {
        return Ok(());
    }
    if src.op_name(op) == "linalg.generic"
        && let Some(block) = block
        && drop_dead_results(src, op, out, block, map, cx.used)?
    {
        return Ok(());
    }
    if src.op_name(op) == "linalg.generic"
        && let Some(block) = block
        && sliced(src, op, out, block, map, cx)?
    {
        return Ok(());
    }
    let (resources, made) = (cx.resources, &mut *cx.made);
    if src.op_name(op) == "linalg.generic"
        && let Some(block) = block
        && let Some((key, ty, align, bytes)) = fold(src, op, resources, made)?
    {
        let attr = out.intern_attr(Attr::Builtin { keyword: "dense_resource", body: format!("<{key}>"), ty: Some(ty) });
        let c = OpSpec::new("arith.constant").results(&[ty]).prop("value", attr).build(out, Some(block));
        let v = out.result(c);
        map.insert(src.ops[op.index()].results[0], v);
        cx.blobs.push(Item::Blob { key, align, bytes: Arc::new(bytes) });
        return Ok(());
    }
    let o = &src.ops[op.index()];
    if o.regions.is_empty() {
        out.clone_op(src, op, block, map)?;
        return Ok(());
    }
    // The operation with empty regions, its blocks then copied here, so that
    // what is nested in functions is folded.
    let operands = o
        .operands
        .iter()
        .map(|v| map.get(v).copied().ok_or("an operand from outside"))
        .collect::<Result<Vec<_>, _>>()?;
    let results: Vec<TypeId> = o.results.iter().map(|&r| src.value_type(r)).collect();
    let mut spec =
        OpSpec::new(src.op_name(op)).operands(&operands).results(&results).regions(o.regions.len()).loc(o.loc);
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
        let mut new_blocks = Vec::new();
        for &b in &blocks {
            let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
            let nb = out.add_block(region, &types);
            for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
                map.insert(a, n);
            }
            new_blocks.push(nb);
        }
        for (&b, &nb) in blocks.iter().zip(&new_blocks) {
            for &inner in &src.blocks[b.index()].ops {
                if !src.ops[inner.index()].successors.is_empty() {
                    return Err("branches between blocks are not supported here".into());
                }
                copy(src, inner, out, Some(nb), map, cx)?;
            }
        }
    }
    Ok(())
}

fn dict(m: &Module, d: Option<AttrId>) -> Vec<(String, AttrId)> {
    match d.map(|d| m.attr(d)) {
        Some(Attr::Dict(es)) => es.clone(),
        _ => Vec::new(),
    }
}

/// `op` without the results nothing uses, if it has any and some are used:
/// their outputs, maps and block arguments gone, and the body only what the
/// other results need. Whether it was written so.
fn drop_dead_results(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
    used: &HashSet<ValueId>,
) -> Result<bool, String> {
    let o = &src.ops[op.index()];
    let live: Vec<bool> = o.results.iter().map(|r| used.contains(r)).collect();
    if live.iter().all(|&l| l) || !live.iter().any(|&l| l) {
        return Ok(false);
    }
    let n_ins = crate::bufferize::inputs_of(src, op);
    let body = src.regions[o.regions[0].index()].blocks[0];
    let bargs = &src.blocks[body.index()].args;
    let ops = &src.blocks[body.index()].ops;
    let &yield_op = ops.last().ok_or("an empty body")?;
    // The body's operations the live results need, from the last back.
    let mut needed: HashSet<ValueId> =
        src.ops[yield_op.index()].operands.iter().zip(&live).filter(|&(_, &l)| l).map(|(&v, _)| v).collect();
    let mut keep = vec![false; ops.len()];
    for (k, &p) in ops.iter().enumerate().rev() {
        let po = &src.ops[p.index()];
        if p == yield_op {
            keep[k] = true;
        } else if po.results.iter().any(|r| needed.contains(r)) {
            if !po.regions.is_empty() {
                return Ok(false);
            }
            keep[k] = true;
            needed.extend(po.operands.iter().copied());
        }
    }
    // A dead output's element must not be needed.
    let dead_args: Vec<ValueId> = (0..live.len()).filter(|&k| !live[k]).map(|k| bargs[n_ins + k]).collect();
    if dead_args.iter().any(|a| needed.contains(a)) {
        return Ok(false);
    }
    let Some(Attr::Array(ms)) = src.op_attr(op, "indexing_maps").map(|a| src.attr(src.resolve_attr(a))) else {
        return Ok(false);
    };
    let ms = ms.clone();
    let keep_operand = |k: usize| k < n_ins || live[k - n_ins];
    let operands: Vec<ValueId> = o
        .operands
        .iter()
        .enumerate()
        .filter(|&(k, _)| keep_operand(k))
        .map(|(_, v)| map.get(v).copied().ok_or("an operand from outside"))
        .collect::<Result<_, _>>()?;
    let maps: Vec<AttrId> = ms.iter().enumerate().filter(|&(k, _)| keep_operand(k)).map(|(_, &m)| m).collect();
    let results: Vec<TypeId> =
        o.results.iter().zip(&live).filter(|&(_, &l)| l).map(|(&r, _)| src.value_type(r)).collect();
    let mut spec = OpSpec::new("linalg.generic").operands(&operands).results(&results).regions(1).loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = match k.as_str() {
            "indexing_maps" => {
                let a = out.array_attr(maps.clone());
                spec.prop(&k, a)
            }
            "operandSegmentSizes" => {
                let a = out.dense_array_attr("i32", &[n_ins as i64, results.len() as i64]);
                spec.prop(&k, a)
            }
            _ => spec.prop(&k, v),
        };
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, Some(block));
    let mut live_results = o.results.iter().zip(&live).filter(|&(_, &l)| l).map(|(&r, _)| r);
    for &n in &out.ops[new.index()].results.clone() {
        map.insert(live_results.next().unwrap(), n);
    }
    let region = out.region_of(new, 0);
    let kept_args: Vec<ValueId> = bargs.iter().enumerate().filter(|&(k, _)| keep_operand(k)).map(|(_, &a)| a).collect();
    let types: Vec<TypeId> = kept_args.iter().map(|&a| src.value_type(a)).collect();
    let nb = out.add_block(region, &types);
    for (&a, &n) in kept_args.iter().zip(&out.blocks[nb.index()].args.clone()) {
        map.insert(a, n);
    }
    for (k, &p) in ops.iter().enumerate() {
        if !keep[k] {
            continue;
        }
        if p == yield_op {
            let ys = src.ops[p.index()]
                .operands
                .iter()
                .zip(&live)
                .filter(|&(_, &l)| l)
                .map(|(v, _)| map.get(v).copied().ok_or("a yield of an unknown value"))
                .collect::<Result<Vec<_>, _>>()?;
            OpSpec::new("linalg.yield").operands(&ys).build(out, Some(nb));
        } else {
            out.clone_op(src, p, Some(nb), map)?;
        }
    }
    Ok(true)
}

/// A `tensor.extract_slice` of `v` without rank reduction, static and of
/// unit strides: its offsets and sizes.
fn static_slice(m: &Module, op: OpId, rank: usize) -> Option<(Vec<i64>, Vec<i64>)> {
    if m.op_name(op) != "tensor.extract_slice" || m.ops[op.index()].operands.len() != 1 {
        return None;
    }
    let list = |k: &str| m.op_attr(op, k).and_then(|a| m.int_list(a));
    let (offsets, sizes, strides) = (list("static_offsets")?, list("static_sizes")?, list("static_strides")?);
    let rank_kept = m.shaped(m.value_type(m.ops[op.index()].results[0])).is_some_and(|(s, _)| s.len() == rank);
    (offsets.len() == rank && sizes.len() == rank && strides.iter().all(|&s| s == 1) && rank_kept)
        .then_some((offsets, sizes))
}

/// `op`, element-wise, as itself on slices of its inputs, if its result
/// is only sliced (perhaps a slice of a slice, and so on): the last slice
/// becomes its result. Whether it was written so.
fn sliced(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
    cx: &mut Cx<'_>,
) -> Result<bool, String> {
    let o = &src.ops[op.index()];
    let n_ins = crate::bufferize::inputs_of(src, op);
    if o.results.len() != 1 || o.operands.len() != n_ins + 1 {
        return Ok(false);
    }
    if def(src, o.operands[n_ins]).is_none_or(|e| src.op_name(e) != "tensor.empty") {
        return Ok(false);
    }
    let Some((shape, elem)) = src.shaped(src.value_type(o.results[0])) else { return Ok(false) };
    let rank = shape.len();
    // Every map the identity, every loop parallel, and no indices read.
    let Some(Attr::Array(ms)) = src.op_attr(op, "indexing_maps").map(|a| src.attr(src.resolve_attr(a))) else {
        return Ok(false);
    };
    let identity = Map::identity(rank);
    let all_identity = ms.iter().all(|&m| match src.attr(src.resolve_attr(m)) {
        Attr::Builtin { keyword: "affine_map", body, .. } => {
            Map::parse(&body[1..body.len() - 1]).ok() == Some(identity.clone())
        }
        _ => false,
    });
    let parallel = match src.op_attr(op, "iterator_types").map(|a| src.attr(src.resolve_attr(a))) {
        Some(Attr::Array(es)) => {
            es.iter().all(|&e| matches!(src.attr(e), Attr::Dialect { body: Some(b), .. } if b.contains("parallel")))
        }
        _ => false,
    };
    let body = src.regions[o.regions[0].index()].blocks[0];
    if !all_identity || !parallel || src.blocks[body.index()].ops.iter().any(|&b| src.op_name(b) == "linalg.index") {
        return Ok(false);
    }
    // The chain of slices, each the only user of the last.
    let only_user = |v: ValueId| match cx.users.get(&v).map(Vec::as_slice) {
        Some(&[u]) => Some(u),
        _ => None,
    };
    let mut chain = Vec::new();
    let (mut offsets, mut sizes) = (vec![0i64; rank], shape.iter().map(|&s| s as i64).collect::<Vec<_>>());
    let mut at = o.results[0];
    while let Some(u) = only_user(at)
        && let Some((offs, szs)) = static_slice(src, u, rank)
    {
        for (o, d) in offsets.iter_mut().zip(&offs) {
            *o += d;
        }
        sizes = szs;
        chain.push(u);
        at = src.ops[u.index()].results[0];
    }
    if chain.is_empty() {
        return Ok(false);
    }
    let shape: Vec<u64> = sizes.iter().map(|&s| s as u64).collect();
    let slice = |out: &mut Module, v: ValueId| -> Result<ValueId, String> {
        let (_, e) = out.shaped(out.value_type(v)).ok_or("an input of unknown shape")?;
        let ty = out.tensor_type(&shape, e);
        let segments = out.dense_array_attr("i32", &[1, 0, 0, 0]);
        let offs = out.dense_array_attr("i64", &offsets);
        let szs = out.dense_array_attr("i64", &sizes);
        let ones = out.dense_array_attr("i64", &vec![1; rank]);
        let s = OpSpec::new("tensor.extract_slice")
            .operands(&[v])
            .results(&[ty])
            .prop("operandSegmentSizes", segments)
            .prop("static_offsets", offs)
            .prop("static_sizes", szs)
            .prop("static_strides", ones)
            .build(out, Some(block));
        Ok(out.result(s))
    };
    let mut operands = Vec::new();
    for v in &o.operands[..n_ins] {
        let v = map.get(v).copied().ok_or("an operand from outside")?;
        operands.push(slice(out, v)?);
    }
    let ty = out.tensor_type(&shape, elem);
    let empty = OpSpec::new("tensor.empty").results(&[ty]).build(out, Some(block));
    operands.push(out.result(empty));
    let mut spec = OpSpec::new("linalg.generic").operands(&operands).results(&[ty]).regions(1).loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = spec.prop(&k, v);
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, Some(block));
    let region = out.region_of(new, 0);
    out.clone_region_into(src, o.regions[0], region, map)?;
    map.insert(at, out.result(new));
    cx.skip.extend(chain);
    Ok(true)
}

/// The op that defines `v`, if an op does.
fn def(m: &Module, v: ValueId) -> Option<OpId> {
    match m.values[v.index()].def {
        ValueDef::Result { op, .. } => Some(op),
        _ => None,
    }
}

/// A folded result: a new blob's key, the result's type, its alignment and
/// its bytes.
type Folded = (String, TypeId, u32, Vec<u8>);

/// The folded result of `op`, if it can be folded.
fn fold(src: &Module, op: OpId, resources: &Resources, made: &mut usize) -> Result<Option<Folded>, String> {
    let o = &src.ops[op.index()];
    if o.operands.len() != 2 || o.results.len() != 1 || crate::bufferize::inputs_of(src, op) != 1 {
        return Ok(None);
    }
    // A constant from a blob, into an empty tensor.
    let Some(c) = def(src, o.operands[0]).filter(|&c| src.op_name(c) == "arith.constant") else { return Ok(None) };
    let key = match src.op_attr(c, "value").map(|a| src.attr(src.resolve_attr(a))) {
        Some(Attr::Builtin { keyword: "dense_resource", body, .. }) => body[1..body.len() - 1].trim().to_string(),
        _ => return Ok(None),
    };
    if def(src, o.operands[1]).is_none_or(|e| src.op_name(e) != "tensor.empty") {
        return Ok(None);
    }
    // A body that yields the input's element.
    let body = src.regions[o.regions[0].index()].blocks[0];
    let ops = &src.blocks[body.index()].ops;
    let [y] = ops[..] else { return Ok(None) };
    if src.op_name(y) != "linalg.yield" || src.ops[y.index()].operands != [src.blocks[body.index()].args[0]] {
        return Ok(None);
    }
    // An identity for the output, a permutation for the input.
    let Some(Attr::Array(ms)) = src.op_attr(op, "indexing_maps").map(|a| src.attr(src.resolve_attr(a))) else {
        return Ok(None);
    };
    let maps: Vec<Map> = ms
        .iter()
        .filter_map(|&m| match src.attr(src.resolve_attr(m)) {
            Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]).ok(),
            _ => None,
        })
        .collect();
    let [input, output] = &maps[..] else { return Ok(None) };
    let n = output.dims;
    if *output != Map::identity(n) || input.dims != n || input.results.len() != n {
        return Ok(None);
    }
    let perm: Vec<usize> =
        input.results.iter().filter_map(|e| if let Expr::Dim(d) = e { Some(*d) } else { None }).collect();
    if perm.len() != n || perm.iter().collect::<HashSet<_>>().len() != n {
        return Ok(None);
    }
    let (Some((in_shape, elem)), Some((out_shape, _))) =
        (src.shaped(src.value_type(o.operands[0])), src.shaped(src.value_type(o.results[0])))
    else {
        return Ok(None);
    };
    let size = match src.ty(elem) {
        Type::Int { width, .. } if width % 8 == 0 => *width as usize / 8,
        Type::Float(f) => match *f {
            "f64" => 8,
            "f32" => 4,
            "f16" | "bf16" => 2,
            _ => return Ok(None),
        },
        _ => return Ok(None),
    };
    let data = resources.get(&key).ok_or_else(|| format!("no resource {key}"))?;
    let count: u64 = out_shape.iter().product();
    if data.len() as u64 != count * size as u64 {
        return Ok(None);
    }

    // Output element at index i reads input element at map(i): input
    // dimension k is loop perm[k].
    let in_strides = crate::build::row_major_strides(&in_shape);
    let mut stride_of_loop = vec![0u64; n];
    for (k, &d) in perm.iter().enumerate() {
        stride_of_loop[d] = in_strides[k];
    }
    let mut bytes = vec![0u8; data.len()];
    let mut idx = vec![0u64; n];
    let mut from = 0u64;
    for i in 0..count as usize {
        let f = from as usize * size;
        bytes[i * size..(i + 1) * size].copy_from_slice(&data[f..f + size]);
        // The next index, the last dimension fastest.
        for d in (0..n).rev() {
            idx[d] += 1;
            from += stride_of_loop[d];
            if idx[d] < out_shape[d] {
                break;
            }
            from -= stride_of_loop[d] * idx[d];
            idx[d] = 0;
        }
    }
    *made += 1;
    let new_key = format!("{key}.folded{made}");
    let ty = src.value_type(o.results[0]);
    Ok(Some((new_key, ty, size as u32, bytes)))
}

/// Removes `arith.constant`s of tensors that nothing uses.
fn drop_unused_constants(m: &mut Module) {
    let mut used: HashSet<ValueId> = HashSet::new();
    for o in &m.ops {
        used.extend(o.operands.iter().copied());
    }
    for b in 0..m.blocks.len() {
        let ops = std::mem::take(&mut m.blocks[b].ops);
        let kept = ops
            .into_iter()
            .filter(|&op| {
                let o = &m.ops[op.index()];
                !(m.name(o.name) == "arith.constant"
                    && o.results.len() == 1
                    && matches!(m.ty(m.value_type(o.results[0])), Type::Tensor { .. })
                    && !used.contains(&o.results[0]))
            })
            .collect();
        m.blocks[b].ops = kept;
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn a_result_nothing_uses() {
        // The maximum of each row and where it is; only the maximum is used.
        let src = r#""builtin.module"() ({
  "func.func"() <{function_type = (tensor<4x8xf32>, tensor<4xf32>, tensor<4xi64>) -> tensor<4xf32>, sym_name = "m"}> ({
  ^bb0(%x: tensor<4x8xf32>, %a: tensor<4xf32>, %b: tensor<4xi64>):
    %r:2 = "linalg.generic"(%x, %a, %b) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0)>, affine_map<(d0, d1) -> (d0)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 2>}> ({
    ^bb0(%p: f32, %q: f32, %i: i64):
      %0 = "linalg.index"() <{dim = 1 : i64}> : () -> index
      %1 = "arith.index_cast"(%0) : (index) -> i64
      %2 = "arith.maximumf"(%p, %q) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %3 = "arith.cmpf"(%p, %q) <{fastmath = #arith.fastmath<none>, predicate = 2 : i64}> : (f32, f32) -> i1
      %4 = "arith.select"(%3, %1, %i) : (i1, i64, i64) -> i64
      "linalg.yield"(%2, %4) : (f32, i64) -> ()
    }) : (tensor<4x8xf32>, tensor<4xf32>, tensor<4xi64>) -> (tensor<4xf32>, tensor<4xi64>)
    "func.return"(%r#0) : (tensor<4xf32>) -> ()
  }) : () -> ()
}) : () -> ()
"#;
        let text = super::run(&crate::parse_module(src).unwrap()).unwrap().to_string();
        for gone in ["linalg.index", "arith.select", "arith.cmpf", "-> (tensor<4xf32>, tensor<4xi64>)"] {
            assert!(!text.contains(gone), "{gone} is still there:\n{text}");
        }
        assert!(text.contains("operandSegmentSizes = array<i32: 1, 1>"), "{text}");
        crate::parse_module(&text).unwrap();
    }

    #[test]
    fn a_map_only_sliced() {
        // x != 0 of all of x, then a slice of a slice of it: only the slice
        // is worked out.
        let src = r#""builtin.module"() ({
  "func.func"() <{function_type = (tensor<8x8xi8>) -> tensor<2x3xi1>, sym_name = "m"}> ({
  ^bb0(%x: tensor<8x8xi8>):
    %z = "arith.constant"() <{value = 0 : i8}> : () -> i8
    %e = "tensor.empty"() : () -> tensor<8x8xi1>
    %r = "linalg.generic"(%x, %e) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: i8, %b: i1):
      %c = "arith.cmpi"(%a, %z) <{predicate = 1 : i64}> : (i8, i8) -> i1
      "linalg.yield"(%c) : (i1) -> ()
    }) : (tensor<8x8xi8>, tensor<8x8xi1>) -> tensor<8x8xi1>
    %s = "tensor.extract_slice"(%r) <{operandSegmentSizes = array<i32: 1, 0, 0, 0>, static_offsets = array<i64: 1, 0>, static_sizes = array<i64: 4, 8>, static_strides = array<i64: 1, 1>}> : (tensor<8x8xi1>) -> tensor<4x8xi1>
    %t = "tensor.extract_slice"(%s) <{operandSegmentSizes = array<i32: 1, 0, 0, 0>, static_offsets = array<i64: 2, 5>, static_sizes = array<i64: 2, 3>, static_strides = array<i64: 1, 1>}> : (tensor<4x8xi1>) -> tensor<2x3xi1>
    "func.return"(%t) : (tensor<2x3xi1>) -> ()
  }) : () -> ()
}) : () -> ()
"#;
        let text = super::run(&crate::parse_module(src).unwrap()).unwrap().to_string();
        assert!(text.contains("static_offsets = array<i64: 3, 5>"), "{text}");
        assert!(text.contains("(tensor<2x3xi8>, tensor<2x3xi1>) -> tensor<2x3xi1>"), "{text}");
        assert!(!text.contains("tensor<4x8xi1>") && !text.contains("(tensor<8x8xi8>, tensor<8x8xi1>)"), "{text}");
        crate::parse_module(&text).unwrap();
    }

    #[test]
    fn a_transpose_of_a_constant() {
        // 2 x 3 of 1..6, transposed: 3 x 2 of 1 4 2 5 3 6.
        let words: String =
            [1f32, 2., 3., 4., 5., 6.].iter().flat_map(|f| f.to_le_bytes()).map(|b| format!("{b:02X}")).collect();
        let src = format!(
            r#""builtin.module"() ({{
  "func.func"() <{{function_type = () -> tensor<3x2xf32>, sym_name = "t"}}> ({{
    %c = "arith.constant"() <{{value = dense_resource<w> : tensor<2x3xf32>}}> : () -> tensor<2x3xf32>
    %e = "tensor.empty"() : () -> tensor<3x2xf32>
    %t = "linalg.generic"(%c, %e) <{{indexing_maps = [affine_map<(d0, d1) -> (d1, d0)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}}> ({{
    ^bb0(%x: f32, %y: f32):
      "linalg.yield"(%x) : (f32) -> ()
    }}) : (tensor<2x3xf32>, tensor<3x2xf32>) -> tensor<3x2xf32>
    "func.return"(%t) : (tensor<3x2xf32>) -> ()
  }}) : () -> ()
}}) : () -> ()
{{-#
  dialect_resources: {{
    builtin: {{
      w: "0x04000000{words}"
    }}
  }}
#-}}
"#
        );
        let m = super::run(&crate::parse_module(&src).unwrap()).unwrap();
        let text = m.to_string();
        assert!(!text.contains("linalg.generic"), "{text}");
        assert!(!text.contains("dense_resource<w> "), "the unused constant is dropped:\n{text}");
        let got = m.resources().get("w.folded1").unwrap().into_owned();
        let floats: Vec<f32> = got.chunks(4).map(|c| f32::from_le_bytes(c.try_into().unwrap())).collect();
        assert_eq!(floats, [1., 4., 2., 5., 3., 6.]);
        // It prints and reads back.
        let again = crate::parse_module(&text).unwrap();
        assert_eq!(again.resources().get("w.folded1").unwrap().into_owned(), got);
    }
}
