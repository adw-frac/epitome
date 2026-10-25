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
use crate::target::{Kind, Target};

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
/// two loads (or stores) of one register class, neighbours or with only
/// instructions between that touch no memory and leave the second's
/// registers alone (it moves up to the first), from one base
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
    // What an instruction between two accesses must not be, for the second
    // to move up to the first: one that touches memory, calls or orders.
    let fence = |inst: &MInst| {
        inst.barrier
            || !inst.imp_defs.is_empty()
            || match inst.op {
                Opcode::Instr(k) => t.instrs[k].memory,
                Opcode::Asm { .. } => true,
                _ => false,
            }
    };
    for b in &mut mf.blocks {
        let old = std::mem::take(&mut b.insts);
        let mut gone = vec![false; old.len()];
        let mut new = Vec::with_capacity(old.len());
        for k in 0..old.len() {
            if gone[k] {
                continue;
            }
            let Some((i, ra, base, ka)) = access(&old[k]) else {
                new.push(old[k].clone());
                continue;
            };
            let (pair, width, load) = single[&i];
            // The next access, if nothing between touches memory.
            let Some(j) = (k + 1..old.len().min(k + 7)).find(|&j| access(&old[j]).is_some() || fence(&old[j])) else {
                new.push(old[k].clone());
                continue;
            };
            let mut paired = false;
            if let Some((i2, rb, base_b, kb)) = access(&old[j])
                && !gone[j]
                && i2 == i
                && base == base_b
            {
                // The second moves up past those between: they must not
                // write the base, or read or write the second's register
                // (a load's result; a store's value, written).
                let clear = old[k + 1..j].iter().all(|between| {
                    let (defs, uses) = between.defs_uses(t);
                    let names = |ks: &[usize], r: u8| ks.iter().any(|&q| between.ops[q] == MOp::Reg(Reg::P(r)));
                    !names(&defs, base) && !names(&defs, rb) && !(load && names(&uses, rb))
                });
                let ((lo_r, lo_k), (hi_r, _)) = if ka < kb { ((ra, ka), (rb, kb)) } else { ((rb, kb), (ra, ka)) };
                let apart = (ka - kb).abs() == width;
                // A load pair writes both at once: two different registers,
                // and the first of the two loads must not change the base
                // (nor the second, moved up past what reads it).
                let ok_load = !load || (ra != rb && ra != base && (j == k + 1 || rb != base));
                if clear
                    && apart
                    && ok_load
                    && t.instrs[pair].fits(&[None, None, None, Some(lo_k)])
                    && epitome_ir::chop::allow(|| format!("{name}: pair two accesses at [{base}, #{lo_k}]"))
                {
                    let r = |n: u8| MOp::Reg(Reg::P(n));
                    new.push(MInst::new(pair, vec![r(lo_r), r(hi_r), r(base), MOp::Imm(lo_k)]));
                    made += 1;
                    gone[j] = true;
                    paired = true;
                }
            }
            if !paired {
                new.push(old[k].clone());
            }
        }
        b.insts = new;
    }
    made
}

/// **Short forms.** After allocation, where the description has them (x86):
/// a move of 0 into a register becomes its zero idiom (role
/// `zero.<class>`, x86's `xor` of the register with itself, two bytes for
/// five) where the flags, which that clobbers, are dead after it: written
/// again before anything reads them, or never read in the block (nothing
/// keeps them from one block to the next). And a compare of a register
/// with 0 (role `cmpi.<class>`) becomes a test of it with itself (role
/// `test.<class>`, a byte shorter), which sets the flags as the compare
/// does. Each change is an elective one (autochop). Returns how many.
/// `vzeroupper` (the description's role `vzeroupper`) before each return
/// and call of a function that uses registers of 256 bits or more: code
/// after it that uses only the low 128 bits of the vector registers, with
/// legacy SSE encodings, would otherwise wait on their upper halves (the
/// transition between AVX and SSE). As LLVM's x86 back end does; not
/// before a return of a wide vector (`at_returns` false), nor before calls
/// when some call passes one (`at_calls` false). The number put in.
pub fn upper_halves(t: &Target, mf: &mut MFunc, at_returns: bool, at_calls: bool) -> usize {
    let Some(vz) = t.role("vzeroupper") else { return 0 };
    let m = &t.machine;
    let wide = mf.blocks.iter().flat_map(|b| &b.insts).any(|inst| match inst.op {
        Opcode::Instr(k) => t.instrs[k].operands.iter().any(|o| matches!(o.kind, Kind::Reg(c) if m.def(c).bits >= 256)),
        _ => false,
    });
    if !wide {
        return 0;
    }
    let mut made = 0;
    for b in &mut mf.blocks {
        let mut k = 0;
        while k < b.insts.len() {
            let call = b.insts[k].is_call(t);
            let ret = matches!(b.insts[k].op, Opcode::Instr(i) if t.has_role(i, "ret"));
            let tail =
                matches!(b.insts[k].op, Opcode::Instr(i) if t.has_role(i, "tailcall") || t.has_role(i, "tailcallr"));
            let leaves = (ret && at_returns) || ((call || tail) && at_calls);
            if leaves {
                b.insts.insert(k, MInst::new(vz, Vec::new()));
                made += 1;
                k += 1;
            }
            k += 1;
        }
    }
    made
}

