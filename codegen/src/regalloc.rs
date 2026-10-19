//! Register allocation: linear scan over live ranges.
//!
//! Instruction `n` reads its operands at position `2n` and writes its
//! results at `2n + 1`, so a value last read by an instruction can share a
//! register with the value it writes. Liveness is worked out per block,
//! and each virtual register gets one segment per block it is live in,
//! from where it becomes live to where it dies or the block ends.
//!
//! Physical registers have fixed stretches where they are taken: an
//! argument from its copy to the call, a result from the call to its copy,
//! and every caller-saved register at each call. Values live across a call
//! therefore end up in callee-saved registers. Copies give hints, so that a
//! copy's two sides often share a register and the copy disappears.
//!
//! When no register is free, the value goes to a stack slot and is loaded
//! into a scratch register (`x16`, `x17`, `x15`) before each use and stored
//! after each definition.

use std::collections::{HashMap, HashSet};

use crate::mir::*;
use crate::target::Target;

/// The registers an instruction reads and writes, including implicit ones.
fn regs_of(t: &Target, inst: &MInst) -> (Vec<Reg>, Vec<Reg>) {
    let (d, u) = inst.defs_uses(t);
    let reg = |k: usize| match inst.ops[k] {
        MOp::Reg(r) => Some(r),
        _ => None,
    };
    let mut defs: Vec<Reg> = d.into_iter().filter_map(reg).collect();
    let mut uses: Vec<Reg> = u.into_iter().filter_map(reg).collect();
    defs.extend(inst.imp_defs.iter().map(|&r| Reg::P(r)));
    uses.extend(inst.imp_uses.iter().map(|&r| Reg::P(r)));
    // The zero register and the stack pointer are not allocated.
    let fixed = |r: &Reg| *r == Reg::P(t.machine.sp) || t.machine.zero.is_some_and(|z| *r == Reg::P(z));
    defs.retain(|r| !fixed(r));
    uses.retain(|r| !fixed(r));
    (defs, uses)
}

type Interval = (u32, u32);

fn overlaps(a: Interval, b: Interval) -> bool {
    a.0 <= b.1 && b.0 <= a.1
}

