//! Each `linalg` operation on buffers into a function of its own, called
//! where it was: so that a model's one huge function becomes many small
//! ones, which the code generator allocates registers for far better, and
//! which a profiler can tell apart.
//!
//! The function is named after the one it came from, the operation's
//! number in it, and what it does: `forward.17.matmul`, `forward.18.map`
//! (element by element), `forward.19.reduce`, `forward.20.fill`. Its
//! arguments are the operation's operands and any value from outside that
//! its body uses. Runs on buffers, after `bufferize` (and
//! `linalg-to-kernels`), before `linalg-to-loops`.

use std::collections::HashMap;

use crate::build::OpSpec;
use crate::ir::*;

/// Outlines every `linalg.generic` and `linalg.fill` in `src`.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
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
        let mut map = HashMap::new();
        for &r in &o.regions {
            for &b in &src.regions[r.index()].blocks {
                for &op in &src.blocks[b.index()].ops {
                    if src.op_name(op) == "func.func" {
                        func(src, op, &mut out, mblock, &mut map)?;
                    } else {
                        out.clone_op(src, op, Some(mblock), &mut map)?;
                    }
                }
            }
        }
    }
    Ok(out)
}

fn dict(m: &Module, d: Option<AttrId>) -> Vec<(String, AttrId)> {
    match d.map(|d| m.attr(d)) {
        Some(Attr::Dict(es)) => es.clone(),
        _ => Vec::new(),
    }
}

fn func(
    src: &Module,
    f: OpId,
    out: &mut Module,
    mblock: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let o = &src.ops[f.index()];
    let mut spec = OpSpec::new("func.func").regions(o.regions.len()).loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = spec.prop(&k, v);
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, Some(mblock));
    let mut count = 0;
    for (k, &r) in o.regions.iter().enumerate() {
        let region = out.region_of(new, k);
        for &b in &src.regions[r.index()].blocks {
            let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
            let nb = out.add_block(region, &types);
            for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
                map.insert(a, n);
            }
            for &op in &src.blocks[b.index()].ops {
                if matches!(src.op_name(op), "linalg.generic" | "linalg.fill") {
                    count += 1;
                    outline(src, op, out, nb, mblock, &format!("{name}.{count}"), map)?;
                } else {
                    out.clone_op(src, op, Some(nb), map)?;
                }
            }
        }
    }
    Ok(())
}

/// What an operation does, for its function's name.
fn kind(src: &Module, op: OpId) -> &'static str {
    if src.op_name(op) == "linalg.fill" {
        return "fill";
    }
    let reduces = match src.op_attr(op, "iterator_types").map(|a| src.attr(src.resolve_attr(a))) {
        Some(Attr::Array(es)) => {
            es.iter().any(|&e| matches!(src.attr(e), Attr::Dialect { body: Some(b), .. } if b.contains("reduction")))
        }
        _ => false,
    };
    let body = src.regions[src.ops[op.index()].regions[0].index()].blocks[0];
    let names: Vec<&str> = src.blocks[body.index()].ops.iter().map(|&o| src.op_name(o)).collect();
    match (reduces, names.as_slice()) {
        (true, ["arith.mulf", "arith.addf", _] | ["arith.muli", "arith.addi", _]) => "matmul",
        (true, _) => "reduce",
        (false, [_]) => "copy",
        (false, _) => "map",
    }
}

/// Values that `op`'s regions use but do not define.
fn captured(src: &Module, op: OpId) -> Vec<ValueId> {
    let mut defined = std::collections::HashSet::new();
    let mut used = Vec::new();
    src.walk(op, &mut |inner| {
        if inner != op {
            defined.extend(src.ops[inner.index()].results.iter().copied());
        }
        for &r in &src.ops[inner.index()].regions {
            for &b in &src.regions[r.index()].blocks {
                defined.extend(src.blocks[b.index()].args.iter().copied());
            }
        }
    });
    src.walk(op, &mut |inner| {
        if inner == op {
            return;
        }
        for &v in &src.ops[inner.index()].operands {
            if !defined.contains(&v) && !used.contains(&v) {
                used.push(v);
            }
        }
    });
    used
}

fn outline(
    src: &Module,
    op: OpId,
    out: &mut Module,
    at: BlockId,
    mblock: BlockId,
    base: &str,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let o = &src.ops[op.index()];
    let mut params: Vec<ValueId> = o.operands.clone();
    // Scalar constants the body uses are copied in, not passed: they stay
    // constants (x to the constant power 2 is then a multiply).
    let mut constants = Vec::new();
    for v in captured(src, op) {
        let constant = match src.values[v.index()].def {
            ValueDef::Result { op: c, .. } => {
                src.op_name(c) == "arith.constant" && src.shaped(src.value_type(v)).is_none()
            }
            _ => false,
        };
        if constant {
            constants.push(v);
        } else if !params.contains(&v) {
            params.push(v);
        }
    }
    let types: Vec<TypeId> = params.iter().map(|&v| src.value_type(v)).collect();
    let fname = format!("{base}.{}", kind(src, op));

    // The function: its arguments stand for the values it was given.
    let fty = out.function_type(&types, &[]);
    let fty = out.type_attr(fty);
    let sym = out.string_attr(&fname);
    let vis = out.string_attr("private");
    // Kept a function, or the optimiser inlines it back, each being called
    // once.
    let unit = out.unit_attr();
    let f = OpSpec::new("func.func")
        .prop("function_type", fty)
        .prop("sym_name", sym)
        .prop("sym_visibility", vis)
        .attr("llvm.no_inline", unit)
        .regions(1)
        .build(out, Some(mblock));
    let region = out.region_of(f, 0);
    let entry = out.add_block(region, &types);
    let mut inner: HashMap<ValueId, ValueId> =
        params.iter().copied().zip(out.blocks[entry.index()].args.clone()).collect();
    for c in constants {
        let ValueDef::Result { op: def, .. } = src.values[c.index()].def else { unreachable!() };
        out.clone_op(src, def, Some(entry), &mut inner)?;
    }
    out.clone_op(src, op, Some(entry), &mut inner)?;
    OpSpec::new("func.return").build(out, Some(entry));

    // The call, where the operation was.
    let args =
        params.iter().map(|v| map.get(v).copied().ok_or("an operand from outside")).collect::<Result<Vec<_>, _>>()?;
    let callee = out.symbol_attr(&fname);
    OpSpec::new("func.call").operands(&args).prop("callee", callee).loc(o.loc).build(out, Some(at));
    Ok(())
}
