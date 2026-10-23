//! Bits moved around and back (`docs/design/combine.md`, "Bit maps", in
//! the code generator's small form): for an integer of up to 64 bits,
//! where each of its bits comes from — a constant, or a bit of a source
//! value — through extensions, truncations, shifts by constants, `and`s
//! and `or`s with constants, and `or`s of values whose bits never meet. A
//! value whose bits are one source's, in place, is that source (extended
//! or truncated); one whose bits are a run of one source's moved down is a
//! shift of it.
//!
//! A field taken out of a bitwise operation (`trunc (lshr (xor %x, %y),
//! 32)`) is the operation of the fields taken out of its operands, where
//! those are each one source's: so values packed together, operated on
//! and taken apart again are operated on as they were.
//!
//! Wide integers split into halves (`wide.rs`) make many of these: a
//! `[4 x u32]` held as an `i128` is packed into halves (`zext`, `shl`, `or`)
//! and its words taken out again (`lshr`, `trunc`), where the words
//! themselves would do.

use epitome_ir::module::*;
use epitome_ir::types::{Type, TypeId};

use crate::prepare::{Ctx, Seq};

/// Where one bit comes from.
#[derive(Clone, Copy, PartialEq, Debug)]
enum Bit {
    Zero,
    One,
    /// Bit `.1` of source `.0`.
    Src(Value, u32),
}

const DEPTH: u32 = 8;

fn int_bits(cx: &Ctx, ty: TypeId) -> Option<u32> {
    match cx.m.types.get(ty) {
        Type::Int(b) if *b <= 64 => Some(*b),
        _ => None,
    }
}

/// The map of `v`, and how many instructions it looked through.
fn map(cx: &Ctx, f: &Function, v: Value, depth: u32, seen: &mut u32) -> Option<Vec<Bit>> {
    let w = int_bits(cx, cx.value_ty(f, v))?;
    let leaf = || (0..w).map(|i| Bit::Src(v, i)).collect::<Vec<_>>();
    if let Some(c) = cx.const_int(v) {
        return Some((0..w).map(|i| if (c >> i) & 1 == 1 { Bit::One } else { Bit::Zero }).collect());
    }
    let Value::Local(l) = v else { return Some(leaf()) };
    let LocalDef::Inst(d) = f.locals[l.index()].def else { return Some(leaf()) };
    if depth == 0 {
        return Some(leaf());
    }
    let sub = |x: Value, seen: &mut u32| map(cx, f, x, depth - 1, seen);
    let r = match &f.insts[d.index()].op {
        Op::Cast { op: CastOp::ZExt, value, .. } => sub(*value, seen).map(|mut m| {
            m.resize(w as usize, Bit::Zero);
            m
        }),
        Op::Cast { op: CastOp::Trunc, value, .. } => sub(*value, seen).map(|m| m[..w as usize].to_vec()),
        Op::Binary { op: BinOp::Shl, lhs, rhs, .. }
            if cx.const_int(*rhs).is_some_and(|c| (0..w as i64).contains(&c)) =>
        {
            let c = cx.const_int(*rhs).unwrap() as usize;
            sub(*lhs, seen).map(|m| (0..w as usize).map(|i| if i < c { Bit::Zero } else { m[i - c] }).collect())
        }
        Op::Binary { op: BinOp::LShr, lhs, rhs, .. }
            if cx.const_int(*rhs).is_some_and(|c| (0..w as i64).contains(&c)) =>
        {
            let c = cx.const_int(*rhs).unwrap() as usize;
            sub(*lhs, seen).map(|m| (0..w as usize).map(|i| m.get(i + c).copied().unwrap_or(Bit::Zero)).collect())
        }
        Op::Binary { op: op @ (BinOp::And | BinOp::Or), lhs, rhs, .. } => {
            let (a, b) = (sub(*lhs, seen)?, sub(*rhs, seen)?);
            // Bit by bit: and with a constant bit, or or of a bit with a
            // zero; anything else is not a map.
            let mut out = Vec::with_capacity(w as usize);
            for (x, y) in a.into_iter().zip(b) {
                out.push(match (op, x, y) {
                    (BinOp::And, Bit::Zero, _) | (BinOp::And, _, Bit::Zero) => Bit::Zero,
                    (BinOp::And, Bit::One, z) | (BinOp::And, z, Bit::One) => z,
                    (BinOp::Or, Bit::One, _) | (BinOp::Or, _, Bit::One) => Bit::One,
                    (BinOp::Or, Bit::Zero, z) | (BinOp::Or, z, Bit::Zero) => z,
                    // The same bit of the same source, both ways.
                    (_, p, q) if p == q => p,
                    _ => return Some(leaf()),
                });
            }
            Some(out)
        }
        _ => return Some(leaf()),
    };
    *seen += 1;
    r.or_else(|| Some(leaf()))
}

