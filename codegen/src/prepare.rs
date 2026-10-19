//! Selection form: rewriting a copy of a function so that its IR has the
//! shapes the instruction descriptions' bodies have.
//!
//! - Every `getelementptr` becomes `getelementptr i8, ptr %base, i64 %off`,
//!   with the offset worked out in `i64`: indices sign-extended, scaled by
//!   `shl` for powers of two and `mul` otherwise, constant parts added up.
//! - `switch` becomes a chain of `icmp eq` and conditional branches.
//! - Edges from a block with several successors to a block with phis are
//!   split, so that the phis' copies have somewhere to go.
//! - Calls to intrinsics that do nothing in code (`llvm.lifetime.*`,
//!   `llvm.dbg.*`, `llvm.assume`) are removed.
//! - Comparisons, divisions and right shifts of values narrower than 32
//!   bits are done on 32-bit extensions of them: a narrow value lives in a
//!   W register with its upper bits undefined, so these operations, which
//!   read every bit, need them made right first.
//! - Loads and stores of small structs (`[2 x i64]`) become one per part.
//! - Intrinsics the description has no instruction for are written out:
//!   minimum, maximum and absolute value of narrow integers as a comparison
//!   and a select, and population count as bit arithmetic.
//! - Conversions between floating point and integers narrower than 32
//!   bits go through `i32`; `fcmp one` and `fcmp ueq`, which no single
//!   condition tests after AArch64's `fcmp`, are split into two; a store of
//!   a floating-point constant stores its bits as an integer.
//! - Division and remainder by constants become multiplications and
//!   shifts (see `divconst`).
//! - Integers of other widths below 64 (`i33`, say) are held in the next
//!   register width, with the same rule: masked or sign-extended in place
//!   before an operation that reads their top bits.

use draconian_ir::apint::ApInt;
use draconian_ir::layout::DataLayout;
use draconian_ir::module::*;
use draconian_ir::types::{Type, TypeId};

use crate::target::sext;

pub struct Ctx<'a> {
    pub m: &'a mut Module,
    pub dl: &'a DataLayout,
    /// The machine description, for what it says about the machine as a
    /// whole (its vector registers' width, which shuffles it has).
    pub t: &'a crate::target::Target,
    /// The features of the function being compiled.
    pub features: crate::features::Features,
}

impl Ctx<'_> {
    /// The width of the vector registers, or 0 if there are none (or their
    /// feature is off): then vectors are done lane by lane.
    pub fn vector_bits(&self) -> u32 {
        match &self.t.machine.vector_feature {
            Some(f) if !self.features.contains(f) => 0,
            _ => self.t.machine.vector_bits,
        }
    }

    /// Are instruction `i`'s features on?
    pub fn enabled(&self, i: usize) -> bool {
        self.t.instrs[i].features.iter().all(|f| self.features.contains(f))
    }

    fn i64t(&mut self) -> TypeId {
        self.m.types.int(64)
    }

    fn i8t(&mut self) -> TypeId {
        self.m.types.int(8)
    }

    pub fn int(&mut self, ty: TypeId, v: i64) -> Value {
        let bits = match self.m.types.get(ty) {
            Type::Int(b) => *b,
            _ => 64,
        };
        Value::Const(self.m.consts.intern(Constant { ty, kind: ConstKind::Int(ApInt::from_i64(bits, v)) }))
    }

    pub fn const_int(&self, v: Value) -> Option<i64> {
        let Value::Const(c) = v else { return None };
        let k = self.m.constant(c);
        match (&k.kind, self.m.types.get(k.ty)) {
            (ConstKind::Int(a), Type::Int(b)) => Some(sext(a.low_u64(), *b)),
            _ => None,
        }
    }

    pub fn value_ty(&self, f: &Function, v: Value) -> TypeId {
        match v {
            Value::Local(x) => f.locals[x.index()].ty,
            Value::Const(c) => self.m.constant(c).ty,
            Value::Metadata(_) => unreachable!(),
        }
    }

    pub fn size_of(&self, ty: TypeId) -> Result<u64, String> {
        self.dl.alloc_size(&self.m.types, ty).ok_or_else(|| "a type without a size".to_string())
    }
}

