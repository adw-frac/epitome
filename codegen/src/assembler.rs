//! An assembler: AArch64 assembly text to an object file (Mach-O or ELF),
//! with the machine description run backwards.
//!
//! Each instruction in the description says how it is written, in its
//! `"asm"` template (`add {d}, {n}, #{imm}`). To read a line, the
//! templates whose first word is the line's mnemonic are tried. A template
//! is literal text and holes; the text between holes must be in the line
//! as it is, and each hole takes what comes before the next piece of
//! literal text. A hole's text is then read loosely, as what its operand
//! is: a register (`w3`, `sp`, `v2.4s`, `q0`), a number (`#-12`, `0x1f`), a
//! condition (`ne`), a symbol (spelled as the instruction's relocation
//! spells it: `_x@PAGEOFF`, `:lo12:x`), or a label. Holes
//! that are expressions (`#{=0-imm}`) are solved for their operand.
//!
//! A reading is kept only if the template, filled in with the values read,
//! gives back the line exactly, and if the values encode (and decode back
//! to themselves: an immediate the encoding cannot hold does not fit). So
//! what is accepted is exactly what the printer writes, and the printer is
//! what the rest of the code generator is tested with. Where two
//! instructions both fit (`mov x0, x1` is both `orr` from `xzr` and `add`
//! to the stack pointer), the one using fewer registers of the
//! stack-pointer classes is chosen, which is the instruction an
//! assembler's alias rules choose; then the first in the description.
//!
//! Assembly is in two passes. The first lays out sections, labels and
//! data, an instruction being 4 bytes; the second encodes the
//! instructions, now that labels have addresses. References to symbols
//! are resolved as `object::resolve` does for compiled code, by the
//! format's rules, so the object file is the one `draconian-llc` writes
//! directly for the same program.
//!
//! The directives are those the code generator writes: `.text`, `.data`,
//! `.bss`, `.section`, `.globl`, `.p2align`, `.type`, `.size`, `.byte`,
//! `.short`, `.long`, `.quad` (of numbers, or of `symbol+offset`),
//! `.ascii`, `.asciz`, `.space`, `.zero` and `.build_version`; and
//! `.subsections_via_symbols`, which is accepted and ignored.

use std::collections::{HashMap, HashSet};

use crate::abi::Syntax;
use crate::enc::{self, Env};
use crate::mir::{self, Operand, Reg};
use crate::object::{self, Object, Pending, RelocKind, Section, SectionKind, Symbol, SymbolKind};
use crate::target::{Kind, Target};

/// An assembled file.
pub struct Assembled {
    pub object: Object,
    pub syntax: Syntax,
    /// From `.build_version`, for Mach-O; else 11.0.
    pub min_os: (u32, u32, u32),
}

impl Assembled {
    /// The object file, in the format the assembly was written for.
    pub fn file(&self, t: &Target) -> Result<Vec<u8>, String> {
        match self.syntax {
            Syntax::Elf => crate::elf::write(&self.object, &t.machine),
            Syntax::MachO => crate::macho::write(&self.object, self.min_os, &t.machine),
        }
    }
}

#[derive(Clone, Debug)]
enum Part {
    Lit(String),
    Hole(String),
}

#[derive(Clone, Debug)]
struct Template {
    instr: usize,
    parts: Vec<Part>,
}

fn split_template(tpl: &str) -> Vec<Part> {
    let mut parts = Vec::new();
    let mut rest = tpl;
    while let Some(open) = rest.find('{') {
        if open > 0 {
            parts.push(Part::Lit(rest[..open].to_string()));
        }
        let close = rest[open..].find('}').map_or(rest.len(), |c| open + c);
        parts.push(Part::Hole(rest[open + 1..close].to_string()));
        rest = &rest[(close + 1).min(rest.len())..];
    }
    if !rest.is_empty() {
        parts.push(Part::Lit(rest.to_string()));
    }
    parts
}

fn mnemonic(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}

