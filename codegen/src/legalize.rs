//! Vector type legalisation: vectors are made into what the description's
//! instructions take. Values of vector types wider than a 128-bit register
//! become lists of 128-bit parts; those with lane counts not a power of
//! two, or narrower than a d register, become a scalar for each lane.
//!
//! Each instruction with a split result or operand is replaced by one per
//! part: element-wise operations, comparisons (whose masks are split as
//! their operands are), selects, loads and stores, phis, and calls to
//! element-wise intrinsics (declared again for the part's type). Others
//! need more:
//!
//! - **Widening** (`sext`, `zext`) is done one doubling at a time, each
//!   part giving two: the extension of its low half and of its high half
//!   (`sxtl` and `sxtl2`). Wider steps are made into chains first.
//! - **Narrowing** (`trunc`) also halves at each step: two parts give one,
//!   the truncations of each joined (`xtn` and `xtn2`).
//! - **Shuffles** take each result lane from the part holding it: whole
//!   parts are reused, splats splatted, and other lanes extracted and
//!   inserted one by one. Shuffles of legal vectors with no instruction are
//!   done the same way. `insertelement` and `extractelement` with constant
//!   lanes go to the part holding the lane.
//! - **Reductions** (`llvm.vector.reduce.*`) combine the parts with the
//!   same operation, then reduce one part. A partial reduction adds its
//!   parts to the accumulator, folding halves together to its width.
//!
//! Before splitting, vectors of pointers become vectors of i64, masks are
//! given the lane widths their uses need (`fix_masks`), and operations
//! with no instruction are rewritten (`rewrite_vector_ops`); after it,
//! those still without one are done lane by lane (`expand_lanewise`).
//! Other operations on split vectors are reported as not supported.

use std::collections::HashMap;

use epitome_ir::module::*;
use epitome_ir::types::{Type, TypeId};

use crate::prepare::{Ctx, callee_name};

/// The lanes, element type and element width of a vector type.
fn vec_info(cx: &Ctx, ty: TypeId) -> Option<(u32, TypeId, u32)> {
    match cx.m.types.get(ty) {
        Type::Vector { scalable: false, len, elem } => {
            let eb = match cx.m.types.get(*elem) {
                Type::Int(b) => *b,
                Type::Float => 32,
                Type::Double => 64,
                _ => return None,
            };
            Some((*len, *elem, eb))
        }
        _ => None,
    }
}

/// How many parts a value of type `ty` needs, if it is not legal: 128-bit
/// parts, or, for lane counts not a power of two and vectors narrower than
/// a d register, a scalar for each lane.
/// Masks (vectors of i1) are not decided by their own type.
fn split_count(cx: &Ctx, ty: TypeId) -> Option<usize> {
    let (len, _, eb) = vec_info(cx, ty)?;
    if eb == 1 {
        return None;
    }
    let bits = len * eb;
    let vb = cx.vector_bits();
    if vb == 0 || !len.is_power_of_two() || bits < vb / 2 {
        return Some(len as usize);
    }
    (bits > vb).then_some((bits / vb) as usize)
}

/// The type of each part of a split vector of `len` lanes of `elem` (`eb`
/// bits wide): a 128-bit vector, or, for those scalarised, the element
/// itself. For masks, `elem` is i1 and `eb` the width of the
/// lanes compared.
fn part(cx: &mut Ctx, len: u32, elem: TypeId, eb: u32) -> TypeId {
    let vb = cx.vector_bits();
    if vb > 0 && len.is_power_of_two() && len * eb >= vb / 2 { vec_ty(cx, vb / eb, elem) } else { elem }
}

fn is_vec(cx: &Ctx, ty: TypeId) -> bool {
    matches!(cx.m.types.get(ty), Type::Vector { .. })
}

fn vec_ty(cx: &mut Ctx, len: u32, elem: TypeId) -> TypeId {
    cx.m.types.intern(Type::Vector { scalable: false, len, elem })
}

/// The LLVM name of a type in an intrinsic's name: `v4i32`, `v2f64`.
pub(crate) fn mangle(cx: &Ctx, ty: TypeId) -> String {
    match cx.m.types.get(ty) {
        Type::Vector { len, elem, .. } => format!("v{len}{}", mangle(cx, *elem)),
        Type::Int(b) => format!("i{b}"),
        Type::Float => "f32".into(),
        Type::Double => "f64".into(),
        _ => "?".into(),
    }
}

/// A function declaration (an intrinsic), found or added.
pub fn declare(cx: &mut Ctx, name: &str, ret: TypeId, params: &[TypeId]) -> Value {
    let g = match cx.m.globals.iter().position(|g| g.name.as_deref() == Some(name)) {
        Some(i) => GlobalId(i as u32),
        None => {
            let ty = cx.m.types.intern(Type::Function { ret, params: params.to_vec(), varargs: false });
            let mut f = Function { ty, ..Default::default() };
            for (k, &t) in params.iter().enumerate() {
                let local = f.add_local(None, t, LocalDef::Param(k as u32));
                f.params.push(Param { local, attrs: vec![] });
            }
            let g = GlobalId(cx.m.globals.len() as u32);
            cx.m.globals.push(Global {
                name: Some(name.to_string()),
                props: GlobalProps::default(),
                attachments: vec![],
                kind: GlobalKind::Function(Box::new(f)),
            });
            cx.m.global_order.push(g);
            g
        }
    };
    let ptr = cx.m.types.ptr(0);
    Value::Const(cx.m.consts.intern(Constant { ty: ptr, kind: ConstKind::Global(g) }))
}

struct Builder<'f> {
    f: &'f mut Function,
    new: Vec<InstId>,
}

impl Builder<'_> {
    fn op(&mut self, op: Op, ty: Option<TypeId>) -> Value {
        let i = self.f.add_inst(op, ty.map(|t| (None, t)));
        self.new.push(i);
        if ty.is_some() { self.f.result(i) } else { Value::Const(ConstId(0)) }
    }
}

fn shuffle(b: &mut Builder, cx: &mut Ctx, a: Value, bv: Value, lanes: &[i32], ty: TypeId) -> Value {
    let i32t = cx.m.types.int(32);
    let elems: Vec<ConstId> = lanes
        .iter()
        .map(|&l| {
            cx.m.consts
                .intern(Constant { ty: i32t, kind: ConstKind::Int(epitome_ir::apint::ApInt::from_i64(32, l as i64)) })
        })
        .collect();
    let mty = vec_ty(cx, lanes.len() as u32, i32t);
    let mask = cx.m.consts.intern(Constant { ty: mty, kind: ConstKind::Vector(elems) });
    b.op(Op::ShuffleVector { a, b: bv, mask }, Some(ty))
}

fn poison(cx: &mut Ctx, ty: TypeId) -> Value {
    Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }))
}

/// The parts of `v`, whose type is split into `n` parts of `part_ty`.
fn parts_of(
    cx: &mut Ctx,
    parts: &HashMap<LocalId, Vec<Value>>,
    f: &Function,
    v: Value,
    n: usize,
    part_ty: TypeId,
) -> Result<Vec<Value>, String> {
    match v {
        Value::Local(x) => parts
            .get(&x)
            .cloned()
            .ok_or_else(|| format!("a split vector {:?} used before its parts", f.locals[x.index()].name)),
        Value::Const(c) => {
            let k = cx.m.constant(c).clone();
            if !is_vec(cx, part_ty) {
                return Ok((0..n)
                    .map(|p| match &k.kind {
                        ConstKind::Vector(es) => Value::Const(es[p]),
                        ConstKind::Splat(x) => Value::Const(*x),
                        other => Value::Const(cx.m.consts.intern(Constant { ty: part_ty, kind: other.clone() })),
                    })
                    .collect());
            }
            let (plen, _, _) = vec_info(cx, part_ty).unwrap();
            Ok((0..n)
                .map(|p| {
                    let kind = match &k.kind {
                        ConstKind::Vector(es) => {
                            ConstKind::Vector(es[p * plen as usize..(p + 1) * plen as usize].to_vec())
                        }
                        other => other.clone(),
                    };
                    Value::Const(cx.m.consts.intern(Constant { ty: part_ty, kind }))
                })
                .collect())
        }
        Value::Metadata(_) => Err("metadata as a vector".into()),
    }
}

/// Makes each extension or truncation change element widths by a factor
/// of two, inserting the steps between.
fn chain_casts(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            if let Op::Cast { op: op @ (CastOp::SExt | CastOp::ZExt | CastOp::Trunc), value, flags, fmf } =
                f.insts[i.index()].op.clone()
                && let Some(r) = f.insts[i.index()].result
            {
                let from_ty = cx.value_ty(f, value);
                let to_ty = f.locals[r.index()].ty;
                if let (Some((len, _, fe)), Some((_, _, te))) = (vec_info(cx, from_ty), vec_info(cx, to_ty))
                    && fe > 1
                    && (te > 2 * fe || fe > 2 * te)
                {
                    let mid_bits = if te > fe { fe * 2 } else { fe / 2 };
                    let mid_elem = cx.m.types.int(mid_bits);
                    let mid_ty = vec_ty(cx, len, mid_elem);
                    let m = f.add_inst(Op::Cast { op, flags, fmf, value }, Some((None, mid_ty)));
                    f.blocks[b.index()].insts.insert(k, m);
                    let mv = f.result(m);
                    if let Op::Cast { value, .. } = &mut f.insts[i.index()].op {
                        *value = mv;
                    }
                    continue;
                }
            }
            k += 1;
        }
    }
}

