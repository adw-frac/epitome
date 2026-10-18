//! Promoting allocas to SSA values.
//!
//! Front ends give each local variable a stack slot and turn every read
//! and write into a load or store. This pass turns such a variable back
//! into SSA values: each store becomes a definition, each load becomes a
//! use of the definition that reaches it, and phis appear where paths with
//! different definitions meet. The alloca, its loads and its stores go.
//!
//! An alloca is promoted when it is in the entry block, holds one value,
//! and is only used by plain (not volatile, not atomic) loads and stores of
//! its own type through the alloca itself, and by lifetime markers. Any
//! other use (an offset, a call, a store of the address) could let memory
//! be reached some other way, so the alloca stays. `sroa` will split
//! aggregates so more of them qualify.
//!
//! The work is done by `ssa::SsaUpdater`. Each block's last store is the
//! variable's definition at the end of that block. A load takes the latest
//! store before it in its block, or else the value at the block's entry.
//! A path with no store gives `undef`, which is what a load from
//! uninitialised memory gives.
//!
//! A `#dbg_declare` of a promoted alloca becomes a `#dbg_value` after each
//! store. (**Open:** also at the phis the pass adds, as the variable's value
//! changes there too.)

use crate::fx::FxHashMap as HashMap;

use draconian_ir::edit::Names;
use draconian_ir::module::*;
use draconian_ir::types::TypeId;

use crate::ctx::Shared;
use crate::ssa::{self, SsaUpdater};

#[derive(Default, Debug, Clone, Copy)]
pub struct Stats {
    pub promoted: usize,
    pub loads: usize,
    pub stores: usize,
}

fn is_lifetime(sh: &Shared, call: &Call) -> bool {
    sh.direct_callee(call)
        .and_then(|g| sh.module.global(g).name.as_deref())
        .is_some_and(|n| n.starts_with("llvm.lifetime."))
}

fn value_type(sh: &Shared, f: &Function, v: Value) -> Option<TypeId> {
    match v {
        Value::Local(l) => Some(f.locals[l.index()].ty),
        Value::Const(c) => Some(sh.consts().get(c).ty),
        Value::Metadata(_) => None,
    }
}

