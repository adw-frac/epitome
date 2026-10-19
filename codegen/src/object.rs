//! Object files in the abstract: sections of bytes, symbols, and
//! relocations, built from compiled functions and globals. `elf.rs` writes
//! one as an ELF relocatable file.
//!
//! Globals are first described as [`GlobalData`], a list of [`Item`]s,
//! which both the assembly printer (`asm.rs`) and [`build`] read, so that
//! the two outputs say the same thing.
//!
//! Building does what an assembler does with the same program:
//!
//! - a call to a local function defined in the same section is resolved
//!   in place (the distance is known), with no relocation;
//! - other references to a local symbol are made against its section, with
//!   the symbol's offset in the addend, so that the symbol need not be kept
//!   for the linker; references through the GOT stay against the symbol;
//! - references to global and undefined symbols are made against them;
//! - the bytes a relocation will fill are zero, the addend being in the
//!   relocation (ELF's RELA form).

use std::collections::HashMap;

use crate::abi::Abi;
use crate::mir::{self, MFunc};
use crate::target::{Kind, Target};

/// How a relocation fills in its place: named in the description's
/// `"reloc"` attribute, and mapped to each format's own numbers.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum RelocKind {
    /// `bl`: the distance to the symbol, in words, 26 bits.
    Call26,
    /// `adrp`: the distance to the symbol's 4KB page, in pages.
    Adrp,
    /// `add`: the symbol's offset in its page, 12 bits.
    AddLo12,
    /// `adrp` of the page of the symbol's GOT entry.
    AdrpGot,
    /// `ldr` of the GOT entry, its offset in its page.
    Ld64GotLo12,
    /// Data: the symbol's 64-bit address.
    Abs64,
}

impl RelocKind {
    pub const ALL: [RelocKind; 6] = [
        RelocKind::Call26,
        RelocKind::Adrp,
        RelocKind::AddLo12,
        RelocKind::AdrpGot,
        RelocKind::Ld64GotLo12,
        RelocKind::Abs64,
    ];

    /// The name the description uses.
    pub fn name(self) -> &'static str {
        match self {
            RelocKind::Call26 => "call26",
            RelocKind::Adrp => "adrp",
            RelocKind::AddLo12 => "add_lo12",
            RelocKind::AdrpGot => "adrp_got",
            RelocKind::Ld64GotLo12 => "ld64_got_lo12",
            RelocKind::Abs64 => "abs64",
        }
    }

    pub fn parse(s: &str) -> Option<RelocKind> {
        RelocKind::ALL.into_iter().find(|k| k.name() == s)
    }

    /// Does it address the symbol's GOT entry rather than the symbol?
    pub fn via_got(self) -> bool {
        matches!(self, RelocKind::AdrpGot | RelocKind::Ld64GotLo12)
    }
}

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

struct Pending {
    section: usize,
    offset: u64,
    kind: RelocKind,
    symbol: String,
    addend: i64,
    /// The instruction holding it, for those resolved in place.
    instr: Option<usize>,
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
                    pending.push(Pending {
                        section: s,
                        offset: sec.data.len() as u64,
                        kind: RelocKind::Abs64,
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
        // A call to a local function in the same section: the distance is
        // known. (A global one could be replaced by another library's, so
        // is left to the linker.)
        if p.kind == RelocKind::Call26
            && !def.global
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
            Some(s) if !def.global && !p.kind.via_got() => (RelocTarget::Section(s), p.addend + def.value as i64),
            _ => (RelocTarget::Symbol(sym), p.addend),
        };
        obj.sections[p.section].relocs.push(Reloc { offset: p.offset, kind: p.kind, target, addend });
    }
    Ok(obj)
}
