//! Operations on buffers split among threads: `linalg-split=N` splits each
//! `linalg.generic`, `linalg.fill` and `memref.copy` it can into up to N
//! chunks, and does them by `__epitome_parallel_for(task, context, chunks)`,
//! which the program provides: it calls `task(context, i)` for each chunk
//! i, on as many threads as it has, and returns when all are done.
//!
//! The memory is split first. An operation is split along one of its
//! parallel dimensions, the one that gives the most chunks (the outermost
//! of those): each chunk's operands are views of those that dimension
//! indexes, the rest whole, and each chunk writes its own part of each
//! output, a whole number of 64-byte lines, so that no two chunks write
//! the same line. Consecutive operations split into as many chunks go in
//! one task where each buffer that any of them writes is split the same
//! way in all of them: a chunk then reads only what it wrote itself, or
//! what none of them writes, and the threads wait for each other once for
//! the lot. So that the chunks share nothing but what they only read, as
//! where each processor has memory of its own.
//!
//! A task is a function `(context, chunk)`, named after its function and
//! its number (`forward.part3`); the context is the operands, a word each,
//! on the stack where the operations were. The operations stay `linalg`
//! in the task, for `linalg-to-kernels` (a chunk of a matrix product is a
//! product of fewer rows) and `outline-linalg` after. A matrix product of
//! 2^23 multiply-adds or more is left whole, for `linalg-to-kernels` to
//! split by its columns. Runs on buffers, after `bufferize`.

use std::collections::HashMap;

use crate::affine::{Expr, Map};
use crate::build::{OpSpec, row_major_strides, strided_attr, strided_layout};
use crate::ir::*;
use crate::to_llvm::elem_bytes;

/// A matrix product at least this large is left to `linalg-to-kernels`.
const LARGE: u64 = 1 << 23;

