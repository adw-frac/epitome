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

/// Where a physical register is taken: closed intervals, kept as their
/// union, disjoint and by start, so that whether an interval meets any of
/// them is one lookup (the last one starting at or before its end).
#[derive(Default)]
struct Busy(std::collections::BTreeMap<u32, u32>);

impl Busy {
    fn meets(&self, (a, b): Interval) -> bool {
        self.0.range(..=b).next_back().is_some_and(|(_, &e)| e >= a)
    }

    fn add(&mut self, (mut a, mut b): Interval) {
        while let Some((&s, &e)) = self.0.range(..=b).next_back() {
            if e < a {
                break;
            }
            self.0.remove(&s);
            a = a.min(s);
            b = b.max(e);
        }
        self.0.insert(a, b);
    }
}

pub fn allocate(t: &Target, f: &mut MFunc) -> Result<(), String> {
    record_copy_classes(f);
    let m = &t.machine;
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
    let nv = f.vclass.len();
    let file_of_v = |v: VReg| m.def(f.vclass[v as usize]).file;
    // A value wider than the registers a function preserves (a vector, of
    // which only the low 64 bits of AArch64's v8-v15 survive a call) cannot
    // be kept in one across a call.
    let too_wide = |v: VReg| {
        let c = m.def(f.vclass[v as usize]);
        m.save_class(c.file).is_none_or(|s| c.bits > m.def(s).bits)
    };
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
            // Inline assembly's early-clobber results are written while its
            // operands are still being read.
            let asm = matches!(inst.op, Opcode::Asm { .. });
            let early: Vec<Reg> = match inst.op {
                Opcode::Asm { id, .. } => f.asms[id as usize]
                    .early
                    .iter()
                    .enumerate()
                    .filter(|e| *e.1)
                    .filter_map(|(k, _)| if let MOp::Reg(r) = inst.ops[k] { Some(r) } else { None })
                    .collect(),
                _ => vec![],
            };
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
                let dp = if early.contains(r) { up } else { dp };
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
            if !inst.imp_defs.is_empty() && !asm {
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
    let mut taken: HashMap<u8, Busy> = HashMap::new();
    for (p, list) in fixed {
        let busy = taken.entry(p).or_default();
        for s in list {
            busy.add(s);
        }
    }
    let mut assigned: Vec<Option<u8>> = vec![None; nv];
    let mut spilled: Vec<VReg> = Vec::new();
    for v in order {
        let mine = &segs[v as usize];
        // A call strictly inside one of its segments (calls are in order).
        let across_call = mine.iter().any(|s| {
            let k = calls.partition_point(|&c| c <= s.0);
            k < calls.len() && calls[k] < s.1
        });
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
        let no_saved: Vec<u8> = Vec::new();
        let wide = too_wide(v);
        if wide && across_call {
            cands.clear();
        }
        let (callee, fp_callee) = if wide { (&no_saved, &no_saved) } else { (&callee_saved, &fp_callee_saved) };
        let caller = caller_saved.iter().chain(&fp_caller_saved);
        let callee = callee.iter().chain(fp_callee);
        if across_call {
            cands.extend(callee.chain(caller).copied());
        } else {
            cands.extend(caller.chain(callee).copied());
        }
        // Only registers of the value's own file.
        let file = file_of_v(v);
        cands.retain(|&p| m.file_of(p) == file);
        let free = cands.into_iter().find(|p| taken.get(p).is_none_or(|busy| mine.iter().all(|&m| !busy.meets(m))));
        match free {
            Some(p) => {
                assigned[v as usize] = Some(p);
                let busy = taken.entry(p).or_default();
                for &s in mine {
                    busy.add(s);
                }
            }
            None => spilled.push(v),
        }
    }

    // Spill slots, and loads and stores around each use and definition.
    let mut slot_of: HashMap<VReg, usize> = HashMap::new();
    for &v in &spilled {
        let size = (m.def(f.vclass[v as usize]).bits as u64 / 8).max(8);
        f.slots.push(Slot { size, align: size, offset: 0 });
        slot_of.insert(v, f.slots.len() - 1);
    }
    // Spill code: a value is spilled as its file's registers are saved
    // (load.x, load.d), or, if wider, by its own class's (load.q), as the
    // description names them by role (those a machine lacks are needed only
    // if values of that kind are spilled).
    let spill_of = |c: crate::target::Class| -> Option<(usize, usize)> {
        let d = m.def(c);
        let as_class = match m.save_class(d.file) {
            Some(s) if m.def(s).bits >= d.bits => s,
            _ => c,
        };
        let n = &m.def(as_class).name;
        t.role(&format!("load.{n}")).zip(t.role(&format!("store.{n}")))
    };
    let vclass = f.vclass.clone();
    let fname = f.name.clone();
    // Each file's scratch registers, for spill code.
    let pool_of = |file: usize| -> Vec<u8> {
        abi.scratch.iter().chain(&abi.fp_scratch).copied().filter(|&r| m.file_of(r) == file).collect()
    };
    for b in &mut f.blocks {
        let old = std::mem::take(&mut b.insts);
        let mut new = Vec::with_capacity(old.len());
        for mut inst in old {
            let (defs, uses) = regs_of(t, &inst);
            let mut scratch: HashMap<VReg, u8> = HashMap::new();
            let mut next: HashMap<usize, usize> = HashMap::new();
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
                    let class = vclass[*v as usize];
                    let pool = pool_of(m.def(class).file);
                    let k = next.entry(m.def(class).file).or_default();
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
                    let (ld, st) = spill_of(class).ok_or_else(|| {
                        format!("{fname}: no instructions load and store a {} register to spill it", m.def(class).name)
                    })?;
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
                    let class = vclass[*v as usize];
                    *op = MOp::Reg(Reg::P(match scratch.get(v) {
                        Some(&s) => s,
                        None => match assigned[*v as usize] {
                            Some(p) => p,
                            // A result nothing reads: the zero register
                            // takes it, or a scratch register of its file
                            // that spill code is not using.
                            None if m.zero_in(class) => m.zero.unwrap(),
                            None => {
                                let pool = pool_of(m.def(class).file);
                                *pool.iter().rev().find(|r| !scratch.values().any(|s| s == *r)).ok_or_else(|| {
                                    format!("{fname}: no register for an unused {} result", m.def(class).name)
                                })?
                            }
                        },
                    }));
                }
            }
            new.push(inst);
            new.extend(after);
        }
        b.insts = new;
    }
    lower_copies(t, f)
}

