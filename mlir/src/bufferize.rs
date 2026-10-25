//! Tensors to buffers: `linalg` on tensors becomes `linalg` on `memref`s,
//! as upstream's `one-shot-bufferize` (with `bufferize-function-boundaries`)
//! followed by `buffer-results-to-out-params` does, with a simpler rule for
//! when an operation may write into a buffer it is given.
//!
//! - A function's tensor arguments become `memref` arguments, and its
//!   results become `memref` arguments after them, which the function
//!   copies its results into (`memref.copy`). It returns nothing.
//! - `tensor.empty` becomes `memref.alloc`; a tensor constant becomes a
//!   private `memref.global` and a `memref.get_global`.
//! - `linalg.fill` and `linalg.generic` write into their output's buffer
//!   when it is one of the function's own, no tensor that shares it is used
//!   later, and the operation does not also read it; otherwise into a new
//!   buffer, which is first a copy of the output if the operation reads it.
//! - `tensor.expand_shape`, `tensor.collapse_shape` and
//!   `tensor.extract_slice` become views of their source's buffer
//!   (`memref.expand_shape`, `memref.collapse_shape`, `memref.subview`);
//!   `tensor.extract` becomes `memref.load`, in an operation's body too.
//! - `tensor.concat` becomes a buffer that each input is copied into.
//! - `tm_tensor.scan` writes into new buffers, the accumulator's a copy of
//!   its starting value.
//! - `tensor.pad` becomes a buffer filled with the padding value, and a
//!   copy of the input into a `memref.subview` of it.
//! - Every buffer allocated is freed (`memref.dealloc`) before returning.
//! - A buffer allocated only to be worked out and then copied whole into a
//!   result's argument (through views: `memref.expand_shape`,
//!   `memref.collapse_shape`) is that argument instead, viewed as the
//!   buffer was, and the copy goes: what LLVM's `memcpyopt` does for a
//!   call that writes a temporary copied to its destination. Only when
//!   nothing between the allocation and the copy touches the argument, or
//!   any other argument of its element type (which might share its memory).

use std::collections::{HashMap, HashSet};

use crate::build::OpSpec;
use crate::ir::*;

/// Bufferizes every function in `src`.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
    let mut globals = Globals::default();
    for top in src.top_ops().collect::<Vec<_>>() {
        match src.op_name(top) {
            "builtin.module" => {
                let module = clone_shell(src, top, &mut out, None);
                let region = out.region_of(module, 0);
                let block = out.add_block(region, &[]);
                for &r in &src.ops[top.index()].regions {
                    for &b in &src.regions[r.index()].blocks {
                        for &op in &src.blocks[b.index()].ops {
                            lower_top(src, op, &mut out, Some(block), &mut globals)?;
                        }
                    }
                }
                // Globals first, as upstream places them.
                let ops = &mut out.blocks[block.index()].ops;
                let (mut g, rest): (Vec<OpId>, Vec<OpId>) = ops.iter().partition(|o| globals.ops.contains(o));
                g.extend(rest);
                *ops = g;
            }
            _ => lower_top(src, top, &mut out, None, &mut globals)?,
        }
    }
    let funcs: Vec<OpId> = (0..out.ops.len() as u32)
        .map(OpId)
        .filter(|&f| out.op_name(f) == "func.func" && out.ops[f.index()].parent.is_some())
        .collect();
    for f in funcs {
        forward_copies(&mut out, f);
    }
    Ok(out)
}

/// The values each operation in `op` (itself included, and what its
/// regions hold) uses.
fn used_in(m: &Module, op: OpId) -> HashSet<ValueId> {
    let mut used = HashSet::new();
    m.walk(op, &mut |o| used.extend(m.ops[o.index()].operands.iter().copied()));
    used
}

/// Buffers copied whole into an argument, made that argument (see the
/// module's documentation).
fn forward_copies(m: &mut Module, f: OpId) {
    let Some(&region) = m.ops[f.index()].regions.first() else { return };
    let Some(&block) = m.regions[region.index()].blocks.first() else { return };
    while forward_one(m, block) {}
}

