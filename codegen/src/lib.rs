//! Code generation for Smaugian: instruction selection from machine
//! descriptions written in LLVM IR, register allocation, frames, and
//! assembly, binary and disassembly output. See `docs/design/isel.md`.

pub mod asm;
pub mod divconst;
pub mod enc;
pub mod frame;
pub mod isel;
pub mod layout;
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
}

/// Which stages to stop after, for looking at the machine IR.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Default)]
pub enum Stop {
    #[default]
    Done,
    AfterSelection,
    AfterAllocation,
}

pub fn compile(t: &Target, m: &mut Module, stop: Stop) -> Result<Compiled, String> {
    let spec = m.data_layout.as_ref().map(|d| String::from_utf8_lossy(d).into_owned());
    let dl = DataLayout::parse(spec.as_deref().unwrap_or(DARWIN_ARM64_LAYOUT))?;
    let mut cx = Ctx { m, dl: &dl };
    let order = cx.m.global_order.clone();
    let mut funcs = Vec::new();
    for g in order {
        let gl = cx.m.global(g);
        let GlobalKind::Function(f) = &gl.kind else { continue };
        if !f.has_body {
            continue;
        }
        let name = gl.name.clone().unwrap_or_else(|| format!("f{}", g.0));
        let global = !matches!(gl.props.linkage, Linkage::Private | Linkage::Internal);
        let f = (**f).clone();
        let prepared = prepare::prepare(&mut cx, &f, &name)?;
        let mut mf = isel::Sel::new(t, &mut cx, &prepared, &name, global).run()?;
        if stop != Stop::AfterSelection {
            regalloc::allocate(t, &mut mf)?;
            if stop != Stop::AfterAllocation {
                frame::lower(t, &mut mf)?;
                layout::place(t, &mut mf);
            }
        }
        let fi = funcs.len();
        for (k, b) in mf.blocks.iter_mut().enumerate() {
            b.label = format!("LBB{fi}_{k}");
        }
        funcs.push(mf);
    }
    let mut out = String::from("\t.section __TEXT,__text,regular,pure_instructions\n");
    for f in &funcs {
        asm::function(t, f, &mut out);
    }
    asm::globals(&cx, &mut out)?;
    Ok(Compiled { funcs, asm: out })
}
