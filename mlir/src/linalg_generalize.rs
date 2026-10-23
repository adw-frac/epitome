//! Named `linalg` operations to `linalg.generic`, as upstream's
//! `linalg-generalize-named-ops` does. A named operation is a generic one
//! whose indexing maps are fixed by its name and properties; its body is
//! already written out in the generic form. So each becomes a
//! `linalg.generic` with the same operands and body, and maps worked out
//! from what it says:
//!
//! | Operation | Maps |
//! | --- | --- |
//! | `linalg.matmul`, `linalg.batch_matmul` | its `indexing_maps`, or the usual ones |
//! | `linalg.transpose` | the input read through `permutation` |
//! | `linalg.broadcast` | the input without the output's `dimensions` |
//! | `linalg.map` | identities |
//! | `linalg.conv_2d_nchw_fchw` | from `strides` and `dilations` |
//!
//! A dimension of the iteration space that the output's map does not use
//! is a reduction. Everything else is copied. This works on tensors and on
//! buffers alike.

use std::collections::HashMap;

use crate::affine::{Expr, Map};
use crate::build::OpSpec;
use crate::ir::*;

/// Generalizes every named `linalg` operation in `src`.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
    let mut map = HashMap::new();
    for top in src.top_ops().collect::<Vec<_>>() {
        copy(src, top, &mut out, None, &mut map)?;
    }
    Ok(out)
}

/// The named operations this pass generalizes.
pub const NAMED: &[&str] = &[
    "linalg.matmul",
    "linalg.batch_matmul",
    "linalg.transpose",
    "linalg.broadcast",
    "linalg.map",
    "linalg.conv_2d_nchw_fchw",
];

fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let name = src.op_name(op);
    if NAMED.contains(&name) {
        let block = block.ok_or("a linalg operation outside a function")?;
        return generalize(src, op, out, block, map).map_err(|e| format!("{name}: {e}"));
    }
    let o = &src.ops[op.index()];
    if o.regions.is_empty() {
        out.clone_op(src, op, block, map)?;
        return Ok(());
    }
    // The operation with empty regions, then its blocks copied by this
    // function, so that operations nested in them are generalized too.
    let operands = o
        .operands
        .iter()
        .map(|v| map.get(v).copied().ok_or("an operand from outside"))
        .collect::<Result<Vec<_>, _>>()?;
    let results: Vec<TypeId> = o.results.iter().map(|&r| src.value_type(r)).collect();
    let mut spec = OpSpec::new(name).operands(&operands).results(&results).regions(o.regions.len()).loc(o.loc);
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
                if !src.ops[inner.index()].successors.is_empty() {
                    return Err("branches between blocks are not supported here".into());
                }
                copy(src, inner, out, Some(nb), map)?;
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

/// The rank of a shaped value's type.
fn rank(m: &Module, v: ValueId) -> Result<usize, String> {
    m.shaped(m.value_type(v)).map(|(s, _)| s.len()).ok_or_else(|| "an operand of unknown shape".to_string())
}

/// `[a, b]` from `dense<[a, b]> : vector<2xi64>`, `dense<a> : ...` (a
/// splat), or `array<i64: a, b>`.
fn ints(m: &Module, attr: AttrId, n: usize) -> Result<Vec<i64>, String> {
    if let Some(l) = m.int_list(attr) {
        return Ok(l);
    }
    match m.attr(m.resolve_attr(attr)) {
        Attr::Builtin { keyword: "dense", body, .. } => {
            let inner = body[1..body.len() - 1].trim();
            let values: Vec<i64> = inner
                .trim_start_matches('[')
                .trim_end_matches(']')
                .split(',')
                .map(|s| s.trim().parse().map_err(|_| format!("'{s}' is not an integer")))
                .collect::<Result<_, _>>()?;
            Ok(if values.len() == 1 { vec![values[0]; n] } else { values })
        }
        _ => Err(format!("expected a list of integers, found {}", crate::printer::attr_text(m, attr))),
    }
}

fn affine_of(m: &Module, attr: AttrId) -> Result<Map, String> {
    match m.attr(m.resolve_attr(attr)) {
        Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]),
        _ => Err(format!("expected an affine map, found {}", crate::printer::attr_text(m, attr))),
    }
}

