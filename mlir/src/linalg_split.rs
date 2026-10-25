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
//! the same line. The chunks are as long as each other but the last, which
//! may be shorter. Operations split into as many chunks go in one task
//! where each buffer that any of them writes is split the same way by all
//! of them (the same block of its elements to each chunk, whatever views
//! of it they have): a chunk then reads only what it wrote itself, or what
//! none of them writes, and the threads wait for each other once for the
//! lot. An operation that cannot join the task waits, and so does each
//! after it that depends on it, while those after it that go on from what
//! the task writes, and depend on nothing waiting, join it. So that
//! the chunks share nothing but what they only read, as where each
//! processor has memory of its own.
//!
//! Matrix products of constant weights of 2^23 multiply-adds or more are
//! split as tensor parallelism splits them, never by their rows (each
//! chunk would read all the weights): by their columns, whole panels of
//! `cols` columns (the kernels' packing) to a chunk, each chunk its own
//! columns of the weights; or, where the task has split their input by the
//! columns the product sums over, by those, each chunk's sums of its part
//! of them (its rows of the weights) to a buffer of its own, which an
//! operation added after the task sums (Megatron's row-parallel layer).
//! Other products are split by their batch, or by their rows into at least
//! `rows` each; large ones of no constant are left to `linalg-to-kernels`.
//!
//! A task is a function `(context, chunk)`, named after its function and
//! its number (`forward.part3`); the context is the operands, a word each,
//! on the stack where the operations were. A task whose last chunk is
//! shorter calls one of two functions, `.full` or `.last`, each with its
//! own shapes. The operations stay `linalg` in the task, for
//! `linalg-to-kernels` (a chunk of a matrix product is a smaller product)
//! and `outline-linalg` after. Runs on buffers, after `bufferize`.

use std::collections::{HashMap, HashSet};

use crate::affine::{Expr, Map};
use crate::build::{OpSpec, row_major_strides, strided_attr, strided_layout};
use crate::ir::*;
use crate::to_llvm::elem_bytes;

/// A matrix product at least this large is split as tensor parallelism
/// splits it, or left to `linalg-to-kernels`.
const LARGE: u64 = 1 << 23;