/// Puts a copy of `f` into selection form.
pub fn prepare(cx: &mut Ctx, f: &Function, fname: &str) -> Result<Function, String> {
    let mut f = f.clone();
    check(cx, &f, fname)?;
    drop_noop_calls(cx, &mut f);
    lower_switches(cx, &mut f);
    expand_intrinsics(cx, &mut f);
    split_aggregate_memory(cx, &mut f);
    crate::legalize::legalize_vectors(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    // Element-wise intrinsics split into scalars expand as scalars do.
    expand_intrinsics(cx, &mut f);
    lower_geps(cx, &mut f)?;
    promote_odd(cx, &mut f)?;
    widen_narrow(cx, &mut f);
    legalize_fp(cx, &mut f)?;
    lower_const_divs(cx, &mut f);
    if cx.t.machine.compare_booleans {
        compare_boolean_branches(cx, &mut f);
    }
    split_phi_edges(&mut f);
    Ok(f)
}

/// Rejects what the code generator cannot do yet.
fn check(cx: &Ctx, f: &Function, fname: &str) -> Result<(), String> {
    // Small structs, as clang passes them ([2 x i64]), live as their parts.
    let small_struct = |ty: &Type| match ty {
        Type::Array { len, elem } => *len <= 2 && matches!(cx.m.types.get(*elem), Type::Int(64)),
        Type::Struct { fields, .. } => {
            fields.len() <= 2 && fields.iter().all(|f| matches!(cx.m.types.get(*f), Type::Int(64)))
        }
        _ => false,
    };
    let bad_type = |ty: TypeId| match cx.m.types.get(ty) {
        Type::Int(b) => *b > 64,
        Type::Ptr(a) => *a != 0,
        Type::Void | Type::Label | Type::Double | Type::Float => false,
        // Vectors that do not fit a register are split (see
        // `legalize_vectors`); scalable ones are not supported.
        Type::Vector { scalable: false, elem, .. } => !matches!(
            cx.m.types.get(*elem),
            Type::Int(1 | 8 | 16 | 32 | 64) | Type::Float | Type::Double | Type::Ptr(0)
        ),
        t => !small_struct(t),
    };
    for p in &f.params {
        if bad_type(f.locals[p.local.index()].ty) {
            return Err(format!("@{fname}: parameters of this type are not supported yet"));
        }
    }
    for i in f.insts_in_order() {
        let inst = &f.insts[i.index()];
        if let Some(r) = inst.result
            && bad_type(f.locals[r.index()].ty)
            && !matches!(inst.op, Op::Alloca { .. } | Op::Call(_))
        {
            return Err(format!(
                "@{fname}: values of type {} are not supported yet",
                type_name(cx, f.locals[r.index()].ty)
            ));
        }
        match &inst.op {
            Op::Invoke { .. } | Op::CallBr { .. } | Op::IndirectBr { .. } | Op::LandingPad { .. } | Op::Resume(_) => {
                return Err(format!("@{fname}: exception handling and indirect branches are not supported yet"));
            }
            Op::Alloca { count: Some(c), .. } if cx.const_int(*c).is_none() => {
                return Err(format!("@{fname}: dynamic allocas are not supported yet"));
            }
            Op::AtomicRmw { .. } | Op::CmpXchg { .. } => {
                return Err(format!("@{fname}: atomic read-modify-write is not supported yet"));
            }
            _ => {}
        }
    }
    Ok(())
}

fn type_name(cx: &Ctx, ty: TypeId) -> String {
    format!("{:?}", cx.m.types.get(ty))
}

pub fn callee_name(m: &Module, call: &Call) -> Option<String> {
    let Value::Const(c) = call.callee else { return None };
    match m.constant(c).kind {
        ConstKind::Global(g) => m.global(g).name.clone(),
        _ => None,
    }
}

fn drop_noop_calls(cx: &Ctx, f: &mut Function) {
    let order: Vec<BlockId> = f.layout.clone();
    for b in order {
        let insts = f.blocks[b.index()].insts.clone();
        let keep: Vec<InstId> = insts
            .into_iter()
            .filter(|&i| match &f.insts[i.index()].op {
                Op::Call(call) => !callee_name(cx.m, call).is_some_and(|n| {
                    n.starts_with("llvm.lifetime.")
                        || n.starts_with("llvm.dbg.")
                        || n == "llvm.assume"
                        || n.starts_with("llvm.experimental.noalias")
                }),
                _ => true,
            })
            .collect();
        f.blocks[b.index()].insts = keep;
    }
}

fn lower_switches(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let Some(t) = f.terminator(b) else { continue };
        let Op::Switch { value, default, cases } = f.insts[t.index()].op.clone() else { continue };
        let ty = cx.value_ty(f, value);
        let i1 = cx.m.types.int(1);
        // The block each test is in: `b` for the first, then new ones.
        let mut at = b;
        let mut pos = f.layout.iter().position(|&x| x == b).unwrap() + 1;
        // The phi values `b` sent to each target.
        let phi_value = |f: &Function, target: BlockId, phi: InstId| -> Option<Value> {
            match &f.insts[phi.index()].op {
                Op::Phi { incoming, .. } => incoming.iter().find(|(_, p)| *p == b).map(|(v, _)| *v),
                _ => None,
            }
            .filter(|_| f.blocks[target.index()].insts.contains(&phi))
        };
        let mut edges: Vec<(BlockId, BlockId)> = Vec::new();
        f.blocks[b.index()].insts.pop();
        for (k, (c, target)) in cases.iter().enumerate() {
            let cmp = f.push_inst(
                at,
                Op::ICmp { pred: ICmpPred::Eq, samesign: false, lhs: value, rhs: Value::Const(*c) },
                Some((None, i1)),
            );
            let next = if k + 1 == cases.len() {
                default
            } else {
                let nb = f.add_block(None);
                f.layout.insert(pos, nb);
                pos += 1;
                nb
            };
            f.push_inst(at, Op::CondBr { cond: f.result(cmp), then_dest: *target, else_dest: next }, None);
            edges.push((at, *target));
            if k + 1 == cases.len() {
                edges.push((at, default));
            }
            at = next;
        }
        if cases.is_empty() {
            f.push_inst(b, Op::Br(default), None);
            continue;
        }
        let _ = ty;
        // Phis: one entry for each new edge, in place of `b`'s.
        let mut targets: Vec<BlockId> = edges.iter().map(|e| e.1).collect();
        targets.sort();
        targets.dedup();
        for target in targets {
            let phis: Vec<InstId> = f.blocks[target.index()]
                .insts
                .iter()
                .copied()
                .take_while(|&i| f.insts[i.index()].op.is_phi())
                .collect();
            for phi in phis {
                let Some(v) = phi_value(f, target, phi) else { continue };
                if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op {
                    incoming.retain(|(_, p)| *p != b);
                    for &(from, to) in &edges {
                        if to == target {
                            incoming.push((v, from));
                        }
                    }
                }
            }
        }
    }
}

