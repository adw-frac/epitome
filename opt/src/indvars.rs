//! Induction variables and trip counts, for loops that test at the bottom
//! (see `rotate`).
//!
//! An *induction variable* is a header phi `i = phi [start, preheader],
//! [i.next, latch]` with `i.next = add i, step` for a constant step. When
//! the latch's branch compares `i.next` (or `i`) with a value that does not
//! change in the loop, the number of iterations, the *trip count*, can be
//! worked out, and the loop rewritten in the forms later passes rely on:
//!
//! - **An exact exit test.** With a step of 1 that cannot wrap (`nsw` for
//!   a signed comparison, `nuw` for unsigned) and a guard proving the loop
//!   only starts when `start < bound`, the counter reaches `bound` exactly,
//!   so `i.next < bound` is `i.next != bound`. The same holds counting down
//!   by 1 with `>`. The trip count is `bound - start`.
//! - **Exit values.** The exit is taken exactly when `i.next == bound`, so
//!   an exit phi that takes `i.next` along the latch's exit edge takes
//!   `bound` instead, and no longer needs the loop to compute it.
//! - **Wider counters.** A counter narrower than 64 bits whose `nsw`
//!   increment cannot overflow equals the sign extension of a 64-bit
//!   counter with the same start and step. Each `sext` of it in the loop is
//!   replaced by a 64-bit twin, so addressing needs no `sext` per iteration.
//!   If the narrow counter then only feeds its own increment and the exit
//!   test, the test moves to the twin and the narrow counter goes.
//!
//! The guard is the conditional branch rotation puts in front of the loop.
//! When start and bound are constants, the comparison is checked directly.

use draconian_ir::apint::ApInt;
use draconian_ir::edit::Names;
use draconian_ir::module::*;
use draconian_ir::types::{Type, TypeId};

use crate::combine::eval::{self, IntConst};
use crate::ctx::Shared;
use crate::loops::{self, Loop};

#[derive(Default, Debug, Clone)]
pub struct Stats {
    /// Loops whose trip count is known, with it, for remarks.
    pub trip_counts: Vec<(String, String)>,
    pub exact_exits: usize,
    pub exit_values: usize,
    pub widened: usize,
}

impl Stats {
    pub fn changed(&self) -> bool {
        self.exact_exits + self.exit_values + self.widened > 0
    }
}

/// An induction variable of a loop.
struct Iv {
    phi: InstId,
    next: InstId,
    start: Value,
    step: i64,
    flags: IntFlags,
    ty: TypeId,
    bits: u32,
}

/// The loop's bottom test, in terms of the counter.
struct Exit {
    branch: InstId,
    cmp: InstId,
    /// The predicate under which the loop goes round again, with the
    /// counter on the left.
    pred: ICmpPred,
    /// True if the test compares `i.next`, false for `i`.
    on_next: bool,
    bound: Value,
    /// Whether the branch goes round again when the comparison is true.
    repeat_on_true: bool,
    exit: BlockId,
}

fn inverse(p: ICmpPred) -> ICmpPred {
    use ICmpPred::*;
    match p {
        Eq => Ne,
        Ne => Eq,
        Ugt => Ule,
        Uge => Ult,
        Ult => Uge,
        Ule => Ugt,
        Sgt => Sle,
        Sge => Slt,
        Slt => Sge,
        Sle => Sgt,
    }
}

pub fn run(sh: &Shared, f: &mut Function) -> Stats {
    let mut stats = Stats::default();
    if !f.has_body {
        return stats;
    }
    let mut names = Names::new(f);
    for l in loops::find(f) {
        simplify_loop(sh, f, &mut names, &l, &mut stats);
    }
    stats
}

fn int_of(sh: &Shared, v: Value) -> Option<IntConst> {
    let Value::Const(c) = v else { return None };
    eval::int_const(sh.consts(), sh.types(), c)
}