fn generalize(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let o = &src.ops[op.index()];
    let name = src.op_name(op);
    let (&init, ins) = o.operands.split_last().ok_or("no operands")?;
    let n_out = rank(src, init)?;
    let prop = |k: &str| src.op_attr(op, k).ok_or_else(|| format!("no '{k}'"));

    let maps: Vec<Map> = match name {
        "linalg.matmul" | "linalg.batch_matmul" => match src.op_attr(op, "indexing_maps") {
            Some(list) => {
                let Attr::Array(ms) = src.attr(src.resolve_attr(list)) else {
                    return Err("indexing_maps is not a list".into());
                };
                ms.iter().map(|&m| affine_of(src, m)).collect::<Result<_, _>>()?
            }
            None if name == "linalg.matmul" => {
                ["(d0, d1, d2) -> (d0, d2)", "(d0, d1, d2) -> (d2, d1)", "(d0, d1, d2) -> (d0, d1)"]
                    .iter()
                    .map(|t| Map::parse(t))
                    .collect::<Result<_, _>>()?
            }
            None => [
                "(d0, d1, d2, d3) -> (d0, d1, d3)",
                "(d0, d1, d2, d3) -> (d0, d3, d2)",
                "(d0, d1, d2, d3) -> (d0, d1, d2)",
            ]
            .iter()
            .map(|t| Map::parse(t))
            .collect::<Result<_, _>>()?,
        },
        "linalg.transpose" => {
            // dim(result, i) = dim(input, permutation[i]).
            let perm = ints(src, prop("permutation")?, n_out)?;
            let mut input = vec![Expr::Const(0); n_out];
            for (i, &p) in perm.iter().enumerate() {
                *input.get_mut(p as usize).ok_or("a permutation out of range")? = Expr::Dim(i);
            }
            vec![Map { dims: n_out, syms: 0, results: input }, Map::identity(n_out)]
        }
        "linalg.broadcast" => {
            // The input has the output's dimensions but these.
            let added = ints(src, prop("dimensions")?, 0)?;
            let input = (0..n_out).filter(|d| !added.contains(&(*d as i64))).map(Expr::Dim).collect();
            vec![Map { dims: n_out, syms: 0, results: input }, Map::identity(n_out)]
        }
        "linalg.map" => vec![Map::identity(n_out); ins.len() + 1],
        "linalg.conv_2d_nchw_fchw" => {
            let s = ints(src, prop("strides")?, 2)?;
            let d = ints(src, prop("dilations")?, 2)?;
            let text = format!(
                "(d0, d1, d2, d3, d4, d5, d6) -> (d0, d4, d2 * {} + d5 * {}, d3 * {} + d6 * {})",
                s[0], d[0], s[1], d[1]
            );
            let input = Map::parse(&text)?;
            let input = Map { results: input.results.iter().map(Expr::simplify).collect(), ..input };
            vec![
                input,
                Map::parse("(d0, d1, d2, d3, d4, d5, d6) -> (d1, d4, d5, d6)")?,
                Map::parse("(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)")?,
            ]
        }
        _ => unreachable!(),
    };
    if maps.len() != o.operands.len() {
        return Err(format!("{} maps for {} operands", maps.len(), o.operands.len()));
    }
    // A dimension the output does not use is summed over.
    let used: Vec<usize> = maps
        .last()
        .unwrap()
        .results
        .iter()
        .filter_map(|e| if let Expr::Dim(d) = e { Some(*d) } else { None })
        .collect();
    let iterators: Vec<AttrId> = (0..maps[0].dims)
        .map(|d| {
            let kind = if used.contains(&d) { "<parallel>" } else { "<reduction>" };
            out.dialect_attr("linalg.iterator_type", Some(kind))
        })
        .collect();

    let operands = o
        .operands
        .iter()
        .map(|v| map.get(v).copied().ok_or("an operand from outside"))
        .collect::<Result<Vec<_>, _>>()?;
    let results: Vec<TypeId> = o.results.iter().map(|&r| src.value_type(r)).collect();
    let maps_attr: Vec<AttrId> = maps.iter().map(|m| out.affine_map_attr(&m.to_string())).collect();
    let maps_attr = out.array_attr(maps_attr);
    let iterators = out.array_attr(iterators);
    let segments = out.dense_array_attr("i32", &[ins.len() as i64, 1]);
    let g = OpSpec::new("linalg.generic")
        .operands(&operands)
        .results(&results)
        .prop("indexing_maps", maps_attr)
        .prop("iterator_types", iterators)
        .prop("operandSegmentSizes", segments)
        .regions(1)
        .loc(o.loc)
        .build(out, Some(block));
    for (&old, &n) in o.results.iter().zip(&out.ops[g.index()].results.clone()) {
        map.insert(old, n);
    }

    // The body: the same, with an argument for the output's element if
    // the named operation's body has none (`linalg.map`).
    let body = src.regions[o.regions.first().ok_or("no body")?.index()].blocks[0];
    let mut types: Vec<TypeId> = src.blocks[body.index()].args.iter().map(|&a| src.value_type(a)).collect();
    if types.len() == ins.len() {
        let elem = src.shaped(src.value_type(init)).ok_or("an output of unknown shape")?.1;
        types.push(elem);
    }
    if types.len() != ins.len() + 1 {
        return Err(format!("a body of {} arguments for {} operands", types.len(), o.operands.len()));
    }
    let region = out.region_of(g, 0);
    let nb = out.add_block(region, &types);
    for (&a, &n) in src.blocks[body.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
        map.insert(a, n);
    }
    for &inner in &src.blocks[body.index()].ops {
        copy(src, inner, out, Some(nb), map)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::parse_module;

    #[test]
    fn named_operations_become_generic() {
        let src = r#""func.func"() <{function_type = (tensor<8x4xf32>, tensor<4x8xf32>) -> tensor<4x8xf32>, sym_name = "t"}> ({
^bb0(%arg0: tensor<8x4xf32>, %arg1: tensor<4x8xf32>):
  %0 = "linalg.transpose"(%arg0, %arg1) <{permutation = array<i64: 1, 0>}> ({
  ^bb0(%arg2: f32, %arg3: f32):
    "linalg.yield"(%arg2) : (f32) -> ()
  }) : (tensor<8x4xf32>, tensor<4x8xf32>) -> tensor<4x8xf32>
  "func.return"(%0) : (tensor<4x8xf32>) -> ()
}) : () -> ()
"#;
        let m = super::run(&parse_module(src).unwrap()).unwrap();
        let text = m.to_string();
        assert!(
            text.contains(
                "\"linalg.generic\"(%arg0, %arg1) <{indexing_maps = [affine_map<(d0, d1) -> (d1, d0)>, \
             affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, \
             #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}>"
            ),
            "{text}"
        );
    }
}
