//! Calling conventions and platforms, read from the description's named
//! metadata (`!aarch64.abi.NAME`): which registers carry arguments and
//! results, which a call clobbers and which survive it, how arguments past
//! the registers are laid out on the stack, where variadic arguments go,
//! and the assembler's dialect.

use smaugian_ir::module::{MdId, Metadata, Module};

/// How arguments that do not fit in registers are laid out on the stack.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum StackArgs {
    /// Each at its own size and alignment, packed (Apple).
    Natural,
    /// Each in an 8-byte slot (AAPCS64).
    Slots,
}

/// Where the variable arguments of a call to a variadic function go.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Variadic {
    /// Always on the stack, in 8-byte slots (Apple).
    Stack,
    /// Where named arguments would go (AAPCS64).
    Named,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Syntax {
    MachO,
    Elf,
}

#[derive(Clone, Debug)]
pub struct Abi {
    pub name: String,
    pub args: Vec<u8>,
    pub result: u8,
    pub clobbers: Vec<u8>,
    pub saved: Vec<u8>,
    pub reserved: Vec<u8>,
    pub scratch: Vec<u8>,
    /// Floating-point registers (32-63 for d0-d31): arguments, result,
    /// those a call may change, those preserved, and scratch for spills.
    pub fp_args: Vec<u8>,
    pub fp_result: u8,
    pub fp_clobbers: Vec<u8>,
    pub fp_saved: Vec<u8>,
    pub fp_scratch: Vec<u8>,
    pub fp: u8,
    pub lr: u8,
    pub stack_args: StackArgs,
    pub variadic: Variadic,
    pub syntax: Syntax,
    pub triples: Vec<String>,
}

/// One register's worth of an argument: its size in bytes, and whether it
/// is floating-point.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Part {
    pub size: u64,
    pub fp: bool,
}

/// Where one argument goes.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum ArgLoc {
    Reg(u8),
    /// A byte offset from the stack pointer at the call.
    Stack(i64),
}

fn regs(names: &[String]) -> Result<Vec<u8>, String> {
    let one = |s: &str| -> Result<u8, String> {
        if let Some(n) = s.strip_prefix('d').and_then(|n| n.parse::<u8>().ok()).filter(|&n| n <= 31) {
            return Ok(32 + n);
        }
        s.strip_prefix('x')
            .and_then(|n| n.parse::<u8>().ok())
            .filter(|&n| n <= 30)
            .ok_or_else(|| format!("bad register {s}"))
    };
    let mut out = Vec::new();
    for n in names {
        match n.split_once('-') {
            Some((a, b)) => out.extend(one(a)?..=one(b)?),
            None => out.push(one(n)?),
        }
    }
    Ok(out)
}

impl Abi {
    /// The registers to allocate values to that a call clobbers.
    pub fn caller_saved(&self) -> Vec<u8> {
        self.clobbers
            .iter()
            .copied()
            .filter(|r| !self.reserved.contains(r) && !self.scratch.contains(r) && *r != self.fp && *r != self.lr)
            .collect()
    }

    /// The registers to allocate values to that survive calls.
    pub fn callee_saved(&self) -> Vec<u8> {
        self.saved.iter().copied().filter(|r| !self.reserved.contains(r) && !self.scratch.contains(r)).collect()
    }

    pub fn fp_caller_saved(&self) -> Vec<u8> {
        self.fp_clobbers.iter().copied().filter(|r| !self.fp_scratch.contains(r)).collect()
    }

    pub fn fp_callee_saved(&self) -> Vec<u8> {
        self.fp_saved.clone()
    }

    /// Every register a call may change.
    pub fn all_clobbers(&self) -> Vec<u8> {
        self.clobbers.iter().chain(&self.fp_clobbers).copied().collect()
    }

    /// Where each argument goes, given each one's size in bytes and how
    /// many are named (the rest are variable arguments), and the bytes of
    /// stack the call needs.
    pub fn assign(&self, sizes: &[u64], named: usize) -> (Vec<ArgLoc>, i64) {
        let parts: Vec<Vec<Part>> = sizes.iter().map(|&s| vec![Part { size: s, fp: false }]).collect();
        let (locs, stack) = self.assign_parts(&parts, named);
        (locs.into_iter().map(|l| l[0]).collect(), stack)
    }

