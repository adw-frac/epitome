//! Assembly output, in the dialect of the platform's assembler (Mach-O or
//! ELF): functions from their machine IR, and global variables as data
//! directives.

use std::fmt::Write;

use smaugian_ir::module::*;
use smaugian_ir::types::{Type, TypeId};

use crate::abi::{Abi, Syntax};
use crate::mir::*;
use crate::prepare::{self, Ctx};
use crate::target::{Target, sext};

pub fn function(t: &Target, f: &MFunc, out: &mut String) {
    let abi = &f.abi;
    let sym = abi.symbol(&f.name);
    let _ = writeln!(out, "\t.p2align 2");
    if f.global {
        let _ = writeln!(out, "\t.globl {sym}");
    }
    if abi.syntax == Syntax::Elf {
        let _ = writeln!(out, "\t.type {sym},%function");
    }
    let _ = writeln!(out, "{sym}:");
    let mut referenced = vec![false; f.blocks.len()];
    for b in &f.blocks {
        for i in &b.insts {
            for op in &i.ops {
                if let MOp::Label(x) = op {
                    referenced[*x] = true;
                }
            }
        }
    }
    for (k, b) in f.blocks.iter().enumerate() {
        if k > 0 && referenced[k] {
            let _ = writeln!(out, "{}:", b.label);
        }
        for i in &b.insts {
            let _ = writeln!(out, "\t{}", format_inst(t, f, i));
        }
    }
    out.push('\n');
}

pub fn globals(cx: &Ctx, abi: &Abi, out: &mut String) -> Result<(), String> {
    let symbol = |n: &str| abi.symbol(n);
    let m = &*cx.m;
    for &g in &m.global_order {
        let gl = m.global(g);
        let GlobalKind::Variable(v) = &gl.kind else { continue };
        let Some(init) = v.init else { continue };
        let name = gl.name.clone().unwrap_or_else(|| format!("g{}", g.0));
        let align = v.align.or_else(|| cx.dl.abi_align(&m.types, v.ty)).unwrap_or(8).max(1);
        let _ = writeln!(out, "\t{}", abi.data_section(v.constant, has_addresses(m, init)));
        if !matches!(gl.props.linkage, Linkage::Private | Linkage::Internal) {
            let _ = writeln!(out, "\t.globl {}", symbol(&name));
        }
        let _ = writeln!(out, "\t.p2align {}", align.trailing_zeros());
        if abi.syntax == Syntax::Elf {
            let _ = writeln!(out, "\t.type {},%object", symbol(&name));
        }
        let _ = writeln!(out, "{}:", symbol(&name));
        data(cx, abi, v.ty, init, out)?;
        out.push('\n');
    }
    Ok(())
}

/// Does constant `c` contain the address of anything?
fn has_addresses(m: &Module, c: ConstId) -> bool {
    match &m.constant(c).kind {
        ConstKind::Global(_)
        | ConstKind::BlockAddress { .. }
        | ConstKind::DsoLocalEquivalent(_)
        | ConstKind::NoCfi(_) => true,
        ConstKind::Array(e) | ConstKind::Struct(e) | ConstKind::Vector(e) => e.iter().any(|&x| has_addresses(m, x)),
        ConstKind::Splat(x) => has_addresses(m, *x),
        ConstKind::Expr(ConstExpr::Cast { value, .. }) => has_addresses(m, *value),
        ConstKind::Expr(ConstExpr::Gep { ptr, .. }) => has_addresses(m, *ptr),
        ConstKind::Expr(_) => true,
        _ => false,
    }
}

fn data(cx: &Ctx, abi: &Abi, ty: TypeId, c: ConstId, out: &mut String) -> Result<(), String> {
    let symbol = |n: &str| abi.symbol(n);
    let m = &*cx.m;
    let size = cx.size_of(ty)?;
    let k = m.constant(c);
    match (&k.kind, m.types.get(ty).clone()) {
        (ConstKind::Zero | ConstKind::Null | ConstKind::Undef | ConstKind::Poison, _) => {
            let _ = writeln!(out, "\t.space {size}");
        }
        (ConstKind::Int(a), Type::Int(bits)) => {
            let v = sext(a.low_u64(), bits) as u64;
            let dir = match size {
                1 => ".byte",
                2 => ".short",
                4 => ".long",
                8 => ".quad",
                _ => return Err(format!("an integer of {size} bytes in data")),
            };
            let mask = if size >= 8 { u64::MAX } else { (1u64 << (size * 8)) - 1 };
            let _ = writeln!(out, "\t{dir} {}", v & mask);
        }
        (ConstKind::Float(bits), _) => {
            let dir = if size == 4 { ".long" } else { ".quad" };
            let _ = writeln!(out, "\t{dir} 0x{:x}", bits);
        }
        (ConstKind::Bytes(bytes), _) => {
            let mut s = String::new();
            for &b in bytes {
                match b {
                    b'"' => s.push_str("\\\""),
                    b'\\' => s.push_str("\\\\"),
                    0x20..=0x7e => s.push(b as char),
                    _ => {
                        let _ = write!(s, "\\{:03o}", b);
                    }
                }
            }
            let _ = writeln!(out, "\t.ascii \"{s}\"");
        }
        (ConstKind::Array(elems) | ConstKind::Vector(elems), Type::Array { elem, .. } | Type::Vector { elem, .. }) => {
            for &e in elems {
                data(cx, abi, elem, e, out)?;
            }
        }
        (ConstKind::Struct(elems), _) => {
            let (fields, packed) = prepare::struct_fields(cx, ty)?;
            let layout = cx.dl.struct_layout(&m.types, &fields, packed).ok_or("struct layout")?;
            let mut at = 0u64;
            for (n, &e) in elems.iter().enumerate() {
                let o = layout.offsets[n];
                if o > at {
                    let _ = writeln!(out, "\t.space {}", o - at);
                }
                data(cx, abi, fields[n], e, out)?;
                at = o + cx.size_of(fields[n])?;
            }
            if layout.size > at {
                let _ = writeln!(out, "\t.space {}", layout.size - at);
            }
        }
        // An integer made a pointer: the integer.
        (ConstKind::Expr(ConstExpr::Cast { op: CastOp::IntToPtr, value }), _)
            if matches!(m.constant(*value).kind, ConstKind::Int(_)) =>
        {
            let ConstKind::Int(a) = &m.constant(*value).kind else { unreachable!() };
            let _ = writeln!(out, "\t.quad {}", a.low_u64());
        }
        _ => match prepare::const_address(cx, c) {
            Some((g, off)) => {
                let name = m.global(g).name.clone().unwrap_or_default();
                if off == 0 {
                    let _ = writeln!(out, "\t.quad {}", symbol(&name));
                } else {
                    let _ = writeln!(out, "\t.quad {}{:+}", symbol(&name), off);
                }
            }
            None => return Err(format!("unsupported constant in data: {:?}", k.kind)),
        },
    }
    Ok(())
}
