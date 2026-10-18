//! Control-flow analyses: reverse postorder, dominator tree, and a check
//! that a function is well-formed SSA.

use draconian_ir::module::*;

/// Blocks reachable from the entry, in reverse postorder.
pub fn reverse_postorder(f: &Function) -> Vec<BlockId> {
    let mut seen = vec![false; f.blocks.len()];
    let mut post = Vec::new();
    let entry = f.entry();
    seen[entry.index()] = true;
    let mut stack = vec![(entry, f.successors(entry), 0usize)];
    while let Some((b, succs, next)) = stack.last_mut() {
        if let Some(&s) = succs.get(*next) {
            *next += 1;
            if !seen[s.index()] {
                seen[s.index()] = true;
                let ss = f.successors(s);
                stack.push((s, ss, 0));
            }
        } else {
            post.push(*b);
            stack.pop();
        }
    }
    post.reverse();
    post
}

/// The dominator tree, by the iterative method of Cooper, Harvey and
/// Kennedy ("A Simple, Fast Dominance Algorithm").
pub struct DomTree {
    /// Immediate dominator of each block; the entry is its own. `None` for
    /// unreachable blocks.
    idom: Vec<Option<BlockId>>,
    /// Position in reverse postorder; `u32::MAX` for unreachable blocks.
    order: Vec<u32>,
}

impl DomTree {
    pub fn new(f: &Function) -> DomTree {
        let rpo = reverse_postorder(f);
        let preds = f.predecessors();
        let mut order = vec![u32::MAX; f.blocks.len()];
        for (i, b) in rpo.iter().enumerate() {
            order[b.index()] = i as u32;
        }
        let mut idom: Vec<Option<BlockId>> = vec![None; f.blocks.len()];
        let entry = rpo[0];
        idom[entry.index()] = Some(entry);
        let mut changed = true;
        while changed {
            changed = false;
            for &b in &rpo[1..] {
                let mut new: Option<BlockId> = None;
                for &p in &preds[b.index()] {
                    if idom[p.index()].is_none() {
                        continue;
                    }
                    new = Some(match new {
                        None => p,
                        Some(n) => {
                            let (mut x, mut y) = (p, n);
                            while x != y {
                                while order[x.index()] > order[y.index()] {
                                    x = idom[x.index()].unwrap();
                                }
                                while order[y.index()] > order[x.index()] {
                                    y = idom[y.index()].unwrap();
                                }
                            }
                            x
                        }
                    });
                }
                if new.is_some() && idom[b.index()] != new {
                    idom[b.index()] = new;
                    changed = true;
                }
            }
        }
        DomTree { idom, order }
    }

    /// The children of each block in the dominator tree, in reverse
    /// postorder.
    pub fn children(&self) -> Vec<Vec<BlockId>> {
        let mut by_order: Vec<(u32, BlockId)> = (0..self.idom.len())
            .filter(|&i| self.order[i] != u32::MAX)
            .map(|i| (self.order[i], BlockId(i as u32)))
            .collect();
        by_order.sort();
        let mut children = vec![Vec::new(); self.idom.len()];
        for (_, b) in by_order {
            if let Some(p) = self.idom[b.index()]
                && p != b
            {
                children[p.index()].push(b);
            }
        }
        children
    }

    pub fn is_reachable(&self, b: BlockId) -> bool {
        self.order[b.index()] != u32::MAX
    }

    /// True if every path from the entry to `b` passes through `a`.
    /// Unreachable blocks are dominated by everything.
    pub fn dominates(&self, a: BlockId, b: BlockId) -> bool {
        if !self.is_reachable(b) {
            return true;
        }
        let mut x = b;
        loop {
            if x == a {
                return true;
            }
            let up = self.idom[x.index()].unwrap();
            if up == x {
                return false;
            }
            x = up;
        }
    }
}