fn lower_geps(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i64t = cx.i64t();
    let i8t = cx.i8t();
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Gep { ptr, indices, source_ty, .. } = f.insts[i.index()].op.clone() else {
                k += 1;
                continue;
            };
            if indices.len() == 1
                && matches!(cx.m.types.get(source_ty), Type::Int(8))
                && cx.value_ty(f, indices[0]) == i64t
            {
                k += 1;
                continue;
            }
            // Constant part, and (index, scale) for the rest.
            let mut constant: i64 = 0;
            let mut terms: Vec<(Value, i64)> = Vec::new();
            let mut ty = source_ty;
            for (n, &idx) in indices.iter().enumerate() {
                let scale;
                if n == 0 {
                    scale = cx.size_of(ty)? as i64;
                } else {
                    match cx.m.types.get(ty).clone() {
                        Type::Struct { .. } | Type::Named(_) => {
                            let field = cx.const_int(idx).ok_or("a struct index that is not constant")? as u64;
                            let (fields, packed) = struct_fields(cx, ty)?;
                            let layout = cx.dl.struct_layout(&cx.m.types, &fields, packed).ok_or("struct layout")?;
                            constant += layout.offsets[field as usize] as i64;
                            ty = fields[field as usize];
                            continue;
                        }
                        Type::Array { elem, .. } | Type::Vector { elem, .. } => {
                            ty = elem;
                            scale = cx.size_of(elem)? as i64;
                        }
                        other => return Err(format!("getelementptr into {other:?}")),
                    }
                }
                match cx.const_int(idx) {
                    Some(c) => constant = constant.wrapping_add(c.wrapping_mul(scale)),
                    None => terms.push((idx, scale)),
                }
            }
            // Build the offset before the gep.
            let mut new: Vec<InstId> = Vec::new();
            let mut total: Option<Value> = None;
            for (idx, scale) in terms {
                let ity = cx.value_ty(f, idx);
                let mut v = idx;
                if ity != i64t {
                    let c = f.add_inst(
                        Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: v },
                        Some((None, i64t)),
                    );
                    new.push(c);
                    v = f.result(c);
                }
                if scale != 1 {
                    let op = if scale > 0 && (scale & (scale - 1)) == 0 {
                        let sh = cx.int(i64t, scale.trailing_zeros() as i64);
                        Op::Binary { op: BinOp::Shl, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: v, rhs: sh }
                    } else {
                        let s = cx.int(i64t, scale);
                        Op::Binary { op: BinOp::Mul, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: v, rhs: s }
                    };
                    let c = f.add_inst(op, Some((None, i64t)));
                    new.push(c);
                    v = f.result(c);
                }
                total = Some(match total {
                    None => v,
                    Some(t) => {
                        let c = f.add_inst(
                            Op::Binary {
                                op: BinOp::Add,
                                flags: IntFlags::NONE,
                                fmf: FastMath::default(),
                                lhs: t,
                                rhs: v,
                            },
                            Some((None, i64t)),
                        );
                        new.push(c);
                        f.result(c)
                    }
                });
            }
            // A constant offset goes on its own gep, so it can become an
            // addressing-mode offset.
            let mut base = ptr;
            if let Some(t) = total {
                if constant == 0 {
                    f.insts[i.index()].op = gep8(i8t, ptr, t);
                } else {
                    let ptr_ty = f.locals[f.insts[i.index()].result.unwrap().index()].ty;
                    let g = f.add_inst(gep8(i8t, ptr, t), Some((None, ptr_ty)));
                    new.push(g);
                    base = f.result(g);
                    let c = cx.int(i64t, constant);
                    f.insts[i.index()].op = gep8(i8t, base, c);
                }
            } else {
                let c = cx.int(i64t, constant);
                f.insts[i.index()].op = gep8(i8t, base, c);
            }
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

/// The register width an odd-sized integer lives in.
fn container(bits: u32) -> Option<u32> {
    match bits {
        1 | 8 | 16 | 32 | 64 => None,
        b if b < 32 => Some(32),
        b if b < 64 => Some(64),
        _ => None,
    }
}

