//! Object files in the abstract: sections of bytes, symbols, and
//! relocations, built from compiled functions and globals. `elf.rs` writes
//! one as an ELF relocatable file, `macho.rs` as a Mach-O object.
//!
//! Globals are first described as [`GlobalData`], a list of [`Item`]s,
//! which both the assembly printer (`asm.rs`) and [`build`] read, so that
//! the two outputs say the same thing.
//!
//! Building does what an assembler for the convention's format does with
//! the same program:
//!
//! - a call to a function defined in the same section is resolved in place
//!   (the distance is known), with no relocation. In ELF only local
//!   functions: a global one could be replaced by another library's
//!   definition, so is left to the linker. In Mach-O, whose symbols are
//!   bound to the library that defines them, global ones too;
//! - in ELF, other references to a local symbol are made against its
//!   section, with the symbol's offset in the addend, so that the symbol
//!   need not be kept for the linker; references through the GOT stay
//!   against the symbol. Mach-O keeps every reference against its symbol;
//! - references to global and undefined symbols are made against them;
//! - the bytes a relocation will fill are zero, the addend being in the
//!   relocation. (The Mach-O writer moves a pointer's addend into the
//!   pointer's bytes, where that format keeps it.)

use std::collections::HashMap;

use crate::abi::{Abi, Syntax};
use crate::machine::RelocUse;
use crate::mir::{self, MFunc};
use crate::target::{Kind, Target};

/// How a relocation fills in its place: an index into the description's
/// relocations (`Machine::relocs`), which say what each is called in each
/// object format and how assembly writes it.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct RelocKind(pub u16);

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum SectionKind {
    /// Code.
    Text,
    /// Writable data.
    Data,
    /// Writable data that starts as zeros: only its size is stored.
    Bss,
    /// Constants.
    ReadOnly,
    /// Constants holding addresses, which the loader writes once.
    RelRo,
}

#[derive(Clone, Debug)]
pub struct Section {
    pub kind: SectionKind,
    pub align: u64,
    /// The contents; empty for `Bss`, whose size is `bss_size`.
    pub data: Vec<u8>,
    pub bss_size: u64,
    pub relocs: Vec<Reloc>,
}

impl Section {
    pub fn size(&self) -> u64 {
        if self.kind == SectionKind::Bss { self.bss_size } else { self.data.len() as u64 }
    }
}

/// What a relocation refers to.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RelocTarget {
    Symbol(usize),
    /// The start of a section (the addend says where in it).
    Section(usize),
}