/// What a map is, if it is one of the shapes made simply: one source's
/// bits from `lo` on, for `len` bits, at bit 0, zeros above.
fn field(m: &[Bit]) -> Option<(Value, u32, u32)> {
    let Bit::Src(s, lo) = m[0] else { return None };
    let len = m.iter().take_while(|b| matches!(b, Bit::Src(x, _) if *x == s)).count() as u32;
    for (i, b) in m.iter().enumerate().take(len as usize) {
        if *b != Bit::Src(s, lo + i as u32) {
            return None;
        }
    }
    if m[len as usize..].iter().all(|b| *b == Bit::Zero) { Some((s, lo, len)) } else { None }
}

/// For a truncation `i` (perhaps of a shift right by a constant) of a
/// bitwise operation: the operation, its operands, and the field taken (its
/// low bit, its width).
fn extraction(cx: &Ctx, f: &Function, i: InstId) -> Option<(BinOp, Value, Value, u32, u32)> {
    let Op::Cast { op: CastOp::Trunc, value, .. } = f.insts[i.index()].op else { return None };
    let w = int_bits(cx, f.locals[f.insts[i.index()].result?.index()].ty)?;
    let def = |v: Value| match v {
        Value::Local(l) => match f.locals[l.index()].def {
            LocalDef::Inst(d) => Some(&f.insts[d.index()].op),
            _ => None,
        },
        _ => None,
    };
    let (mut u, mut lo) = (value, 0);
    if let Some(Op::Binary { op: BinOp::LShr, lhs, rhs, .. }) = def(u)
        && let Some(c) = cx.const_int(*rhs)
    {
        u = *lhs;
        lo = c as u32;
    }
    match def(u)? {
        Op::Binary { op: op @ (BinOp::Xor | BinOp::And | BinOp::Or), lhs, rhs, .. } => Some((*op, *lhs, *rhs, lo, w)),
        _ => None,
    }
}

/// The field `[lo, lo + w)` of `v`'s map, if it is one source's bits, in
/// order: the source and the field's place in it.
fn field_of(cx: &Ctx, f: &Function, v: Value, lo: u32, w: u32) -> Option<(Value, u32)> {
    let mut seen = 0;
    let m = map(cx, f, v, DEPTH, &mut seen)?;
    let part = m.get(lo as usize..(lo + w) as usize)?;
    let Bit::Src(s, at) = part[0] else { return None };
    for (k, b) in part.iter().enumerate() {
        if *b != Bit::Src(s, at + k as u32) {
            return None;
        }
    }
    Some((s, at))
}

/// Source `s`'s bits `[at, at + w)`, as an integer of type `ty` (`w` bits).
fn take(cx: &mut Ctx, sq: &mut Seq, s: Value, at: u32, ty: TypeId) -> Value {
    let sty = cx.value_ty(sq.f, s);
    let mut v = s;
    if at > 0 {
        let c = cx.int(sty, i64::from(at));
        v = sq.bin(BinOp::LShr, v, c, sty);
    }
    if sty != ty { sq.cast(CastOp::Trunc, v, ty) } else { v }
}