/// Runs mem2reg on one function.
pub fn run(sh: &Shared, f: &mut Function) -> Stats {
    let mut stats = Stats::default();
    if !f.has_body {
        return stats;
    }
    let entry = f.entry();
    let mut users: HashMap<LocalId, Vec<InstId>> = HashMap::default();
    for i in f.insts_in_order() {
        f.insts[i.index()].op.for_each_value(|v| {
            if let Value::Local(l) = v {
                users.entry(*l).or_default().push(i);
            }
        });
    }

    // The allocas to promote, and their variable numbers.
    let mut var_of: HashMap<LocalId, usize> = HashMap::default();
    let mut allocas: Vec<(InstId, LocalId, TypeId)> = Vec::new();
    for &i in &f.blocks[entry.index()].insts {
        let Op::Alloca { inalloca: false, ty, count, addrspace, .. } = f.insts[i.index()].op else { continue };
        let single = match count {
            None => true,
            Some(Value::Const(c)) => {
                crate::combine::eval::int_const(sh.consts(), sh.types(), c).is_some_and(|k| k.value == 1)
            }
            _ => false,
        };
        if !single || addrspace.is_some_and(|a| a != 0) {
            continue;
        }
        let a = f.insts[i.index()].result.unwrap();
        let me = Value::Local(a);
        let ok = users.get(&a).map(|v| v.as_slice()).unwrap_or(&[]).iter().all(|&u| {
            let inst = &f.insts[u.index()];
            match &inst.op {
                Op::Load { volatile: false, atomic: None, ptr, .. } => {
                    *ptr == me && inst.result.is_some_and(|r| f.locals[r.index()].ty == ty)
                }
                Op::Store { volatile: false, atomic: None, ptr, value, .. } => {
                    *ptr == me && *value != me && value_type(sh, f, *value) == Some(ty)
                }
                Op::Call(call) => is_lifetime(sh, call),
                _ => false,
            }
        });
        if ok {
            var_of.insert(a, allocas.len());
            allocas.push((i, a, ty));
        }
    }
    if allocas.is_empty() {
        return stats;
    }
    // The allocas go, so their names are free for the values that replace
    // them.
    let mut up = SsaUpdater::new(f.predecessors());
    for &(_, a, ty) in &allocas {
        let name = f.locals[a.index()].name.take();
        up.add_var(ty, name, sh.undef(ty));
    }
    let mut names = Names::new(f);
    let promoted = |v: Value| match v {
        Value::Local(l) => var_of.get(&l).copied(),
        _ => None,
    };

    // Each block's last store defines the variable at the block's end.
    let layout = f.layout.clone();
    for &b in &layout {
        let mut last: HashMap<usize, Value> = HashMap::default();
        for &i in &f.blocks[b.index()].insts {
            if let Op::Store { ptr, value, .. } = f.insts[i.index()].op
                && let Some(var) = promoted(ptr)
            {
                last.insert(var, value);
            }
        }
        for (var, v) in last {
            up.def(var, b, v);
        }
    }

    // `#dbg_declare` records of promoted allocas: (variable, expression,
    // location) to describe each stored value with.
    let mut declared: HashMap<usize, (MdId, MdId, MdId)> = HashMap::default();
    for i in f.insts_in_order() {
        for r in &f.insts[i.index()].debug_records {
            if r.kind == "declare"
                && r.args.len() == 4
                && let Metadata::Value(v) = sh.metadata()[r.args[0].index()].data
                && let Some(var) = promoted(v)
            {
                declared.insert(var, (r.args[1], r.args[2], r.args[3]));
            }
        }
    }

    // Rewrite each block in order.
    let mut map: HashMap<LocalId, Value> = HashMap::default();
    let mut erased = vec![false; f.insts.len()];
    for &(i, _, _) in &allocas {
        erased[i.index()] = true;
    }
    for &b in &layout {
        let mut current: HashMap<usize, Value> = HashMap::default();
        let mut pending: Vec<DebugRecord> = Vec::new();
        let insts = f.blocks[b.index()].insts.clone();
        for i in insts {
            // The updater adds phis as it goes, here and in other blocks.
            erased.resize(f.insts.len(), false);
            let op = f.insts[i.index()].op.clone();
            match op {
                Op::Store { ptr, value, .. } if promoted(ptr).is_some() => {
                    let var = promoted(ptr).unwrap();
                    current.insert(var, value);
                    erased[i.index()] = true;
                    stats.stores += 1;
                    if let Some(&(variable, expr, loc)) = declared.get(&var) {
                        pending.push(DebugRecord {
                            kind: "value".into(),
                            args: vec![sh.md_value(value), variable, expr, loc],
                        });
                    }
                }
                Op::Load { ptr, .. } if promoted(ptr).is_some() => {
                    let var = promoted(ptr).unwrap();
                    let v = match current.get(&var) {
                        Some(&v) => v,
                        None => up.value_at_entry(f, &mut names, var, b),
                    };
                    map.insert(f.insts[i.index()].result.unwrap(), v);
                    erased[i.index()] = true;
                    stats.loads += 1;
                }
                Op::Call(call) if is_lifetime(sh, &call) && call.args.iter().any(|a| promoted(a.value).is_some()) => {
                    erased[i.index()] = true;
                }
                _ => {}
            }
            // Records on erased instructions, and the new `#dbg_value`s,
            // go to the next instruction that stays.
            let records = std::mem::take(&mut f.insts[i.index()].debug_records);
            let kept: Vec<DebugRecord> = records
                .into_iter()
                .filter(|r| {
                    let declares_promoted = r.kind == "declare"
                        && r.args.first().is_some_and(
                            |a| matches!(sh.metadata()[a.index()].data, Metadata::Value(v) if promoted(v).is_some()),
                        );
                    !declares_promoted
                })
                .collect();
            if erased[i.index()] {
                pending.extend(kept);
            } else {
                let mut all = std::mem::take(&mut pending);
                all.extend(kept);
                f.insts[i.index()].debug_records = all;
            }
        }
    }
    stats.promoted = allocas.len();

    // Put the blocks right, then send every use through the replacements.
    let resolve = |mut v: Value| {
        while let Value::Local(l) = v {
            match map.get(&l) {
                Some(&next) => v = next,
                None => break,
            }
        }
        v
    };
    erased.resize(f.insts.len(), false);
    for &b in &layout {
        f.blocks[b.index()].insts.retain(|i| !erased[i.index()]);
    }
    for i in f.insts_in_order().collect::<Vec<_>>() {
        f.insts[i.index()].op.for_each_value_mut(|v| *v = resolve(*v));
    }
    let replaced = ssa::remove_trivial_phis(f, &up.phis);

    // Debug records follow the values; ones about promoted allocas, or
    // values that went away, become `poison`.
    let final_value = |v: Value| -> Value {
        let mut v = resolve(v);
        while let Value::Local(l) = v {
            match replaced.get(&l) {
                Some(&n) if n != v => v = resolve(n),
                _ => break,
            }
        }
        v
    };
    let mut changes = Vec::new();
    for i in f.insts_in_order() {
        for (k, r) in f.insts[i.index()].debug_records.iter().enumerate() {
            for (j, &arg) in r.args.iter().enumerate() {
                let Metadata::Value(v @ Value::Local(_)) = sh.metadata()[arg.index()].data else { continue };
                let new = if promoted(v).is_some() {
                    let Value::Local(l) = v else { unreachable!() };
                    sh.poison(f.locals[l.index()].ty)
                } else {
                    final_value(v)
                };
                if new != v {
                    changes.push((i, k, j, new));
                }
            }
        }
    }
    for (i, k, j, v) in changes {
        f.insts[i.index()].debug_records[k].args[j] = sh.md_value(v);
    }
    stats
}
