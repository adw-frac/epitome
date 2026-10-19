//! What `draconian-objdump` prints: an object file's sections, symbols,
//! relocations and contents, and its code disassembled with the machine
//! description.
//!
//! A file (ELF, or Mach-O: objects, linked images, and the arm64 slice of
//! universal files) is first read into an [`Image`], which says the same
//! for every format: sections with their addresses and bytes, symbols
//! with their addresses, and relocations against names.
//!
//! Disassembly decodes each word as the description's instruction whose
//! literal bits it has (see `mir::decode`). Where a relocation will fill a
//! word in, the word is decoded as the instruction that carries that kind
//! of relocation (its `"reloc"`), and the symbol is printed in its place, as
//! assembly would write it: `add x0, x0, #0` with an `R_AARCH64_ADD_ABS_LO12_NC`
//! against `names` is `add x0, x0, :lo12:names`. Branch targets are printed
//! with the symbol they are in, `0x98 <use+0x90>`. Mapping symbols (`$x`,
//! `$d`) say where code and data are in a section: data is printed as
//! `.word`s.

use std::fmt::Write;

use crate::abi::Syntax;
use crate::enc::Env;
use crate::machine::Machine;
use crate::mir::{self, Operand, Reg};
use crate::object::RelocKind;
use crate::target::{Kind, Target};
use crate::{elf, macho};

#[derive(Clone, Debug)]
pub struct Image {
    /// The format, as objdump names it: `elf64-littleaarch64`.
    pub format: String,
    /// Mach-O: symbols are written `sym@PAGE`, not `:lo12:sym`.
    pub macho: bool,
    pub sections: Vec<ImageSection>,
    pub symbols: Vec<ImageSymbol>,
}

#[derive(Clone, Debug)]
pub struct ImageSection {
    pub name: String,
    pub addr: u64,
    pub size: u64,
    /// The contents (empty if the section has none in the file).
    pub data: Vec<u8>,
    pub code: bool,
    /// `TEXT`, `DATA`, `BSS`, or empty for sections not loaded.
    pub kind: &'static str,
    pub relocs: Vec<ImageReloc>,
}

#[derive(Clone, Debug)]
pub struct ImageReloc {
    /// From the start of the section.
    pub offset: u64,
    pub type_name: String,
    /// The kind, if the description names it.
    pub kind: Option<RelocKind>,
    pub target: String,
    pub addend: i64,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SymbolClass {
    Func,
    Object,
    Section,
    /// `$x` or `$d` (or `$x.<n>`): where code or data starts.
    Mapping,
    Other,
}

#[derive(Clone, Debug)]
pub struct ImageSymbol {
    pub name: String,
    pub value: u64,
    pub size: u64,
    /// An index into the image's sections; `None` if undefined (or
    /// absolute).
    pub section: Option<usize>,
    pub global: bool,
    pub weak: bool,
    pub class: SymbolClass,
}

impl Image {
    /// Reads an image from a file's bytes.
    /// Reads an image from a file's bytes; machine `m` names its
    /// relocations.
    pub fn read(bytes: &[u8], m: &Machine) -> Result<Image, String> {
        if elf::is_elf(bytes) {
            return Ok(Image::from_elf(&elf::read(bytes)?, m));
        }
        if macho::is_macho(bytes) {
            return Ok(Image::from_macho(&macho::read(bytes)?, m));
        }
        Err("not a file format draconian-objdump reads (ELF, Mach-O)".into())
    }

