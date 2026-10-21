//! A small RV64 machine for testing: a static linker for ELF relocatable
//! files, and an interpreter for RV64I, M, A, F, D and Zbb, written from the
//! RISC-V Instruction Set Manual (Volume I) and the RISC-V ELF psABI, not
//! from the description under test.
//!
//! The C library is the host's: calls to `printf`, `putchar`, `puts`,
//! `memcpy`, `memmove`, `memset`, `strlen`, `abort` and `exit` jump to stub
//! addresses, where the host does the work and returns.

use std::collections::HashMap;

use epitome_codegen::elf::{self, ElfFile};

const BASE: u64 = 0x10000;
const MEM: usize = 64 << 20;
const STUBS: u64 = 0x1000;
const RETURN: u64 = 0x800;
const SHF_TLS: u64 = 0x400;
const LIBC: &[&str] = &[
    "printf",
    "putchar",
    "puts",
    "memcpy",
    "memmove",
    "memset",
    "strlen",
    "abort",
    "exit",
    "__udivti3",
    "__divti3",
    "__umodti3",
    "__modti3",
];

pub struct Machine {
    x: [u64; 32],
    f: [u64; 32],
    pc: u64,
    mem: Vec<u8>,
    pub out: String,
    entry: u64,
    stubs: HashMap<u64, &'static str>,
    /// The address `lr` reserved, until an `sc` (there is one hart, so
    /// nothing else breaks a reservation).
    reserved: Option<u64>,
    /// Where the thread-local sections start: the one thread's block, and
    /// what `tp` points at (the psABI's TLS variant I, with no TCB here).
    tls: u64,
}

fn sext(v: u64, bits: u32) -> i64 {
    ((v << (64 - bits)) as i64) >> (64 - bits)
}

fn bits(w: u32, hi: u32, lo: u32) -> u32 {
    (w >> lo) & ((1u32 << (hi - lo + 1)) - 1)
}

impl Machine {
    /// Links `objects` and readies `main` to run.
    pub fn link(objects: &[Vec<u8>]) -> Result<Machine, String> {
        let mut m = Machine {
            x: [0; 32],
            f: [0; 32],
            pc: 0,
            mem: vec![0; MEM],
            out: String::new(),
            entry: 0,
            stubs: HashMap::new(),
            reserved: None,
            tls: 0,
        };
        let files: Vec<ElfFile> = objects.iter().map(|b| elf::read(b)).collect::<Result<_, _>>()?;
        // Lay out every allocated section: the thread-local ones first,
        // together, as the one thread's block.
        let mut at = BASE;
        m.tls = BASE;
        let mut base: HashMap<(usize, usize), u64> = HashMap::new();
        for tls in [true, false] {
            for (fi, f) in files.iter().enumerate() {
                for (si, s) in f.sections.iter().enumerate() {
                    // Unwind tables: nothing here unwinds.
                    if s.flags & elf::SHF_ALLOC == 0 || s.name == ".eh_frame" || (s.flags & SHF_TLS != 0) != tls {
                        continue;
                    }
                    at = at.next_multiple_of(s.align.max(1));
                    base.insert((fi, si), at);
                    if s.sh_type != elf::SHT_NOBITS {
                        m.mem[at as usize..at as usize + s.data.len()].copy_from_slice(&s.data);
                    }
                    at += s.size;
                }
            }
        }
        // Global symbols, then the C library's stubs for the rest.
        let mut globals: HashMap<String, u64> = HashMap::new();
        for (fi, f) in files.iter().enumerate() {
            for s in &f.symbols {
                if s.bind != elf::STB_LOCAL && s.shndx != 0 && !s.name.is_empty() {
                    let b = base.get(&(fi, s.shndx as usize)).ok_or("a symbol in a section not loaded")?;
                    globals.insert(s.name.clone(), b + s.value);
                }
            }
        }
        for (k, name) in LIBC.iter().enumerate() {
            let a = STUBS + 16 * k as u64;
            globals.entry(name.to_string()).or_insert(a);
            m.stubs.insert(a, name);
        }
        // Relocations.
        for (fi, f) in files.iter().enumerate() {
            for (si, s) in f.sections.iter().enumerate() {
                let Some(&sbase) = base.get(&(fi, si)) else { continue };
                for r in &s.relocs {
                    let sym = &f.symbols[r.sym as usize];
                    let sv = if sym.shndx == 0 {
                        *globals.get(&sym.name).ok_or_else(|| format!("undefined symbol {}", sym.name))?
                    } else {
                        base.get(&(fi, sym.shndx as usize)).ok_or("a symbol in a section not loaded")? + sym.value
                    };
                    let target = sv.wrapping_add(r.addend as u64);
                    let p = sbase + r.offset;
                    let insn = m.read32(p);
                    match r.rel_type {
                        2 => m.write64(p, target),
                        17 => {
                            let off = target.wrapping_sub(p) as i64;
                            if !(-(1 << 20)..(1 << 20)).contains(&off) {
                                return Err(format!("R_RISCV_JAL to {} out of range", sym.name));
                            }
                            let o = off as u32;
                            let imm = (bits(o, 20, 20) << 31)
                                | (bits(o, 10, 1) << 21)
                                | (bits(o, 11, 11) << 20)
                                | (bits(o, 19, 12) << 12);
                            m.write32(p, (insn & 0xfff) | imm);
                        }
                        26 => {
                            let hi = (target.wrapping_add(0x800) >> 12) as u32 & 0xfffff;
                            m.write32(p, (insn & 0xfff) | (hi << 12));
                        }
                        27 => {
                            let lo = target as u32 & 0xfff;
                            m.write32(p, (insn & 0x000f_ffff) | (lo << 20));
                        }
                        // R_RISCV_TPREL_*: the offset from tp, as lui's
                        // high part, an I or S immediate's low part, and
                        // the add of tp that marks the sequence.
                        29 => {
                            let off = target.wrapping_sub(m.tls);
                            let hi = (off.wrapping_add(0x800) >> 12) as u32 & 0xfffff;
                            m.write32(p, (insn & 0xfff) | (hi << 12));
                        }
                        30 => {
                            let lo = target.wrapping_sub(m.tls) as u32 & 0xfff;
                            m.write32(p, (insn & 0x000f_ffff) | (lo << 20));
                        }
                        31 => {
                            let lo = target.wrapping_sub(m.tls) as u32 & 0xfff;
                            m.write32(p, (insn & 0x01ff_f07f) | ((lo >> 5) << 25) | ((lo & 31) << 7));
                        }
                        32 => {}
                        t => return Err(format!("relocation type {t} is not supported")),
                    }
                }
            }
        }
        m.entry = *globals.get("main").ok_or("no main")?;
        Ok(m)
    }