/// Extensions of masks to lanes of another width than the comparison that
/// made them: first to the comparison's own lanes (free: the lanes are
/// already all ones or zeros), then `and` with 1 for `zext`, then widened
/// or narrowed as integers.
fn widen_masks(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Cast { op: op @ (CastOp::SExt | CastOp::ZExt), value: Value::Local(m), flags, fmf } =
                f.insts[i.index()].op.clone()
            else {
                k += 1;
                continue;
            };
            let to_ty = f.locals[f.insts[i.index()].result.unwrap().index()].ty;
            let (Some((len, _, 1)), Some((_, _, te))) = (vec_info(cx, f.locals[m.index()].ty), vec_info(cx, to_ty))
            else {
                k += 1;
                continue;
            };
            // The lane width of the comparison that made the mask.
            let Some(cb) = mask_width(cx, f, Value::Local(m), &mut Vec::new()).filter(|&cb| cb != te) else {
                k += 1;
                continue;
            };
            let ce = cx.m.types.int(cb);
            let lane_ty = vec_ty(cx, len, ce);
            let mut new = Vec::new();
            let s = f.add_inst(
                Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf, value: Value::Local(m) },
                Some((None, lane_ty)),
            );
            new.push(s);
            let mut v = f.result(s);
            if op == CastOp::ZExt {
                let one = cx.int(ce, 1);
                let Value::Const(one) = one else { unreachable!() };
                let ones = Value::Const(cx.m.consts.intern(Constant { ty: lane_ty, kind: ConstKind::Splat(one) }));
                let a = f.add_inst(
                    Op::Binary { op: BinOp::And, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: v, rhs: ones },
                    Some((None, lane_ty)),
                );
                new.push(a);
                v = f.result(a);
            }
            // Then widened, or narrowed, as integers.
            let op = if cb < te { op } else { CastOp::Trunc };
            f.insts[i.index()].op = Op::Cast { op, flags, fmf, value: v };
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
}

/// Vectors of pointers become vectors of i64: their values retyped, the
/// scalars going in and out of them converted, and vector `getelementptr`s
/// written as arithmetic.
fn pointer_vectors(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i64t = cx.m.types.int(64);
    let ptr = cx.m.types.ptr(0);
    let as_int = |cx: &mut Ctx, ty: TypeId| match cx.m.types.get(ty).clone() {
        Type::Vector { scalable: false, len, elem } if elem == ptr => Some(vec_ty(cx, len, i64t)),
        _ => None,
    };
    if !f.locals.iter().any(|l| matches!(cx.m.types.get(l.ty), Type::Vector { elem, .. } if *elem == ptr)) {
        return Ok(());
    }
    for k in 0..f.locals.len() {
        if let Some(t) = as_int(cx, f.locals[k].ty) {
            f.locals[k].ty = t;
        }
    }
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            // Constants of pointer vectors: null, zero and poison only.
            let mut op = f.insts[i.index()].op.clone();
            let mut bad = false;
            op.for_each_value_mut(|v| {
                if let Value::Const(c) = *v {
                    let k = cx.m.constant(c).clone();
                    if let Some(t) = as_int(cx, k.ty) {
                        let kind = match k.kind {
                            ConstKind::Zero | ConstKind::Null => ConstKind::Zero,
                            ConstKind::Vector(es)
                                if es
                                    .iter()
                                    .all(|&e| matches!(cx.m.constant(e).kind, ConstKind::Null | ConstKind::Zero)) =>
                            {
                                ConstKind::Zero
                            }
                            ConstKind::Poison => ConstKind::Poison,
                            ConstKind::Undef => ConstKind::Undef,
                            _ => {
                                bad = true;
                                return;
                            }
                        };
                        *v = Value::Const(cx.m.consts.intern(Constant { ty: t, kind }));
                    }
                }
            });
            if bad {
                return Err("a vector of pointers to globals".into());
            }
            let res = f.insts[i.index()].result;
            let res_ty = res.map(|r| f.locals[r.index()].ty);
            let mut new = Vec::new();
            match &mut op {
                // A pointer put into a vector: its address.
                Op::InsertElement { element, .. } if cx.value_ty(f, *element) == ptr => {
                    let c = f.add_inst(
                        Op::Cast {
                            op: CastOp::PtrToInt,
                            flags: IntFlags::NONE,
                            fmf: FastMath::default(),
                            value: *element,
                        },
                        Some((None, i64t)),
                    );
                    new.push(c);
                    *element = f.result(c);
                }
                // One taken out: made a pointer again.
                Op::ExtractElement { .. } if res_ty == Some(ptr) => {
                    let r = res.unwrap();
                    let old = Value::Local(r);
                    f.locals[r.index()].ty = i64t;
                    let c = f.add_inst(
                        Op::Cast { op: CastOp::IntToPtr, flags: IntFlags::NONE, fmf: FastMath::default(), value: old },
                        Some((None, ptr)),
                    );
                    let cv = f.result(c);
                    f.insts[i.index()].op = op.clone();
                    f.replace_uses(old, cv);
                    // replace_uses rewrote the cast's own operand too.
                    f.insts[c.index()].op =
                        Op::Cast { op: CastOp::IntToPtr, flags: IntFlags::NONE, fmf: FastMath::default(), value: old };
                    f.blocks[b.index()].insts.insert(k + 1, c);
                    k += 2;
                    continue;
                }
                Op::Cast { op: CastOp::PtrToInt | CastOp::IntToPtr, value, .. }
                    if res_ty.is_some_and(|t| matches!(cx.m.types.get(t), Type::Vector { .. }))
                        && cx.value_ty(f, *value) == res_ty.unwrap() =>
                {
                    let v = *value;
                    f.replace_uses(Value::Local(res.unwrap()), v);
                    f.blocks[b.index()].insts.remove(k);
                    continue;
                }
                Op::Gep { source_ty, ptr: base, indices, .. }
                    if res_ty.is_some_and(|t| matches!(cx.m.types.get(t), Type::Vector { .. })) =>
                {
                    let rt = res_ty.unwrap();
                    let (len, _, _) = vec_info(cx, rt).unwrap();
                    let [idx] = indices[..] else {
                        return Err("a vector getelementptr with more than one index".into());
                    };
                    let size = cx.size_of(*source_ty)?;
                    let i64z = cx.int(i64t, 0);
                    let splat = |f: &mut Function, cx: &mut Ctx, v: Value, new: &mut Vec<InstId>| -> Value {
                        let vt = cx.value_ty(f, v);
                        if matches!(cx.m.types.get(vt), Type::Vector { .. }) {
                            return v;
                        }
                        let v = if vt == ptr {
                            let c = f.add_inst(
                                Op::Cast {
                                    op: CastOp::PtrToInt,
                                    flags: IntFlags::NONE,
                                    fmf: FastMath::default(),
                                    value: v,
                                },
                                Some((None, i64t)),
                            );
                            new.push(c);
                            f.result(c)
                        } else {
                            v
                        };
                        let pz = poison(cx, rt);
                        let ins =
                            f.add_inst(Op::InsertElement { vector: pz, element: v, index: i64z }, Some((None, rt)));
                        new.push(ins);
                        let insv = f.result(ins);
                        let mut bb = Builder { f, new: Vec::new() };
                        let s = shuffle(&mut bb, cx, insv, pz, &vec![0; len as usize], rt);
                        new.extend(bb.new);
                        s
                    };
                    let bv = splat(f, cx, *base, &mut new);
                    let iv = splat(f, cx, idx, &mut new);
                    let off = if size == 1 {
                        iv
                    } else {
                        let sc = cx.int(i64t, size as i64);
                        let Value::Const(sc) = sc else { unreachable!() };
                        let sv = Value::Const(cx.m.consts.intern(Constant { ty: rt, kind: ConstKind::Splat(sc) }));
                        let m = f.add_inst(
                            Op::Binary {
                                op: BinOp::Mul,
                                flags: IntFlags::NONE,
                                fmf: FastMath::default(),
                                lhs: iv,
                                rhs: sv,
                            },
                            Some((None, rt)),
                        );
                        new.push(m);
                        f.result(m)
                    };
                    op = Op::Binary {
                        op: BinOp::Add,
                        flags: IntFlags::NONE,
                        fmf: FastMath::default(),
                        lhs: bv,
                        rhs: off,
                    };
                }
                _ => {}
            }
            f.insts[i.index()].op = op;
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

/// Is there an instruction for this shuffle of legal vectors: a pattern in
/// the description whose root is a shuffle by this mask? Others are done
/// lane by lane.
fn native_shuffle(cx: &Ctx, f: &Function, i: InstId) -> bool {
    let Op::ShuffleVector { a, mask, .. } = &f.insts[i.index()].op else { return false };
    let Some(r) = f.insts[i.index()].result else { return false };
    let rty = f.locals[r.index()].ty;
    let of_masks =
        matches!(cx.m.types.get(rty), Type::Vector { elem, .. } if matches!(cx.m.types.get(*elem), Type::Int(1)));
    let hb = (!of_masks).then(|| crate::target::head_bits(cx.m, rty));
    let of_insert = matches!(a, Value::Local(x) if matches!(f.locals[x.index()].def,
        LocalDef::Inst(d) if matches!(f.insts[d.index()].op, Op::InsertElement { .. })));
    let src_bits = crate::target::type_bits(cx.m, cx.value_ty(f, *a));
    crate::target::mask_lanes(cx.m, *mask).is_some_and(|lanes| cx.t.has_shuffle(&lanes, hb, src_bits, of_insert))
}

/// Vector operations rewritten into a form instructions more often have:
/// `icmp ne` against other than zero, as `icmp ne (xor ..), 0` (which
/// AArch64's `cmtst` does); conversions between integers and floats of
/// another width, as a conversion at the float's width and an extension or
/// truncation (`uitofp <2 x i32> to <2 x double>` widens first). (Shifts by
/// a vector of amounts are the description's: AArch64's recipes shift with
/// `ushl` and `sshl`.)
fn rewrite_vector_ops(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            if f.insts[i.index()].result.is_none() {
                k += 1;
                continue;
            }
            let mut new = Vec::new();
            match f.insts[i.index()].op.clone() {
                Op::ICmp { pred: ICmpPred::Ne, samesign, lhs, rhs }
                    if vec_info(cx, cx.value_ty(f, lhs)).is_some()
                        && !matches!(rhs, Value::Const(c) if matches!(cx.m.constant(c).kind, ConstKind::Zero)) =>
                {
                    let t = cx.value_ty(f, lhs);
                    let x = f.add_inst(
                        Op::Binary { op: BinOp::Xor, flags: IntFlags::NONE, fmf: FastMath::default(), lhs, rhs },
                        Some((None, t)),
                    );
                    new.push(x);
                    let zero = Value::Const(cx.m.consts.intern(Constant { ty: t, kind: ConstKind::Zero }));
                    f.insts[i.index()].op = Op::ICmp { pred: ICmpPred::Ne, samesign, lhs: f.result(x), rhs: zero };
                }
                Op::Cast { op: op @ (CastOp::UIToFP | CastOp::SIToFP), value, .. }
                    if vec_info(cx, cx.value_ty(f, value))
                        .zip(vec_info(cx, f.locals[f.insts[i.index()].result.unwrap().index()].ty))
                        .is_some_and(|((_, _, a), (_, _, b))| a != b) =>
                {
                    let from = cx.value_ty(f, value);
                    let to = f.locals[f.insts[i.index()].result.unwrap().index()].ty;
                    let ((len, _, a), (_, _, bits)) = (vec_info(cx, from).unwrap(), vec_info(cx, to).unwrap());
                    let et = cx.m.types.int(bits);
                    let wide = cx.m.types.intern(Type::Vector { scalable: false, len, elem: et });
                    let ext = match (op, a < bits) {
                        (_, false) => CastOp::Trunc,
                        (CastOp::UIToFP, true) => CastOp::ZExt,
                        _ => CastOp::SExt,
                    };
                    let x = f.add_inst(
                        Op::Cast { op: ext, flags: IntFlags::NONE, fmf: FastMath::default(), value },
                        Some((None, wide)),
                    );
                    new.push(x);
                    f.insts[i.index()].op =
                        Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value: f.result(x) };
                }
                Op::Cast { op: op @ (CastOp::FPToUI | CastOp::FPToSI), value, .. }
                    if vec_info(cx, cx.value_ty(f, value))
                        .zip(vec_info(cx, f.locals[f.insts[i.index()].result.unwrap().index()].ty))
                        .is_some_and(|((_, _, a), (_, _, b))| a != b) =>
                {
                    let from = cx.value_ty(f, value);
                    let r = f.insts[i.index()].result.unwrap();
                    let to = f.locals[r.index()].ty;
                    let ((len, _, bits), (_, _, b)) = (vec_info(cx, from).unwrap(), vec_info(cx, to).unwrap());
                    let et = cx.m.types.int(bits);
                    let wide = cx.m.types.intern(Type::Vector { scalable: false, len, elem: et });
                    // Converted at the float's width, then narrowed or
                    // extended: the original's result, from a new one.
                    let conv = f.add_inst(
                        Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value },
                        Some((None, wide)),
                    );
                    new.push(conv);
                    let ext = if b < bits {
                        CastOp::Trunc
                    } else if op == CastOp::FPToUI {
                        CastOp::ZExt
                    } else {
                        CastOp::SExt
                    };
                    f.insts[i.index()].op =
                        Op::Cast { op: ext, flags: IntFlags::NONE, fmf: FastMath::default(), value: f.result(conv) };
                }
                _ => {}
            }
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
}