fn invariant(f: &Function, l: &Loop, v: Value) -> bool {
    match v {
        Value::Const(_) => true,
        Value::Local(x) => match f.locals[x.index()].def {
            LocalDef::Param(_) => true,
            LocalDef::Inst(d) => !l.blocks.iter().any(|b| f.blocks[b.index()].insts.contains(&d)),
            _ => false,
        },
        Value::Metadata(_) => false,
    }
}

fn def_inst(f: &Function, v: Value) -> Option<InstId> {
    match v {
        Value::Local(x) => match f.locals[x.index()].def {
            LocalDef::Inst(d) => Some(d),
            _ => None,
        },
        _ => None,
    }
}

fn simplify_loop(sh: &Shared, f: &mut Function, names: &mut Names, l: &Loop, stats: &mut Stats) {
    let h = l.header;
    let [latch] = l.latches[..] else { return };
    let preds = f.predecessors();
    let outside: Vec<BlockId> = preds[h.index()].iter().copied().filter(|p| !l.contains(*p)).collect();
    let [pre] = outside[..] else { return };

    // Induction variables.
    let mut ivs: Vec<Iv> = Vec::new();
    for &p in f.blocks[h.index()].insts.iter().take_while(|&&i| f.insts[i.index()].op.is_phi()) {
        let Op::Phi { incoming, .. } = &f.insts[p.index()].op else { continue };
        if incoming.len() != 2 {
            continue;
        }
        let start = incoming.iter().find(|(_, b)| *b == pre).map(|(v, _)| *v);
        let next = incoming.iter().find(|(_, b)| *b == latch).map(|(v, _)| *v);
        let (Some(start), Some(next)) = (start, next) else { continue };
        let Some(n) = def_inst(f, next) else { continue };
        let me = f.result(p);
        let Op::Binary { op: BinOp::Add, flags, lhs, rhs, .. } = f.insts[n.index()].op else { continue };
        let step_value = if lhs == me {
            rhs
        } else if rhs == me {
            lhs
        } else {
            continue;
        };
        let Some(step) = int_of(sh, step_value) else { continue };
        let ty = f.locals[f.insts[p.index()].result.unwrap().index()].ty;
        let Type::Int(bits) = *sh.types().get(ty) else { continue };
        ivs.push(Iv { phi: p, next: n, start, step: eval::sext(step.value, step.bits), flags, ty, bits });
    }
    if ivs.is_empty() {
        return;
    }

    // The bottom test.
    let Some(branch) = f.terminator(latch) else { return };
    let Op::CondBr { cond, then_dest, else_dest } = f.insts[branch.index()].op else { return };
    let (repeat_on_true, exit) = if then_dest == h && !l.contains(else_dest) {
        (true, else_dest)
    } else if else_dest == h && !l.contains(then_dest) {
        (false, then_dest)
    } else {
        return;
    };
    let Some(cmp) = def_inst(f, cond) else { return };
    let Op::ICmp { pred, lhs, rhs, .. } = f.insts[cmp.index()].op else { return };
    let header_name = f.block_name(h).map(|n| format!("%{n}")).unwrap_or_else(|| "a loop".into());

    for iv in &ivs {
        let (phi_v, next_v) = (f.result(iv.phi), f.result(iv.next));
        let counter = |v: Value| v == phi_v || v == next_v;
        let (pred, counter_side, bound) = if counter(lhs) && invariant(f, l, rhs) {
            (pred, lhs, rhs)
        } else if counter(rhs) && invariant(f, l, lhs) {
            (eval::swapped(pred), rhs, lhs)
        } else {
            continue;
        };
        let repeat_pred = if repeat_on_true { pred } else { inverse(pred) };
        let e = Exit { branch, cmp, pred: repeat_pred, on_next: counter_side == next_v, bound, repeat_on_true, exit };
        if let Some(count) = trip_count(sh, f, iv, &e) {
            stats.trip_counts.push((header_name.clone(), count));
        }
        if exact_exit(sh, f, pre, h, iv, &e) {
            stats.exact_exits += 1;
            stats.exit_values += exit_values(f, latch, iv, &e);
        }
        stats.widened += widen(sh, f, names, l, pre, latch, iv, &e);
        // One counter per loop is enough: the test is now in its terms.
        return;
    }
}