/// Reads the assembly of `t`'s instructions.
pub struct Assembler<'t> {
    t: &'t Target,
    by_mnemonic: HashMap<String, Vec<Template>>,
    /// Templates with a hole in the mnemonic (`b.{c}`), by the literal
    /// text before it.
    by_prefix: Vec<(String, Template)>,
    /// How many lines that cannot be assembled to report.
    pub max_errors: usize,
}

/// What a line's holes said.
struct Reading {
    env: Env,
    shown: HashMap<usize, Operand>,
    /// The symbol operand: its index and the symbol's name.
    sym: Option<(usize, String)>,
    /// The label operand: its index and the label.
    label: Option<(usize, String)>,
}

fn parse_int(s: &str) -> Option<i64> {
    let s = s.trim();
    let (neg, body) = match s.strip_prefix('-') {
        Some(b) => (true, b),
        None => (false, s.strip_prefix('+').unwrap_or(s)),
    };
    let v = match body.strip_prefix("0x").or_else(|| body.strip_prefix("0X")) {
        Some(h) => u64::from_str_radix(h, 16).ok()? as i64,
        None => body.parse::<u64>().ok()? as i64,
    };
    Some(if neg { v.wrapping_neg() } else { v })
}

fn valid_symbol(s: &str) -> bool {
    !s.is_empty()
        && !s.starts_with(|c: char| c.is_ascii_digit())
        && s.chars().all(|c| c.is_ascii_alphanumeric() || matches!(c, '_' | '.' | '$'))
}

impl<'t> Assembler<'t> {
    pub fn new(t: &'t Target) -> Assembler<'t> {
        let mut by_mnemonic: HashMap<String, Vec<Template>> = HashMap::new();
        let mut by_prefix = Vec::new();
        for (i, ins) in t.instrs.iter().enumerate() {
            if ins.asm.is_empty() {
                continue;
            }
            let tpl = Template { instr: i, parts: split_template(&ins.asm) };
            let m = mnemonic(&ins.asm);
            match m.find('{') {
                Some(k) => by_prefix.push((m[..k].to_string(), tpl)),
                None => by_mnemonic.entry(m.to_string()).or_default().push(tpl),
            }
        }
        Assembler { t, by_mnemonic, by_prefix, max_errors: 20 }
    }

    /// The holes' texts, if `line` has the template's literal text.
    fn holes<'l>(&self, tpl: &Template, line: &'l str) -> Option<Vec<(String, &'l str)>> {
        let mut pos = 0;
        let mut out = Vec::new();
        for (k, part) in tpl.parts.iter().enumerate() {
            match part {
                Part::Lit(l) => {
                    if !line[pos..].starts_with(l.as_str()) {
                        return None;
                    }
                    pos += l.len();
                }
                Part::Hole(inner) => {
                    let end = match tpl.parts.get(k + 1) {
                        Some(Part::Lit(l)) => pos + line[pos..].find(l.as_str())?,
                        Some(Part::Hole(_)) => return None,
                        None => line.len(),
                    };
                    if end == pos {
                        return None;
                    }
                    out.push((inner.clone(), &line[pos..end]));
                    pos = end;
                }
            }
        }
        (pos == line.len()).then_some(out)
    }

