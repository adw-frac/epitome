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
use crate::unwind::Cfi;

pub fn lower(t: &Target, f: &mut MFunc) -> Result<(), String> {
    let (fp_reg, lr_reg) = (f.abi.fp, f.abi.lr);
    let mut callee_saved = f.abi.callee_saved();
    callee_saved.extend(f.abi.fp_callee_saved());
    // Callee-saved registers written anywhere.
    let mut saved: Vec<u8> = Vec::new();
    for b in &f.blocks {
        for inst in &b.insts {
            let (defs, _) = inst.defs_uses(t);
            let written =
                defs.iter().filter_map(|&k| if let MOp::Reg(Reg::P(r)) = inst.ops[k] { Some(r) } else { None });
            // And those inline assembly clobbers.
            let clobbered = if matches!(inst.op, Opcode::Asm { .. }) { inst.imp_defs.clone() } else { vec![] };
            for r in written.chain(clobbered) {
                if callee_saved.contains(&r) && !saved.contains(&r) {
                    saved.push(r);
                }
            }
        }
    }
    // Where sp moves, the frame is addressed from the base register, which
    // is saved like the others.
    let base = if f.dynamic_stack {
        let b = f.abi.base.ok_or_else(|| format!("{}: sp moves, and the convention names no base register", f.name))?;
        if !saved.contains(&b) {
            saved.push(b);
        }
        Some(b)
    } else {
        None
    };
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
    let calls =
        f.blocks.iter().any(|b| b.insts.iter().any(|i| !i.imp_defs.is_empty() && !matches!(i.op, Opcode::Asm { .. })));
    let record = if calls { 16 } else { 0 };
    let size = (off + record + 15) / 16 * 16;
    let fp_at = size - 16;
    f.frame_size = size;
    // Offsets from sp of up to 32760 reach saved registers with one
    // scaled store; adjusting sp takes one or two immediates of 12 bits.
    if size > 32760 {
        return Err(format!("{}: a frame of {size} bytes is too big for now", f.name));
    }

    // Frame offsets become immediates. Where one is more than the
    // instruction's immediate holds (RISC-V's reach 2047 bytes), the
    // address is made in a scratch register the instruction does not use:
    // the offset, added to the base; the instruction then uses offset 0.
    let far = f.abi.far_scratch;
    for b in &mut f.blocks {
        let old = std::mem::take(&mut b.insts);
        for mut inst in old {
            let mut at = None;
            for (k, op) in inst.ops.iter_mut().enumerate() {
                match op {
                    MOp::Frame(s, o) => {
                        *op = MOp::Imm(f.slots[*s].offset + *o);
                        at = Some(k);
                    }
                    MOp::Incoming(o) => {
                        *op = MOp::Imm(size + *o);
                        at = Some(k);
                    }
                    MOp::OutArea => *op = MOp::Imm(f.out_size),
                    _ => {}
                }
            }
            if let (Some(k), Some(b)) = (at, base)
                && k > 0
                && inst.ops[k - 1] == MOp::Reg(Reg::P(t.machine.sp))
            {
                inst.ops[k - 1] = MOp::Reg(Reg::P(b));
            }
            if let (Some(k), Opcode::Instr(i)) = (at, inst.op)
                && k > 0
                && let MOp::Imm(off) = inst.ops[k]
                && let MOp::Reg(Reg::P(base)) = inst.ops[k - 1]
            {
                let values: Vec<Option<i64>> =
                    inst.ops.iter().map(|o| if let MOp::Imm(v) = o { Some(*v) } else { None }).collect();
                if !t.instrs[i].fits(&values) {
                    let tmp = far.ok_or_else(|| {
                        format!("{}: a frame offset of {off}, and the convention names no far-scratch register", f.name)
                    })?;
                    let add = t.role("add").ok_or("no \"add\" instruction for a far frame offset")?;
                    constant(t, &mut b.insts, tmp, off)?;
                    b.insts.push(MInst::new(
                        add,
                        vec![MOp::Reg(Reg::P(tmp)), MOp::Reg(Reg::P(base)), MOp::Reg(Reg::P(tmp))],
                    ));
                    inst.ops[k - 1] = MOp::Reg(Reg::P(tmp));
                    inst.ops[k] = MOp::Imm(0);
                }
            }
            b.insts.push(inst);
        }
    }

    // Registers saved and restored two at a time where they can be: two of
    // the same file at neighbouring slots, at an offset a pair reaches.
    let mut slots: Vec<(u8, i64)> = Vec::new();
    if calls {
        slots.push((fp_reg, fp_at));
        slots.push((lr_reg, fp_at + 8));
    }
    slots.extend(save_at.iter().copied());
    // Where the saves are too far from sp for a store's offset (RISC-V's
    // reach 2047 bytes), the frame is made in two steps: the part above the
    // lowest save first, with the saves near sp, then the rest.
    let sp = t.machine.sp;
    let reaches = |slots: &[(u8, i64)]| {
        slots.iter().all(|&(reg, at)| {
            let role = format!("store.{}", t.machine.save_name(reg));
            t.role(&role).is_some_and(|i| t.instrs[i].fits(&[None, None, Some(at)]))
        })
    };
    let low = if reaches(&slots) { 0 } else { slots.iter().map(|s| s.1).min().unwrap_or(0) / 16 * 16 };
    let near: Vec<(u8, i64)> = slots.iter().map(|&(reg, at)| (reg, at - low)).collect();
    let (saves, restores) = save_restore(t, &near);
    // The unwind rules (unwind.rs) go after what they describe: where the
    // CFA (sp on entry) is after each move of sp, and where each register
    // was saved, from the CFA.
    let cfi = |c: Cfi| MInst { op: Opcode::Cfi(c), ..MInst::new(0, vec![]) };
    let mut prologue = Vec::new();
    if size - low > 0 {
        adjust(t, &mut prologue, sp, sp, -(size - low), &f.abi.scratch)?;
        prologue.push(cfi(Cfi::DefCfaOffset(size - low)));
    }
    prologue.extend(saves);
    prologue.extend(slots.iter().map(|&(reg, at)| cfi(Cfi::Offset(reg, at - size))));
    if calls {
        adjust(t, &mut prologue, fp_reg, sp, fp_at - low, &f.abi.scratch)?;
    }
    if low > 0 {
        adjust(t, &mut prologue, sp, sp, -low, &f.abi.scratch)?;
        prologue.push(cfi(Cfi::DefCfaOffset(size)));
    }
    let mut epilogue = Vec::new();
    if let Some(b) = base {
        let addi = t.by_role("addi");
        prologue.push(MInst::new(addi, vec![MOp::Reg(Reg::P(b)), MOp::Reg(Reg::P(sp)), MOp::Imm(0)]));
        prologue.push(cfi(Cfi::DefCfa(b, size)));
        epilogue.push(MInst::new(addi, vec![MOp::Reg(Reg::P(sp)), MOp::Reg(Reg::P(b)), MOp::Imm(0)]));
    }
    if low > 0 {
        adjust(t, &mut epilogue, sp, sp, low, &f.abi.scratch)?;
    }
    epilogue.extend(restores);
    if size - low > 0 {
        adjust(t, &mut epilogue, sp, sp, size - low, &f.abi.scratch)?;
    }

    // Before each return, and each tail call (whose callee returns to this
    // function's caller).
    let leaves =
        |inst: &MInst| matches!(inst.op, Opcode::Instr(k) if t.has_role(k, "ret") || t.has_role(k, "tailcall"));
    for b in &mut f.blocks {
        let old = std::mem::take(&mut b.insts);
        for inst in old {
            if leaves(&inst) {
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

/// The stores that save registers at their offsets from `sp`, and the loads
/// that restore them: `stp` and `ldp` for two of the same register file at
/// neighbouring slots, if a pair's offset can hold it; else `str` and
/// `ldr`.
fn save_restore(t: &Target, slots: &[(u8, i64)]) -> (Vec<MInst>, Vec<MInst>) {
    let r = |n: u8| MOp::Reg(Reg::P(n));
    let file = |reg: u8| t.machine.save_name(reg);
    let (mut saves, mut restores) = (Vec::new(), Vec::new());
    let mut k = 0;
    while k < slots.len() {
        let (a, at) = slots[k];
        if let Some(&(b, bt)) = slots.get(k + 1)
            && file(a) == file(b)
            && bt == at + 8
        {
            let pair = t.role(&format!("store.pair.{}", file(a))).zip(t.role(&format!("load.pair.{}", file(a))));
            if let Some((stp, ldp)) = pair
                && t.instrs[stp].fits(&[None, None, None, Some(at)])
            {
                saves.push(MInst::new(stp, vec![r(a), r(b), r(t.machine.sp), MOp::Imm(at)]));
                restores.push(MInst::new(ldp, vec![r(a), r(b), r(t.machine.sp), MOp::Imm(at)]));
                k += 2;
                continue;
            }
        }
        let st = t.by_role(&format!("store.{}", file(a)));
        let ld = t.by_role(&format!("load.{}", file(a)));
        saves.push(MInst::new(st, vec![r(a), r(t.machine.sp), MOp::Imm(at)]));
        restores.push(MInst::new(ld, vec![r(a), r(t.machine.sp), MOp::Imm(at)]));
        k += 1;
    }
    (saves, restores)
}

/// `dst = src + amount`, for a frame's sizes: one add (or subtract) of an
/// immediate if the description has one that holds it; else, where it has
/// them (AArch64), an immediate shifted by 12 for the 4KB pages and one for
/// the rest.
fn adjust(t: &Target, out: &mut Vec<MInst>, dst: u8, src: u8, amount: i64, scratch: &[u8]) -> Result<(), String> {
    let r = |n: u8| MOp::Reg(Reg::P(n));
    let fits = |role: &str, v: i64| t.role(role).filter(|&i| t.instrs[i].fits(&[None, None, Some(v)]));
    if let Some(i) = fits("addi", amount) {
        out.push(MInst::new(i, vec![r(dst), r(src), MOp::Imm(amount)]));
        return Ok(());
    }
    if amount < 0
        && let Some(i) = fits("subi", -amount)
    {
        out.push(MInst::new(i, vec![r(dst), r(src), MOp::Imm(-amount)]));
        return Ok(());
    }
    let (op, op12) = if amount < 0 { (t.role("subi"), t.role("subi12")) } else { (t.role("addi"), t.role("addi12")) };
    let (Some(op), Some(op12)) = (op, op12) else {
        // Else the amount, made in a scratch register, added.
        let scratch = *scratch.first().ok_or("no scratch register for a large frame")?;
        constant(t, out, scratch, amount)?;
        let add = t.role("add").ok_or("no \"add\" instruction for a large frame")?;
        out.push(MInst::new(add, vec![r(dst), r(src), r(scratch)]));
        return Ok(());
    };
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
    Ok(())
}

/// Integer `v` in register `reg`, for frame sizes: by one of the
/// description's constant instructions if it holds it, else by one for the
/// high part and an add-immediate (`"addi"`) for the low 12 bits.
fn constant(t: &Target, out: &mut Vec<MInst>, reg: u8, v: i64) -> Result<(), String> {
    let r = |n: u8| MOp::Reg(Reg::P(n));
    let wide = |ci: &usize| t.instrs[*ci].operands[0].bits == 64;
    if let Some(&ci) = t.constants.iter().filter(|ci| wide(ci)).find(|&&ci| t.instrs[ci].fits(&[None, Some(v)])) {
        out.push(MInst::new(ci, vec![r(reg), MOp::Imm(v)]));
        return Ok(());
    }
    let add = t.role("addi").ok_or("no \"addi\" instruction")?;
    let lo = (v << 52) >> 52;
    let hi = v - lo;
    let ci = t
        .constants
        .iter()
        .copied()
        .filter(|ci| wide(ci))
        .find(|&ci| t.instrs[ci].fits(&[None, Some(hi)]))
        .ok_or_else(|| format!("no way to make the frame size {v}"))?;
    if !t.instrs[add].fits(&[None, None, Some(lo)]) {
        return Err(format!("no way to make the frame size {v}"));
    }
    out.push(MInst::new(ci, vec![r(reg), MOp::Imm(hi)]));
    out.push(MInst::new(add, vec![r(reg), r(reg), MOp::Imm(lo)]));
    Ok(())
}

/// A block holding only `b X` is skipped: branches to it go to `X`. Blocks
/// no longer reached are removed, and branches to the next block dropped.
fn tidy_branches(t: &Target, f: &mut MFunc) {
    let b_op = Opcode::Instr(t.by_role("jump"));
    let ends_flow = |t: &Target, b: &MBlock| {
        b.insts.last().is_some_and(|i| match i.op {
            Opcode::Instr(k) => {
                t.has_role(k, "jump") || t.has_role(k, "ret") || t.has_role(k, "trap") || t.has_role(k, "tailcall")
            }
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
