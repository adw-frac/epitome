//! Unwind tables: DWARF's call frame information, which says how to undo
//! each function's frame from any of its instructions that calls (where
//! the CFA, the stack pointer on entry, is, and where registers were
//! saved), for C++ exceptions, debuggers and profilers to walk the stack.
//!
//! Frame lowering puts `Opcode::Cfi` pseudo-instructions in each prologue,
//! after what they describe; assembly writes them as `.cfi_*` directives.
//! An object file has them as `.eh_frame` (ELF) or `__TEXT,__eh_frame`
//! (Mach-O): one CIE, with what all functions share, then one FDE a
//! function. The forms are those the platforms' assemblers write (observed
//! with clang and rustc): augmentation `zR`, code alignment 1, the data
//! alignment the description gives for the object format (`cfi-data-align`:
//! AArch64's is -4 in ELF, -8 in Mach-O), the link register as
//! the return address column, and the CFA starting at the stack pointer.
//! A function's address is PC-relative: 4 bytes under ELF, 8 under Mach-O,
//! where it is a pair of relocations, the function less a symbol at the
//! table's start.

use crate::abi::Syntax;
use crate::machine::{Machine, RelocUse};
use crate::object::{Object, Reloc, RelocKind, RelocTarget, Section, SectionKind, Symbol, SymbolKind};

/// One rule of a frame, for the instructions after it.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cfi {
    /// The CFA is the stack pointer plus this.
    DefCfaOffset(i64),
    /// The CFA is this register plus this.
    DefCfa(u8, i64),
    /// This register is saved at the CFA plus this.
    Offset(u8, i64),
}

/// A function's unwinding: where it is, and its rules, each at an offset
/// from its start.
#[derive(Clone, Debug)]
pub struct Frame {
    pub section: usize,
    pub start: u64,
    pub len: u64,
    /// The function's symbol (Mach-O's pair names it).
    pub symbol: usize,
    pub rules: Vec<(u64, Cfi)>,
}

/// What the tables' common part says.
pub struct Params {
    pub syntax: Syntax,
    pub data_align: i64,
    /// The return address column: the link register.
    pub ra: u8,
}

fn uleb(out: &mut Vec<u8>, mut v: u64) {
    loop {
        let b = (v & 0x7f) as u8;
        v >>= 7;
        if v == 0 {
            out.push(b);
            return;
        }
        out.push(b | 0x80);
    }
}

fn sleb(out: &mut Vec<u8>, mut v: i64) {
    loop {
        let b = (v & 0x7f) as u8;
        v >>= 7;
        let done = (v == 0 && b & 0x40 == 0) || (v == -1 && b & 0x40 != 0);
        out.push(if done { b } else { b | 0x80 });
        if done {
            return;
        }
    }
}

/// Pads an entry (its length word first) to a multiple of 4 bytes with
/// DW_CFA_nop, and fills in its length.
fn finish(entry: &mut Vec<u8>) {
    while !entry.len().is_multiple_of(4) {
        entry.push(0);
    }
    let len = (entry.len() - 4) as u32;
    entry[..4].copy_from_slice(&len.to_le_bytes());
}

/// The rules as call frame instructions, each after an advance to it.
fn instructions(m: &Machine, p: &Params, rules: &[(u64, Cfi)]) -> Result<Vec<u8>, String> {
    let mut out = Vec::new();
    let mut at = 0u64;
    let dwarf = |r: u8| m.dwarf_number(r).ok_or_else(|| format!("register {} has no DWARF number", m.lookup_name(r)));
    for &(off, rule) in rules {
        let d = off - at;
        if d > 0 {
            if d < 64 {
                out.push(0x40 | d as u8);
            } else if d < 256 {
                out.extend([0x02, d as u8]);
            } else if d < 65536 {
                out.push(0x03);
                out.extend((d as u16).to_le_bytes());
            } else {
                out.push(0x04);
                out.extend((d as u32).to_le_bytes());
            }
            at = off;
        }
        match rule {
            Cfi::DefCfaOffset(o) => {
                out.push(0x0e);
                uleb(&mut out, o as u64);
            }
            Cfi::DefCfa(r, o) => {
                out.push(0x0c);
                uleb(&mut out, dwarf(r)? as u64);
                uleb(&mut out, o as u64);
            }
            Cfi::Offset(r, o) => {
                let n = dwarf(r)?;
                let f = o / p.data_align;
                if n < 64 && f >= 0 {
                    out.push(0x80 | n as u8);
                    uleb(&mut out, f as u64);
                } else if f >= 0 {
                    out.push(0x05);
                    uleb(&mut out, n as u64);
                    uleb(&mut out, f as u64);
                } else {
                    out.push(0x11);
                    uleb(&mut out, n as u64);
                    sleb(&mut out, f);
                }
            }
        }
    }
    Ok(out)
}