pub fn allocate(t: &Target, f: &mut MFunc) -> Result<(), String> {
    record_copy_widths(f);
    let abi = f.abi.clone();
    let caller_saved = abi.caller_saved();
    let callee_saved = abi.callee_saved();
    let fp_caller_saved = abi.fp_caller_saved();
    let fp_callee_saved = abi.fp_callee_saved();
    let allocatable = |r: u8| {
        caller_saved.contains(&r)
            || callee_saved.contains(&r)
            || fp_caller_saved.contains(&r)
            || fp_callee_saved.contains(&r)
    };
    let nv = f.vwide.len();
    // Positions.
    let mut block_range: Vec<Interval> = Vec::new();
    let mut n = 0u32;
    for b in &f.blocks {
        let start = 2 * n;
        n += b.insts.len() as u32;
        let end = if b.insts.is_empty() { start } else { 2 * n - 1 };
        block_range.push((start, end));
    }

    // Liveness of virtual registers.
    let nb = f.blocks.len();
    let mut gen_: Vec<HashSet<VReg>> = vec![HashSet::new(); nb];
    let mut kill: Vec<HashSet<VReg>> = vec![HashSet::new(); nb];
    for (bi, b) in f.blocks.iter().enumerate() {
        for inst in &b.insts {
            let (defs, uses) = regs_of(t, inst);
            for r in uses {
                if let Reg::V(v) = r
                    && !kill[bi].contains(&v)
                {
                    gen_[bi].insert(v);
                }
            }
            for r in defs {
                if let Reg::V(v) = r {
                    kill[bi].insert(v);
                }
            }
        }
    }
    let mut live_in: Vec<HashSet<VReg>> = vec![HashSet::new(); nb];
    let mut live_out: Vec<HashSet<VReg>> = vec![HashSet::new(); nb];
    let mut changed = true;
    while changed {
        changed = false;
        for bi in (0..nb).rev() {
            let mut out: HashSet<VReg> = HashSet::new();
            for &s in &f.blocks[bi].succs {
                out.extend(live_in[s].iter().copied());
            }
            let mut inn: HashSet<VReg> = gen_[bi].clone();
            inn.extend(out.iter().filter(|v| !kill[bi].contains(v)).copied());
            if inn.len() != live_in[bi].len() || out.len() != live_out[bi].len() {
                changed = true;
            }
            live_in[bi] = inn;
            live_out[bi] = out;
        }
    }

    // Segments, fixed stretches, hints and calls.
    let mut segs: Vec<Vec<Interval>> = vec![Vec::new(); nv];
    let mut fixed: HashMap<u8, Vec<Interval>> = HashMap::new();
    let mut hints: Vec<Vec<Reg>> = vec![Vec::new(); nv];
    let mut calls: Vec<u32> = Vec::new();
    let mut idx = 0u32;
    for (bi, b) in f.blocks.iter().enumerate() {
        let (bs, be) = block_range[bi];
        let mut local: HashMap<VReg, Interval> = HashMap::new();
        let widen = |local: &mut HashMap<VReg, Interval>, v: VReg, p: u32| {
            local.entry(v).and_modify(|e| e.1 = e.1.max(p)).or_insert((p, p));
        };
        for &v in &live_in[bi] {
            widen(&mut local, v, bs);
        }
        let mut open: HashMap<u8, u32> = HashMap::new();
        for inst in &b.insts {
            let (defs, uses) = regs_of(t, inst);
            let (up, dp) = (2 * idx, 2 * idx + 1);
            for r in &uses {
                match *r {
                    Reg::V(v) => widen(&mut local, v, up),
                    Reg::P(p) if allocatable(p) => {
                        let s = open.remove(&p).unwrap_or(bs);
                        fixed.entry(p).or_default().push((s, up));
                    }
                    _ => {}
                }
            }
            for r in &defs {
                match *r {
                    Reg::V(v) => widen(&mut local, v, dp),
                    Reg::P(p) if allocatable(p) => {
                        if let Some(s) = open.insert(p, dp) {
                            fixed.entry(p).or_default().push((s, s));
                        }
                    }
                    _ => {}
                }
            }
            if !inst.imp_defs.is_empty() {
                calls.push(dp);
            }
            if inst.op == Opcode::Copy
                && let (MOp::Reg(a), MOp::Reg(c)) = (&inst.ops[0], &inst.ops[1])
            {
                if let Reg::V(v) = a {
                    hints[*v as usize].push(*c);
                }
                if let Reg::V(v) = c {
                    hints[*v as usize].push(*a);
                }
            }
            idx += 1;
        }
        for (p, s) in open {
            fixed.entry(p).or_default().push((s, s));
        }
        for &v in &live_out[bi] {
            widen(&mut local, v, be);
        }
        for (v, s) in local {
            segs[v as usize].push(s);
        }
    }

    // Linear scan.
    for s in &mut segs {
        s.sort();
    }
    let mut order: Vec<VReg> = (0..nv as VReg).filter(|&v| !segs[v as usize].is_empty()).collect();
    order.sort_by_key(|&v| (segs[v as usize][0].0, v));
    let mut taken: HashMap<u8, Vec<Interval>> = fixed;
    let mut assigned: Vec<Option<u8>> = vec![None; nv];
    let mut spilled: Vec<VReg> = Vec::new();
    for v in order {
        let mine = &segs[v as usize];
        let across_call = calls.iter().any(|&c| mine.iter().any(|s| s.0 < c && c < s.1));
        // Registers of values joined to this one by copies, nearest first.
        let mut cands: Vec<u8> = Vec::new();
        let mut seen: HashSet<VReg> = HashSet::from([v]);
        let mut frontier: Vec<VReg> = vec![v];
        for _ in 0..4 {
            let mut next = Vec::new();
            for &w in &frontier {
                for h in &hints[w as usize] {
                    match h {
                        Reg::P(p) if allocatable(*p) => cands.push(*p),
                        Reg::V(x) => {
                            if let Some(p) = assigned[*x as usize] {
                                cands.push(p);
                            }
                            if seen.insert(*x) {
                                next.push(*x);
                            }
                        }
                        _ => {}
                    }
                }
            }
            frontier = next;
        }
        // Only registers of the value's own file.
        let fp = f.vfp[v as usize];
        cands.retain(|&p| (p >= 32) == fp);
        // Only the low 64 bits of the saved floating-point registers
        // survive a call, so a whole vector live across one is spilled.
        let no_saved: Vec<u8> = Vec::new();
        let callee_fp = if f.vq[v as usize] { &no_saved } else { &fp_callee_saved };
        if f.vq[v as usize] && across_call {
            cands.clear();
        }
        let (caller, callee) = if fp { (&fp_caller_saved, callee_fp) } else { (&caller_saved, &callee_saved) };
        if across_call {
            cands.extend(callee.iter().copied());
            cands.extend(caller.iter().copied());
        } else {
            cands.extend(caller.iter().copied());
            cands.extend(callee.iter().copied());
        }
        let free = cands
            .into_iter()
            .find(|p| taken.get(p).is_none_or(|list| list.iter().all(|&s| mine.iter().all(|&m| !overlaps(s, m)))));
        match free {
            Some(p) => {
                assigned[v as usize] = Some(p);
                taken.entry(p).or_default().extend(mine.iter().copied());
            }
            None => spilled.push(v),
        }
    }

    // Spill slots, and loads and stores around each use and definition.
    let mut slot_of: HashMap<VReg, usize> = HashMap::new();
    for &v in &spilled {
        let size = if f.vq[v as usize] { 16 } else { 8 };
        f.slots.push(Slot { size, align: size, offset: 0 });
        slot_of.insert(v, f.slots.len() - 1);
    }
    // Spill code: loads and stores of each register file, as the
    // description names them by role (those a machine lacks are needed only
    // if values of that kind are spilled).
    let pair = |l: &str, s: &str| t.role(l).zip(t.role(s));
    let (ldr, str_) = pair("load.x", "store.x").ok_or("no instruction has role load.x or store.x")?;
    let fp_spill = pair("load.d", "store.d");
    let q_spill = pair("load.q", "store.q");
    let vfp = f.vfp.clone();
    let vq = f.vq.clone();
    let fname = f.name.clone();
    for b in &mut f.blocks {
        let old = std::mem::take(&mut b.insts);
        let mut new = Vec::with_capacity(old.len());
        for mut inst in old {
            let (defs, uses) = regs_of(t, &inst);
            let mut scratch: HashMap<VReg, u8> = HashMap::new();
            let (mut next, mut next_fp) = (0, 0);
            let mut after = Vec::new();
            // Operands read first, then results: a result whose scratch
            // registers have run out can share one an operand used, since
            // operands are read before results are written (but not one
            // that is both, such as a written-back base).
            let both: Vec<Reg> = uses.iter().filter(|r| defs.contains(r)).copied().collect();
            for r in uses.iter().chain(defs.iter()) {
                if let Reg::V(v) = r
                    && let Some(&slot) = slot_of.get(v)
                    && !scratch.contains_key(v)
                {
                    let fp = vfp[*v as usize];
                    let (pool, k) = if fp { (&abi.fp_scratch, &mut next_fp) } else { (&abi.scratch, &mut next) };
                    let s = match pool.get(*k) {
                        Some(&s) => {
                            *k += 1;
                            s
                        }
                        None if !uses.contains(r) => *pool
                            .iter()
                            .find(|&&s| !both.iter().any(|b| matches!(b, Reg::V(w) if scratch.get(w) == Some(&s))))
                            .ok_or_else(|| format!("{fname}: more spilled operands than scratch registers"))?,
                        None => return Err(format!("{fname}: more spilled operands than scratch registers")),
                    };
                    scratch.insert(*v, s);
                    let (ld, st) = if vq[*v as usize] {
                        q_spill.ok_or_else(|| format!("{fname}: no instruction spills a vector register"))?
                    } else if fp {
                        fp_spill.ok_or_else(|| format!("{fname}: no instruction spills a floating-point register"))?
                    } else {
                        (ldr, str_)
                    };
                    if uses.contains(r) {
                        new.push(MInst::new(
                            ld,
                            vec![MOp::Reg(Reg::P(s)), MOp::Reg(Reg::P(t.machine.sp)), MOp::Frame(slot, 0)],
                        ));
                    }
                    if defs.contains(r) {
                        after.push(MInst::new(
                            st,
                            vec![MOp::Reg(Reg::P(s)), MOp::Reg(Reg::P(t.machine.sp)), MOp::Frame(slot, 0)],
                        ));
                    }
                }
            }
            for op in &mut inst.ops {
                if let MOp::Reg(Reg::V(v)) = op {
                    *op = MOp::Reg(Reg::P(match scratch.get(v) {
                        Some(&s) => s,
                        // A result nothing reads: the zero register takes it.
                        None => assigned[*v as usize].or(t.machine.zero).unwrap_or(abi.scratch[0]),
                    }));
                }
            }
            new.push(inst);
            new.extend(after);
        }
        b.insts = new;
    }
    lower_copies(t, f);
    Ok(())
}

