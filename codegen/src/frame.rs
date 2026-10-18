//! Frames: laying out stack slots, saving registers, and tidying branches.
//!
//! The frame, from `sp` up: locals and spill slots, then the callee-saved
//! registers the function uses, then the caller's frame pointer and the
//! return address, where `x29` points. Its size is a multiple of 16.
//!
//! A function that makes no calls keeps its return address in `x30` and
//! needs no frame record; with no slots and no saved registers either, it
//! has no frame at all.

use crate::mir::*;
use crate::regalloc::CALLEE_SAVED;
use crate::target::Target;

const SP: u8 = 31;
const FP: u8 = 29;
const LR: u8 = 30;

pub fn lower(t: &Target, f: &mut MFunc) -> Result<(), String> {
    // Callee-saved registers written anywhere.
    let mut saved: Vec<u8> = Vec::new();
    for b in &f.blocks {
        for inst in &b.insts {
            let (defs, _) = inst.defs_uses(t);
            for k in defs {
                if let MOp::Reg(Reg::P(r)) = inst.ops[k]
                    && CALLEE_SAVED.contains(&r)
                    && !saved.contains(&r)
                {
                    saved.push(r);
                }
            }
        }
    }
    saved.sort();
    let mut off: i64 = 0;
    for s in &mut f.slots {
        let a = s.align as i64;
        off = (off + a - 1) / a * a;
        s.offset = off;
        off += s.size as i64;
    }
    off = (off + 7) / 8 * 8;
    let save_at: Vec<(u8, i64)> = saved.iter().enumerate().map(|(k, &r)| (r, off + 8 * k as i64)).collect();
    off += 8 * saved.len() as i64;
    let calls = f.blocks.iter().any(|b| b.insts.iter().any(|i| !i.imp_defs.is_empty()));
    let record = if calls { 16 } else { 0 };
    let size = (off + record + 15) / 16 * 16;
    let fp_at = size - 16;
    f.frame_size = size;
    if size > 4095 {
        return Err(format!("{}: a frame of {size} bytes is too big for now", f.name));
    }

    // Frame offsets become immediates.
    for b in &mut f.blocks {
        for inst in &mut b.insts {
            for op in &mut inst.ops {
                if let MOp::Frame(s, o) = op {
                    *op = MOp::Imm(f.slots[*s].offset + *o);
                }
            }
        }
    }

    let sub = t.by_role("subi");
    let add = t.by_role("addi");
    let ldr = t.by_role("load.x");
    let str_ = t.by_role("store.x");
    let r = |n: u8| MOp::Reg(Reg::P(n));
    let mut prologue = Vec::new();
    if size > 0 {
        prologue.push(MInst::new(sub, vec![r(SP), r(SP), MOp::Imm(size)]));
    }
    if calls {
        prologue.push(MInst::new(str_, vec![r(FP), r(SP), MOp::Imm(fp_at)]));
        prologue.push(MInst::new(str_, vec![r(LR), r(SP), MOp::Imm(fp_at + 8)]));
        prologue.push(MInst::new(add, vec![r(FP), r(SP), MOp::Imm(fp_at)]));
    }
    for &(reg, at) in &save_at {
        prologue.push(MInst::new(str_, vec![r(reg), r(SP), MOp::Imm(at)]));
    }
    let mut epilogue = Vec::new();
    for &(reg, at) in &save_at {
        epilogue.push(MInst::new(ldr, vec![r(reg), r(SP), MOp::Imm(at)]));
    }
    if calls {
        epilogue.push(MInst::new(ldr, vec![r(FP), r(SP), MOp::Imm(fp_at)]));
        epilogue.push(MInst::new(ldr, vec![r(LR), r(SP), MOp::Imm(fp_at + 8)]));
    }
    if size > 0 {
        epilogue.push(MInst::new(add, vec![r(SP), r(SP), MOp::Imm(size)]));
    }

    let ret = t.by_name["RET"];
    for b in &mut f.blocks {
        let old = std::mem::take(&mut b.insts);
        for inst in old {
            if inst.op == Opcode::Instr(ret) {
                b.insts.extend(epilogue.iter().cloned());
            }
            b.insts.push(inst);
        }
    }
    let entry = &mut f.blocks[0].insts;
    entry.splice(0..0, prologue);
    tidy_branches(t, f);
    Ok(())
}

/// A block holding only `b X` is skipped: branches to it go to `X`. Blocks
/// no longer reached are removed, and branches to the next block dropped.
fn tidy_branches(t: &Target, f: &mut MFunc) {
    let b_op = Opcode::Instr(t.by_name["B"]);
    let ends_flow = |t: &Target, b: &MBlock| {
        b.insts.last().is_some_and(|i| match i.op {
            Opcode::Instr(k) => matches!(t.instrs[k].name.as_str(), "B" | "RET" | "BRK"),
            _ => false,
        })
    };
    // Skip blocks that only branch.
    let n = f.blocks.len();
    let mut forward: Vec<usize> = (0..n).collect();
    for (i, b) in f.blocks.iter().enumerate() {
        if let [only] = b.insts.as_slice()
            && only.op == b_op
            && let MOp::Label(x) = only.ops[0]
            && x != i
        {
            forward[i] = x;
        }
    }
    let resolve = |mut i: usize| {
        for _ in 0..n {
            if forward[i] == i {
                break;
            }
            i = forward[i];
        }
        i
    };
    for b in &mut f.blocks {
        for inst in &mut b.insts {
            for op in &mut inst.ops {
                if let MOp::Label(x) = op {
                    *x = resolve(*x);
                }
            }
        }
    }
    // Remove blocks nothing reaches.
    let mut reached = vec![false; n];
    reached[0] = true;
    for i in 0..n {
        for inst in &f.blocks[i].insts {
            for op in &inst.ops {
                if let MOp::Label(x) = op {
                    reached[*x] = true;
                }
            }
        }
        if i + 1 < n && !ends_flow(t, &f.blocks[i]) {
            reached[i + 1] = true;
        }
    }
    let mut new_index = vec![0usize; n];
    let mut k = 0;
    for i in 0..n {
        new_index[i] = k;
        if reached[i] {
            k += 1;
        }
    }
    let old = std::mem::take(&mut f.blocks);
    for (i, mut b) in old.into_iter().enumerate() {
        if !reached[i] {
            continue;
        }
        for inst in &mut b.insts {
            for op in &mut inst.ops {
                if let MOp::Label(x) = op {
                    *x = new_index[*x];
                }
            }
        }
        b.succs = b.succs.iter().map(|&s| new_index[s]).collect();
        f.blocks.push(b);
    }
    // A branch to the next block is a fall-through.
    let nb = f.blocks.len();
    for i in 0..nb {
        let drop = f.blocks[i].insts.last().is_some_and(|last| last.op == b_op && last.ops[0] == MOp::Label(i + 1));
        if drop {
            f.blocks[i].insts.pop();
        }
    }
}