/// The trip count as text, for remarks: a number when start and bound are
/// constants, otherwise `bound - start`. A test of `i` rather than `i.next`
/// is the same as a test of `i.next` against `bound + step`, when it is
/// `!=`: the loop ends after the iteration where `i` reaches `bound`.
fn trip_count(sh: &Shared, f: &Function, iv: &Iv, e: &Exit) -> Option<String> {
    if iv.step.abs() != 1 || (!e.on_next && e.pred != ICmpPred::Ne) {
        return None;
    }
    let counts_up = iv.step == 1 && matches!(e.pred, ICmpPred::Slt | ICmpPred::Ult | ICmpPred::Ne);
    let counts_down = iv.step == -1 && matches!(e.pred, ICmpPred::Sgt | ICmpPred::Ugt | ICmpPred::Ne);
    if !counts_up && !counts_down {
        return None;
    }
    let constant = |v: Value| int_of(sh, v).map(|k| eval::sext(k.value, k.bits));
    let name = |v: Value| match v {
        Value::Local(x) => f.locals[x.index()].name.clone().map(|n| format!("%{n}")),
        _ => None,
    };
    // The bound `i.next` is tested against, as a constant if it is one,
    // and how far it is from the bound written in the test.
    let shift = if e.on_next { 0 } else { iv.step };
    let (start, bound) = (constant(iv.start), constant(e.bound).map(|b| b + shift));
    // The count is `hi - lo`, plus `extra` when the bound was not folded.
    let ((hi, hi_k), (lo, lo_k)) =
        if counts_up { ((e.bound, bound), (iv.start, start)) } else { ((iv.start, start), (e.bound, bound)) };
    let extra = if bound.is_none() { shift.abs() } else { 0 };
    // Values without names are left out of remarks.
    let text = |v: Value, k: Option<i64>| k.map(|k| k.to_string()).or_else(|| name(v));
    match (hi_k, lo_k) {
        (Some(h), Some(l)) => (h - l > 0).then(|| (h - l).to_string()),
        (_, Some(0)) if extra == 0 => text(hi, hi_k),
        _ if extra == 0 => Some(format!("{} - {}", text(hi, hi_k)?, text(lo, lo_k)?)),
        _ => Some(format!("{} - {} + 1", text(hi, hi_k)?, text(lo, lo_k)?)),
    }
}

/// True if the loop only starts when `start pred bound` holds: by
/// constants, or by the guard branch into the preheader side.
fn starts_inside(sh: &Shared, f: &Function, pre: BlockId, h: BlockId, iv: &Iv, pred: ICmpPred, bound: Value) -> bool {
    if let (Some(s), Some(b)) = (int_of(sh, iv.start), int_of(sh, bound)) {
        return eval::fold_icmp(pred, s.value, b.value, s.bits);
    }
    // The guard: `pre` branches into the loop only when the comparison holds.
    let Some(t) = f.terminator(pre) else { return false };
    let Op::CondBr { cond, then_dest, else_dest } = f.insts[t.index()].op else { return false };
    let into_loop_on_true = then_dest == h;
    if !into_loop_on_true && else_dest != h {
        return false;
    }
    let Some(c) = def_inst(f, cond) else { return false };
    let Op::ICmp { pred: gp, lhs, rhs, .. } = f.insts[c.index()].op else { return false };
    let (gp, a, b) = if lhs == iv.start { (gp, lhs, rhs) } else { (eval::swapped(gp), rhs, lhs) };
    let gp = if into_loop_on_true { gp } else { inverse(gp) };
    gp == pred && a == iv.start && b == bound
}