pub fn simplify(cx: &mut Ctx, f: &mut Function) {
    narrow_extractions(cx, f);
    let blocks: Vec<(BlockId, Vec<InstId>)> =
        f.layout.iter().map(|&b| (b, f.blocks[b.index()].insts.clone())).collect();
    for (b, insts) in blocks {
        for i in insts {
            let Some(r) = f.insts[i.index()].result else { continue };
            let ty = f.locals[r.index()].ty;
            let Some(w) = int_bits(cx, ty) else { continue };
            if !matches!(
                f.insts[i.index()].op,
                Op::Cast { op: CastOp::Trunc | CastOp::ZExt, .. }
                    | Op::Binary { op: BinOp::Shl | BinOp::LShr | BinOp::And | BinOp::Or, .. }
            ) {
                continue;
            }
            let mut seen = 0;
            let Some(m) = map(cx, f, Value::Local(r), DEPTH, &mut seen) else { continue };
            let Some((s, lo, len)) = field(&m) else { continue };
            if s == Value::Local(r) {
                continue;
            }
            let Some(sw) = int_bits(cx, cx.value_ty(f, s)) else { continue };
            // The new: a shift (if not in place), and a truncation or an
            // extension (or a mask, for a field narrower than both).
            let shift = lo > 0;
            let fits = lo + len == sw || len == w;
            let cost = u32::from(shift) + u32::from(sw != w) + u32::from(!fits);
            if cost >= seen {
                continue;
            }
            let k = f.blocks[b.index()].insts.iter().position(|&x| x == i).unwrap();
            let mut sq = Seq { f, new: Vec::new() };
            let sty = cx.value_ty(sq.f, s);
            let mut v = s;
            if shift {
                let c = cx.int(sty, i64::from(lo));
                v = sq.bin(BinOp::LShr, v, c, sty);
            }
            if !fits {
                // Bits of the source above the field (it is narrower than
                // both): masked off.
                let mask = cx.int(sty, ((1u128 << len) - 1) as i64);
                v = sq.bin(BinOp::And, v, mask, sty);
            }
            if sw > w {
                v = sq.cast(CastOp::Trunc, v, ty);
            } else if sw < w {
                v = sq.cast(CastOp::ZExt, v, ty);
            }
            let new = std::mem::take(&mut sq.new);
            f.blocks[b.index()].insts.splice(k..k, new);
            f.replace_uses(Value::Local(r), v);
        }
    }
}

/// Fields taken out of bitwise operations whose operands' fields are each
/// one source's: the operation of those (see the module's comment).
fn narrow_extractions(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<(BlockId, Vec<InstId>)> =
        f.layout.iter().map(|&b| (b, f.blocks[b.index()].insts.clone())).collect();
    for (b, insts) in blocks {
        for i in insts {
            let Some((op, x, y, lo, w)) = extraction(cx, f, i) else { continue };
            let (Some((sx, ax)), Some((sy, ay))) = (field_of(cx, f, x, lo, w), field_of(cx, f, y, lo, w)) else {
                continue;
            };
            let r = f.insts[i.index()].result.unwrap();
            let ty = f.locals[r.index()].ty;
            if !matches!(cx.m.types.get(cx.value_ty(f, sx)), Type::Int(_))
                || !matches!(cx.m.types.get(cx.value_ty(f, sy)), Type::Int(_))
            {
                continue;
            }
            let k = f.blocks[b.index()].insts.iter().position(|&z| z == i).unwrap();
            let mut sq = Seq { f, new: Vec::new() };
            let a = take(cx, &mut sq, sx, ax, ty);
            let c = take(cx, &mut sq, sy, ay, ty);
            let v = sq.bin(op, a, c, ty);
            let new = std::mem::take(&mut sq.new);
            f.blocks[b.index()].insts.splice(k..k, new);
            f.replace_uses(Value::Local(r), v);
        }
    }
}