/// After splitting: operations on legal vectors that no instruction does,
/// done lane by lane: divisions and remainders, multiplications of 64-bit
/// lanes, and reductions
/// with no across-lanes instruction (`and`, `or`, `xor`, `mul`; of 64-bit
/// lanes, all but `add`; of two 32-bit lanes, all but `add`).
fn expand_lanewise(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i64t = cx.m.types.int(64);
    let blocks: Vec<BlockId> = f.layout.clone();
    for blk in blocks {
        let mut k = 0;
        while k < f.blocks[blk.index()].insts.len() {
            let i = f.blocks[blk.index()].insts[k];
            let Some(r) = f.insts[i.index()].result else {
                k += 1;
                continue;
            };
            let rt = f.locals[r.index()].ty;
            let mut bld = Builder { f, new: Vec::new() };
            let lanes = |bld: &mut Builder, cx: &mut Ctx, v: Value, len: u32, elem: TypeId| -> Vec<Value> {
                (0..len)
                    .map(|l| {
                        let idx = cx.int(i64t, l as i64);
                        bld.op(Op::ExtractElement { vector: v, index: idx }, Some(elem))
                    })
                    .collect()
            };
            let mut replace = None;
            match bld.f.insts[i.index()].op.clone() {
                Op::Binary {
                    op: op @ (BinOp::Mul | BinOp::UDiv | BinOp::SDiv | BinOp::URem | BinOp::SRem),
                    flags,
                    fmf,
                    lhs,
                    rhs,
                } if vec_info(cx, rt).is_some_and(|(_, _, eb)| eb == 64 || op != BinOp::Mul) => {
                    let (len, elem, _) = vec_info(cx, rt).unwrap();
                    let a = lanes(&mut bld, cx, lhs, len, elem);
                    let b = lanes(&mut bld, cx, rhs, len, elem);
                    let mut acc = poison(cx, rt);
                    for l in 0..len as usize {
                        let m = bld.op(Op::Binary { op, flags, fmf, lhs: a[l], rhs: b[l] }, Some(elem));
                        let idx = cx.int(i64t, l as i64);
                        acc = bld.op(Op::InsertElement { vector: acc, element: m, index: idx }, Some(rt));
                    }
                    replace = Some(acc);
                }
                Op::Call(call) => {
                    let name = callee_name(cx.m, &call).unwrap_or_default();
                    if let Some(rest) = name.strip_prefix("llvm.vector.reduce.")
                        && let Some(&arg) = call.args.first().map(|a| &a.value)
                        && let Some((len, elem, eb)) = vec_info(cx, cx.value_ty(bld.f, arg))
                    {
                        let opname = rest.split('.').next().unwrap_or("");
                        let native = match opname {
                            "add" => true,
                            "smax" | "smin" | "umax" | "umin" => eb < 64 && len * eb == cx.vector_bits() || eb < 32,
                            _ => false,
                        };
                        if !native
                            && matches!(
                                opname,
                                "add" | "mul" | "and" | "or" | "xor" | "smax" | "smin" | "umax" | "umin"
                            )
                        {
                            let ls = lanes(&mut bld, cx, arg, len, elem);
                            let mut acc = ls[0];
                            for &l in &ls[1..] {
                                acc = combine(&mut bld, cx, opname, acc, l, elem)?;
                            }
                            replace = Some(acc);
                        }
                    }
                }
                _ => {}
            }
            let new = std::mem::take(&mut bld.new);
            match replace {
                Some(v) => {
                    f.replace_uses(Value::Local(r), v);
                    let n = new.len();
                    f.blocks[blk.index()].insts.splice(k..=k, new);
                    k += n;
                }
                None => k += 1,
            }
        }
    }
    Ok(())
}

