//! Simplifying the control-flow graph.
//!
//! Branches themselves are simplified by the combiner: rules such as
//! `condbr(true, ^a, ^b) -> br(^a)` in `opt/rules/combine.rules`, and a
//! built-in fold for `switch`. What is left here changes the shape of the
//! graph rather than one instruction:
//!
//! - **Unreachable blocks** are deleted, with their phi entries.
//! - **Empty blocks** holding only `br label %next` are bypassed: their
//!   predecessors branch to `%next` directly, and phis in `%next` get an
//!   entry for each new edge. Not done if a predecessor already branches to
//!   `%next` with a different phi value, since one block cannot send two
//!   values along its edges to the same place.
//! - **Diamonds and triangles** become `select`s. An `if` whose arms are
//!   empty blocks (or with one arm missing) only chooses a value for the
//!   phis where the arms meet, so the phis can be computed with `select` in
//!   the block that branches, and the branch goes straight to the join.
//!   An arm may also compute up to two values that are safe to compute
//!   anyway (pure, unable to trap); they move before the branch.
//! - **Straight lines** merge: a block that is the only successor of its
//!   only predecessor joins it.
//!
//! These repeat until nothing changes. Functions whose blocks have their
//! address taken are left alone, since a `blockaddress` may name any block.

use draconian_ir::module::*;

use crate::cleanup;
use crate::ctx::Shared;

#[derive(Default, Debug, Clone, Copy)]
pub struct Stats {
    pub unreachable: usize,
    pub bypassed: usize,
    pub selects: usize,
    /// Instructions run before a branch, so that an arm became empty.
    pub speculated: usize,
    pub merged: usize,
}

impl Stats {
    pub fn total(&self) -> usize {
        self.unreachable + self.bypassed + self.selects + self.merged
    }
}

pub struct Outcome {
    pub stats: Stats,
    /// Instructions worth combining again: new selects, and phis that got
    /// new entries.
    pub touched: Vec<InstId>,
}

/// Most phis turned into selects at one join.
const MAX_SELECTS: usize = 8;

pub fn run(sh: &Shared, f: &mut Function, block_addresses: bool) -> Outcome {
    let mut out = Outcome { stats: Stats::default(), touched: Vec::new() };
    if !f.has_body || block_addresses {
        return out;
    }
    for _round in 0..16 {
        let before = out.stats.total();
        let n = f.layout.len();
        cleanup::remove_unreachable(f);
        out.stats.unreachable += n - f.layout.len();
        while bypass_all(f, &mut out) {}
        fold_same_targets(f, &mut out);
        select_all(sh, f, &mut out);
        let n = f.layout.len();
        cleanup::merge_blocks(f);
        out.stats.merged += n - f.layout.len();
        if out.stats.total() == before {
            break;
        }
    }
    out.touched.retain(|&i| f.insts[i.index()].result.is_some());
    out
}

