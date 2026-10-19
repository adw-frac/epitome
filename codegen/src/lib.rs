//! Code generation for Draconian: instruction selection from machine
//! descriptions written in LLVM IR, register allocation, frames, and
//! assembly, binary and disassembly output. See `docs/design/isel.md`.

pub mod abi;
pub mod asm;
pub mod assembler;
pub mod divconst;
pub mod elf;
pub mod enc;
pub mod features;
pub mod frame;
pub mod isel;
pub mod layout;
pub mod legalize;
pub mod machine;
pub mod macho;
pub mod mir;
pub mod objdump;
pub mod object;
pub mod prepare;
pub mod regalloc;
pub mod target;

use draconian_ir::Module;
use draconian_ir::layout::DataLayout;
use draconian_ir::module::*;

use crate::mir::MFunc;
use crate::prepare::Ctx;
use crate::target::Target;

/// The default data layout for arm64 Darwin, when a module has none.
pub const DARWIN_ARM64_LAYOUT: &str = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32";

pub struct Compiled {
    pub funcs: Vec<MFunc>,
    /// The globals with initial values.
    pub globals: Vec<object::GlobalData>,
    pub abi: abi::Abi,
    /// For Mach-O: the least macOS version the code is for, from the
    /// module's triple (`arm64-apple-macosx26.0.0`), else 11.0.
    pub min_os: (u32, u32, u32),
    pub asm: String,
    /// With `keep_going`: the functions that could not be compiled, and why.
    pub errors: Vec<String>,
}

/// Which stages to stop after, for looking at the machine IR.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Default)]
pub enum Stop {
    #[default]
    Done,
    AfterSelection,
    AfterAllocation,
}

#[derive(Clone, Debug, Default)]
pub struct Options {
    pub stop: Stop,
    /// The calling convention and platform, by name; by default, the one
    /// the module's target triple names, or else `darwin`.
    pub abi: Option<String>,
    /// Further registers to keep out of allocation.
    pub reserve: Vec<u8>,
    /// The assembler dialect, if not the convention's own.
    pub syntax: Option<abi::Syntax>,
    /// Report each function that cannot be compiled, and carry on with the
    /// rest, instead of stopping at the first.
    pub keep_going: bool,
    /// The CPU, as the description names it; by default the one each
    /// function's IR names, or the description's.
    pub mcpu: Option<String>,
    /// Features turned on or off: `+neon`, `-lse`, or lists of them.
    pub mattr: Vec<String>,
}

/// The convention `opts` asks for, for module `m`.
pub fn choose_abi(t: &Target, m: &Module, opts: &Options) -> Result<abi::Abi, String> {
    let triple = m.triple.as_ref().map(|s| String::from_utf8_lossy(s).into_owned()).unwrap_or_default();
    let mut abi = match &opts.abi {
        Some(name) => t.abi(name).ok_or_else(|| format!("no calling convention {name}"))?,
        None => t.abi_for_triple(&triple).or_else(|| t.abi("darwin")).ok_or("no calling convention")?,
    }
    .clone();
    abi.reserved.extend(&opts.reserve);
    if let Some(s) = opts.syntax {
        abi.syntax = s;
    }
    Ok(abi)
}

pub fn compile(t: &Target, m: &mut Module, opts: &Options) -> Result<Compiled, String> {
    let stop = opts.stop;
    let abi = choose_abi(t, m, opts)?;
    let spec = m.data_layout.as_ref().map(|d| String::from_utf8_lossy(d).into_owned());
    let dl = DataLayout::parse(spec.as_deref().unwrap_or(DARWIN_ARM64_LAYOUT))?;
    let mut cx = Ctx { m, dl: &dl, t, features: Default::default() };
    let order = cx.m.global_order.clone();
    let mut funcs = Vec::new();
    let mut errors = Vec::new();
    for g in order {
        let gl = cx.m.global(g);
        let GlobalKind::Function(f) = &gl.kind else { continue };
        if !f.has_body {
            continue;
        }
        let name = gl.name.clone().unwrap_or_else(|| format!("f{}", g.0));
        let global = !matches!(gl.props.linkage, Linkage::Private | Linkage::Internal);
        let f = (**f).clone();
        cx.features = features::of_function(t, cx.m, &f.fn_attrs, opts.mcpu.as_deref(), &opts.mattr)?;
        let one = |cx: &mut Ctx| -> Result<MFunc, String> {
            let prepared = prepare::prepare(cx, &f, &name)?;
            let mut mf = isel::Sel::new(t, &abi, cx, &prepared, &name, global).run()?;
            if stop != Stop::AfterSelection {
                regalloc::allocate(t, &mut mf)?;
                if stop != Stop::AfterAllocation {
                    frame::lower(t, &mut mf)?;
                    layout::place(t, &mut mf);
                    layout::relax(t, &mut mf);
                }
            }
            Ok(mf)
        };
        let mut mf = match one(&mut cx) {
            Ok(mf) => mf,
            Err(e) if opts.keep_going => {
                errors.push(e);
                continue;
            }
            Err(e) => return Err(e),
        };
        let fi = funcs.len();
        for (k, b) in mf.blocks.iter_mut().enumerate() {
            b.label = format!("{}BB{fi}_{k}", abi.local_prefix());
        }
        funcs.push(mf);
    }
    let min_os = min_os_version(&String::from_utf8_lossy(cx.m.triple.as_deref().unwrap_or_default()));
    let mut out = String::new();
    if abi.syntax == abi::Syntax::MachO {
        let (a, b, c) = min_os;
        let update = if c == 0 { String::new() } else { format!(", {c}") };
        out.push_str(&format!("\t.build_version macos, {a}, {b}{update}\n"));
    }
    out.push_str(&format!("\t{}\n", abi.section_directive(object::SectionKind::Text)));
    for f in &funcs {
        asm::function(t, f, &mut out);
    }
    let globals = asm::collect_globals(&cx, &abi)?;
    asm::print_globals(&abi, &globals, &mut out);
    if abi.syntax == abi::Syntax::Elf {
        // The stack need not be executable.
        out.push_str("\t.section .note.GNU-stack,\"\",%progbits\n");
    }
    Ok(Compiled { funcs, globals, abi, min_os, asm: out, errors })
}

/// The macOS version a triple names (`macosx26.0.0`, `macos14.2`), or 11.0,
/// the first for arm64.
pub fn min_os_version(triple: &str) -> (u32, u32, u32) {
    let rest = triple.split('-').find_map(|p| p.strip_prefix("macosx").or_else(|| p.strip_prefix("macos")));
    let mut parts = rest.unwrap_or("").split('.').map(|x| x.parse::<u32>().ok());
    match (parts.next().flatten(), parts.next().flatten(), parts.next().flatten()) {
        (Some(a), b, c) if a > 0 => (a, b.unwrap_or(0), c.unwrap_or(0)),
        _ => (11, 0, 0),
    }
}

impl Compiled {
    /// The object file's contents, in the abstract (see `object`).
    pub fn object(&self, t: &Target) -> Result<object::Object, String> {
        object::build(t, &self.abi, &self.funcs, &self.globals)
    }

    /// The object file, in the convention's format: ELF or Mach-O.
    pub fn object_file(&self, t: &Target) -> Result<Vec<u8>, String> {
        let obj = self.object(t)?;
        match self.abi.syntax {
            abi::Syntax::Elf => elf::write(&obj, &t.machine),
            abi::Syntax::MachO => macho::write(&obj, self.min_os, &t.machine),
        }
    }
}