    /// Reads a line as instruction `i`, by the holes' texts.
    fn read(&self, i: usize, holes: &[(String, &str)], syntax: Syntax) -> Option<Reading> {
        let ins = &self.t.instrs[i];
        let mut r = Reading { env: Env::new(), shown: HashMap::new(), sym: None, label: None };
        let set = |env: &mut Env, name: &str, v: i64| -> Option<()> {
            match env.insert(name.to_string(), v) {
                Some(old) if old != v => None,
                _ => Some(()),
            }
        };
        for (inner, text) in holes {
            if let Some(expr) = inner.strip_prefix('=') {
                let e = enc::parse_expr(expr).ok()?;
                let (name, v) = enc::invert(&e, parse_int(text)?)?;
                set(&mut r.env, &name, v)?;
                continue;
            }
            let (name, _) = match inner.split_once(':') {
                Some((n, m)) => (n, Some(m)),
                None => (inner.as_str(), None),
            };
            let k = ins.operands.iter().position(|o| o.name == name)?;
            match ins.operands[k].kind {
                Kind::Reg(class) => {
                    // By any of its names (a vector's without its
                    // arrangement); the template, printing it back,
                    // decides whether the name was the right one.
                    let p = self.t.machine.lookup(text.split('.').next()?)?;
                    let n = self.t.machine.field(class, p)?;
                    set(&mut r.env, name, n)?;
                    r.shown.insert(k, Operand::Reg(Reg::P(p)));
                }
                Kind::Imm => set(&mut r.env, name, parse_int(text)?)?,
                Kind::Cond => {
                    let c = self.t.conds.iter().find(|c| c.asm == *text)?;
                    set(&mut r.env, name, c.value)?;
                }
                Kind::Sym => {
                    // As the instruction's relocation spells it.
                    let sym = match ins.reloc {
                        Some(rk) => self.t.machine.relocs[rk.0 as usize].unspell(syntax, text)?,
                        None => text,
                    };
                    let s = valid_symbol(sym).then(|| sym.to_string())?;
                    set(&mut r.env, name, 0)?;
                    r.sym = Some((k, s));
                    r.shown.insert(k, Operand::Text(text.to_string()));
                }
                Kind::Label => {
                    if !valid_symbol(text) {
                        return None;
                    }
                    r.label = Some((k, text.to_string()));
                    r.shown.insert(k, Operand::Text(text.to_string()));
                }
            }
        }
        Some(r)
    }

    /// The instruction `line` is, encoded at `pc`, with `label` giving the
    /// address of a label in the same section; and the symbol it refers
    /// to, if it does.
    fn encode(
        &self,
        line: &str,
        pc: u64,
        syntax: Syntax,
        label: &dyn Fn(&str) -> Option<u64>,
    ) -> Result<(usize, u32, Option<String>), String> {
        let m = mnemonic(line);
        let cands: Vec<&Template> = self
            .by_mnemonic
            .get(m)
            .into_iter()
            .flatten()
            .chain(self.by_prefix.iter().filter(|(p, _)| m.starts_with(p.as_str())).map(|(_, t)| t))
            .collect();
        if cands.is_empty() {
            return Err("no instruction has this mnemonic".into());
        }
        let mut best: Option<(usize, usize, u32, Option<String>)> = None;
        for tpl in cands {
            let Some(holes) = self.holes(tpl, line) else { continue };
            let Some(mut r) = self.read(tpl.instr, &holes, syntax) else { continue };
            let ins = &self.t.instrs[tpl.instr];
            if let Some((k, name)) = &r.label {
                let Some(at) = label(name) else {
                    return Err(format!("no label {name} in this section"));
                };
                r.env.insert(ins.operands[*k].name.clone(), at as i64 - pc as i64);
            }
            // The template, filled in, must give the line back.
            let printed = mir::fill_template(self.t, None, tpl.instr, |k| {
                if let Some(op) = r.shown.get(&k) {
                    return match op {
                        Operand::Reg(x) => Operand::Reg(*x),
                        Operand::Text(s) => Operand::Text(s.clone()),
                        Operand::Imm(v) => Operand::Imm(*v),
                        Operand::Sym(s) => Operand::Sym(s.clone()),
                    };
                }
                match r.env.get(&ins.operands[k].name) {
                    Some(v) => Operand::Imm(*v),
                    None => Operand::Text("?".into()),
                }
            });
            if printed != line {
                continue;
            }
            // The values must encode, and decode back as themselves.
            let Some(word) = ins.enc.encode(&r.env) else { continue };
            let Some(back) = ins.decode(word) else { continue };
            if r.env.iter().any(|(n, v)| back.get(n).is_some_and(|b| b != v)) {
                continue;
            }
            let sp_classes =
                ins.operands.iter().filter(|o| matches!(o.kind, Kind::Reg(c) if self.t.machine.def(c).sp)).count();
            if best.as_ref().is_none_or(|b| sp_classes < b.0) {
                best = Some((sp_classes, tpl.instr, word, r.sym.map(|s| s.1)));
            }
        }
        best.map(|(_, i, w, s)| (i, w, s))
            .ok_or_else(|| "no instruction is written this way, or its values do not fit".into())
    }

