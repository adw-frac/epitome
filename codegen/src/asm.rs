//! Assembly output, in the dialect of the platform's assembler (Mach-O or
//! ELF): functions from their machine IR, and global variables as data
//! directives, from the same description of them (`object::GlobalData`)
//! that object files are written from.

use std::fmt::Write;

use epitome_ir::module::*;
use epitome_ir::types::{Type, TypeId};

use crate::abi::{Abi, Syntax};
use crate::mir::*;
use crate::object::{GlobalData, Item, SectionKind};
use crate::prepare::{self, Ctx};
use crate::target::{Target, sext};

/// Writes function `f`, the `index`th, with its exception table if it has
/// landing pads.
pub fn function(t: &Target, f: &MFunc, index: usize, out: &mut String) -> Result<(), String> {
    let abi = &f.abi;
    let sym = abi.symbol(&f.name);
    let table = crate::eh::lsda(t, f, abi.syntax, &|n| abi.symbol(n))?;
    let table_label = format!("{}exception{index}", abi.local_prefix());
    let _ = writeln!(out, "\t.p2align 2");
    if f.global {
        let _ = writeln!(out, "\t.globl {sym}");
    }
    if abi.syntax == Syntax::Elf {
        let _ = writeln!(out, "\t.type {sym},%function");
    }
    let _ = writeln!(out, "{sym}:");
    let _ = writeln!(out, "\t.cfi_startproc");
    if let (Some(eh), Some(_)) = (&f.eh, &table) {
        // Indirect, PC-relative, 4 bytes; and PC-relative.
        let _ = writeln!(out, "\t.cfi_personality 155, {}", abi.symbol(&eh.personality));
        let _ = writeln!(out, "\t.cfi_lsda 16, {table_label}");
    }
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
    let _ = writeln!(out, "\t.cfi_endproc");
    if abi.syntax == Syntax::Elf {
        let _ = writeln!(out, "\t.size {sym}, .-{sym}");
    }
    if let Some(table) = table {
        // The table's bytes, its references to types through the GOT each
        // relative to a label at it.
        let _ = writeln!(out, "\t{}", abi.section_directive(SectionKind::ExceptTable));
        let _ = writeln!(out, "\t.p2align 2");
        // A symbol at it too, for the unwind tables to name.
        let _ = writeln!(out, "GCC_except_table{index}:\n{table_label}:");
        let mut at = 0;
        let mut refs = table.got_refs.iter().peekable();
        let mut n = 0;
        while at < table.bytes.len() {
            if let Some((off, name)) = refs.next_if(|r| r.0 as usize == at) {
                let l = format!("{}ttype{index}_{n}", abi.local_prefix());
                n += 1;
                let _ = writeln!(out, "{l}:\n\t.long {name}@GOT-{l}");
                at = *off as usize + 4;
                continue;
            }
            let end = refs.peek().map_or(table.bytes.len(), |r| r.0 as usize).min(at + 16);
            let list: Vec<String> = table.bytes[at..end].iter().map(|b| b.to_string()).collect();
            let _ = writeln!(out, "\t.byte {}", list.join(", "));
            at = end;
        }
        let _ = writeln!(out, "\t{}", abi.section_directive(SectionKind::Text));
    }
    out.push('\n');
    Ok(())
}

/// The globals with initial values, in module order, as data.
pub fn collect_globals(cx: &Ctx, abi: &Abi) -> Result<Vec<GlobalData>, String> {
    let m = &*cx.m;
    let mut out = Vec::new();
    for &g in &m.global_order {
        let gl = m.global(g);
        let GlobalKind::Variable(v) = &gl.kind else { continue };
        let Some(init) = v.init else { continue };
        let name = gl.name.clone().unwrap_or_else(|| format!("g{}", g.0));
        let align = v.align.or_else(|| cx.dl.abi_align(&m.types, v.ty)).unwrap_or(8).max(1);
        let mut items = Vec::new();
        data(cx, abi, v.ty, init, &mut items)?;
        let zero = items.iter().all(|i| matches!(i, Item::Zero(_)));
        let section = match (v.constant, has_addresses(m, init)) {
            // Zeros are only counted, where the format has a section for
            // that which assembly can name simply.
            (false, _) if zero && abi.syntax == Syntax::Elf => SectionKind::Bss,
            (false, _) => SectionKind::Data,
            (true, false) => SectionKind::ReadOnly,
            (true, true) => SectionKind::RelRo,
        };
        out.push(GlobalData {
            symbol: abi.symbol(&name),
            global: !matches!(gl.props.linkage, Linkage::Private | Linkage::Internal),
            section,
            align,
            items,
        });
    }
    Ok(out)
}