/// The lane width of mask `v`: that of the comparison that made it, through
/// logic, freezes, selects and phis. `None` for masks of any width: splats
/// of one boolean (the whole register is ones or zeros) and constants.
fn mask_width(cx: &Ctx, f: &Function, v: Value, seen: &mut Vec<LocalId>) -> Option<u32> {
    let Value::Local(x) = v else { return None };
    let LocalDef::Inst(d) = f.locals[x.index()].def else { return None };
    if seen.contains(&x) {
        return None;
    }
    seen.push(x);
    let w = match &f.insts[d.index()].op {
        Op::ICmp { lhs, .. } | Op::FCmp { lhs, .. } => vec_info(cx, cx.value_ty(f, *lhs)).map(|(_, _, e)| e),
        Op::Binary { lhs, rhs, .. } => mask_width(cx, f, *lhs, seen).or_else(|| mask_width(cx, f, *rhs, seen)),
        Op::Freeze(a) => mask_width(cx, f, *a, seen),
        Op::Select { then_value, else_value, .. } => {
            mask_width(cx, f, *then_value, seen).or_else(|| mask_width(cx, f, *else_value, seen))
        }
        Op::Phi { incoming, .. } => incoming.iter().find_map(|(v, _)| mask_width(cx, f, *v, seen)),
        Op::ShuffleVector { a, .. } if !is_bool_splat(cx, f, d) => mask_width(cx, f, *a, seen),
        _ => None,
    };
    seen.pop();
    w
}

/// Is `i` a splat of one boolean: `shufflevector (insertelement poison, i1
/// %c, 0), poison, zeroinitializer`?
fn is_bool_splat(cx: &Ctx, f: &Function, i: InstId) -> bool {
    let Op::ShuffleVector { a: Value::Local(x), mask, .. } = &f.insts[i.index()].op else { return false };
    let Some(lanes) = crate::target::mask_lanes(cx.m, *mask) else { return false };
    lanes.iter().all(|&l| l <= 0)
        && matches!(f.locals[x.index()].def, LocalDef::Inst(d) if matches!(&f.insts[d.index()].op,
            Op::InsertElement { element, .. } if matches!(cx.m.types.get(cx.value_ty(f, *element)), Type::Int(1))))
}

/// Masks made as wide as their uses need, as LLVM promotes vectors of i1:
///
/// - a mask used by a `select` of lanes of another width, or combined with
///   a mask of another width, is converted: extended to its comparison's
///   lane width, extended or truncated to the width wanted, and compared
///   with zero;
/// - a splat of one boolean is extended and splatted as an integer, then
///   compared with zero, which makes a register of all ones or all zeros,
///   right at any width;
/// - `icmp eq|ne (bitcast mask to iN), 0`, whether any lane is set, is the
///   unsigned maximum of the mask's lanes compared with zero.
fn fix_masks(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i1 = cx.m.types.int(1);
    let i64t = cx.m.types.int(64);
    // Converts mask `m` (lanes `len`) from width `from` to `to`, before `new`.
    let convert =
        |cx: &mut Ctx, f: &mut Function, new: &mut Vec<InstId>, m: Value, len: u32, from: u32, to: u32| -> Value {
            let ft = {
                let e = cx.m.types.int(from);
                vec_ty(cx, len, e)
            };
            let tt = {
                let e = cx.m.types.int(to);
                vec_ty(cx, len, e)
            };
            let s = f.add_inst(
                Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: m },
                Some((None, ft)),
            );
            new.push(s);
            let op = if to > from { CastOp::SExt } else { CastOp::Trunc };
            let c = f.add_inst(
                Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value: f.result(s) },
                Some((None, tt)),
            );
            new.push(c);
            let zero = Value::Const(cx.m.consts.intern(Constant { ty: tt, kind: ConstKind::Zero }));
            let mt = { vec_ty(cx, len, i1) };
            let r = f.add_inst(
                Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: f.result(c), rhs: zero },
                Some((None, mt)),
            );
            new.push(r);
            f.result(r)
        };
    let is_mask = |cx: &Ctx, ty: TypeId| vec_info(cx, ty).is_some_and(|(_, _, e)| e == 1);
    let blocks: Vec<BlockId> = f.layout.clone();
    // Uses first, while the splats can still be told apart.
    for &b in &blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let mut new = Vec::new();
            match f.insts[i.index()].op.clone() {
                Op::Select { fmf, cond, then_value, else_value } if is_mask(cx, cx.value_ty(f, cond)) => {
                    let (len, _, te) = vec_info(cx, cx.value_ty(f, then_value)).ok_or("a select of masks")?;
                    if let Some(w) = mask_width(cx, f, cond, &mut Vec::new())
                        && w != te
                        && te != 1
                    {
                        let c = convert(cx, f, &mut new, cond, len, w, te);
                        f.insts[i.index()].op = Op::Select { fmf, cond: c, then_value, else_value };
                    }
                }
                Op::Binary { op, flags, fmf, lhs, rhs } if is_mask(cx, cx.value_ty(f, lhs)) => {
                    let (len, _, _) = vec_info(cx, cx.value_ty(f, lhs)).unwrap();
                    if let (Some(a), Some(c)) =
                        (mask_width(cx, f, lhs, &mut Vec::new()), mask_width(cx, f, rhs, &mut Vec::new()))
                        && a != c
                    {
                        let r = convert(cx, f, &mut new, rhs, len, c, a);
                        f.insts[i.index()].op = Op::Binary { op, flags, fmf, lhs, rhs: r };
                    }
                }
                Op::ICmp { pred: pred @ (ICmpPred::Eq | ICmpPred::Ne), samesign, lhs: Value::Local(x), rhs }
                    if matches!(rhs, Value::Const(c) if matches!(cx.m.constant(c).kind, ConstKind::Zero | ConstKind::Int(_)) && cx.const_int(rhs) == Some(0))
                        && let LocalDef::Inst(d) = f.locals[x.index()].def
                        && let Op::Cast { op: CastOp::BitCast, value: m, .. } = f.insts[d.index()].op
                        && is_mask(cx, cx.value_ty(f, m)) =>
                {
                    let (len, _, _) = vec_info(cx, cx.value_ty(f, m)).unwrap();
                    let w = mask_width(cx, f, m, &mut Vec::new()).unwrap_or((cx.vector_bits() / len).max(8));
                    let e = cx.m.types.int(w);
                    let vt = vec_ty(cx, len, e);
                    let s = f.add_inst(
                        Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: m },
                        Some((None, vt)),
                    );
                    new.push(s);
                    let callee = declare(cx, &format!("llvm.vector.reduce.umax.{}", mangle(cx, vt)), e, &[vt]);
                    let mut bld = Builder { f, new: Vec::new() };
                    let sv = bld.f.result(s);
                    let r = call_value(&mut bld, cx, callee, vec![sv], e, vt);
                    new.extend(bld.new);
                    let zero = cx.int(e, 0);
                    f.insts[i.index()].op = Op::ICmp { pred, samesign, lhs: r, rhs: zero };
                }
                _ => {}
            }
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    // Then the splats.
    for &b in &blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            if !is_bool_splat(cx, f, i) {
                k += 1;
                continue;
            }
            let Op::ShuffleVector { a: Value::Local(x), .. } = f.insts[i.index()].op else { unreachable!() };
            let LocalDef::Inst(d) = f.locals[x.index()].def else { unreachable!() };
            let Op::InsertElement { element, .. } = f.insts[d.index()].op else { unreachable!() };
            let r = f.insts[i.index()].result.unwrap();
            let (len, _, _) = vec_info(cx, f.locals[r.index()].ty).unwrap();
            let w = (cx.vector_bits() / len).max(8);
            let e = cx.m.types.int(w);
            let vt = vec_ty(cx, len, e);
            let mut new = Vec::new();
            let z = f.add_inst(
                Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: element },
                Some((None, e)),
            );
            new.push(z);
            let pz = poison(cx, vt);
            let zero_idx = cx.int(i64t, 0);
            let ins =
                f.add_inst(Op::InsertElement { vector: pz, element: f.result(z), index: zero_idx }, Some((None, vt)));
            new.push(ins);
            let mut bld = Builder { f, new: Vec::new() };
            let insv = bld.f.result(ins);
            let sp = shuffle(&mut bld, cx, insv, pz, &vec![0; len as usize], vt);
            new.extend(bld.new);
            let zero = Value::Const(cx.m.consts.intern(Constant { ty: vt, kind: ConstKind::Zero }));
            f.insts[i.index()].op = Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: sp, rhs: zero };
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