/// Checks the rules every pass must keep, and returns a message for each
/// one broken:
///
/// - each block ends with its only terminator, and phis come first;
/// - a phi has one entry per predecessor;
/// - every local used is defined in the body, and its definition
///   dominates the use (for a phi, the end of the incoming block).
pub fn verify(f: &Function, name: &str) -> Vec<String> {
    let mut errors = Vec::new();
    if !f.has_body {
        return errors;
    }
    let preds = f.predecessors();
    let dom = DomTree::new(f);
    // Where each local is defined: (block, position); params at the entry.
    let mut def_at: Vec<Option<(BlockId, usize)>> = vec![None; f.locals.len()];
    for p in &f.params {
        def_at[p.local.index()] = Some((f.entry(), 0));
    }
    for &b in &f.layout {
        for (k, &i) in f.blocks[b.index()].insts.iter().enumerate() {
            if let Some(r) = f.insts[i.index()].result {
                def_at[r.index()] = Some((b, k + 1));
            }
        }
    }
    let block_label = |b: BlockId| f.block_name(b).map(|n| format!("%{n}")).unwrap_or(format!("block #{}", b.0));
    for &b in &f.layout {
        let insts = &f.blocks[b.index()].insts;
        let Some(&last) = insts.last() else {
            errors.push(format!("@{name}: {} is empty", block_label(b)));
            continue;
        };
        if !f.insts[last.index()].op.is_terminator() {
            errors.push(format!("@{name}: {} does not end with a terminator", block_label(b)));
        }
        let mut seen_non_phi = false;
        for (k, &i) in insts.iter().enumerate() {
            let op = &f.insts[i.index()].op;
            if op.is_terminator() && k + 1 != insts.len() {
                errors.push(format!("@{name}: terminator in the middle of {}", block_label(b)));
            }
            if op.is_phi() {
                if seen_non_phi {
                    errors.push(format!("@{name}: phi after other instructions in {}", block_label(b)));
                }
                let Op::Phi { incoming, .. } = op else { unreachable!() };
                // One entry per edge into the block, so a switch that reaches
                // it twice needs two.
                let mut from: Vec<BlockId> = incoming.iter().map(|x| x.1).collect();
                from.sort();
                let mut want: Vec<BlockId> = preds[b.index()]
                    .iter()
                    .flat_map(|&p| std::iter::repeat_n(p, f.successors(p).iter().filter(|&&s| s == b).count()))
                    .collect();
                want.sort();
                if from != want && dom.is_reachable(b) {
                    errors.push(format!("@{name}: phi in {} does not match its predecessors", block_label(b)));
                }
                for (v, p) in incoming {
                    check_use(&mut errors, name, f, &dom, &def_at, *v, *p, usize::MAX, &block_label);
                }
            } else {
                seen_non_phi = true;
                op.for_each_value(|v| check_use(&mut errors, name, f, &dom, &def_at, *v, b, k, &block_label));
            }
        }
    }
    errors
}

#[allow(clippy::too_many_arguments)]
fn check_use(
    errors: &mut Vec<String>,
    name: &str,
    f: &Function,
    dom: &DomTree,
    def_at: &[Option<(BlockId, usize)>],
    v: Value,
    b: BlockId,
    pos: usize,
    label: &dyn Fn(BlockId) -> String,
) {
    let Value::Local(l) = v else { return };
    if matches!(f.locals[l.index()].def, LocalDef::Block(_)) {
        return;
    }
    let what = f.locals[l.index()].name.clone().map(|n| format!("%{n}")).unwrap_or(format!("local #{}", l.0));
    match def_at[l.index()] {
        None => errors.push(format!("@{name}: {what} is used in {} but not defined", label(b))),
        Some((db, dpos)) => {
            let ok = if db == b { dpos <= pos } else { dom.dominates(db, b) };
            if !ok {
                errors.push(format!("@{name}: {what} does not dominate its use in {}", label(b)));
            }
        }
    }
}
