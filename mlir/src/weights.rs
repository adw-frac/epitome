//! Constant weights out of the program, into a file of their own: for a
//! model whose weights are more than an executable can hold (x86-64 code
//! reaches its data only within 2 GB of itself) or than is worth linking.
//!
//! Each constant `memref.global` of `dense_resource` data at least
//! `min_bytes` long is left out, its bytes put in the weights at a
//! multiple of 64, and each `memref.get_global` of it becomes the address
//! the program gives (`__epitome_weights()`, which it provides: where it
//! has loaded the weights) plus the offset, as the memref. Runs on
//! buffers, before `to-llvm`.

use std::collections::HashMap;

use crate::build::OpSpec;
use crate::ir::*;

/// `src` with its large constant weights left out, and the weights.
pub fn externalize(src: &Module, min_bytes: usize) -> Result<(Module, Vec<u8>), String> {
    let resources = src.resources();
    let mut weights: Vec<u8> = Vec::new();
    let mut offsets: HashMap<String, u64> = HashMap::new();
    let mut keys: std::collections::HashSet<String> = std::collections::HashSet::new();
    let mut out = src.empty_like();
    let mut map = HashMap::new();
    for top in src.top_ops().collect::<Vec<_>>() {
        if src.op_name(top) != "builtin.module" {
            return Err(format!("{}: expected a builtin.module", src.op_name(top)));
        }
        let o = &src.ops[top.index()];
        let mut spec = OpSpec::new("builtin.module").regions(1).loc(o.loc);
        for (k, v) in dict(src, o.properties).into_iter().chain(dict(src, o.attrs)) {
            spec = spec.prop(&k, v);
        }
        let module = spec.build(&mut out, None);
        let region = out.region_of(module, 0);
        let mblock = out.add_block(region, &[]);
        let ops: Vec<OpId> = o
            .regions
            .iter()
            .flat_map(|&r| src.regions[r.index()].blocks.clone())
            .flat_map(|b| src.blocks[b.index()].ops.clone())
            .collect();
        // The weights to leave out.
        for &op in &ops {
            if src.op_name(op) != "memref.global" || src.op_attr(op, "constant").is_none() {
                continue;
            }
            let Some(Attr::Builtin { keyword: "dense_resource", body, .. }) =
                src.op_attr(op, "initial_value").map(|a| src.attr(src.resolve_attr(a)))
            else {
                continue;
            };
            let key = body.trim_start_matches('<').split(['>', ':']).next().unwrap_or("").trim();
            let Some(bytes) = resources.get(key) else { continue };
            if bytes.len() < min_bytes {
                continue;
            }
            let name = src.op_attr(op, "sym_name").and_then(|a| src.string_of(a)).ok_or("a global without a name")?;
            weights.resize(weights.len().next_multiple_of(64), 0);
            offsets.insert(name, weights.len() as u64);
            keys.insert(key.to_string());
            weights.extend_from_slice(&bytes);
        }
        if offsets.is_empty() {
            return Ok((src.clone(), weights));
        }
        let ptr = out.dialect_type("llvm.ptr", None);
        let fty = out.function_type(&[], &[ptr]);
        let fty = out.type_attr(fty);
        let sym = out.string_attr("__epitome_weights");
        let vis = out.string_attr("private");
        OpSpec::new("func.func")
            .prop("function_type", fty)
            .prop("sym_name", sym)
            .prop("sym_visibility", vis)
            .regions(1)
            .build(&mut out, Some(mblock));
        for &op in &ops {
            let left_out = src.op_name(op) == "memref.global"
                && src.op_attr(op, "sym_name").and_then(|a| src.string_of(a)).is_some_and(|n| offsets.contains_key(&n));
            if !left_out {
                copy(src, op, &mut out, mblock, &mut map, &offsets)?;
            }
        }
    }
    // Their data, not needed any more.
    for item in &mut out.items {
        match item {
            Item::Resources(text) => {
                let kept: Vec<&str> = text
                    .lines()
                    .filter(|line| {
                        let key = line.trim().split_once(':').map(|(k, _)| k.trim().trim_matches('"'));
                        !key.is_some_and(|k| keys.contains(k))
                    })
                    .collect();
                *text = kept.join("\n").into();
            }
            Item::Blob { key, bytes, .. } if keys.contains(key.as_str()) => *bytes = std::sync::Arc::new(Vec::new()),
            _ => {}
        }
    }
    Ok((out, weights))
}

