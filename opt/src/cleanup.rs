//! Small CFG clean-ups run after a function has been restructured. They
//! keep the output readable; the full `simplifycfg` is planned separately.

use epitome_ir::module::*;

use crate::cfg;

/// Merges a block into its predecessor when the predecessor ends with an
/// unconditional branch to it and is its only predecessor. Phis in the
/// merged block have a single entry, so they are replaced by their value.
///
/// One walk over the blocks, merging each block's chain of successors into
/// it, with the lists of predecessors kept up to date and the phis'
/// replacements made in one sweep at the end, so a long chain costs its
/// length, not its length squared.
///
/// Not for functions whose blocks have their address taken: a merged
/// block would disappear from under its `blockaddress`.
pub fn merge_blocks(f: &mut Function) {
    let mut preds = f.predecessors();
    let entry = f.entry();
    let mut gone = vec![false; f.blocks.len()];
    // Replaced phis' values, by local, resolved at the end.
    let mut replaced: Vec<Option<Value>> = vec![None; f.locals.len()];
    let mut any = false;
    for k in 0..f.layout.len() {
        let b = f.layout[k];
        if gone[b.index()] {
            continue;
        }
        loop {
            let Some(t) = f.terminator(b) else { break };
            let Op::Br(s) = f.insts[t.index()].op else { break };
            if s == b || s == entry || preds[s.index()].as_slice() != [b] {
                break;
            }
            // (Names number the whole function: only for the step reported.)
            if !epitome_ir::chop::allow(|| {
                let name = |x: BlockId| epitome_ir::printer::local_name(f, f.blocks[x.index()].local);
                format!("merge block {} into {}", name(s), name(b))
            }) {
                break;
            }
            while let Some(&i) = f.blocks[s.index()].insts.first() {
                let Op::Phi { incoming, .. } = &f.insts[i.index()].op else { break };
                let v = incoming[0].0;
                if let Some(r) = f.insts[i.index()].result {
                    replaced[r.index()] = Some(v);
                }
                f.blocks[s.index()].insts.remove(0);
            }
            let rest = std::mem::take(&mut f.blocks[s.index()].insts);
            let br = f.blocks[b.index()].insts.pop().unwrap();
            // Debug records on the branch belong before what follows it.
            let records = std::mem::take(&mut f.insts[br.index()].debug_records);
            if let Some(&first) = rest.first() {
                f.insts[first.index()].debug_records.splice(0..0, records);
            }
            f.blocks[b.index()].insts.extend(rest);
            let mut succs = f.successors(b);
            succs.sort();
            succs.dedup();
            for x in succs {
                f.retarget_phis(x, s, b);
                for p in &mut preds[x.index()] {
                    if *p == s {
                        *p = b;
                    }
                }
            }
            gone[s.index()] = true;
            any = true;
        }
    }
    if !any {
        return;
    }
    f.layout.retain(|x| !gone[x.index()]);
    // The phis' values, through chains of replaced phis.
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
}

/// Removes blocks that cannot be reached from the entry, and their entries
/// in the phis of reachable blocks.
pub fn remove_unreachable(f: &mut Function) {
    let rpo = cfg::reverse_postorder(f);
    let mut reachable = vec![false; f.blocks.len()];
    rpo.iter().for_each(|b| reachable[b.index()] = true);
    let dead: Vec<BlockId> = f.layout.iter().copied().filter(|b| !reachable[b.index()]).collect();
    if dead.is_empty() || !epitome_ir::chop::allow(|| format!("remove {} unreachable blocks", dead.len())) {
        return;
    }
    for &b in &dead {
        for s in f.successors(b) {
            if reachable[s.index()] {
                f.remove_phi_entries(s, b);
            }
        }
    }
    f.layout.retain(|b| reachable[b.index()]);
}
