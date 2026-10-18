//! Block placement: putting blocks in an order where most branches fall
//! through, after allocation and frames.
//!
//! First, small blocks that return are copied into the blocks that jump to
//! them, so a function's `ret` need not be reached by a branch. Then blocks
//! are chained: each block is followed by a successor not yet placed,
//! preferring one that does not leave the function, so loops stay together
//! and returns go last. Finally each block's branches are rewritten for the
//! new order: a branch to the next block is dropped, and a conditional
//! branch whose target now follows it is inverted (`"inverse"` in the
//! description, with its condition inverted) to jump to the other way.

use crate::mir::*;
use crate::target::{Kind, Target};

/// Return blocks this small are copied into blocks that jump to them.
const MAX_TAIL: usize = 6;

/// How a block ends.
#[derive(Clone, Debug)]
enum Exit {
    /// With a return or a trap, as its last instruction.
    Leaves,
    /// Going on to a block, by a branch or by falling through.
    Goto(usize),
    /// A conditional branch to `taken`, else to `other`.
    Cond { branch: MInst, taken: usize, other: usize },
}

fn label_of(i: &MInst) -> Option<usize> {
    i.ops.iter().find_map(|o| if let MOp::Label(b) = o { Some(*b) } else { None })
}

/// Splits each block into its body and how it ends.
fn split(t: &Target, f: &MFunc) -> Vec<(Vec<MInst>, Exit)> {
    let b_op = Opcode::Instr(t.by_name["B"]);
    let n = f.blocks.len();
    let mut out = Vec::new();
    for (i, b) in f.blocks.iter().enumerate() {
        let mut body = b.insts.clone();
        let fall = i + 1;
        let leaves = |inst: &MInst| match inst.op {
            Opcode::Instr(k) => matches!(t.instrs[k].name.as_str(), "RET" | "BRK"),
            _ => false,
        };
        let exit = if body.last().is_some_and(leaves) {
            Exit::Leaves
        } else if body.last().is_some_and(|x| x.op == b_op) {
            let jump = body.pop().unwrap();
            let target = label_of(&jump).unwrap();
            match body.last().and_then(|x| label_of(x).map(|l| (x.clone(), l))) {
                Some((branch, taken)) => {
                    body.pop();
                    Exit::Cond { branch, taken, other: target }
                }
                None => Exit::Goto(target),
            }
        } else if let Some((branch, taken)) = body.last().and_then(|x| label_of(x).map(|l| (x.clone(), l))) {
            body.pop();
            Exit::Cond { branch, taken, other: fall }
        } else {
            assert!(fall < n, "{}: the last block falls off the end", f.name);
            Exit::Goto(fall)
        };
        out.push((body, exit));
    }
    out
}

/// The conditional branch taken exactly when `branch` is not.
fn invert(t: &Target, branch: &MInst) -> Option<MInst> {
    let Opcode::Instr(k) = branch.op else { return None };
    let ins = &t.instrs[k];
    let inv = *t.by_name.get(ins.inverse.as_deref()?)?;
    let mut ops = branch.ops.clone();
    for (o, op) in ins.operands.iter().zip(&mut ops) {
        if o.kind == Kind::Cond
            && let MOp::Imm(c) = op
        {
            *c = t.inverse_cond(*c)?;
        }
    }
    Some(MInst::new(inv, ops))
}

pub fn place(t: &Target, f: &mut MFunc) {
    let mut parts = split(t, f);
    let n = parts.len();

    // Copy small return blocks into the blocks that go to them.
    for r in 0..n {
        if !matches!(parts[r].1, Exit::Leaves) || parts[r].0.len() > MAX_TAIL {
            continue;
        }
        let tail = parts[r].0.clone();
        for p in 0..n {
            if p != r && matches!(parts[p].1, Exit::Goto(x) if x == r) {
                parts[p].0.extend(tail.iter().cloned());
                parts[p].1 = Exit::Leaves;
            }
        }
    }

    let succs = |e: &Exit| -> Vec<usize> {
        match e {
            Exit::Leaves => vec![],
            Exit::Goto(x) => vec![*x],
            Exit::Cond { taken, other, .. } => vec![*other, *taken],
        }
    };
    let leaves = |b: usize| matches!(parts[b].1, Exit::Leaves);
    // Which blocks anything still reaches.
    let mut reached = vec![false; n];
    let mut stack = vec![0];
    while let Some(b) = stack.pop() {
        if !std::mem::replace(&mut reached[b], true) {
            stack.extend(succs(&parts[b].1));
        }
    }

    // Chain blocks: after each, a successor not yet placed, staying in the
    // function rather than leaving it.
    let mut placed = vec![false; n];
    let mut order = vec![0usize];
    placed[0] = true;
    loop {
        let cur = *order.last().unwrap();
        let cands: Vec<usize> = succs(&parts[cur].1).into_iter().filter(|&s| !placed[s] && reached[s]).collect();
        let next = cands
            .iter()
            .copied()
            .find(|&s| !leaves(s))
            .or_else(|| cands.first().copied())
            .or_else(|| (0..n).find(|&b| !placed[b] && reached[b] && !leaves(b)))
            .or_else(|| (0..n).find(|&b| !placed[b] && reached[b]));
        let Some(next) = next else { break };
        placed[next] = true;
        order.push(next);
    }

    // Rebuild the blocks, with branches for the new order.
    let mut index = vec![usize::MAX; n];
    for (k, &b) in order.iter().enumerate() {
        index[b] = k;
    }
    let b_op = t.by_name["B"];
    let relabel = |inst: &mut MInst| {
        for op in &mut inst.ops {
            if let MOp::Label(x) = op {
                *x = index[*x];
            }
        }
    };
    let old = std::mem::take(&mut f.blocks);
    for (k, &b) in order.iter().enumerate() {
        let next = order.get(k + 1).copied();
        let (body, exit) = parts[b].clone();
        let mut insts = body;
        match exit {
            Exit::Leaves => {}
            Exit::Goto(x) => {
                if Some(x) != next {
                    insts.push(MInst::new(b_op, vec![MOp::Label(x)]));
                }
            }
            Exit::Cond { branch, taken, other } => {
                let with_label = |mut i: MInst, to: usize| {
                    for op in &mut i.ops {
                        if let MOp::Label(x) = op {
                            *x = to;
                        }
                    }
                    i
                };
                if Some(other) == next {
                    insts.push(with_label(branch, taken));
                } else if let (Some(true), Some(inv)) = (next.map(|x| x == taken), invert(t, &branch)) {
                    insts.push(with_label(inv, other));
                } else {
                    insts.push(with_label(branch, taken));
                    insts.push(MInst::new(b_op, vec![MOp::Label(other)]));
                }
            }
        }
        for i in &mut insts {
            relabel(i);
        }
        let mut block = old[b].clone();
        block.insts = insts;
        f.blocks.push(block);
    }
}