    pub fn from_macho(f: &macho::MachFile, m: &Machine) -> Image {
        let sections: Vec<ImageSection> = f
            .sections
            .iter()
            .map(|s| ImageSection {
                name: format!("{},{}", s.segment, s.name),
                addr: s.addr,
                size: s.size,
                data: s.data.clone(),
                code: s.is_code(),
                kind: match (s.is_code(), s.is_zerofill()) {
                    (true, _) => "TEXT",
                    (false, true) => "BSS",
                    _ => "DATA",
                },
                relocs: Vec::new(),
            })
            .collect();
        let mut img = Image { format: "mach-o arm64".into(), macho: true, sections, symbols: Vec::new() };
        for (k, s) in f.sections.iter().enumerate() {
            img.sections[k].relocs = s
                .relocs
                .iter()
                .map(|r| ImageReloc {
                    offset: r.offset,
                    type_name: m.macho_name(r.rel_type),
                    kind: m.by_macho(r.rel_type, r.length).map(|k| RelocKind(k as u16)),
                    target: if r.external {
                        f.symbols
                            .get(r.symbolnum as usize)
                            .map_or_else(|| format!("<symbol {}>", r.symbolnum), |x| x.name.clone())
                    } else {
                        img.sections
                            .get(r.symbolnum as usize - 1)
                            .map_or_else(|| format!("<section {}>", r.symbolnum), |x| x.name.clone())
                    },
                    addend: r.addend,
                })
                .collect();
        }
        img.symbols = f
            .symbols
            .iter()
            .filter(|s| !s.is_stab())
            .map(|s| {
                let section = if s.is_defined() && s.sect > 0 { Some(s.sect as usize - 1) } else { None };
                ImageSymbol {
                    name: s.name.clone(),
                    value: s.value,
                    size: 0,
                    section,
                    global: s.is_external(),
                    weak: s.desc & macho::N_WEAK_DEF != 0,
                    class: match section {
                        Some(k) if img.sections.get(k).is_some_and(|x| x.code) => SymbolClass::Func,
                        Some(_) => SymbolClass::Object,
                        None => SymbolClass::Other,
                    },
                }
            })
            .collect();
        img
    }

    pub fn from_elf(f: &elf::ElfFile, m: &Machine) -> Image {
        // The image keeps every section but the null one.
        let index = |shndx: u16| -> Option<usize> {
            (shndx != 0 && (shndx as usize) < f.sections.len() && shndx < 0xff00).then(|| shndx as usize - 1)
        };
        let sections = f
            .sections
            .iter()
            .skip(1)
            .map(|s| {
                let alloc = s.flags & elf::SHF_ALLOC != 0;
                let code = s.flags & elf::SHF_EXECINSTR != 0;
                ImageSection {
                    name: s.name.clone(),
                    addr: s.addr,
                    size: s.size,
                    data: s.data.clone(),
                    code,
                    kind: match (alloc, code, s.sh_type) {
                        (true, true, _) => "TEXT",
                        (true, false, elf::SHT_NOBITS) => "BSS",
                        (true, false, _) => "DATA",
                        _ => "",
                    },
                    relocs: s
                        .relocs
                        .iter()
                        .map(|r| ImageReloc {
                            offset: r.offset - if f.file_type == elf::ET_REL { 0 } else { s.addr },
                            type_name: m.elf_name(r.rel_type),
                            kind: m.by_elf(r.rel_type).map(|k| RelocKind(k as u16)),
                            target: f.reloc_target(r),
                            addend: r.addend,
                        })
                        .collect(),
                }
            })
            .collect();
        let symbols = f
            .symbols
            .iter()
            .skip(1)
            .map(|s| ImageSymbol {
                name: s.name.clone(),
                value: s.value,
                size: s.size,
                section: index(s.shndx),
                global: s.bind == elf::STB_GLOBAL,
                weak: s.bind == elf::STB_WEAK,
                class: match s.sym_type {
                    elf::STT_FUNC => SymbolClass::Func,
                    elf::STT_OBJECT => SymbolClass::Object,
                    elf::STT_SECTION => SymbolClass::Section,
                    _ if is_mapping(&s.name) => SymbolClass::Mapping,
                    _ => SymbolClass::Other,
                },
            })
            .collect();
        Image { format: m.elf_format.clone(), macho: false, sections, symbols }
    }