/// Turns copies into moves, dropping those between the same register.
fn lower_copies(t: &Target, f: &mut MFunc) {
    use crate::target::Class;
    for b in &mut f.blocks {
        let old = std::mem::take(&mut b.insts);
        for inst in old {
            if inst.op != Opcode::Copy {
                b.insts.push(inst);
                continue;
            }
            let (MOp::Reg(Reg::P(d)), MOp::Reg(Reg::P(s))) = (&inst.ops[0], &inst.ops[1]) else {
                b.insts.push(inst);
                continue;
            };
            if d == s {
                continue;
            }
            let wide = inst.wide;
            // Within a register file, or across it with fmov.
            let op = match (*d >= 32, *s >= 32, wide) {
                (true, true, _) if inst.q => t.by_role("copy.q"),
                (false, false, true) => t.copies[&Class::X],
                (false, false, false) => t.copies[&Class::W],
                (true, true, true) => t.copies[&Class::D],
                (true, true, false) => t.copies[&Class::S],
                (true, false, true) => t.by_role("fmov.d.x"),
                (true, false, false) => t.by_role("fmov.s.w"),
                (false, true, true) => t.by_role("fmov.x.d"),
                (false, true, false) => t.by_role("fmov.w.s"),
            };
            b.insts.push(MInst::new(op, vec![MOp::Reg(Reg::P(*d)), MOp::Reg(Reg::P(*s))]));
        }
    }
}

/// Records each copy's width before allocation, while its virtual
/// registers still say how wide they are.
fn record_copy_widths(f: &mut MFunc) {
    let vwide = f.vwide.clone();
    let vq = f.vq.clone();
    for b in &mut f.blocks {
        for inst in &mut b.insts {
            if inst.op != Opcode::Copy {
                continue;
            }
            let w = |o: &MOp| match o {
                MOp::Reg(Reg::V(v)) => Some(vwide[*v as usize]),
                _ => None,
            };
            inst.wide = w(&inst.ops[0]).or(w(&inst.ops[1])).unwrap_or(true);
            let q = |o: &MOp| match o {
                MOp::Reg(Reg::V(v)) => Some(vq[*v as usize]),
                _ => None,
            };
            inst.q = q(&inst.ops[0]).or(q(&inst.ops[1])).unwrap_or(false);
        }
    }
}
