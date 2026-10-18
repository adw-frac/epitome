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
use crate::target::Target;

const SP: u8 = 31;

pub fn lower(t: &Target, f: &mut MFunc) -> Result<(), String> {
    let (fp_reg, lr_reg) = (f.abi.fp, f.abi.lr);
    let mut callee_saved = f.abi.callee_saved();
    callee_saved.extend(f.abi.fp_callee_saved());
    // Callee-saved registers written anywhere.
    let mut saved: Vec<u8> = Vec::new();
    for b in &f.blocks {
        for inst in &b.insts {
            let (defs, _) = inst.defs_uses(t);
            for k in defs {
                if let MOp::Reg(Reg::P(r)) = inst.ops[k]
                    && callee_saved.contains(&r)
                    && !saved.contains(&r)
                {
                    saved.push(r);
                }
            }
        }
    }
    saved.sort();
    // Arguments for calls go at the bottom, where the callee finds them.
    let mut off: i64 = f.out_size;
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
    // Offsets from sp of up to 32760 reach saved registers with one
    // scaled store; adjusting sp takes one or two immediates of 12 bits.
    if size > 32760 {
        return Err(format!("{}: a frame of {size} bytes is too big for now", f.name));
    }

    // Frame offsets become immediates.
    for b in &mut f.blocks {
        for inst in &mut b.insts {
            for op in &mut inst.ops {
                match op {
                    MOp::Frame(s, o) => *op = MOp::Imm(f.slots[*s].offset + *o),
                    MOp::Incoming(o) => *op = MOp::Imm(size + *o),
                    _ => {}
                }
            }
        }
    }

    let ldr = t.by_role("load.x");
    let str_ = t.by_role("store.x");
    let r = |n: u8| MOp::Reg(Reg::P(n));
    let mut prologue = Vec::new();
    if size > 0 {
        adjust(t, &mut prologue, SP, SP, -size);
    }
    if calls {
        prologue.push(MInst::new(str_, vec![r(fp_reg), r(SP), MOp::Imm(fp_at)]));
        prologue.push(MInst::new(str_, vec![r(lr_reg), r(SP), MOp::Imm(fp_at + 8)]));
        adjust(t, &mut prologue, fp_reg, SP, fp_at);
    }
    let (ldr_d, str_d) = (t.by_role("load.d"), t.by_role("store.d"));
    for &(reg, at) in &save_at {
        prologue.push(MInst::new(if reg >= 32 { str_d } else { str_ }, vec![r(reg), r(SP), MOp::Imm(at)]));
    }
    let mut epilogue = Vec::new();
    for &(reg, at) in &save_at {
        epilogue.push(MInst::new(if reg >= 32 { ldr_d } else { ldr }, vec![r(reg), r(SP), MOp::Imm(at)]));
    }
    if calls {
        epilogue.push(MInst::new(ldr, vec![r(fp_reg), r(SP), MOp::Imm(fp_at)]));
        epilogue.push(MInst::new(ldr, vec![r(lr_reg), r(SP), MOp::Imm(fp_at + 8)]));
    }
    if size > 0 {
        adjust(t, &mut epilogue, SP, SP, size);
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

/// `dst = src + amount`, for a frame's sizes: an immediate shifted by 12
/// for the 4KB pages, then one for the rest.
fn adjust(t: &Target, out: &mut Vec<MInst>, dst: u8, src: u8, amount: i64) {
    let r = |n: u8| MOp::Reg(Reg::P(n));
    let (op, op12) =
        if amount < 0 { (t.by_role("subi"), t.by_role("subi12")) } else { (t.by_role("addi"), t.by_role("addi12")) };
    let a = amount.abs();
    let (pages, rest) = (a & !0xfff, a & 0xfff);
    let mut from = src;
    if pages != 0 {
        out.push(MInst::new(op12, vec![r(dst), r(from), MOp::Imm(pages)]));
        from = dst;
    }
    if rest != 0 || pages == 0 {
        out.push(MInst::new(op, vec![r(dst), r(from), MOp::Imm(rest)]));
    }
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
