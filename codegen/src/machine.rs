//! What a description says about its machine as a whole, in named metadata:
//! the names of its registers, its relocations, and a few parameters.
//!
//! ```llvm
//! !target.registers = !{!1, ...}
//! !1 = !{!"x", !"x{0-30}", !"xzr"}        ; class x: x0 ... x30, then xzr
//! !target.params = !{!2, ...}
//! !2 = !{!"sp", !"sp"}                     ; the stack pointer, by name
//! !target.relocs = !{!3, ...}
//! !3 = !{!"name", !"call26", !"elf", !"283", ...}
//! ```
//!
//! Each register class lists the names of its registers in number order;
//! `x{0-30}` stands for x0 to x30. The floating-point and vector classes
//! (`d`, `s`, `q`, `v`) number their registers from 32 in the code
//! generator, so their names are of registers 32 and up. Further *views*
//! name the same registers another way for templates: `b` and `h` (scalar
//! views of the vector registers) and `lanes` (`v3` in `v3.4s`).
//!
//! The parameters:
//!
//! - `sp`, `zero`: the stack pointer, and the register that reads as zero
//!   (if there is one), by name;
//! - `vector-bits`: the width of a vector register, or 0 if there are none
//!   (vectors are then done lane by lane);
//! - `narrow-results`: how a 32-bit result sits in a 64-bit register:
//!   `zero` (the top half is zeroed; AArch64) or `sign` (sign-extended;
//!   RISC-V), which decides which extensions and truncations are free;
//! - `external-via-got`: `yes` if symbols another module defines are
//!   reached through the global offset table;
//! - `elf-machine`, `elf-flags`, `macho-cpu`: the object files' identity;
//! - `cpu`: the CPU to assume when none is named;
//! - `boolean-branches`: `bit` if a branch can test a boolean's lowest bit
//!   (the rest being undefined), or `compare` if branches compare whole
//!   registers: then a branch on a boolean that is not a comparison's is
//!   made a comparison of it, zero-extended, with zero.
//!
//! `vector-bits` may name a third value, the feature the vector registers
//! come with (`neon`): without it, vectors are done lane by lane.
//!
//! `!target.cpus` lists CPUs, each a name and then the features it has
//! (`!{!"generic", !"fp-armv8", !"neon"}`). Entries of the description with
//! a `"feature"` attribute are used only when their features are on; see
//! `features.rs`.
//!
//! A relocation is a list of properties, as pairs:
//!
//! - `name`: as `"reloc"` attributes name it;
//! - `elf`, `elf-name`: its ELF number and name; `macho`, `macho-name`,
//!   `macho-pcrel`, `macho-length`: Mach-O's type, name, whether it is
//!   PC-relative, and log2 of its size;
//! - `elf-syntax`, `macho-syntax`: how assembly writes an operand it fills
//!   in, with `{s}` for the symbol (`:lo12:{s}`, `{s}@PAGEOFF`);
//! - `use`: `call` (a branch to a symbol, resolved in place when the
//!   symbol is in the same section), `got` (through the global offset
//!   table: kept against the symbol), or `data8` (a pointer of 8 bytes in
//!   data; `dataN` for N bytes);
//! - `target`: the address an instruction reaches, from its address `pc`
//!   and the operand's value `v`, for disassembly (`(pc & -4096) + (v << 12)`).
//!
//! Relocations with only a number and a name are for reading other
//! programs' object files.

use std::collections::HashMap;

use draconian_ir::module::{MdId, Metadata, Module};

use crate::abi::Syntax;
use crate::enc::{self, Env, Expr};
use crate::target::Class;

/// How a 32-bit result sits in a 64-bit register.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Narrow {
    /// Its top half is zero: zero extension is free, and so is truncation.
    Zero,
    /// It is sign-extended: sign extension is free; truncation is not.
    Sign,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RelocUse {
    Plain,
    /// A branch to a symbol.
    Call,
    /// Through the global offset table.
    Got,
    /// A pointer in data, of this many bytes.
    Data(u8),
}