pub fn legalize_vectors(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    pointer_vectors(cx, f)?;
    rewrite_vector_ops(cx, f);
    fix_masks(cx, f)?;
    crate::prepare::bool_vector_casts(cx, f);
    widen_masks(cx, f);
    chain_casts(cx, f);
    let mut parts: HashMap<LocalId, Vec<Value>> = HashMap::new();
    let mut pending_phis: Vec<(Vec<InstId>, InstId)> = Vec::new();
    let blocks: Vec<BlockId> = f.layout.clone();
    for blk in blocks {
        let mut k = 0;
        while k < f.blocks[blk.index()].insts.len() {
            let i = f.blocks[blk.index()].insts[k];
            let res = f.insts[i.index()].result;
            let res_ty = res.map(|r| f.locals[r.index()].ty);
            let mut uses_split = false;
            f.insts[i.index()].op.for_each_value(|v| match v {
                Value::Local(x) => uses_split |= parts.contains_key(x),
                Value::Const(c) => uses_split |= split_count(cx, cx.m.constant(*c).ty).is_some(),
                Value::Metadata(_) => {}
            });
            let res_split = res_ty.and_then(|t| split_count(cx, t));
            let odd_shuffle = match &f.insts[i.index()].op {
                Op::ShuffleVector { .. } => !native_shuffle(cx, f, i),
                _ => false,
            };
            if !uses_split && res_split.is_none() && !odd_shuffle {
                k += 1;
                continue;
            }
            let op = f.insts[i.index()].op.clone();
            let mut bld = Builder { f, new: Vec::new() };
            // The parts of the result, or a replacement for it.
            let mut out_parts: Option<Vec<Value>> = None;
            let mut replace: Option<Value> = None;
            match op {
                Op::Binary { op, flags, fmf, lhs, rhs } if res_split.is_none() => {
                    // Masks, split as the comparisons that made them were.
                    let ps = [lhs, rhs]
                        .iter()
                        .find_map(|v| if let Value::Local(x) = v { parts.get(x).cloned() } else { None })
                        .ok_or("a binary operation on a split vector with a legal result")?;
                    let n = ps.len();
                    let pt = cx.value_ty(bld.f, ps[0]);
                    let l = parts_of(cx, &parts, bld.f, lhs, n, pt)?;
                    let r = parts_of(cx, &parts, bld.f, rhs, n, pt)?;
                    out_parts = Some(
                        (0..n).map(|p| bld.op(Op::Binary { op, flags, fmf, lhs: l[p], rhs: r[p] }, Some(pt))).collect(),
                    );
                }
                Op::Binary { op, flags, fmf, lhs, rhs } => {
                    let n = res_split.unwrap();
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let l = parts_of(cx, &parts, bld.f, lhs, n, pt)?;
                    let r = parts_of(cx, &parts, bld.f, rhs, n, pt)?;
                    out_parts = Some(
                        (0..n).map(|p| bld.op(Op::Binary { op, flags, fmf, lhs: l[p], rhs: r[p] }, Some(pt))).collect(),
                    );
                }
                Op::FNeg { fmf, value } => {
                    let n = res_split.unwrap();
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let v = parts_of(cx, &parts, bld.f, value, n, pt)?;
                    out_parts = Some((0..n).map(|p| bld.op(Op::FNeg { fmf, value: v[p] }, Some(pt))).collect());
                }
                Op::ICmp { pred, samesign, lhs, rhs } => {
                    let ot = cx.value_ty(bld.f, lhs);
                    let n = split_count(cx, ot).ok_or("a comparison of legal vectors with a split result")?;
                    let (vlen, elem, eb) = vec_info(cx, ot).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let i1 = cx.m.types.int(1);
                    let mt = part(cx, vlen, i1, eb);
                    let l = parts_of(cx, &parts, bld.f, lhs, n, pt)?;
                    let r = parts_of(cx, &parts, bld.f, rhs, n, pt)?;
                    out_parts = Some(
                        (0..n).map(|p| bld.op(Op::ICmp { pred, samesign, lhs: l[p], rhs: r[p] }, Some(mt))).collect(),
                    );
                }
                Op::FCmp { pred, fmf, lhs, rhs } => {
                    let ot = cx.value_ty(bld.f, lhs);
                    let n = split_count(cx, ot).ok_or("a comparison of legal vectors with a split result")?;
                    let (vlen, elem, eb) = vec_info(cx, ot).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let i1 = cx.m.types.int(1);
                    let mt = part(cx, vlen, i1, eb);
                    let l = parts_of(cx, &parts, bld.f, lhs, n, pt)?;
                    let r = parts_of(cx, &parts, bld.f, rhs, n, pt)?;
                    out_parts =
                        Some((0..n).map(|p| bld.op(Op::FCmp { pred, fmf, lhs: l[p], rhs: r[p] }, Some(mt))).collect());
                }
                Op::Select { fmf, cond, then_value, else_value } => {
                    let n = res_split.ok_or("a select of split vectors with a legal result")?;
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let t = parts_of(cx, &parts, bld.f, then_value, n, pt)?;
                    let e = parts_of(cx, &parts, bld.f, else_value, n, pt)?;
                    let c: Vec<Value> = match cond {
                        Value::Local(x) if parts.contains_key(&x) => parts[&x].clone(),
                        // A scalar condition chooses whole vectors.
                        v if !matches!(cx.m.types.get(cx.value_ty(bld.f, v)), Type::Vector { .. }) => vec![v; n],
                        _ => return Err("a select whose mask is not split as its values are".into()),
                    };
                    if c.len() != n {
                        return Err("a select whose mask is not split as its values are".into());
                    }
                    out_parts = Some(
                        (0..n)
                            .map(|p| {
                                bld.op(Op::Select { fmf, cond: c[p], then_value: t[p], else_value: e[p] }, Some(pt))
                            })
                            .collect(),
                    );
                }
                Op::Freeze(v) => {
                    let n = res_split.unwrap();
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let vs = parts_of(cx, &parts, bld.f, v, n, pt)?;
                    out_parts = Some((0..n).map(|p| bld.op(Op::Freeze(vs[p]), Some(pt))).collect());
                }
                Op::Phi { fmf, .. } => {
                    let n = res_split.ok_or("a phi of split masks")?;
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let mut phis = Vec::new();
                    for _ in 0..n {
                        let p = bld.f.add_inst(Op::Phi { fmf, incoming: vec![] }, Some((None, pt)));
                        phis.push(p);
                    }
                    out_parts = Some(phis.iter().map(|&p| bld.f.result(p)).collect());
                    bld.new.extend(phis.iter().copied());
                    pending_phis.push((phis, i));
                }
                Op::Load { volatile, atomic: None, ptr, align } => {
                    let n = res_split.unwrap();
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let step = if is_vec(cx, pt) { (cx.vector_bits() / 8) as i64 } else { (eb / 8) as i64 };
                    let i64t = cx.m.types.int(64);
                    let i8t = cx.m.types.int(8);
                    let ptr_ty = cx.m.types.ptr(0);
                    let mut ps = Vec::new();
                    for p in 0..n {
                        let at = if p == 0 {
                            ptr
                        } else {
                            let off = Value::Const(cx.m.consts.intern(Constant {
                                ty: i64t,
                                kind: ConstKind::Int(epitome_ir::apint::ApInt::from_i64(64, step * p as i64)),
                            }));
                            bld.op(
                                Op::Gep {
                                    flags: GepFlags::default(),
                                    inrange: None,
                                    source_ty: i8t,
                                    ptr,
                                    indices: vec![off],
                                },
                                Some(ptr_ty),
                            )
                        };
                        ps.push(bld.op(
                            Op::Load { volatile, atomic: None, ptr: at, align: align.map(|a| a.min(step as u64)) },
                            Some(pt),
                        ));
                    }
                    out_parts = Some(ps);
                }
                Op::Store { volatile, atomic: None, value, ptr, align } => {
                    let vt = cx.value_ty(bld.f, value);
                    let n = split_count(cx, vt).ok_or("a store of a split mask")?;
                    let (vlen, elem, eb) = vec_info(cx, vt).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let vs = parts_of(cx, &parts, bld.f, value, n, pt)?;
                    let step = if is_vec(cx, pt) { (cx.vector_bits() / 8) as i64 } else { (eb / 8) as i64 };
                    let i64t = cx.m.types.int(64);
                    let i8t = cx.m.types.int(8);
                    let ptr_ty = cx.m.types.ptr(0);
                    for (p, &v) in vs.iter().enumerate() {
                        let at = if p == 0 {
                            ptr
                        } else {
                            let off = Value::Const(cx.m.consts.intern(Constant {
                                ty: i64t,
                                kind: ConstKind::Int(epitome_ir::apint::ApInt::from_i64(64, step * p as i64)),
                            }));
                            bld.op(
                                Op::Gep {
                                    flags: GepFlags::default(),
                                    inrange: None,
                                    source_ty: i8t,
                                    ptr,
                                    indices: vec![off],
                                },
                                Some(ptr_ty),
                            )
                        };
                        bld.op(
                            Op::Store {
                                volatile,
                                atomic: None,
                                value: v,
                                ptr: at,
                                align: align.map(|a| a.min(step as u64)),
                            },
                            None,
                        );
                    }
                    out_parts = Some(vec![]);
                }
                // A split mask's bits as an integer (`bitcast <4 x i1> to
                // i4` of a `<4 x i64>` comparison): each part's, in its
                // place, low lanes in the low bits.
                Op::Cast { op: CastOp::BitCast, value: Value::Local(x), .. }
                    if parts.contains_key(&x) && res_ty.is_some_and(|t| matches!(cx.m.types.get(t), Type::Int(_))) =>
                {
                    let ty = res_ty.unwrap();
                    // Only compared with zero (whether any lane is set):
                    // the parts or-ed, then the unsigned maximum of the
                    // lanes, as integers, is the answer, 1 or 0.
                    let r = res.unwrap();
                    let mut only_zero_tests = true;
                    for j in bld.f.insts_in_order() {
                        let op = &bld.f.insts[j.index()].op;
                        let mut uses = false;
                        op.for_each_value(|v| uses |= *v == Value::Local(r));
                        if uses {
                            only_zero_tests &= matches!(op, Op::ICmp { pred: ICmpPred::Eq | ICmpPred::Ne, lhs: Value::Local(l), rhs: Value::Const(c), .. }
                                if *l == r && matches!(cx.m.constant(*c).kind, ConstKind::Zero)
                                    || matches!(&cx.m.constant(*c).kind, ConstKind::Int(a) if a.is_zero()));
                        }
                    }
                    let ps = parts[&x].clone();
                    let pt = cx.value_ty(bld.f, ps[0]);
                    if only_zero_tests && let Type::Vector { len, .. } = *cx.m.types.get(pt) {
                        let mut acc = ps[0];
                        for &p in &ps[1..] {
                            acc = bld.op(
                                Op::Binary {
                                    op: BinOp::Or,
                                    flags: IntFlags::NONE,
                                    fmf: FastMath::default(),
                                    lhs: acc,
                                    rhs: p,
                                },
                                Some(pt),
                            );
                        }
                        let w = (cx.vector_bits() / len).max(8);
                        let e = cx.m.types.int(w);
                        let it = vec_ty(cx, len, e);
                        let wide = bld.op(
                            Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: acc },
                            Some(it),
                        );
                        let callee = declare(cx, &format!("llvm.vector.reduce.umax.{}", mangle(cx, it)), e, &[it]);
                        let m = call_value(&mut bld, cx, callee, vec![wide], e, it);
                        let zero = Value::Const(cx.m.consts.intern(Constant { ty: e, kind: ConstKind::Zero }));
                        let i1 = cx.m.types.int(1);
                        let any = bld.op(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: m, rhs: zero }, Some(i1));
                        replace = Some(bld.op(
                            Op::Cast { op: CastOp::ZExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: any },
                            Some(ty),
                        ));
                    } else {
                        let mut acc: Option<Value> = None;
                        let mut at = 0u32;
                        for p in parts[&x].clone() {
                            let pty = cx.value_ty(bld.f, p);
                            let k = match cx.m.types.get(pty) {
                                Type::Vector { len, .. } => *len,
                                _ => 1,
                            };
                            let bits = if k == 1 && !is_vec(cx, pty) {
                                p
                            } else {
                                let kt = cx.m.types.int(k);
                                bld.op(
                                    Op::Cast {
                                        op: CastOp::BitCast,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        value: p,
                                    },
                                    Some(kt),
                                )
                            };
                            let z = bld.op(
                                Op::Cast {
                                    op: CastOp::ZExt,
                                    flags: IntFlags::NONE,
                                    fmf: FastMath::default(),
                                    value: bits,
                                },
                                Some(ty),
                            );
                            let z = if at == 0 {
                                z
                            } else {
                                let sh = Value::Const(cx.m.consts.intern(Constant {
                                    ty,
                                    kind: ConstKind::Int(epitome_ir::apint::ApInt::from_i64(
                                        match cx.m.types.get(ty) {
                                            Type::Int(b) => *b,
                                            _ => 64,
                                        },
                                        at as i64,
                                    )),
                                }));
                                bld.op(
                                    Op::Binary {
                                        op: BinOp::Shl,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        lhs: z,
                                        rhs: sh,
                                    },
                                    Some(ty),
                                )
                            };
                            acc = Some(match acc {
                                None => z,
                                Some(a) => bld.op(
                                    Op::Binary {
                                        op: BinOp::Or,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        lhs: a,
                                        rhs: z,
                                    },
                                    Some(ty),
                                ),
                            });
                            at += k;
                        }
                        replace = acc;
                    }
                }
                Op::Cast { op, flags, fmf, value } => {
                    let from_ty = cx.value_ty(bld.f, value);
                    let to_ty = res_ty.unwrap();
                    let (len, fe_ty, fe) = vec_info(cx, from_ty).ok_or("a cast of a split vector to a scalar")?;
                    let (_, te_ty, te) = vec_info(cx, to_ty).ok_or("a cast of a split vector to a scalar")?;
                    // The source as 128-bit parts (one, if it is legal).
                    let src: Vec<Value> = match value {
                        Value::Local(x) if parts.contains_key(&x) => parts[&x].clone(),
                        v if len * fe == cx.vector_bits() => vec![v],
                        // A legal vector cast to a scalarised one: its lanes.
                        v if res_split.is_some()
                            && fe > 1
                            && (!len.is_power_of_two() || len * te < cx.vector_bits() / 2) =>
                        {
                            let i64t = cx.m.types.int(64);
                            (0..len)
                                .map(|l| {
                                    let idx = cx.int(i64t, l as i64);
                                    bld.op(Op::ExtractElement { vector: v, index: idx }, Some(fe_ty))
                                })
                                .collect()
                        }
                        _ => return Err("a cast from a vector narrower than a register to a split one".into()),
                    };
                    if !is_vec(cx, cx.value_ty(bld.f, src[0])) {
                        // Scalarised: lane for lane.
                        out_parts = Some(
                            src.iter().map(|&s| bld.op(Op::Cast { op, flags, fmf, value: s }, Some(te_ty))).collect(),
                        );
                    } else if fe == te || fe == 1 {
                        // Lane for lane: each part on its own.
                        let pt = vec_ty(cx, cx.vector_bits() / te.max(8), te_ty);
                        out_parts = Some(
                            src.iter().map(|&s| bld.op(Op::Cast { op, flags, fmf, value: s }, Some(pt))).collect(),
                        );
                    } else if te == 2 * fe {
                        // Widening: each part's halves.
                        let half = cx.vector_bits() / 2;
                        let half_ty = vec_ty(cx, half / fe, fe_ty);
                        let pt = vec_ty(cx, half / fe, te_ty);
                        let l = (half / fe) as i32;
                        let mut ps = Vec::new();
                        for &s in &src {
                            let pz = poison(cx, cx.value_ty(bld.f, s));
                            let lo = shuffle(&mut bld, cx, s, pz, &(0..l).collect::<Vec<_>>(), half_ty);
                            let hi = shuffle(&mut bld, cx, s, pz, &(l..2 * l).collect::<Vec<_>>(), half_ty);
                            ps.push(bld.op(Op::Cast { op, flags, fmf, value: lo }, Some(pt)));
                            ps.push(bld.op(Op::Cast { op, flags, fmf, value: hi }, Some(pt)));
                        }
                        out_parts = Some(ps);
                    } else if fe == 2 * te {
                        // Narrowing: pairs of parts into one.
                        if src.len() < 2 {
                            return Err("a narrowing of a legal vector to a split one".into());
                        }
                        let vb = cx.vector_bits();
                        let half_ty = vec_ty(cx, vb / fe, te_ty);
                        let pt = vec_ty(cx, vb / te, te_ty);
                        let l = (vb / fe) as i32;
                        let mut ps = Vec::new();
                        for pair in src.chunks(2) {
                            let a = bld.op(Op::Cast { op, flags, fmf, value: pair[0] }, Some(half_ty));
                            let b = bld.op(Op::Cast { op, flags, fmf, value: pair[1] }, Some(half_ty));
                            ps.push(shuffle(&mut bld, cx, a, b, &(0..2 * l).collect::<Vec<_>>(), pt));
                        }
                        if ps.len() == 1 && res_split.is_none() {
                            replace = Some(ps[0]);
                        } else {
                            out_parts = Some(ps);
                        }
                    } else {
                        return Err(format!("a cast of split vectors from {fe} to {te} bits"));
                    }
                }
                Op::ShuffleVector { a, b: bv, mask } => {
                    // Each lane of the result found in the operands' parts:
                    // whole parts reused, splats splatted, other lanes
                    // extracted and inserted one by one.
                    let lanes = crate::target::mask_lanes(cx.m, mask).ok_or("a shuffle mask that is not constant")?;
                    let at = cx.value_ty(bld.f, a);
                    let (alen, elem, _) = vec_info(cx, at).unwrap();
                    let src_of = |v: Value| match v {
                        Value::Local(x) if parts.contains_key(&x) => parts[&x].clone(),
                        v => vec![v],
                    };
                    let (sa, sb) = (src_of(a), src_of(bv));
                    let pla = alen as usize / sa.len();
                    let plb = alen as usize / sb.len();
                    // A lane of the operands: the part holding it, and where.
                    let find = |l: i32| -> Option<(Value, usize)> {
                        if l < 0 {
                            None
                        } else if (l as usize) < alen as usize {
                            Some((sa[l as usize / pla], l as usize % pla))
                        } else {
                            let l = l as usize - alen as usize;
                            Some((sb[l / plb], l % plb))
                        }
                    };
                    let rt = res_ty.unwrap();
                    let (rlen, _, reb) = vec_info(cx, rt).unwrap();
                    let (n, pt) = match res_split {
                        Some(n) => (n, part(cx, rlen, elem, reb)),
                        None => (1, rt),
                    };
                    let opl = rlen as usize / n;
                    let i64t = cx.m.types.int(64);
                    let mut ps = Vec::new();
                    for p in 0..n {
                        let ls = &lanes[p * opl..(p + 1) * opl];
                        let found: Vec<Option<(Value, usize)>> = ls.iter().map(|&l| find(l)).collect();
                        let scalar = |bld: &mut Builder, cx: &mut Ctx, (v, k): (Value, usize)| {
                            if is_vec(cx, cx.value_ty(bld.f, v)) {
                                let idx = cx.int(i64t, k as i64);
                                bld.op(Op::ExtractElement { vector: v, index: idx }, Some(elem))
                            } else {
                                v
                            }
                        };
                        if !is_vec(cx, pt) {
                            ps.push(match found[0] {
                                Some(x) => scalar(&mut bld, cx, x),
                                None => poison(cx, pt),
                            });
                            continue;
                        }
                        let first = found.iter().flatten().next().copied();
                        let Some((v0, k0)) = first else {
                            ps.push(poison(cx, pt));
                            continue;
                        };
                        let v0_ty = cx.value_ty(bld.f, v0);
                        if v0_ty == pt
                            && found.iter().enumerate().all(|(k, x)| x.is_none_or(|(v, j)| v == v0 && j == k))
                        {
                            ps.push(v0);
                        } else if found.iter().all(|x| x.is_none_or(|y| y == (v0, k0))) {
                            let e = scalar(&mut bld, cx, (v0, k0));
                            let pz = poison(cx, pt);
                            let zero = cx.int(i64t, 0);
                            let ins = bld.op(Op::InsertElement { vector: pz, element: e, index: zero }, Some(pt));
                            ps.push(shuffle(&mut bld, cx, ins, pz, &vec![0; opl], pt));
                        } else {
                            let mut acc = poison(cx, pt);
                            for (k, x) in found.iter().enumerate() {
                                if let Some(x) = *x {
                                    let e = scalar(&mut bld, cx, x);
                                    let idx = cx.int(i64t, k as i64);
                                    acc = bld.op(Op::InsertElement { vector: acc, element: e, index: idx }, Some(pt));
                                }
                            }
                            ps.push(acc);
                        }
                    }
                    if res_split.is_some() {
                        out_parts = Some(ps);
                    } else {
                        replace = Some(ps[0]);
                    }
                }
                Op::InsertElement { vector, element, index } => {
                    let n = res_split.unwrap();
                    let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                    let pt = part(cx, vlen, elem, eb);
                    let idx =
                        cx.const_int(index).ok_or("an insertelement into a split vector at a lane not constant")?;
                    let mut vs = parts_of(cx, &parts, bld.f, vector, n, pt)?;
                    let l = (vlen as usize / n) as i64;
                    let i64t = cx.m.types.int(64);
                    let lane = cx.int(i64t, idx % l);
                    let p = (idx / l) as usize;
                    vs[p] = if is_vec(cx, pt) {
                        bld.op(Op::InsertElement { vector: vs[p], element, index: lane }, Some(pt))
                    } else {
                        element
                    };
                    out_parts = Some(vs);
                }
                Op::ExtractElement { vector, index } => {
                    let vt = cx.value_ty(bld.f, vector);
                    let (vlen, elem, eb) = vec_info(cx, vt).ok_or("an extractelement from a split non-vector")?;
                    let idx =
                        cx.const_int(index).ok_or("an extractelement from a split vector at a lane not constant")?;
                    // A mask's parts say how it was split (its lanes have
                    // no width of their own); else its type does.
                    let made = match vector {
                        Value::Local(x) => parts.get(&x).cloned(),
                        _ => None,
                    };
                    let (vs, pt) = match made {
                        Some(vs) if !vs.is_empty() => {
                            let pt = cx.value_ty(bld.f, vs[0]);
                            (vs, pt)
                        }
                        _ => {
                            let n = split_count(cx, vt).ok_or("an extractelement from a mask split in no known way")?;
                            let pt = part(cx, vlen, elem, eb);
                            (parts_of(cx, &parts, bld.f, vector, n, pt)?, pt)
                        }
                    };
                    let n = vs.len();
                    let l = (vlen as usize / n) as i64;
                    let i64t = cx.m.types.int(64);
                    let lane = cx.int(i64t, idx % l);
                    let v = vs[(idx / l) as usize];
                    replace = Some(if is_vec(cx, pt) {
                        bld.op(Op::ExtractElement { vector: v, index: lane }, Some(elem))
                    } else {
                        v
                    });
                }
                Op::Call(call) => {
                    let name = callee_name(cx.m, &call).unwrap_or_default();
                    let args: Vec<Value> = call.args.iter().map(|a| a.value).collect();
                    if let Some(rest) = name.strip_prefix("llvm.vector.reduce.") {
                        // Combine the parts, then reduce one.
                        let opname = rest.split('.').next().unwrap_or("");
                        let vt = cx.value_ty(bld.f, args[0]);
                        // A mask is split as the comparison that made it was.
                        let (vs, pt) = match args[0] {
                            Value::Local(x) if split_count(cx, vt).is_none() && parts.contains_key(&x) => {
                                let vs = parts[&x].clone();
                                let pt = cx.value_ty(bld.f, vs[0]);
                                (vs, pt)
                            }
                            _ => {
                                let n = split_count(cx, vt).ok_or("a reduction of a legal vector")?;
                                let (vlen, elem, eb) = vec_info(cx, vt).unwrap();
                                let pt = part(cx, vlen, elem, eb);
                                (parts_of(cx, &parts, bld.f, args[0], n, pt)?, pt)
                            }
                        };
                        let mut acc = vs[0];
                        for &v in &vs[1..] {
                            acc = combine(&mut bld, cx, opname, acc, v, pt)?;
                        }
                        let r = res_ty.unwrap();
                        let mask_lanes = match cx.m.types.get(pt) {
                            Type::Vector { len, elem, .. } if matches!(cx.m.types.get(*elem), Type::Int(1)) => {
                                Some(*len)
                            }
                            _ => None,
                        };
                        replace = Some(match mask_lanes {
                            // A mask's: as integer lanes, all ones or zeros,
                            // the unsigned maximum (any set) or minimum (all).
                            Some(len) if matches!(opname, "or" | "and") => {
                                let w = (cx.vector_bits() / len).max(8);
                                let e = cx.m.types.int(w);
                                let it = vec_ty(cx, len, e);
                                let wide = bld.op(
                                    Op::Cast {
                                        op: CastOp::SExt,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        value: acc,
                                    },
                                    Some(it),
                                );
                                let red = if opname == "or" { "umax" } else { "umin" };
                                let callee =
                                    declare(cx, &format!("llvm.vector.reduce.{red}.{}", mangle(cx, it)), e, &[it]);
                                let x = call_value(&mut bld, cx, callee, vec![wide], e, it);
                                let zero = Value::Const(cx.m.consts.intern(Constant { ty: e, kind: ConstKind::Zero }));
                                bld.op(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: x, rhs: zero }, Some(r))
                            }
                            _ if is_vec(cx, pt) => {
                                let callee =
                                    declare(cx, &format!("llvm.vector.reduce.{opname}.{}", mangle(cx, pt)), r, &[pt]);
                                call_value(&mut bld, cx, callee, vec![acc], r, pt)
                            }
                            _ => acc,
                        });
                    } else if name.starts_with("llvm.experimental.vector.partial.reduce.add.") {
                        let acc_ty = res_ty.unwrap();
                        if let Some(n) = split_count(cx, acc_ty) {
                            // The accumulator split too: each of the input's
                            // lanes is added to the accumulator's lane it
                            // falls on, counting round.
                            let (alen, elem, eb) = vec_info(cx, acc_ty).unwrap();
                            let pt = part(cx, alen, elem, eb);
                            let mut acc = parts_of(cx, &parts, bld.f, args[0], n, pt)?;
                            let vt = cx.value_ty(bld.f, args[1]);
                            let (vlen, _, veb) = vec_info(cx, vt).ok_or("a partial reduction of a scalar")?;
                            let lanes: Vec<Value> = match split_count(cx, vt) {
                                Some(m) => {
                                    let vpt = part(cx, vlen, elem, veb);
                                    let vs = parts_of(cx, &parts, bld.f, args[1], m, vpt)?;
                                    let i64t = cx.m.types.int(64);
                                    let per = vlen as usize / m;
                                    let mut out = Vec::new();
                                    for v in vs {
                                        if is_vec(cx, cx.value_ty(bld.f, v)) {
                                            for l in 0..per {
                                                let idx = cx.int(i64t, l as i64);
                                                out.push(
                                                    bld.op(Op::ExtractElement { vector: v, index: idx }, Some(elem)),
                                                );
                                            }
                                        } else {
                                            out.push(v);
                                        }
                                    }
                                    out
                                }
                                None => {
                                    return Err("a partial reduction of a legal vector into a split accumulator".into());
                                }
                            };
                            if is_vec(cx, pt) {
                                return Err("a partial reduction into an accumulator split in vectors".into());
                            }
                            for (j, v) in lanes.into_iter().enumerate() {
                                let k = j % n;
                                acc[k] = bld.op(
                                    Op::Binary {
                                        op: BinOp::Add,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        lhs: acc[k],
                                        rhs: v,
                                    },
                                    Some(elem),
                                );
                            }
                            out_parts = Some(acc);
                        } else {
                            let (alen, elem, eb) = vec_info(cx, acc_ty).unwrap();
                            let vt = cx.value_ty(bld.f, args[1]);
                            let vs: Vec<Value> = match split_count(cx, vt) {
                                Some(n) => {
                                    let pt = vec_ty(cx, cx.vector_bits() / eb, elem);
                                    parts_of(cx, &parts, bld.f, args[1], n, pt)?
                                }
                                None => vec![args[1]],
                            };
                            let pt = cx.value_ty(bld.f, vs[0]);
                            let mut s = vs[0];
                            for &v in &vs[1..] {
                                s = bld.op(
                                    Op::Binary {
                                        op: BinOp::Add,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        lhs: s,
                                        rhs: v,
                                    },
                                    Some(pt),
                                );
                            }
                            // Fold halves together down to the accumulator's lanes.
                            let (mut slen, _, _) = vec_info(cx, pt).unwrap();
                            while slen > alen {
                                let half = slen / 2;
                                let ht = vec_ty(cx, half, elem);
                                let pz = poison(cx, cx.value_ty(bld.f, s));
                                let lo = shuffle(&mut bld, cx, s, pz, &(0..half as i32).collect::<Vec<_>>(), ht);
                                let hi =
                                    shuffle(&mut bld, cx, s, pz, &(half as i32..slen as i32).collect::<Vec<_>>(), ht);
                                s = bld.op(
                                    Op::Binary {
                                        op: BinOp::Add,
                                        flags: IntFlags::NONE,
                                        fmf: FastMath::default(),
                                        lhs: lo,
                                        rhs: hi,
                                    },
                                    Some(ht),
                                );
                                slen = half;
                            }
                            replace = Some(bld.op(
                                Op::Binary {
                                    op: BinOp::Add,
                                    flags: IntFlags::NONE,
                                    fmf: FastMath::default(),
                                    lhs: args[0],
                                    rhs: s,
                                },
                                Some(acc_ty),
                            ));
                        }
                    } else if name.starts_with("llvm.") && res_split.is_some() {
                        // An element-wise intrinsic: called for each part,
                        // declared again for the part's type.
                        let n = res_split.unwrap();
                        let (vlen, elem, eb) = vec_info(cx, res_ty.unwrap()).unwrap();
                        let pt = part(cx, vlen, elem, eb);
                        let base = name.rsplit_once('.').map(|(b, _)| b).unwrap_or(&name).to_string();
                        let mut arg_parts = Vec::new();
                        let mut arg_tys = Vec::new();
                        for &a in &args {
                            let at = cx.value_ty(bld.f, a);
                            if split_count(cx, at).is_some() || at == res_ty.unwrap() {
                                arg_parts.push(parts_of(cx, &parts, bld.f, a, n, pt)?);
                                arg_tys.push(pt);
                            } else {
                                arg_parts.push(vec![a; n]);
                                arg_tys.push(at);
                            }
                        }
                        let callee = declare(cx, &format!("{base}.{}", mangle(cx, pt)), pt, &arg_tys);
                        out_parts = Some(
                            (0..n)
                                .map(|p| {
                                    let a: Vec<Value> = arg_parts.iter().map(|ap| ap[p]).collect();
                                    call_value(&mut bld, cx, callee, a, pt, pt)
                                })
                                .collect(),
                        );
                    } else {
                        return Err(format!("a call to {name} with split vectors"));
                    }
                }
                op => return Err(format!("split vectors in {op:?}")),
            }
            // A legal vector made from scalars: inserted lane by lane.
            if let (Some(ps), None, Some(rt)) = (&out_parts, res_split, res_ty)
                && let Some((len, elem, eb)) = vec_info(cx, rt)
                && eb != 1
                && ps.len() == len as usize
                && ps.first().is_some_and(|&p| !is_vec(cx, cx.value_ty(bld.f, p)))
            {
                let i64t = cx.m.types.int(64);
                let mut acc = poison(cx, rt);
                for (k, &p) in ps.iter().enumerate() {
                    let idx = cx.int(i64t, k as i64);
                    let p = if cx.value_ty(bld.f, p) == elem {
                        p
                    } else {
                        return Err("a scalarised lane of another type".into());
                    };
                    acc = bld.op(Op::InsertElement { vector: acc, element: p, index: idx }, Some(rt));
                }
                replace = Some(acc);
                out_parts = None;
            }
            let new = std::mem::take(&mut bld.new);
            if let (Some(ps), Some(r)) = (out_parts, res) {
                parts.insert(r, ps);
            }
            if let (Some(v), Some(r)) = (replace, res) {
                f.replace_uses(Value::Local(r), v);
            }
            let n = new.len();
            f.blocks[blk.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
    // Phis' incoming parts, now that every part is known.
    for (phis, orig) in pending_phis {
        let Op::Phi { incoming, .. } = f.insts[orig.index()].op.clone() else { unreachable!() };
        let pt = f.locals[f.insts[phis[0].index()].result.unwrap().index()].ty;
        for (v, from) in incoming {
            let vs = parts_of(cx, &parts, f, v, phis.len(), pt)?;
            for (p, &phi) in phis.iter().enumerate() {
                if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op {
                    incoming.push((vs[p], from));
                }
            }
        }
    }
    // Phis go first in their blocks.
    for &b in &f.layout.clone() {
        let insts = std::mem::take(&mut f.blocks[b.index()].insts);
        let (phis, rest): (Vec<InstId>, Vec<InstId>) = insts.into_iter().partition(|&i| f.insts[i.index()].op.is_phi());
        f.blocks[b.index()].insts = phis.into_iter().chain(rest).collect();
    }
    expand_lanewise(cx, f)
}