/// Splits what it can of every function in `src` into up to `most`
/// chunks, a matrix product's rows into at least `rows` each.
pub fn run(src: &Module, most: u64, rows: u64) -> Result<Module, String> {
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
        let mut cx = Cx { most, rows, tasks: 0, declared: false, mblock };
        let mut map = HashMap::new();
        for &r in &o.regions {
            for &b in &src.regions[r.index()].blocks {
                for &op in &src.blocks[b.index()].ops {
                    let one_block =
                        src.ops[op.index()].regions.first().is_some_and(|&r| src.regions[r.index()].blocks.len() == 1);
                    if src.op_name(op) == "func.func" && one_block {
                        func(src, op, &mut out, &mut cx, &mut map)?;
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

struct Cx {
    most: u64,
    /// The fewest rows of a matrix product in a chunk.
    rows: u64,
    /// Tasks made so far, for their names.
    tasks: usize,
    /// Whether `__epitome_parallel_for` is declared yet.
    declared: bool,
    mblock: BlockId,
}

/// One operand of an operation split a given way: the value, the position
/// in its shape that is split (`None`: whole for each chunk), and whether
/// the operation writes it.
#[derive(Clone, Copy, PartialEq, Debug)]
struct Access {
    value: ValueId,
    at: Option<usize>,
    write: bool,
}

/// Operations to do in one task, split into `chunks`, each with its
/// operands' accesses.
struct Group {
    ops: Vec<(OpId, Vec<Access>)>,
    chunks: u64,
}

impl Group {
    fn accesses(&self) -> impl Iterator<Item = &Access> {
        self.ops.iter().flat_map(|(_, a)| a)
    }
}

fn func(
    src: &Module,
    f: OpId,
    out: &mut Module,
    cx: &mut Cx,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let o = &src.ops[f.index()];
    let mut spec = OpSpec::new("func.func").regions(1).loc(o.loc);
    for (k, v) in dict(src, o.properties) {
        spec = spec.prop(&k, v);
    }
    for (k, v) in dict(src, o.attrs) {
        spec = spec.attr(&k, v);
    }
    let new = spec.build(out, Some(cx.mblock));
    let b = src.regions[o.regions[0].index()].blocks[0];
    let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
    let region = out.region_of(new, 0);
    let nb = out.add_block(region, &types);
    for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
        map.insert(a, n);
    }
    let mut group: Option<Group> = None;
    for &op in &src.blocks[b.index()].ops {
        if let Some(choice) = best(src, op, cx.most, cx.rows) {
            // With the operations before, if it can be split as they are.
            if let Some(g) = &mut group
                && choice.0 == g.chunks
                && let Some(acc) = joins(src, op, g, cx.rows)
            {
                g.ops.push((op, acc));
                continue;
            }
            if let Some(g) = group.take() {
                task(src, &name, g, out, nb, cx, map)?;
            }
            group = Some(Group { ops: vec![(op, choice.1)], chunks: choice.0 });
            continue;
        }
        let pure = matches!(
            src.op_name(op),
            "arith.constant"
                | "llvm.mlir.constant"
                | "memref.alloc"
                | "memref.subview"
                | "memref.expand_shape"
                | "memref.collapse_shape"
                | "memref.get_global"
        );
        // A buffer the group uses, freed: the group first.
        let frees_ours = src.op_name(op) == "memref.dealloc"
            && group.as_ref().is_some_and(|g| {
                let r = root(src, src.ops[op.index()].operands[0]);
                g.accesses().any(|a| root(src, a.value) == r)
            });
        if (!pure || frees_ours)
            && let Some(g) = group.take()
        {
            task(src, &name, g, out, nb, cx, map)?;
        }
        out.clone_op(src, op, Some(nb), map)?;
    }
    if let Some(g) = group.take() {
        task(src, &name, g, out, nb, cx, map)?;
    }
    Ok(())
}

/// The buffer a view is of.
fn root(src: &Module, mut v: ValueId) -> ValueId {
    while let ValueDef::Result { op, .. } = src.values[v.index()].def {
        if !matches!(src.op_name(op), "memref.subview" | "memref.expand_shape" | "memref.collapse_shape") {
            break;
        }
        v = src.ops[op.index()].operands[0];
    }
    v
}

/// The maps of a `linalg.generic`, or of a `linalg.fill` or `memref.copy`
/// (identities), which of its operands it writes, and which of its
/// dimensions are parallel.
type Maps = (Vec<Option<Map>>, Vec<bool>, Vec<bool>);

fn maps_of(src: &Module, op: OpId) -> Option<Maps> {
    let o = &src.ops[op.index()];
    let rank = |v: ValueId| src.shaped(src.value_type(v)).map(|(s, _)| s.len());
    match src.op_name(op) {
        "linalg.fill" => {
            let n = rank(*o.operands.get(1)?)?;
            return Some((vec![None, Some(Map::identity(n))], vec![false, true], vec![true; n]));
        }
        "memref.copy" => {
            let (from, to) = (src.shaped(src.value_type(o.operands[0]))?, src.shaped(src.value_type(o.operands[1]))?);
            if from.0 != to.0 {
                return None;
            }
            let n = from.0.len();
            return Some((vec![Some(Map::identity(n)); 2], vec![false, true], vec![true; n]));
        }
        "linalg.generic" => {}
        _ => return None,
    }
    let Some(Attr::Array(ms)) = src.op_attr(op, "indexing_maps").map(|a| src.attr(src.resolve_attr(a))) else {
        return None;
    };
    let maps = ms
        .iter()
        .map(|&a| match src.attr(src.resolve_attr(a)) {
            Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]).ok().map(Some),
            _ => None,
        })
        .collect::<Option<Vec<_>>>()?;
    let ins = src.op_attr(op, "operandSegmentSizes").and_then(|a| src.int_list(a))?[0] as usize;
    let writes = (0..o.operands.len()).map(|k| k >= ins).collect();
    let Some(Attr::Array(its)) = src.op_attr(op, "iterator_types").map(|a| src.attr(src.resolve_attr(a))) else {
        return None;
    };
    let parallel = its
        .iter()
        .map(
            |&a| matches!(src.attr(src.resolve_attr(a)), Attr::Dialect { body: Some(b), .. } if b.contains("parallel")),
        )
        .collect();
    Some((maps, writes, parallel))
}

/// Whether expression `e` uses dimension `d`.
fn uses(e: &Expr, d: usize) -> bool {
    match e {
        Expr::Dim(k) => *k == d,
        Expr::Sym(_) | Expr::Const(_) => false,
        Expr::Add(a, b) | Expr::Mul(a, b) | Expr::FloorDiv(a, b) | Expr::CeilDiv(a, b) | Expr::Mod(a, b) => {
            uses(a, d) || uses(b, d)
        }
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

/// `op`'s operands, split along dimension `d` into `chunks`, if it can be:
/// each operand that `d` indexes is indexed by it alone, in one place;
/// each chunk's part of each output is whole 64-byte lines; and the body
/// does not ask for the index (`linalg.index`).
fn split(src: &Module, op: OpId, d: usize, chunks: u64, rows: u64) -> Option<Vec<Access>> {
    let (maps, writes, parallel) = maps_of(src, op)?;
    if !parallel.get(d).copied().unwrap_or(false) {
        return None;
    }
    // A matrix product: split by its batch, or by its rows into at least
    // `rows` each (as many as a kernel's tile has); not by its columns.
    let product = parallel.iter().any(|p| !p) && writes.iter().filter(|w| !**w).count() == 2;
    if product {
        let indexes = |k: usize| maps[k].as_ref().is_some_and(|m| m.results.iter().any(|e| uses(e, d)));
        let ty = src.value_type(src.ops[op.index()].operands[2]);
        let r = maps[2].as_ref()?.results.iter().position(|e| *e == Expr::Dim(d))?;
        let extent = src.shaped(ty)?.0[r];
        match (indexes(0), indexes(1)) {
            (true, true) => {}
            (true, false) if extent / chunks >= rows => {}
            _ => return None,
        }
    }
    let mut indexed = false;
    src.walk(op, &mut |inner| {
        indexed |= src.op_name(inner) == "linalg.index"
            && src.op_attr(inner, "dim").and_then(|a| src.int_of(a)) == Some(d as i64);
    });
    if indexed {
        return None;
    }
    let o = &src.ops[op.index()];
    let mut accesses = Vec::new();
    let mut extent = None;
    for (k, &v) in o.operands.iter().enumerate() {
        let Some(map) = &maps[k] else {
            accesses.push(Access { value: v, at: None, write: false });
            continue;
        };
        let at: Vec<usize> = (0..map.results.len()).filter(|&r| uses(&map.results[r], d)).collect();
        let at = match at[..] {
            [] => None,
            [r] if map.results[r] == Expr::Dim(d) => Some(r),
            _ => return None,
        };
        let ty = src.value_type(v);
        let (shape, elem) = src.shaped(ty)?;
        if let Some(r) = at {
            if extent.is_some_and(|e| e != shape[r]) || shape[r] % chunks != 0 {
                return None;
            }
            extent = Some(shape[r]);
        }
        if writes[k] {
            let r = at?;
            let (strides, offset) = strided_layout(src, ty).unwrap_or_else(|| (row_major_strides(&shape), 0));
            let bytes = elem_bytes(src, elem).ok()?;
            if (shape[r] / chunks * strides[r] * bytes) % 64 != 0 || (offset * bytes) % 64 != 0 {
                return None;
            }
        }
        // A product's constant (its weights) whole, for the kernel to see.
        if product && at.is_some() && copied(src, v) {
            return None;
        }
        // A value is one part of itself for the operation.
        if accesses.iter().any(|a: &Access| a.value == v && a.at != at) {
            return None;
        }
        accesses.push(Access { value: v, at, write: writes[k] });
    }
    if extent.is_none_or(|e| e < chunks) {
        return None;
    }
    for v in captured(src, op) {
        accesses.push(Access { value: v, at: None, write: false });
    }
    Some(accesses)
}

/// The most chunks (up to `most`) `op` splits into, and how; `None` if it
/// is not split.
fn best(src: &Module, op: OpId, most: u64, rows: u64) -> Option<(u64, Vec<Access>)> {
    let (maps, _, parallel) = maps_of(src, op)?;
    // A large product: its columns split by linalg-to-kernels.
    if parallel.iter().any(|p| !p) {
        let o = &src.ops[op.index()];
        let mut extents = vec![1; parallel.len()];
        for (k, &v) in o.operands.iter().enumerate() {
            if let (Some(map), Some((shape, _))) = (&maps[k], src.shaped(src.value_type(v))) {
                for (r, e) in map.results.iter().enumerate() {
                    if let Expr::Dim(d) = e {
                        extents[*d] = shape[r];
                    }
                }
            }
        }
        if extents.iter().product::<u64>() >= LARGE {
            return None;
        }
    }
    (2..=most).rev().find_map(|c| (0..parallel.len()).find_map(|d| split(src, op, d, c, rows)).map(|a| (c, a)))
}

/// How `op` can be split to go with group `g`: into as many chunks, each
/// buffer that any of them writes split the same way by all.
fn joins(src: &Module, op: OpId, g: &Group, rows: u64) -> Option<Vec<Access>> {
    let (_, _, parallel) = maps_of(src, op)?;
    (0..parallel.len()).find_map(|d| {
        let acc = split(src, op, d, g.chunks, rows)?;
        let all: Vec<&Access> = g.accesses().chain(&acc).collect();
        let consistent = all.iter().filter(|a| a.write).all(|w| {
            let r = root(src, w.value);
            all.iter().filter(|a| root(src, a.value) == r).all(|a| a.value == w.value && a.at == w.at)
        });
        consistent.then_some(acc)
    })
}

/// Group `g` as a task, called by `__epitome_parallel_for` here, at the end
/// of `at`.
fn task(
    src: &Module,
    fname: &str,
    g: Group,
    out: &mut Module,
    at: BlockId,
    cx: &mut Cx,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let i64t = out.int_type(64);
    let i32t = out.int_type(32);
    let i8t = out.int_type(8);
    let index = out.index_type();
    let ptr = out.dialect_type("llvm.ptr", None);
    let build = |out: &mut Module, blk: BlockId, spec: OpSpec| -> ValueId {
        let op = spec.build(out, Some(blk));
        out.result(op)
    };
    let constant = |out: &mut Module, blk: BlockId, v: i64| -> ValueId {
        let attr = out.int_attr(v, i64t);
        build(out, blk, OpSpec::new("llvm.mlir.constant").results(&[i64t]).prop("value", attr))
    };
    let gep = |out: &mut Module, blk: BlockId, p: ValueId, off: ValueId, elem: TypeId| -> ValueId {
        let et = out.type_attr(elem);
        let nw = out.int_attr(0, i32t);
        let raw = out.dense_array_attr("i32", &[i32::MIN as i64]);
        build(
            out,
            blk,
            OpSpec::new("llvm.getelementptr")
                .operands(&[p, off])
                .results(&[ptr])
                .prop("elem_type", et)
                .prop("noWrapFlags", nw)
                .prop("rawConstantIndices", raw),
        )
    };
    let is_index = |out: &Module, t: TypeId| matches!(out.ty(out.resolve_type(t)), Type::Index);

    // Constants are copied in (scalars, and globals and views of them, for
    // the kernels to see constant weights); every other value is a
    // parameter.
    let mut params: Vec<ValueId> = Vec::new();
    for a in g.accesses() {
        if !copied(src, a.value) && !params.contains(&a.value) {
            params.push(a.value);
        }
    }

    // The task: (context, chunk).
    let name = format!("{fname}.part{}", cx.tasks);
    cx.tasks += 1;
    let fty = out.function_type(&[ptr, i64t], &[]);
    let fty = out.type_attr(fty);
    let sym = out.string_attr(&name);
    let vis = out.string_attr("private");
    let f = OpSpec::new("func.func")
        .prop("function_type", fty)
        .prop("sym_name", sym)
        .prop("sym_visibility", vis)
        .regions(1)
        .build(out, Some(cx.mblock));
    let region = out.region_of(f, 0);
    let tb = out.add_block(region, &[ptr, i64t]);
    let (ctx, chunk) = (out.blocks[tb.index()].args[0], out.blocks[tb.index()].args[1]);
    // Each parameter from its word: a memref's address, and for each way it
    // is split, the chunk's part of it.
    let mut words = HashMap::new();
    for (k, &v) in params.iter().enumerate() {
        let slot = constant(out, tb, k as i64);
        let p = gep(out, tb, ctx, slot, i64t);
        let a8 = out.int_attr(8, i64t);
        let ty = src.value_type(v);
        let word = if src.shaped(ty).is_some() || is_index(out, ty) {
            build(out, tb, OpSpec::new("llvm.load").operands(&[p]).results(&[i64t]).prop("alignment", a8))
        } else {
            build(out, tb, OpSpec::new("llvm.load").operands(&[p]).results(&[ty]))
        };
        words.insert(v, word);
    }
    let mut inner: HashMap<ValueId, ValueId> = HashMap::new();
    for a in g.accesses() {
        if copied(src, a.value) {
            copy_in(src, a.value, out, tb, &mut inner)?;
            if a.at.is_some() && !words.contains_key(&a.value) {
                let v = inner[&a.value];
                let i = build(
                    out,
                    tb,
                    OpSpec::new("memref.extract_aligned_pointer_as_index").operands(&[v]).results(&[index]),
                );
                let w = build(out, tb, OpSpec::new("arith.index_cast").operands(&[i]).results(&[i64t]));
                words.insert(a.value, w);
            }
        }
    }
    let mut parts: HashMap<(ValueId, Option<usize>), ValueId> = HashMap::new();
    for a in g.accesses() {
        if parts.contains_key(&(a.value, a.at)) || copied(src, a.value) && a.at.is_none() {
            continue;
        }
        let ty = src.value_type(a.value);
        let word = words[&a.value];
        let value = if let Some((shape, elem)) = src.shaped(ty) {
            let mut base = build(out, tb, OpSpec::new("llvm.inttoptr").operands(&[word]).results(&[ptr]));
            let mut part = ty;
            if let Some(r) = a.at {
                let (strides, offset) = strided_layout(src, ty).unwrap_or_else(|| (row_major_strides(&shape), 0));
                let per = shape[r] / g.chunks;
                let step = constant(out, tb, (per * strides[r] * elem_bytes(src, elem)?) as i64);
                let flags = out.int_attr(0, i32t);
                let off = build(
                    out,
                    tb,
                    OpSpec::new("llvm.mul").operands(&[chunk, step]).results(&[i64t]).prop("overflowFlags", flags),
                );
                base = gep(out, tb, base, off, i8t);
                let mut s = shape.clone();
                s[r] = per;
                let layout = strided_attr(out, &strides, offset);
                part = out.memref_type(&s, elem, Some(layout));
            }
            build(out, tb, OpSpec::new("builtin.unrealized_conversion_cast").operands(&[base]).results(&[part]))
        } else if is_index(out, ty) {
            build(out, tb, OpSpec::new("arith.index_cast").operands(&[word]).results(&[index]))
        } else {
            word
        };
        parts.insert((a.value, a.at), value);
    }
    // Each operation, on its parts of its operands.
    for (op, mine) in &g.ops {
        let op = *op;
        let mut local = inner.clone();
        for a in mine {
            if let Some(&p) = parts.get(&(a.value, a.at)) {
                local.insert(a.value, p);
            }
        }
        out.clone_op(src, op, Some(tb), &mut local)?;
    }
    OpSpec::new("func.return").build(out, Some(tb));

    // The context: a word for each parameter.
    let n = constant(out, at, params.len() as i64);
    let et = out.type_attr(i64t);
    let ctx = build(out, at, OpSpec::new("llvm.alloca").operands(&[n]).results(&[ptr]).prop("elem_type", et));
    for (k, &v) in params.iter().enumerate() {
        let ty = src.value_type(v);
        let x = *map.get(&v).ok_or("an operand from outside")?;
        let word = if src.shaped(ty).is_some() {
            let i =
                build(out, at, OpSpec::new("memref.extract_aligned_pointer_as_index").operands(&[x]).results(&[index]));
            build(out, at, OpSpec::new("arith.index_cast").operands(&[i]).results(&[i64t]))
        } else if is_index(out, ty) {
            build(out, at, OpSpec::new("arith.index_cast").operands(&[x]).results(&[i64t]))
        } else {
            x
        };
        let slot = constant(out, at, k as i64);
        let p = gep(out, at, ctx, slot, i64t);
        OpSpec::new("llvm.store").operands(&[word, p]).build(out, Some(at));
    }
    if !cx.declared {
        let fty = out.function_type(&[ptr, ptr, i64t], &[]);
        let fty = out.type_attr(fty);
        let sym = out.string_attr("__epitome_parallel_for");
        let vis = out.string_attr("private");
        OpSpec::new("func.func")
            .prop("function_type", fty)
            .prop("sym_name", sym)
            .prop("sym_visibility", vis)
            .regions(1)
            .build(out, Some(cx.mblock));
        cx.declared = true;
    }
    let task = out.symbol_attr(&name);
    let fnptr = build(out, at, OpSpec::new("llvm.mlir.addressof").results(&[ptr]).prop("global_name", task));
    let chunks = constant(out, at, g.chunks as i64);
    let callee = out.symbol_attr("__epitome_parallel_for");
    OpSpec::new("func.call").operands(&[fnptr, ctx, chunks]).prop("callee", callee).build(out, Some(at));
    Ok(())
}

/// Whether `v` is copied into a task rather than passed: a scalar
/// constant, a global, or a view of one.
fn copied(src: &Module, v: ValueId) -> bool {
    let ValueDef::Result { op, .. } = src.values[v.index()].def else { return false };
    match src.op_name(op) {
        "arith.constant" | "llvm.mlir.constant" => src.shaped(src.value_type(v)).is_none(),
        "memref.get_global" => true,
        "memref.subview" | "memref.expand_shape" | "memref.collapse_shape" => {
            src.ops[op.index()].operands.len() == 1 && copied(src, src.ops[op.index()].operands[0])
        }
        _ => false,
    }
}

/// `v` (`copied`) and what it is made from, copied in at the end of `b`.
fn copy_in(
    src: &Module,
    v: ValueId,
    out: &mut Module,
    b: BlockId,
    inner: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    if inner.contains_key(&v) {
        return Ok(());
    }
    let ValueDef::Result { op, .. } = src.values[v.index()].def else { unreachable!() };
    for &x in &src.ops[op.index()].operands {
        copy_in(src, x, out, b, inner)?;
    }
    out.clone_op(src, op, Some(b), inner)?;
    Ok(())
}