#[derive(Clone, Debug)]
pub struct RelocDef {
    pub name: String,
    pub elf: Option<u32>,
    pub elf_name: String,
    pub macho: Option<u8>,
    pub macho_name: String,
    pub macho_pcrel: bool,
    pub macho_length: u8,
    pub elf_syntax: String,
    pub macho_syntax: String,
    pub usage: RelocUse,
    pub target: Option<Expr>,
}

impl RelocDef {
    /// How assembly in `syntax` writes an operand this fills in.
    pub fn spell(&self, syntax: Syntax, sym: &str) -> String {
        let tpl = match syntax {
            Syntax::Elf => &self.elf_syntax,
            Syntax::MachO => &self.macho_syntax,
        };
        tpl.replace("{s}", sym)
    }

    /// The symbol in an operand written `text`, if this is how it is
    /// written in `syntax`.
    pub fn unspell<'a>(&self, syntax: Syntax, text: &'a str) -> Option<&'a str> {
        let tpl = match syntax {
            Syntax::Elf => &self.elf_syntax,
            Syntax::MachO => &self.macho_syntax,
        };
        let (pre, post) = tpl.split_once("{s}")?;
        text.strip_prefix(pre)?.strip_suffix(post)
    }

    /// The address an instruction at `pc` reaches, with operand value `v`.
    pub fn reaches(&self, pc: u64, v: i64) -> Option<u64> {
        let e = self.target.as_ref()?;
        let mut env = Env::new();
        env.insert("pc".into(), pc as i64);
        env.insert("v".into(), v);
        enc::eval(e, &env).map(|a| a as u64)
    }
}

#[derive(Clone, Debug)]
pub struct Machine {
    /// The names of each class's registers, in number order (from 32, for
    /// the floating-point and vector classes).
    pub names: HashMap<Class, Vec<String>>,
    /// Other names for the vector registers, for templates.
    pub views: HashMap<String, Vec<String>>,
    pub sp: u8,
    pub zero: Option<u8>,
    pub vector_bits: u32,
    pub narrow: Narrow,
    pub external_via_got: bool,
    pub elf_machine: u16,
    pub elf_flags: u32,
    pub macho_cpu: Option<u32>,
    pub relocs: Vec<RelocDef>,
    /// The feature the vector registers come with, if they are optional.
    pub vector_feature: Option<String>,
    /// CPUs, with the features each has.
    pub cpus: Vec<(String, Vec<String>)>,
    /// The CPU to assume when none is named.
    pub default_cpu: Option<String>,
    /// Branches on a boolean in a register must compare the whole register
    /// (RISC-V), rather than test its lowest bit (AArch64's `tbnz`).
    pub compare_booleans: bool,
}

fn strings(m: &Module, id: MdId) -> Vec<String> {
    match &m.metadata[id.index()].data {
        Metadata::Tuple { ops, .. } => ops
            .iter()
            .filter_map(|o| match o.map(|x| &m.metadata[x.index()].data) {
                Some(Metadata::String(s)) => Some(String::from_utf8_lossy(s).into_owned()),
                _ => None,
            })
            .collect(),
        _ => vec![],
    }
}

/// The tuples of strings in named metadata `name`.
pub fn tuples(m: &Module, name: &str) -> Vec<Vec<String>> {
    m.named_metadata
        .iter()
        .filter(|nm| nm.name == name)
        .flat_map(|nm| nm.ops.iter().map(|&op| strings(m, op)))
        .collect()
}

/// `x{0-30}` is x0 ... x30; other names are themselves.
fn expand(names: &[String]) -> Result<Vec<String>, String> {
    let mut out = Vec::new();
    for n in names {
        match n.split_once('{') {
            Some((pre, rest)) => {
                let (range, post) = rest.split_once('}').ok_or_else(|| format!("bad register names {n}"))?;
                let (a, b) = range.split_once('-').ok_or_else(|| format!("bad register names {n}"))?;
                let (a, b): (u32, u32) = (a.parse().map_err(|_| n.clone())?, b.parse().map_err(|_| n.clone())?);
                out.extend((a..=b).map(|k| format!("{pre}{k}{post}")));
            }
            None => out.push(n.clone()),
        }
    }
    Ok(out)
}

