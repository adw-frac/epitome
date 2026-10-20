//! Marking calls `tail`: the half of LLVM's `tailcallelim` that says which
//! calls may reuse the caller's frame. (The other half, a call to the
//! function itself becoming a jump, is in `recursion.rs`.)
//!
//! A `tail` marker promises that the callee does not touch the caller's
//! stack: its allocas, its variable arguments, or the memory of its `byval`
//! parameters. Code generation then makes a call that the function's return
//! follows into a jump. The marker says nothing about where the call is, so
//! any call may have it once the promise holds.
//!
//! The promise is kept here in the simplest way: the function has no
//! allocas, takes no variable arguments and no `byval` parameters. After
//! SROA and mem2reg that is most functions. It also leaves alone calls to
//! `returns_twice` functions (`setjmp`), whose frame must survive, and
//! calls marked `notail` or `musttail`. Each marker is an elective change
//! (autochop).

use epitome_ir::module::*;
use epitome_ir::types::Type;

use crate::attrs;
use crate::ctx::Shared;

/// Marks the calls that may be tail calls. Returns how many it marked.
pub fn run(sh: &Shared, f: &mut Function) -> usize {
    if !f.has_body {
        return 0;
    }
    let m = sh.module;
    if let Type::Function { varargs: true, .. } = sh.ty(f.ty) {
        return 0;
    }
    if f.params.iter().any(|p| attrs::has_named(m, &p.attrs, "byval") || attrs::has_named(m, &p.attrs, "inalloca")) {
        return 0;
    }
    let mut calls = Vec::new();
    for &b in &f.layout {
        for &i in &f.blocks[b.index()].insts {
            match &f.insts[i.index()].op {
                Op::Alloca { .. } | Op::VaArg { .. } => return 0,
                Op::Call(call) if call.tail == TailKind::None => {
                    let twice = attrs::has(m, &call.fn_attrs, "returns_twice")
                        || sh
                            .direct_callee(call)
                            .and_then(|t| sh.published(t))
                            .is_some_and(|t| attrs::has(m, &t.fn_attrs, "returns_twice"));
                    // An argument that is a pointer into this frame would
                    // need an alloca, which there is none of; `byval`
                    // copies are made by the call itself, in the caller's
                    // outgoing area, which a jump cannot keep.
                    let byval = call.args.iter().any(|a| attrs::has_named(m, &a.attrs, "byval"));
                    if !twice && !byval {
                        calls.push(i);
                    }
                }
                _ => {}
            }
        }
    }
    let mut marked = 0;
    for i in calls {
        if !epitome_ir::chop::allow(|| format!("tailmark: {} may be a tail call", epitome_ir::printer::inst_name(f, i)))
        {
            continue;
        }
        if let Op::Call(call) = &mut f.insts[i.index()].op {
            call.tail = TailKind::Tail;
            marked += 1;
        }
    }
    marked
}