    /// A symbol's name as printed: a section symbol is its section's name.
    fn symbol_name(&self, s: &ImageSymbol) -> String {
        match (s.class, s.section) {
            (SymbolClass::Section, Some(k)) => self.sections[k].name.clone(),
            _ => s.name.clone(),
        }
    }
}

fn is_mapping(name: &str) -> bool {
    matches!(name, "$x" | "$d") || name.starts_with("$x.") || name.starts_with("$d.")
}

/// `-h`: the section headers.
pub fn headers(img: &Image) -> String {
    let w = img.sections.iter().map(|s| s.name.len()).max().unwrap_or(4).max(4);
    let mut out = format!("Sections:\nIdx {:w$} Size     VMA              Type\n", "Name");
    let _ = writeln!(out, "  0 {:w$} {:08x} {:016x} ", "", 0, 0);
    for (k, s) in img.sections.iter().enumerate() {
        let _ = writeln!(out, "{:>3} {:w$} {:08x} {:016x} {}", k + 1, s.name, s.size, s.addr, s.kind);
    }
    out
}

/// `-t`: the symbol table.
pub fn symbols(img: &Image) -> String {
    let mut out = String::from("SYMBOL TABLE:\n");
    for s in &img.symbols {
        let bind = if s.section.is_none() {
            ' '
        } else if s.weak {
            'w'
        } else if s.global {
            'g'
        } else {
            'l'
        };
        // objdump's flag columns: the sixth says debugging (a section
        // symbol), the seventh function or object.
        let (debug, class) = match s.class {
            SymbolClass::Func => (' ', 'F'),
            SymbolClass::Object => (' ', 'O'),
            SymbolClass::Section => ('d', ' '),
            _ => (' ', ' '),
        };
        let section = s.section.map_or("*UND*".to_string(), |k| img.sections[k].name.clone());
        let _ = writeln!(
            out,
            "{:016x} {bind}    {debug}{class} {section}\t{:016x} {}",
            s.value,
            s.size,
            img.symbol_name(s)
        );
    }
    out
}

/// `-r`: each section's relocations.
pub fn relocations(img: &Image) -> String {
    let mut out = String::new();
    for s in &img.sections {
        if s.relocs.is_empty() {
            continue;
        }
        let _ = writeln!(out, "RELOCATION RECORDS FOR [{}]:", s.name);
        let _ = writeln!(out, "OFFSET           TYPE                     VALUE");
        for r in &s.relocs {
            let _ = writeln!(out, "{:016x} {:<24} {}", r.offset, r.type_name, target_text(r));
        }
        out.push('\n');
    }
    out
}

fn target_text(r: &ImageReloc) -> String {
    match r.addend {
        0 => r.target.clone(),
        a if a > 0 => format!("{}+{a:#x}", r.target),
        a => format!("{}-{:#x}", r.target, a.unsigned_abs()),
    }
}

/// `-s`: each section's contents in hex, sixteen bytes to a line.
pub fn contents(img: &Image) -> String {
    let mut out = String::new();
    for s in &img.sections {
        if s.data.is_empty() {
            continue;
        }
        let _ = writeln!(out, "Contents of section {}:", s.name);
        for (k, chunk) in s.data.chunks(16).enumerate() {
            let mut hex = String::new();
            for (j, b) in chunk.iter().enumerate() {
                if j > 0 && j % 4 == 0 {
                    hex.push(' ');
                }
                let _ = write!(hex, "{b:02x}");
            }
            let text: String = chunk.iter().map(|&b| if (0x20..0x7f).contains(&b) { b as char } else { '.' }).collect();
            let _ = writeln!(out, " {:04x} {hex:<35}  {text}", s.addr + 16 * k as u64);
        }
    }
    out
}

/// How assembly writes a relocation's symbol in an instruction, as the
/// description spells it.
fn reloc_operand(m: &Machine, r: &ImageReloc, macho: bool) -> String {
    let t = target_text(r);
    let syntax = if macho { Syntax::MachO } else { Syntax::Elf };
    match r.kind {
        Some(k) => m.relocs[k.0 as usize].spell(syntax, &t),
        None => t,
    }
}

/// The instruction `word` is, when a relocation of `kind` fills it in.
fn decode_reloc(t: &Target, word: u32, kind: RelocKind) -> Option<(usize, Env)> {
    (0..t.instrs.len())
        .filter(|&i| t.instrs[i].reloc == Some(kind) && word & t.instrs[i].enc.mask == t.instrs[i].enc.value)
        .find_map(|i| t.instrs[i].decode(word).map(|env| (i, env)))
}

/// `-d`: the code sections disassembled.
pub fn disassemble(t: &Target, img: &Image, show_relocs: bool) -> String {
    let mut out = String::new();
    // Symbols to name addresses by: functions, objects and others, not
    // section or mapping symbols.
    let mut named: Vec<(u64, usize, String)> = img
        .symbols
        .iter()
        .filter(|s| matches!(s.class, SymbolClass::Func | SymbolClass::Object | SymbolClass::Other))
        .filter_map(|s| s.section.map(|k| (img.sections[k].addr + s.value_in(img, k), k, s.name.clone())))
        // Not Mach-O's assembler temporaries (`ltmp0`, at each section's
        // start).
        .filter(|(_, _, n)| !(n.is_empty() || img.macho && n.starts_with("ltmp")))
        .collect();
    named.sort();
    named.dedup();
    for (k, s) in img.sections.iter().enumerate() {
        if !s.code || s.data.is_empty() {
            continue;
        }
        let _ = writeln!(out, "\nDisassembly of section {}:", s.name);
        let here: Vec<&(u64, usize, String)> = named.iter().filter(|x| x.1 == k).collect();
        // Where code and data start, by the mapping symbols.
        let mut mapping: Vec<(u64, bool)> = img
            .symbols
            .iter()
            .filter(|m| m.class == SymbolClass::Mapping && m.section == Some(k))
            .map(|m| (m.value_in(img, k), m.name.starts_with("$d")))
            .collect();
        mapping.sort();
        let is_data = |off: u64| mapping.iter().rev().find(|m| m.0 <= off).is_some_and(|m| m.1);
        // A target address, with the symbol it is in.
        let label = |addr: u64| -> String {
            let sym = here.iter().rev().find(|x| x.0 <= addr).or_else(|| here.first().filter(|x| x.0 == addr));
            match sym {
                Some((a, _, n)) if *a == addr => format!("{addr:#x} <{n}>"),
                Some((a, _, n)) => format!("{addr:#x} <{n}+{:#x}>", addr - a),
                None => format!("{addr:#x}"),
            }
        };
        if here.first().is_none_or(|x| x.0 > s.addr) {
            let _ = writeln!(out, "\n{:016x} <{}>:", s.addr, s.name);
        }
        let mut off = 0u64;
        while off < s.data.len() as u64 {
            let addr = s.addr + off;
            for (a, _, n) in &here {
                if *a == addr {
                    let _ = writeln!(out, "\n{addr:016x} <{n}>:");
                }
            }
            let rest = &s.data[off as usize..];
            if rest.len() < 4 {
                let bytes: Vec<String> = rest.iter().map(|b| format!("{b:02x}")).collect();
                let _ = writeln!(out, "{addr:>8x}: {:<8}     \t.byte {}", bytes.join(""), bytes.join(", "));
                break;
            }
            let word = u32::from_le_bytes(rest[..4].try_into().unwrap());
            let relocs: Vec<&ImageReloc> = s.relocs.iter().filter(|r| r.offset == off).collect();
            let text = if is_data(off) {
                format!(".word {word:#010x}")
            } else {
                // Against a section: the symbol there, if one is.
                let named_reloc = relocs.first().map(|r| {
                    let mut r = (*r).clone();
                    if let Some(sk) = img.sections.iter().position(|x| x.name == r.target)
                        && let Some(n) =
                            named.iter().find(|x| x.1 == sk && x.0 == img.sections[sk].addr + r.addend as u64)
                    {
                        r.target = n.2.clone();
                        r.addend = 0;
                    }
                    r
                });
                instruction(t, word, addr, named_reloc.as_ref(), img.macho, &label)
            };
            let _ = writeln!(out, "{addr:>8x}: {word:08x}     \t{text}");
            if show_relocs {
                for r in relocs {
                    let _ = writeln!(out, "\t\t{:016x}:  {}\t{}", addr, r.type_name, target_text(r));
                }
            }
            off += 4;
        }
    }
    out
}

impl ImageSymbol {
    /// The symbol's offset in section `k`: its value, which in files that
    /// are linked is an address.
    fn value_in(&self, img: &Image, k: usize) -> u64 {
        let s = &img.sections[k];
        if self.value >= s.addr && s.addr != 0 { self.value - s.addr } else { self.value }
    }
}

/// One instruction, as assembly; `reloc` is the relocation that fills it
/// in, if there is one.
pub fn instruction(
    t: &Target,
    word: u32,
    pc: u64,
    reloc: Option<&ImageReloc>,
    macho: bool,
    label: &dyn Fn(u64) -> String,
) -> String {
    let decoded = match reloc.and_then(|r| r.kind) {
        Some(k) => decode_reloc(t, word, k).or_else(|| mir::decode(t, word)),
        None => mir::decode(t, word),
    };
    let Some((i, env)) = decoded else { return format!(".word {word:#010x}") };
    let ins = &t.instrs[i];
    mir::fill_template(t, None, i, |k| {
        let o = &ins.operands[k];
        let v = env[&o.name];
        match o.kind {
            Kind::Reg(c) => Operand::Reg(Reg::P(t.machine.phys(c, v))),
            Kind::Label => Operand::Text(label(pc.wrapping_add(v as u64))),
            Kind::Sym => match reloc {
                Some(r) => Operand::Text(reloc_operand(&t.machine, r, macho)),
                None => match ins.reloc.and_then(|kind| t.machine.relocs[kind.0 as usize].reaches(pc, v)) {
                    Some(a) => Operand::Text(label(a)),
                    None => Operand::Imm(v),
                },
            },
            Kind::Imm | Kind::Cond => Operand::Imm(v),
        }
    })
}

/// Checks that `img`'s code disassembles as `asm` (the assembly it was
/// made from) says: the same number of instructions, each with the same
/// mnemonic (or one `aliases` pairs with it), and where a relocation fills
/// an instruction in, the same instruction, symbol and all. Returns how
/// many instructions there are.
pub fn reads_back(t: &Target, img: &Image, asm: &str, aliases: &[(&str, &str)]) -> Result<usize, String> {
    let dump = disassemble(t, img, true);
    // Each instruction: its text, and whether a relocation fills it in.
    let mut lines: Vec<(String, bool)> = Vec::new();
    for l in dump.lines() {
        if l.starts_with("\t\t") {
            if let Some(last) = lines.last_mut() {
                last.1 = true;
            }
        } else if let Some((_, rest)) = l.split_once(": ")
            && let Some((_, text)) = rest.split_once('\t')
        {
            lines.push((text.to_string(), false));
        }
    }
    let written: Vec<&str> = asm.lines().filter_map(|l| l.strip_prefix('\t')).filter(|l| !l.starts_with('.')).collect();
    if written.len() != lines.len() {
        return Err(format!("{} instructions read back, {} written", lines.len(), written.len()));
    }
    let mnemonic = |s: &str| s.split_whitespace().next().unwrap_or("").to_string();
    for (k, ((read, relocated), wrote)) in lines.iter().zip(&written).enumerate() {
        let (a, b) = (mnemonic(read), mnemonic(wrote));
        let alias = aliases.contains(&(a.as_str(), b.as_str())) || aliases.contains(&(b.as_str(), a.as_str()));
        if (a != b && !alias) || (*relocated && read != wrote) {
            return Err(format!("instruction {k} reads back as `{read}`, was written `{wrote}`"));
        }
    }
    Ok(lines.len())
}
