//! `linalg` on buffers to a target's kernels: a `linalg.generic` that a
//! kernel computes is done a tile at a time by calls to the kernel's
//! function, as upstream lowers `linalg.matmul` to `arm_sme` outer products
//! on AArch64 with SME.
//!
//! Which operations a target has kernels for, and the kernels themselves,
//! are data: `mlir/targets/<name>.mlir` (the pass is
//! `linalg-to-kernels=<name>`, or `=<path>` for a file of one's own). Each
//! `epitome.kernel` there gives the indexing maps, iterators, body and
//! element type of the `linalg.generic` it computes, the size of a tile of
//! the output, and the function that computes one; the file defines the
//! function, which this pass copies into the module.
//!
//! So far kernels multiply matrices, `C[m, n] += A[m, k] B[k, n]`. The pass
//! packs A transposed, so that a column of a tile of A is contiguous, then
//! calls the function for each tile of C:
//! `(c, ldc, at, lda, b, ldb, k, cols)`, pointers and row strides in
//! elements. Rows of C past the last whole tile are left to a
//! `linalg.generic` on views of A and C; the last tile of columns may be
//! narrower, and `cols` says by how much. The pass runs after
//! `bufferize` and before `linalg-to-loops`.

use std::collections::HashMap;
use std::sync::OnceLock;

use crate::affine::Map;
use crate::build::{OpSpec, row_major_strides, strided_attr, strided_layout};
use crate::ir::*;

const BUILT_IN: &[(&str, &str)] = &[("aarch64-sme", include_str!("../targets/aarch64-sme.mlir"))];

