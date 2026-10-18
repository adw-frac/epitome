//! Small CFG clean-ups run after a function has been restructured. They
//! keep the output readable; the full `simplifycfg` is planned separately.

use draconian_ir::module::*;

use crate::cfg;

/// Merges a block into its predecessor when the predecessor ends with an
/// unconditional branch to it and is its only predecessor. Phis in the
/// merged block have a single entry, so they are replaced by their value.
///
/// Not for functions whose blocks have their address taken: a merged
/// block would disappear from under its `blockaddress`.
pub fn merge_blocks(f: &mut Function) {
    loop {
        let preds = f.predecessors();
        let entry = f.entry();
        let mut merged = false;
        for k in 0..f.layout.len() {
            let b = f.layout[k];
            let Some(t) = f.terminator(b) else { continue };
            let Op::Br(s) = f.insts[t.index()].op else { continue };
            if s == b || s == entry || preds[s.index()].as_slice() != [b] {
                continue;
            }
            // Replace the phis while every instruction is still in a block,
            // so `replace_uses` sees them all.
            while let Some(&i) = f.blocks[s.index()].insts.first() {
                let Op::Phi { incoming, .. } = &f.insts[i.index()].op else { break };
                let v = incoming[0].0;
                let me = f.result(i);
                f.blocks[s.index()].insts.remove(0);
                f.replace_uses(me, v);
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
            succs.dedup();
            for x in succs {
                f.retarget_phis(x, s, b);
            }
            f.layout.retain(|&x| x != s);
            merged = true;
            break;
        }
        if !merged {
            return;
        }
    }
}

/// Removes blocks that cannot be reached from the entry, and their entries
/// in the phis of reachable blocks.
pub fn remove_unreachable(f: &mut Function) {
    let rpo = cfg::reverse_postorder(f);
    let mut reachable = vec![false; f.blocks.len()];
    rpo.iter().for_each(|b| reachable[b.index()] = true);
    let dead: Vec<BlockId> = f.layout.iter().copied().filter(|b| !reachable[b.index()]).collect();
    for &b in &dead {
        for s in f.successors(b) {
            if reachable[s.index()] {
                f.remove_phi_entries(s, b);
            }
        }
    }
    f.layout.retain(|b| reachable[b.index()]);
}