    fn read32(&self, a: u64) -> u32 {
        u32::from_le_bytes(self.mem[a as usize..a as usize + 4].try_into().unwrap())
    }
    fn write32(&mut self, a: u64, v: u32) {
        self.mem[a as usize..a as usize + 4].copy_from_slice(&v.to_le_bytes());
    }
    fn read64(&self, a: u64) -> u64 {
        u64::from_le_bytes(self.mem[a as usize..a as usize + 8].try_into().unwrap())
    }
    fn write64(&mut self, a: u64, v: u64) {
        self.mem[a as usize..a as usize + 8].copy_from_slice(&v.to_le_bytes());
    }
    fn load(&self, a: u64, n: usize) -> Result<u64, String> {
        let a = a as usize;
        if a < BASE as usize || a + n > MEM {
            return Err(format!("a load of {n} bytes at {a:#x}"));
        }
        let mut b = [0u8; 8];
        b[..n].copy_from_slice(&self.mem[a..a + n]);
        Ok(u64::from_le_bytes(b))
    }
    fn store(&mut self, a: u64, n: usize, v: u64) -> Result<(), String> {
        let a = a as usize;
        if a < BASE as usize || a + n > MEM {
            return Err(format!("a store of {n} bytes at {a:#x}"));
        }
        self.mem[a..a + n].copy_from_slice(&v.to_le_bytes()[..n]);
        Ok(())
    }
    fn set(&mut self, r: u32, v: u64) {
        if r != 0 {
            self.x[r as usize] = v;
        }
    }
    fn fd(&self, r: u32) -> f64 {
        f64::from_bits(self.f[r as usize])
    }
    fn fs(&self, r: u32) -> f32 {
        f32::from_bits(self.f[r as usize] as u32)
    }
    fn set_d(&mut self, r: u32, v: f64) {
        self.f[r as usize] = v.to_bits();
    }
    fn set_s(&mut self, r: u32, v: f32) {
        // NaN-boxed.
        self.f[r as usize] = 0xffff_ffff_0000_0000 | v.to_bits() as u64;
    }
    fn cstr(&self, a: u64) -> String {
        let mut s = Vec::new();
        let mut a = a as usize;
        while a < MEM && self.mem[a] != 0 {
            s.push(self.mem[a]);
            a += 1;
        }
        String::from_utf8_lossy(&s).into_owned()
    }