/// Splits what it can of every function in `src` into up to `most`
/// chunks, a matrix product's rows into at least `rows` each, its columns
/// into whole panels of `cols`.
pub fn run(src: &Module, most: u64, rows: u64, cols: u64) -> Result<Module, String> {
    // Sums of partial products are added to a copy of `src`.
    let mut src = src.clone();
    let mut out = src.empty_like();
    for top in src.top_ops().collect::<Vec<_>>() {
        if src.op_name(top) != "builtin.module" {
            return Err(format!("{}: expected a builtin.module", src.op_name(top)));
        }
        let o = src.ops[top.index()].clone();
        let mut spec = OpSpec::new("builtin.module").regions(1).loc(o.loc);
        for (k, v) in dict(&src, o.properties).into_iter().chain(dict(&src, o.attrs)) {
            spec = spec.prop(&k, v);
        }
        let module = spec.build(&mut out, None);
        let region = out.region_of(module, 0);
        let mblock = out.add_block(region, &[]);
        let mut cx = Cx { most, rows, cols: cols.max(1), tasks: 0, declared: false, mblock };
        let mut map = HashMap::new();
        for &r in &o.regions {
            for b in src.regions[r.index()].blocks.clone() {
                for op in src.blocks[b.index()].ops.clone() {
                    let one_block =
                        src.ops[op.index()].regions.first().is_some_and(|&r| src.regions[r.index()].blocks.len() == 1);
                    if src.op_name(op) == "func.func" && one_block {
                        func(&mut src, op, &mut out, &mut cx, &mut map)?;
                    } else {
                        out.clone_op(&src, op, Some(mblock), &mut map)?;
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
    /// A chunk of a product's columns, a multiple of this many.
    cols: u64,
    /// Tasks made so far, for their names.
    tasks: usize,
    /// Whether `__epitome_parallel_for` is declared yet.
    declared: bool,
    mblock: BlockId,
}

/// One operand of an operation split a given way: the value, the position
/// in its shape that is split and each chunk's length there (`None`:
/// whole for each chunk), and whether the operation writes it.
#[derive(Clone, Copy, PartialEq, Debug)]
struct Access {
    value: ValueId,
    at: Option<(usize, u64)>,
    write: bool,
}

/// An operation in a task, with its operands' accesses; and, for a product
/// split by the columns it sums over, the buffer of each chunk's sums
/// (`partial`, of the shape of its output, one for each chunk), which it
/// writes rather than its output.
struct Entry {
    op: OpId,
    acc: Vec<Access>,
    partial: Option<ValueId>,
}

/// Operations to do in one task, split into `chunks`.
struct Group {
    entries: Vec<Entry>,
    chunks: u64,
}

impl Group {
    fn accesses(&self) -> impl Iterator<Item = &Access> {
        self.entries.iter().flat_map(|e| &e.acc)
    }
}

/// The buffers an operation reads and writes; a barrier is one that may
/// touch anything.
#[derive(Default)]
struct Effects {
    reads: HashSet<ValueId>,
    writes: HashSet<ValueId>,
    barrier: bool,
}

impl Effects {
    fn add(&mut self, e: &Effects) {
        self.reads.extend(&e.reads);
        self.writes.extend(&e.writes);
        self.barrier |= e.barrier;
    }

    /// Whether `e` must stay after (or before) what this has.
    fn conflicts(&self, e: &Effects) -> bool {
        self.barrier
            || e.barrier
            || e.writes.iter().any(|r| self.reads.contains(r) || self.writes.contains(r))
            || e.reads.iter().any(|r| self.writes.contains(r))
    }
}

/// Operations that touch no memory but through their results.
fn pure(src: &Module, op: OpId) -> bool {
    let name = src.op_name(op);
    let memory = src.ops[op.index()].operands.iter().any(|&v| src.shaped(src.value_type(v)).is_some());
    matches!(
        name,
        "llvm.mlir.constant"
            | "memref.alloc"
            | "memref.subview"
            | "memref.expand_shape"
            | "memref.collapse_shape"
            | "memref.get_global"
    ) || (name.starts_with("arith.") || name.starts_with("math.")) && !memory && src.ops[op.index()].regions.is_empty()
}

fn effects(src: &Module, op: OpId) -> Effects {
    let mut e = Effects::default();
    let o = &src.ops[op.index()];
    let shaped = |v: ValueId| src.shaped(src.value_type(v)).is_some();
    if let Some((_, writes, _)) = maps_of(src, op) {
        for (k, &v) in o.operands.iter().enumerate() {
            if shaped(v) {
                if writes[k] { &mut e.writes } else { &mut e.reads }.insert(root(src, v));
            }
        }
        for v in captured(src, op) {
            if shaped(v) {
                e.reads.insert(root(src, v));
            }
        }
        return e;
    }
    match src.op_name(op) {
        "memref.dealloc" => {
            e.writes.insert(root(src, o.operands[0]));
        }
        "memref.load" => {
            e.reads.insert(root(src, o.operands[0]));
        }
        "memref.store" => {
            e.writes.insert(root(src, o.operands[1]));
        }
        _ if pure(src, op) => {}
        _ => e.barrier = true,
    }
    e
}

fn func(
    src: &mut Module,
    f: OpId,
    out: &mut Module,
    cx: &mut Cx,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let o = src.ops[f.index()].clone();
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

    // The operations, as a stream: a task gathered from it, those that wait
    // for the task the next stream.
    let mut stream: Vec<OpId> = src.blocks[b.index()].ops.clone();
    loop {
        let mut group: Option<Group> = None;
        let mut touched = Effects::default();
        let mut waiting: Vec<OpId> = Vec::new();
        let mut waits = Effects::default();
        let mut waiting_values: HashSet<ValueId> = HashSet::new();
        let mut i = 0;
        while i < stream.len() {
            let op = stream[i];
            i += 1;
            let e = effects(src, op);
            let uses_waiting =
                || src.ops[op.index()].operands.iter().chain(&captured(src, op)).any(|v| waiting_values.contains(v));
            if !waiting.is_empty() && (waits.conflicts(&e) || uses_waiting()) {
                waits.add(&e);
                waiting_values.extend(src.ops[op.index()].results.iter().copied());
                waiting.push(op);
                continue;
            }
            if pure(src, op) {
                out.clone_op(src, op, Some(nb), map)?;
                continue;
            }
            if let Some(g) = &mut group {
                // Past what waits, only what goes on from what the task
                // writes joins it: the rest is not brought forward (nor its
                // buffers made live sooner).
                let feeds = waiting.is_empty() || e.reads.iter().any(|r| touched.writes.contains(r));
                if feeds && let Some((mut acc, ksplit)) = joins(src, op, g, cx) {
                    let mut partial = None;
                    if ksplit {
                        // Its buffer of sums, a chunk's each, written.
                        let p = partial_sums(src, op, g.chunks, &mut stream, i, out, nb, map)?;
                        acc.push(Access { value: p, at: Some((0, 1)), write: true });
                        partial = Some(p);
                    }
                    touched.add(&e);
                    g.entries.push(Entry { op, acc, partial });
                    continue;
                }
                // A task of only fills and copies so far: split as `op` is,
                // if they can be.
                if let Some(regrouped) = regroup(src, op, g, cx) {
                    touched.add(&e);
                    *g = regrouped;
                    continue;
                }
                // Done before the task where nothing of it is in the task;
                // after it otherwise, as is all that depends on it.
                if e.barrier || touched.conflicts(&e) || best(src, op, cx).is_some() {
                    waits.add(&e);
                    waiting_values.extend(src.ops[op.index()].results.iter().copied());
                    waiting.push(op);
                } else {
                    out.clone_op(src, op, Some(nb), map)?;
                }
                continue;
            }
            if let Some((chunks, acc)) = best(src, op, cx) {
                touched.add(&e);
                group = Some(Group { entries: vec![Entry { op, acc, partial: None }], chunks });
                continue;
            }
            out.clone_op(src, op, Some(nb), map)?;
        }
        if let Some(g) = group.take() {
            task(src, &name, g, out, nb, cx, map)?;
        }
        if waiting.is_empty() {
            break;
        }
        stream = waiting;
    }
    Ok(())
}

/// For product `op`, split by the columns it sums over into `chunks`: a
/// buffer for each chunk's sums, made now; after `op` in `stream` (at
/// `next`), their sum added to its output; and the buffer freed after its
/// output is. The buffer, in `src`.
#[allow(clippy::too_many_arguments)]
fn partial_sums(
    src: &mut Module,
    op: OpId,
    chunks: u64,
    stream: &mut Vec<OpId>,
    next: usize,
    out: &mut Module,
    nb: BlockId,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<ValueId, String> {
    src.adopt_interned(out);
    let c = src.ops[op.index()].operands[2];
    let (shape, elem) = src.shaped(src.value_type(c)).ok_or("a product of no shape")?;
    let mut pshape = vec![chunks];
    pshape.extend(&shape);
    let pty = src.memref_type(&pshape, elem, None);
    let i64t = src.int_type(64);
    let a64 = src.int_attr(64, i64t);
    let segments = src.dense_array_attr("i32", &[0, 0]);
    let alloc = OpSpec::new("memref.alloc")
        .results(&[pty])
        .prop("alignment", a64)
        .prop("operandSegmentSizes", segments)
        .build(src, None);
    let p = src.result(alloc);
    // The sum: out[d...] += p[c, d...], c the first dimension (the loop
    // outermost, the others' elements one after another within it).
    let n = shape.len();
    let dims: Vec<String> = (0..=n).map(|d| format!("d{d}")).collect();
    let all = dims.join(", ");
    let pmap = src.affine_map_attr(&format!("({all}) -> ({all})"));
    let cmap = src.affine_map_attr(&format!("({all}) -> ({})", dims[1..].join(", ")));
    let maps = src.array_attr(vec![pmap, cmap]);
    let par = src.dialect_attr("linalg.iterator_type", Some("<parallel>"));
    let red = src.dialect_attr("linalg.iterator_type", Some("<reduction>"));
    let mut its = vec![red];
    its.extend(vec![par; n]);
    let its = src.array_attr(its);
    let segments = src.dense_array_attr("i32", &[1, 1]);
    let sum = OpSpec::new("linalg.generic")
        .operands(&[p, c])
        .prop("indexing_maps", maps)
        .prop("iterator_types", its)
        .prop("operandSegmentSizes", segments)
        .regions(1)
        .build(src, None);
    let region = src.region_of(sum, 0);
    let body = src.add_block(region, &[elem, elem]);
    let [x, acc] = src.blocks[body.index()].args[..] else { unreachable!() };
    let fm = src.dialect_attr("arith.fastmath", Some("<none>"));
    let add =
        OpSpec::new("arith.addf").operands(&[acc, x]).results(&[elem]).prop("fastmath", fm).build(src, Some(body));
    let s = src.result(add);
    OpSpec::new("linalg.yield").operands(&[s]).build(src, Some(body));
    let free = OpSpec::new("memref.dealloc").operands(&[p]).build(src, None);
    out.adopt_interned(src);

    out.clone_op(src, alloc, Some(nb), map)?;
    stream.insert(next, sum);
    let r = root(src, c);
    let after = stream[next..]
        .iter()
        .position(|&o| src.op_name(o) == "memref.dealloc" && root(src, src.ops[o.index()].operands[0]) == r)
        .map(|k| next + k + 1);
    let at = after.unwrap_or_else(|| {
        let last = stream.len();
        if stream.last().is_some_and(|&o| src.op_name(o) == "func.return") { last - 1 } else { last }
    });
    stream.insert(at, free);
    Ok(p)
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

/// The elements of its buffer each chunk of access `a` is in: the buffer,
/// and each chunk's block of elements in each period of them (chunk c the
/// c-th block). `None` where the view is not within those blocks.
fn key(src: &Module, a: &Access) -> Option<(ValueId, u64, u64)> {
    let (r, per) = a.at?;
    let ty = src.value_type(a.value);
    let (shape, _) = src.shaped(ty)?;
    let (strides, offset) = strided_layout(src, ty).unwrap_or_else(|| (row_major_strides(&shape), 0));
    let s = strides[r];
    let period = shape[r] * s;
    // Each other dimension outside the period, or within one element of
    // the split dimension.
    let mut inner = offset % period;
    for d in 0..shape.len() {
        if d == r || shape[d] == 1 {
            continue;
        }
        if strides[d] % period == 0 {
            continue;
        }
        inner += (shape[d] - 1) * strides[d];
    }
    (inner < s).then_some((root(src, a.value), per * s, period))
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

/// Each dimension's extent, from the operands it indexes alone.
fn extents(src: &Module, op: OpId, maps: &[Option<Map>], dims: usize) -> Vec<u64> {
    let mut extents = vec![1; dims];
    for (k, &v) in src.ops[op.index()].operands.iter().enumerate() {
        if let (Some(map), Some((shape, _))) = (&maps[k], src.shaped(src.value_type(v))) {
            for (r, e) in map.results.iter().enumerate() {
                if let Expr::Dim(d) = e {
                    extents[*d] = shape[r];
                }
            }
        }
    }
    extents
}

/// Whether `op` is a matrix product (two inputs, sums), and if so whether
/// it is large, and whether its second input is constant weights.
fn product(src: &Module, op: OpId) -> Option<(bool, bool)> {
    let (maps, writes, parallel) = maps_of(src, op)?;
    if !parallel.iter().any(|p| !p) || writes.iter().filter(|w| !**w).count() != 2 {
        return None;
    }
    let large = extents(src, op, &maps, parallel.len()).iter().product::<u64>() >= LARGE;
    Some((large, copied(src, src.ops[op.index()].operands[1])))
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
    let mut defined = HashSet::new();
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

/// `op`'s operands, split along dimension `d` into `chunks`, each `want`
/// long but the last (or the least length that suits), if it can be: each
/// operand that `d` indexes is indexed by it alone, in one place; each
/// chunk's part of each output is whole 64-byte lines; and the body does
/// not ask for the index (`linalg.index`).
fn split(src: &Module, op: OpId, d: usize, chunks: u64, want: Option<u64>, cx: &Cx) -> Option<Vec<Access>> {
    let (maps, writes, parallel) = maps_of(src, op)?;
    if !parallel.get(d).copied().unwrap_or(false) {
        return None;
    }
    let extent = extents(src, op, &maps, parallel.len())[d];
    // A product: by its batch; a large one of constant weights by its
    // columns, whole panels of them; another by its rows, at least `rows`
    // each (as many as a kernel's tile has).
    let product = product(src, op);
    let (mut unit, mut least) = (1, 1);
    if let Some((large, weights)) = product {
        let indexes = |k: usize| maps[k].as_ref().is_some_and(|m| m.results.iter().any(|e| uses(e, d)));
        match (indexes(0), indexes(1)) {
            (true, true) => {}
            (true, false) if !large => least = cx.rows,
            (false, true) if large && weights => unit = cx.cols,
            _ => return None,
        }
    }
    let mut indexed = false;
    src.walk(op, &mut |inner| {
        indexed |= src.op_name(inner) == "linalg.index"
            && src.op_attr(inner, "dim").and_then(|a| src.int_of(a)) == Some(d as i64);
    });
    if indexed || extent < chunks {
        return None;
    }
    let lengths: Vec<u64> = match want {
        Some(w) => vec![w],
        None => (extent.div_ceil(chunks)..=extent).take_while(|&per| extent.div_ceil(per) == chunks).collect(),
    };
    lengths
        .into_iter()
        .filter(|&per| per % unit == 0 && per >= least && extent.div_ceil(per) == chunks)
        .find_map(|per| accesses(src, op, &maps, &writes, d, per, product == Some((true, true))))
}

/// `op`'s operands' accesses, split along dimension `d`, `per` to a chunk.
fn accesses(
    src: &Module,
    op: OpId,
    maps: &[Option<Map>],
    writes: &[bool],
    d: usize,
    per: u64,
    weights: bool,
) -> Option<Vec<Access>> {
    let o = &src.ops[op.index()];
    let mut accesses = Vec::new();
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
        if writes[k] {
            let r = at?;
            let (strides, offset) = strided_layout(src, ty).unwrap_or_else(|| (row_major_strides(&shape), 0));
            let bytes = elem_bytes(src, elem).ok()?;
            if (per * strides[r] * bytes) % 64 != 0 || (offset * bytes) % 64 != 0 {
                return None;
            }
        }
        // A small product's constant (its weights) whole, for the kernel to
        // see; a large one's only its weights' columns.
        let product = maps.len() == 3 && writes.iter().filter(|w| !**w).count() == 2;
        if at.is_some() && copied(src, v) && product && !(weights && k == 1) {
            return None;
        }
        // A value is one part of itself for the operation.
        let at = at.map(|r| (r, per));
        if accesses.iter().any(|a: &Access| a.value == v && a.at != at) {
            return None;
        }
        accesses.push(Access { value: v, at, write: writes[k] });
    }
    for v in captured(src, op) {
        accesses.push(Access { value: v, at: None, write: false });
    }
    Some(accesses)
}

/// The most chunks (up to `most`) `op` splits into, and how; `None` if it
/// is not split.
fn best(src: &Module, op: OpId, cx: &Cx) -> Option<(u64, Vec<Access>)> {
    let (_, _, parallel) = maps_of(src, op)?;
    (2..=cx.most).rev().find_map(|c| (0..parallel.len()).find_map(|d| split(src, op, d, c, None, cx)).map(|a| (c, a)))
}

/// Whether the accesses each split each buffer that any of them writes the
/// same way.
fn consistent(src: &Module, all: &[&Access]) -> bool {
    let mut keys: HashMap<ValueId, Option<(u64, u64)>> = HashMap::new();
    let roots: HashSet<ValueId> = all.iter().filter(|a| a.write).map(|a| root(src, a.value)).collect();
    for a in all {
        let r = root(src, a.value);
        if !roots.contains(&r) {
            continue;
        }
        let k = key(src, a).map(|(_, block, period)| (block, period));
        if k.is_none() || *keys.entry(r).or_insert(k) != k {
            return false;
        }
    }
    true
}

/// How `op` can be split to go with group `g`: into as many chunks, each
/// buffer that any of them writes split the same way by all; and whether
/// it is a product split by what it sums over.
fn joins(src: &Module, op: OpId, g: &Group, cx: &Cx) -> Option<(Vec<Access>, bool)> {
    let (maps, _, parallel) = maps_of(src, op)?;
    let written: HashMap<ValueId, (u64, u64)> = g
        .accesses()
        .filter(|a| a.write)
        .filter_map(|a| key(src, a).map(|(r, block, period)| (r, (block, period))))
        .collect();
    let ok = |acc: &[Access]| {
        let all: Vec<&Access> = g.accesses().chain(acc).collect();
        consistent(src, &all)
    };
    if let Some(acc) = ksplit(src, op, g, &maps, &written)
        && ok(&acc)
    {
        return Some((acc, true));
    }
    let o = &src.ops[op.index()];
    (0..parallel.len())
        .find_map(|d| {
            // The lengths that would split as the group does what it writes.
            let mut wants: Vec<Option<u64>> = Vec::new();
            for (k, &v) in o.operands.iter().enumerate() {
                let (Some(map), Some(&(block, period))) = (&maps[k], written.get(&root(src, v))) else { continue };
                let Some(r) = map.results.iter().position(|e| *e == Expr::Dim(d)) else { continue };
                let ty = src.value_type(v);
                let Some((shape, _)) = src.shaped(ty) else { continue };
                let strides = strided_layout(src, ty).map_or_else(|| row_major_strides(&shape), |l| l.0);
                if shape[r] * strides[r] == period && block % strides[r] == 0 {
                    wants.push(Some(block / strides[r]));
                }
            }
            wants.push(None);
            wants.into_iter().find_map(|w| split(src, op, d, g.chunks, w, cx).filter(|acc| ok(acc)))
        })
        .map(|acc| (acc, false))
}

/// Group `g`, of fills and copies alone, and `op` after them, split as `op`
/// splits best, if they all can be.
fn regroup(src: &Module, op: OpId, g: &Group, cx: &Cx) -> Option<Group> {
    if g.entries.iter().any(|e| !matches!(src.op_name(e.op), "linalg.fill" | "memref.copy")) {
        return None;
    }
    let (chunks, acc) = best(src, op, cx)?;
    let mut new = Group { entries: vec![Entry { op, acc, partial: None }], chunks };
    let mut before = Vec::new();
    for e in &g.entries {
        let (acc, _) = joins(src, e.op, &new, cx)?;
        new.entries.push(Entry { op: e.op, acc: acc.clone(), partial: None });
        before.push(Entry { op: e.op, acc, partial: None });
    }
    before.push(new.entries.swap_remove(0));
    Some(Group { entries: before, chunks })
}

/// Large product `op` of constant weights, split by the columns it sums
/// over as `g` has split what it writes of its first input (each chunk's
/// sums to a buffer of its own), if it can be: its first input and its
/// weights' rows split, its output not touched.
fn ksplit(
    src: &Module,
    op: OpId,
    g: &Group,
    maps: &[Option<Map>],
    written: &HashMap<ValueId, (u64, u64)>,
) -> Option<Vec<Access>> {
    if product(src, op) != Some((true, true)) || maps.len() != 3 {
        return None;
    }
    let (_, _, parallel) = maps_of(src, op)?;
    let k = parallel.iter().position(|p| !p)?;
    let o = &src.ops[op.index()];
    let (a, b) = (o.operands[0], o.operands[1]);
    let place = |m: &Option<Map>| {
        let m = m.as_ref()?;
        let at: Vec<usize> = (0..m.results.len()).filter(|&r| uses(&m.results[r], k)).collect();
        match at[..] {
            [r] if m.results[r] == Expr::Dim(k) => Some(r),
            _ => None,
        }
    };
    let (ra, rb) = (place(&maps[0])?, place(&maps[1])?);
    let &(block, period) = written.get(&root(src, a))?;
    let ty = src.value_type(a);
    let (shape, _) = src.shaped(ty)?;
    let strides = strided_layout(src, ty).map_or_else(|| row_major_strides(&shape), |l| l.0);
    if shape[ra] * strides[ra] != period || block % strides[ra] != 0 {
        return None;
    }
    let per = block / strides[ra];
    if shape[ra].div_ceil(per) != g.chunks {
        return None;
    }
    let mut acc = vec![
        Access { value: a, at: Some((ra, per)), write: false },
        Access { value: b, at: Some((rb, per)), write: false },
    ];
    for v in captured(src, op) {
        acc.push(Access { value: v, at: None, write: false });
    }
    Some(acc)
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

    // Constants are copied in (scalars, and globals and views of them, for
    // the kernels to see constant weights); every other value is a
    // parameter.
    let mut params: Vec<ValueId> = Vec::new();
    for a in g.accesses() {
        if !copied(src, a.value) && !params.contains(&a.value) {
            params.push(a.value);
        }
    }

    // Whether the last chunk is shorter: then a function for it of its own.
    let ragged = g.accesses().any(|a| {
        a.at.is_some_and(|(r, per)| src.shaped(src.value_type(a.value)).is_some_and(|(s, _)| s[r] % per != 0))
    });
    let name = format!("{fname}.part{}", cx.tasks);
    cx.tasks += 1;
    if ragged {
        let full = format!("{name}.full");
        let last = format!("{name}.last");
        body(src, &g, &params, &full, false, out, cx)?;
        body(src, &g, &params, &last, true, out, cx)?;
        // The task: the last chunk's function for the last chunk, else the
        // other's.
        let tb = declare(out, cx, &name);
        let [ctx, chunk] = out.blocks[tb.index()].args[..] else { unreachable!() };
        let n = constant(out, tb, g.chunks as i64 - 1);
        let eq = out.int_attr(0, i64t);
        let i1 = out.int_type(1);
        let is_last =
            build(out, tb, OpSpec::new("llvm.icmp").operands(&[chunk, n]).results(&[i1]).prop("predicate", eq));
        let (fs, ls) = (out.symbol_attr(&full), out.symbol_attr(&last));
        let f = build(out, tb, OpSpec::new("llvm.mlir.addressof").results(&[ptr]).prop("global_name", fs));
        let l = build(out, tb, OpSpec::new("llvm.mlir.addressof").results(&[ptr]).prop("global_name", ls));
        let which = build(out, tb, OpSpec::new("llvm.select").operands(&[is_last, l, f]).results(&[ptr]));
        let cconv = out.dialect_attr("llvm.cconv", Some("<ccc>"));
        let tail = out.dialect_attr("llvm.tailcallkind", Some("<none>"));
        let fm = out.dialect_attr("llvm.fastmath", Some("<none>"));
        let bundles = out.dense_array_attr("i32", &[]);
        let segments = out.dense_array_attr("i32", &[3, 0]);
        OpSpec::new("llvm.call")
            .operands(&[which, ctx, chunk])
            .prop("CConv", cconv)
            .prop("TailCallKind", tail)
            .prop("fastmathFlags", fm)
            .prop("op_bundle_sizes", bundles)
            .prop("operandSegmentSizes", segments)
            .build(out, Some(tb));
        OpSpec::new("func.return").build(out, Some(tb));
    } else {
        body(src, &g, &params, &name, false, out, cx)?;
    }

    // The context: a word for each parameter.
    let n = constant(out, at, params.len() as i64);
    let et = out.type_attr(i64t);
    let ctx = build(out, at, OpSpec::new("llvm.alloca").operands(&[n]).results(&[ptr]).prop("elem_type", et));
    let gep = |out: &mut Module, blk: BlockId, p: ValueId, off: ValueId| -> ValueId {
        let et = out.type_attr(i64t);
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
        let p = gep(out, at, ctx, slot);
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

/// A function `name(context, chunk)` of the module, private; its block.
fn declare(out: &mut Module, cx: &Cx, name: &str) -> BlockId {
    let i64t = out.int_type(64);
    let ptr = out.dialect_type("llvm.ptr", None);
    let fty = out.function_type(&[ptr, i64t], &[]);
    let fty = out.type_attr(fty);
    let sym = out.string_attr(name);
    let vis = out.string_attr("private");
    let f = OpSpec::new("func.func")
        .prop("function_type", fty)
        .prop("sym_name", sym)
        .prop("sym_visibility", vis)
        .regions(1)
        .build(out, Some(cx.mblock));
    let region = out.region_of(f, 0);
    out.add_block(region, &[ptr, i64t])
}

/// Group `g`'s operations on a chunk, as function `name(context, chunk)`:
/// for any chunk but the last, or (`last`) for the last.
fn body(
    src: &Module,
    g: &Group,
    params: &[ValueId],
    name: &str,
    last: bool,
    out: &mut Module,
    cx: &Cx,
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

    let tb = declare(out, cx, name);
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
    let mut parts: HashMap<(ValueId, Option<(usize, u64)>), ValueId> = HashMap::new();
    for a in g.accesses() {
        if parts.contains_key(&(a.value, a.at)) || copied(src, a.value) && a.at.is_none() {
            continue;
        }
        let ty = src.value_type(a.value);
        let word = words[&a.value];
        let value = if let Some((shape, elem)) = src.shaped(ty) {
            let mut base = build(out, tb, OpSpec::new("llvm.inttoptr").operands(&[word]).results(&[ptr]));
            let mut part = ty;
            if let Some((r, per)) = a.at {
                let (strides, offset) = strided_layout(src, ty).unwrap_or_else(|| (row_major_strides(&shape), 0));
                let step = constant(out, tb, (per * strides[r] * elem_bytes(src, elem)?) as i64);
                let flags = out.int_attr(0, i32t);
                let off = build(
                    out,
                    tb,
                    OpSpec::new("llvm.mul").operands(&[chunk, step]).results(&[i64t]).prop("overflowFlags", flags),
                );
                base = gep(out, tb, base, off, i8t);
                let mut s = shape.clone();
                s[r] = if last { shape[r] - (shape[r].div_ceil(per) - 1) * per } else { per };
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
    // Each operation, on its parts of its operands; a product split by what
    // it sums over, on its chunk's buffer of sums, zeroed first.
    for e in &g.entries {
        let mut local = inner.clone();
        for a in &e.acc {
            if let Some(&p) = parts.get(&(a.value, a.at)) {
                local.insert(a.value, p);
            }
        }
        if let Some(p) = e.partial {
            let c = src.ops[e.op.index()].operands[2];
            let (shape, elem) = src.shaped(src.value_type(c)).ok_or("a product of no shape")?;
            let bytes = shape.iter().product::<u64>() * elem_bytes(src, elem)?;
            let base = build(out, tb, OpSpec::new("llvm.inttoptr").operands(&[words[&p]]).results(&[ptr]));
            let step = constant(out, tb, bytes as i64);
            let flags = out.int_attr(0, i32t);
            let off = build(
                out,
                tb,
                OpSpec::new("llvm.mul").operands(&[chunk, step]).results(&[i64t]).prop("overflowFlags", flags),
            );
            let base = gep(out, tb, base, off, i8t);
            let mine = out.memref_type(&shape, elem, None);
            let mine =
                build(out, tb, OpSpec::new("builtin.unrealized_conversion_cast").operands(&[base]).results(&[mine]));
            let zero = out.float_attr("0.000000e+00", elem);
            let zero = build(out, tb, OpSpec::new("arith.constant").results(&[elem]).prop("value", zero));
            let segments = out.dense_array_attr("i32", &[1, 1]);
            let f = OpSpec::new("linalg.fill")
                .operands(&[zero, mine])
                .prop("operandSegmentSizes", segments)
                .regions(1)
                .build(out, Some(tb));
            let region = out.region_of(f, 0);
            let fb = out.add_block(region, &[elem, elem]);
            let x = out.blocks[fb.index()].args[0];
            OpSpec::new("linalg.yield").operands(&[x]).build(out, Some(fb));
            local.insert(c, mine);
        }
        out.clone_op(src, e.op, Some(tb), &mut local)?;
    }
    OpSpec::new("func.return").build(out, Some(tb));
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
