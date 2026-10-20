//! Natural loops.
//!
//! A *back edge* is an edge from a block to a block that dominates it; the
//! dominating block is a loop *header*. The loop is the header plus every
//! block that can reach one of its back edges without passing through the
//! header. Edges that leave the loop go to *exit* blocks. A loop's
//! *latches* are the blocks with back edges to its header.
//!
//! Loops whose header does not dominate them (irreducible control flow) are
//! not natural loops and are not found; passes leave them alone.

use epitome_ir::edit::Names;
use epitome_ir::module::*;

use crate::cfg::DomTree;

#[derive(Clone, Debug)]
pub struct Loop {
    pub header: BlockId,
    /// Every block in the loop, the header first.
    pub blocks: Vec<BlockId>,
    pub latches: Vec<BlockId>,
    /// The same blocks, to ask about in constant time.
    members: crate::fx::FxHashSet<BlockId>,
}

impl Loop {
    pub fn contains(&self, b: BlockId) -> bool {
        self.members.contains(&b)
    }

    /// Adds a block made since the loop was found (the preheader of a loop
    /// inside it).
    pub fn add_block(&mut self, b: BlockId) {
        if self.members.insert(b) {
            self.blocks.push(b);
        }
    }

    /// Blocks outside the loop that a block in it branches to.
    pub fn exits(&self, f: &Function) -> Vec<BlockId> {
        let mut out = Vec::new();
        for &b in &self.blocks {
            for s in f.successors(b) {
                if !self.contains(s) && !out.contains(&s) {
                    out.push(s);
                }
            }
        }
        out
    }

    /// The preheader: the header's only predecessor from outside the loop,
    /// if it has just one, and that block's only successor is the header.
    pub fn preheader(&self, f: &Function, preds: &[Vec<BlockId>]) -> Option<BlockId> {
        let outside: Vec<BlockId> = preds[self.header.index()].iter().copied().filter(|p| !self.contains(*p)).collect();
        match outside.as_slice() {
            [p] if f.successors(*p).iter().all(|&s| s == self.header) => Some(*p),
            _ => None,
        }
    }
}

/// Every natural loop of a function, innermost (smallest) first.
pub fn find(f: &Function) -> Vec<Loop> {
    let dom = DomTree::new(f);
    let preds = f.predecessors();
    let mut loops: Vec<Loop> = Vec::new();
    for &b in &f.layout {
        if !dom.is_reachable(b) {
            continue;
        }
        for h in f.successors(b) {
            if !dom.dominates(h, b) {
                continue;
            }
            match loops.iter_mut().find(|l| l.header == h) {
                Some(l) => {
                    if !l.latches.contains(&b) {
                        l.latches.push(b);
                    }
                }
                None => loops.push(Loop {
                    header: h,
                    blocks: vec![h],
                    latches: vec![b],
                    members: [h].into_iter().collect(),
                }),
            }
        }
    }
    for l in &mut loops {
        let mut work: Vec<BlockId> = l.latches.clone();
        while let Some(x) = work.pop() {
            // The header is the loop's first block already, and the walk
            // stops there.
            if x == l.header || !l.members.insert(x) {
                continue;
            }
            l.blocks.push(x);
            for &p in &preds[x.index()] {
                if dom.is_reachable(p) {
                    work.push(p);
                }
            }
        }
    }
    loops.sort_by_key(|l| l.blocks.len());
    loops
}

/// Makes sure loop `l` has a preheader, adding an empty block between the
/// header and its predecessors outside the loop if not. Returns the
/// preheader, or `None` if one cannot be made (a predecessor ends in
/// something other than a branch or switch).
pub fn ensure_preheader(f: &mut Function, names: &mut Names, l: &Loop) -> Option<BlockId> {
    let preds = f.predecessors();
    if let Some(p) = l.preheader(f, &preds) {
        return Some(p);
    }
    let outside: Vec<BlockId> = preds[l.header.index()].iter().copied().filter(|p| !l.contains(*p)).collect();
    if outside.is_empty() {
        return None;
    }
    let plain = outside.iter().all(|&p| {
        f.terminator(p)
            .is_some_and(|t| matches!(f.insts[t.index()].op, Op::Br(_) | Op::CondBr { .. } | Op::Switch { .. }))
    });
    if !plain {
        return None;
    }
    let name = Some(names.fresh(&format!("{}.preheader", f.block_name(l.header).unwrap_or("loop"))));
    let pre = f.add_block(name);
    let at = f.layout.iter().position(|&b| b == l.header).unwrap();
    f.layout.insert(at, pre);
    // The header's phis: entries from outside move to a phi in the
    // preheader (or straight through, for one predecessor).
    let header_phis: Vec<InstId> =
        f.blocks[l.header.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect();
    for phi in header_phis {
        let Op::Phi { fmf, incoming } = f.insts[phi.index()].op.clone() else { unreachable!() };
        let (from_outside, inside): (Vec<_>, Vec<_>) = incoming.into_iter().partition(|(_, b)| outside.contains(b));
        let first = from_outside[0].0;
        let value = if from_outside.iter().all(|(v, _)| *v == first) {
            first
        } else {
            let r = f.insts[phi.index()].result.unwrap();
            let ty = f.locals[r.index()].ty;
            let name = f.locals[r.index()].name.clone().map(|n| names.fresh(&format!("{n}.ph")));
            let p = f.push_inst(pre, Op::Phi { fmf, incoming: from_outside }, Some((name, ty)));
            f.result(p)
        };
        let mut entries = inside;
        entries.push((value, pre));
        f.insts[phi.index()].op = Op::Phi { fmf, incoming: entries };
    }
    f.push_inst(pre, Op::Br(l.header), None);
    for p in outside {
        let t = f.terminator(p).unwrap();
        f.insts[t.index()].op.for_each_successor_mut(|s| {
            if *s == l.header {
                *s = pre;
            }
        });
    }
    Some(pre)
}
