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

/// The most instructions one map looks through.
const BUDGET: u32 = 32;

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
    // Deep enough, or looked through enough already (an `and` or `or` of
    // two values looks through both, so a chain of them would take time
    // doubling with the depth).
    if depth == 0 || *seen >= BUDGET {
        return Some(leaf());
    }
    let sub = |x: Value, seen: &mut u32| map(cx, f, x, depth - 1, seen);
    // Counted on the way in, for the budget (and taken back for an
    // instruction not looked through).
    *seen += 1;
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
                    _ => {
                        *seen -= 1;
                        return Some(leaf());
                    }
                });
            }
            Some(out)
        }
        _ => {
            *seen -= 1;
            return Some(leaf());
        }
    };
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
    split_packed(cx, f);
    // Fields simplified make extractions of operations (a wide shift's
    // halves, `trunc (or (lshr %lo, 32), (shl %hi, 32))`, are `trunc (lshr
    // %lo, 32)`), which narrowed make fields again.
    for _ in 0..2 {
        narrow_extractions(cx, f);
        fields(cx, f);
    }
}

/// Values that are one source's field: that field taken out simply.
fn fields(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<Vec<InstId>> = f.layout.iter().map(|&b| f.blocks[b.index()].insts.clone()).collect();
    // Made before each instruction, and what each replaced value is.
    let mut before: std::collections::HashMap<InstId, Vec<InstId>> = Default::default();
    let mut repl: std::collections::HashMap<LocalId, Value> = Default::default();
    for insts in blocks {
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
            before.entry(i).or_default().extend(new);
            repl.insert(r, v);
        }
    }
    insert_before(f, &before);
    f.replace_many(&repl);
}

/// Instructions put before others (`before`), in one pass over each block.
fn insert_before(f: &mut Function, before: &std::collections::HashMap<InstId, Vec<InstId>>) {
    if before.is_empty() {
        return;
    }
    for b in f.layout.clone() {
        let old = std::mem::take(&mut f.blocks[b.index()].insts);
        let mut out = Vec::with_capacity(old.len());
        for i in old {
            if let Some(new) = before.get(&i) {
                out.extend(new.iter().copied());
            }
            out.push(i);
        }
        f.blocks[b.index()].insts = out;
    }
}

/// Fields taken out of bitwise operations whose operands' fields are each
/// one source's: the operation of those (see the module's comment).
fn narrow_extractions(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<Vec<InstId>> = f.layout.iter().map(|&b| f.blocks[b.index()].insts.clone()).collect();
    let mut before: std::collections::HashMap<InstId, Vec<InstId>> = Default::default();
    let mut repl: std::collections::HashMap<LocalId, Value> = Default::default();
    for insts in blocks {
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
            let mut sq = Seq { f, new: Vec::new() };
            let a = take(cx, &mut sq, sx, ax, ty);
            let c = take(cx, &mut sq, sy, ay, ty);
            let v = sq.bin(op, a, c, ty);
            let new = std::mem::take(&mut sq.new);
            before.entry(i).or_default().extend(new);
            repl.insert(r, v);
        }
    }
    insert_before(f, &before);
    f.replace_many(&repl);
}