fn call_value(b: &mut Builder, cx: &mut Ctx, callee: Value, args: Vec<Value>, ret: TypeId, _pt: TypeId) -> Value {
    let params: Vec<TypeId> = args.iter().map(|&a| cx.value_ty(b.f, a)).collect();
    let fn_ty = cx.m.types.intern(Type::Function { ret, params, varargs: false });
    let call = Call {
        tail: TailKind::None,
        fmf: FastMath::default(),
        cconv: CallConv::default(),
        ret_attrs: vec![],
        addrspace: None,
        fn_ty,
        callee,
        args: args.into_iter().map(|value| CallArg { value, attrs: vec![] }).collect(),
        fn_attrs: vec![],
        bundles: vec![],
    };
    b.op(Op::Call(Box::new(call)), Some(ret))
}

/// The element-wise operation a reduction applies, on two parts.
fn combine(b: &mut Builder, cx: &mut Ctx, op: &str, x: Value, y: Value, pt: TypeId) -> Result<Value, String> {
    let bin = |o: BinOp| Op::Binary { op: o, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: x, rhs: y };
    Ok(match op {
        "add" => b.op(bin(BinOp::Add), Some(pt)),
        "mul" => b.op(bin(BinOp::Mul), Some(pt)),
        "and" => b.op(bin(BinOp::And), Some(pt)),
        "or" => b.op(bin(BinOp::Or), Some(pt)),
        "xor" => b.op(bin(BinOp::Xor), Some(pt)),
        "smax" | "smin" | "umax" | "umin" if !is_vec(cx, pt) => {
            let pred = match op {
                "smax" => ICmpPred::Sgt,
                "smin" => ICmpPred::Slt,
                "umax" => ICmpPred::Ugt,
                _ => ICmpPred::Ult,
            };
            let i1 = cx.m.types.int(1);
            let c = b.op(Op::ICmp { pred, samesign: false, lhs: x, rhs: y }, Some(i1));
            b.op(Op::Select { fmf: FastMath::default(), cond: c, then_value: x, else_value: y }, Some(pt))
        }
        "smax" | "smin" | "umax" | "umin" => {
            let callee = declare(cx, &format!("llvm.{op}.{}", mangle(cx, pt)), pt, &[pt, pt]);
            call_value(b, cx, callee, vec![x, y], pt, pt)
        }
        other => return Err(format!("reductions by {other} of split vectors are not supported yet")),
    })
}