/// Turns copies into moves, dropping those between the same register:
/// within a file, by the copy of the class (or of a wider one of its file:
/// AArch64 copies 64-bit vectors as d registers); between files, by the
/// instruction with role `move.<to>.<from>` (`move.d.x`, `fmov d0, x1`).
fn lower_copies(t: &Target, f: &mut MFunc) -> Result<(), String> {
    let m = &t.machine;
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
            let (fd, fs) = (m.file_of(*d), m.file_of(*s));
            let class = inst.class.or_else(|| m.save_class(fd)).ok_or("a copy of no class")?;
            let bits = m.def(class).bits;
            let op = if fd == fs {
                let mut within: Vec<(u32, usize)> = t
                    .copies
                    .iter()
                    .filter(|(c, _)| m.def(**c).file == fd && !m.def(**c).sp && m.def(**c).bits >= bits)
                    .map(|(c, &i)| (m.def(*c).bits, i))
                    .collect();
                within.sort();
                within
                    .first()
                    .map(|w| w.1)
                    .ok_or_else(|| format!("{}: no \"copy\" instruction for {} registers", f.name, m.files[fd].name))?
            } else {
                let name = |file: usize| m.scalar_in(file, bits).map(|c| m.def(c).name.clone());
                let (Some(to), Some(from)) = (name(fd), name(fs)) else {
                    return Err(format!("{}: no {bits}-bit class to copy between register files", f.name));
                };
                t.role(&format!("move.{to}.{from}"))
                    .ok_or_else(|| format!("{}: no instruction has role move.{to}.{from}", f.name))?
            };
            b.insts.push(MInst::new(op, vec![MOp::Reg(Reg::P(*d)), MOp::Reg(Reg::P(*s))]));
        }
    }
    Ok(())
}

/// Records each copy's class before allocation, while its virtual
/// registers still say.
fn record_copy_classes(f: &mut MFunc) {
    let vclass = f.vclass.clone();
    for b in &mut f.blocks {
        for inst in &mut b.insts {
            if inst.op != Opcode::Copy {
                continue;
            }
            let c = |o: &MOp| match o {
                MOp::Reg(Reg::V(v)) => Some(vclass[*v as usize]),
                _ => None,
            };
            inst.class = c(&inst.ops[0]).or(c(&inst.ops[1]));
        }
    }
}
