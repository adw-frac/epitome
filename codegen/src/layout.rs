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
    let b_op = Opcode::Instr(t.by_role("jump"));
    let n = f.blocks.len();
    let mut out = Vec::new();
    for (i, b) in f.blocks.iter().enumerate() {
        let mut body = b.insts.clone();
        let fall = i + 1;
        let leaves = |inst: &MInst| match inst.op {
            Opcode::Instr(k) => t.has_role(k, "ret") || t.has_role(k, "trap") || t.has_role(k, "tailcall"),
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

    // Edges to an empty block that only goes on somewhere else go there
    // directly, whether they were branches or fall-throughs.
    let skip = |parts: &Vec<(Vec<MInst>, Exit)>, mut b: usize| {
        for _ in 0..n {
            match &parts[b] {
                (body, Exit::Goto(x)) if body.is_empty() && *x != b => b = *x,
                _ => break,
            }
        }
        b
    };
    for k in 0..n {
        let exit = match parts[k].1.clone() {
            Exit::Goto(x) => Exit::Goto(skip(&parts, x)),
            Exit::Cond { branch, taken, other } => {
                Exit::Cond { branch, taken: skip(&parts, taken), other: skip(&parts, other) }
            }
            e => e,
        };
        parts[k].1 = exit;
    }

    // Copy small return blocks into the blocks that go to them.
    for r in 0..n {
        if !matches!(parts[r].1, Exit::Leaves) || parts[r].0.len() > MAX_TAIL {
            continue;
        }
        let tail = parts[r].0.clone();
        for (p, part) in parts.iter_mut().enumerate() {
            if p != r && matches!(part.1, Exit::Goto(x) if x == r) {
                part.0.extend(tail.iter().cloned());
                part.1 = Exit::Leaves;
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
    let b_op = t.by_role("jump");
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

/// Whether `inst`, at byte `pc`, can reach a block starting at `target`:
/// a field too narrow for the distance does not encode.
fn reaches(t: &Target, inst: &MInst, pc: i64, target: i64) -> bool {
    let Opcode::Instr(k) = inst.op else { return true };
    let ins = &t.instrs[k];
    let mut env = crate::enc::Env::new();
    for (o, op) in ins.operands.iter().zip(&inst.ops) {
        let v = match op {
            MOp::Reg(Reg::P(r)) => t.machine.index(*r),
            MOp::Imm(v) => *v,
            MOp::Label(_) => target - pc,
            _ => 0,
        };
        env.insert(o.name.clone(), v);
    }
    ins.enc.encode(&env).is_some()
}

/// Branch relaxation: a conditional branch whose target is out of its
/// range (19 bits of words for `b.cond` and `cbz`, 14 for `tbz`) becomes
/// the opposite branch around an unconditional one, which reaches 128MB.
// The blocks are changed while their positions are read by index.
#[allow(clippy::needless_range_loop)]
pub fn relax(t: &Target, f: &mut MFunc) {
    let b_op = t.by_role("jump");
    for _ in 0..16 {
        // Where each block and instruction starts.
        let mut starts = Vec::new();
        let mut at: Vec<Vec<i64>> = Vec::new();
        let mut n = 0i64;
        for b in &f.blocks {
            starts.push(n);
            at.push(
                b.insts
                    .iter()
                    .map(|i| {
                        let here = n;
                        n += f.bytes(i);
                        here
                    })
                    .collect(),
            );
        }
        let mut changed = false;
        for bi in 0..f.blocks.len() {
            let len = f.blocks[bi].insts.len();
            for k in 0..len {
                let inst = &f.blocks[bi].insts[k];
                let Opcode::Instr(op) = inst.op else { continue };
                if op == b_op {
                    continue;
                }
                let Some(target) = inst.ops.iter().find_map(|o| if let MOp::Label(x) = o { Some(*x) } else { None })
                else {
                    continue;
                };
                let pc = at[bi][k];
                if reaches(t, inst, pc, starts[target]) {
                    continue;
                }
                let Some(mut inv) = invert(t, inst) else { continue };
                // Where the branch goes when not taken: the jump after it,
                // or else the next block.
                let after = f.blocks[bi].insts.get(k + 1).cloned();
                let not_taken = match &after {
                    Some(j) if j.op == Opcode::Instr(b_op) => {
                        j.ops.iter().find_map(|o| if let MOp::Label(x) = o { Some(*x) } else { None })
                    }
                    Some(_) => None,
                    None => Some(bi + 1),
                };
                let Some(not_taken) = not_taken else { continue };
                // If the way not taken was a jump, it may be far too: the
                // inverted branch goes to a new block just after, holding
                // that jump.
                let near = if after.is_some() {
                    insert_after(f, bi, vec![MInst::new(b_op, vec![MOp::Label(not_taken)])]);
                    bi + 1
                } else {
                    not_taken
                };
                let target = if target > bi { target + after.is_some() as usize } else { target };
                for o in &mut inv.ops {
                    if let MOp::Label(x) = o {
                        *x = near;
                    }
                }
                let far = MInst::new(b_op, vec![MOp::Label(target)]);
                f.blocks[bi].insts.truncate(k);
                f.blocks[bi].insts.push(inv);
                f.blocks[bi].insts.push(far);
                changed = true;
                break;
            }
        }
        if !changed {
            break;
        }
    }
}

/// Inserts a block holding `insts` (whose labels are numbered as before the
/// insertion) after block `bi`, renumbering the labels of the blocks after
/// it.
fn insert_after(f: &mut MFunc, bi: usize, mut insts: Vec<MInst>) {
    for inst in &mut insts {
        for op in &mut inst.ops {
            if let MOp::Label(x) = op
                && *x > bi
            {
                *x += 1;
            }
        }
    }
    for b in &mut f.blocks {
        for inst in &mut b.insts {
            for op in &mut inst.ops {
                if let MOp::Label(x) = op
                    && *x > bi
                {
                    *x += 1;
                }
            }
        }
        for s in &mut b.succs {
            if *s > bi {
                *s += 1;
            }
        }
    }
    let label = format!("{}.far", f.blocks[bi].label);
    let succs = insts
        .iter()
        .flat_map(|i| i.ops.iter().filter_map(|o| if let MOp::Label(x) = o { Some(*x) } else { None }))
        .collect();
    f.blocks.insert(bi + 1, MBlock { label, insts, succs, term_start: 0 });
}