/// A local symbol at the start of section `s` (Mach-O's relocation pairs
/// subtract and add them).
fn section_start(obj: &mut Object, s: usize, name: &str) -> usize {
    if let Some(k) = obj.symbols.iter().position(|x| x.name == name) {
        return k;
    }
    obj.symbols.push(Symbol {
        name: name.into(),
        section: Some(s),
        value: 0,
        size: 0,
        global: false,
        kind: SymbolKind::NoType,
    });
    obj.symbols.len() - 1
}

/// Adds the unwind table section for `frames` to `obj`.
pub fn add_eh_frame(obj: &mut Object, m: &Machine, p: &Params, frames: &[Frame]) -> Result<(), String> {
    if frames.is_empty() {
        return Ok(());
    }
    let macho = p.syntax == Syntax::MachO;
    let mut data = Vec::new();
    let s = obj.sections.len();
    let mut relocs = Vec::new();
    let reloc = |u: RelocUse| {
        m.reloc_used(u).map(|k| RelocKind(k as u16)).ok_or_else(|| format!("no relocation has use {u:?}"))
    };
    // Mach-O's pairs subtract a symbol at the table's start.
    let start_sym = if macho { Some(section_start(obj, s, "ltmp_eh_frame")) } else { None };
    // The CIE: what all the functions share. Augmentation zR: the FDEs'
    // addresses are PC-relative, 8 bytes (Mach-O) or 4, signed (ELF).
    let mut cie = vec![0u8; 4];
    cie.extend(0u32.to_le_bytes());
    cie.push(1);
    cie.extend(b"zR\0");
    uleb(&mut cie, 1);
    sleb(&mut cie, p.data_align);
    cie.push(m.dwarf_number(p.ra).ok_or("the link register has no DWARF number")? as u8);
    uleb(&mut cie, 1);
    cie.push(if macho { 0x10 } else { 0x1b });
    cie.push(0x0c);
    uleb(&mut cie, m.dwarf_number(m.sp).ok_or("the stack pointer has no DWARF number")? as u64);
    uleb(&mut cie, 0);
    finish(&mut cie);
    data.extend(&cie);
    let mut last = 0;
    for f in frames {
        let at = data.len() as u64;
        last = at as usize;
        let mut fde = vec![0u8; 4];
        fde.extend((at as u32 + 4).to_le_bytes());
        let field = at + 8;
        if let Some(st) = start_sym {
            fde.extend((-(field as i64)).to_le_bytes());
            fde.extend(f.len.to_le_bytes());
            relocs.push(Reloc {
                offset: field,
                kind: reloc(RelocUse::EhSub)?,
                target: RelocTarget::Symbol(st),
                addend: 0,
            });
            relocs.push(Reloc {
                offset: field,
                kind: reloc(RelocUse::EhUnsigned)?,
                target: RelocTarget::Symbol(f.symbol),
                addend: 0,
            });
        } else {
            fde.extend(0u32.to_le_bytes());
            fde.extend((f.len as u32).to_le_bytes());
            relocs.push(Reloc {
                offset: field,
                kind: reloc(RelocUse::EhPcRel)?,
                target: RelocTarget::Section(f.section),
                addend: f.start as i64,
            });
        }
        uleb(&mut fde, 0);
        fde.extend(instructions(m, p, &f.rules)?);
        finish(&mut fde);
        data.extend(fde);
    }
    // The last entry is padded out to the section's alignment, 8.
    while !data.len().is_multiple_of(8) {
        data.push(0);
    }
    let len = (data.len() - last - 4) as u32;
    data[last..last + 4].copy_from_slice(&len.to_le_bytes());
    obj.sections.push(Section { kind: SectionKind::EhFrame, align: 8, data, bss_size: 0, relocs });
    Ok(())
}