fn promote_odd(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    // The original width of each value that moves to a wider type.
    let mut orig: std::collections::HashMap<LocalId, u32> = std::collections::HashMap::new();
    for (k, l) in f.locals.iter_mut().enumerate() {
        if let Type::Int(b) = *cx.m.types.get(l.ty)
            && let Some(c) = container(b)
        {
            orig.insert(LocalId(k as u32), b);
            l.ty = cx.m.types.int(c);
        }
    }
    if orig.is_empty() {
        return Ok(());
    }
    let bits_of = |cx: &Ctx, f: &Function, orig: &std::collections::HashMap<LocalId, u32>, v: Value| -> u32 {
        match v {
            Value::Local(x) => orig.get(&x).copied().unwrap_or_else(|| match cx.m.types.get(f.locals[x.index()].ty) {
                Type::Int(b) => *b,
                _ => 64,
            }),
            Value::Const(c) => match cx.m.types.get(cx.m.constant(c).ty) {
                Type::Int(b) => *b,
                _ => 64,
            },
            _ => 64,
        }
    };
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let mut new: Vec<InstId> = Vec::new();
            // Constants of odd widths become constants of the wider type.
            let mut op = f.insts[i.index()].op.clone();
            op.for_each_value_mut(|v| {
                if let Value::Const(c) = *v
                    && let Type::Int(bits) = *cx.m.types.get(cx.m.constant(c).ty)
                    && let Some(w) = container(bits)
                    && let Some(n) = cx.const_int(*v)
                {
                    let t = cx.m.types.int(w);
                    *v = cx.int(t, n);
                }
            });
            // Operations that read the top bits get their operands made
            // right: masked for unsigned readings, sign-extended for signed.
            let mut fix = |cx: &mut Ctx, f: &mut Function, v: Value, bits: u32, signed: bool| -> Value {
                let Some(w) = container(bits) else { return v };
                let t = cx.m.types.int(w);
                let nf = IntFlags::NONE;
                let fm = FastMath::default();
                if signed {
                    let sh = cx.int(t, (w - bits) as i64);
                    let a =
                        f.add_inst(Op::Binary { op: BinOp::Shl, flags: nf, fmf: fm, lhs: v, rhs: sh }, Some((None, t)));
                    let r = f.add_inst(
                        Op::Binary { op: BinOp::AShr, flags: nf, fmf: fm, lhs: f.result(a), rhs: sh },
                        Some((None, t)),
                    );
                    new.push(a);
                    new.push(r);
                    f.result(r)
                } else {
                    let mask = cx.int(t, ((1u64 << bits) - 1) as i64);
                    let a = f.add_inst(
                        Op::Binary { op: BinOp::And, flags: nf, fmf: fm, lhs: v, rhs: mask },
                        Some((None, t)),
                    );
                    new.push(a);
                    f.result(a)
                }
            };
            let res = f.insts[i.index()].result;
            let res_odd = res.and_then(|r| orig.get(&r).copied());
            if matches!(op, Op::Load { .. } | Op::Store { .. }) {
                let mut odd = res_odd.is_some();
                op.for_each_value(|v| odd |= container(bits_of(cx, f, &orig, *v)).is_some());
                if odd {
                    return Err("loads and stores of odd-sized integers are not supported yet".into());
                }
            }
            match &mut op {
                Op::Binary { op: bop, flags, lhs, rhs, .. } => {
                    let bits = bits_of(cx, f, &orig, *lhs);
                    if container(bits).is_some() {
                        *flags = IntFlags::NONE;
                        match bop {
                            BinOp::LShr | BinOp::UDiv | BinOp::URem => {
                                *lhs = fix(cx, f, *lhs, bits, false);
                                *rhs = fix(cx, f, *rhs, bits, false);
                            }
                            BinOp::AShr => {
                                *lhs = fix(cx, f, *lhs, bits, true);
                                *rhs = fix(cx, f, *rhs, bits, false);
                            }
                            BinOp::SDiv | BinOp::SRem => {
                                *lhs = fix(cx, f, *lhs, bits, true);
                                *rhs = fix(cx, f, *rhs, bits, true);
                            }
                            _ => {}
                        }
                    }
                }
                Op::ICmp { pred, lhs, rhs, .. } => {
                    let bits = bits_of(cx, f, &orig, *lhs);
                    let signed = matches!(pred, ICmpPred::Sgt | ICmpPred::Sge | ICmpPred::Slt | ICmpPred::Sle);
                    *lhs = fix(cx, f, *lhs, bits, signed);
                    *rhs = fix(cx, f, *rhs, bits, signed);
                }
                Op::Cast { op: cop, flags, value, .. } => {
                    let from = bits_of(cx, f, &orig, *value);
                    let to_ty = f.locals[res.unwrap().index()].ty;
                    let to = match cx.m.types.get(to_ty) {
                        Type::Int(b) => *b,
                        _ => 64,
                    };
                    let from_odd = container(from).is_some();
                    if from_odd || res_odd.is_some() {
                        *flags = IntFlags::NONE;
                        if from_odd && matches!(cop, CastOp::ZExt | CastOp::SExt) {
                            *value = fix(cx, f, *value, from, *cop == CastOp::SExt);
                        }
                        // Between equal register widths, the cast is free.
                        let from_w = container(from).unwrap_or(from);
                        if from_w == to {
                            *cop = CastOp::BitCast;
                        }
                    }
                }
                _ => {}
            }
            // A bitcast between integers is the identity; use freeze, which
            // is a plain copy, as the selector treats bitcasts of pointers.
            if let Op::Cast { op: CastOp::BitCast, value, .. } = op {
                op = Op::Freeze(value);
            }
            f.insts[i.index()].op = op;
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

fn split_aggregate_memory(cx: &mut Ctx, f: &mut Function) {
    let i64t = cx.m.types.int(64);
    let i8t = cx.m.types.int(8);
    let parts_of = |cx: &Ctx, ty: TypeId| -> Option<u32> {
        match cx.m.types.get(ty) {
            Type::Array { len, elem } if *len <= 2 && matches!(cx.m.types.get(*elem), Type::Int(64)) => {
                Some(*len as u32)
            }
            Type::Struct { fields, .. }
                if fields.len() <= 2 && fields.iter().all(|t| matches!(cx.m.types.get(*t), Type::Int(64))) =>
            {
                Some(fields.len() as u32)
            }
            _ => None,
        }
    };
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let mut s = Seq { f, new: Vec::new() };
            let done = match s.f.insts[i.index()].op.clone() {
                Op::Store { value, ptr, volatile: false, atomic: None, .. } => {
                    let ty = cx.value_ty(s.f, value);
                    match parts_of(cx, ty) {
                        Some(n) => {
                            let ptr_ty = cx.m.types.ptr(0);
                            for part in 0..n {
                                let e = s.op(Op::ExtractValue { aggregate: value, indices: vec![part] }, i64t);
                                let off = cx.int(i64t, 8 * part as i64);
                                let p = s.op(gep8(i8t, ptr, off), ptr_ty);
                                let st = s.f.add_inst(
                                    Op::Store { volatile: false, atomic: None, value: e, ptr: p, align: Some(8) },
                                    None,
                                );
                                s.new.push(st);
                            }
                            true
                        }
                        None => false,
                    }
                }
                Op::Load { ptr, volatile: false, atomic: None, .. } => {
                    let r = s.f.insts[i.index()].result.unwrap();
                    let ty = s.f.locals[r.index()].ty;
                    match parts_of(cx, ty) {
                        Some(n) => {
                            let ptr_ty = cx.m.types.ptr(0);
                            let mut agg = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }));
                            for part in 0..n {
                                let off = cx.int(i64t, 8 * part as i64);
                                let p = s.op(gep8(i8t, ptr, off), ptr_ty);
                                let v = s.op(Op::Load { volatile: false, atomic: None, ptr: p, align: Some(8) }, i64t);
                                agg = s.op(Op::InsertValue { aggregate: agg, element: v, indices: vec![part] }, ty);
                            }
                            s.f.replace_uses(Value::Local(r), agg);
                            true
                        }
                        None => false,
                    }
                }
                _ => false,
            };
            let new = std::mem::take(&mut s.new);
            if done {
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
            } else {
                k += 1;
            }
        }
    }
}

