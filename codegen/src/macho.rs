//! Reading 64-bit Mach-O files (objects and linked images, and the arm64
//! slice of universal files), for `draconian-objdump`.
//!
//! From Apple's published `<mach-o/loader.h>`, `<mach-o/nlist.h>`,
//! `<mach-o/reloc.h>`, `<mach-o/arm64/reloc.h>` and `<mach-o/fat.h>`: a
//! header, then load commands, of which `LC_SEGMENT_64` lists sections
//! (with their relocations) and `LC_SYMTAB` places the symbols and their
//! names. A relocation names a symbol (`extern`) or a section (by number,
//! from 1); an `ARM64_RELOC_ADDEND` gives the addend of the relocation
//! after it.

use crate::object::RelocKind;

pub const MH_MAGIC_64: u32 = 0xfeed_facf;
pub const FAT_MAGIC: u32 = 0xcafe_babe;
pub const CPU_TYPE_ARM64: u32 = 0x0100_000c;
pub const MH_OBJECT: u32 = 1;

const LC_SEGMENT_64: u32 = 0x19;
const LC_SYMTAB: u32 = 0x2;

pub const S_ZEROFILL: u32 = 1;
pub const S_ATTR_PURE_INSTRUCTIONS: u32 = 0x8000_0000;
pub const S_ATTR_SOME_INSTRUCTIONS: u32 = 0x400;

pub const N_STAB: u8 = 0xe0;
pub const N_EXT: u8 = 0x01;
pub const N_TYPE: u8 = 0x0e;
pub const N_UNDF: u8 = 0x0;
pub const N_SECT: u8 = 0xe;
pub const N_WEAK_DEF: u16 = 0x80;

/// The arm64 relocation types, with their names.
pub const RELOCS: &[(u8, &str)] = &[
    (0, "ARM64_RELOC_UNSIGNED"),
    (1, "ARM64_RELOC_SUBTRACTOR"),
    (2, "ARM64_RELOC_BRANCH26"),
    (3, "ARM64_RELOC_PAGE21"),
    (4, "ARM64_RELOC_PAGEOFF12"),
    (5, "ARM64_RELOC_GOT_LOAD_PAGE21"),
    (6, "ARM64_RELOC_GOT_LOAD_PAGEOFF12"),
    (7, "ARM64_RELOC_POINTER_TO_GOT"),
    (8, "ARM64_RELOC_TLVP_LOAD_PAGE21"),
    (9, "ARM64_RELOC_TLVP_LOAD_PAGEOFF12"),
    (10, "ARM64_RELOC_ADDEND"),
];

pub fn reloc_name(ty: u8) -> String {
    RELOCS.iter().find(|r| r.0 == ty).map_or_else(|| format!("ARM64_RELOC_{ty}"), |r| r.1.to_string())
}

/// The kind a relocation is, if the description names it. (`PAGEOFF12`
/// also fills in loads and stores; those are decoded as themselves.)
pub fn reloc_kind(ty: u8, length: u8) -> Option<RelocKind> {
    match (ty, length) {
        (0, 3) => Some(RelocKind::Abs64),
        (2, _) => Some(RelocKind::Call26),
        (3, _) => Some(RelocKind::Adrp),
        (4, _) => Some(RelocKind::AddLo12),
        (5, _) => Some(RelocKind::AdrpGot),
        (6, _) => Some(RelocKind::Ld64GotLo12),
        _ => None,
    }
}

#[derive(Clone, Debug)]
pub struct MachFile {
    pub file_type: u32,
    pub cpu_type: u32,
    pub sections: Vec<MachSection>,
    pub symbols: Vec<MachSymbol>,
}

#[derive(Clone, Debug)]
pub struct MachSection {
    pub segment: String,
    pub name: String,
    pub addr: u64,
    pub size: u64,
    pub flags: u32,
    /// The contents (none for zero-fill sections).
    pub data: Vec<u8>,
    pub relocs: Vec<MachReloc>,
}

#[derive(Clone, Debug)]
pub struct MachReloc {
    /// From the start of the section.
    pub offset: u64,
    pub rel_type: u8,
    /// log2 of the size of the place: 2 for an instruction, 3 for a pointer.
    pub length: u8,
    pub pcrel: bool,
    /// A symbol index if `external`, else a section number (from 1).
    pub symbolnum: u32,
    pub external: bool,
    /// From an `ARM64_RELOC_ADDEND` before it.
    pub addend: i64,
}

#[derive(Clone, Debug)]
pub struct MachSymbol {
    pub name: String,
    pub n_type: u8,
    /// The section number, from 1; 0 for none.
    pub sect: u8,
    pub desc: u16,
    pub value: u64,
}

impl MachSymbol {
    pub fn is_stab(&self) -> bool {
        self.n_type & N_STAB != 0
    }
    pub fn is_external(&self) -> bool {
        self.n_type & N_EXT != 0
    }
    pub fn is_defined(&self) -> bool {
        self.n_type & N_TYPE == N_SECT
    }
}

impl MachSection {
    pub fn is_code(&self) -> bool {
        self.flags & (S_ATTR_PURE_INSTRUCTIONS | S_ATTR_SOME_INSTRUCTIONS) != 0
    }
    pub fn is_zerofill(&self) -> bool {
        self.flags & 0xff == S_ZEROFILL
    }
}

fn u32_le(b: &[u8], at: usize) -> Result<u32, String> {
    b.get(at..at + 4)
        .map(|x| u32::from_le_bytes(x.try_into().unwrap()))
        .ok_or_else(|| format!("past the end at {at:#x}"))
}

fn u64_le(b: &[u8], at: usize) -> Result<u64, String> {
    b.get(at..at + 8)
        .map(|x| u64::from_le_bytes(x.try_into().unwrap()))
        .ok_or_else(|| format!("past the end at {at:#x}"))
}