pub fn print_globals(abi: &Abi, globals: &[GlobalData], out: &mut String) {
    for g in globals {
        let _ = writeln!(out, "\t{}", abi.section_directive(g.section));
        if g.global {
            let _ = writeln!(out, "\t.globl {}", g.symbol);
        }
        let _ = writeln!(out, "\t.p2align {}", g.align.trailing_zeros());
        if abi.syntax == Syntax::Elf {
            let _ = writeln!(out, "\t.type {},%object", g.symbol);
        }
        let _ = writeln!(out, "{}:", g.symbol);
        for item in &g.items {
            match item {
                Item::Int { size, value, hex } => {
                    let dir = match size {
                        1 => ".byte",
                        2 => ".short",
                        4 => ".long",
                        _ => ".quad",
                    };
                    if *hex {
                        let _ = writeln!(out, "\t{dir} 0x{value:x}");
                    } else {
                        let _ = writeln!(out, "\t{dir} {value}");
                    }
                }
                Item::Bytes(bytes) => {
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
                Item::Zero(n) => {
                    let _ = writeln!(out, "\t.space {n}");
                }
                Item::Addr { symbol, offset: 0 } => {
                    let _ = writeln!(out, "\t.quad {symbol}");
                }
                Item::Addr { symbol, offset } => {
                    let _ = writeln!(out, "\t.quad {symbol}{offset:+}");
                }
            }
        }
        if abi.syntax == Syntax::Elf {
            let _ = writeln!(out, "\t.size {}, {}", g.symbol, g.size());
        }
        out.push('\n');
    }
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

fn data(cx: &Ctx, abi: &Abi, ty: TypeId, c: ConstId, out: &mut Vec<Item>) -> Result<(), String> {
    let m = &*cx.m;
    let size = cx.size_of(ty)?;
    let k = m.constant(c);
    match (&k.kind, m.types.get(ty).clone()) {
        (ConstKind::Zero | ConstKind::Null | ConstKind::Undef | ConstKind::Poison, _) => out.push(Item::Zero(size)),
        (ConstKind::Int(a), Type::Int(bits)) => {
            if !matches!(size, 1 | 2 | 4 | 8) {
                return Err(format!("an integer of {size} bytes in data"));
            }
            let v = sext(a.low_u64(), bits) as u64;
            let mask = if size >= 8 { u64::MAX } else { (1u64 << (size * 8)) - 1 };
            out.push(Item::Int { size: size as u8, value: v & mask, hex: false });
        }
        (ConstKind::Float(bits), _) => {
            if !matches!(size, 2 | 4 | 8) {
                return Err(format!("a floating-point value of {size} bytes in data"));
            }
            out.push(Item::Int { size: size as u8, value: *bits as u64, hex: true });
        }
        (ConstKind::Bytes(bytes), _) => out.push(Item::Bytes(bytes.clone())),
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
                    out.push(Item::Zero(o - at));
                }
                data(cx, abi, fields[n], e, out)?;
                at = o + cx.size_of(fields[n])?;
            }
            if layout.size > at {
                out.push(Item::Zero(layout.size - at));
            }
        }
        // An integer made a pointer: the integer.
        (ConstKind::Expr(ConstExpr::Cast { op: CastOp::IntToPtr, value }), _)
            if matches!(m.constant(*value).kind, ConstKind::Int(_)) =>
        {
            let ConstKind::Int(a) = &m.constant(*value).kind else { unreachable!() };
            out.push(Item::Int { size: 8, value: a.low_u64(), hex: false });
        }
        _ => match prepare::const_address(cx, c) {
            Some((g, offset)) => {
                let name = m.global(g).name.clone().unwrap_or_default();
                out.push(Item::Addr { symbol: abi.symbol(&name), offset });
            }
            None => return Err(format!("unsupported constant in data: {:?}", k.kind)),
        },
    }
    Ok(())
}
