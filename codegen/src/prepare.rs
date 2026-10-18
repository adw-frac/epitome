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
//! - Division and remainder by constants become multiplications and
//!   shifts (see `divconst`).
//! - Integers of other widths below 64 (`i33`, say) are held in the next
//!   register width, with the same rule: masked or sign-extended in place
//!   before an operation that reads their top bits.

use smaugian_ir::apint::ApInt;
use smaugian_ir::layout::DataLayout;
use smaugian_ir::module::*;
use smaugian_ir::types::{Type, TypeId};

use crate::target::sext;

pub struct Ctx<'a> {
    pub m: &'a mut Module,
    pub dl: &'a DataLayout,
}

impl Ctx<'_> {
    fn i64t(&mut self) -> TypeId {
        self.m.types.int(64)
    }

    fn i8t(&mut self) -> TypeId {
        self.m.types.int(8)
    }

    fn int(&mut self, ty: TypeId, v: i64) -> Value {
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

    fn value_ty(&self, f: &Function, v: Value) -> TypeId {
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
    lower_geps(cx, &mut f)?;
    promote_odd(cx, &mut f)?;
    widen_narrow(cx, &mut f);
    lower_const_divs(cx, &mut f);
    split_phi_edges(&mut f);
    Ok(f)
}

/// Rejects what the code generator cannot do yet.
fn check(cx: &Ctx, f: &Function, fname: &str) -> Result<(), String> {
    let bad_type = |ty: TypeId| match cx.m.types.get(ty) {
        Type::Int(b) => *b > 64,
        Type::Ptr(a) => *a != 0,
        Type::Void | Type::Label => false,
        _ => true,
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
            Op::AtomicRmw { .. } | Op::CmpXchg { .. } | Op::Fence { .. } => {
                return Err(format!("@{fname}: atomics are not supported yet"));
            }
            Op::Load { atomic: Some(_), .. } | Op::Store { atomic: Some(_), .. } => {
                return Err(format!("@{fname}: atomics are not supported yet"));
            }
            Op::VaArg { .. } => return Err(format!("@{fname}: va_arg is not supported yet")),
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
