//! 64-bit Mach-O files for arm64: writing an [`Object`] as an object file
//! (`MH_OBJECT`), and reading any Mach-O file (objects and linked images,
//! and the arm64 slice of universal files) for `draconian-objdump` and the
//! tests.
//!
//! From Apple's published `<mach-o/loader.h>`, `<mach-o/nlist.h>`,
//! `<mach-o/reloc.h>` and `<mach-o/fat.h>` (the CPU type and relocation
//! types are the description's, `machine.rs`): a
//! header, then load commands, of which `LC_SEGMENT_64` lists sections
//! (with their relocations) and `LC_SYMTAB` places the symbols and their
//! names. A relocation names a symbol (`extern`) or a section (by number,
//! from 1); an `ARM64_RELOC_ADDEND` gives the addend of the relocation
//! after it.

use std::collections::HashMap;

use crate::machine::{Machine, RelocUse};
use crate::object::{Object, RelocTarget, SectionKind};

pub const MH_MAGIC_64: u32 = 0xfeed_facf;
pub const FAT_MAGIC: u32 = 0xcafe_babe;
pub const CPU_TYPE_ARM64: u32 = 0x0100_000c;
pub const MH_OBJECT: u32 = 1;

const LC_SEGMENT_64: u32 = 0x19;
const LC_SYMTAB: u32 = 0x2;
const LC_DYSYMTAB: u32 = 0xb;
const LC_BUILD_VERSION: u32 = 0x32;
pub const PLATFORM_MACOS: u32 = 1;

pub const S_ZEROFILL: u32 = 1;
pub const S_ATTR_PURE_INSTRUCTIONS: u32 = 0x8000_0000;
pub const S_ATTR_SOME_INSTRUCTIONS: u32 = 0x400;

pub const N_STAB: u8 = 0xe0;
pub const N_EXT: u8 = 0x01;
pub const N_TYPE: u8 = 0x0e;
pub const N_UNDF: u8 = 0x0;
pub const N_SECT: u8 = 0xe;
pub const N_WEAK_DEF: u16 = 0x80;

#[derive(Clone, Debug)]
pub struct MachFile {
    pub file_type: u32,
    pub cpu_type: u32,
    pub flags: u32,
    /// From `LC_BUILD_VERSION`: the platform, and the least OS version.
    pub build: Option<(u32, (u32, u32, u32))>,
    /// From `LC_DYSYMTAB`: how many local, defined external and undefined
    /// symbols there are, in that order in the table.
    pub dysymtab: Option<(u32, u32, u32)>,
    pub sections: Vec<MachSection>,
    pub symbols: Vec<MachSymbol>,
}

#[derive(Clone, Debug)]
pub struct MachSection {
    pub segment: String,
    pub name: String,
    pub addr: u64,
    pub size: u64,
    /// log2 of the alignment.
    pub align: u32,
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
    let flags = u32_le(bytes, 24)?;
    let mut at = 32;
    let mut sections = Vec::new();
    let mut symtab = None;
    let mut build = None;
    let mut dysymtab = None;
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
                        align: u32_le(bytes, h + 52)?,
                        flags,
                        data,
                        relocs,
                    });
                }
            }
            LC_BUILD_VERSION => {
                let v = u32_le(bytes, at + 12)?;
                build = Some((u32_le(bytes, at + 8)?, (v >> 16, (v >> 8) & 0xff, v & 0xff)));
            }
            LC_DYSYMTAB => {
                dysymtab = Some((u32_le(bytes, at + 12)?, u32_le(bytes, at + 20)?, u32_le(bytes, at + 28)?));
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
    Ok(MachFile { file_type, cpu_type, flags, build, dysymtab, sections, symbols })
}

// ---------------------------------------------------------------------------
// Writing

/// The segment and section a kind of section is in Mach-O.
pub fn section_names(kind: SectionKind) -> (&'static str, &'static str) {
    match kind {
        SectionKind::Text => ("__TEXT", "__text"),
        SectionKind::Data => ("__DATA", "__data"),
        SectionKind::Bss => ("__DATA", "__bss"),
        SectionKind::ReadOnly => ("__TEXT", "__const"),
        SectionKind::RelRo => ("__DATA", "__const"),
    }
}