fn dict(m: &Module, d: Option<AttrId>) -> Vec<(String, AttrId)> {
    match d.map(|d| m.attr(d)) {
        Some(Attr::Dict(es)) => es.clone(),
        _ => Vec::new(),
    }
}

/// `op` copied to the end of `block`, as `clone_op` does, but each
/// `memref.get_global` of weights left out (at `offsets`) the address in
/// the weights.
fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
    offsets: &HashMap<String, u64>,
) -> Result<(), String> {
    let o = &src.ops[op.index()];
    if src.op_name(op) == "memref.get_global" {
        let name = match src.op_attr(op, "name").map(|a| src.attr(a)) {
            Some(Attr::SymbolRef(p)) => p[0].clone(),
            _ => String::new(),
        };
        if let Some(&offset) = offsets.get(&name) {
            let ptr = out.dialect_type("llvm.ptr", None);
            let i64t = out.int_type(64);
            let i32t = out.int_type(32);
            let i8t = out.int_type(8);
            let callee = out.symbol_attr("__epitome_weights");
            let call = OpSpec::new("func.call").results(&[ptr]).prop("callee", callee).build(out, Some(block));
            let base = out.result(call);
            let attr = out.int_attr(offset as i64, i64t);
            let c = OpSpec::new("llvm.mlir.constant").results(&[i64t]).prop("value", attr).build(out, Some(block));
            let c = out.result(c);
            let et = out.type_attr(i8t);
            let nw = out.int_attr(0, i32t);
            let raw = out.dense_array_attr("i32", &[i32::MIN as i64]);
            let g = OpSpec::new("llvm.getelementptr")
                .operands(&[base, c])
                .results(&[ptr])
                .prop("elem_type", et)
                .prop("noWrapFlags", nw)
                .prop("rawConstantIndices", raw)
                .build(out, Some(block));
            let p = out.result(g);
            let cast = OpSpec::new("builtin.unrealized_conversion_cast")
                .operands(&[p])
                .results(&[src.value_type(o.results[0])])
                .loc(o.loc)
                .build(out, Some(block));
            let r = out.result(cast);
            map.insert(o.results[0], r);
            return Ok(());
        }
    }
    let operands = o
        .operands
        .iter()
        .map(|v| map.get(v).copied().ok_or_else(|| format!("{}: an operand from outside", src.op_name(op))))
        .collect::<Result<Vec<_>, _>>()?;
    let results: Vec<TypeId> = o.results.iter().map(|&r| src.value_type(r)).collect();
    let mut spec = OpSpec::new(src.op_name(op)).operands(&operands).results(&results).loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = spec.prop(&k, v);
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.regions(o.regions.len()).build(out, Some(block));
    for (&old, &n) in o.results.iter().zip(&out.ops[new.index()].results.clone()) {
        map.insert(old, n);
    }
    for (k, &r) in o.regions.iter().enumerate() {
        let region = out.region_of(new, k);
        let blocks = &src.regions[r.index()].blocks;
        let mut new_blocks = Vec::new();
        for &b in blocks {
            let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
            let nb = out.add_block(region, &types);
            for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
                map.insert(a, n);
            }
            new_blocks.push(nb);
        }
        for (&b, &nb) in blocks.iter().zip(&new_blocks) {
            for &inner in &src.blocks[b.index()].ops {
                copy(src, inner, out, nb, map, offsets)?;
                let succ: Vec<BlockId> = src.ops[inner.index()]
                    .successors
                    .iter()
                    .map(|s| new_blocks[blocks.iter().position(|x| x == s).expect("a successor in the region")])
                    .collect();
                let last = *out.blocks[nb.index()].ops.last().unwrap();
                if !succ.is_empty() {
                    out.ops[last.index()].successors = succ;
                }
            }
        }
    }
    Ok(())
}