impl Machine {
    pub fn read(m: &Module) -> Result<Machine, String> {
        let mut names = HashMap::new();
        let mut views = HashMap::new();
        for t in tuples(m, "target.registers") {
            let Some((class, list)) = t.split_first() else { continue };
            let list = expand(list)?;
            match Class::parse(class) {
                Some(c) => {
                    names.insert(c, list);
                }
                None => {
                    views.insert(class.clone(), list);
                }
            }
        }
        if names.is_empty() {
            return Err("the description names no registers (!target.registers)".into());
        }
        let all_params = tuples(m, "target.params");
        let params: HashMap<String, String> = all_params
            .iter()
            .filter_map(|t| Some((t.first()?.clone(), t.get(1).cloned().unwrap_or_default())))
            .collect();
        let mut mc = Machine {
            names,
            views,
            sp: 0,
            zero: None,
            vector_bits: 0,
            narrow: Narrow::Zero,
            external_via_got: false,
            elf_machine: 0,
            elf_flags: 0,
            macho_cpu: None,
            relocs: Vec::new(),
            vector_feature: None,
            cpus: Vec::new(),
            default_cpu: None,
            compare_booleans: false,
        };
        let num = |k: &str| -> Result<Option<u64>, String> {
            params
                .get(k)
                .map(|v| {
                    let v = v.trim();
                    match v.strip_prefix("0x") {
                        Some(h) => u64::from_str_radix(h, 16),
                        None => v.parse(),
                    }
                    .map_err(|_| format!("target parameter {k}: {v}"))
                })
                .transpose()
        };
        mc.sp = mc.reg(params.get("sp").ok_or("no stack pointer (target parameter sp)")?)?;
        mc.zero = params.get("zero").map(|z| mc.reg(z)).transpose()?;
        mc.vector_bits = num("vector-bits")?.unwrap_or(0) as u32;
        mc.vector_feature = all_params.iter().find(|t| t[0] == "vector-bits").and_then(|t| t.get(2).cloned());
        mc.default_cpu = params.get("cpu").cloned();
        mc.compare_booleans = match params.get("boolean-branches").map(String::as_str) {
            None | Some("bit") => false,
            Some("compare") => true,
            Some(o) => return Err(format!("target parameter boolean-branches: {o}")),
        };
        for t in tuples(m, "target.cpus") {
            if let Some((name, feats)) = t.split_first() {
                mc.cpus.push((name.clone(), feats.to_vec()));
            }
        }
        mc.narrow = match params.get("narrow-results").map(String::as_str) {
            None | Some("zero") => Narrow::Zero,
            Some("sign") => Narrow::Sign,
            Some(o) => return Err(format!("target parameter narrow-results: {o}")),
        };
        mc.external_via_got = params.get("external-via-got").is_some_and(|v| v == "yes");
        mc.elf_machine = num("elf-machine")?.unwrap_or(0) as u16;
        mc.elf_flags = num("elf-flags")?.unwrap_or(0) as u32;
        mc.macho_cpu = num("macho-cpu")?.map(|v| v as u32);
        for t in tuples(m, "target.relocs") {
            let p: HashMap<&str, &str> =
                t.chunks(2).filter_map(|c| Some((c[0].as_str(), c.get(1)?.as_str()))).collect();
            let name = p.get("name").ok_or("a relocation without a name")?.to_string();
            let parse = |k: &str| -> Result<Option<u32>, String> {
                p.get(k).map(|v| v.parse::<u32>().map_err(|_| format!("relocation {name}: {k} {v}"))).transpose()
            };
            mc.relocs.push(RelocDef {
                elf: parse("elf")?,
                elf_name: p.get("elf-name").unwrap_or(&"").to_string(),
                macho: parse("macho")?.map(|v| v as u8),
                macho_name: p.get("macho-name").unwrap_or(&"").to_string(),
                macho_pcrel: p.get("macho-pcrel") == Some(&"yes"),
                macho_length: parse("macho-length")?.unwrap_or(2) as u8,
                elf_syntax: p.get("elf-syntax").unwrap_or(&"{s}").to_string(),
                macho_syntax: p.get("macho-syntax").unwrap_or(&"{s}").to_string(),
                usage: match p.get("use").copied() {
                    None | Some("") => RelocUse::Plain,
                    Some("call") => RelocUse::Call,
                    Some("got") => RelocUse::Got,
                    Some(d) if d.starts_with("data") => RelocUse::Data(
                        d.trim_start_matches("data").parse().map_err(|_| format!("relocation {name}: use {d}"))?,
                    ),
                    Some(o) => return Err(format!("relocation {name}: use {o}")),
                },
                target: p
                    .get("target")
                    .map(|e| enc::parse_expr(e).map_err(|err| format!("relocation {name}: {err}")))
                    .transpose()?,
                name,
            });
        }
        Ok(mc)
    }

