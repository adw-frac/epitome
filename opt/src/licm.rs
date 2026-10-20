//! Loop-invariant code motion: what a loop computes the same way every
//! time round moves to its preheader, and is computed once. LLVM's `licm`,
//! without promoting memory to registers.
//!
//! - **Arithmetic** that cannot trap (anything pure but division and
//!   remainder, unless the divisor is a constant that cannot make them
//!   trap), whose operands are all defined outside the loop, moves.
//!   Running it when the loop would not have does no harm.
//! - **Loads** move when their address is invariant and the write that
//!   reaches them (memory SSA's walker, `memssa.rs`) is outside the loop:
//!   nothing in the loop can change the bytes. Since a load may fault, it
//!   moves only from a block that dominates every block the loop exits
//!   from, so it would have run anyway.
//!
//! Loops are taken innermost first; what moves to an inner loop's
//! preheader, which is in the outer loop, may then move out of that too.
//! Within a loop, one walk in reverse postorder is enough: an operand from
//! the loop is defined earlier in that order, so it has already moved if
//! it could. Each move is an elective change (autochop).

use epitome_ir::edit::Names;
use epitome_ir::module::*;

use crate::aa::BasicAa;
use crate::cfg::{self, DomTree};
use crate::ctx::Shared;
use crate::fx::FxHashSet as HashSet;
use crate::loops;
use crate::memssa::{Access, MemorySsa, WalkState};

#[derive(Clone, Copy, Debug, Default)]
pub struct Stats {
    /// Instructions moved out of loops, and how many of them were loads.
    pub hoisted: usize,
    pub loads: usize,
}

pub fn run(sh: &Shared, f: &mut Function) -> Stats {
    let mut stats = Stats::default();
    if !f.has_body {
        return stats;
    }
    let mut found = loops::find(f);
    if found.is_empty() {
        return stats;
    }
    let aa = BasicAa::new(sh, f);
    let ssa = MemorySsa::build(&aa, f);
    let walk = WalkState::new(f);
    // A preheader is made only for a loop something moves out of. Making
    // one adds a block before the header: no dominance between the blocks
    // there were changes, and the block holds no memory access, so the
    // dominator tree and memory SSA stay right for them. The predecessors
    // and the order of blocks are found again.
    let dom = DomTree::new(f);
    let mut rpo = cfg::reverse_postorder(f);
    let mut preds = f.predecessors();
    let mut block_of = f.inst_blocks();
    let mut names: Option<Names> = None;
    // Innermost (smallest) first.
    for k in 0..found.len() {
        let l = found[k].clone();
        let exiting: Vec<BlockId> =
            l.blocks.iter().copied().filter(|&b| f.successors(b).iter().any(|s| !l.contains(*s))).collect();
        // What moves, in order: each block's instructions that can.
        let mut moving: HashSet<InstId> = HashSet::default();
        let mut plan: Vec<(BlockId, Vec<InstId>)> = Vec::new();
        for &b in rpo.iter().filter(|b| l.contains(**b)) {
            let mut out = Vec::new();
            for &i in &f.blocks[b.index()].insts {
                let inside = |v: Value| match v {
                    Value::Local(x) => match f.locals[x.index()].def {
                        LocalDef::Inst(d) => {
                            !moving.contains(&d)
                                && block_of.get(d.index()).copied().flatten().is_some_and(|db| l.contains(db))
                        }
                        _ => false,
                    },
                    _ => false,
                };
                let op = &f.insts[i.index()].op;
                let mut invariant = true;
                op.for_each_value(|v| invariant &= !inside(*v));
                if !invariant {
                    continue;
                }
                let is_load = matches!(op, Op::Load { volatile: false, atomic: None, .. });
                let movable = if is_load {
                    // Run anyway, and nothing in the loop writes the bytes.
                    !exiting.is_empty()
                        && exiting.iter().all(|&e| dom.dominates(b, e))
                        && walk.clobber_of(&ssa, &aa, f, i).is_some_and(|c| {
                            c.exact
                                && match ssa.get(c.at) {
                                    Access::LiveOnEntry => true,
                                    Access::Def { block, .. } | Access::Phi { block, .. } => !l.contains(*block),
                                    Access::Use { .. } => false,
                                }
                        })
                } else {
                    safe_to_speculate(sh, op)
                };
                if !movable
                    || !epitome_ir::chop::allow(|| {
                        format!(
                            "licm: move {} out of the loop at {}",
                            epitome_ir::printer::inst_name(f, i),
                            epitome_ir::printer::local_name(f, f.blocks[l.header.index()].local)
                        )
                    })
                {
                    continue;
                }
                moving.insert(i);
                out.push(i);
            }
            if !out.is_empty() {
                plan.push((b, out));
            }
        }
        if plan.is_empty() {
            continue;
        }
        // The preheader, made if there is none.
        let pre = match l.preheader(f, &preds) {
            Some(p) => p,
            None => {
                let names = names.get_or_insert_with(|| Names::new(f));
                let Some(p) = loops::ensure_preheader(f, names, &l) else { continue };
                // It is in every loop around this one.
                for outer in found.iter_mut().skip(k + 1) {
                    if outer.contains(l.header) {
                        outer.add_block(p);
                    }
                }
                preds = f.predecessors();
                rpo = cfg::reverse_postorder(f);
                block_of.resize(f.insts.len(), None);
                // Its phis and branch are new instructions.
                for &i in &f.blocks[p.index()].insts {
                    block_of[i.index()] = Some(p);
                }
                p
            }
        };
        for (b, out) in plan {
            let gone: HashSet<InstId> = out.iter().copied().collect();
            f.blocks[b.index()].insts.retain(|x| !gone.contains(x));
            for &i in &out {
                block_of[i.index()] = Some(pre);
                stats.hoisted += 1;
                stats.loads += matches!(f.insts[i.index()].op, Op::Load { .. }) as usize;
            }
            // To the end of the preheader, before its branch.
            let at = f.blocks[pre.index()].insts.len() - 1;
            f.blocks[pre.index()].insts.splice(at..at, out);
        }
    }
    stats
}

/// Whether running `op` where it would not have run is harmless: pure,
/// and cannot trap.
pub(crate) fn safe_to_speculate(sh: &Shared, op: &Op) -> bool {
    match op {
        Op::Binary { op, rhs, .. } => match op {
            BinOp::UDiv | BinOp::URem => const_int(sh, *rhs).is_some_and(|d| d != 0),
            // Also not by -1: the most negative number divided by -1
            // overflows.
            BinOp::SDiv | BinOp::SRem => const_int(sh, *rhs).is_some_and(|d| d != 0 && d != -1),
            _ => true,
        },
        Op::ICmp { .. }
        | Op::FCmp { .. }
        | Op::Select { .. }
        | Op::Cast { .. }
        | Op::FNeg { .. }
        | Op::Gep { .. }
        | Op::ExtractValue { .. }
        | Op::InsertValue { .. }
        | Op::ExtractElement { .. }
        | Op::InsertElement { .. }
        | Op::ShuffleVector { .. } => true,
        _ => false,
    }
}

fn const_int(sh: &Shared, v: Value) -> Option<i64> {
    let Value::Const(c) = v else { return None };
    let k = crate::combine::eval::int_const(sh.consts(), sh.types(), c)?;
    Some(crate::combine::eval::sext(k.value, k.bits))
}