pub fn short_forms(t: &Target, mf: &mut MFunc) -> usize {
    let m = &t.machine;
    let class_name = |k: usize| match t.instrs[k].operands.first().map(|o| o.kind) {
        Some(Kind::Reg(c)) => Some(m.def(c).name.clone()),
        _ => None,
    };
    let name = mf.name.clone();
    let mut made = 0;
    for b in &mut mf.blocks {
        for k in 0..b.insts.len() {
            let Opcode::Instr(op) = b.insts[k].op else { continue };
            // A compare with 0: a test.
            if let [MOp::Reg(r), MOp::Imm(0)] = b.insts[k].ops[..]
                && let Some(c) = class_name(op)
                && t.has_role(op, &format!("cmpi.{c}"))
                && let Some(test) = t.role(&format!("test.{c}"))
                && epitome_ir::chop::allow(|| format!("{name}: test a register against itself for a compare with 0"))
            {
                b.insts[k] = MInst::new(test, vec![MOp::Reg(r), MOp::Reg(r)]);
                made += 1;
                continue;
            }
            // A move of 0: the zero idiom, where the flags are dead.
            if t.constants.contains(&op)
                && let [MOp::Reg(d), MOp::Imm(0)] = b.insts[k].ops[..]
                && let Some(c) = class_name(op)
                && let Some(zero) = t.role(&format!("zero.{c}"))
            {
                let dead = flags_dead(t, &b.insts[k + 1..]);
                if dead && epitome_ir::chop::allow(|| format!("{name}: zero a register by its zero idiom")) {
                    b.insts[k] = MInst::new(zero, vec![MOp::Reg(d)]);
                    made += 1;
                }
            }
        }
    }
    made
}

/// Whether the flags are dead after `rest` begins: written again before
/// anything reads them, or not read in the rest of the block.
fn flags_dead(t: &Target, rest: &[MInst]) -> bool {
    let reads = |i: &MInst| match i.op {
        Opcode::Instr(k) => t.instrs[k].operands.iter().any(|o| o.kind == Kind::Cond),
        Opcode::Asm { .. } => true,
        _ => false,
    };
    let writes = |i: &MInst| match i.op {
        Opcode::Instr(k) => t.instrs[k].sets.is_some() || t.instrs[k].clobbers_flags || i.is_call(t),
        Opcode::Asm { .. } => true,
        _ => false,
    };
    rest.iter().find(|i| reads(i) || writes(i)).is_none_or(|i| !reads(i))
}

/// **Three-address adds.** After allocation, where the description has
/// them (x86): a copy of `s` into `d` followed by a two-address add to `d`
/// (roles `add2i.<class>`, of an immediate, and `add2.<class>`, of a
/// register), whose flags are dead, becomes one three-address add that
/// leaves the flags alone (roles `addi` and `add`, x86's `lea`): `movq
/// %r15, %rax; addq $1, %rax` is `leaq 1(%r15), %rax`. Each change is an
/// elective one (autochop). Returns how many.
pub fn three_address(t: &Target, mf: &mut MFunc) -> usize {
    let m = &t.machine;
    let (Some(addi), Some(add)) = (t.role("addi"), t.role("add")) else { return 0 };
    let copies: Vec<usize> = t.copies.values().copied().collect();
    let sp = m.sp;
    let name = mf.name.clone();
    let mut made = 0;
    for b in &mut mf.blocks {
        let mut k = 0;
        while k + 1 < b.insts.len() {
            let (c, j) = (&b.insts[k], &b.insts[k + 1]);
            let (Opcode::Instr(ci), Opcode::Instr(ji)) = (c.op, j.op) else {
                k += 1;
                continue;
            };
            let [MOp::Reg(Reg::P(d)), MOp::Reg(Reg::P(s))] = c.ops[..] else {
                k += 1;
                continue;
            };
            let class = match t.instrs[ji].operands.first().map(|o| o.kind) {
                Some(Kind::Reg(cl)) => m.def(cl).name.clone(),
                _ => String::new(),
            };
            let new = match j.ops[..] {
                [MOp::Reg(Reg::P(x)), MOp::Reg(Reg::P(y)), MOp::Imm(v)]
                    if x == d && y == d && t.has_role(ji, &format!("add2i.{class}")) =>
                {
                    Some(MInst::new(addi, vec![MOp::Reg(Reg::P(d)), MOp::Reg(Reg::P(s)), MOp::Imm(v)]))
                }
                [MOp::Reg(Reg::P(x)), MOp::Reg(Reg::P(y)), MOp::Reg(Reg::P(r))]
                    if x == d && y == d && t.has_role(ji, &format!("add2.{class}")) =>
                {
                    // (d + d is s + s; an index cannot be sp.)
                    let r = if r == d { s } else { r };
                    let (base, index) = if r == sp { (r, s) } else { (s, r) };
                    (index != sp).then(|| {
                        MInst::new(add, vec![MOp::Reg(Reg::P(d)), MOp::Reg(Reg::P(base)), MOp::Reg(Reg::P(index))])
                    })
                }
                _ => None,
            };
            if let Some(new) = new
                && copies.contains(&ci)
                && d != s
                && flags_dead(t, &b.insts[k + 2..])
                && epitome_ir::chop::allow(|| format!("{name}: a copy and a two-address add as one three-address add"))
            {
                b.insts[k] = new;
                b.insts.remove(k + 1);
                made += 1;
            }
            k += 1;
        }
    }
    made
}