    /// Assembles `text`: Mach-O assembly if it says so (`.build_version`,
    /// or `__TEXT` and `__DATA` sections), or `syntax` says so; else ELF.
    pub fn assemble(&self, text: &str, syntax: Option<Syntax>) -> Result<Assembled, String> {
        let syntax = syntax.unwrap_or_else(|| {
            let macho = text.lines().any(|l| {
                let l = l.trim();
                l.starts_with(".build_version")
                    || (l.starts_with(".section") && (l.contains("__TEXT") || l.contains("__DATA")))
            });
            if macho { Syntax::MachO } else { Syntax::Elf }
        });
        let temp = |name: &str| match syntax {
            Syntax::MachO => name.starts_with('L'),
            Syntax::Elf => name.starts_with(".L"),
        };
        let mut obj = Object::default();
        let mut by_kind: HashMap<SectionKind, usize> = HashMap::new();
        let mut cur: Option<usize> = None;
        let mut discard = false;
        let mut labels: HashMap<String, (usize, u64)> = HashMap::new();
        let mut defined: Vec<String> = Vec::new();
        let mut globals: HashSet<String> = HashSet::new();
        let mut types: HashMap<String, SymbolKind> = HashMap::new();
        let mut sizes: HashMap<String, u64> = HashMap::new();
        let mut min_os = (11, 0, 0);
        // What the second pass does, in order: instructions, and data
        // that refers to symbols.
        enum Later {
            Instr { section: usize, offset: u64, line: usize, text: String },
            Data { section: usize, offset: u64, symbol: String, addend: i64 },
        }
        let mut later: Vec<Later> = Vec::new();
        let lines: Vec<&str> = text.lines().collect();

        let err = |n: usize, msg: String| format!("line {}: {msg}: `{}`", n + 1, lines[n].trim());
        for (n, raw) in lines.iter().enumerate() {
            let mut line = strip_comment(raw).trim();
            // Labels, perhaps followed by more on the line.
            while let Some((name, rest)) = line.split_once(':')
                && valid_symbol(name)
            {
                let name = name.to_string();
                let s = section_of(&mut obj, &mut by_kind, &mut cur, SectionKind::Text);
                let at = obj.sections[s].size();
                if labels.insert(name.clone(), (s, at)).is_some() {
                    return Err(err(n, format!("{name} is defined twice")));
                }
                if !temp(&name) {
                    defined.push(name);
                }
                line = rest.trim();
            }
            if line.is_empty() {
                continue;
            }
            if let Some(d) = line.strip_prefix('.').filter(|d| d.starts_with(|c: char| c.is_ascii_alphabetic())) {
                let (name, args) = d.split_once(char::is_whitespace).unwrap_or((d, ""));
                let args = args.trim();
                let list = || split_args(args);
                let mut switch = |kind: Option<SectionKind>| {
                    discard = kind.is_none();
                    if let Some(k) = kind {
                        cur = Some(section_for(&mut obj, &mut by_kind, k));
                    }
                };
                match name {
                    "text" => switch(Some(SectionKind::Text)),
                    "data" => switch(Some(SectionKind::Data)),
                    "bss" => switch(Some(SectionKind::Bss)),
                    "section" => {
                        let kind =
                            section_kind(args, syntax).ok_or_else(|| err(n, "a section not supported".into()))?;
                        switch(kind);
                    }
                    "globl" | "global" => {
                        globals.insert(args.to_string());
                    }
                    "p2align" | "align" | "balign" => {
                        let v = list()
                            .first()
                            .and_then(|a| parse_int(a))
                            .ok_or_else(|| err(n, "a bad alignment".into()))?;
                        let align = if name == "balign" { v as u64 } else { 1u64 << v };
                        let s = section_of(&mut obj, &mut by_kind, &mut cur, SectionKind::Text);
                        let sec = &mut obj.sections[s];
                        sec.align = sec.align.max(align);
                        let at = sec.size().next_multiple_of(align);
                        if sec.kind == SectionKind::Bss {
                            sec.bss_size = at;
                        } else {
                            sec.data.resize(at as usize, 0);
                        }
                    }
                    "type" => {
                        let a = list();
                        let kind = match a.get(1).map(|s| s.trim_start_matches(['%', '@'])) {
                            Some("function") => SymbolKind::Func,
                            Some("object") => SymbolKind::Object,
                            _ => return Err(err(n, "a symbol type not supported".into())),
                        };
                        types.insert(a[0].clone(), kind);
                    }
                    "size" => {
                        let a = list();
                        let (Some(sym), Some(expr)) = (a.first(), a.get(1)) else {
                            return Err(err(n, "a bad .size".into()));
                        };
                        let size = match expr.strip_prefix(".-") {
                            Some(start) if start == sym => {
                                let (s, at) = *labels.get(start).ok_or_else(|| err(n, format!("no label {start}")))?;
                                obj.sections[s].size() - at
                            }
                            _ => parse_int(expr).ok_or_else(|| err(n, "a size not supported".into()))? as u64,
                        };
                        sizes.insert(sym.clone(), size);
                    }
                    "byte" | "short" | "hword" | "2byte" | "long" | "word" | "4byte" | "quad" | "xword" | "8byte" => {
                        let size = match name {
                            "byte" => 1,
                            "short" | "hword" | "2byte" => 2,
                            "long" | "word" | "4byte" => 4,
                            _ => 8,
                        };
                        let s = section_of(&mut obj, &mut by_kind, &mut cur, SectionKind::Data);
                        for v in list() {
                            let sec = &mut obj.sections[s];
                            if sec.kind == SectionKind::Bss {
                                return Err(err(n, "data in .bss".into()));
                            }
                            match parse_int(&v) {
                                Some(x) => sec.data.extend_from_slice(&(x as u64).to_le_bytes()[..size]),
                                None if size == 8 => {
                                    let (symbol, addend) =
                                        parse_sym_offset(&v).ok_or_else(|| err(n, format!("a bad value {v}")))?;
                                    later.push(Later::Data {
                                        section: s,
                                        offset: sec.data.len() as u64,
                                        symbol,
                                        addend,
                                    });
                                    sec.data.extend_from_slice(&[0; 8]);
                                }
                                None => return Err(err(n, format!("a value not supported here: {v}"))),
                            }
                        }
                    }
                    "ascii" | "asciz" | "string" => {
                        let mut bytes = unescape(args).ok_or_else(|| err(n, "a bad string".into()))?;
                        if name != "ascii" {
                            bytes.push(0);
                        }
                        let s = section_of(&mut obj, &mut by_kind, &mut cur, SectionKind::Data);
                        obj.sections[s].data.extend_from_slice(&bytes);
                    }
                    "space" | "zero" | "skip" => {
                        let a = list();
                        let count = a.first().and_then(|x| parse_int(x)).ok_or_else(|| err(n, "a bad size".into()))?;
                        let fill = a.get(1).and_then(|x| parse_int(x)).unwrap_or(0) as u8;
                        let s = section_of(&mut obj, &mut by_kind, &mut cur, SectionKind::Data);
                        let sec = &mut obj.sections[s];
                        if sec.kind == SectionKind::Bss {
                            sec.bss_size += count as u64;
                        } else {
                            sec.data.resize(sec.data.len() + count as usize, fill);
                        }
                    }
                    "build_version" => {
                        let a = list();
                        let num = |k: usize| a.get(k).and_then(|x| parse_int(x)).map(|v| v as u32);
                        if a.first().map(String::as_str) != Some("macos") {
                            return Err(err(n, "a platform other than macOS".into()));
                        }
                        min_os = (num(1).unwrap_or(11), num(2).unwrap_or(0), num(3).unwrap_or(0));
                    }
                    "subsections_via_symbols" => {}
                    _ => return Err(err(n, format!("the directive .{name} is not supported"))),
                }
                continue;
            }
            if discard {
                return Err(err(n, "an instruction in a section that is not kept".into()));
            }
            let s = section_of(&mut obj, &mut by_kind, &mut cur, SectionKind::Text);
            let sec = &mut obj.sections[s];
            if sec.kind == SectionKind::Bss {
                return Err(err(n, "an instruction in .bss".into()));
            }
            later.push(Later::Instr { section: s, offset: sec.data.len() as u64, line: n, text: normalise(line) });
            sec.data.extend_from_slice(&[0; 4]);
        }

        // The second pass: instructions, and references to symbols in order.
        // Every instruction that cannot be read is reported.
        let mut pending = Vec::new();
        let mut errors = Vec::new();
        for l in later {
            match l {
                Later::Instr { section, offset, line, text } => {
                    let find = |name: &str| labels.get(name).filter(|l| l.0 == section).map(|l| l.1);
                    let (i, word, sym) = match self.encode(&text, offset, syntax, &find) {
                        Ok(x) => x,
                        Err(e) => {
                            errors.push(err(line, e));
                            continue;
                        }
                    };
                    obj.sections[section].data[offset as usize..offset as usize + 4]
                        .copy_from_slice(&word.to_le_bytes());
                    if let Some(symbol) = sym {
                        let kind = self.t.instrs[i]
                            .reloc
                            .ok_or_else(|| err(line, "a symbol in an instruction without a \"reloc\"".into()))?;
                        pending.push(Pending { section, offset, kind, symbol, addend: 0, instr: Some(i) });
                    }
                }
                Later::Data { section, offset, symbol, addend } => {
                    let kind =
                        self.t.machine.data_reloc(8).ok_or("the description has no relocation for pointers in data")?;
                    pending.push(Pending {
                        section,
                        offset,
                        kind: RelocKind(kind as u16),
                        symbol,
                        addend,
                        instr: None,
                    });
                }
            }
        }
        if !errors.is_empty() {
            let n = errors.len();
            errors.truncate(self.max_errors);
            let more =
                if n > self.max_errors { format!("\n... and {} more", n - self.max_errors) } else { String::new() };
            return Err(format!("{n} lines could not be assembled:\n{}{more}", errors.join("\n")));
        }
        for name in defined {
            let (s, value) = labels[&name];
            let code = obj.sections[s].kind == SectionKind::Text;
            obj.symbols.push(Symbol {
                size: sizes.get(&name).copied().unwrap_or(0),
                kind: types.get(&name).copied().unwrap_or(if code { SymbolKind::Func } else { SymbolKind::Object }),
                global: globals.contains(&name),
                section: Some(s),
                value,
                name,
            });
        }
        object::resolve(self.t, &mut obj, pending, syntax == Syntax::MachO)?;
        Ok(Assembled { object: obj, syntax, min_os })
    }
}

