//! Loops on buffers to the `llvm` dialect, as upstream's
//! `convert-scf-to-cf`, `lower-affine`, `convert-arith-to-llvm`,
//! `finalize-memref-to-llvm` and `convert-func-to-llvm` do together, with
//! `use-bare-ptr-memref-call-conv`: shapes are static, so a `memref` is
//! just a pointer to its first element, its sizes, strides and offset
//! known from its type.
//!
//! - `func.func` becomes `llvm.func`, each `memref` argument a `!llvm.ptr`;
//!   `index` becomes `i64`.
//! - `scf.for` becomes a header block that compares the induction variable
//!   (a block argument) with the bound, the body, and a branch back with
//!   the next value.
//! - `memref.load` and `memref.store` become an `llvm.getelementptr` at
//!   offset `offset + Σ index × stride`, and `llvm.load` or `llvm.store`.
//! - `memref.alloc` and `memref.dealloc` call `malloc` and `free`;
//!   `memref.global` becomes `llvm.mlir.global` and `memref.get_global`
//!   `llvm.mlir.addressof`; `memref.copy` is `llvm.intr.memcpy` between
//!   packed buffers, and loops otherwise.

use std::collections::HashMap;

use crate::affine::{Expr, Map};
use crate::build::{OpSpec, row_major_strides};
use crate::ir::*;

