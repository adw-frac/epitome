//! Passes over machine instructions after selection.
//!
//! **Redundant compares.** Selection makes each user of a comparison with
//! its own compare, since a pattern covers the compare and what reads the
//! flags together: `(a < b) + (a == b) * 2` compares `a` with `b` twice. In
//! a block, a compare the same as the last instruction that set the flags
//! (the same instruction, on the same operands) is removed, when nothing
//! between them wrote the flags or the operands. What may write the flags is
//! an instruction that sets them (`"sets"` in the description), one that
//! clobbers them (x86's arithmetic: `"clobbers"="flags"`), a call, anything
//! else that clobbers registers (`imp_defs`), and inline assembly.
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
                // (Never a barrier: x86's fucompi also pops the x87 stack.)
                if !inst.barrier
                    && last.as_ref().is_some_and(|l| l.op == inst.op && l.ops == inst.ops)
                    && epitome_ir::chop::allow(|| format!("{name}: remove a compare the same as the last"))
                {
                    removed += 1;
                    continue;
                }
                last = Some(inst.clone());
                keep.push(inst);
                continue;
            }
            let clobbers = matches!(inst.op, Opcode::Instr(i) if t.instrs[i].clobbers_flags);
            if matches!(inst.op, Opcode::Asm { .. }) || !inst.imp_defs.is_empty() || clobbers {
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

/// **Stack slots addressed from `sp`.** Selection makes each alloca's
/// address once, `add d, sp, #slot`, and uses `d` everywhere, so `d` lives
/// across the whole function (in a callee-saved register, saved and
/// restored). Instead, a load, store or add whose operand is `d` plus an
/// immediate (`Instr::base_offset`) takes `sp` and the slot directly
/// (`[sp, #slot+k]`), and any other use gets its own `add t, sp, #slot`
/// just before it. Frame lowering makes the slot operands offsets (from the
/// base register where `sp` moves), and copes with those too far for an
/// instruction. Returns how many uses changed.
pub fn frame_addresses(t: &Target, mf: &mut MFunc) -> usize {
    let sp = t.machine.sp;
    let Some(addi) = t.role("addi") else { return 0 };
    // Virtual registers defined once, by `add d, sp, #slot`.
    let mut defs: std::collections::HashMap<VReg, usize> = std::collections::HashMap::new();
    let mut frame_of: std::collections::HashMap<VReg, (usize, i64)> = std::collections::HashMap::new();
    for b in &mf.blocks {
        for inst in &b.insts {
            let (ds, _) = inst.defs_uses(t);
            for k in ds {
                if let MOp::Reg(Reg::V(v)) = inst.ops[k] {
                    *defs.entry(v).or_default() += 1;
                    if let (Opcode::Instr(i), [_, MOp::Reg(Reg::P(base)), MOp::Frame(s, o)]) = (inst.op, &inst.ops[..])
                        && (i == addi || t.instrs[i].address_of && t.instrs[i].base_offset == Some((1, 2)))
                        && *base == sp
                    {
                        frame_of.insert(v, (*s, *o));
                    }
                }
            }
        }
    }
    frame_of.retain(|v, _| defs.get(v) == Some(&1));
    if frame_of.is_empty() {
        return 0;
    }
    let mut changed = 0;
    let mut vclass = std::mem::take(&mut mf.vclass);
    for b in &mut mf.blocks {
        let old = std::mem::take(&mut b.insts);
        let mut new = Vec::with_capacity(old.len());
        for mut inst in old {
            // The definitions themselves go; every use makes its own.
            if let Opcode::Instr(i) = inst.op
                && (i == addi || t.instrs[i].address_of)
                && let MOp::Reg(Reg::V(v)) = inst.ops[0]
                && frame_of.contains_key(&v)
            {
                continue;
            }
            let (ds, us) = inst.defs_uses(t);
            // base + immediate: the slot, from sp.
            if let Opcode::Instr(i) = inst.op
                && let Some((base, off)) = t.instrs[i].base_offset
                && let (MOp::Reg(Reg::V(v)), MOp::Imm(k)) = (inst.ops[base].clone(), inst.ops[off].clone())
                && let Some(&(s, o)) = frame_of.get(&v)
                && !ds.contains(&base)
                // Below the slot: an offset from sp an instruction may not
                // take (unsigned offsets); left as base and offset.
                && o + k >= 0
            {
                inst.ops[base] = MOp::Reg(Reg::P(sp));
                inst.ops[off] = MOp::Frame(s, o + k);
                changed += 1;
            }
            // Any other use: the address made again just before.
            for k in us {
                if let MOp::Reg(Reg::V(v)) = inst.ops[k]
                    && let Some(&(s, o)) = frame_of.get(&v)
                {
                    let tmp = vclass.len() as VReg;
                    vclass.push(vclass[v as usize]);
                    new.push(MInst::new(addi, vec![MOp::Reg(Reg::V(tmp)), MOp::Reg(Reg::P(sp)), MOp::Frame(s, o)]));
                    inst.ops[k] = MOp::Reg(Reg::V(tmp));
                    changed += 1;
                }
            }
            new.push(inst);
        }
        b.insts = new;
    }
    mf.vclass = vclass;
    changed
}

/// **Load and store pairs.** After frame lowering, when offsets are final:
/// two neighbouring loads (or stores) of one register class, from one base
/// register at offsets one register's width apart, become one pair
/// instruction (`ldp`, `stp`), when the description has one for the class
/// (roles `load.pair.<class>`, `store.pair.<class>`) and it holds the lower
/// offset. For loads, the two destinations differ, and the first does not
/// overwrite the base the second reads. Each pair is an elective change
/// (autochop). Returns how many pairs were made.
pub fn pair_memory(t: &Target, mf: &mut MFunc) -> usize {
    // Each single load or store with a pair: (its class's pair, width,
    // whether a load).
    let mut single: std::collections::HashMap<usize, (usize, i64, bool)> = std::collections::HashMap::new();
    for cd in &t.machine.classes {
        let (c, bytes) = (&cd.name, (cd.bits / 8) as i64);
        if bytes == 0 {
            continue;
        }
        for (load, kind) in [(true, "load"), (false, "store")] {
            if let (Some(one), Some(two)) = (t.role(&format!("{kind}.{c}")), t.role(&format!("{kind}.pair.{c}"))) {
                single.insert(one, (two, bytes, load));
            }
        }
    }
    if single.is_empty() {
        return 0;
    }
    // (instruction's single, register, base, offset)
    let access = |inst: &MInst| -> Option<(usize, u8, u8, i64)> {
        // An atomic access (a monotonic one is a plain load or store) is a
        // barrier: never merged.
        if inst.barrier {
            return None;
        }
        let Opcode::Instr(i) = inst.op else { return None };
        single.get(&i)?;
        match inst.ops[..] {
            [MOp::Reg(Reg::P(r)), MOp::Reg(Reg::P(base)), MOp::Imm(k)] => Some((i, r, base, k)),
            _ => None,
        }
    };
    let name = mf.name.clone();
    let mut made = 0;
    for b in &mut mf.blocks {
        let old = std::mem::take(&mut b.insts);
        let mut new = Vec::with_capacity(old.len());
        let mut k = 0;
        while k < old.len() {
            if let (Some((i, ra, base, ka)), Some((j, rb, base_b, kb))) =
                (access(&old[k]), old.get(k + 1).and_then(access))
                && i == j
                && base == base_b
            {
                let (pair, width, load) = single[&i];
                let ((lo_r, lo_k), (hi_r, _)) = if ka < kb { ((ra, ka), (rb, kb)) } else { ((rb, kb), (ra, ka)) };
                let apart = (ka - kb).abs() == width;
                // A load pair writes both at once: two different registers,
                // and the first of the two loads must not change the base.
                let ok_load = !load || (ra != rb && ra != base);
                if apart
                    && ok_load
                    && t.instrs[pair].fits(&[None, None, None, Some(lo_k)])
                    && epitome_ir::chop::allow(|| format!("{name}: pair two accesses at [{base}, #{lo_k}]"))
                {
                    let r = |n: u8| MOp::Reg(Reg::P(n));
                    new.push(MInst::new(pair, vec![r(lo_r), r(hi_r), r(base), MOp::Imm(lo_k)]));
                    made += 1;
                    k += 2;
                    continue;
                }
            }
            new.push(old[k].clone());
            k += 1;
        }
        b.insts = new;
    }
    made
}