/// The section a `.section` directive names: `None` for one that is not
/// kept (`.note.GNU-stack`, which the ELF writer adds itself).
fn section_kind(args: &str, syntax: Syntax) -> Option<Option<SectionKind>> {
    let parts: Vec<&str> = args.split(',').map(str::trim).collect();
    let name = match syntax {
        Syntax::MachO => format!("{},{}", parts.first()?, parts.get(1)?),
        Syntax::Elf => parts.first()?.to_string(),
    };
    Some(Some(match name.as_str() {
        "__TEXT,__text" | ".text" => SectionKind::Text,
        "__DATA,__data" | ".data" => SectionKind::Data,
        "__DATA,__bss" | ".bss" => SectionKind::Bss,
        "__TEXT,__const" | ".rodata" => SectionKind::ReadOnly,
        "__DATA,__const" | ".data.rel.ro" => SectionKind::RelRo,
        ".note.GNU-stack" => return Some(None),
        _ => return None,
    }))
}

/// The section of this kind, made the first time it is used.
fn section_for(obj: &mut Object, by_kind: &mut HashMap<SectionKind, usize>, kind: SectionKind) -> usize {
    *by_kind.entry(kind).or_insert_with(|| {
        obj.sections.push(Section { kind, align: 1, data: Vec::new(), bss_size: 0, relocs: Vec::new() });
        obj.sections.len() - 1
    })
}