fn section_flags(kind: SectionKind) -> u32 {
    match kind {
        SectionKind::Text => S_ATTR_PURE_INSTRUCTIONS | S_ATTR_SOME_INSTRUCTIONS,
        SectionKind::Bss => S_ZEROFILL,
        _ => 0,
    }
}

fn put_name16(out: &mut Vec<u8>, name: &str) {
    let mut b = [0u8; 16];
    b[..name.len().min(16)].copy_from_slice(&name.as_bytes()[..name.len().min(16)]);
    out.extend_from_slice(&b);
}

fn put32(out: &mut Vec<u8>, v: u32) {
    out.extend_from_slice(&v.to_le_bytes());
}

fn put64(out: &mut Vec<u8>, v: u64) {
    out.extend_from_slice(&v.to_le_bytes());
}

/// Writes `obj` as a 64-bit Mach-O object file for arm64 that says it is
/// for macOS `min_os` or later.
///
/// Its load commands: one unnamed `LC_SEGMENT_64` holding every section
/// (laid out one after another from address 0, as in the file),
/// `LC_BUILD_VERSION`, `LC_SYMTAB`, and `LC_DYSYMTAB`. The symbol table has
/// the local symbols, then the defined external ones by name, then the
/// undefined ones by name, as `LC_DYSYMTAB` says. Relocations name their
/// symbols (`r_extern`), and are listed from the highest address down, as
/// assembler does; a pointer's addend is in the pointer's bytes.
pub fn write(obj: &Object, min_os: (u32, u32, u32), m: &Machine) -> Result<Vec<u8>, String> {
    let cpu = m.macho_cpu.ok_or("the description has no Mach-O CPU type (target parameter macho-cpu)")?;
    // Addresses: each section after the last, aligned.
    let mut addrs = Vec::new();
    let mut at = 0u64;
    for s in &obj.sections {
        at = at.next_multiple_of(s.align.max(1));
        addrs.push(at);
        at += s.size();
    }
    let vmsize = at;

    // Symbols: locals, defined externals by name, undefined by name.
    let mut order: Vec<usize> = (0..obj.symbols.len()).collect();
    let class = |k: usize| {
        let s = &obj.symbols[k];
        if !s.global {
            0
        } else if s.section.is_some() {
            1
        } else {
            2
        }
    };
    order.sort_by(|&a, &b| {
        class(a)
            .cmp(&class(b))
            .then_with(|| if class(a) == 0 { a.cmp(&b) } else { obj.symbols[a].name.cmp(&obj.symbols[b].name) })
    });
    let index: HashMap<usize, u32> = order.iter().enumerate().map(|(i, &k)| (k, i as u32)).collect();
    let counts = [0, 1, 2].map(|c| order.iter().filter(|&&k| class(k) == c).count() as u32);

    let mut strtab = vec![b' ', 0];
    let mut symtab = Vec::new();
    for &k in &order {
        let s = &obj.symbols[k];
        let strx = strtab.len() as u32;
        strtab.extend_from_slice(s.name.as_bytes());
        strtab.push(0);
        put32(&mut symtab, strx);
        let (n_type, n_sect, value) = match s.section {
            Some(sec) => (N_SECT | if s.global { N_EXT } else { 0 }, sec as u8 + 1, addrs[sec] + s.value),
            None => (N_UNDF | N_EXT, 0, 0),
        };
        symtab.extend_from_slice(&[n_type, n_sect, 0, 0]);
        put64(&mut symtab, value);
    }
    while strtab.len() % 8 != 0 {
        strtab.push(0);
    }

    // Section contents, with pointers' addends in their bytes, and each
    // section's relocations.
    let mut contents: Vec<Vec<u8>> = Vec::new();
    let mut relocs: Vec<Vec<u8>> = Vec::new();
    for s in &obj.sections {
        let mut data = s.data.clone();
        let mut rel = Vec::new();
        let mut sorted: Vec<&crate::object::Reloc> = s.relocs.iter().collect();
        sorted.sort_by_key(|r| std::cmp::Reverse(r.offset));
        for r in sorted {
            let def = &m.relocs[r.kind.0 as usize];
            let ty = def.macho.ok_or_else(|| format!("relocation {} has no Mach-O type", def.name))?;
            let (pcrel, length) = (def.macho_pcrel, def.macho_length);
            let RelocTarget::Symbol(sym) = r.target else { unreachable!("Mach-O relocations name their symbols") };
            let mut addend = r.addend;
            if matches!(def.usage, RelocUse::Data(_)) {
                let at = r.offset as usize;
                data[at..at + 8].copy_from_slice(&(addend as u64).to_le_bytes());
                addend = 0;
            }
            if addend != 0 {
                put32(&mut rel, r.offset as u32);
                put32(&mut rel, ((addend as u32) & 0x00ff_ffff) | (2 << 25) | (10 << 28));
            }
            put32(&mut rel, r.offset as u32);
            let info = index[&sym] | (pcrel as u32) << 24 | (length as u32) << 25 | 1 << 27 | (ty as u32) << 28;
            put32(&mut rel, info);
        }
        contents.push(data);
        relocs.push(rel);
    }

    // Layout: header, load commands, section contents, relocations, symbols,
    // strings.
    let nsects = obj.sections.len() as u32;
    let seg_size = 72 + 80 * nsects;
    let sizeofcmds = seg_size + 24 + 24 + 80;
    let mut off = 32 + sizeofcmds as u64;
    let mut file_offs = Vec::new();
    let fileoff = off;
    for (k, s) in obj.sections.iter().enumerate() {
        if s.kind == SectionKind::Bss {
            file_offs.push(0);
            continue;
        }
        // Sections keep their addresses' distances in the file.
        off = fileoff + addrs[k];
        file_offs.push(off);
        off += s.size();
    }
    let filesize = off - fileoff;
    let mut rel_offs = Vec::new();
    off = off.next_multiple_of(8);
    for r in &relocs {
        rel_offs.push(if r.is_empty() { 0 } else { off });
        off += r.len() as u64;
    }
    let symoff = off.next_multiple_of(8);
    let stroff = symoff + symtab.len() as u64;

    let mut out = Vec::new();
    put32(&mut out, MH_MAGIC_64);
    put32(&mut out, cpu);
    put32(&mut out, 0); // CPU_SUBTYPE_ARM64_ALL
    put32(&mut out, MH_OBJECT);
    put32(&mut out, 4);
    put32(&mut out, sizeofcmds);
    put32(&mut out, 0); // flags
    put32(&mut out, 0); // reserved

    put32(&mut out, LC_SEGMENT_64);
    put32(&mut out, seg_size);
    put_name16(&mut out, "");
    put64(&mut out, 0);
    put64(&mut out, vmsize);
    put64(&mut out, fileoff);
    put64(&mut out, filesize);
    put32(&mut out, 7);
    put32(&mut out, 7);
    put32(&mut out, nsects);
    put32(&mut out, 0);
    for (k, s) in obj.sections.iter().enumerate() {
        let (seg, sect) = section_names(s.kind);
        put_name16(&mut out, sect);
        put_name16(&mut out, seg);
        put64(&mut out, addrs[k]);
        put64(&mut out, s.size());
        put32(&mut out, file_offs[k] as u32);
        put32(&mut out, s.align.max(1).trailing_zeros());
        put32(&mut out, rel_offs[k] as u32);
        put32(&mut out, (relocs[k].len() / 8) as u32);
        put32(&mut out, section_flags(s.kind));
        put32(&mut out, 0);
        put32(&mut out, 0);
        put32(&mut out, 0);
    }

    put32(&mut out, LC_BUILD_VERSION);
    put32(&mut out, 24);
    put32(&mut out, PLATFORM_MACOS);
    put32(&mut out, (min_os.0 << 16) | (min_os.1 << 8) | min_os.2);
    put32(&mut out, 0); // sdk
    put32(&mut out, 0); // tools

    put32(&mut out, LC_SYMTAB);
    put32(&mut out, 24);
    put32(&mut out, symoff as u32);
    put32(&mut out, order.len() as u32);
    put32(&mut out, stroff as u32);
    put32(&mut out, strtab.len() as u32);

    put32(&mut out, LC_DYSYMTAB);
    put32(&mut out, 80);
    put32(&mut out, 0);
    put32(&mut out, counts[0]);
    put32(&mut out, counts[0]);
    put32(&mut out, counts[1]);
    put32(&mut out, counts[0] + counts[1]);
    put32(&mut out, counts[2]);
    out.resize(out.len() + 4 * 12, 0);

    for (k, data) in contents.iter().enumerate() {
        if obj.sections[k].kind == SectionKind::Bss {
            continue;
        }
        out.resize(file_offs[k] as usize, 0);
        out.extend_from_slice(data);
    }
    for (k, r) in relocs.iter().enumerate() {
        if !r.is_empty() {
            out.resize(rel_offs[k] as usize, 0);
            out.extend_from_slice(r);
        }
    }
    out.resize(symoff as usize, 0);
    out.extend_from_slice(&symtab);
    out.extend_from_slice(&strtab);
    Ok(out)
}

