//! Calls on constants, worked out: a call whose arguments are all integer
//! constants, to a function whose body is known and final, is followed
//! through that body with the constants. If the path it takes reaches a
//! `ret` within `BUDGET` instructions, computing only integers (arithmetic,
//! comparisons, selects, casts, phis, branches), the call does nothing but
//! return that value: it becomes the constant, or goes if it returns
//! nothing. Any other instruction on the path (a load, a store, another
//! call), or a result that would be poison or undefined, leaves the call.
//!
//! The function may be the caller itself: `twist(0, 0, 0, 0)` inside
//! `twist` returns at once. This is the part of LLVM's interprocedural
//! constant propagation that needs no analysis of the whole module. Each
//! replacement is an elective change (autochop).

use epitome_ir::module::*;
use epitome_ir::types::Type;

use crate::attrs;
use crate::combine::eval::{self, Folded};
use crate::ctx::Shared;

/// The most instructions followed for one call.
const BUDGET: usize = 256;

/// Replaces the calls on constants that can be worked out; returns how
/// many.
pub fn run(sh: &Shared, g: GlobalId, f: &mut Function) -> usize {
    if !f.has_body {
        return 0;
    }
    let mut found: Vec<(BlockId, InstId, Option<u64>)> = Vec::new();
    for &b in &f.layout {
        for &i in &f.blocks[b.index()].insts {
            let Op::Call(call) = &f.insts[i.index()].op else { continue };
            let Some(callee) = sh.direct_callee(call) else { continue };
            if call.args.iter().any(|a| !matches!(a.value, Value::Const(_))) {
                continue;
            }
            let global = sh.module.global(callee);
            if !attrs::definition_is_final(global.props.linkage) {
                continue;
            }
            let body: &Function = if callee == g {
                f
            } else {
                match sh.published(callee) {
                    Some(b) if b.has_body => b,
                    _ => continue,
                }
            };
            let args: Option<Vec<u64>> = call
                .args
                .iter()
                .map(|a| match a.value {
                    Value::Const(c) => eval::int_const(sh.consts(), sh.types(), c).map(|k| k.value),
                    _ => None,
                })
                .collect();
            let Some(args) = args else { continue };
            if args.len() != body.params.len() {
                continue;
            }
            if let Some(result) = follow(sh, body, &args) {
                found.push((b, i, result));
            }
        }
    }
    let mut done = 0;
    for (b, i, result) in found {
        if !epitome_ir::chop::allow(|| {
            format!("constcall: {} worked out", epitome_ir::printer::inst_name(f, i))
        }) {
            continue;
        }
        if let Some(r) = f.insts[i.index()].result {
            let ty = f.locals[r.index()].ty;
            let Some(bits) = eval::int_bits(sh.types(), ty) else { continue };
            let Some(v) = result else { continue };
            f.replace_uses(Value::Local(r), sh.int(bits, eval::sext(v, bits)));
        }
        f.blocks[b.index()].insts.retain(|&x| x != i);
        done += 1;
    }
    done
}

/// Follows `f` with these arguments: `Some(value)` if it returns within the
/// budget having only computed integers (`Some(None)` for `ret void`).
fn follow(sh: &Shared, f: &Function, args: &[u64]) -> Option<Option<u64>> {
    let mut vals: Vec<Option<u64>> = vec![None; f.locals.len()];
    for (p, &a) in f.params.iter().zip(args) {
        vals[p.local.index()] = Some(a);
    }
    let bits_of = |ty| match sh.types().get(ty) {
        Type::Int(b) if *b <= 64 => Some(*b),
        _ => None,
    };
    let get = |vals: &[Option<u64>], v: Value| -> Option<u64> {
        match v {
            Value::Local(l) => vals[l.index()],
            Value::Const(c) => eval::int_const(sh.consts(), sh.types(), c).map(|k| k.value),
            _ => None,
        }
    };
    let mut block = f.entry();
    let mut prev: Option<BlockId> = None;
    let mut steps = 0;
    loop {
        let insts = &f.blocks[block.index()].insts;
        // Phis read the values from before the block, all at once.
        let mut phis = Vec::new();
        for &i in insts {
            let Op::Phi { incoming, .. } = &f.insts[i.index()].op else { break };
            let from = prev?;
            let v = incoming.iter().find(|(_, b)| *b == from).map(|(v, _)| *v)?;
            phis.push((f.insts[i.index()].result?, get(&vals, v)?));
        }
        for (r, v) in phis {
            vals[r.index()] = Some(v);
        }
        for &i in insts {
            steps += 1;
            if steps > BUDGET {
                return None;
            }
            let inst = &f.insts[i.index()];
            let result = |vals: &mut Vec<Option<u64>>, v: u64| {
                if let Some(r) = inst.result {
                    vals[r.index()] = Some(v);
                }
            };
            match &inst.op {
                Op::Phi { .. } => {}
                Op::Binary { op, flags, lhs, rhs, .. } => {
                    let bits = bits_of(f.locals[inst.result?.index()].ty)?;
                    let (a, b) = (get(&vals, *lhs)?, get(&vals, *rhs)?);
                    match eval::fold_binop(*op, *flags, a, b, bits)? {
                        Folded::Int(v) => result(&mut vals, v),
                        Folded::Poison => return None,
                    }
                }
                Op::ICmp { pred, lhs, rhs, .. } => {
                    let ty = match lhs {
                        Value::Local(l) => f.locals[l.index()].ty,
                        Value::Const(c) => sh.consts().get(*c).ty,
                        _ => return None,
                    };
                    let bits = bits_of(ty)?;
                    let (a, b) = (get(&vals, *lhs)?, get(&vals, *rhs)?);
                    result(&mut vals, eval::fold_icmp(*pred, a, b, bits) as u64);
                }
                Op::Select { cond, then_value, else_value, .. } => {
                    let c = get(&vals, *cond)?;
                    let v = get(&vals, if c & 1 != 0 { *then_value } else { *else_value })?;
                    result(&mut vals, v);
                }
                Op::Cast { op, flags, value, .. } => {
                    let from = match value {
                        Value::Local(l) => bits_of(f.locals[l.index()].ty)?,
                        Value::Const(c) => bits_of(sh.consts().get(*c).ty)?,
                        _ => return None,
                    };
                    let to = bits_of(f.locals[inst.result?.index()].ty)?;
                    match eval::fold_cast(*op, *flags, get(&vals, *value)?, from, to)? {
                        Folded::Int(v) => result(&mut vals, v),
                        Folded::Poison => return None,
                    }
                }
                Op::Br(next) => {
                    prev = Some(block);
                    block = *next;
                    break;
                }
                Op::CondBr { cond, then_dest, else_dest } => {
                    let c = get(&vals, *cond)?;
                    prev = Some(block);
                    block = if c & 1 != 0 { *then_dest } else { *else_dest };
                    break;
                }
                Op::Ret(None) => return Some(None),
                Op::Ret(Some(v)) => return Some(Some(get(&vals, *v)?)),
                _ => return None,
            }
        }
    }
}