/// The current section (`default`'s, if none was named yet).
fn section_of(
    obj: &mut Object,
    by_kind: &mut HashMap<SectionKind, usize>,
    cur: &mut Option<usize>,
    default: SectionKind,
) -> usize {
    let s = match *cur {
        Some(s) => s,
        None => section_for(obj, by_kind, default),
    };
    *cur = Some(s);
    s
}

/// The line without a comment (`//` or `;`, outside strings).
fn strip_comment(line: &str) -> &str {
    let mut in_str = false;
    let mut escaped = false;
    let b = line.as_bytes();
    for (k, &c) in b.iter().enumerate() {
        if in_str {
            match c {
                _ if escaped => escaped = false,
                b'\\' => escaped = true,
                b'"' => in_str = false,
                _ => {}
            }
            continue;
        }
        match c {
            b'"' => in_str = true,
            b';' => return &line[..k],
            b'/' if b.get(k + 1) == Some(&b'/') => return &line[..k],
            _ => {}
        }
    }
    line
}

/// An instruction line as the printer writes it: the mnemonic, one space,
/// then the operands.
fn normalise(line: &str) -> String {
    match line.split_once(char::is_whitespace) {
        Some((m, rest)) => format!("{m} {}", rest.trim()),
        None => line.to_string(),
    }
}