    /// Runs `main`; returns its exit status.
    pub fn run(&mut self, max_steps: u64) -> Result<i32, String> {
        self.x[2] = (MEM as u64 - 4096) & !15;
        self.x[1] = RETURN;
        self.x[4] = self.tls;
        self.pc = self.entry;
        for _ in 0..max_steps {
            if self.pc == RETURN {
                return Ok(self.x[10] as i32);
            }
            if let Some(&name) = self.stubs.get(&self.pc) {
                if let Some(code) = self.libc(name)? {
                    return Ok(code);
                }
                self.pc = self.x[1];
                continue;
            }
            self.step()?;
        }
        Err("too many steps".into())
    }

    /// The C library function `name`, on the arguments in a0-a7 (and the
    /// stack, for printf's). `Some(code)` if it ends the program.
    fn libc(&mut self, name: &str) -> Result<Option<i32>, String> {
        let a = |m: &Machine, k: usize| m.x[10 + k];
        match name {
            "printf" => {
                let fmt = self.cstr(a(self, 0));
                let mut args = Vec::new();
                for k in 1..8 {
                    args.push(a(self, k));
                }
                let sp = self.x[2];
                for k in 0..32 {
                    args.push(self.read64(sp + 8 * k));
                }
                let s = printf(&fmt, &args, |p| self.cstr(p));
                self.out.push_str(&s);
                self.x[10] = s.len() as u64;
            }
            "putchar" => {
                self.out.push(a(self, 0) as u8 as char);
            }
            "puts" => {
                let s = self.cstr(a(self, 0));
                self.out.push_str(&s);
                self.out.push('\n');
            }
            "memcpy" | "memmove" => {
                let (d, s, n) = (a(self, 0) as usize, a(self, 1) as usize, a(self, 2) as usize);
                self.mem.copy_within(s..s + n, d);
            }
            "memset" => {
                let (d, v, n) = (a(self, 0) as usize, a(self, 1) as u8, a(self, 2) as usize);
                self.mem[d..d + n].fill(v);
            }
            "strlen" => {
                self.x[10] = self.cstr(a(self, 0)).len() as u64;
            }
            // The runtime's 128-bit division: each operand in a pair of
            // registers, low half first, as is the result.
            "__udivti3" | "__divti3" | "__umodti3" | "__modti3" => {
                let wide = |k: usize| ((a(self, k + 1) as u128) << 64) | a(self, k) as u128;
                let (x, y) = (wide(0), wide(2));
                if y == 0 {
                    return Err(format!("{name} by zero"));
                }
                let r: u128 = match name {
                    "__udivti3" => x / y,
                    "__umodti3" => x % y,
                    "__divti3" => (x as i128).wrapping_div(y as i128) as u128,
                    _ => (x as i128).wrapping_rem(y as i128) as u128,
                };
                self.x[10] = r as u64;
                self.x[11] = (r >> 64) as u64;
            }
            "abort" => return Err("abort".into()),
            "exit" => return Ok(Some(a(self, 0) as i32)),
            _ => return Err(format!("{name} is not in this C library")),
        }
        Ok(None)
    }