fn expand_intrinsics(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Call(call) = &f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let Some(name) = callee_name(cx.m, call) else {
                k += 1;
                continue;
            };
            let args: Vec<Value> = call.args.iter().map(|a| a.value).collect();
            let Some(r) = f.insts[i.index()].result else {
                k += 1;
                continue;
            };
            let ty = f.locals[r.index()].ty;
            // Scalars only: vector intrinsics have instructions.
            let bits = match cx.m.types.get(ty) {
                Type::Int(b) => *b,
                _ => 64,
            };
            let scalar = matches!(cx.m.types.get(ty), Type::Int(_));
            let i1 = cx.m.types.int(1);
            let mut s = Seq { f, new: Vec::new() };
            let base = name.split('.').take(2).collect::<Vec<_>>().join(".");
            let minmax = match base.as_str() {
                "llvm.smax" => Some(ICmpPred::Sgt),
                "llvm.smin" => Some(ICmpPred::Slt),
                "llvm.umax" => Some(ICmpPred::Ugt),
                "llvm.umin" => Some(ICmpPred::Ult),
                _ => None,
            };
            // An ordered floating-point reduction: the start value, then
            // each lane added (or multiplied) in order, as written.
            if (name.starts_with("llvm.vector.reduce.fadd.") || name.starts_with("llvm.vector.reduce.fmul."))
                && let Type::Vector { len, elem, .. } = cx.m.types.get(cx.value_ty(s.f, args[1])).clone()
            {
                let i64t = cx.m.types.int(64);
                let op = if name.contains(".fadd.") { BinOp::FAdd } else { BinOp::FMul };
                let mut acc = args[0];
                for lane in 0..len {
                    let idx = cx.int(i64t, lane as i64);
                    let e = s.op(Op::ExtractElement { vector: args[1], index: idx }, elem);
                    acc =
                        s.op(Op::Binary { op, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: acc, rhs: e }, ty);
                }
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), acc);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // A funnel shift by a constant, of vectors or (where the
            // description has no instruction for it) of scalars: two shifts
            // and an or.
            let vector = matches!(cx.m.types.get(ty), Type::Vector { .. });
            if (base == "llvm.fshl" || base == "llvm.fshr")
                && (vector || !cx.t.intrinsics.contains(&name))
                && let Some(c) = crate::target::lit_of(
                    cx.m,
                    match args[2] {
                        Value::Const(c) => c,
                        _ => ConstId(u32::MAX),
                    },
                )
                .filter(|_| matches!(args[2], Value::Const(_)))
            {
                let elem = match cx.m.types.get(ty).clone() {
                    Type::Vector { elem, .. } => elem,
                    _ => ty,
                };
                let eb = match cx.m.types.get(elem) {
                    Type::Int(b) => *b as i64,
                    _ => 64,
                };
                let amt = c.0.rem_euclid(eb);
                let amount = |cx: &mut Ctx, v: i64| -> Value {
                    let e = cx.int(elem, v);
                    if !vector {
                        return e;
                    }
                    let Value::Const(e) = e else { unreachable!() };
                    Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Splat(e) }))
                };
                // fshl(a, b, c) is (a << c) | (b >> (w - c)); fshr(a, b, c) is
                // fshl(a, b, w - c).
                let amt = if base == "llvm.fshr" { (eb - amt) % eb } else { amt };
                let value = if amt == 0 {
                    if base == "llvm.fshr" { args[1] } else { args[0] }
                } else {
                    let (a, b) = (amount(cx, amt), amount(cx, eb - amt));
                    let hi = s.bin(BinOp::Shl, args[0], a, ty);
                    let lo = s.bin(BinOp::LShr, args[1], b, ty);
                    s.bin(BinOp::Or, hi, lo, ty)
                };
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), value);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // ctlz and cttz may say a zero input gives poison; giving the
            // full width instead is always allowed, and is what clz does.
            if (base == "llvm.ctlz" || base == "llvm.cttz") && args.len() == 2 {
                let no = cx.int(i1, 0);
                if let Op::Call(c) = &mut s.f.insts[i.index()].op {
                    c.args[1].value = no;
                }
            }
            let value = match (minmax, base.as_str()) {
                // Narrow minimum and maximum: compare and select.
                (Some(pred), _) if scalar && bits < 32 => {
                    let c = s.op(Op::ICmp { pred, samesign: false, lhs: args[0], rhs: args[1] }, i1);
                    Some(s.op(
                        Op::Select { fmf: FastMath::default(), cond: c, then_value: args[0], else_value: args[1] },
                        ty,
                    ))
                }
                // The size of the object a pointer points into, when it is
                // not known here: "unknown" is -1, or 0 if a lower bound
                // is asked for. (An optimiser folds the known cases.)
                (_, "llvm.objectsize") => {
                    let min = cx.const_int(args[1]).unwrap_or(0) != 0;
                    Some(cx.int(ty, if min { 0 } else { -1 }))
                }
                // Saturating subtraction: a > b ? a - b : 0.
                (_, "llvm.usub") if scalar && name.starts_with("llvm.usub.sat") => {
                    let zero = cx.int(ty, 0);
                    let diff = s.bin(BinOp::Sub, args[0], args[1], ty);
                    let c = s.op(Op::ICmp { pred: ICmpPred::Ugt, samesign: false, lhs: args[0], rhs: args[1] }, i1);
                    Some(s.op(Op::Select { fmf: FastMath::default(), cond: c, then_value: diff, else_value: zero }, ty))
                }
                // Vector abs keeps its call, for the abs instruction; its
                // flag (poison for the most negative value) may be dropped.
                (_, "llvm.abs")
                    if cx.value_ty(s.f, args[0]) != ty || matches!(cx.m.types.get(ty), Type::Vector { .. }) =>
                {
                    let no = cx.int(i1, 0);
                    if let Op::Call(c) = &mut s.f.insts[i.index()].op {
                        c.args[1].value = no;
                    }
                    None
                }
                (_, "llvm.abs") => {
                    let zero = cx.int(ty, 0);
                    let neg = s.bin(BinOp::Sub, zero, args[0], ty);
                    let c = s.op(Op::ICmp { pred: ICmpPred::Slt, samesign: false, lhs: args[0], rhs: zero }, i1);
                    Some(
                        s.op(
                            Op::Select { fmf: FastMath::default(), cond: c, then_value: neg, else_value: args[0] },
                            ty,
                        ),
                    )
                }
                // Population count: sums of bits in pairs, nibbles and
                // bytes, then a multiply to add the bytes up.
                (_, "llvm.ctpop") if scalar => {
                    let w = if bits <= 32 { 32 } else { 64 };
                    let wt = cx.m.types.int(w);
                    let mut x = if bits < w { s.cast(CastOp::ZExt, args[0], wt) } else { args[0] };
                    let rep = |byte: u64| -> i64 { (0..w / 8).fold(0u64, |acc, k| acc | (byte << (8 * k))) as i64 };
                    let c = |cx: &mut Ctx, v: i64| cx.int(wt, v);
                    let one = c(cx, 1);
                    let half = s.bin(BinOp::LShr, x, one, wt);
                    let m1 = c(cx, rep(0x55));
                    let half = s.bin(BinOp::And, half, m1, wt);
                    x = s.bin(BinOp::Sub, x, half, wt);
                    let m2 = c(cx, rep(0x33));
                    let lo = s.bin(BinOp::And, x, m2, wt);
                    let two = c(cx, 2);
                    let hi = s.bin(BinOp::LShr, x, two, wt);
                    let hi = s.bin(BinOp::And, hi, m2, wt);
                    x = s.bin(BinOp::Add, lo, hi, wt);
                    let four = c(cx, 4);
                    let sh = s.bin(BinOp::LShr, x, four, wt);
                    x = s.bin(BinOp::Add, x, sh, wt);
                    let m4 = c(cx, rep(0x0f));
                    x = s.bin(BinOp::And, x, m4, wt);
                    let ones = c(cx, rep(0x01));
                    x = s.bin(BinOp::Mul, x, ones, wt);
                    let top = c(cx, w as i64 - 8);
                    x = s.bin(BinOp::LShr, x, top, wt);
                    Some(if bits < w { s.cast(CastOp::Trunc, x, ty) } else { x })
                }
                _ => None,
            };
            let new = std::mem::take(&mut s.new);
            match value {
                Some(v) => {
                    f.replace_uses(Value::Local(r), v);
                    let n = new.len();
                    f.blocks[b.index()].insts.splice(k..=k, new);
                    k += n;
                }
                None => k += 1,
            }
        }
    }
}