/// Lowers every function and global in `src` to the `llvm` dialect.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
    for top in src.top_ops().collect::<Vec<_>>() {
        match src.op_name(top) {
            "builtin.module" => {
                let o = &src.ops[top.index()];
                let mut spec = OpSpec::new("builtin.module").regions(1).loc(o.loc);
                for (k, v) in dict(src, o.properties).into_iter().chain(dict(src, o.attrs)) {
                    spec = spec.prop(&k, v);
                }
                let module = spec.build(&mut out, None);
                let region = out.region_of(module, 0);
                let block = out.add_block(region, &[]);
                let mut decls = Decls::default();
                for &r in &o.regions {
                    for &b in &src.regions[r.index()].blocks {
                        for &op in &src.blocks[b.index()].ops {
                            lower_top(src, op, &mut out, Some(block), &mut decls)?;
                        }
                    }
                }
                decls.declare(&mut out, block);
            }
            _ => {
                let mut decls = Decls::default();
                lower_top(src, top, &mut out, None, &mut decls)?;
                decls.declare_top(&mut out);
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

/// The functions the lowered code calls (`malloc`, `free`, `libm`'s), to
/// declare, in order of first use, each with the body of its `!llvm.func`.
#[derive(Default)]
struct Decls {
    used: Vec<(String, String)>,
}

impl Decls {
    fn need(&mut self, name: &str, ty: &str) {
        if !self.used.iter().any(|(n, _)| n == name) {
            self.used.push((name.to_string(), ty.to_string()));
        }
    }

    fn declare(&self, m: &mut Module, block: BlockId) {
        for (name, ty) in &self.used {
            llvm_func(m, Some(block), name, ty);
        }
    }

    fn declare_top(&self, m: &mut Module) {
        for (name, ty) in &self.used {
            llvm_func(m, None, name, ty);
        }
    }
}

/// An `llvm.func` with an empty body, `ty` the body of its `!llvm.func`.
fn llvm_func(m: &mut Module, block: Option<BlockId>, name: &str, ty: &str) -> OpId {
    let fty = m.dialect_type("llvm.func", Some(ty));
    let props = func_props(m, name, fty);
    let mut spec = OpSpec::new("llvm.func").regions(1);
    for (k, v) in props {
        spec = spec.prop(k, v);
    }
    spec.build(m, block)
}

fn func_props(m: &mut Module, name: &str, fty: TypeId) -> Vec<(&'static str, AttrId)> {
    let i64t = m.int_type(64);
    let zero = m.int_attr(0, i64t);
    vec![
        ("CConv", m.dialect_attr("llvm.cconv", Some("<ccc>"))),
        ("function_type", m.type_attr(fty)),
        ("linkage", m.dialect_attr("llvm.linkage", Some("<external>"))),
        ("sym_name", m.string_attr(name)),
        ("unnamed_addr", zero),
        ("visibility_", zero),
    ]
}

fn lower_top(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    decls: &mut Decls,
) -> Result<(), String> {
    match src.op_name(op) {
        "func.func" => lower_func(src, op, out, block, decls),
        "memref.global" => lower_global(src, op, out, block),
        other => Err(format!("{other}: not supported at the top level")),
    }
}

// ---------------------------------------------------------------------------
// Types

/// The `llvm` dialect's name for a scalar type in a function type or an
/// array: `i32`, `f32`, `ptr`.
fn llvm_type_text(m: &Module, ty: TypeId) -> Result<String, String> {
    Ok(match m.ty(m.resolve_type(ty)) {
        Type::Index => "i64".to_string(),
        Type::MemRef { .. } => "ptr".to_string(),
        Type::Dialect { name, body: None } if name == "llvm.ptr" => "ptr".to_string(),
        Type::Int { width, .. } => format!("i{width}"),
        Type::Float(f) => f.to_string(),
        _ => return Err(format!("type {} is not supported", crate::printer::type_text(m, ty))),
    })
}

/// The type a value of `ty` has in the `llvm` dialect.
fn llvm_type(m: &mut Module, ty: TypeId) -> TypeId {
    match m.ty(m.resolve_type(ty)) {
        Type::Index => m.int_type(64),
        Type::MemRef { .. } => m.dialect_type("llvm.ptr", None),
        _ => ty,
    }
}

/// Bytes in an element of type `ty`.
fn elem_bytes(m: &Module, ty: TypeId) -> Result<u64, String> {
    Ok(match m.ty(m.resolve_type(ty)) {
        Type::Int { width, .. } => (*width as u64).div_ceil(8).max(1),
        Type::Index => 8,
        Type::Float(f) => match *f {
            "f64" => 8,
            "f32" | "tf32" => 4,
            "f16" | "bf16" => 2,
            "f80" | "f128" => 16,
            _ => 1,
        },
        _ => return Err(format!("elements of type {} are not supported", crate::printer::type_text(m, ty))),
    })
}

/// A memref's shape, element type, strides and offset, from its type.
#[derive(Clone, Debug)]
struct Layout {
    shape: Vec<u64>,
    elem: TypeId,
    strides: Vec<u64>,
    offset: u64,
}

impl Layout {
    fn of(m: &Module, ty: TypeId) -> Result<Layout, String> {
        let text = || crate::printer::type_text(m, ty);
        let Type::MemRef { shape: Some(shape), elem, extra } = m.ty(m.resolve_type(ty)) else {
            return Err(format!("{} is not a ranked memref", text()));
        };
        let shape: Vec<u64> = shape
            .iter()
            .map(|d| d.ok_or(()))
            .collect::<Result<_, _>>()
            .map_err(|_| format!("{} is not static", text()))?;
        let mut layout = Layout { strides: row_major_strides(&shape), shape, elem: *elem, offset: 0 };
        for &a in extra {
            match m.attr(m.resolve_attr(a)) {
                Attr::Builtin { keyword: "strided", body, .. } => {
                    // `<[49, 49, 7, 1], offset: 8>`
                    let inner = &body[1..body.len() - 1];
                    let (list, rest) = inner.split_once(']').ok_or_else(|| format!("bad layout in {}", text()))?;
                    layout.strides = list
                        .trim_start_matches('[')
                        .split(',')
                        .map(|s| s.trim().parse().map_err(|_| format!("a dynamic stride in {}", text())))
                        .collect::<Result<_, _>>()?;
                    if let Some(off) = rest.split_once("offset:").map(|(_, o)| o.trim()) {
                        layout.offset = off.parse().map_err(|_| format!("a dynamic offset in {}", text()))?;
                    }
                }
                Attr::Int { .. } => {} // A memory space.
                _ => return Err(format!("the layout of {} is not supported", text())),
            }
        }
        Ok(layout)
    }

    fn is_packed(&self) -> bool {
        self.offset == 0 && self.strides == row_major_strides(&self.shape)
    }

    fn numel(&self) -> u64 {
        self.shape.iter().product()
    }
}

// ---------------------------------------------------------------------------
// Globals

fn lower_global(src: &Module, op: OpId, out: &mut Module, block: Option<BlockId>) -> Result<(), String> {
    let get = |k: &str| src.op_attr(op, k);
    let name = get("sym_name").and_then(|a| src.string_of(a)).ok_or("a global without a name")?;
    let ty = match get("type").map(|a| src.attr(a)) {
        Some(Attr::Type(t)) => *t,
        _ => return Err(format!("@{name}: a global without a type")),
    };
    let layout = Layout::of(src, ty)?;
    let mut array = llvm_type_text(src, layout.elem)?;
    for &d in layout.shape.iter().rev() {
        array = format!("array<{d} x {array}>");
    }
    // A zero-dimensional memref holds one element, not an array.
    let global_type = if layout.shape.is_empty() {
        layout.elem
    } else {
        out.dialect_type("llvm.array", Some(&array["array".len()..]))
    };
    let i32t = out.int_type(32);
    let i64t = out.int_type(64);
    let mut spec = OpSpec::new("llvm.mlir.global")
        .prop("addr_space", out.int_attr(0, i32t))
        .prop("global_type", out.type_attr(global_type))
        .prop("linkage", out.dialect_attr("llvm.linkage", Some("<private>")))
        .prop("sym_name", out.string_attr(&name))
        .prop("tls_mode", out.int_attr(0, i64t))
        .prop("unnamed_addr", out.int_attr(0, i64t))
        .prop("visibility_", out.int_attr(0, i64t))
        .regions(1);
    if let Some(a) = get("alignment") {
        spec = spec.prop("alignment", a);
    }
    if get("constant").is_some() {
        spec = spec.prop("constant", out.unit_attr());
    }
    if let Some(v) = get("initial_value") {
        spec = spec.prop("value", v);
    }
    spec.build(out, block);
    Ok(())
}

// ---------------------------------------------------------------------------
// Functions

fn lower_func(
    src: &Module,
    f: OpId,
    out: &mut Module,
    parent: Option<BlockId>,
    decls: &mut Decls,
) -> Result<(), String> {
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let fail = |e: String| format!("@{name}: {e}");
    let (inputs, results) = match src.op_attr(f, "function_type").map(|a| src.attr(a)) {
        Some(Attr::Type(t)) => match src.ty(*t) {
            Type::Function { inputs, results } => (inputs.clone(), results.clone()),
            _ => return Err(fail("function_type is not a function type".into())),
        },
        _ => return Err(fail("no function_type".into())),
    };
    let params: Vec<String> = inputs.iter().map(|&t| llvm_type_text(src, t)).collect::<Result<_, _>>().map_err(fail)?;
    let ret = match results[..] {
        [] => "void".to_string(),
        [r] => llvm_type_text(src, r).map_err(fail)?,
        _ => return Err(fail("several results are not supported".into())),
    };
    let fty = out.dialect_type("llvm.func", Some(&format!("<{ret} ({})>", params.join(", "))));
    let mut spec = OpSpec::new("llvm.func").regions(1).loc(src.ops[f.index()].loc);
    for (k, v) in func_props(out, &name, fty) {
        spec = spec.prop(k, v);
    }
    // Attributes for the llvm.func, as upstream passes them on: `llvm.`
    // and the property's name (`{llvm.no_inline}`).
    for (k, v) in dict(src, src.ops[f.index()].attrs) {
        if let Some(prop) = k.strip_prefix("llvm.") {
            spec = spec.prop(prop, v);
        }
    }
    let func = spec.build(out, parent);
    let o = &src.ops[f.index()];
    let Some(&region) = o.regions.first() else { return Ok(()) };
    let blocks = &src.regions[region.index()].blocks;
    let [body] = blocks[..] else {
        return if blocks.is_empty() {
            Ok(())
        } else {
            Err(fail("a body of more than one block is not supported".into()))
        };
    };
    let arg_types: Vec<TypeId> = inputs.iter().map(|&t| llvm_type(out, t)).collect();
    let new_region = out.region_of(func, 0);
    let entry = out.add_block(new_region, &arg_types);
    let mut l = Lower {
        src,
        out,
        region: new_region,
        block: entry,
        map: HashMap::new(),
        layouts: HashMap::new(),
        ints: HashMap::new(),
        decls,
    };
    for (k, &a) in src.blocks[body.index()].args.iter().enumerate() {
        let n = l.out.blocks[entry.index()].args[k];
        l.map.insert(a, n);
        if matches!(src.ty(src.value_type(a)), Type::MemRef { .. }) {
            let layout = Layout::of(src, src.value_type(a)).map_err(fail)?;
            l.layouts.insert(n, layout);
        }
    }
    for &op in &src.blocks[body.index()].ops {
        l.op(op).map_err(|e| fail(format!("{}: {e}", src.op_name(op))))?;
    }
    Ok(())
}

/// A loop's body, given its induction variable.
type LoopBody<'b, 'a> = dyn FnMut(&mut Lower<'a>, ValueId) -> Result<(), String> + 'b;

/// A loop's body, given its induction variable and the values carried from
/// the iteration before; it gives the values for the next.
type CarryingBody<'b, 'a> = dyn FnMut(&mut Lower<'a>, ValueId, &[ValueId]) -> Result<Vec<ValueId>, String> + 'b;

/// A loop nest's innermost body, given the induction variables.
type NestBody<'b, 'a> = dyn FnMut(&mut Lower<'a>, &[ValueId]) -> Result<(), String> + 'b;

struct Lower<'a> {
    src: &'a Module,
    out: &'a mut Module,
    /// The function's region, which new blocks go at the end of.
    region: RegionId,
    /// Where new operations go.
    block: BlockId,
    map: HashMap<ValueId, ValueId>,
    /// The layout of each pointer that stands for a memref.
    layouts: HashMap<ValueId, Layout>,
    /// The value of each integer constant.
    ints: HashMap<ValueId, i64>,
    decls: &'a mut Decls,
}

impl<'a> Lower<'a> {
    /// For a vector of i1, the vector of i8 a buffer of them holds.
    fn bytes_of_bools(&mut self, ty: TypeId) -> Option<TypeId> {
        let Type::Vector { dims, elem } = self.out.ty(ty).clone() else { return None };
        if !matches!(self.out.ty(elem), Type::Int { width: 1, .. }) {
            return None;
        }
        let i8t = self.out.int_type(8);
        Some(self.out.intern_type(Type::Vector { dims, elem: i8t }))
    }

    fn emit(
        &mut self,
        name: &str,
        operands: &[ValueId],
        results: &[TypeId],
        props: Vec<(&str, AttrId)>,
    ) -> Option<ValueId> {
        let mut spec = OpSpec::new(name).operands(operands).results(results);
        for (k, v) in props {
            spec = spec.prop(k, v);
        }
        let op = spec.build(self.out, Some(self.block));
        self.out.ops[op.index()].results.first().copied()
    }

    fn operand(&self, v: ValueId) -> Result<ValueId, String> {
        self.map.get(&v).copied().ok_or_else(|| "an operand that was not lowered".to_string())
    }

    fn fastmath(&mut self) -> AttrId {
        self.out.dialect_attr("llvm.fastmath", Some("<none>"))
    }

    /// `v` as a value plus a constant, through adds of constants: `None`
    /// for the value when it is a constant itself.
    fn split_constant(&self, v: ValueId) -> (Option<ValueId>, i64) {
        let ValueDef::Result { op, .. } = self.out.values[v.index()].def else { return (Some(v), 0) };
        let as_const = |x: ValueId| -> Option<i64> {
            let ValueDef::Result { op, .. } = self.out.values[x.index()].def else { return None };
            if self.out.op_name(op) != "llvm.mlir.constant" {
                return None;
            }
            self.out.op_attr(op, "value").and_then(|a| self.out.int_of(a))
        };
        if let Some(c) = as_const(v) {
            return (None, c);
        }
        if self.out.op_name(op) == "llvm.add"
            && let [a, b] = self.out.ops[op.index()].operands[..]
        {
            if let Some(c) = as_const(b) {
                let (x, k) = self.split_constant(a);
                return (x, k.wrapping_add(c));
            }
            if let Some(c) = as_const(a) {
                let (x, k) = self.split_constant(b);
                return (x, k.wrapping_add(c));
            }
        }
        (Some(v), 0)
    }

    fn i64_const(&mut self, v: i64) -> ValueId {
        let i64t = self.out.int_type(64);
        let attr = self.out.int_attr(v, i64t);
        self.emit("llvm.mlir.constant", &[], &[i64t], vec![("value", attr)]).unwrap()
    }

    /// An integer operation on `i64`s with no overflow flags.
    fn int_op(&mut self, name: &str, a: ValueId, b: ValueId) -> ValueId {
        let i64t = self.out.int_type(64);
        let i32t = self.out.int_type(32);
        let flags = self.out.int_attr(0, i32t);
        self.emit(name, &[a, b], &[i64t], vec![("overflowFlags", flags)]).unwrap()
    }

    fn call(&mut self, callee: &str, args: &[ValueId], result: Option<TypeId>) -> Option<ValueId> {
        let cconv = self.out.dialect_attr("llvm.cconv", Some("<ccc>"));
        let tail = self.out.dialect_attr("llvm.tailcallkind", Some("<none>"));
        let sym = self.out.symbol_attr(callee);
        let fm = self.fastmath();
        let bundles = self.out.dense_array_attr("i32", &[]);
        let segments = self.out.dense_array_attr("i32", &[args.len() as i64, 0]);
        self.emit(
            "llvm.call",
            args,
            &result.into_iter().collect::<Vec<_>>(),
            vec![
                ("CConv", cconv),
                ("TailCallKind", tail),
                ("callee", sym),
                ("fastmathFlags", fm),
                ("op_bundle_sizes", bundles),
                ("operandSegmentSizes", segments),
            ],
        )
    }

    /// The address of the element at `indices` of the memref `ptr`.
    fn address(&mut self, ptr: ValueId, indices: &[ValueId]) -> Result<ValueId, String> {
        let layout = self.layouts.get(&ptr).cloned().ok_or("a memref of unknown layout")?;
        // The offset: each index times its stride, the constant parts of
        // indices (an unrolled copy's `i + 1`) added up apart and last, so
        // that they become an access's displacement.
        let mut constant = layout.offset as i64;
        let mut off: Option<ValueId> = None;
        for (&i, &s) in indices.iter().zip(&layout.strides) {
            let (i, c) = self.split_constant(i);
            constant = constant.wrapping_add(c.wrapping_mul(s as i64));
            let Some(i) = i else { continue };
            let term = if s == 1 {
                i
            } else {
                let c = self.i64_const(s as i64);
                self.int_op("llvm.mul", i, c)
            };
            off = Some(match off {
                None => term,
                Some(acc) => self.int_op("llvm.add", acc, term),
            });
        }
        let off = match (off, constant) {
            (Some(o), 0) => o,
            (Some(o), c) => {
                let c = self.i64_const(c);
                self.int_op("llvm.add", o, c)
            }
            (None, c) => self.i64_const(c),
        };
        let ptr_ty = self.out.dialect_type("llvm.ptr", None);
        let elem = self.out.type_attr(layout.elem);
        let i32t = self.out.int_type(32);
        let nowrap = self.out.int_attr(0, i32t);
        let raw = self.out.dense_array_attr("i32", &[i32::MIN as i64]);
        Ok(self
            .emit(
                "llvm.getelementptr",
                &[ptr, off],
                &[ptr_ty],
                vec![("elem_type", elem), ("noWrapFlags", nowrap), ("rawConstantIndices", raw)],
            )
            .unwrap())
    }

    /// A vector load's or store's properties: unordered, and aligned only
    /// as its elements are.
    fn access_props(&mut self) -> Vec<(&'static str, AttrId)> {
        let i64t = self.out.int_type(64);
        let ordering = self.out.int_attr(0, i64t);
        let i32t = self.out.int_type(32);
        let align = self.out.int_attr(4, i32t);
        vec![("alignment", align), ("ordering", ordering)]
    }

    fn load(&mut self, ptr: ValueId, indices: &[ValueId]) -> Result<ValueId, String> {
        let elem = self.layouts.get(&ptr).ok_or("a memref of unknown layout")?.elem;
        let p = self.address(ptr, indices)?;
        let i64t = self.out.int_type(64);
        let ordering = self.out.int_attr(0, i64t);
        Ok(self.emit("llvm.load", &[p], &[elem], vec![("ordering", ordering)]).unwrap())
    }

    fn store(&mut self, v: ValueId, ptr: ValueId, indices: &[ValueId]) -> Result<(), String> {
        let p = self.address(ptr, indices)?;
        let i64t = self.out.int_type(64);
        let ordering = self.out.int_attr(0, i64t);
        self.emit("llvm.store", &[v, p], &[], vec![("ordering", ordering)]);
        Ok(())
    }

    /// A loop from `lb` to `ub` by `step`, its body made by `body` with the
    /// induction variable: a header block that tests it, the body, and a
    /// branch back. Afterwards, operations go into the block after it.
    fn for_loop(&mut self, lb: ValueId, ub: ValueId, step: ValueId, body: &mut LoopBody<'_, 'a>) -> Result<(), String> {
        self.carrying_loop(lb, ub, step, &[], &mut |l, iv, _| body(l, iv).map(|()| Vec::new()))?;
        Ok(())
    }

    /// `for_loop`, carrying values from one iteration to the next: they
    /// start as `init`, `body` is given them and gives the next ones, and
    /// the loop gives the last.
    fn carrying_loop(
        &mut self,
        lb: ValueId,
        ub: ValueId,
        step: ValueId,
        init: &[ValueId],
        body: &mut CarryingBody<'_, 'a>,
    ) -> Result<Vec<ValueId>, String> {
        let i64t = self.out.int_type(64);
        let mut types = vec![i64t];
        types.extend(init.iter().map(|&v| self.out.value_type(v)));
        let header = self.out.add_block(self.region, &types);
        let entry = self.out.add_block(self.region, &[]);
        let mut operands = vec![lb];
        operands.extend_from_slice(init);
        OpSpec::new("llvm.br").operands(&operands).successors(&[header]).build(self.out, Some(self.block));
        self.block = header;
        let args = self.out.blocks[header.index()].args.clone();
        let iv = args[0];
        let pred = self.out.int_attr(2, i64t); // slt
        let i1 = self.out.int_type(1);
        let more = self.emit("llvm.icmp", &[iv, ub], &[i1], vec![("predicate", pred)]).unwrap();
        // The block after the loop comes after the body's blocks, made last.
        self.block = entry;
        let next = body(self, iv, &args[1..])?;
        let mut operands = vec![self.int_op("llvm.add", iv, step)];
        operands.extend(next);
        OpSpec::new("llvm.br").operands(&operands).successors(&[header]).build(self.out, Some(self.block));
        let exit = self.out.add_block(self.region, &[]);
        let segments = self.out.dense_array_attr("i32", &[1, 0, 0]);
        OpSpec::new("llvm.cond_br")
            .operands(&[more])
            .successors(&[entry, exit])
            .prop("operandSegmentSizes", segments)
            .build(self.out, Some(header));
        self.block = exit;
        Ok(args[1..].to_vec())
    }

    /// Loops over every index of `shape`, outermost first.
    fn nest(&mut self, shape: &[u64], body: &mut NestBody<'_, 'a>) -> Result<(), String> {
        fn go<'a>(
            l: &mut Lower<'a>,
            shape: &[u64],
            idx: &mut Vec<ValueId>,
            body: &mut NestBody<'_, 'a>,
        ) -> Result<(), String> {
            let Some((&n, rest)) = shape.split_first() else { return body(l, idx) };
            let (lb, ub, step) = (l.i64_const(0), l.i64_const(n as i64), l.i64_const(1));
            l.for_loop(lb, ub, step, &mut |l, iv| {
                idx.push(iv);
                let r = go(l, rest, idx, body);
                idx.pop();
                r
            })
        }
        go(self, shape, &mut Vec::new(), body)
    }

    fn op(&mut self, op: OpId) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let name = src.op_name(op);
        let args: Vec<ValueId> = o.operands.iter().map(|&v| self.operand(v)).collect::<Result<_, _>>()?;
        let result_ty = |l: &mut Self| o.results.first().map(|&r| llvm_type(l.out, src.value_type(r)));
        let new = match name {
            "arith.constant" => {
                let ty = result_ty(self).unwrap();
                let value = src.op_attr(op, "value").ok_or("a constant without a value")?;
                let value = match src.attr(value) {
                    Attr::Int { text, ty: Some(t) } if matches!(src.ty(*t), Type::Index) => {
                        self.out.intern_attr(Attr::Int { text: text.clone(), ty: Some(ty) })
                    }
                    _ => value,
                };
                let c = self.emit("llvm.mlir.constant", &[], &[ty], vec![("value", value)]);
                if let (Some(c), Some(n)) = (c, self.out.int_of(value)) {
                    self.ints.insert(c, n);
                }
                c
            }
            "arith.addf" | "arith.subf" | "arith.mulf" | "arith.divf" | "arith.remf" | "arith.negf" => {
                let llvm = match name {
                    "arith.addf" => "llvm.fadd",
                    "arith.subf" => "llvm.fsub",
                    "arith.mulf" => "llvm.fmul",
                    "arith.divf" => "llvm.fdiv",
                    "arith.remf" => "llvm.frem",
                    _ => "llvm.fneg",
                };
                let ty = result_ty(self).unwrap();
                let fm = self.fastmath();
                self.emit(llvm, &args, &[ty], vec![("fastmathFlags", fm)])
            }
            "arith.addi" | "arith.subi" | "arith.muli" | "arith.shli" => {
                let llvm = match name {
                    "arith.addi" => "llvm.add",
                    "arith.subi" => "llvm.sub",
                    "arith.muli" => "llvm.mul",
                    _ => "llvm.shl",
                };
                let flags = match src.op_attr(op, "overflowFlags").map(|a| src.attr(a)) {
                    Some(Attr::Dialect { body: Some(b), .. }) => {
                        (b.contains("nsw") as i64) | ((b.contains("nuw") as i64) << 1)
                    }
                    _ => 0,
                };
                let ty = result_ty(self).unwrap();
                let i32t = self.out.int_type(32);
                let flags = self.out.int_attr(flags, i32t);
                self.emit(llvm, &args, &[ty], vec![("overflowFlags", flags)])
            }
            "arith.divsi" | "arith.divui" | "arith.remsi" | "arith.remui" | "arith.andi" | "arith.ori"
            | "arith.xori" | "arith.shrsi" | "arith.shrui" => {
                let llvm = match name {
                    "arith.divsi" => "llvm.sdiv",
                    "arith.divui" => "llvm.udiv",
                    "arith.remsi" => "llvm.srem",
                    "arith.remui" => "llvm.urem",
                    "arith.andi" => "llvm.and",
                    "arith.ori" => "llvm.or",
                    "arith.xori" => "llvm.xor",
                    "arith.shrsi" => "llvm.ashr",
                    _ => "llvm.lshr",
                };
                let ty = result_ty(self).unwrap();
                self.emit(llvm, &args, &[ty], vec![])
            }
            "arith.cmpf" | "arith.cmpi" => {
                let pred = src.op_attr(op, "predicate").ok_or("no predicate")?;
                // i1, or a vector of them for vectors.
                let i1 = self.out.int_type(1);
                let i1 = result_ty(self).unwrap_or(i1);
                let mut props = vec![("predicate", pred)];
                let llvm = if name == "arith.cmpf" {
                    props.insert(0, ("fastmathFlags", self.fastmath()));
                    "llvm.fcmp"
                } else {
                    "llvm.icmp"
                };
                self.emit(llvm, &args, &[i1], props)
            }
            "arith.select" => {
                let ty = result_ty(self).unwrap();
                let fm = self.fastmath();
                self.emit("llvm.select", &args, &[ty], vec![("fastmathFlags", fm)])
            }
            "arith.extsi" | "arith.extui" | "arith.trunci" | "arith.sitofp" | "arith.uitofp" | "arith.fptosi"
            | "arith.fptoui" | "arith.extf" | "arith.truncf" => {
                let llvm = match name {
                    "arith.extsi" => "llvm.sext",
                    "arith.extui" => "llvm.zext",
                    "arith.trunci" => "llvm.trunc",
                    "arith.sitofp" => "llvm.sitofp",
                    "arith.uitofp" => "llvm.uitofp",
                    "arith.fptosi" => "llvm.fptosi",
                    "arith.fptoui" => "llvm.fptoui",
                    "arith.extf" => "llvm.fpext",
                    _ => "llvm.fptrunc",
                };
                let ty = result_ty(self).unwrap();
                self.emit(llvm, &args, &[ty], vec![])
            }
            "arith.index_cast" | "arith.index_castui" => {
                let ty = result_ty(self).unwrap();
                let from = self.out.value_type(args[0]);
                let (fw, tw) = (int_width(self.out, from), int_width(self.out, ty));
                if fw == tw {
                    Some(args[0])
                } else if fw > tw {
                    self.emit("llvm.trunc", &args, &[ty], vec![])
                } else {
                    let llvm = if name == "arith.index_cast" { "llvm.sext" } else { "llvm.zext" };
                    self.emit(llvm, &args, &[ty], vec![])
                }
            }
            "affine.apply" => {
                let map = match src.op_attr(op, "map").map(|a| src.attr(src.resolve_attr(a))) {
                    Some(Attr::Builtin { keyword: "affine_map", body, .. }) => Map::parse(&body[1..body.len() - 1])?,
                    _ => return Err("no map".into()),
                };
                if map.syms > 0 || map.results.len() != 1 {
                    return Err("only maps of one result and no symbols are supported".into());
                }
                Some(self.affine(&map.results[0], &args)?)
            }
            "memref.alloc" => {
                let ty = src.value_type(o.results[0]);
                let layout = Layout::of(src, ty)?;
                let bytes = (layout.numel() * elem_bytes(src, layout.elem)?).max(1);
                let n = self.i64_const(bytes as i64);
                self.decls.need("malloc", "<ptr (i64)>");
                let ptr = self.out.dialect_type("llvm.ptr", None);
                let p = self.call("malloc", &[n], Some(ptr)).unwrap();
                self.layouts.insert(p, layout);
                Some(p)
            }
            "memref.dealloc" => {
                self.decls.need("free", "<void (ptr)>");
                self.call("free", &args, None);
                None
            }
            "memref.get_global" => {
                let sym = src.op_attr(op, "name").ok_or("no name")?;
                let ptr = self.out.dialect_type("llvm.ptr", None);
                let p = self.emit("llvm.mlir.addressof", &[], &[ptr], vec![("global_name", sym)]).unwrap();
                self.layouts.insert(p, Layout::of(src, src.value_type(o.results[0]))?);
                Some(p)
            }
            "memref.subview" | "memref.expand_shape" | "memref.collapse_shape" => {
                // The same pointer: a view's offset and strides, from the
                // start of the buffer it is a view of, are in its type.
                let layout = Layout::of(src, src.value_type(o.results[0]))?;
                if !self.layouts.contains_key(&args[0]) {
                    return Err("a view of a memref of unknown layout".into());
                }
                let p = args[0];
                // A second name for the same pointer, with the view's layout.
                let alias = self.alias(p);
                self.layouts.insert(alias, layout);
                Some(alias)
            }
            "memref.load" => Some(self.load(args[0], &args[1..])?),
            "memref.store" => {
                self.store(args[0], args[1], &args[2..])?;
                None
            }
            "memref.copy" => {
                let (from, to) = (args[0], args[1]);
                let lf = self.layouts.get(&from).cloned().ok_or("a copy from a memref of unknown layout")?;
                let lt = self.layouts.get(&to).cloned().ok_or("a copy to a memref of unknown layout")?;
                if lf.shape != lt.shape {
                    return Err("a copy between memrefs of different shapes".into());
                }
                if lf.is_packed() && lt.is_packed() {
                    let len = self.i64_const((lf.numel() * elem_bytes(src, lf.elem)?) as i64);
                    let f = self.out.bool_attr(false);
                    self.emit("llvm.intr.memcpy", &[to, from, len], &[], vec![("isVolatile", f)]);
                } else {
                    self.nest(&lf.shape, &mut |l, idx| {
                        let v = l.load(from, idx)?;
                        l.store(v, to, idx)
                    })?;
                }
                None
            }
            "scf.for" => {
                let body = src.regions[o.regions[0].index()].blocks[0];
                let bargs = src.blocks[body.index()].args.clone();
                let ops = src.blocks[body.index()].ops.clone();
                let results = self.carrying_loop(args[0], args[1], args[2], &args[3..], &mut |l, iv, carried| {
                    l.map.insert(bargs[0], iv);
                    for (&a, &c) in bargs[1..].iter().zip(carried) {
                        l.map.insert(a, c);
                    }
                    for &inner in &ops {
                        if l.src.op_name(inner) == "scf.yield" {
                            return l.src.ops[inner.index()].operands.iter().map(|&v| l.operand(v)).collect();
                        }
                        l.op(inner).map_err(|e| format!("{}: {e}", l.src.op_name(inner)))?;
                    }
                    Ok(Vec::new())
                })?;
                for (&r, &n) in o.results.iter().zip(&results) {
                    self.map.insert(r, n);
                }
                None
            }
            "vector.load" => {
                let ty = result_ty(self).unwrap();
                let p = self.address(args[0], &args[1..])?;
                let props = self.access_props();
                // A buffer of i1 holds a byte each, where a vector of i1 in
                // memory is bits: bytes loaded, then compared with zero.
                match self.bytes_of_bools(ty) {
                    Some(bytes) => {
                        let v = self.emit("llvm.load", &[p], &[bytes], props).unwrap();
                        let zero = self.emit("llvm.mlir.zero", &[], &[bytes], vec![]).unwrap();
                        let i64t = self.out.int_type(64);
                        let ne = self.out.int_attr(1, i64t);
                        self.emit("llvm.icmp", &[v, zero], &[ty], vec![("predicate", ne)])
                    }
                    None => self.emit("llvm.load", &[p], &[ty], props),
                }
            }
            "vector.store" => {
                let p = self.address(args[1], &args[2..])?;
                let props = self.access_props();
                let ty = self.out.value_type(args[0]);
                let value = match self.bytes_of_bools(ty) {
                    Some(bytes) => self.emit("llvm.zext", &[args[0]], &[bytes], vec![]).unwrap(),
                    None => args[0],
                };
                self.emit("llvm.store", &[value, p], &[], props);
                None
            }
            "vector.broadcast" => {
                // Into lane 0 of a vector, then lane 0 everywhere, as a splat
                // is written in LLVM IR.
                let ty = result_ty(self).unwrap();
                let Type::Vector { dims, .. } = self.out.ty(ty).clone() else { return Err("not to a vector".into()) };
                let poison = self.emit("llvm.mlir.poison", &[], &[ty], vec![]).unwrap();
                let zero = self.i64_const(0);
                let one = self.emit("llvm.insertelement", &[poison, args[0], zero], &[ty], vec![]).unwrap();
                let mask = self.out.dense_array_attr("i32", &vec![0; dims[0].0 as usize]);
                self.emit("llvm.shufflevector", &[one, poison], &[ty], vec![("mask", mask)])
            }
            "vector.reduction" => {
                // The lanes combined in pairs: (a + b) + (c + d).
                let ty = result_ty(self).unwrap();
                let Type::Vector { dims, .. } = self.out.ty(self.out.value_type(args[0])).clone() else {
                    return Err("not of a vector".into());
                };
                let kind = match src.op_attr(op, "kind").map(|a| src.attr(a)) {
                    Some(Attr::Dialect { body: Some(b), .. }) => b.trim_matches(|c| c == '<' || c == '>').to_string(),
                    _ => return Err("no kind".into()),
                };
                let combine = match kind.as_str() {
                    "add" => "llvm.fadd",
                    "mul" => "llvm.fmul",
                    "maximumf" => "llvm.intr.maximum",
                    "minimumf" => "llvm.intr.minimum",
                    "maxnumf" => "llvm.intr.maxnum",
                    "minnumf" => "llvm.intr.minnum",
                    _ => return Err(format!("a reduction of kind {kind} is not supported yet")),
                };
                let mut lanes = Vec::new();
                for k in 0..dims[0].0 {
                    let i = self.i64_const(k as i64);
                    lanes.push(self.emit("llvm.extractelement", &[args[0], i], &[ty], vec![]).unwrap());
                }
                while lanes.len() > 1 {
                    let fm = self.fastmath();
                    lanes = lanes
                        .chunks(2)
                        .map(|p| match p {
                            [a, b] => self.emit(combine, &[*a, *b], &[ty], vec![("fastmathFlags", fm)]).unwrap(),
                            [a] => *a,
                            _ => unreachable!(),
                        })
                        .collect();
                }
                Some(lanes[0])
            }
            "arith.bitcast" => {
                let ty = result_ty(self).unwrap();
                self.emit("llvm.bitcast", &args, &[ty], vec![])
            }
            "math.rsqrt" => {
                let ty = result_ty(self).unwrap();
                let fm = self.fastmath();
                let root = self.emit("llvm.intr.sqrt", &args, &[ty], vec![("fastmathFlags", fm)]).unwrap();
                let one = self.out.float_attr("1.000000e+00", ty);
                let one = self.emit("llvm.mlir.constant", &[], &[ty], vec![("value", one)]).unwrap();
                self.emit("llvm.fdiv", &[one, root], &[ty], vec![("fastmathFlags", fm)])
            }
            "math.fpowi" => {
                let ty = result_ty(self).unwrap();
                let fm = self.fastmath();
                match self.ints.get(&args[1]).copied().filter(|n| (0..=16).contains(n)) {
                    // A small constant power: repeated multiplication.
                    Some(n) => {
                        let one = self.out.float_attr("1.000000e+00", ty);
                        let mut r = self.emit("llvm.mlir.constant", &[], &[ty], vec![("value", one)]).unwrap();
                        for _ in 0..n {
                            r = self.emit("llvm.fmul", &[r, args[0]], &[ty], vec![("fastmathFlags", fm)]).unwrap();
                        }
                        Some(r)
                    }
                    None => {
                        let n = self.emit("llvm.sitofp", &[args[1]], &[ty], vec![]).unwrap();
                        self.libm("pow", ty, &[args[0], n])
                    }
                }
            }
            _ if LIBM.contains(&name) => {
                let ty = result_ty(self).unwrap();
                self.libm(&name["math.".len()..], ty, &args)
            }
            "cf.assert" => {
                // A branch to a block that stops the program.
                let ok = self.out.add_block(self.region, &[]);
                let fail = self.out.add_block(self.region, &[]);
                let segments = self.out.dense_array_attr("i32", &[1, 0, 0]);
                OpSpec::new("llvm.cond_br")
                    .operands(&args)
                    .successors(&[ok, fail])
                    .prop("operandSegmentSizes", segments)
                    .build(self.out, Some(self.block));
                self.block = fail;
                self.decls.need("abort", "<void ()>");
                self.call("abort", &[], None);
                self.emit("llvm.unreachable", &[], &[], vec![]);
                self.block = ok;
                None
            }
            // Operations with an LLVM intrinsic of their own.
            _ if intrinsic(name).is_some() => {
                let ty = result_ty(self).unwrap();
                let fm = self.fastmath();
                self.emit(intrinsic(name).unwrap(), &args, &[ty], vec![("fastmathFlags", fm)])
            }
            "func.call" => {
                let callee = src.op_attr(op, "callee").ok_or("no callee")?;
                let name = match src.attr(callee) {
                    Attr::SymbolRef(p) => p[0].clone(),
                    _ => return Err("callee is not a symbol".into()),
                };
                let result = result_ty(self);
                self.call(&name, &args, result)
            }
            "memref.extract_aligned_pointer_as_index" => {
                // The pointer itself: a memref is its aligned pointer here.
                let i64t = self.out.int_type(64);
                self.emit("llvm.ptrtoint", &args, &[i64t], vec![])
            }
            "arith.minsi" | "arith.maxsi" | "arith.minui" | "arith.maxui" => {
                let ty = result_ty(self).unwrap();
                let pred = match name {
                    "arith.minsi" => 2, // slt
                    "arith.maxsi" => 4, // sgt
                    "arith.minui" => 6, // ult
                    _ => 8,             // ugt
                };
                let i64t = self.out.int_type(64);
                let pred = self.out.int_attr(pred, i64t);
                let i1 = self.out.int_type(1);
                let which = self.emit("llvm.icmp", &args, &[i1], vec![("predicate", pred)]).unwrap();
                let fm = self.fastmath();
                self.emit("llvm.select", &[which, args[0], args[1]], &[ty], vec![("fastmathFlags", fm)])
            }
            // Already in the llvm dialect, as a kernel is: as it is, with
            // index values as i64.
            _ if name.starts_with("llvm.") => {
                let results: Vec<TypeId> = o.results.iter().map(|&r| llvm_type(self.out, src.value_type(r))).collect();
                let props = dict(src, o.properties);
                let mut spec = OpSpec::new(name).operands(&args).results(&results);
                for (k, v) in props {
                    spec = spec.prop(&k, v);
                }
                let new = spec.build(self.out, Some(self.block));
                self.out.ops[new.index()].results.first().copied()
            }
            "func.return" => {
                self.emit("llvm.return", &args, &[], vec![]);
                None
            }
            _ => return Err("not supported yet".into()),
        };
        if let (Some(&r), Some(n)) = (o.results.first(), new) {
            self.map.insert(r, n);
        }
        Ok(())
    }

    /// A call to the C library's `name` (`powf` for `f32`), declared.
    fn libm(&mut self, name: &str, ty: TypeId, args: &[ValueId]) -> Option<ValueId> {
        let name = if name == "powf" { "pow" } else { name };
        let (func, t) = match self.out.ty(ty) {
            Type::Float("f32") => (format!("{name}f"), "f32"),
            Type::Float("f64") => (name.to_string(), "f64"),
            _ => return None,
        };
        let params = vec![t; args.len()].join(", ");
        self.decls.need(&func, &format!("<{t} ({params})>"));
        self.call(&func, args, Some(ty))
    }

    /// `p` under another name, so that it can have another layout: a
    /// `getelementptr` of 0 elements.
    fn alias(&mut self, p: ValueId) -> ValueId {
        let zero = self.i64_const(0);
        let ptr_ty = self.out.dialect_type("llvm.ptr", None);
        let i8t = self.out.int_type(8);
        let elem = self.out.type_attr(i8t);
        let i32t = self.out.int_type(32);
        let nowrap = self.out.int_attr(0, i32t);
        let raw = self.out.dense_array_attr("i32", &[i32::MIN as i64]);
        self.emit(
            "llvm.getelementptr",
            &[p, zero],
            &[ptr_ty],
            vec![("elem_type", elem), ("noWrapFlags", nowrap), ("rawConstantIndices", raw)],
        )
        .unwrap()
    }

    /// An affine expression of the operands, as `i64` arithmetic.
    fn affine(&mut self, e: &Expr, dims: &[ValueId]) -> Result<ValueId, String> {
        Ok(match e {
            Expr::Dim(d) => *dims.get(*d).ok_or("a dimension with no operand")?,
            Expr::Const(c) => self.i64_const(*c),
            Expr::Add(a, b) => {
                let (x, y) = (self.affine(a, dims)?, self.affine(b, dims)?);
                self.int_op("llvm.add", x, y)
            }
            Expr::Mul(a, b) => {
                let (x, y) = (self.affine(a, dims)?, self.affine(b, dims)?);
                self.int_op("llvm.mul", x, y)
            }
            _ => return Err(format!("'{e}' in an affine map is not supported yet")),
        })
    }
}

/// `math` operations that call the C library's function of the same name
/// (`expf` for `f32`, `exp` for `f64`), as clang calls them: Epitome's code
/// generator has no instructions for them.
const LIBM: &[&str] = &[
    "math.exp",
    "math.exp2",
    "math.expm1",
    "math.log",
    "math.log2",
    "math.log10",
    "math.log1p",
    "math.sin",
    "math.cos",
    "math.tan",
    "math.tanh",
    "math.atan",
    "math.atan2",
    "math.erf",
    "math.powf",
    "math.cbrt",
];

/// The `llvm.intr` operation that does what `name` does, for the `math`
/// and `arith` operations that have one.
fn intrinsic(name: &str) -> Option<&'static str> {
    Some(match name {
        "arith.maximumf" => "llvm.intr.maximum",
        "arith.minimumf" => "llvm.intr.minimum",
        "arith.maxnumf" => "llvm.intr.maxnum",
        "arith.minnumf" => "llvm.intr.minnum",
        "math.absf" => "llvm.intr.fabs",
        "math.ceil" => "llvm.intr.ceil",
        "math.floor" => "llvm.intr.floor",
        "math.round" => "llvm.intr.round",
        "math.roundeven" => "llvm.intr.roundeven",
        "math.trunc" => "llvm.intr.trunc",
        "math.sqrt" => "llvm.intr.sqrt",
        "math.fma" => "llvm.intr.fma",
        "math.copysign" => "llvm.intr.copysign",
        _ => return None,
    })
}

fn int_width(m: &Module, ty: TypeId) -> u32 {
    match m.ty(ty) {
        Type::Int { width, .. } => *width,
        _ => 64,
    }
}