    fn step(&mut self) -> Result<(), String> {
        let pc = self.pc;
        if pc < BASE || pc as usize + 4 > MEM {
            return Err(format!("a jump to {pc:#x}"));
        }
        let w = self.read32(pc);
        let (rd, rs1, rs2, f3, f7) =
            (bits(w, 11, 7), bits(w, 19, 15), bits(w, 24, 20), bits(w, 14, 12), bits(w, 31, 25));
        let x1 = self.x[rs1 as usize];
        let x2 = self.x[rs2 as usize];
        let imm_i = sext(bits(w, 31, 20) as u64, 12);
        let imm_s = sext(((bits(w, 31, 25) << 5) | bits(w, 11, 7)) as u64, 12);
        let imm_b = sext(
            ((bits(w, 31, 31) << 12) | (bits(w, 7, 7) << 11) | (bits(w, 30, 25) << 5) | (bits(w, 11, 8) << 1)) as u64,
            13,
        );
        let imm_u = sext((w & 0xffff_f000) as u64, 32);
        let imm_j = sext(
            ((bits(w, 31, 31) << 20) | (bits(w, 19, 12) << 12) | (bits(w, 20, 20) << 11) | (bits(w, 30, 21) << 1))
                as u64,
            21,
        );
        let bad = || format!("an instruction this machine does not have: {w:08x} at {pc:#x}");
        let mut next = pc.wrapping_add(4);
        match w & 0x7f {
            0x37 => self.set(rd, imm_u as u64),
            0x17 => self.set(rd, pc.wrapping_add(imm_u as u64)),
            0x6f => {
                self.set(rd, next);
                next = pc.wrapping_add(imm_j as u64);
            }
            0x67 => {
                let t = x1.wrapping_add(imm_i as u64) & !1;
                self.set(rd, next);
                next = t;
            }
            0x63 => {
                let take = match f3 {
                    0 => x1 == x2,
                    1 => x1 != x2,
                    4 => (x1 as i64) < (x2 as i64),
                    5 => (x1 as i64) >= (x2 as i64),
                    6 => x1 < x2,
                    7 => x1 >= x2,
                    _ => return Err(bad()),
                };
                if take {
                    next = pc.wrapping_add(imm_b as u64);
                }
            }
            0x03 => {
                let a = x1.wrapping_add(imm_i as u64);
                let v = match f3 {
                    0 => sext(self.load(a, 1)?, 8) as u64,
                    1 => sext(self.load(a, 2)?, 16) as u64,
                    2 => sext(self.load(a, 4)?, 32) as u64,
                    3 => self.load(a, 8)?,
                    4 => self.load(a, 1)?,
                    5 => self.load(a, 2)?,
                    6 => self.load(a, 4)?,
                    _ => return Err(bad()),
                };
                self.set(rd, v);
            }
            0x23 => {
                let a = x1.wrapping_add(imm_s as u64);
                let n = match f3 {
                    0 => 1,
                    1 => 2,
                    2 => 4,
                    3 => 8,
                    _ => return Err(bad()),
                };
                self.store(a, n, x2)?;
            }
            0x13 => {
                let sh = bits(w, 25, 20);
                let v = match f3 {
                    0 => x1.wrapping_add(imm_i as u64),
                    2 => ((x1 as i64) < imm_i) as u64,
                    3 => (x1 < imm_i as u64) as u64,
                    4 => x1 ^ imm_i as u64,
                    6 => x1 | imm_i as u64,
                    7 => x1 & imm_i as u64,
                    1 if bits(w, 31, 26) == 0 => x1 << sh,
                    1 if f7 == 0x30 => match rs2 {
                        0 => x1.leading_zeros() as u64,
                        1 => x1.trailing_zeros() as u64,
                        2 => x1.count_ones() as u64,
                        4 => sext(x1, 8) as u64,
                        5 => sext(x1, 16) as u64,
                        _ => return Err(bad()),
                    },
                    5 if bits(w, 31, 26) == 0 => x1 >> sh,
                    5 if bits(w, 31, 26) == 0x10 => ((x1 as i64) >> sh) as u64,
                    5 if bits(w, 31, 20) == 0x6b8 => x1.swap_bytes(),
                    _ => return Err(bad()),
                };
                self.set(rd, v);
            }
            0x1b => {
                let sh = rs2;
                let v = match (f3, f7) {
                    (0, _) => sext(x1.wrapping_add(imm_i as u64), 32),
                    (1, 0) => sext((x1 as u32).wrapping_shl(sh) as u64, 32),
                    (5, 0) => sext(((x1 as u32) >> sh) as u64, 32),
                    (5, 0x20) => ((x1 as i32) >> sh) as i64,
                    _ => return Err(bad()),
                };
                self.set(rd, v as u64);
            }
            0x33 => {
                let (s1, s2) = (x1 as i64, x2 as i64);
                let v = match (f7, f3) {
                    (0, 0) => x1.wrapping_add(x2),
                    (0x20, 0) => x1.wrapping_sub(x2),
                    (0, 1) => x1 << (x2 & 63),
                    (0, 2) => (s1 < s2) as u64,
                    (0, 3) => (x1 < x2) as u64,
                    (0, 4) => x1 ^ x2,
                    (0, 5) => x1 >> (x2 & 63),
                    (0x20, 5) => (s1 >> (x2 & 63)) as u64,
                    (0, 6) => x1 | x2,
                    (0, 7) => x1 & x2,
                    (1, 0) => x1.wrapping_mul(x2),
                    (1, 1) => ((s1 as i128 * s2 as i128) >> 64) as u64,
                    (1, 2) => ((s1 as i128 * x2 as i128) >> 64) as u64,
                    (1, 3) => ((x1 as u128 * x2 as u128) >> 64) as u64,
                    (1, 4) => match (s1, s2) {
                        (_, 0) => u64::MAX,
                        (i64::MIN, -1) => s1 as u64,
                        _ => (s1 / s2) as u64,
                    },
                    (1, 5) => x1.checked_div(x2).unwrap_or(u64::MAX),
                    (1, 6) => match (s1, s2) {
                        (_, 0) => x1,
                        (i64::MIN, -1) => 0,
                        _ => (s1 % s2) as u64,
                    },
                    (1, 7) => x1.checked_rem(x2).unwrap_or(x1),
                    (0x05, 4) => s1.min(s2) as u64,
                    (0x05, 5) => x1.min(x2),
                    (0x05, 6) => s1.max(s2) as u64,
                    (0x05, 7) => x1.max(x2),
                    (0x20, 7) => x1 & !x2,
                    (0x20, 6) => x1 | !x2,
                    (0x20, 4) => !(x1 ^ x2),
                    _ => return Err(bad()),
                };
                self.set(rd, v);
            }
            0x3b => {
                let (a, b) = (x1 as u32, x2 as u32);
                let (sa, sb) = (a as i32, b as i32);
                let v: i32 = match (f7, f3) {
                    (0, 0) => a.wrapping_add(b) as i32,
                    (0x20, 0) => a.wrapping_sub(b) as i32,
                    (0, 1) => a.wrapping_shl(b & 31) as i32,
                    (0, 5) => (a >> (b & 31)) as i32,
                    (0x20, 5) => sa >> (b & 31),
                    (1, 0) => a.wrapping_mul(b) as i32,
                    (1, 4) => match (sa, sb) {
                        (_, 0) => -1,
                        (i32::MIN, -1) => sa,
                        _ => sa / sb,
                    },
                    (1, 5) => a.checked_div(b).unwrap_or(u32::MAX) as i32,
                    (1, 6) => match (sa, sb) {
                        (_, 0) => sa,
                        (i32::MIN, -1) => 0,
                        _ => sa % sb,
                    },
                    (1, 7) => a.checked_rem(b).unwrap_or(a) as i32,
                    (0x04, 4) if rs2 == 0 => (x1 as u16) as i32,
                    _ => return Err(bad()),
                };
                self.set(rd, v as i64 as u64);
            }
            0x0f => {}
            // A: with one hart, the orderings (aq, rl) change nothing.
            0x2f => {
                let n = match f3 {
                    2 => 4,
                    3 => 8,
                    _ => return Err(bad()),
                };
                let a = x1;
                if a % n as u64 != 0 {
                    return Err(format!("a misaligned atomic at {a:#x} ({pc:#x})"));
                }
                let narrow = |v: u64| if n == 4 { sext(v, 32) as u64 } else { v };
                let f5 = bits(w, 31, 27);
                match f5 {
                    0b00010 => {
                        self.reserved = Some(a);
                        let v = narrow(self.load(a, n)?);
                        self.set(rd, v);
                    }
                    0b00011 => {
                        let ok = self.reserved.take() == Some(a);
                        if ok {
                            self.store(a, n, x2)?;
                        }
                        self.set(rd, u64::from(!ok));
                    }
                    _ => {
                        let old = narrow(self.load(a, n)?);
                        let src = narrow(x2);
                        let (so, ss) = (old as i64, src as i64);
                        let new = match f5 {
                            0b00001 => src,
                            0b00000 => old.wrapping_add(src),
                            0b00100 => old ^ src,
                            0b01100 => old & src,
                            0b01000 => old | src,
                            0b10000 => so.min(ss) as u64,
                            0b10100 => so.max(ss) as u64,
                            // Unsigned at the width: the 32-bit values are
                            // sign-extended alike, so their order is kept.
                            0b11000 => old.min(src),
                            0b11100 => old.max(src),
                            _ => return Err(bad()),
                        };
                        self.store(a, n, new)?;
                        self.set(rd, old);
                    }
                }
            }
            0x73 if w == 0x0010_0073 => return Err("ebreak".into()),
            0x07 => {
                let a = x1.wrapping_add(imm_i as u64);
                match f3 {
                    2 => {
                        let v = self.load(a, 4)?;
                        self.f[rd as usize] = 0xffff_ffff_0000_0000 | v;
                    }
                    3 => self.f[rd as usize] = self.load(a, 8)?,
                    _ => return Err(bad()),
                }
            }
            0x27 => {
                let a = x1.wrapping_add(imm_s as u64);
                match f3 {
                    2 => self.store(a, 4, self.f[rs2 as usize])?,
                    3 => self.store(a, 8, self.f[rs2 as usize])?,
                    _ => return Err(bad()),
                }
            }
            0x43 | 0x47 | 0x4b | 0x4f => {
                let rs3 = bits(w, 31, 27);
                let neg_prod = matches!(w & 0x7f, 0x4b | 0x4f);
                let neg_add = matches!(w & 0x7f, 0x47 | 0x4f);
                if bits(w, 26, 25) == 1 {
                    let (a, b, c) = (self.fd(rs1), self.fd(rs2), self.fd(rs3));
                    let a = if neg_prod { -a } else { a };
                    let c = if neg_add { -c } else { c };
                    self.set_d(rd, a.mul_add(b, c));
                } else {
                    let (a, b, c) = (self.fs(rs1), self.fs(rs2), self.fs(rs3));
                    let a = if neg_prod { -a } else { a };
                    let c = if neg_add { -c } else { c };
                    self.set_s(rd, a.mul_add(b, c));
                }
            }
            0x53 => self.fp_op(w, rd, rs1, rs2, f3, f7).map_err(|_| bad())?,
            _ => return Err(bad()),
        }
        self.pc = next;
        Ok(())
    }