/// Builds instructions to go before another, of one integer type.
struct Seq<'f> {
    f: &'f mut Function,
    new: Vec<InstId>,
}

impl Seq<'_> {
    fn op(&mut self, op: Op, ty: TypeId) -> Value {
        let i = self.f.add_inst(op, Some((None, ty)));
        self.new.push(i);
        self.f.result(i)
    }

    fn bin(&mut self, op: BinOp, lhs: Value, rhs: Value, ty: TypeId) -> Value {
        self.op(Op::Binary { op, flags: IntFlags::NONE, fmf: FastMath::default(), lhs, rhs }, ty)
    }

    fn cast(&mut self, op: CastOp, value: Value, ty: TypeId) -> Value {
        self.op(Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value }, ty)
    }
}

/// The high half of `x * m` at `w` bits, then shifted right by `extra`:
/// the product of the operands extended to `2w` bits.
fn mul_high(cx: &mut Ctx, s: &mut Seq, x: Value, m: i64, w: u32, signed: bool, extra: u32) -> Value {
    let ty = cx.m.types.int(w);
    let wide = cx.m.types.int(2 * w);
    let ext = if signed { CastOp::SExt } else { CastOp::ZExt };
    let mc = cx.int(ty, m);
    let a = s.cast(ext, x, wide);
    let b = s.cast(ext, mc, wide);
    let p = s.bin(BinOp::Mul, a, b, wide);
    // At 32 bits, any further shift joins this one; at 64, smulh and
    // umulh take the high half as it is.
    let (shift, rest) = if w == 32 { (32 + extra, 0) } else { (64, extra) };
    let sh = cx.int(wide, shift as i64);
    let op = if signed && w == 32 { BinOp::AShr } else { BinOp::LShr };
    let h = s.bin(op, p, sh, wide);
    let hi = s.cast(CastOp::Trunc, h, ty);
    if rest > 0 {
        let k = cx.int(ty, rest as i64);
        return s.bin(if signed { BinOp::AShr } else { BinOp::LShr }, hi, k, ty);
    }
    hi
}