/// Forwards the first copy in `block` that can be; whether there was one.
fn forward_one(m: &mut Module, block: BlockId) -> bool {
    let args = m.blocks[block.index()].args.clone();
    let ops = m.blocks[block.index()].ops.clone();
    for (ci, &copy) in ops.iter().enumerate() {
        if m.op_name(copy) == "memref.copy" && forward(m, block, &args, &ops, ci, copy) {
            return true;
        }
    }
    false
}

fn forward(m: &mut Module, block: BlockId, args: &[ValueId], ops: &[OpId], ci: usize, copy: OpId) -> bool {
    let [src, dst] = m.ops[copy.index()].operands[..] else { return false };
    // Into an argument with no layout of its own.
    let dst_ty = m.value_type(dst);
    if !args.contains(&dst) || crate::build::strided_layout(m, dst_ty).is_some() {
        return false;
    }
    let Some((_, dst_elem)) = m.shaped(dst_ty) else { return false };
    // From views of an allocation in this block.
    let mut chain = Vec::new();
    let mut at = src;
    let alloc = loop {
        let ValueDef::Result { op, .. } = m.values[at.index()].def else { return false };
        match m.op_name(op) {
            "memref.alloc" if m.ops[op.index()].operands.is_empty() => break op,
            "memref.expand_shape" | "memref.collapse_shape" => {
                chain.push(op);
                at = m.ops[op.index()].operands[0];
            }
            _ => return false,
        }
    };
    let Some(ai) = ops.iter().position(|&o| o == alloc) else { return false };
    let buffer = m.ops[alloc.index()].results[0];
    if ai > ci || crate::build::strided_layout(m, m.value_type(buffer)).is_some() {
        return false;
    }
    // The buffer used only before the copy (and freed after it); the views
    // only on the way to the copy; and between the allocation and the copy,
    // no argument the destination might share memory with.
    let views: Vec<ValueId> = chain.iter().map(|&o| m.ops[o.index()].results[0]).collect();
    let sharing: Vec<ValueId> =
        args.iter().copied().filter(|&a| m.shaped(m.value_type(a)).is_some_and(|(_, e)| e == dst_elem)).collect();
    for (k, &o) in ops.iter().enumerate() {
        if o == copy || chain.contains(&o) {
            continue;
        }
        let used = used_in(m, o);
        if views.iter().any(|v| used.contains(v)) {
            return false;
        }
        if used.contains(&buffer) && k > ci && m.op_name(o) != "memref.dealloc" {
            return false;
        }
        if k > ai && k < ci && sharing.iter().any(|a| used.contains(a)) {
            return false;
        }
    }
    // The argument, viewed back the way the copy viewed the buffer, where
    // the allocation was.
    let mut view = dst;
    for &o in &chain {
        let to = m.value_type(m.ops[o.index()].operands[0]);
        let reassoc = m.op_attr(o, "reassociation").expect("a reshape with no reassociation");
        let inverse = if m.op_name(o) == "memref.expand_shape" {
            OpSpec::new("memref.collapse_shape").prop("reassociation", reassoc)
        } else {
            let (shape, _) = m.shaped(to).expect("a reshape of no shape");
            let shape: Vec<i64> = shape.iter().map(|&d| d as i64).collect();
            let sizes = m.dense_array_attr("i64", &shape);
            OpSpec::new("memref.expand_shape").prop("reassociation", reassoc).prop("static_output_shape", sizes)
        };
        let v = inverse.operands(&[view]).results(&[to]).build(m, Some(block));
        view = m.result(v);
        let list = &mut m.blocks[block.index()].ops;
        list.pop();
        let at = list.iter().position(|&x| x == alloc).unwrap();
        list.insert(at, v);
    }
    // The buffer's uses now the argument's view; the allocation, its frees,
    // the views and the copy gone.
    for o in m.ops.iter_mut() {
        for x in o.operands.iter_mut() {
            if *x == buffer {
                *x = view;
            }
        }
    }
    let frees: Vec<OpId> = m.blocks[block.index()]
        .ops
        .iter()
        .copied()
        .filter(|&o| m.op_name(o) == "memref.dealloc" && m.ops[o.index()].operands == [view])
        .collect();
    let gone: HashSet<OpId> = chain.iter().copied().chain([alloc, copy]).chain(frees).collect();
    m.blocks[block.index()].ops.retain(|o| !gone.contains(o));
    true
}