    fn fp_op(&mut self, w: u32, rd: u32, rs1: u32, rs2: u32, f3: u32, f7: u32) -> Result<(), ()> {
        // The operation is f7's top five bits; its bottom two, the format
        // (00 single, 01 double).
        let double = f7 & 3 == 1;
        let x1 = self.x[rs1 as usize];
        // Rounding towards zero (rm 001) and otherwise to nearest even; the
        // programs here use no other.
        let to_int = |v: f64, signed: bool, wide: bool| -> u64 {
            let t = if f3 == 1 { v.trunc() } else { v.round_ties_even() };
            match (signed, wide) {
                (true, true) => t as i64 as u64,
                (false, true) => t as u64,
                (true, false) => (t as i32) as i64 as u64,
                (false, false) => (t as u32) as i32 as i64 as u64,
            }
        };
        match f7 >> 2 {
            0b00000 | 0b00001 | 0b00010 | 0b00011 | 0b01011 => {
                if double {
                    let (a, b) = (self.fd(rs1), self.fd(rs2));
                    let r = match f7 >> 2 {
                        0b00000 => a + b,
                        0b00001 => a - b,
                        0b00010 => a * b,
                        0b00011 => a / b,
                        _ => a.sqrt(),
                    };
                    self.set_d(rd, r);
                } else {
                    let (a, b) = (self.fs(rs1), self.fs(rs2));
                    let r = match f7 >> 2 {
                        0b00000 => a + b,
                        0b00001 => a - b,
                        0b00010 => a * b,
                        0b00011 => a / b,
                        _ => a.sqrt(),
                    };
                    self.set_s(rd, r);
                }
            }
            0b00100 => {
                let (a, b) = (self.f[rs1 as usize], self.f[rs2 as usize]);
                let sign = if double { 1u64 << 63 } else { 1u64 << 31 };
                let s = match f3 {
                    0 => b & sign,
                    1 => !b & sign,
                    2 => (a ^ b) & sign,
                    _ => return Err(()),
                };
                let v = (a & !sign) | s;
                self.f[rd as usize] = if double { v } else { 0xffff_ffff_0000_0000 | (v & 0xffff_ffff) };
            }
            0b00101 => {
                if double {
                    let (a, b) = (self.fd(rs1), self.fd(rs2));
                    self.set_d(rd, if f3 == 0 { a.min(b) } else { a.max(b) });
                } else {
                    let (a, b) = (self.fs(rs1), self.fs(rs2));
                    self.set_s(rd, if f3 == 0 { a.min(b) } else { a.max(b) });
                }
            }
            0b01000 => {
                // fcvt.s.d (f7 0100000) and fcvt.d.s (0100001)
                if double {
                    let v = self.fs(rs1) as f64;
                    self.set_d(rd, v);
                } else {
                    let v = self.fd(rs1) as f32;
                    self.set_s(rd, v);
                }
            }
            0b10100 => {
                let r = if double {
                    let (a, b) = (self.fd(rs1), self.fd(rs2));
                    match f3 {
                        2 => a == b,
                        1 => a < b,
                        0 => a <= b,
                        _ => return Err(()),
                    }
                } else {
                    let (a, b) = (self.fs(rs1), self.fs(rs2));
                    match f3 {
                        2 => a == b,
                        1 => a < b,
                        0 => a <= b,
                        _ => return Err(()),
                    }
                };
                self.set(rd, r as u64);
            }
            0b11000 => {
                let v = if double { self.fd(rs1) } else { self.fs(rs1) as f64 };
                let r = match rs2 {
                    0 => to_int(v, true, false),
                    1 => to_int(v, false, false),
                    2 => to_int(v, true, true),
                    3 => to_int(v, false, true),
                    _ => return Err(()),
                };
                self.set(rd, r);
            }
            0b11010 => {
                let v: f64 = match rs2 {
                    0 => x1 as i32 as f64,
                    1 => x1 as u32 as f64,
                    2 => x1 as i64 as f64,
                    3 => x1 as f64,
                    _ => return Err(()),
                };
                if double {
                    let v = match rs2 {
                        2 => x1 as i64 as f64,
                        3 => x1 as f64,
                        _ => v,
                    };
                    self.set_d(rd, v);
                } else {
                    let v = match rs2 {
                        0 => x1 as i32 as f32,
                        1 => x1 as u32 as f32,
                        2 => x1 as i64 as f32,
                        _ => x1 as f32,
                    };
                    self.set_s(rd, v);
                }
            }
            0b11100 if f3 == 0 => {
                let v = if double { self.f[rs1 as usize] } else { sext(self.f[rs1 as usize] & 0xffff_ffff, 32) as u64 };
                self.set(rd, v);
            }
            0b11110 if f3 == 0 => {
                self.f[rd as usize] = if double { x1 } else { 0xffff_ffff_0000_0000 | (x1 & 0xffff_ffff) };
            }
            _ => {
                let _ = w;
                return Err(());
            }
        }
        Ok(())
    }
}

