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
//!   Nothing is moved or run speculatively: the arms are empty.
//! - **Straight lines** merge: a block that is the only successor of its
//!   only predecessor joins it.
//!
//! These repeat until nothing changes. Functions whose blocks have their
//! address taken are left alone, since a `blockaddress` may name any block.

use smaugian_ir::module::*;

use crate::cleanup;
use crate::ctx::Shared;

#[derive(Default, Debug, Clone, Copy)]
pub struct Stats {
    pub unreachable: usize,
    pub bypassed: usize,
    pub selects: usize,
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
        while select_one(sh, f, &mut out) {}
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

/// Turns one diamond or triangle into selects. Returns false when there is
/// none.
fn select_one(sh: &Shared, f: &mut Function, out: &mut Outcome) -> bool {
    let preds = f.predecessors();
    for k in 0..f.layout.len() {
        let a = f.layout[k];
        let Some(t) = f.terminator(a) else { continue };
        let Op::CondBr { cond, then_dest, else_dest } = f.insts[t.index()].op else { continue };
        if then_dest == else_dest {
            continue;
        }
        let only_from_a = |x: BlockId| preds[x.index()].as_slice() == [a];
        // Where the two ways meet, and the block each value arrives from.
        let (join, from_then, from_else) = match (forwards_to(f, then_dest), forwards_to(f, else_dest)) {
            (Some(j1), Some(j2)) if j1 == j2 && only_from_a(then_dest) && only_from_a(else_dest) => {
                (j1, then_dest, else_dest)
            }
            (Some(j), _) if j == else_dest && only_from_a(then_dest) => (j, then_dest, a),
            (_, Some(j)) if j == then_dest && only_from_a(else_dest) => (j, a, else_dest),
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
        // Compute each phi with a select before the branch.
        for &phi in &join_phis {
            let (tv, ev) = (incoming(f, phi, from_then).unwrap(), incoming(f, phi, from_else).unwrap());
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
            f.replace_uses(Value::Local(r), v);
            crate::inline::replace_in_debug_records(sh, f, r, v);
        }
        f.insts[t.index()].op = Op::Br(join);
        return true;
    }
    false
}