    /// The name of register `r` in class `class`.
    pub fn name(&self, class: Class, r: u8) -> String {
        let k = if class.is_fp() { r.wrapping_sub(32) } else { r } as usize;
        self.names.get(&class).and_then(|n| n.get(k)).cloned().unwrap_or_else(|| format!("r{r}?"))
    }

    /// The name of register `r` (32 and up) in a view: `lanes`, `b`, `h`.
    pub fn view(&self, view: &str, r: u8) -> Option<String> {
        self.views.get(view).and_then(|n| n.get(r.wrapping_sub(32) as usize)).cloned()
    }

    /// The register a name names, in any class or view.
    pub fn reg(&self, name: &str) -> Result<u8, String> {
        self.lookup(name).ok_or_else(|| format!("no register {name}"))
    }

    pub fn lookup(&self, name: &str) -> Option<u8> {
        for (c, names) in &self.names {
            if let Some(k) = names.iter().position(|n| n == name) {
                return Some(if c.is_fp() { 32 + k as u8 } else { k as u8 });
            }
        }
        for names in self.views.values() {
            if let Some(k) = names.iter().position(|n| n == name) {
                return Some(32 + k as u8);
            }
        }
        None
    }

    /// Registers in a list such as `["x0-x7", "x30"]`.
    pub fn regs(&self, list: &[String]) -> Result<Vec<u8>, String> {
        let mut out = Vec::new();
        for n in list {
            match n.split_once('-').filter(|(a, b)| self.lookup(a).is_some() && self.lookup(b).is_some()) {
                Some((a, b)) => out.extend(self.reg(a)?..=self.reg(b)?),
                None => out.push(self.reg(n)?),
            }
        }
        Ok(out)
    }

    pub fn reloc(&self, name: &str) -> Option<usize> {
        self.relocs.iter().position(|r| r.name == name)
    }

    /// The relocation for a pointer of `bytes` bytes in data.
    pub fn data_reloc(&self, bytes: u8) -> Option<usize> {
        self.relocs.iter().position(|r| r.usage == RelocUse::Data(bytes))
    }

    pub fn by_elf(&self, ty: u32) -> Option<usize> {
        self.relocs.iter().position(|r| r.elf == Some(ty))
    }

    pub fn by_macho(&self, ty: u8, length: u8) -> Option<usize> {
        self.relocs
            .iter()
            .position(|r| r.macho == Some(ty) && (r.usage != RelocUse::Data(8) || length == 3))
            .or_else(|| self.relocs.iter().position(|r| r.macho == Some(ty)))
    }

    pub fn elf_name(&self, ty: u32) -> String {
        match self.by_elf(ty) {
            Some(k) if !self.relocs[k].elf_name.is_empty() => self.relocs[k].elf_name.clone(),
            _ => format!("R_{ty}"),
        }
    }

    pub fn macho_name(&self, ty: u8) -> String {
        match self.relocs.iter().find(|r| r.macho == Some(ty) && !r.macho_name.is_empty()) {
            Some(r) => r.macho_name.clone(),
            None => format!("RELOC_{ty}"),
        }
    }
}