/// The phis at the start of a block.
fn phis(f: &Function, b: BlockId) -> Vec<InstId> {
    f.blocks[b.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect()
}

/// The value a phi takes along the edge from `from`.
fn incoming(f: &Function, phi: InstId, from: BlockId) -> Option<Value> {
    let Op::Phi { incoming, .. } = &f.insts[phi.index()].op else { return None };
    incoming.iter().find(|(_, b)| *b == from).map(|(v, _)| *v)
}

/// The block an empty block (just `br label %next`) branches to.
fn forwards_to(f: &Function, b: BlockId) -> Option<BlockId> {
    let insts = &f.blocks[b.index()].insts;
    let [only] = insts[..] else { return None };
    let inst = &f.insts[only.index()];
    match inst.op {
        // Debug records on the branch would have nowhere to go.
        Op::Br(next) if next != b && inst.debug_records.is_empty() => Some(next),
        _ => None,
    }
}

/// The most instructions an arm may have and still be run before the
/// branch, so that its phis become selects.
const MAX_SPECULATED: usize = 2;

/// Like `forwards_to`, for a block that may also compute up to
/// `MAX_SPECULATED` values that are safe to compute when the block would
/// not have run: pure, and unable to trap (`licm::safe_to_speculate`).
fn speculates_to(sh: &Shared, f: &Function, b: BlockId) -> Option<BlockId> {
    let insts = &f.blocks[b.index()].insts;
    let (&last, body) = insts.split_last()?;
    if body.len() > MAX_SPECULATED {
        return None;
    }
    let inst = &f.insts[last.index()];
    let Op::Br(next) = inst.op else { return None };
    if next == b || !inst.debug_records.is_empty() {
        return None;
    }
    body.iter()
        .all(|&i| {
            let op = &f.insts[i.index()].op;
            !matches!(op, Op::Phi { .. }) && crate::licm::safe_to_speculate(sh, op)
        })
        .then_some(next)
}

/// A conditional branch whose targets bypassing made the same is a plain
/// branch; one of its two edges' phi entries goes. The combiner's
/// `br_same` rule does this for branches it visits, but bypassing makes
/// new ones after it has run. The condition may now be unused, so it is
/// handed back to the combiner.
fn fold_same_targets(f: &mut Function, out: &mut Outcome) {
    for k in 0..f.layout.len() {
        let b = f.layout[k];
        let Some(t) = f.terminator(b) else { continue };
        let Op::CondBr { cond, then_dest, else_dest } = f.insts[t.index()].op else { continue };
        if then_dest != else_dest
            || !draconian_ir::chop::allow(|| {
                format!(
                    "simplifycfg: a branch to the same block from {}",
                    draconian_ir::printer::local_name(f, f.blocks[b.index()].local)
                )
            })
        {
            continue;
        }
        f.insts[t.index()].op = Op::Br(then_dest);
        for phi in phis(f, then_dest) {
            if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op
                && let Some(at) = incoming.iter().position(|(_, from)| *from == b)
            {
                incoming.remove(at);
            }
        }
        if let Value::Local(l) = cond
            && let LocalDef::Inst(d) = f.locals[l.index()].def
        {
            out.touched.push(d);
        }
        out.stats.bypassed += 1;
    }
}

/// Bypasses every empty block it can, in one walk, keeping the lists of
/// predecessors up to date as it goes. Returns true if it bypassed any.
fn bypass_all(f: &mut Function, out: &mut Outcome) -> bool {
    let mut preds = f.predecessors();
    let entry = f.entry();
    let mut gone = vec![false; f.blocks.len()];
    let mut any = false;
    for k in 0..f.layout.len() {
        let b = f.layout[k];
        if b == entry {
            continue;
        }
        let Some(next) = forwards_to(f, b) else { continue };
        if gone[next.index()] {
            continue;
        }
        let ps = preds[b.index()].clone();
        if ps.is_empty() {
            continue;
        }
        // Only plain branches and switches are retargeted.
        let retargetable = ps.iter().all(|&p| {
            f.terminator(p)
                .is_some_and(|t| matches!(f.insts[t.index()].op, Op::Br(_) | Op::CondBr { .. } | Op::Switch { .. }))
        });
        if !retargetable {
            continue;
        }
        // A predecessor that already reaches `next` must send the same
        // values as `b` does.
        let next_phis = phis(f, next);
        let clash = ps.iter().any(|&p| {
            preds[next.index()].contains(&p) && next_phis.iter().any(|&phi| incoming(f, phi, p) != incoming(f, phi, b))
        });
        if clash {
            continue;
        }
        if !draconian_ir::chop::allow(|| {
            format!(
                "simplifycfg: bypass the empty block {}",
                draconian_ir::printer::local_name(f, f.blocks[b.index()].local)
            )
        }) {
            continue;
        }
        for &p in &ps {
            let t = f.terminator(p).unwrap();
            let mut edges = 0;
            f.insts[t.index()].op.for_each_successor_mut(|s| {
                if *s == b {
                    *s = next;
                    edges += 1;
                }
            });
            for &phi in &next_phis {
                let v = incoming(f, phi, b).expect("phi has an entry for each predecessor");
                if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op {
                    incoming.extend(std::iter::repeat_n((v, p), edges));
                }
            }
        }
        for &phi in &next_phis {
            if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op {
                incoming.retain(|(_, from)| *from != b);
            }
        }
        // `next` is now reached from `b`'s predecessors instead of `b`.
        let list = &mut preds[next.index()];
        list.retain(|&x| x != b);
        for p in ps {
            if !list.contains(&p) {
                list.push(p);
            }
        }
        preds[b.index()].clear();
        gone[b.index()] = true;
        out.touched.extend(next_phis);
        out.stats.bypassed += 1;
        any = true;
    }
    if any {
        f.layout.retain(|b| !gone[b.index()]);
    }
    any
}

/// Turns every diamond and triangle it can into selects, in one walk: the
/// lists of predecessors are kept up to date as branches change, and the
/// phis' replacements are made in one sweep at the end (a value may be a
/// phi replaced earlier in the walk, so they are resolved through chains).
fn select_all(sh: &Shared, f: &mut Function, out: &mut Outcome) {
    let mut preds = f.predecessors();
    let mut replaced: Vec<Option<Value>> = vec![None; f.locals.len()];
    let mut any = false;
    for k in 0..f.layout.len() {
        let a = f.layout[k];
        let Some(t) = f.terminator(a) else { continue };
        let Op::CondBr { cond, then_dest, else_dest } = f.insts[t.index()].op else { continue };
        if then_dest == else_dest {
            continue;
        }
        let only_from_a = |preds: &[Vec<BlockId>], x: BlockId| preds[x.index()].as_slice() == [a];
        // Where the two ways meet, and the block each value arrives from.
        let (join, from_then, from_else) = match (speculates_to(sh, f, then_dest), speculates_to(sh, f, else_dest)) {
            (Some(j1), Some(j2)) if j1 == j2 && only_from_a(&preds, then_dest) && only_from_a(&preds, else_dest) => {
                (j1, then_dest, else_dest)
            }
            (Some(j), _) if j == else_dest && only_from_a(&preds, then_dest) => (j, then_dest, a),
            (_, Some(j)) if j == then_dest && only_from_a(&preds, else_dest) => (j, a, else_dest),
            _ => continue,
        };
        if join == a {
            continue;
        }
        // The join must be reached only these two ways, once each.
        let mut want = vec![from_then, from_else];
        want.sort();
        let mut got = preds[join.index()].clone();
        got.sort();
        let edges_into_join: usize = got.iter().map(|&p| f.successors(p).iter().filter(|&&s| s == join).count()).sum();
        if got != want || edges_into_join != 2 {
            continue;
        }
        let join_phis = phis(f, join);
        let complete =
            join_phis.iter().all(|&p| incoming(f, p, from_then).is_some() && incoming(f, p, from_else).is_some());
        if join_phis.len() > MAX_SELECTS || !complete {
            continue;
        }
        if !draconian_ir::chop::allow(|| {
            format!(
                "simplifycfg: selects for the branch in {}",
                draconian_ir::printer::local_name(f, f.blocks[a.index()].local)
            )
        }) {
            continue;
        }
        let resolve = |replaced: &[Option<Value>], mut v: Value| {
            while let Value::Local(l) = v
                && let Some(n) = replaced[l.index()]
            {
                v = n;
            }
            v
        };
        // What the arms compute moves before the branch.
        for x in [then_dest, else_dest] {
            if x == a || x == join {
                continue;
            }
            let n = f.blocks[x.index()].insts.len() - 1;
            let moved: Vec<InstId> = f.blocks[x.index()].insts.drain(..n).collect();
            let at = f.blocks[a.index()].insts.len() - 1;
            out.touched.extend(moved.iter().copied());
            out.stats.speculated += moved.len();
            f.blocks[a.index()].insts.splice(at..at, moved);
        }
        // Compute each phi with a select before the branch.
        for &phi in &join_phis {
            let tv = resolve(&replaced, incoming(f, phi, from_then).unwrap());
            let ev = resolve(&replaced, incoming(f, phi, from_else).unwrap());
            let r = f.insts[phi.index()].result.unwrap();
            let v = if tv == ev {
                tv
            } else {
                let fmf = match f.insts[phi.index()].op {
                    Op::Phi { fmf, .. } => fmf,
                    _ => FastMath::default(),
                };
                let name = f.locals[r.index()].name.clone();
                let ty = f.locals[r.index()].ty;
                let sel = f.add_inst(Op::Select { fmf, cond, then_value: tv, else_value: ev }, Some((name, ty)));
                let at = f.blocks[a.index()].insts.len() - 1;
                f.blocks[a.index()].insts.insert(at, sel);
                out.touched.push(sel);
                out.stats.selects += 1;
                f.result(sel)
            };
            f.locals[r.index()].name = None;
            f.blocks[join.index()].insts.retain(|&x| x != phi);
            if replaced.len() < f.locals.len() {
                replaced.resize(f.locals.len(), None);
            }
            replaced[r.index()] = Some(v);
        }
        f.insts[t.index()].op = Op::Br(join);
        // `a` now goes straight to the join; the arms lose it.
        for x in [then_dest, else_dest] {
            if x != join {
                preds[x.index()].retain(|&p| p != a);
            }
        }
        preds[join.index()] = vec![a];
        any = true;
    }
    if !any {
        return;
    }
    if replaced.len() < f.locals.len() {
        replaced.resize(f.locals.len(), None);
    }
    let resolve = |mut v: Value| {
        while let Value::Local(l) = v
            && let Some(n) = replaced[l.index()]
        {
            v = n;
        }
        v
    };
    let order: Vec<InstId> = f.insts_in_order().collect();
    for i in order {
        f.insts[i.index()].op.for_each_value_mut(|v| *v = resolve(*v));
    }
    let lmap: Vec<Option<Value>> = (0..f.locals.len()).map(|k| replaced[k].map(resolve)).collect();
    crate::inline::replace_all_in_debug_records(sh, f, &lmap);
}