#[derive(Clone, Debug)]
pub struct Reloc {
    pub offset: u64,
    pub kind: RelocKind,
    pub target: RelocTarget,
    pub addend: i64,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SymbolKind {
    Func,
    Object,
    /// Undefined: whatever another file defines.
    NoType,
}

#[derive(Clone, Debug)]
pub struct Symbol {
    pub name: String,
    /// The section defining it; `None` if it is undefined.
    pub section: Option<usize>,
    pub value: u64,
    pub size: u64,
    pub global: bool,
    pub kind: SymbolKind,
}

#[derive(Clone, Debug, Default)]
pub struct Object {
    pub sections: Vec<Section>,
    pub symbols: Vec<Symbol>,
}

/// A piece of a global's initial value.
#[derive(Clone, Debug, PartialEq)]
pub enum Item {
    /// An integer of `size` bytes (a float's bits, if `hex`, which is how
    /// assembly prints it).
    Int {
        size: u8,
        value: u64,
        hex: bool,
    },
    /// Bytes, as a string.
    Bytes(Vec<u8>),
    Zero(u64),
    /// The 64-bit address of `symbol` (as the platform names it), plus
    /// `offset`.
    Addr {
        symbol: String,
        offset: i64,
    },
}

impl Item {
    pub fn size(&self) -> u64 {
        match self {
            Item::Int { size, .. } => *size as u64,
            Item::Bytes(b) => b.len() as u64,
            Item::Zero(n) => *n,
            Item::Addr { .. } => 8,
        }
    }
}

/// A global variable: where it goes and what it starts as.
#[derive(Clone, Debug)]
pub struct GlobalData {
    /// As the platform names it.
    pub symbol: String,
    pub global: bool,
    pub section: SectionKind,
    pub align: u64,
    pub items: Vec<Item>,
}

impl GlobalData {
    pub fn size(&self) -> u64 {
        self.items.iter().map(Item::size).sum()
    }
}

/// A reference to a symbol, by name, before the symbols are all known.
pub struct Pending {
    pub section: usize,
    pub offset: u64,
    pub kind: RelocKind,
    /// As the platform names it.
    pub symbol: String,
    pub addend: i64,
    /// The instruction holding it (an index into the description), for
    /// those resolved in place.
    pub instr: Option<usize>,
}

/// The object for compiled functions (laid out and allocated) and globals.
pub fn build(t: &Target, abi: &Abi, funcs: &[MFunc], globals: &[GlobalData]) -> Result<Object, String> {
    let mut obj = Object::default();
    let mut by_kind: HashMap<SectionKind, usize> = HashMap::new();
    let mut section = |obj: &mut Object, kind: SectionKind| -> usize {
        *by_kind.entry(kind).or_insert_with(|| {
            obj.sections.push(Section { kind, align: 1, data: Vec::new(), bss_size: 0, relocs: Vec::new() });
            obj.sections.len() - 1
        })
    };
    // Pads section `s` to `align`, and returns where the next thing goes.
    let place = |obj: &mut Object, s: usize, align: u64| -> u64 {
        let sec = &mut obj.sections[s];
        sec.align = sec.align.max(align);
        let at = sec.size().next_multiple_of(align);
        if sec.kind == SectionKind::Bss {
            sec.bss_size = at;
        } else {
            sec.data.resize(at as usize, 0);
        }
        at
    };
    let mut pending = Vec::new();

    for f in funcs {
        let s = section(&mut obj, SectionKind::Text);
        let at = place(&mut obj, s, 4);
        let (words, fixups) = mir::encode_function(t, f)?;
        for w in &words {
            obj.sections[s].data.extend_from_slice(&w.to_le_bytes());
        }
        obj.symbols.push(Symbol {
            name: abi.symbol(&f.name),
            section: Some(s),
            value: at,
            size: 4 * words.len() as u64,
            global: f.global,
            kind: SymbolKind::Func,
        });
        for fx in fixups {
            let i = t.by_name[&fx.instr];
            let kind = t.instrs[i].reloc.ok_or_else(|| format!("{}: {} has no \"reloc\"", f.name, fx.instr))?;
            pending.push(Pending {
                section: s,
                offset: at + fx.offset as u64,
                kind,
                symbol: abi.symbol(&fx.symbol),
                addend: 0,
                instr: Some(i),
            });
        }
    }

    for g in globals {
        let s = section(&mut obj, g.section);
        let at = place(&mut obj, s, g.align.max(1));
        let bss = g.section == SectionKind::Bss;
        for item in &g.items {
            let sec = &mut obj.sections[s];
            match item {
                Item::Zero(n) if bss => sec.bss_size += n,
                _ if bss => return Err(format!("{}: a value other than zero in .bss", g.symbol)),
                Item::Int { size, value, .. } => sec.data.extend_from_slice(&value.to_le_bytes()[..*size as usize]),
                Item::Bytes(b) => sec.data.extend_from_slice(b),
                Item::Zero(n) => sec.data.resize(sec.data.len() + *n as usize, 0),
                Item::Addr { symbol, offset } => {
                    let kind =
                        t.machine.data_reloc(8).ok_or("the description has no relocation for pointers in data")?;
                    pending.push(Pending {
                        section: s,
                        offset: sec.data.len() as u64,
                        kind: RelocKind(kind as u16),
                        symbol: symbol.clone(),
                        addend: *offset,
                        instr: None,
                    });
                    sec.data.extend_from_slice(&[0; 8]);
                }
            }
        }
        obj.symbols.push(Symbol {
            name: g.symbol.clone(),
            section: Some(s),
            value: at,
            size: g.size(),
            global: g.global,
            kind: SymbolKind::Object,
        });
    }

    resolve(t, &mut obj, pending, abi.syntax == Syntax::MachO)?;
    Ok(obj)
}

/// Turns references by name into relocations (or resolves them in place),
/// by the rules of the format (see the top of this file): Mach-O's if
/// `macho`, else ELF's. Symbols not defined are added as undefined.
pub fn resolve(t: &Target, obj: &mut Object, pending: Vec<Pending>, macho: bool) -> Result<(), String> {
    let mut by_name: HashMap<String, usize> =
        obj.symbols.iter().enumerate().map(|(k, s)| (s.name.clone(), k)).collect();
    for p in pending {
        let sym = match by_name.get(&p.symbol) {
            Some(&k) => k,
            None => {
                obj.symbols.push(Symbol {
                    name: p.symbol.clone(),
                    section: None,
                    value: 0,
                    size: 0,
                    global: true,
                    kind: SymbolKind::NoType,
                });
                by_name.insert(p.symbol.clone(), obj.symbols.len() - 1);
                obj.symbols.len() - 1
            }
        };
        let def = obj.symbols[sym].clone();
        // A call within the section: the distance is known.
        let usage = t.machine.relocs[p.kind.0 as usize].usage;
        if usage == RelocUse::Call
            && (macho || !def.global)
            && def.section == Some(p.section)
            && let Some(i) = p.instr
        {
            let ins = &t.instrs[i];
            let at = p.offset as usize;
            let data = &mut obj.sections[p.section].data;
            let word = u32::from_le_bytes(data[at..at + 4].try_into().unwrap());
            let mut env = ins.decode(word).ok_or_else(|| format!("cannot decode the {} to {}", ins.name, def.name))?;
            let op = ins.operands.iter().find(|o| o.kind == Kind::Sym).ok_or("a call without a symbol operand")?;
            env.insert(op.name.clone(), def.value as i64 + p.addend - p.offset as i64);
            let word = ins
                .enc
                .encode(&env)
                .ok_or_else(|| format!("{}: the call to {} is out of range", ins.name, def.name))?;
            data[at..at + 4].copy_from_slice(&word.to_le_bytes());
            continue;
        }
        let (target, addend) = match def.section {
            Some(s) if !macho && !def.global && usage != RelocUse::Got => {
                (RelocTarget::Section(s), p.addend + def.value as i64)
            }
            _ => (RelocTarget::Symbol(sym), p.addend),
        };
        obj.sections[p.section].relocs.push(Reloc { offset: p.offset, kind: p.kind, target, addend });
    }
    Ok(())
}

/// Where two canonical forms (`ElfFile::canonical`, `MachFile::canonical`)
/// differ: up to `max` lines of each that are not in the other.
pub fn differences(ours: &str, theirs: &str, max: usize) -> Vec<String> {
    let a: std::collections::HashSet<&str> = ours.lines().collect();
    let b: std::collections::HashSet<&str> = theirs.lines().collect();
    let mut out: Vec<String> =
        ours.lines().filter(|l| !b.contains(l)).take(max).map(|l| format!("ours:   {l}")).collect();
    out.extend(theirs.lines().filter(|l| !a.contains(l)).take(max).map(|l| format!("theirs: {l}")));
    out
}