    /// Like `assign`, for arguments that may have several parts: a small
    /// struct passed as `[2 x i64]` takes consecutive registers if enough
    /// are left, and otherwise goes on the stack whole, with no registers
    /// used for arguments after it.
    pub fn assign_parts(&self, args: &[Vec<Part>], named: usize) -> (Vec<Vec<ArgLoc>>, i64) {
        let mut locs = Vec::new();
        let mut next_reg = 0;
        let mut next_fp = 0;
        let mut stack: i64 = 0;
        for (k, parts) in args.iter().enumerate() {
            let fp = parts.iter().all(|p| p.fp);
            let variadic = k >= named;
            let n = parts.len();
            if variadic && self.variadic == Variadic::Stack {
                let mut here = Vec::new();
                for _ in parts.iter() {
                    stack = (stack + 7) / 8 * 8;
                    here.push(ArgLoc::Stack(stack));
                    stack += 8;
                }
                locs.push(here);
                continue;
            }
            // Floating-point values take floating-point registers, counted
            // separately; integers and pointers take x0-x7.
            let (regs, next) = if fp { (&self.fp_args, &mut next_fp) } else { (&self.args, &mut next_reg) };
            if *next + n <= regs.len() {
                locs.push(regs[*next..*next + n].iter().map(|&r| ArgLoc::Reg(r)).collect());
                *next += n;
                continue;
            }
            if n > 1 {
                *next = regs.len();
            }
            let mut here = Vec::new();
            for &Part { size, .. } in parts {
                let (align, room) = match (self.stack_args, n) {
                    (StackArgs::Natural, 1) => (size.max(1) as i64, size.max(1) as i64),
                    _ => (8, 8),
                };
                stack = (stack + align - 1) / align * align;
                here.push(ArgLoc::Stack(stack));
                stack += room;
            }
            locs.push(here);
        }
        (locs, (stack + 15) / 16 * 16)
    }

    /// The symbol for a global's name. A name starting with byte 1 is
    /// used as it is, without the platform's prefix (LLVM's `@"\01name"`).
    pub fn symbol(&self, name: &str) -> String {
        if let Some(exact) = name.strip_prefix('\u{1}') {
            return exact.to_string();
        }
        match self.syntax {
            Syntax::MachO => format!("_{name}"),
            Syntax::Elf => name.to_string(),
        }
    }

    /// The prefix of local labels, which the assembler keeps out of the
    /// symbol table.
    pub fn local_prefix(&self) -> &'static str {
        match self.syntax {
            Syntax::MachO => "L",
            Syntax::Elf => ".L",
        }
    }

    /// A reference to the 4KB page holding `sym`, and to its offset in it.
    pub fn page(&self, sym: &str) -> String {
        match self.syntax {
            Syntax::MachO => format!("{}@PAGE", self.symbol(sym)),
            Syntax::Elf => self.symbol(sym),
        }
    }

    pub fn pageoff(&self, sym: &str) -> String {
        match self.syntax {
            Syntax::MachO => format!("{}@PAGEOFF", self.symbol(sym)),
            Syntax::Elf => format!(":lo12:{}", self.symbol(sym)),
        }
    }

    /// The page holding `sym`'s entry in the global offset table, and the
    /// entry's offset in it.
    pub fn got_page(&self, sym: &str) -> String {
        match self.syntax {
            Syntax::MachO => format!("{}@GOTPAGE", self.symbol(sym)),
            Syntax::Elf => format!(":got:{}", self.symbol(sym)),
        }
    }

    pub fn got_pageoff(&self, sym: &str) -> String {
        match self.syntax {
            Syntax::MachO => format!("{}@GOTPAGEOFF", self.symbol(sym)),
            Syntax::Elf => format!(":got_lo12:{}", self.symbol(sym)),
        }
    }

    pub fn text_section(&self) -> &'static str {
        match self.syntax {
            Syntax::MachO => ".section __TEXT,__text,regular,pure_instructions",
            Syntax::Elf => ".text",
        }
    }

    /// Where a global goes: constants without addresses in them are
    /// read-only text; constants with addresses need relocating when the
    /// program is loaded, so go where the loader may write.
    pub fn data_section(&self, constant: bool, has_addresses: bool) -> &'static str {
        match (self.syntax, constant, has_addresses) {
            (Syntax::MachO, false, _) => ".section __DATA,__data",
            (Syntax::MachO, true, false) => ".section __TEXT,__const",
            (Syntax::MachO, true, true) => ".section __DATA,__const",
            (Syntax::Elf, false, _) => ".data",
            (Syntax::Elf, true, false) => ".section .rodata",
            (Syntax::Elf, true, true) => ".section .data.rel.ro,\"aw\"",
        }
    }
}