/// Rewrites `i.next < bound` (and its relatives) as `i.next != bound` when
/// the counter must reach `bound` exactly. Returns true if it did, or if the
/// test was already exact.
fn exact_exit(sh: &Shared, f: &mut Function, pre: BlockId, h: BlockId, iv: &Iv, e: &Exit) -> bool {
    if !e.on_next {
        return false;
    }
    if e.pred == ICmpPred::Ne && iv.step.abs() == 1 {
        return true;
    }
    let ok = match (iv.step, e.pred) {
        (1, ICmpPred::Slt) | (-1, ICmpPred::Sgt) => iv.flags.contains(IntFlags::NSW),
        (1, ICmpPred::Ult) => iv.flags.contains(IntFlags::NUW),
        _ => false,
    };
    if !ok || !starts_inside(sh, f, pre, h, iv, e.pred, e.bound) {
        return false;
    }
    let next = f.result(iv.next);
    let pred = if e.repeat_on_true { ICmpPred::Ne } else { ICmpPred::Eq };
    f.insts[e.cmp.index()].op = Op::ICmp { pred, samesign: false, lhs: next, rhs: e.bound };
    let _ = e.branch;
    true
}

/// With an exact exit, the counter leaves the loop equal to `bound`: exit
/// phis taking `i.next` from the latch take `bound`. Returns how many.
fn exit_values(f: &mut Function, latch: BlockId, iv: &Iv, e: &Exit) -> usize {
    let next = f.result(iv.next);
    let mut n = 0;
    let exit_phis: Vec<InstId> =
        f.blocks[e.exit.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect();
    for p in exit_phis {
        if let Op::Phi { incoming, .. } = &mut f.insts[p.index()].op {
            for (v, b) in incoming.iter_mut() {
                if *b == latch && *v == next {
                    *v = e.bound;
                    n += 1;
                }
            }
        }
    }
    n
}

/// Replaces `sext` of a narrow counter with a 64-bit counter. Returns 1 if
/// it did.
#[allow(clippy::too_many_arguments)]
fn widen(
    sh: &Shared,
    f: &mut Function,
    names: &mut Names,
    l: &Loop,
    pre: BlockId,
    latch: BlockId,
    iv: &Iv,
    e: &Exit,
) -> usize {
    if iv.bits >= 64 || !iv.flags.contains(IntFlags::NSW) {
        return 0;
    }
    let (phi_v, next_v) = (f.result(iv.phi), f.result(iv.next));
    let i64t = sh.intern_type(Type::Int(64));
    // The `sext`s to i64 of the counter, inside the loop.
    let mut sexts: Vec<(InstId, bool)> = Vec::new();
    for &b in &l.blocks {
        for &i in &f.blocks[b.index()].insts {
            if let Op::Cast { op: CastOp::SExt, value, .. } = f.insts[i.index()].op
                && (value == phi_v || value == next_v)
                && f.insts[i.index()].result.is_some_and(|r| f.locals[r.index()].ty == i64t)
            {
                sexts.push((i, value == next_v));
            }
        }
    }
    if sexts.is_empty() {
        return 0;
    }
    let h = l.header;
    // The start, extended in the preheader (or as a constant).
    let start64 = match int_of(sh, iv.start) {
        Some(k) => int64(sh, i64t, eval::sext(k.value, k.bits)),
        None => {
            let name = Some(names.fresh("wide.start"));
            let op = Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: iv.start };
            let c = f.add_inst(op, Some((name, i64t)));
            let at = f.blocks[pre.index()].insts.len() - 1;
            f.blocks[pre.index()].insts.insert(at, c);
            f.result(c)
        }
    };
    let phi_name = f.locals[f.insts[iv.phi.index()].result.unwrap().index()].name.clone();
    let wide_name = Some(names.fresh(&format!("{}.wide", phi_name.as_deref().unwrap_or("iv"))));
    let wide = f.add_inst(Op::Phi { fmf: FastMath::default(), incoming: vec![] }, Some((wide_name, i64t)));
    f.blocks[h.index()].insts.insert(0, wide);
    let wide_v = f.result(wide);
    let next_name = Some(names.fresh(&format!("{}.wide.next", phi_name.as_deref().unwrap_or("iv"))));
    let step = int64(sh, i64t, iv.step);
    let wide_next = f.add_inst(
        Op::Binary { op: BinOp::Add, flags: IntFlags::NSW, fmf: FastMath::default(), lhs: wide_v, rhs: step },
        Some((next_name, i64t)),
    );
    let block_of_next = f.inst_blocks()[iv.next.index()].unwrap();
    let at = f.blocks[block_of_next.index()].insts.iter().position(|&x| x == iv.next).unwrap();
    f.blocks[block_of_next.index()].insts.insert(at + 1, wide_next);
    let wide_next_v = f.result(wide_next);
    if let Op::Phi { incoming, .. } = &mut f.insts[wide.index()].op {
        incoming.push((start64, pre));
        incoming.push((wide_next_v, latch));
    }
    for (i, of_next) in sexts {
        let r = f.insts[i.index()].result.unwrap();
        f.replace_uses(Value::Local(r), if of_next { wide_next_v } else { wide_v });
        crate::inline::replace_in_debug_records(sh, f, r, if of_next { wide_next_v } else { wide_v });
        for b in &l.blocks {
            f.blocks[b.index()].insts.retain(|&x| x != i);
        }
    }

    // If the narrow counter now only feeds its increment and the exit
    // test, test the wide one against the extended bound instead, and let
    // the narrow one go.
    let users = |f: &Function, v: Value| -> Vec<InstId> {
        f.insts_in_order()
            .filter(|&i| {
                let mut uses = false;
                f.insts[i.index()].op.for_each_value(|x| uses |= *x == v);
                uses
            })
            .collect()
    };
    let phi_users = users(f, phi_v);
    let next_users = users(f, next_v);
    let only_counting = phi_users == vec![iv.next]
        && next_users.iter().all(|&u| u == iv.phi || u == e.cmp)
        && matches!(f.insts[e.cmp.index()].op, Op::ICmp { pred: ICmpPred::Eq | ICmpPred::Ne, .. });
    if only_counting && e.on_next {
        let bound64 = match int_of(sh, e.bound) {
            Some(k) => Some(int64(sh, i64t, eval::sext(k.value, k.bits))),
            None if invariant(f, l, e.bound) => {
                let name = Some(names.fresh("wide.bound"));
                let op = Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: e.bound };
                let c = f.add_inst(op, Some((name, i64t)));
                let at = f.blocks[pre.index()].insts.len() - 1;
                f.blocks[pre.index()].insts.insert(at, c);
                Some(f.result(c))
            }
            None => None,
        };
        if let Some(bound64) = bound64
            && let Op::ICmp { pred, .. } = f.insts[e.cmp.index()].op
        {
            f.insts[e.cmp.index()].op = Op::ICmp { pred, samesign: false, lhs: wide_next_v, rhs: bound64 };
            // The narrow counter is now a dead cycle of two. Debug records
            // that showed it lose it.
            f.blocks[h.index()].insts.retain(|&x| x != iv.phi);
            f.blocks[block_of_next.index()].insts.retain(|&x| x != iv.next);
            for v in [phi_v, next_v] {
                if let Value::Local(r) = v {
                    crate::inline::replace_in_debug_records(sh, f, r, sh.poison(iv.ty));
                }
            }
        }
    }
    1
}

fn int64(sh: &Shared, ty: TypeId, v: i64) -> Value {
    Value::Const(sh.intern_const(Constant { ty, kind: ConstKind::Int(ApInt::from_i64(64, v)) }))
}