impl MachFile {
    /// The file as sorted text, for comparing two files that should say
    /// the same: the header's type and flags, the build version, each
    /// section's flags, alignment, address, size and contents, its
    /// relocations (against names), and the symbols, without the
    /// assembler's temporaries (`ltmp0`). Where things are in the file,
    /// and in what order, is left out.
    pub fn canonical(&self, m: &Machine) -> String {
        use std::fmt::Write;
        let mut out = format!("file type {} flags {:#x}\n", self.file_type, self.flags);
        if let Some((platform, (a, b, c))) = self.build {
            let _ = writeln!(out, "build platform {platform} minos {a}.{b}.{c}");
        }
        let name = |k: usize| self.sections.get(k).map_or("?".to_string(), |s| format!("{},{}", s.segment, s.name));
        for s in &self.sections {
            let _ = writeln!(
                out,
                "section {},{} flags {:#x} align {} addr {:#x} size {:#x}",
                s.segment, s.name, s.flags, s.align, s.addr, s.size
            );
            for (k, chunk) in s.data.chunks(16).enumerate() {
                let hex: Vec<String> = chunk.iter().map(|b| format!("{b:02x}")).collect();
                let _ = writeln!(out, "  {:06x} {}", k * 16, hex.join(""));
            }
            let mut relocs: Vec<String> = s
                .relocs
                .iter()
                .map(|r| {
                    let target = if r.external {
                        self.symbols.get(r.symbolnum as usize).map_or("?".to_string(), |x| x.name.clone())
                    } else {
                        format!("section {}", name(r.symbolnum as usize - 1))
                    };
                    format!(
                        "  reloc {:06x} {} pcrel {} length {} {}{:+#x}",
                        r.offset,
                        m.macho_name(r.rel_type),
                        r.pcrel,
                        r.length,
                        target,
                        r.addend
                    )
                })
                .collect();
            relocs.sort();
            for r in relocs {
                let _ = writeln!(out, "{r}");
            }
        }
        let mut syms: Vec<String> = self
            .symbols
            .iter()
            .filter(|s| !s.is_stab() && !s.name.starts_with("ltmp"))
            .map(|s| {
                let sect = if s.sect == 0 { "*UND*".to_string() } else { name(s.sect as usize - 1) };
                format!("symbol {} type {:#x} in {} at {:#x} desc {:#x}", s.name, s.n_type, sect, s.value, s.desc)
            })
            .collect();
        syms.sort();
        for s in syms {
            let _ = writeln!(out, "{s}");
        }
        out
    }
}