fn lower_const_divs(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Binary { op, lhs: x, rhs, .. } = f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let signed = matches!(op, BinOp::SDiv | BinOp::SRem);
            let rem = matches!(op, BinOp::SRem | BinOp::URem);
            let (Some(d), Type::Int(w)) = (cx.const_int(rhs), cx.m.types.get(cx.value_ty(f, x)).clone()) else {
                k += 1;
                continue;
            };
            if !matches!(op, BinOp::SDiv | BinOp::SRem | BinOp::UDiv | BinOp::URem) || !(w == 32 || w == 64) || d == 0 {
                k += 1;
                continue;
            }
            let ty = cx.m.types.int(w);
            let mask: u64 = if w == 64 { u64::MAX } else { (1u64 << w) - 1 };
            let mut s = Seq { f, new: Vec::new() };
            let zero = cx.int(ty, 0);
            let c = |cx: &mut Ctx, v: i64| cx.int(ty, v);
            let result = if signed {
                let ad = d.unsigned_abs() & mask;
                if d == 1 || d == -1 {
                    let q = if d == 1 { x } else { s.bin(BinOp::Sub, zero, x, ty) };
                    if rem { zero } else { q }
                } else if ad.is_power_of_two() {
                    // Round towards zero: add 2^k - 1 to negative values.
                    let kk = ad.trailing_zeros() as i64;
                    let sign = s.bin(BinOp::AShr, x, c(cx, w as i64 - 1), ty);
                    let bias = s.bin(BinOp::LShr, sign, c(cx, w as i64 - kk), ty);
                    let t = s.bin(BinOp::Add, x, bias, ty);
                    if rem {
                        let low = s.bin(BinOp::And, t, c(cx, -(ad as i64)), ty);
                        s.bin(BinOp::Sub, x, low, ty)
                    } else {
                        let q = s.bin(BinOp::AShr, t, c(cx, kk), ty);
                        if d < 0 { s.bin(BinOp::Sub, zero, q, ty) } else { q }
                    }
                } else {
                    let (m, sh) = crate::divconst::magic_signed(d, w);
                    let needs_fix = (d > 0 && m < 0) || (d < 0 && m > 0);
                    let mut q = mul_high(cx, &mut s, x, m, w, true, if needs_fix { 0 } else { sh });
                    if needs_fix {
                        q = s.bin(if d > 0 { BinOp::Add } else { BinOp::Sub }, q, x, ty);
                        if sh > 0 {
                            q = s.bin(BinOp::AShr, q, c(cx, sh as i64), ty);
                        }
                    }
                    let sign = s.bin(BinOp::LShr, q, c(cx, w as i64 - 1), ty);
                    let q = s.bin(BinOp::Add, q, sign, ty);
                    if rem {
                        let p = s.bin(BinOp::Mul, q, c(cx, d), ty);
                        s.bin(BinOp::Sub, x, p, ty)
                    } else {
                        q
                    }
                }
            } else {
                let du = (d as u64) & mask;
                if du == 1 {
                    if rem { zero } else { x }
                } else if du.is_power_of_two() {
                    if rem {
                        s.bin(BinOp::And, x, c(cx, (du - 1) as i64), ty)
                    } else {
                        s.bin(BinOp::LShr, x, c(cx, du.trailing_zeros() as i64), ty)
                    }
                } else {
                    let q = if du > mask / 2 {
                        // Only 0 or 1 fits.
                        let i1 = cx.m.types.int(1);
                        let ge = s.op(Op::ICmp { pred: ICmpPred::Uge, samesign: false, lhs: x, rhs: c(cx, d) }, i1);
                        s.cast(CastOp::ZExt, ge, ty)
                    } else {
                        let (m, add, sh) = crate::divconst::magic_unsigned(du, w);
                        if add {
                            let t = mul_high(cx, &mut s, x, m as i64, w, false, 0);
                            let diff = s.bin(BinOp::Sub, x, t, ty);
                            let half = s.bin(BinOp::LShr, diff, c(cx, 1), ty);
                            let sum = s.bin(BinOp::Add, half, t, ty);
                            s.bin(BinOp::LShr, sum, c(cx, sh as i64 - 1), ty)
                        } else {
                            mul_high(cx, &mut s, x, m as i64, w, false, sh)
                        }
                    };
                    if rem {
                        let p = s.bin(BinOp::Mul, q, c(cx, d), ty);
                        s.bin(BinOp::Sub, x, p, ty)
                    } else {
                        q
                    }
                }
            };
            let new = std::mem::take(&mut s.new);
            let res = f.insts[i.index()].result.unwrap();
            f.replace_uses(Value::Local(res), result);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

fn legalize_fp(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i32t = cx.m.types.int(32);
    let i1 = cx.m.types.int(1);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let res = f.insts[i.index()].result;
            let mut s = Seq { f, new: Vec::new() };
            // Scalars only: vectors have their own conversions.
            let bits_of = |cx: &Ctx, ty: TypeId| match cx.m.types.get(ty) {
                Type::Int(b) => *b,
                _ => 64,
            };
            let mut replace: Option<Value> = None;
            match s.f.insts[i.index()].op.clone() {
                Op::Cast { op: op @ (CastOp::SIToFP | CastOp::UIToFP), value, .. } => {
                    let from = bits_of(cx, cx.value_ty(s.f, value));
                    if from < 32 {
                        let ext = if op == CastOp::SIToFP { CastOp::SExt } else { CastOp::ZExt };
                        let w = s.cast(ext, value, i32t);
                        if let Op::Cast { value, .. } = &mut s.f.insts[i.index()].op {
                            *value = w;
                        }
                    }
                }
                Op::Cast { op: op @ (CastOp::FPToSI | CastOp::FPToUI), value, .. } => {
                    let r = res.unwrap();
                    let to_ty = s.f.locals[r.index()].ty;
                    if bits_of(cx, to_ty) < 32 {
                        // Convert to 32 bits, then take the low bits.
                        let w = s.op(Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value }, i32t);
                        replace = Some(s.cast(CastOp::Trunc, w, to_ty));
                    }
                }
                Op::FCmp {
                    pred: pred @ (FCmpPred::One | FCmpPred::Ueq | FCmpPred::True | FCmpPred::False),
                    lhs,
                    rhs,
                    fmf,
                } => {
                    replace = Some(match pred {
                        FCmpPred::True => cx.int(i1, 1),
                        FCmpPred::False => cx.int(i1, 0),
                        _ => {
                            // one: ordered and not equal; ueq: unordered or equal.
                            let (a, b, op) = if pred == FCmpPred::One {
                                (FCmpPred::Ord, FCmpPred::Une, BinOp::And)
                            } else {
                                (FCmpPred::Uno, FCmpPred::Oeq, BinOp::Or)
                            };
                            let x = s.op(Op::FCmp { pred: a, fmf, lhs, rhs }, i1);
                            let y = s.op(Op::FCmp { pred: b, fmf, lhs, rhs }, i1);
                            s.bin(op, x, y, i1)
                        }
                    });
                }
                Op::Store { value: Value::Const(c), ptr, volatile, atomic, align } => {
                    let k = cx.m.constant(c);
                    if let ConstKind::Float(raw) = k.kind {
                        let bits = match cx.m.types.get(k.ty) {
                            Type::Double => 64,
                            Type::Float => 32,
                            _ => 0,
                        };
                        if bits > 0 {
                            let ity = cx.m.types.int(bits);
                            let v = cx.int(ity, crate::target::sext(raw as u64, bits));
                            s.f.insts[i.index()].op = Op::Store { value: v, ptr, volatile, atomic, align };
                        }
                    }
                }
                Op::Binary { op: BinOp::FRem, .. } => return Err("frem is not supported yet".into()),
                _ => {}
            }
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            match replace {
                Some(v) => {
                    f.replace_uses(Value::Local(res.unwrap()), v);
                    f.blocks[b.index()].insts.splice(k..=k, new);
                    k += n;
                }
                None => {
                    f.blocks[b.index()].insts.splice(k..k, new);
                    k += n + 1;
                }
            }
        }
    }
    Ok(())
}

fn widen_narrow(cx: &mut Ctx, f: &mut Function) {
    let i32t = cx.m.types.int(32);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let (signed, lhs, rhs) = match f.insts[i.index()].op {
                Op::ICmp { pred, lhs, rhs, .. } => {
                    (matches!(pred, ICmpPred::Sgt | ICmpPred::Sge | ICmpPred::Slt | ICmpPred::Sle), lhs, rhs)
                }
                Op::Binary { op: BinOp::SDiv | BinOp::SRem | BinOp::AShr, lhs, rhs, .. } => (true, lhs, rhs),
                Op::Binary { op: BinOp::UDiv | BinOp::URem | BinOp::LShr, lhs, rhs, .. } => (false, lhs, rhs),
                _ => {
                    k += 1;
                    continue;
                }
            };
            let bits = match cx.m.types.get(cx.value_ty(f, lhs)) {
                Type::Int(b) if *b < 32 => *b,
                _ => {
                    k += 1;
                    continue;
                }
            };
            let mut new = Vec::new();
            let mut widen = |cx: &mut Ctx, f: &mut Function, v: Value| -> Value {
                if let Some(c) = cx.const_int(v) {
                    let raw = c as u64 & ((1u64 << bits) - 1);
                    return cx.int(i32t, if signed { sext(raw, bits) } else { raw as i64 });
                }
                let op = if signed { CastOp::SExt } else { CastOp::ZExt };
                let c = f.add_inst(
                    Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value: v },
                    Some((None, i32t)),
                );
                new.push(c);
                f.result(c)
            };
            let (l, r) = (widen(cx, f, lhs), widen(cx, f, rhs));
            let narrow_result = !matches!(f.insts[i.index()].op, Op::ICmp { .. });
            match &mut f.insts[i.index()].op {
                Op::ICmp { lhs, rhs, .. } | Op::Binary { lhs, rhs, .. } => {
                    *lhs = l;
                    *rhs = r;
                }
                _ => unreachable!(),
            }
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n;
            if narrow_result {
                // The operation is now 32 bits wide; its users still see
                // the narrow type through a truncation.
                let res = f.insts[i.index()].result.unwrap();
                let narrow_ty = f.locals[res.index()].ty;
                f.locals[res.index()].ty = i32t;
                let t = f.add_inst(
                    Op::Cast {
                        op: CastOp::Trunc,
                        flags: IntFlags::NONE,
                        fmf: FastMath::default(),
                        value: Value::Local(res),
                    },
                    Some((None, narrow_ty)),
                );
                let tv = f.result(t);
                f.replace_uses(Value::Local(res), tv);
                // Undo the replacement in the truncation itself.
                f.insts[t.index()].op = Op::Cast {
                    op: CastOp::Trunc,
                    flags: IntFlags::NONE,
                    fmf: FastMath::default(),
                    value: Value::Local(res),
                };
                f.blocks[b.index()].insts.insert(k + 1, t);
                k += 1;
            }
            k += 1;
        }
    }
}