/// Every convention the description names.
pub fn read(m: &Module, prefix: &str) -> Result<Vec<Abi>, String> {
    let strings = |id: MdId| -> Vec<String> {
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
    };
    let mut out = Vec::new();
    for nm in &m.named_metadata {
        let Some(name) = nm.name.strip_prefix(prefix) else { continue };
        let mut props: std::collections::HashMap<String, Vec<String>> = Default::default();
        for &op in &nm.ops {
            let list = strings(op);
            if let Some((k, v)) = list.split_first() {
                props.insert(k.clone(), v.to_vec());
            }
        }
        let get = |k: &str| props.get(k).cloned().ok_or_else(|| format!("{name}: no {k}"));
        let one = |k: &str| -> Result<String, String> {
            get(k)?.first().cloned().ok_or_else(|| format!("{name}: empty {k}"))
        };
        let frame = regs(&get("frame")?)?;
        out.push(Abi {
            name: name.to_string(),
            args: regs(&get("args")?)?,
            result: regs(&get("result")?)?[0],
            clobbers: regs(&get("clobbers")?)?,
            saved: regs(&get("saved")?)?,
            reserved: regs(&get("reserved")?)?,
            scratch: regs(&get("scratch")?)?,
            fp_args: regs(&get("fp-args")?)?,
            fp_result: regs(&get("fp-result")?)?[0],
            fp_clobbers: regs(&get("fp-clobbers")?)?,
            fp_saved: regs(&get("fp-saved")?)?,
            fp_scratch: regs(&get("fp-scratch")?)?,
            fp: frame[0],
            lr: frame[1],
            stack_args: match one("stack-args")?.as_str() {
                "natural" => StackArgs::Natural,
                "slots" => StackArgs::Slots,
                s => return Err(format!("{name}: stack-args {s}")),
            },
            variadic: match one("variadic")?.as_str() {
                "stack" => Variadic::Stack,
                "named" => Variadic::Named,
                s => return Err(format!("{name}: variadic {s}")),
            },
            syntax: match one("syntax")?.as_str() {
                "macho" => Syntax::MachO,
                "elf" => Syntax::Elf,
                s => return Err(format!("{name}: syntax {s}")),
            },
            triples: get("triples")?,
        });
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::target::Target;

    #[test]
    fn stack_arguments() {
        let t = Target::aarch64();
        let darwin = t.abi("darwin").unwrap();
        let aapcs = t.abi("aapcs64").unwrap();
        // Eight in registers, then a char, a short, an int and a long.
        let sizes = [8, 8, 8, 8, 8, 8, 8, 8, 1, 2, 4, 8];
        let (d, dn) = darwin.assign(&sizes, sizes.len());
        assert_eq!(&d[8..], &[ArgLoc::Stack(0), ArgLoc::Stack(2), ArgLoc::Stack(4), ArgLoc::Stack(8)]);
        assert_eq!(dn, 16);
        let (a, an) = aapcs.assign(&sizes, sizes.len());
        assert_eq!(&a[8..], &[ArgLoc::Stack(0), ArgLoc::Stack(8), ArgLoc::Stack(16), ArgLoc::Stack(24)]);
        assert_eq!(an, 32);
        // printf("%d %d", a, b): one named argument.
        let (d, _) = darwin.assign(&[8, 4, 4], 1);
        assert_eq!(d, vec![ArgLoc::Reg(0), ArgLoc::Stack(0), ArgLoc::Stack(8)]);
        let (a, _) = aapcs.assign(&[8, 4, 4], 1);
        assert_eq!(a, vec![ArgLoc::Reg(0), ArgLoc::Reg(1), ArgLoc::Reg(2)]);
        assert!(!darwin.caller_saved().contains(&18) && aapcs.caller_saved().contains(&18));
    }
}