/// C's printf, for the conversions the test programs use: `d i u x X c s
/// p`, with `l`, `ll` and `z`, flags, widths and precisions, and `f e g a`
/// for doubles (which a variadic call passes in integer registers).
pub fn printf(fmt: &str, args: &[u64], cstr: impl Fn(u64) -> String) -> String {
    let mut out = String::new();
    let mut args = args.iter().copied();
    let mut chars = fmt.chars().peekable();
    while let Some(c) = chars.next() {
        if c != '%' {
            out.push(c);
            continue;
        }
        let mut flags = String::new();
        while let Some(&f) = chars.peek() {
            if "-+ #0".contains(f) {
                flags.push(f);
                chars.next();
            } else {
                break;
            }
        }
        let mut width = String::new();
        while let Some(&d) = chars.peek().filter(|d| d.is_ascii_digit()) {
            width.push(d);
            chars.next();
        }
        let mut prec: Option<usize> = None;
        if chars.peek() == Some(&'.') {
            chars.next();
            let mut p = String::new();
            while let Some(&d) = chars.peek().filter(|d| d.is_ascii_digit()) {
                p.push(d);
                chars.next();
            }
            prec = Some(p.parse().unwrap_or(0));
        }
        let mut long = 0;
        while let Some(&l) = chars.peek().filter(|l| matches!(l, 'l' | 'z' | 'h')) {
            if l != 'h' {
                long += 1;
            }
            chars.next();
        }
        let Some(conv) = chars.next() else { break };
        let body = match conv {
            '%' => "%".to_string(),
            'd' | 'i' => {
                let v = args.next().unwrap_or(0);
                let v = if long > 0 { v as i64 } else { v as i32 as i64 };
                let s = v.unsigned_abs().to_string();
                let s = match prec {
                    Some(p) if s.len() < p => format!("{}{s}", "0".repeat(p - s.len())),
                    _ => s,
                };
                let sign = if v < 0 {
                    "-"
                } else if flags.contains('+') {
                    "+"
                } else if flags.contains(' ') {
                    " "
                } else {
                    ""
                };
                format!("{sign}{s}")
            }
            'u' | 'x' | 'X' | 'o' => {
                let v = args.next().unwrap_or(0);
                let v = if long > 0 { v } else { v as u32 as u64 };
                let s = match conv {
                    'u' => v.to_string(),
                    'x' => format!("{v:x}"),
                    'X' => format!("{v:X}"),
                    _ => format!("{v:o}"),
                };
                let s = match prec {
                    Some(p) if s.len() < p => format!("{}{s}", "0".repeat(p - s.len())),
                    _ => s,
                };
                if flags.contains('#') && v != 0 && conv != 'u' {
                    format!(
                        "{}{s}",
                        if conv == 'o' {
                            "0"
                        } else if conv == 'x' {
                            "0x"
                        } else {
                            "0X"
                        }
                    )
                } else {
                    s
                }
            }
            'c' => (args.next().unwrap_or(0) as u8 as char).to_string(),
            's' => {
                let s = cstr(args.next().unwrap_or(0));
                match prec {
                    Some(p) => s.chars().take(p).collect(),
                    None => s,
                }
            }
            'p' => format!("0x{:x}", args.next().unwrap_or(0)),
            'f' | 'F' | 'e' | 'E' | 'g' | 'G' | 'a' | 'A' => {
                let v = f64::from_bits(args.next().unwrap_or(0));
                let s = float(v, conv.to_ascii_lowercase(), prec, flags.contains('#'));
                let s = if v.is_sign_positive() && !s.starts_with('-') && flags.contains('+') {
                    format!("+{s}")
                } else {
                    s
                };
                if conv.is_ascii_uppercase() { s.to_uppercase() } else { s }
            }
            _ => format!("%{conv}"),
        };
        let w: usize = width.parse().unwrap_or(0);
        if body.len() < w {
            let pad = w - body.len();
            if flags.contains('-') {
                out.push_str(&body);
                out.push_str(&" ".repeat(pad));
            } else if flags.contains('0') && !matches!(conv, 's' | 'c') {
                let (sign, digits) = match body.strip_prefix('-') {
                    Some(d) => ("-", d),
                    None => ("", body.as_str()),
                };
                out.push_str(sign);
                out.push_str(&"0".repeat(pad));
                out.push_str(digits);
            } else {
                out.push_str(&" ".repeat(pad));
                out.push_str(&body);
            }
        } else {
            out.push_str(&body);
        }
    }
    out
}