fn gep8(i8t: TypeId, ptr: Value, off: Value) -> Op {
    Op::Gep { flags: GepFlags::default(), inrange: None, source_ty: i8t, ptr, indices: vec![off] }
}

pub fn struct_fields(cx: &Ctx, ty: TypeId) -> Result<(Vec<TypeId>, bool), String> {
    match cx.m.types.get(ty) {
        Type::Struct { packed, fields } => Ok((fields.clone(), *packed)),
        Type::Named(n) => {
            let body = cx.m.types.structs[*n as usize].body.as_ref().ok_or("an opaque struct")?;
            Ok((body.fields.clone(), body.packed))
        }
        _ => Err("not a struct".into()),
    }
}

/// Splits each edge from a block with several successors into a block
/// with phis.
/// For machines whose branches compare whole registers: a branch on a
/// boolean that is not an integer comparison in the same block (whose
/// branch can compare its operands) becomes a branch on the boolean,
/// zero-extended, compared with zero. A boolean's bits above the lowest are
/// undefined, so the extension is needed.
fn compare_boolean_branches(cx: &mut Ctx, f: &mut Function) {
    let i64t = cx.m.types.int(64);
    let i1 = cx.m.types.int(1);
    let zero = cx.int(i64t, 0);
    for b in f.layout.clone() {
        let Some(t) = f.terminator(b) else { continue };
        let Op::CondBr { cond: Value::Local(c), then_dest, else_dest } = f.insts[t.index()].op.clone() else {
            continue;
        };
        let compared_here = matches!(f.locals[c.index()].def,
            LocalDef::Inst(d) if matches!(f.insts[d.index()].op, Op::ICmp { .. })
                && f.blocks[b.index()].insts.contains(&d));
        if compared_here {
            continue;
        }
        let z = f.add_inst(
            Op::Cast { op: CastOp::ZExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: Value::Local(c) },
            Some((None, i64t)),
        );
        let cmp =
            f.add_inst(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: f.result(z), rhs: zero }, Some((None, i1)));
        let at = f.blocks[b.index()].insts.len() - 1;
        f.blocks[b.index()].insts.splice(at..at, [z, cmp]);
        f.insts[t.index()].op = Op::CondBr { cond: f.result(cmp), then_dest, else_dest };
    }
}

fn split_phi_edges(f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for p in blocks {
        let Some(t) = f.terminator(p) else { continue };
        let succs = f.insts[t.index()].op.successors();
        if succs.len() < 2 {
            continue;
        }
        let has_phis = |f: &Function, s: BlockId| {
            f.blocks[s.index()].insts.first().is_some_and(|&i| f.insts[i.index()].op.is_phi())
        };
        let mut edge = 0;
        let mut new_targets: Vec<BlockId> = Vec::new();
        for s in succs {
            if !has_phis(f, s) {
                new_targets.push(s);
                continue;
            }
            let e = f.add_block(None);
            let at = f.layout.iter().position(|&x| x == p).unwrap() + 1 + edge;
            edge += 1;
            f.layout.insert(at, e);
            f.push_inst(e, Op::Br(s), None);
            // One of `p`'s entries in the phis moves to `e`.
            let phis: Vec<InstId> =
                f.blocks[s.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect();
            for phi in phis {
                if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op
                    && let Some(entry) = incoming.iter_mut().find(|(_, from)| *from == p)
                {
                    entry.1 = e;
                }
            }
            new_targets.push(e);
        }
        let mut it = new_targets.into_iter();
        f.insts[t.index()].op.for_each_successor_mut(|s| *s = it.next().unwrap());
    }
}

/// A global and a byte offset, for a constant address.
pub fn const_address(cx: &Ctx, c: ConstId) -> Option<(GlobalId, i64)> {
    let k = cx.m.constant(c);
    match &k.kind {
        ConstKind::Global(g) => Some((*g, 0)),
        ConstKind::Expr(e) => match e {
            ConstExpr::Cast { value, .. } => const_address(cx, *value),
            ConstExpr::Gep { ptr: base, indices, source_ty, .. } => {
                let (g, mut off) = const_address(cx, *base)?;
                let mut ty = *source_ty;
                for (n, &idx) in indices.iter().enumerate() {
                    let i = {
                        let ik = cx.m.constant(idx);
                        match (&ik.kind, cx.m.types.get(ik.ty)) {
                            (ConstKind::Int(a), Type::Int(b)) => sext(a.low_u64(), *b),
                            (ConstKind::Zero | ConstKind::Null, _) => 0,
                            _ => return None,
                        }
                    };
                    if n == 0 {
                        off += i * cx.size_of(ty).ok()? as i64;
                        continue;
                    }
                    match cx.m.types.get(ty).clone() {
                        Type::Struct { .. } | Type::Named(_) => {
                            let (fields, packed) = struct_fields(cx, ty).ok()?;
                            let layout = cx.dl.struct_layout(&cx.m.types, &fields, packed)?;
                            off += layout.offsets[i as usize] as i64;
                            ty = fields[i as usize];
                        }
                        Type::Array { elem, .. } | Type::Vector { elem, .. } => {
                            off += i * cx.size_of(elem).ok()? as i64;
                            ty = elem;
                        }
                        _ => return None,
                    }
                }
                Some((g, off))
            }
            _ => None,
        },
        _ => None,
    }
}