/// An operation with its properties and attributes but not its regions'
/// contents: a new region for each.
fn clone_shell(src: &Module, op: OpId, out: &mut Module, block: Option<BlockId>) -> OpId {
    let o = &src.ops[op.index()];
    let mut spec = OpSpec::new(src.op_name(op)).regions(o.regions.len()).loc(o.loc);
    if let Some(Attr::Dict(es)) = o.properties.map(|p| src.attr(p)) {
        for (k, v) in es {
            spec = spec.prop(k, *v);
        }
    }
    if let Some(Attr::Dict(es)) = o.attrs.map(|a| src.attr(a)) {
        for (k, v) in es {
            spec = spec.attr(k, *v);
        }
    }
    spec.build(out, block)
}

/// The `memref.global`s made so far, by their value, and their names.
#[derive(Default)]
struct Globals {
    by_value: HashMap<(AttrId, TypeId), String>,
    names: HashSet<String>,
    ops: HashSet<OpId>,
}

fn lower_top(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    globals: &mut Globals,
) -> Result<(), String> {
    match src.op_name(op) {
        "func.func" => lower_func(src, op, out, block, globals),
        other => Err(format!("{other}: only functions are bufferized")),
    }
}

/// The `memref` type with the same shape and elements as tensor type `t`.
fn memref_of(m: &mut Module, t: TypeId) -> Result<TypeId, String> {
    match m.ty(m.resolve_type(t)).clone() {
        Type::Tensor { shape, elem, encoding: None } => {
            Ok(m.intern_type(Type::MemRef { shape, elem, extra: Vec::new() }))
        }
        Type::Tensor { .. } => Err("tensors with an encoding are not supported".to_string()),
        _ => Ok(t),
    }
}

/// How many of a `linalg` operation's operands are inputs: the first of its
/// `operandSegmentSizes`, or all but the last.
pub(crate) fn inputs_of(m: &Module, op: OpId) -> usize {
    m.op_attr(op, "operandSegmentSizes")
        .and_then(|a| m.int_list(a))
        .and_then(|l| l.first().copied())
        .map_or(m.ops[op.index()].operands.len().saturating_sub(1), |n| n as usize)
}

fn dict(m: &Module, d: Option<AttrId>) -> Vec<(String, AttrId)> {
    match d.map(|d| m.attr(d)) {
        Some(Attr::Dict(es)) => es.clone(),
        _ => Vec::new(),
    }
}

fn is_tensor(m: &Module, t: TypeId) -> bool {
    matches!(m.ty(m.resolve_type(t)), Type::Tensor { .. })
}

