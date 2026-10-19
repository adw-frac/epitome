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
    /// A physical register, numbered as `machine.rs` numbers them: the
    /// files one after another.
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
    /// An offset from the stack pointer on entry: an argument the caller
    /// put on the stack. Known once the frame's size is.
    Incoming(i64),
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
    /// For a copy: the class of what is copied (recorded before register
    /// allocation, while the virtual registers say).
    pub class: Option<Class>,
}

impl MInst {
    pub fn new(op: usize, ops: Vec<MOp>) -> MInst {
        MInst { op: Opcode::Instr(op), ops, imp_uses: Vec::new(), imp_defs: Vec::new(), class: None }
    }

    pub fn copy(dst: Reg, src: Reg) -> MInst {
        MInst {
            op: Opcode::Copy,
            ops: vec![MOp::Reg(dst), MOp::Reg(src)],
            imp_uses: Vec::new(),
            imp_defs: Vec::new(),
            class: None,
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
                    if (k == 0 && ins.has_result) || (k == 1 && ins.second_result) {
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
    /// Each virtual register's class.
    pub vclass: Vec<Class>,
    pub slots: Vec<Slot>,
    pub frame_size: i64,
    /// Bytes at the bottom of the frame for arguments to calls.
    pub out_size: i64,
    pub abi: crate::abi::Abi,
}

impl MFunc {
    pub fn new_vreg(&mut self, class: Class) -> VReg {
        self.vclass.push(class);
        (self.vclass.len() - 1) as VReg
    }
}

// ---------------------------------------------------------------------------
// Printing

pub fn reg_name(t: &Target, r: Reg, class: Class) -> String {
    match r {
        Reg::P(n) => t.machine.name(class, n),
        Reg::V(v) => format!("%{}{v}", t.machine.def(class).name),
    }
}

/// The assembly for one instruction.
pub fn format_inst(t: &Target, f: &MFunc, inst: &MInst) -> String {
    match inst.op {
        Opcode::Copy => {
            let class = |o: &MOp| match o {
                MOp::Reg(Reg::V(v)) => Some(f.vclass[*v as usize]),
                _ => inst.class,
            };
            let r = |o: &MOp| match (o, class(o).or(class(&inst.ops[0])).or(class(&inst.ops[1]))) {
                (MOp::Reg(Reg::P(p)), Some(c)) if t.machine.field(c, *p).is_none() => {
                    let file = t.machine.file_of(*p);
                    let c = t.machine.scalar_in(file, t.machine.def(c).bits).unwrap_or(c);
                    reg_name(t, Reg::P(*p), c)
                }
                (MOp::Reg(r), Some(c)) => reg_name(t, *r, c),
                (MOp::Reg(Reg::P(p)), None) => format!("r{p}"),
                _ => "?".into(),
            };
            format!("COPY {}, {}", r(&inst.ops[0]), r(&inst.ops[1]))
        }
        Opcode::Instr(i) => {
            let value = |k: usize| -> Operand {
                match &inst.ops[k] {
                    MOp::Reg(r) => Operand::Reg(*r),
                    MOp::Imm(v) => Operand::Imm(*v),
                    MOp::Label(b) => Operand::Text(f.blocks[*b].label.clone()),
                    MOp::Sym(s) => Operand::Sym(s.clone()),
                    MOp::Frame(s, o) => Operand::Text(format!("frame{s}+{o}")),
                    MOp::Incoming(o) => Operand::Text(format!("incoming+{o}")),
                }
            };
            fill_template(t, Some(&f.abi), i, value)
        }
    }
}

pub enum Operand {
    Reg(Reg),
    Imm(i64),
    Text(String),
    /// A symbol, written as the platform writes it.
    Sym(String),
}

/// Fills in instruction `i`'s template, with `value(k)` for operand `k`.
/// `abi` says how to write symbols (`{s:page}` and `{s:pageoff}` are the
/// page holding a symbol and its offset in it).
pub fn fill_template(t: &Target, abi: Option<&crate::abi::Abi>, i: usize, value: impl Fn(usize) -> Operand) -> String {
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
                let m = &t.machine;
                // A vector arrangement, `{n:4s}`: v3.4s; or a lane's size,
                // `{n:.s}`: v3.s (followed in the template by `[k]`).
                if let Some(arr) =
                    modifier.filter(|m| m.len() >= 2 && (m.as_bytes()[0].is_ascii_digit() || m.starts_with('.')))
                {
                    let arr = arr.trim_start_matches('.');
                    match (r, m.class("lanes")) {
                        (Reg::P(n), Some(lanes)) => out.push_str(&format!("{}.{arr}", m.name(lanes, n))),
                        (Reg::P(_), None) => out.push('?'),
                        (Reg::V(v), _) => out.push_str(&format!("%v{v}.{arr}")),
                    }
                    continue;
                }
                // The register as another class names it: `{n:w}` is w3,
                // `{n:s}` s3, `{n:b}` b3.
                let class = match modifier {
                    Some(v) => match m.class(v) {
                        Some(c) => c,
                        None => {
                            out.push('?');
                            continue;
                        }
                    },
                    None => class,
                };
                out.push_str(&reg_name(t, r, class));
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
            // A symbol, as the relocation that fills it in writes it.
            (Operand::Sym(s), _) => out.push_str(&match (abi, ins.reloc) {
                (Some(a), Some(k)) => t.machine.relocs[k.0 as usize].spell(a.syntax, &a.symbol(&s)),
                (Some(a), None) => a.symbol(&s),
                (None, _) => s,
            }),
            (Operand::Reg(r), _) => out.push_str(&match r {
                Reg::P(p) => format!("r{p}"),
                Reg::V(v) => format!("%{v}"),
            }),
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
                    MOp::Reg(Reg::P(r)) => t.machine.index(*r),
                    MOp::Reg(Reg::V(_)) => return Err(format!("{}: a virtual register left after allocation", f.name)),
                    MOp::Imm(v) => *v,
                    MOp::Label(target) => starts[*target] as i64 - pc as i64,
                    MOp::Sym(s) => {
                        fixups.push(Fixup { offset: pc, symbol: s.clone(), instr: ins.name.clone() });
                        0
                    }
                    MOp::Frame(..) | MOp::Incoming(_) => {
                        return Err(format!("{}: a frame offset left after layout", f.name));
                    }
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
            fill_template(t, None, i, |k| {
                let o = &ins.operands[k];
                let v = env[&o.name];
                match o.kind {
                    Kind::Reg(c) => Operand::Reg(Reg::P(t.machine.phys(c, v))),
                    Kind::Label => Operand::Text(format!("0x{:x}", (pc as i64 + v) as u64)),
                    Kind::Sym => Operand::Text("<symbol>".into()),
                    Kind::Imm | Kind::Cond => Operand::Imm(v),
                }
            })
        }
    }
}