/// `%e`'s exponent, as C writes it: a sign and at least two digits.
fn c_exponent(e: i32) -> String {
    format!("{}{:02}", if e < 0 { '-' } else { '+' }, e.abs())
}

fn float(v: f64, conv: char, prec: Option<usize>, alt: bool) -> String {
    if v.is_nan() {
        return "nan".into();
    }
    if v.is_infinite() {
        return if v < 0.0 { "-inf".into() } else { "inf".into() };
    }
    match conv {
        'f' => format!("{:.*}", prec.unwrap_or(6), v),
        'e' => {
            let s = format!("{:.*e}", prec.unwrap_or(6), v);
            let (m, e) = s.split_once('e').unwrap();
            format!("{m}e{}", c_exponent(e.parse().unwrap()))
        }
        'g' => {
            let p = match prec {
                Some(0) => 1,
                Some(p) => p,
                None => 6,
            };
            let s = format!("{:.*e}", p - 1, v);
            let (m, e) = s.split_once('e').unwrap();
            let x: i32 = e.parse().unwrap();
            let strip = |s: String| -> String {
                if alt || !s.contains('.') { s } else { s.trim_end_matches('0').trim_end_matches('.').to_string() }
            };
            if x >= -4 && x < p as i32 {
                strip(format!("{:.*}", (p as i32 - 1 - x) as usize, v))
            } else {
                format!("{}e{}", strip(m.to_string()), c_exponent(x))
            }
        }
        _ => {
            // %a: hexadecimal, as few digits as are needed.
            let bits = v.to_bits();
            let sign = if bits >> 63 == 1 { "-" } else { "" };
            let exp = ((bits >> 52) & 0x7ff) as i32;
            let frac = bits & ((1u64 << 52) - 1);
            if exp == 0 && frac == 0 {
                return format!("{sign}0x0p+0");
            }
            let (lead, e) = if exp == 0 { (0, -1022) } else { (1, exp - 1023) };
            let mut digits = format!("{frac:013x}");
            while digits.ends_with('0') {
                digits.pop();
            }
            let dot = if digits.is_empty() { String::new() } else { format!(".{digits}") };
            format!("{sign}0x{lead}{dot}p{}{}", if e < 0 { '-' } else { '+' }, e.abs())
        }
    }
}