fn lower_func(
    src: &Module,
    f: OpId,
    out: &mut Module,
    parent: Option<BlockId>,
    globals: &mut Globals,
) -> Result<(), String> {
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let fail = |e: String| format!("@{name}: {e}");
    let o = &src.ops[f.index()];
    let Some(&region) = o.regions.first() else { return Err(fail("no body".into())) };
    let [block] = src.regions[region.index()].blocks[..] else {
        return Err(fail("a body of more than one block is not supported".into()));
    };
    let body = &src.blocks[block.index()];
    let Some(&ret) = body.ops.last().filter(|&&r| src.op_name(r) == "func.return") else {
        return Err(fail("the body does not end in func.return".into()));
    };

    // Arguments, then a buffer for each result.
    let mut types = Vec::new();
    for &a in &body.args {
        types.push(memref_of(out, src.value_type(a)).map_err(fail)?);
    }
    let returned = &src.ops[ret.index()].operands;
    for &v in returned {
        types.push(memref_of(out, src.value_type(v)).map_err(fail)?);
    }
    let fty = out.function_type(&types, &[]);
    let fty = out.type_attr(fty);
    let mut spec = OpSpec::new("func.func").prop("function_type", fty).regions(1).loc(o.loc);
    for key in ["sym_name", "sym_visibility"] {
        if let Some(v) = src.op_attr(f, key) {
            spec = spec.prop(key, v);
        }
    }
    let func = spec.build(out, parent);
    let entry = {
        let region = out.region_of(func, 0);
        out.add_block(region, &types)
    };
    let args = out.blocks[entry.index()].args.clone();

    // The last operation that uses each value, counting uses inside regions.
    let mut last_use: HashMap<ValueId, usize> = HashMap::new();
    for (i, &op) in body.ops.iter().enumerate() {
        src.walk(op, &mut |inner| {
            for &v in &src.ops[inner.index()].operands {
                last_use.insert(v, i);
            }
        });
    }

    let mut b = Buf {
        src,
        out,
        block: entry,
        map: HashMap::new(),
        owned: Vec::new(),
        own: HashSet::new(),
        empty: HashSet::new(),
        root: HashMap::new(),
        sharing: HashMap::new(),
        globals,
    };
    for (&a, &n) in body.args.iter().zip(&args) {
        b.bind(a, n);
    }
    for (i, &op) in body.ops[..body.ops.len() - 1].iter().enumerate() {
        b.op(op, i, &last_use).map_err(|e| fail(format!("{}: {e}", src.op_name(op))))?;
    }
    for (k, &v) in returned.iter().enumerate() {
        let buffer = *b.map.get(&v).ok_or_else(|| fail("a result that was not bufferized".into()))?;
        let dest = args[body.args.len() + k];
        OpSpec::new("memref.copy").operands(&[buffer, dest]).build(b.out, Some(entry));
    }
    for buffer in std::mem::take(&mut b.owned) {
        OpSpec::new("memref.dealloc").operands(&[buffer]).build(b.out, Some(entry));
    }
    OpSpec::new("func.return").build(b.out, Some(entry));
    Ok(())
}

struct Buf<'a> {
    src: &'a Module,
    out: &'a mut Module,
    block: BlockId,
    /// Each tensor's buffer, and each other value's copy.
    map: HashMap<ValueId, ValueId>,
    /// Buffers allocated here, to free.
    owned: Vec<ValueId>,
    own: HashSet<ValueId>,
    /// Tensors from `tensor.empty`, whose contents nothing reads.
    empty: HashSet<ValueId>,
    /// The buffer each view is a view of, at the bottom.
    root: HashMap<ValueId, ValueId>,
    /// The tensors whose buffers are each buffer or a view of it.
    sharing: HashMap<ValueId, Vec<ValueId>>,
    globals: &'a mut Globals,
}