fn u32_be(b: &[u8], at: usize) -> Result<u32, String> {
    b.get(at..at + 4)
        .map(|x| u32::from_be_bytes(x.try_into().unwrap()))
        .ok_or_else(|| format!("past the end at {at:#x}"))
}

fn name16(b: &[u8], at: usize) -> Result<String, String> {
    let raw = b.get(at..at + 16).ok_or("a name past the end")?;
    let end = raw.iter().position(|&c| c == 0).unwrap_or(16);
    Ok(String::from_utf8_lossy(&raw[..end]).into_owned())
}

/// Is this a Mach-O file, 64-bit or universal (by its first bytes)?
pub fn is_macho(bytes: &[u8]) -> bool {
    matches!(u32_le(bytes, 0), Ok(MH_MAGIC_64)) || matches!(u32_be(bytes, 0), Ok(FAT_MAGIC))
}

/// Reads a 64-bit Mach-O file, or the arm64 slice of a universal one.
pub fn read(bytes: &[u8]) -> Result<MachFile, String> {
    if u32_be(bytes, 0)? == FAT_MAGIC {
        let n = u32_be(bytes, 4)? as usize;
        for k in 0..n {
            let at = 8 + 20 * k;
            if u32_be(bytes, at)? == CPU_TYPE_ARM64 {
                let offset = u32_be(bytes, at + 8)? as usize;
                let size = u32_be(bytes, at + 12)? as usize;
                let slice = bytes.get(offset..offset + size).ok_or("a slice past the end")?;
                return read(slice);
            }
        }
        return Err("a universal file without an arm64 slice".into());
    }
    if u32_le(bytes, 0)? != MH_MAGIC_64 {
        return Err("not a 64-bit Mach-O file".into());
    }
    let cpu_type = u32_le(bytes, 4)?;
    let file_type = u32_le(bytes, 12)?;
    let ncmds = u32_le(bytes, 16)? as usize;
    let mut at = 32;
    let mut sections = Vec::new();
    let mut symtab = None;
    for _ in 0..ncmds {
        let cmd = u32_le(bytes, at)?;
        let size = u32_le(bytes, at + 4)? as usize;
        if size < 8 {
            return Err("a load command too small".into());
        }
        match cmd {
            LC_SEGMENT_64 => {
                let nsects = u32_le(bytes, at + 64)? as usize;
                for s in 0..nsects {
                    let h = at + 72 + 80 * s;
                    let flags = u32_le(bytes, h + 64)?;
                    let size = u64_le(bytes, h + 40)?;
                    let offset = u32_le(bytes, h + 48)? as usize;
                    let zerofill = flags & 0xff == S_ZEROFILL || flags & 0xff == 0x12 || flags & 0xff == 0xc;
                    let data = if zerofill || size == 0 {
                        Vec::new()
                    } else {
                        bytes.get(offset..offset + size as usize).ok_or("section contents past the end")?.to_vec()
                    };
                    let reloff = u32_le(bytes, h + 56)? as usize;
                    let nreloc = u32_le(bytes, h + 60)? as usize;
                    let mut relocs = Vec::new();
                    let mut addend = 0i64;
                    for r in 0..nreloc {
                        let address = u32_le(bytes, reloff + 8 * r)?;
                        let info = u32_le(bytes, reloff + 8 * r + 4)?;
                        if address & 0x8000_0000 != 0 {
                            continue; // a scattered relocation: not used on arm64
                        }
                        let rel_type = (info >> 28) as u8;
                        let symbolnum = info & 0x00ff_ffff;
                        if rel_type == 10 {
                            // The addend, sign-extended from 24 bits, for the next.
                            addend = ((symbolnum << 8) as i32 >> 8) as i64;
                            continue;
                        }
                        relocs.push(MachReloc {
                            offset: address as u64,
                            rel_type,
                            length: ((info >> 25) & 3) as u8,
                            pcrel: info & (1 << 24) != 0,
                            symbolnum,
                            external: info & (1 << 27) != 0,
                            addend: std::mem::take(&mut addend),
                        });
                    }
                    relocs.sort_by_key(|r| r.offset);
                    sections.push(MachSection {
                        name: name16(bytes, h)?,
                        segment: name16(bytes, h + 16)?,
                        addr: u64_le(bytes, h + 32)?,
                        size,
                        flags,
                        data,
                        relocs,
                    });
                }
            }
            LC_SYMTAB => {
                symtab = Some((
                    u32_le(bytes, at + 8)? as usize,
                    u32_le(bytes, at + 12)? as usize,
                    u32_le(bytes, at + 16)? as usize,
                    u32_le(bytes, at + 20)? as usize,
                ));
            }
            _ => {}
        }
        at += size;
    }
    let mut symbols = Vec::new();
    if let Some((symoff, nsyms, stroff, strsize)) = symtab {
        let strings = bytes.get(stroff..stroff + strsize).ok_or("the string table past the end")?;
        for k in 0..nsyms {
            let e = symoff + 16 * k;
            let strx = u32_le(bytes, e)? as usize;
            let rest = strings.get(strx..).unwrap_or(&[]);
            let end = rest.iter().position(|&c| c == 0).unwrap_or(rest.len());
            let head = bytes.get(e + 4..e + 8).ok_or("a symbol past the end")?;
            symbols.push(MachSymbol {
                name: String::from_utf8_lossy(&rest[..end]).into_owned(),
                n_type: head[0],
                sect: head[1],
                desc: u16::from_le_bytes([head[2], head[3]]),
                value: u64_le(bytes, e + 8)?,
            });
        }
    }
    Ok(MachFile { file_type, cpu_type, sections, symbols })
}
