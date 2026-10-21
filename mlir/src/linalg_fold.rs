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
    for top in src.top_ops().collect::<Vec<_>>() {
        copy(src, top, &mut out, None, &mut map, &resources, &mut made, &mut blobs)?;
    }
    // The new blobs, before the file's own resources.
    let at = out.items.iter().position(|i| matches!(i, Item::Resources(_))).unwrap_or(out.items.len());
    for (k, b) in blobs.into_iter().enumerate() {
        out.items.insert(at + k, b);
    }
    drop_unused_constants(&mut out);
    Ok(out)
}

#[allow(clippy::too_many_arguments)]
fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    map: &mut HashMap<ValueId, ValueId>,
    resources: &Resources,
    made: &mut usize,
    blobs: &mut Vec<Item>,
) -> Result<(), String> {
    if src.op_name(op) == "linalg.generic"
        && let Some(block) = block
        && let Some((key, ty, align, bytes)) = fold(src, op, resources, made)?
    {
        let attr = out.intern_attr(Attr::Builtin { keyword: "dense_resource", body: format!("<{key}>"), ty: Some(ty) });
        let c = OpSpec::new("arith.constant").results(&[ty]).prop("value", attr).build(out, Some(block));
        let v = out.result(c);
        map.insert(src.ops[op.index()].results[0], v);
        blobs.push(Item::Blob { key, align, bytes: Arc::new(bytes) });
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
                copy(src, inner, out, Some(nb), map, resources, made, blobs)?;
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
