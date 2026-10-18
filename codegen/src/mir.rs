//! Machine IR: blocks of machine instructions, each an instruction from the
//! description (or a copy) with its operands. Printing, encoding and
//! disassembly all go through the description: the `"asm"` template and
//! the `"enc"` fields.

use std::fmt::Write;

use crate::enc::{self, Env};
use crate::target::{Class, Kind, Target};

pub type VReg = u32;

#[derive(Clone, Copy, PartialEq, Eq, Debug, Hash)]
pub enum Reg {
    V(VReg),
    /// A physical register: 0-30, or 31 for the zero register or the stack
    /// pointer, as the operand's class says.
    P(u8),
}

#[derive(Clone, PartialEq, Debug)]
pub enum MOp {
    Reg(Reg),
    Imm(i64),
    /// A block of the same function.
    Label(usize),
    Sym(String),
    /// An offset in the frame, known once the frame is laid out: the slot
    /// and a byte offset in it.
    Frame(usize, i64),
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Opcode {
    Instr(usize),
    /// `ops[0] = ops[1]`, both registers of the width of `ops[0]`.
    Copy,
}

#[derive(Clone, Debug)]
pub struct MInst {
    pub op: Opcode,
    pub ops: Vec<MOp>,
    pub imp_uses: Vec<u8>,
    pub imp_defs: Vec<u8>,
    /// For a copy: 64 bits wide, rather than 32.
    pub wide: bool,
}

impl MInst {
    pub fn new(op: usize, ops: Vec<MOp>) -> MInst {
        MInst { op: Opcode::Instr(op), ops, imp_uses: Vec::new(), imp_defs: Vec::new(), wide: true }
    }

    pub fn copy(dst: Reg, src: Reg) -> MInst {
        MInst {
            op: Opcode::Copy,
            ops: vec![MOp::Reg(dst), MOp::Reg(src)],
            imp_uses: Vec::new(),
            imp_defs: Vec::new(),
            wide: true,
        }
    }