impl Buf<'_> {
    /// Records that tensor `t` is held in `buffer`.
    fn bind(&mut self, t: ValueId, buffer: ValueId) {
        self.map.insert(t, buffer);
        if is_tensor(self.src, self.src.value_type(t)) {
            let root = self.root_of(buffer);
            self.sharing.entry(root).or_default().push(t);
        }
    }

    fn root_of(&self, buffer: ValueId) -> ValueId {
        self.root.get(&buffer).copied().unwrap_or(buffer)
    }

    /// Records that `view` is a view of `of`'s buffer, held as `buffer`.
    fn bind_view(&mut self, view: ValueId, buffer: ValueId, of: ValueId) {
        let root = self.root_of(of);
        self.root.insert(buffer, root);
        self.bind(view, buffer);
    }

    fn buffer(&self, t: ValueId) -> Result<ValueId, String> {
        self.map.get(&t).copied().ok_or_else(|| "a value that was not bufferized".to_string())
    }

    fn alloc(&mut self, ty: TypeId) -> ValueId {
        let align = self.out.int_type(64);
        let align = self.out.int_attr(64, align);
        let segments = self.out.dense_array_attr("i32", &[0, 0]);
        let a = OpSpec::new("memref.alloc")
            .results(&[ty])
            .prop("alignment", align)
            .prop("operandSegmentSizes", segments)
            .build(self.out, Some(self.block));
        let v = self.out.result(a);
        self.owned.push(v);
        self.own.insert(v);
        v
    }

    /// The buffer an operation writes its output into, given the output
    /// tensor `outs`, at operation `i` of the body.
    fn destination(
        &mut self,
        outs: ValueId,
        reads: &[ValueId],
        i: usize,
        last_use: &HashMap<ValueId, usize>,
    ) -> Result<ValueId, String> {
        let buffer = self.buffer(outs)?;
        let done = |t: &ValueId| last_use.get(t).is_none_or(|&l| l <= i);
        let unshared = self.sharing.get(&buffer).is_none_or(|ts| ts.iter().all(done));
        let read = reads.iter().any(|&r| self.root_of(r) == buffer);
        if self.own.contains(&buffer) && unshared && !read {
            return Ok(buffer);
        }
        let ty = self.out.value_type(buffer);
        let fresh = self.alloc(ty);
        if !self.empty.contains(&outs) {
            OpSpec::new("memref.copy").operands(&[buffer, fresh]).build(self.out, Some(self.block));
        }
        Ok(fresh)
    }

    fn op(&mut self, op: OpId, i: usize, last_use: &HashMap<ValueId, usize>) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        match src.op_name(op) {
            "arith.constant" if is_tensor(src, src.value_type(o.results[0])) => {
                let ty = memref_of(self.out, src.value_type(o.results[0]))?;
                let value = src.op_attr(op, "value").ok_or("a constant without a value")?;
                let name = self.global(value, ty);
                let sym = self.out.symbol_attr(&name);
                let g =
                    OpSpec::new("memref.get_global").results(&[ty]).prop("name", sym).build(self.out, Some(self.block));
                let v = self.out.result(g);
                self.map.insert(o.results[0], v);
            }
            "tensor.empty" => {
                let ty = memref_of(self.out, src.value_type(o.results[0]))?;
                let v = self.alloc(ty);
                self.map.insert(o.results[0], v);
                self.empty.insert(o.results[0]);
            }
            "linalg.fill" | "linalg.generic" => {
                let n_ins = inputs_of(src, op);
                let (ins, outs) = o.operands.split_at(n_ins);
                let mut operands = Vec::new();
                for v in ins {
                    operands.push(self.buffer(*v)?);
                }
                // The inputs' buffers, and those the body reads, as
                // `tensor.extract` does (not the outputs: writing into one
                // in place is the point).
                let mut reads = operands.clone();
                src.walk(op, &mut |inner| {
                    if inner == op {
                        return;
                    }
                    for v in &src.ops[inner.index()].operands {
                        if let Some(&b) = self.map.get(v) {
                            reads.push(b);
                        }
                    }
                });
                let mut dests = Vec::new();
                for &out in outs {
                    let dest = self.destination(out, &reads, i, last_use)?;
                    reads.push(dest);
                    dests.push(dest);
                }
                operands.extend(&dests);
                let new = self.with_props(op, &operands, &[]);
                self.body(o.regions[0], self.out.region_of(new, 0))?;
                for (&r, &dest) in o.results.iter().zip(&dests) {
                    self.bind(r, dest);
                }
            }
            "tensor.expand_shape" | "tensor.collapse_shape" => {
                let source = self.buffer(o.operands[0])?;
                let (shape, elem) = self.out.shaped(src.value_type(o.results[0])).ok_or("a result of unknown shape")?;
                if crate::build::strided_layout(self.out, self.out.value_type(source)).is_some() {
                    return Err("reshaping a strided view is not supported".into());
                }
                let ty = self.out.memref_type(&shape, elem, None);
                let name = if src.op_name(op) == "tensor.expand_shape" {
                    "memref.expand_shape"
                } else {
                    "memref.collapse_shape"
                };
                let mut spec = OpSpec::new(name).operands(&[source]).results(&[ty]).loc(o.loc);
                for (k, v) in dict(src, o.properties) {
                    spec = spec.prop(&k, v);
                }
                let view = spec.build(self.out, Some(self.block));
                let view = self.out.result(view);
                self.bind_view(o.results[0], view, source);
            }
            "tensor.extract_slice" => {
                let source = self.buffer(o.operands[0])?;
                if o.operands.len() != 1 {
                    return Err("dynamic slices are not supported".into());
                }
                let get = |k: &str| src.op_attr(op, k).and_then(|a| src.int_list(a)).ok_or(format!("no {k}"));
                let (offsets, sizes, steps) = (get("static_offsets")?, get("static_sizes")?, get("static_strides")?);
                let (shape, elem) = self.out.shaped(src.value_type(o.results[0])).ok_or("a result of unknown shape")?;
                if shape.len() != sizes.len() {
                    return Err("slices that drop dimensions are not supported".into());
                }
                let src_ty = self.out.value_type(source);
                let (strides, offset) = crate::build::strided_layout(self.out, src_ty).unwrap_or_else(|| {
                    let (s, _) = self.out.shaped(src_ty).unwrap();
                    (crate::build::row_major_strides(&s), 0)
                });
                let offset = offset as i64 + offsets.iter().zip(&strides).map(|(&o, &s)| o * s as i64).sum::<i64>();
                let strides: Vec<u64> = strides.iter().zip(&steps).map(|(&s, &k)| s * k as u64).collect();
                let layout = crate::build::strided_attr(self.out, &strides, offset as u64);
                let ty = self.out.memref_type(&shape, elem, Some(layout));
                let mut spec = OpSpec::new("memref.subview").operands(&[source]).results(&[ty]).loc(o.loc);
                for (k, v) in dict(src, o.properties) {
                    spec = spec.prop(&k, v);
                }
                let view = spec.build(self.out, Some(self.block));
                let view = self.out.result(view);
                self.bind_view(o.results[0], view, source);
            }
            "tensor.extract" => {
                let operands = o.operands.iter().map(|&v| self.buffer(v)).collect::<Result<Vec<_>, _>>()?;
                let ty = src.value_type(o.results[0]);
                let l = OpSpec::new("memref.load").operands(&operands).results(&[ty]).build(self.out, Some(self.block));
                let v = self.out.result(l);
                self.map.insert(o.results[0], v);
            }
            "tensor.concat" => {
                let dim = src.op_attr(op, "dim").and_then(|a| src.int_of(a)).ok_or("no dim")? as usize;
                let ty = memref_of(self.out, src.value_type(o.results[0]))?;
                let (out_shape, _) = self.out.shaped(ty).ok_or("a result of unknown shape")?;
                let dest = self.alloc(ty);
                let strides = crate::build::row_major_strides(&out_shape);
                let mut at = 0u64;
                for &input in &o.operands {
                    let buffer = self.buffer(input)?;
                    let (shape, elem) =
                        self.out.shaped(self.out.value_type(buffer)).ok_or("an input of unknown shape")?;
                    let mut offsets = vec![0i64; shape.len()];
                    offsets[dim] = at as i64;
                    let view = self.subview(dest, &offsets, &shape, elem, &strides);
                    OpSpec::new("memref.copy").operands(&[buffer, view]).build(self.out, Some(self.block));
                    at += shape[dim];
                }
                self.bind(o.results[0], dest);
            }
            "tm_tensor.scan" => {
                let [input, out_init, acc_init] = o.operands[..] else { return Err("expected three operands".into()) };
                let input = self.buffer(input)?;
                let out_ty = self.out.value_type(self.buffer(out_init)?);
                let out = self.alloc(out_ty);
                let acc_src = self.buffer(acc_init)?;
                let acc_ty = self.out.value_type(acc_src);
                let acc = self.alloc(acc_ty);
                OpSpec::new("memref.copy").operands(&[acc_src, acc]).build(self.out, Some(self.block));
                let new = self.with_props(op, &[input, out, acc], &[]);
                self.body(o.regions[0], self.out.region_of(new, 0))?;
                self.bind(o.results[0], out);
                self.bind(o.results[1], acc);
            }
            "tensor.pad" => self.pad(op)?,
            _ => {
                if o.operands.iter().chain(&o.results).any(|&v| is_tensor(src, src.value_type(v))) {
                    return Err("not supported yet".into());
                }
                self.out.clone_op(src, op, Some(self.block), &mut self.map)?;
            }
        }
        Ok(())
    }

    /// `op` with these operands and results, its properties, and an empty
    /// region for each of its own.
    fn with_props(&mut self, op: OpId, operands: &[ValueId], results: &[TypeId]) -> OpId {
        let o = &self.src.ops[op.index()];
        let mut spec =
            OpSpec::new(self.src.op_name(op)).operands(operands).results(results).regions(o.regions.len()).loc(o.loc);
        for (k, v) in dict(self.src, o.properties) {
            spec = spec.prop(&k, v);
        }
        spec.build(self.out, Some(self.block))
    }

    /// An operation's body copied into `into`, with `tensor.extract` of
    /// a tensor from outside it reading that tensor's buffer.
    fn body(&mut self, from: RegionId, into: RegionId) -> Result<(), String> {
        let src = self.src;
        for &b in &src.regions[from.index()].blocks {
            let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
            let nb = self.out.add_block(into, &types);
            for (&a, &n) in src.blocks[b.index()].args.iter().zip(&self.out.blocks[nb.index()].args.clone()) {
                self.map.insert(a, n);
            }
            let saved = std::mem::replace(&mut self.block, nb);
            for &op in &src.blocks[b.index()].ops {
                if src.op_name(op) == "tensor.extract" {
                    self.op(op, 0, &HashMap::new())?;
                } else {
                    self.out.clone_op(src, op, Some(nb), &mut self.map)?;
                }
            }
            self.block = saved;
        }
        Ok(())
    }

    /// A view of `buffer` (of row-major `strides`) at `offsets`, of `shape`.
    fn subview(&mut self, buffer: ValueId, offsets: &[i64], shape: &[u64], elem: TypeId, strides: &[u64]) -> ValueId {
        let offset: i64 = offsets.iter().zip(strides).map(|(&o, &s)| o * s as i64).sum();
        let layout = crate::build::strided_attr(self.out, strides, offset as u64);
        let ty = self.out.memref_type(shape, elem, Some(layout));
        let segments = self.out.dense_array_attr("i32", &[1, 0, 0, 0]);
        let offsets = self.out.dense_array_attr("i64", offsets);
        let sizes: Vec<i64> = shape.iter().map(|&s| s as i64).collect();
        let sizes = self.out.dense_array_attr("i64", &sizes);
        let ones = self.out.dense_array_attr("i64", &vec![1; shape.len()]);
        let v = OpSpec::new("memref.subview")
            .operands(&[buffer])
            .results(&[ty])
            .prop("operandSegmentSizes", segments)
            .prop("static_offsets", offsets)
            .prop("static_sizes", sizes)
            .prop("static_strides", ones)
            .build(self.out, Some(self.block));
        self.out.result(v)
    }

    /// `tensor.pad`: a new buffer filled with the padding value, and the
    /// input copied into the middle of it.
    fn pad(&mut self, op: OpId) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let low = src.op_attr(op, "static_low").and_then(|a| src.int_list(a)).ok_or("no static_low")?;
        if o.operands.len() != 1 {
            return Err("dynamic padding is not supported".into());
        }
        let yield_op = src.regions[o.regions[0].index()].blocks.first().and_then(|b| src.blocks[b.index()].ops.last());
        let value = yield_op.and_then(|&y| src.ops[y.index()].operands.first()).ok_or("no padding value")?;
        let value = *self.map.get(value).ok_or("a padding value defined inside the pad")?;
        let input = *self.map.get(&o.operands[0]).ok_or("an input that was not bufferized")?;
        let ty = memref_of(self.out, src.value_type(o.results[0]))?;
        let padded = self.alloc(ty);

        // Fill with the padding value.
        let segments = self.out.dense_array_attr("i32", &[1, 1]);
        let fill = OpSpec::new("linalg.fill")
            .operands(&[value, padded])
            .prop("operandSegmentSizes", segments)
            .regions(1)
            .build(self.out, Some(self.block));
        let elem = self.out.value_type(value);
        let region = self.out.region_of(fill, 0);
        let fb = self.out.add_block(region, &[elem, elem]);
        let a = self.out.blocks[fb.index()].args[0];
        OpSpec::new("linalg.yield").operands(&[a]).build(self.out, Some(fb));

        // The middle, as a strided view, and the input copied into it.
        let (pshape, _) = self.out.shaped(ty).ok_or("a padded tensor of unknown shape")?;
        let (ishape, ielem) = self.out.shaped(self.out.value_type(input)).ok_or("an input of unknown shape")?;
        let strides = crate::build::row_major_strides(&pshape);
        let offset: i64 = low.iter().zip(&strides).map(|(&l, &s)| l * s as i64).sum();
        let list: Vec<String> = strides.iter().map(|s| s.to_string()).collect();
        let layout = self.out.intern_attr(Attr::Builtin {
            keyword: "strided",
            body: format!("<[{}], offset: {offset}>", list.join(", ")),
            ty: None,
        });
        let view_ty = self.out.memref_type(&ishape, ielem, Some(layout));
        let ones = vec![1i64; ishape.len()];
        let sizes: Vec<i64> = ishape.iter().map(|&s| s as i64).collect();
        let segments = self.out.dense_array_attr("i32", &[1, 0, 0, 0]);
        let offsets = self.out.dense_array_attr("i64", &low);
        let sizes = self.out.dense_array_attr("i64", &sizes);
        let ones = self.out.dense_array_attr("i64", &ones);
        let view = OpSpec::new("memref.subview")
            .operands(&[padded])
            .results(&[view_ty])
            .prop("operandSegmentSizes", segments)
            .prop("static_offsets", offsets)
            .prop("static_sizes", sizes)
            .prop("static_strides", ones)
            .build(self.out, Some(self.block));
        let view = self.out.result(view);
        OpSpec::new("memref.copy").operands(&[input, view]).build(self.out, Some(self.block));
        self.map.insert(o.results[0], padded);
        Ok(())
    }

    /// The name of the private `memref.global` holding `value`, made if
    /// there is none yet, as `__constant_2x8xf32`.
    fn global(&mut self, value: AttrId, ty: TypeId) -> String {
        if let Some(n) = self.globals.by_value.get(&(value, ty)) {
            return n.clone();
        }
        let base = format!(
            "__constant_{}",
            crate::printer::type_text(self.out, ty).trim_start_matches("memref<").trim_end_matches('>')
        );
        let mut name = base.clone();
        let mut k = 0;
        while self.globals.names.contains(&name) {
            name = format!("{base}_{k}");
            k += 1;
        }
        let i64t = self.out.int_type(64);
        let align = self.out.int_attr(64, i64t);
        let unit = self.out.unit_attr();
        let sym = self.out.string_attr(&name);
        let vis = self.out.string_attr("private");
        let tyattr = self.out.type_attr(ty);
        // The module's body: the block holding this function.
        let region = self.out.blocks[self.block.index()].parent;
        let func = self.out.regions[region.index()].parent;
        let func_block = func.and_then(|f| self.out.ops[f.index()].parent);
        let g = OpSpec::new("memref.global")
            .prop("alignment", align)
            .prop("constant", unit)
            .prop("initial_value", value)
            .prop("sym_name", sym)
            .prop("sym_visibility", vis)
            .prop("type", tyattr)
            .build(self.out, func_block);
        self.globals.ops.insert(g);
        self.globals.names.insert(name.clone());
        self.globals.by_value.insert((value, ty), name.clone());
        name
    }
}