/// The `i64` phis and bitwise operations whose operands are packed halves,
/// constants or each other, and whose every use is another of them or
/// takes a half out (`trunc` to `i32`, perhaps after `lshr` by 32): each
/// becomes two, on the halves, and the halves taken out are those.
fn split_packed(cx: &mut Ctx, f: &mut Function) {
    let i64t = cx.m.types.int(64);
    let i32t = cx.m.types.int(32);
    let mut users: std::collections::HashMap<LocalId, Vec<InstId>> = Default::default();
    for i in f.insts_in_order() {
        f.insts[i.index()].op.for_each_value(|v| {
            if let Value::Local(l) = v {
                users.entry(*l).or_default().push(i);
            }
        });
    }
    let def = |f: &Function, l: LocalId| match f.locals[l.index()].def {
        LocalDef::Inst(d) => Some(d),
        _ => None,
    };
    let mut members: std::collections::HashSet<LocalId> = std::collections::HashSet::new();
    for i in f.insts_in_order() {
        let Some(r) = f.insts[i.index()].result else { continue };
        if f.locals[r.index()].ty == i64t
            && matches!(
                f.insts[i.index()].op,
                Op::Phi { .. } | Op::Binary { op: BinOp::And | BinOp::Or | BinOp::Xor, .. }
            )
        {
            members.insert(r);
        }
    }
    if members.is_empty() {
        return;
    }
    // Whether an operand is two halves packed together: each an `i32`
    // value's bits, or a half of a value being split.
    let packed = |cx: &Ctx, f: &Function, members: &std::collections::HashSet<LocalId>, v: Value| -> bool {
        let mut seen = 0;
        let Some(m) = map(cx, f, v, DEPTH, &mut seen) else { return false };
        m.len() == 64
            && (0..2).all(|h| {
                let part = &m[32 * h..32 * h + 32];
                let Bit::Src(src, at) = part[0] else { return false };
                part.iter().enumerate().all(|(k, b)| *b == Bit::Src(src, at + k as u32))
                    && match src {
                        _ if at == 0 && cx.value_ty(f, src) == i32t => true,
                        Value::Local(l) => members.contains(&l) && at % 32 == 0,
                        _ => false,
                    }
            })
    };
    let operand_ok = |cx: &Ctx, f: &Function, members: &std::collections::HashSet<LocalId>, v: Value| match v {
        Value::Local(l) if members.contains(&l) => true,
        _ if cx.const_int(v).is_some() => true,
        _ => packed(cx, f, members, v),
    };
    // A use that takes a half out: a truncation to i32, or a shift down by
    // 32 that only truncations to i32 use.
    let trunc32 = |f: &Function, u: InstId| {
        matches!(f.insts[u.index()].op, Op::Cast { op: CastOp::Trunc, .. })
            && f.insts[u.index()].result.is_some_and(|r| f.locals[r.index()].ty == i32t)
    };
    // Each round takes out the members that cannot be split; one that has
    // not settled in a few rounds is a long chain of other operations, not
    // packed halves (and would take time in the square of its length), and
    // nothing is split.
    for round in 0.. {
        if round == 4 {
            return;
        }
        let mut out = Vec::new();
        for &l in &members {
            let d = def(f, l).unwrap();
            let ok_ops = match &f.insts[d.index()].op {
                Op::Phi { incoming, .. } => incoming.iter().all(|&(v, _)| operand_ok(cx, f, &members, v)),
                Op::Binary { lhs, rhs, .. } => operand_ok(cx, f, &members, *lhs) && operand_ok(cx, f, &members, *rhs),
                _ => false,
            };
            let ok_uses = users.get(&l).is_none_or(|us| {
                us.iter().all(|&u| {
                    f.insts[u.index()].result.is_some_and(|r| members.contains(&r))
                        || trunc32(f, u)
                        || matches!(f.insts[u.index()].op, Op::Binary { op: BinOp::LShr, lhs: Value::Local(x), rhs, .. }
                            if x == l && cx.const_int(rhs) == Some(32))
                            && f.insts[u.index()]
                                .result
                                .is_some_and(|r| users.get(&r).is_some_and(|ts| ts.iter().all(|&t| trunc32(f, t))))
                })
            });
            if !ok_ops || !ok_uses {
                out.push(l);
            }
        }
        if out.is_empty() {
            break;
        }
        for l in out {
            members.remove(&l);
        }
    }
    if members.is_empty() || !epitome_ir::chop::allow(|| format!("split {} packed values into halves", members.len())) {
        return;
    }
    // The halves of each member: new phis first (at their blocks' starts),
    // then the operations in order, each after its original.
    let mut parts: std::collections::HashMap<LocalId, [Value; 2]> = Default::default();
    let blocks = f.inst_blocks();
    let mut order: Vec<InstId> =
        f.insts_in_order().filter(|&i| f.insts[i.index()].result.is_some_and(|r| members.contains(&r))).collect();
    order.sort_by_key(|&i| !matches!(f.insts[i.index()].op, Op::Phi { .. }));
    let mut new_phis: Vec<(LocalId, [InstId; 2])> = Vec::new();
    let mut after: std::collections::HashMap<InstId, Vec<InstId>> = Default::default();
    for &i in &order {
        let r = f.insts[i.index()].result.unwrap();
        match f.insts[i.index()].op.clone() {
            Op::Phi { fmf, .. } => {
                let ps = [0, 1].map(|_| f.add_inst(Op::Phi { fmf, incoming: vec![] }, Some((None, i32t))));
                let b = blocks[i.index()].unwrap();
                f.blocks[b.index()].insts.splice(0..0, ps);
                parts.insert(r, [f.result(ps[0]), f.result(ps[1])]);
                new_phis.push((r, ps));
            }
            Op::Binary { op, lhs, rhs, .. } => {
                let (a, c) = (half_parts(cx, f, &members, &parts, lhs), half_parts(cx, f, &members, &parts, rhs));
                let mut made = Vec::new();
                let mut vs = [lhs; 2];
                for h in 0..2 {
                    let x = f.add_inst(
                        Op::Binary { op, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: a[h], rhs: c[h] },
                        Some((None, i32t)),
                    );
                    made.push(x);
                    vs[h] = f.result(x);
                }
                after.insert(i, made);
                parts.insert(r, vs);
            }
            _ => unreachable!(),
        }
    }
    for (r, ps) in new_phis {
        let d = def(f, r).unwrap();
        let Op::Phi { incoming, .. } = f.insts[d.index()].op.clone() else { unreachable!() };
        for (v, pred) in incoming {
            let hs = half_parts(cx, f, &members, &parts, v);
            for h in 0..2 {
                if let Op::Phi { incoming, .. } = &mut f.insts[ps[h].index()].op {
                    incoming.push((hs[h], pred));
                }
            }
        }
    }
    for b in f.layout.clone() {
        let old = std::mem::take(&mut f.blocks[b.index()].insts);
        let mut out = Vec::with_capacity(old.len());
        for i in old {
            out.push(i);
            if let Some(m) = after.get(&i) {
                out.extend(m.iter().copied());
            }
        }
        f.blocks[b.index()].insts = out;
    }
    // The halves taken out are the halves; then the originals, and what
    // took the halves out, go (they use each other round loops, so would
    // not go as unused).
    let mut dead: std::collections::HashSet<InstId> = std::collections::HashSet::new();
    for (&l, hs) in &parts {
        dead.insert(def(f, l).unwrap());
        for &u in users.get(&l).map(|v| v.as_slice()).unwrap_or(&[]) {
            let Some(ur) = f.insts[u.index()].result else { continue };
            if members.contains(&ur) {
                continue;
            }
            dead.insert(u);
            if trunc32(f, u) {
                f.replace_uses(Value::Local(ur), hs[0]);
            } else {
                for &t in users.get(&ur).map(|v| v.as_slice()).unwrap_or(&[]) {
                    if let Some(tr) = f.insts[t.index()].result {
                        f.replace_uses(Value::Local(tr), hs[1]);
                    }
                    dead.insert(t);
                }
            }
        }
    }
    for b in f.layout.clone() {
        f.blocks[b.index()].insts.retain(|i| !dead.contains(i));
    }
}

/// The two halves of an operand of a value being split.
fn half_parts(
    cx: &mut Ctx,
    f: &Function,
    members: &std::collections::HashSet<LocalId>,
    parts: &std::collections::HashMap<LocalId, [Value; 2]>,
    v: Value,
) -> [Value; 2] {
    let i32t = cx.m.types.int(32);
    if let Value::Local(l) = v
        && members.contains(&l)
    {
        return parts[&l];
    }
    if let Some(c) = cx.const_int(v) {
        return [cx.int(i32t, i64::from(c as u32 as i32)), cx.int(i32t, i64::from((c >> 32) as u32 as i32))];
    }
    let mut seen = 0;
    let m = map(cx, f, v, DEPTH, &mut seen).expect("a packed operand");
    [0, 1].map(|h| match m[32 * h] {
        Bit::Src(Value::Local(l), at) if members.contains(&l) => parts[&l][(at / 32) as usize],
        Bit::Src(src, _) => src,
        _ => unreachable!("a packed operand"),
    })
}