    /// The registers this instruction defines and uses, by operand index.
    pub fn defs_uses(&self, t: &Target) -> (Vec<usize>, Vec<usize>) {
        let mut defs = Vec::new();
        let mut uses = Vec::new();
        match self.op {
            Opcode::Copy => {
                defs.push(0);
                uses.push(1);
            }
            Opcode::Instr(i) => {
                let ins = &t.instrs[i];
                for (k, o) in ins.operands.iter().enumerate() {
                    if !matches!(self.ops.get(k), Some(MOp::Reg(_))) {
                        continue;
                    }
                    if k == 0 && ins.has_result {
                        defs.push(k);
                    } else if matches!(o.kind, Kind::Reg(_)) {
                        uses.push(k);
                        if o.writeback {
                            defs.push(k);
                        }
                    }
                }
            }
        }
        (defs, uses)
    }
}

#[derive(Clone, Debug)]
pub struct MBlock {
    pub label: String,
    pub insts: Vec<MInst>,
    pub succs: Vec<usize>,
    /// Where the instructions for the block's terminator start: copies for
    /// the successors' phis go here.
    pub term_start: usize,
}

#[derive(Clone, Debug)]
pub struct Slot {
    pub size: u64,
    pub align: u64,
    pub offset: i64,
}

#[derive(Clone, Debug)]
pub struct MFunc {
    pub name: String,
    pub global: bool,
    pub blocks: Vec<MBlock>,
    /// For each virtual register: is it 64 bits wide?
    pub vwide: Vec<bool>,
    pub slots: Vec<Slot>,
    pub frame_size: i64,
}

impl MFunc {
    pub fn new_vreg(&mut self, wide: bool) -> VReg {
        self.vwide.push(wide);
        (self.vwide.len() - 1) as VReg
    }
}

// ---------------------------------------------------------------------------
// Printing

pub fn reg_name(r: Reg, class: Class) -> String {
    match r {
        Reg::P(n) => class.name(n),
        Reg::V(v) => format!("%{}{v}", if class.is_64() { "x" } else { "w" }),
    }
}

/// The assembly for one instruction.
pub fn format_inst(t: &Target, f: &MFunc, inst: &MInst) -> String {
    match inst.op {
        Opcode::Copy => {
            let wide = match &inst.ops[0] {
                MOp::Reg(Reg::V(v)) => f.vwide[*v as usize],
                _ => true,
            };
            let c = if wide { Class::X } else { Class::W };
            let r = |o: &MOp| if let MOp::Reg(r) = o { reg_name(*r, c) } else { "?".into() };
            format!("COPY {}, {}", r(&inst.ops[0]), r(&inst.ops[1]))
        }
        Opcode::Instr(i) => {
            let value = |k: usize| -> Operand {
                match &inst.ops[k] {
                    MOp::Reg(r) => Operand::Reg(*r),
                    MOp::Imm(v) => Operand::Imm(*v),
                    MOp::Label(b) => Operand::Text(f.blocks[*b].label.clone()),
                    MOp::Sym(s) => Operand::Text(format!("_{s}")),
                    MOp::Frame(s, o) => Operand::Text(format!("frame{s}+{o}")),
                }
            };
            fill_template(t, i, value)
        }
    }
}

pub enum Operand {
    Reg(Reg),
    Imm(i64),
    Text(String),
}

/// Fills in instruction `i`'s template, with `value(k)` for operand `k`.
pub fn fill_template(t: &Target, i: usize, value: impl Fn(usize) -> Operand) -> String {
    let ins = &t.instrs[i];
    let tpl = &ins.asm;
    let mut out = String::new();
    let mut rest = tpl.as_str();
    while let Some(open) = rest.find('{') {
        out.push_str(&rest[..open]);
        let close = rest[open..].find('}').map(|c| open + c).unwrap_or(rest.len());
        let inner = &rest[open + 1..close];
        rest = &rest[(close + 1).min(rest.len())..];
        if let Some(expr) = inner.strip_prefix('=') {
            let mut env = Env::new();
            for (k, o) in ins.operands.iter().enumerate() {
                if let Operand::Imm(v) = value(k) {
                    env.insert(o.name.clone(), v);
                }
            }
            let v = enc::parse_expr(expr).ok().and_then(|e| enc::eval(&e, &env));
            let _ = write!(out, "{}", v.map_or("?".to_string(), |v| v.to_string()));
            continue;
        }
        let (name, modifier) = match inner.split_once(':') {
            Some((n, m)) => (n, Some(m)),
            None => (inner, None),
        };
        let Some(k) = ins.operands.iter().position(|o| o.name == name) else {
            out.push('?');
            continue;
        };
        let o = &ins.operands[k];
        match (value(k), o.kind) {
            (Operand::Reg(r), Kind::Reg(class)) => {
                let class = match modifier {
                    Some("w") => class.with_width(false),
                    Some("x") => class.with_width(true),
                    _ => class,
                };
                out.push_str(&reg_name(r, class));
            }
            (Operand::Imm(v), Kind::Cond) => {
                out.push_str(t.conds.iter().find(|c| c.value == v).map_or("?", |c| c.asm.as_str()));
            }
            (Operand::Imm(v), _) => match modifier {
                Some("h32") => {
                    let _ = write!(out, "0x{:x}", v as u64 & 0xffff_ffff);
                }
                Some("h64") => {
                    let _ = write!(out, "0x{:x}", v as u64);
                }
                _ => {
                    let _ = write!(out, "{v}");
                }
            },
            (Operand::Text(s), _) => out.push_str(&s),
            (Operand::Reg(r), _) => out.push_str(&reg_name(r, Class::X)),
        }
    }
    out.push_str(rest);
    out
}

// ---------------------------------------------------------------------------
// Encoding

#[derive(Clone, Debug, PartialEq)]
pub struct Fixup {
    pub offset: usize,
    pub symbol: String,
    pub instr: String,
}

/// The machine code for a function laid out and allocated, with a fixup
/// for each symbol reference. Branches within the function are resolved.
pub fn encode_function(t: &Target, f: &MFunc) -> Result<(Vec<u32>, Vec<Fixup>), String> {
    let mut starts = Vec::new();
    let mut n = 0usize;
    for b in &f.blocks {
        starts.push(n * 4);
        n += b.insts.len();
    }
    let mut words = Vec::new();
    let mut fixups = Vec::new();
    for (bi, b) in f.blocks.iter().enumerate() {
        for (k, inst) in b.insts.iter().enumerate() {
            let pc = starts[bi] + k * 4;
            let Opcode::Instr(i) = inst.op else { return Err(format!("{}: a copy left after allocation", f.name)) };
            let ins = &t.instrs[i];
            let mut env = Env::new();
            for (o, op) in ins.operands.iter().zip(&inst.ops) {
                let v = match op {
                    MOp::Reg(Reg::P(r)) => *r as i64,
                    MOp::Reg(Reg::V(_)) => return Err(format!("{}: a virtual register left after allocation", f.name)),
                    MOp::Imm(v) => *v,
                    MOp::Label(target) => starts[*target] as i64 - pc as i64,
                    MOp::Sym(s) => {
                        fixups.push(Fixup { offset: pc, symbol: s.clone(), instr: ins.name.clone() });
                        0
                    }
                    MOp::Frame(..) => return Err(format!("{}: a frame offset left after layout", f.name)),
                };
                env.insert(o.name.clone(), v);
            }
            let word = ins
                .enc
                .encode(&env)
                .ok_or_else(|| format!("{}: cannot encode `{}`", f.name, format_inst(t, f, inst)))?;
            words.push(word);
        }
    }
    Ok((words, fixups))
}

// ---------------------------------------------------------------------------
// Disassembly

/// The instruction a word encodes, and its operands, if the description
/// has it: the candidates whose literal bits match, most literal bits first.
pub fn decode(t: &Target, word: u32) -> Option<(usize, Env)> {
    let mut cands: Vec<usize> = (0..t.instrs.len())
        .filter(|&i| t.instrs[i].decode && word & t.instrs[i].enc.mask == t.instrs[i].enc.value)
        .collect();
    cands.sort_by_key(|&i| std::cmp::Reverse(t.instrs[i].enc.mask.count_ones()));
    for i in cands {
        let ins = &t.instrs[i];
        let Some(env) = ins.decode(word) else { continue };
        // A condition must be one the description names.
        let conds_ok =
            ins.operands.iter().all(|o| o.kind != Kind::Cond || t.conds.iter().any(|c| c.value == env[&o.name]));
        if conds_ok {
            return Some((i, env));
        }
    }
    None
}

/// Disassembles one word at address `pc`.
pub fn disassemble(t: &Target, word: u32, pc: u64) -> String {
    match decode(t, word) {
        None => format!(".word 0x{word:08x}"),
        Some((i, env)) => {
            let ins = &t.instrs[i];
            fill_template(t, i, |k| {
                let o = &ins.operands[k];
                let v = env[&o.name];
                match o.kind {
                    Kind::Reg(_) => Operand::Reg(Reg::P(v as u8)),
                    Kind::Label => Operand::Text(format!("0x{:x}", (pc as i64 + v) as u64)),
                    Kind::Sym => Operand::Text("<symbol>".into()),
                    Kind::Imm | Kind::Cond => Operand::Imm(v),
                }
            })
        }
    }
}