/// Lowers what `kernels` (a name in `mlir/targets`, or a path) has kernels
/// for.
pub fn run(src: &Module, kernels: &str) -> Result<Module, String> {
    let set = load(kernels)?;
    let mut out = src.empty_like();
    let mut imported: HashMap<String, String> = HashMap::new();
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
        let block = out.add_block(region, &[]);
        let mut map = HashMap::new();
        for &r in &o.regions {
            for &b in &src.regions[r.index()].blocks {
                for &op in &src.blocks[b.index()].ops {
                    if src.op_name(op) == "func.func" {
                        func(src, op, &mut out, block, set, &mut imported, &mut map)?;
                    } else {
                        out.clone_op(src, op, Some(block), &mut map)?;
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

/// A target's kernels: the module of its file, and each kernel's
/// description.
struct Set {
    m: Module,
    kernels: Vec<Kernel>,
}

struct Kernel {
    maps: Vec<Map>,
    iterators: Vec<String>,
    body: Vec<String>,
    element: TypeId,
    tile: (u64, u64),
    function: String,
    /// `batch_matmul`: a matrix product for each index of the first
    /// dimension, each done as a `matmul`.
    batch: bool,
    /// The function does every column of a block of rows, its last
    /// argument the number of columns (rather than one tile, its last
    /// argument the tile's width).
    whole_rows: bool,
}

fn load(name: &str) -> Result<&'static Set, String> {
    static SETS: OnceLock<std::sync::Mutex<HashMap<String, &'static Set>>> = OnceLock::new();
    let sets = SETS.get_or_init(Default::default);
    if let Some(&s) = sets.lock().unwrap().get(name) {
        return Ok(s);
    }
    let text = match BUILT_IN.iter().find(|(n, _)| *n == name) {
        Some((_, t)) => t.to_string(),
        None => std::fs::read_to_string(name).map_err(|e| {
            let known: Vec<&str> = BUILT_IN.iter().map(|(n, _)| *n).collect();
            format!("{name}: {e} (built in: {})", known.join(", "))
        })?,
    };
    let m = crate::parse_module(&text).map_err(|e| format!("{name}:{e}"))?;
    let mut kernels = Vec::new();
    for op in m.top_ops() {
        if m.op_name(op) != "epitome.kernel" {
            continue;
        }
        let get = |k: &str| m.op_attr(op, k).ok_or_else(|| format!("{name}: a kernel without '{k}'"));
        let strings = |a: AttrId| -> Vec<String> {
            match m.attr(a) {
                Attr::Array(es) => es.iter().filter_map(|&e| m.string_of(e)).collect(),
                _ => Vec::new(),
            }
        };
        let maps = match m.attr(get("indexing_maps")?) {
            Attr::Array(es) => es
                .iter()
                .map(|&e| match m.attr(e) {
                    Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]),
                    _ => Err("indexing_maps holds something else".to_string()),
                })
                .collect::<Result<Vec<_>, _>>()?,
            _ => return Err(format!("{name}: indexing_maps is not a list")),
        };
        let element = match m.attr(get("element")?) {
            Attr::Type(t) => *t,
            _ => return Err(format!("{name}: element is not a type")),
        };
        let tile = match m.int_list(get("tile")?).as_deref() {
            Some(&[r, c]) => (r as u64, c as u64),
            _ => return Err(format!("{name}: tile should be [rows, columns]")),
        };
        let function = match m.attr(get("function")?) {
            Attr::SymbolRef(p) => p[0].clone(),
            _ => return Err(format!("{name}: function is not a symbol")),
        };
        let batch = match m.op_attr(op, "op").and_then(|a| m.string_of(a)).as_deref() {
            Some("matmul") => false,
            Some("batch_matmul") => true,
            _ => return Err(format!("{name}: only matmul and batch_matmul kernels are supported")),
        };
        kernels.push(Kernel {
            maps,
            iterators: strings(get("iterator_types")?),
            body: strings(get("body")?),
            element,
            tile,
            function,
            batch,
            whole_rows: m.op_attr(op, "whole_rows").is_some(),
        });
    }
    let set: &'static Set = Box::leak(Box::new(Set { m, kernels }));
    sets.lock().unwrap().insert(name.to_string(), set);
    Ok(set)
}

/// A function, its `linalg.generic`s that a kernel computes replaced.
fn func(
    src: &Module,
    f: OpId,
    out: &mut Module,
    parent: BlockId,
    set: &Set,
    imported: &mut HashMap<String, String>,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let o = &src.ops[f.index()];
    let mut spec = OpSpec::new("func.func").regions(o.regions.len()).loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = spec.prop(&k, v);
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, Some(parent));
    for (k, &r) in o.regions.iter().enumerate() {
        let region = out.region_of(new, k);
        for &b in &src.regions[r.index()].blocks {
            let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
            let nb = out.add_block(region, &types);
            for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
                map.insert(a, n);
            }
            for &op in &src.blocks[b.index()].ops {
                // The kernels that compute it, in the order of the file.
                let ks: Vec<&Kernel> = if src.op_name(op) == "linalg.generic" {
                    set.kernels.iter().filter(|k| matches(src, op, &set.m, k)).collect()
                } else {
                    Vec::new()
                };
                let done = match ks.first() {
                    Some(k) if k.batch => batched(src, op, out, nb, parent, set, &ks, imported, map)?,
                    Some(_) => {
                        let o = &src.ops[op.index()];
                        let operands = [o.operands[0], o.operands[1], o.operands[2]].map(|v| map[&v]);
                        let props = dict(src, o.properties);
                        tiles(src, op, operands, &props, out, nb, parent, set, &ks, imported, map)?
                    }
                    None => false,
                };
                if !done {
                    out.clone_op(src, op, Some(nb), map)?;
                }
            }
        }
    }
    Ok(())
}

/// Whether `op` is the `linalg.generic` kernel `k` computes: the same maps,
/// iterators, element type and body.
fn matches(src: &Module, op: OpId, km: &Module, k: &Kernel) -> bool {
    let o = &src.ops[op.index()];
    if crate::bufferize::inputs_of(src, op) != 2 || o.operands.len() != 3 || !o.results.is_empty() {
        return false;
    }
    let Some(Attr::Array(ms)) = src.op_attr(op, "indexing_maps").map(|a| src.attr(src.resolve_attr(a))) else {
        return false;
    };
    let maps: Vec<Option<Map>> = ms
        .iter()
        .map(|&m| match src.attr(src.resolve_attr(m)) {
            Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]).ok(),
            _ => None,
        })
        .collect();
    if maps.len() != k.maps.len() || maps.iter().zip(&k.maps).any(|(a, b)| a.as_ref() != Some(b)) {
        return false;
    }
    let iterators: Vec<String> = match src.op_attr(op, "iterator_types").map(|a| src.attr(src.resolve_attr(a))) {
        Some(Attr::Array(es)) => es
            .iter()
            .filter_map(|&e| match src.attr(e) {
                Attr::Dialect { body: Some(b), .. } => Some(b.trim_matches(|c| c == '<' || c == '>').to_string()),
                _ => None,
            })
            .collect(),
        _ => return false,
    };
    if iterators != k.iterators {
        return false;
    }
    // Every operand's elements are of the kernel's type.
    let elem = crate::printer::type_text(km, k.element);
    if o.operands
        .iter()
        .any(|&v| src.shaped(src.value_type(v)).is_none_or(|(_, e)| crate::printer::type_text(src, e) != elem))
    {
        return false;
    }
    // The body: a product of the inputs, added to the output.
    let body = src.regions[o.regions[0].index()].blocks[0];
    let args = &src.blocks[body.index()].args;
    let ops = &src.blocks[body.index()].ops;
    let names: Vec<&str> = ops.iter().map(|&b| src.op_name(b)).collect();
    if names.len() != k.body.len() + 1
        || names[..k.body.len()] != k.body.iter().map(String::as_str).collect::<Vec<_>>()[..]
    {
        return false;
    }
    let (mul, add, ret) = (&src.ops[ops[0].index()], &src.ops[ops[1].index()], &src.ops[ops[2].index()]);
    let product = mul.operands.len() == 2 && mul.operands.contains(&args[0]) && mul.operands.contains(&args[1]);
    let sum = add.operands.len() == 2 && add.operands.contains(&args[2]) && add.operands.contains(&mul.results[0]);
    product && sum && ret.operands == add.results
}

