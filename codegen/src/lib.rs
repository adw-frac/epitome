//! Code generation for Smaugian: instruction selection from machine
//! descriptions written in LLVM IR, register allocation, frames, and
//! assembly, binary and disassembly output. See `docs/design/isel.md`.

pub mod abi;
pub mod asm;
pub mod divconst;
pub mod enc;
pub mod frame;
pub mod isel;
pub mod layout;
pub mod legalize;
pub mod mir;
pub mod prepare;
pub mod regalloc;
pub mod target;

use smaugian_ir::Module;
use smaugian_ir::layout::DataLayout;
use smaugian_ir::module::*;

use crate::mir::MFunc;
use crate::prepare::Ctx;
use crate::target::Target;

/// The default data layout for arm64 Darwin, when a module has none.
pub const DARWIN_ARM64_LAYOUT: &str = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32";

pub struct Compiled {
    pub funcs: Vec<MFunc>,
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
    let mut cx = Ctx { m, dl: &dl };
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
    let mut out = format!("\t{}\n", abi.text_section());
    for f in &funcs {
        asm::function(t, f, &mut out);
    }
    asm::globals(&cx, &abi, &mut out)?;
    Ok(Compiled { funcs, asm: out, errors })
}
