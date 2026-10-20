//! Passes over machine instructions after selection.
//!
//! **Redundant compares.** Selection makes each user of a comparison with
//! its own compare, since a pattern covers the compare and what reads the
//! flags together: `(a < b) + (a == b) * 2` compares `a` with `b` twice. In
//! a block, a compare the same as the last instruction that set the flags
//! (the same instruction, on the same operands) is removed, when nothing
//! between them wrote the flags or the operands. What may write the flags is
//! an instruction that sets them (`"sets"` in the description), a call,
//! anything else that clobbers registers (`imp_defs`), and inline assembly.
//! Each removal is an elective change (autochop).

use crate::mir::*;
use crate::target::Target;

/// Removes redundant compares; returns how many.
pub fn redundant_compares(t: &Target, mf: &mut MFunc) -> usize {
    let mut removed = 0;
    let name = mf.name.clone();
    for b in &mut mf.blocks {
        let mut last: Option<MInst> = None;
        let mut keep = Vec::with_capacity(b.insts.len());
        for inst in std::mem::take(&mut b.insts) {
            let sets = matches!(inst.op, Opcode::Instr(i) if t.instrs[i].sets.is_some());
            if sets {
                if last.as_ref().is_some_and(|l| l.op == inst.op && l.ops == inst.ops)
                    && draconian_ir::chop::allow(|| format!("{name}: remove a compare the same as the last"))
                {
                    removed += 1;
                    continue;
                }
                last = Some(inst.clone());
                keep.push(inst);
                continue;
            }
            if matches!(inst.op, Opcode::Asm { .. }) || !inst.imp_defs.is_empty() {
                last = None;
            } else if let Some(l) = &last {
                let (defs, _) = inst.defs_uses(t);
                if defs.iter().any(|&k| l.ops.contains(&inst.ops[k])) {
                    last = None;
                }
            }
            keep.push(inst);
        }
        b.insts = keep;
    }
    removed
}