/// A directive's arguments, split at commas outside strings.
fn split_args(args: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut cur = String::new();
    let mut in_str = false;
    for c in args.chars() {
        match c {
            '"' => {
                in_str = !in_str;
                cur.push(c);
            }
            ',' if !in_str => out.push(std::mem::take(&mut cur).trim().to_string()),
            _ => cur.push(c),
        }
    }
    if !cur.trim().is_empty() || !out.is_empty() {
        out.push(cur.trim().to_string());
    }
    out
}

/// `sym`, `sym+8` or `sym-8`.
fn parse_sym_offset(s: &str) -> Option<(String, i64)> {
    let s = s.trim();
    let split = s.char_indices().skip(1).find(|&(_, c)| c == '+' || c == '-').map(|(k, _)| k);
    let (name, off) = match split {
        Some(k) => (&s[..k], parse_int(&s[k..])?),
        None => (s, 0),
    };
    valid_symbol(name).then(|| (name.to_string(), off))
}

/// The bytes of a quoted string, with `\\`, `\"`, `\n`, `\t`, `\r`, `\0`
/// and octal escapes `\ooo`.
fn unescape(s: &str) -> Option<Vec<u8>> {
    let inner = s.trim().strip_prefix('"')?.strip_suffix('"')?;
    let b = inner.as_bytes();
    let mut out = Vec::new();
    let mut k = 0;
    while k < b.len() {
        if b[k] != b'\\' {
            out.push(b[k]);
            k += 1;
            continue;
        }
        k += 1;
        let c = *b.get(k)?;
        match c {
            b'0'..=b'7' => {
                let mut v = 0u32;
                let mut n = 0;
                while n < 3 && k < b.len() && (b'0'..=b'7').contains(&b[k]) {
                    v = v * 8 + (b[k] - b'0') as u32;
                    k += 1;
                    n += 1;
                }
                out.push(v as u8);
                continue;
            }
            b'n' => out.push(b'\n'),
            b't' => out.push(b'\t'),
            b'r' => out.push(b'\r'),
            b'b' => out.push(8),
            b'f' => out.push(12),
            _ => out.push(c),
        }
        k += 1;
    }
    Some(out)
}