/// A row-major or strided memref's strides and offset.
fn layout(m: &Module, ty: TypeId) -> Option<(Vec<u64>, u64)> {
    strided_layout(m, ty).or_else(|| m.shaped(ty).map(|(s, _)| (row_major_strides(&s), 0)))
}

/// A `batch_matmul` as a `matmul` for each index of its first dimension,
/// on views of its operands; false (and nothing added) where its shapes do
/// not suit the kernel.
#[allow(clippy::too_many_arguments)]
fn batched(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: BlockId,
    module_block: BlockId,
    set: &Set,
    ks: &[&Kernel],
    imported: &mut HashMap<String, String>,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<bool, String> {
    let o = &src.ops[op.index()];
    let operands = [o.operands[0], o.operands[1], o.operands[2]].map(|v| map[&v]);
    let fewest = ks.iter().map(|k| k.tile.0).min().unwrap_or(u64::MAX);
    let mut shapes = Vec::new();
    for &v in &operands {
        let ty = out.value_type(v);
        let (Some((shape, elem)), Some(l)) = (out.shaped(ty), layout(out, ty)) else { return Ok(false) };
        shapes.push((shape, elem, l));
    }
    let batch = shapes[0].0[0];
    if shapes.iter().any(|s| s.0.len() != 3 || s.0[0] != batch) || shapes[0].0[1] < fewest {
        return Ok(false);
    }
    // A matmul's maps and iterators, for the rows past the last whole tile.
    let maps = ["(d0, d1, d2) -> (d0, d2)", "(d0, d1, d2) -> (d2, d1)", "(d0, d1, d2) -> (d0, d1)"]
        .iter()
        .map(|m| out.affine_map_attr(m))
        .collect();
    let maps = out.array_attr(maps);
    let par = out.dialect_attr("linalg.iterator_type", Some("<parallel>"));
    let red = out.dialect_attr("linalg.iterator_type", Some("<reduction>"));
    let iters = out.array_attr(vec![par, par, red]);
    let segments = out.dense_array_attr("i32", &[2, 1]);
    let props = vec![
        ("indexing_maps".to_string(), maps),
        ("iterator_types".to_string(), iters),
        ("operandSegmentSizes".to_string(), segments),
    ];
    for i in 0..batch {
        // Each operand's matrix i, a rank-reduced view.
        let mut views = [operands[0]; 3];
        for (j, (v, (shape, elem, (strides, offset)))) in operands.iter().zip(&shapes).enumerate() {
            let layout = strided_attr(out, &strides[1..], offset + i * strides[0]);
            let ty = out.memref_type(&shape[1..], *elem, Some(layout));
            let segs = out.dense_array_attr("i32", &[1, 0, 0, 0]);
            let offsets = out.dense_array_attr("i64", &[i as i64, 0, 0]);
            let sizes = out.dense_array_attr("i64", &[1, shape[1] as i64, shape[2] as i64]);
            let ones = out.dense_array_attr("i64", &[1, 1, 1]);
            let s = OpSpec::new("memref.subview")
                .operands(&[*v])
                .results(&[ty])
                .prop("operandSegmentSizes", segs)
                .prop("static_offsets", offsets)
                .prop("static_sizes", sizes)
                .prop("static_strides", ones)
                .build(out, Some(block));
            views[j] = out.result(s);
        }
        if !tiles(src, op, views, &props, out, block, module_block, set, ks, imported, map)? {
            return Err("a batch_matmul whose matrices do not suit the kernel".into());
        }
    }
    Ok(true)
}

/// A matmul of `operands` (A, B and C, already in `out`) as tiles computed
/// by kernel `k`, with `props` for a `linalg.generic` of the rows past the
/// last whole tile (whose body is `op`'s); false (and nothing added) where
/// its shapes do not suit the kernel.
#[allow(clippy::too_many_arguments)]
fn tiles(
    src: &Module,
    op: OpId,
    operands: [ValueId; 3],
    props: &[(String, AttrId)],
    out: &mut Module,
    block: BlockId,
    module_block: BlockId,
    set: &Set,
    ks: &[&Kernel],
    imported: &mut HashMap<String, String>,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<bool, String> {
    let [a, b, c] = operands;
    let (Some((sa, elem)), Some((sb, _)), Some((sc, _))) =
        (out.shaped(out.value_type(a)), out.shaped(out.value_type(b)), out.shaped(out.value_type(c)))
    else {
        return Ok(false);
    };
    let (m, kk, n) = (sa[0], sa[1], sb[1]);
    let (Some(_), Some(lb), Some(lc)) =
        (layout(out, out.value_type(a)), layout(out, out.value_type(b)), layout(out, out.value_type(c)))
    else {
        return Ok(false);
    };
    // The first kernel with a tile no taller than C; rows past its last
    // whole tile go to the next.
    let Some(ki) = ks.iter().position(|k| k.tile.0 <= m) else { return Ok(false) };
    let k = ks[ki];
    // The kernel reads rows of B and C: their elements must be contiguous.
    let full = m / k.tile.0 * k.tile.0;
    if full == 0 || kk == 0 || n == 0 || lb.0[1] != 1 || lc.0[1] != 1 || sc != [m, n] {
        return Ok(false);
    }

    // The kernel's function, once in the module.
    let fname = match imported.get(&k.function) {
        Some(n) => n.clone(),
        None => {
            let f = set
                .m
                .top_ops()
                .find(|&f| {
                    set.m.op_attr(f, "sym_name").and_then(|a| set.m.string_of(a)).as_deref() == Some(&k.function)
                })
                .ok_or_else(|| format!("no function @{} in the kernels", k.function))?;
            out.import_op(&set.m, f, Some(module_block), &mut HashMap::new())?;
            // Before the functions that call it, as upstream places them.
            let ops = &mut out.blocks[module_block.index()].ops;
            let new = ops.pop().unwrap();
            ops.insert(0, new);
            imported.insert(k.function.clone(), k.function.clone());
            k.function.clone()
        }
    };

    let i64t = out.int_type(64);
    let index = out.index_type();
    let ptr = out.dialect_type("llvm.ptr", None);
    let add = |out: &mut Module, spec: OpSpec| -> ValueId {
        let op = spec.build(out, Some(block));
        out.result(op)
    };
    let c64 = |out: &mut Module, v: i64| -> ValueId {
        let attr = out.int_attr(v, i64t);
        add(out, OpSpec::new("llvm.mlir.constant").results(&[i64t]).prop("value", attr))
    };
    let cidx = |out: &mut Module, v: i64| -> ValueId {
        let attr = out.int_attr(v, index);
        add(out, OpSpec::new("arith.constant").results(&[index]).prop("value", attr))
    };

    // A transposed: AT[k, m] = A[m, k], packed.
    let at_ty = out.memref_type(&[kk, m], elem, None);
    let i64a = out.int_attr(64, i64t);
    let segments = out.dense_array_attr("i32", &[0, 0]);
    let at = add(
        out,
        OpSpec::new("memref.alloc").results(&[at_ty]).prop("alignment", i64a).prop("operandSegmentSizes", segments),
    );
    {
        let maps = [Map::parse("(d0, d1) -> (d1, d0)")?, Map::identity(2)];
        let maps: Vec<AttrId> = maps.iter().map(|m| out.affine_map_attr(&m.to_string())).collect();
        let maps = out.array_attr(maps);
        let par = out.dialect_attr("linalg.iterator_type", Some("<parallel>"));
        let iters = out.array_attr(vec![par, par]);
        let segments = out.dense_array_attr("i32", &[1, 1]);
        let g = OpSpec::new("linalg.generic")
            .operands(&[a, at])
            .prop("indexing_maps", maps)
            .prop("iterator_types", iters)
            .prop("operandSegmentSizes", segments)
            .regions(1)
            .build(out, Some(block));
        let region = out.region_of(g, 0);
        let body = out.add_block(region, &[elem, elem]);
        let x = out.blocks[body.index()].args[0];
        OpSpec::new("linalg.yield").operands(&[x]).build(out, Some(body));
    }

    // Each operand's address, as a pointer.
    let pointer = |out: &mut Module, v: ValueId| -> ValueId {
        let i = add(out, OpSpec::new("memref.extract_aligned_pointer_as_index").operands(&[v]).results(&[index]));
        let i = add(out, OpSpec::new("arith.index_cast").operands(&[i]).results(&[i64t]));
        add(out, OpSpec::new("llvm.inttoptr").operands(&[i]).results(&[ptr]))
    };
    let (pa, pb, pc) = (pointer(out, at), pointer(out, b), pointer(out, c));
    let (ldc, lda, ldb) = (c64(out, lc.0[0] as i64), c64(out, m as i64), c64(out, lb.0[0] as i64));
    let (kv, offb, offc) = (c64(out, kk as i64), c64(out, lb.1 as i64), c64(out, lc.1 as i64));
    let nv = c64(out, n as i64);

    // for i in 0..full by tile rows, for j in 0..n by tile columns.
    let zero = cidx(out, 0);
    let (rows, cols) = (cidx(out, k.tile.0 as i64), cidx(out, k.tile.1 as i64));
    let (mend, nend) = (cidx(out, full as i64), cidx(out, n as i64));
    let gep = |out: &mut Module, blk: BlockId, p: ValueId, off: ValueId| -> ValueId {
        let f32t = elem;
        let et = out.type_attr(f32t);
        let i32t = out.int_type(32);
        let nw = out.int_attr(0, i32t);
        let raw = out.dense_array_attr("i32", &[i32::MIN as i64]);
        let g = OpSpec::new("llvm.getelementptr")
            .operands(&[p, off])
            .results(&[ptr])
            .prop("elem_type", et)
            .prop("noWrapFlags", nw)
            .prop("rawConstantIndices", raw)
            .build(out, Some(blk));
        out.result(g)
    };
    let int = |out: &mut Module, blk: BlockId, name: &str, x: ValueId, y: ValueId| -> ValueId {
        let i32t = out.int_type(32);
        let flags = out.int_attr(0, i32t);
        let r = OpSpec::new(name).operands(&[x, y]).results(&[i64t]).prop("overflowFlags", flags).build(out, Some(blk));
        out.result(r)
    };
    let outer = OpSpec::new("scf.for").operands(&[zero, mend, rows]).regions(1).build(out, Some(block));
    let r1 = out.region_of(outer, 0);
    let ob = out.add_block(r1, &[index]);
    let i = out.blocks[ob.index()].args[0];
    if k.whole_rows {
        // One call for each block of rows, for all its columns.
        let at_ob = |out: &mut Module, spec: OpSpec| -> ValueId {
            let op = spec.build(out, Some(ob));
            out.result(op)
        };
        let i64i = at_ob(out, OpSpec::new("arith.index_cast").operands(&[i]).results(&[i64t]));
        let rowc = int(out, ob, "llvm.mul", i64i, ldc);
        let offs = int(out, ob, "llvm.add", rowc, offc);
        let tc = gep(out, ob, pc, offs);
        let ta = gep(out, ob, pa, i64i);
        let tb = gep(out, ob, pb, offb);
        let callee = out.symbol_attr(&fname);
        OpSpec::new("func.call")
            .operands(&[tc, ldc, ta, lda, tb, ldb, kv, nv])
            .prop("callee", callee)
            .build(out, Some(ob));
        OpSpec::new("scf.yield").build(out, Some(ob));
        return rest_rows(
            src,
            op,
            [a, b, c],
            props,
            out,
            block,
            module_block,
            set,
            &ks[ki + 1..],
            imported,
            map,
            full,
            at,
        )
        .map(|()| true);
    }
    let inner = OpSpec::new("scf.for").operands(&[zero, nend, cols]).regions(1).build(out, Some(ob));
    OpSpec::new("scf.yield").build(out, Some(ob));
    let r2 = out.region_of(inner, 0);
    let ib = out.add_block(r2, &[index]);
    let j = out.blocks[ib.index()].args[0];
    let at_ib = |out: &mut Module, spec: OpSpec| -> ValueId {
        let op = spec.build(out, Some(ib));
        out.result(op)
    };
    let i64i = at_ib(out, OpSpec::new("arith.index_cast").operands(&[i]).results(&[i64t]));
    let i64j = at_ib(out, OpSpec::new("arith.index_cast").operands(&[j]).results(&[i64t]));
    // The tile's columns: those of the matrix left, at most a tile's.
    let left = at_ib(out, OpSpec::new("arith.subi").operands(&[nend, j]).results(&[index]));
    let width = at_ib(out, OpSpec::new("arith.minsi").operands(&[left, cols]).results(&[index]));
    let width = at_ib(out, OpSpec::new("arith.index_cast").operands(&[width]).results(&[i64t]));
    let rowc = int(out, ib, "llvm.mul", i64i, ldc);
    let offs = int(out, ib, "llvm.add", rowc, i64j);
    let offs = int(out, ib, "llvm.add", offs, offc);
    let tc = gep(out, ib, pc, offs);
    let ta = gep(out, ib, pa, i64i);
    let offs = int(out, ib, "llvm.add", i64j, offb);
    let tb = gep(out, ib, pb, offs);
    let callee = out.symbol_attr(&fname);
    OpSpec::new("func.call")
        .operands(&[tc, ldc, ta, lda, tb, ldb, kv, width])
        .prop("callee", callee)
        .build(out, Some(ib));
    OpSpec::new("scf.yield").build(out, Some(ib));

    rest_rows(src, op, [a, b, c], props, out, block, module_block, set, &ks[ki + 1..], imported, map, full, at)?;
    Ok(true)
}

/// Rows of C past `full`, the last whole tile's end: by the kernels left,
/// else as the original operation on views; then the packed A freed.
#[allow(clippy::too_many_arguments)]
fn rest_rows(
    src: &Module,
    op: OpId,
    [a, b, c]: [ValueId; 3],
    props: &[(String, AttrId)],
    out: &mut Module,
    block: BlockId,
    module_block: BlockId,
    set: &Set,
    ks: &[&Kernel],
    imported: &mut HashMap<String, String>,
    map: &mut HashMap<ValueId, ValueId>,
    full: u64,
    at: ValueId,
) -> Result<(), String> {
    let o = &src.ops[op.index()];
    let (sa, elem) = out.shaped(out.value_type(a)).ok_or("an operand of unknown shape")?;
    let (sc, _) = out.shaped(out.value_type(c)).ok_or("an operand of unknown shape")?;
    let (m, kk, n) = (sa[0], sa[1], sc[1]);
    let lc = layout(out, out.value_type(c)).ok_or("an operand of unknown layout")?;
    if full < m {
        let rest = m - full;
        let view = |out: &mut Module, v: ValueId, (strides, offset): &(Vec<u64>, u64), cols: u64| -> ValueId {
            let off = offset + full * strides[0];
            let layout = strided_attr(out, strides, off);
            let ty = out.memref_type(&[rest, cols], elem, Some(layout));
            let segments = out.dense_array_attr("i32", &[1, 0, 0, 0]);
            let offsets = out.dense_array_attr("i64", &[full as i64, 0]);
            let sizes = out.dense_array_attr("i64", &[rest as i64, cols as i64]);
            let ones = out.dense_array_attr("i64", &[1, 1]);
            let s = OpSpec::new("memref.subview")
                .operands(&[v])
                .results(&[ty])
                .prop("operandSegmentSizes", segments)
                .prop("static_offsets", offsets)
                .prop("static_sizes", sizes)
                .prop("static_strides", ones)
                .build(out, Some(block));
            out.result(s)
        };
        let va = view(out, a, &layout(out, out.value_type(a)).unwrap(), kk);
        let vc = view(out, c, &lc, n);
        if !tiles(src, op, [va, b, vc], props, out, block, module_block, set, ks, imported, map)? {
            let mut spec = OpSpec::new("linalg.generic").operands(&[va, b, vc]).regions(1).loc(o.loc);
            for (key, v) in props {
                spec = spec.prop(key, *v);
            }
            let g = spec.build(out, Some(block));
            let region = out.region_of(g, 0);
            out.clone_region_into(src, o.regions[0], region, map)?;
        }
    }
    OpSpec::new("memref.dealloc").operands(&[at]).build(out, Some(block));
    Ok(())
}
