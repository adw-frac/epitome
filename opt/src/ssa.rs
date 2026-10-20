//! Putting a function back into SSA form after a variable gains extra
//! definitions.
//!
//! A pass that restructures control flow can leave a value with several
//! definitions, for example the original instruction plus a reload from
//! memory on another path. `SsaUpdater` takes the definitions, block by
//! block, and answers "which value reaches this block?", adding phis where
//! paths with different values meet. It is the on-demand method of Braun
//! et al., "Simple and Efficient Construction of Static Single Assignment
//! Form" (CC 2013), on a complete CFG.
//!
//! A definition is recorded per block and stands for the whole block, so
//! every use in a block with a definition must come after it. Passes keep
//! to this by putting new definitions at the start of fresh blocks.

use crate::fx::{FxHashMap as HashMap, FxHashSet as HashSet};

use epitome_ir::edit::Names;
use epitome_ir::module::*;
use epitome_ir::types::TypeId;

struct Var {
    ty: TypeId,
    name: Option<String>,
    /// The value on paths with no definition, which are unreachable.
    poison: Value,
}

pub struct SsaUpdater {
    preds: Vec<Vec<BlockId>>,
    vars: Vec<Var>,
    defs: HashMap<(usize, BlockId), Value>,
    /// Blocks with a definition of their own, as opposed to a cached
    /// answer.
    own: HashSet<(usize, BlockId)>,
    /// Values at the start of blocks with their own definition.
    entries: HashMap<(usize, BlockId), Value>,
    /// Phis added so far, as (block, instruction).
    pub phis: Vec<(BlockId, InstId)>,
}

impl SsaUpdater {
    /// `preds` must describe the final CFG: the updater adds phis but never
    /// changes control flow.
    pub fn new(preds: Vec<Vec<BlockId>>) -> Self {
        SsaUpdater {
            preds,
            vars: Vec::new(),
            defs: HashMap::default(),
            own: HashSet::default(),
            entries: HashMap::default(),
            phis: Vec::new(),
        }
    }

    pub fn add_var(&mut self, ty: TypeId, name: Option<String>, poison: Value) -> usize {
        self.vars.push(Var { ty, name, poison });
        self.vars.len() - 1
    }

    /// Records that `value` is the definition of `var` in `block`.
    pub fn def(&mut self, var: usize, block: BlockId, value: Value) {
        self.defs.insert((var, block), value);
        self.own.insert((var, block));
    }

    /// The value of `var` at the start of `block`, before any definition
    /// the block makes itself. For a block without one, the same as
    /// `value_at`.
    pub fn value_at_entry(&mut self, f: &mut Function, names: &mut Names, var: usize, block: BlockId) -> Value {
        if !self.own.contains(&(var, block)) {
            return self.value_at(f, names, var, block);
        }
        if let Some(&v) = self.entries.get(&(var, block)) {
            return v;
        }
        let preds = self.preds[block.index()].clone();
        let v = match preds.as_slice() {
            [] => self.vars[var].poison,
            [p] => self.value_at(f, names, var, *p),
            _ => {
                let name = self.vars[var].name.as_ref().map(|n| names.fresh(n));
                let phi = f.add_inst(
                    Op::Phi { fmf: FastMath::default(), incoming: Vec::new() },
                    Some((name, self.vars[var].ty)),
                );
                f.blocks[block.index()].insts.insert(0, phi);
                self.phis.push((block, phi));
                let value = f.result(phi);
                // Before visiting predecessors: a loop back here reads the
                // block's own definition at its end, not this phi.
                self.entries.insert((var, block), value);
                let mut incoming = Vec::new();
                for p in preds {
                    let v = self.value_at(f, names, var, p);
                    let edges = f.successors(p).iter().filter(|&&s| s == block).count().max(1);
                    incoming.extend(std::iter::repeat_n((v, p), edges));
                }
                let Op::Phi { incoming: slot, .. } = &mut f.insts[phi.index()].op else { unreachable!() };
                *slot = incoming;
                value
            }
        };
        self.entries.insert((var, block), v);
        v
    }

    /// The value of `var` at the end of `block`, which is also its value
    /// for any use in `block` after the block's definition.
    pub fn value_at(&mut self, f: &mut Function, names: &mut Names, var: usize, block: BlockId) -> Value {
        // Follow single predecessors until a definition, the entry, or a
        // block where paths meet. A chain that comes back on itself without
        // meeting another path is unreachable.
        let mut chain = Vec::new();
        let mut seen = HashSet::default();
        let mut b = block;
        let v = loop {
            if let Some(&v) = self.defs.get(&(var, b)) {
                break v;
            }
            match self.preds[b.index()].as_slice() {
                [] => break self.vars[var].poison,
                [p] => {
                    if !seen.insert(b) {
                        break self.vars[var].poison;
                    }
                    chain.push(b);
                    b = *p;
                }
                _ => break self.phi(f, names, var, b),
            }
        };
        for c in chain {
            self.defs.insert((var, c), v);
        }
        v
    }

    /// Adds a phi for `var` at the start of `block`, which has several
    /// predecessors, and fills it in.
    fn phi(&mut self, f: &mut Function, names: &mut Names, var: usize, block: BlockId) -> Value {
        let name = self.vars[var].name.as_ref().map(|n| names.fresh(n));
        let phi =
            f.add_inst(Op::Phi { fmf: FastMath::default(), incoming: Vec::new() }, Some((name, self.vars[var].ty)));
        f.blocks[block.index()].insts.insert(0, phi);
        self.phis.push((block, phi));
        let value = f.result(phi);
        // Record the phi before visiting predecessors, so a loop back to
        // this block finds it.
        self.defs.insert((var, block), value);
        // One entry per edge: a switch may reach this block more than once.
        let preds = self.preds[block.index()].clone();
        let mut incoming: Vec<(Value, BlockId)> = Vec::new();
        for p in preds {
            let v = self.value_at(f, names, var, p);
            let edges = f.successors(p).iter().filter(|&&s| s == block).count().max(1);
            incoming.extend(std::iter::repeat_n((v, p), edges));
        }
        let Op::Phi { incoming: slot, .. } = &mut f.insts[phi.index()].op else { unreachable!() };
        *slot = incoming;
        value
    }

    /// The value of `var` at the end of `block` if it is already known
    /// without adding phis.
    pub fn peek(&self, var: usize, mut block: BlockId) -> Option<Value> {
        for _ in 0..=self.preds.len() {
            if let Some(&v) = self.defs.get(&(var, block)) {
                return Some(v);
            }
            match self.preds[block.index()].as_slice() {
                [p] => block = *p,
                _ => return None,
            }
        }
        None
    }
}

/// Removes phis whose entries all hold the same value (ignoring the phi
/// itself), replacing their uses with that value, until none are left.
/// Only the phis in `candidates` are considered. Returns the replacements
/// made, so callers can update references held elsewhere.
pub fn remove_trivial_phis(f: &mut Function, candidates: &[(BlockId, InstId)]) -> HashMap<LocalId, Value> {
    let mut replaced: HashMap<LocalId, Value> = HashMap::default();
    let mut live: Vec<(BlockId, InstId)> = candidates.to_vec();
    loop {
        let mut changed = false;
        let mut keep = Vec::new();
        for &(b, i) in &live {
            let me = f.result(i);
            let Op::Phi { incoming, .. } = &f.insts[i.index()].op else { unreachable!() };
            let mut same: Option<Value> = None;
            let mut trivial = true;
            for (v, _) in incoming {
                if *v == me || Some(*v) == same {
                    continue;
                }
                if same.is_some() {
                    trivial = false;
                    break;
                }
                same = Some(*v);
            }
            match (trivial, same) {
                (true, Some(v)) => {
                    f.blocks[b.index()].insts.retain(|&x| x != i);
                    f.replace_uses(me, v);
                    let Value::Local(l) = me else { unreachable!() };
                    for r in replaced.values_mut() {
                        if *r == me {
                            *r = v;
                        }
                    }
                    replaced.insert(l, v);
                    changed = true;
                }
                _ => keep.push((b, i)),
            }
        }
        live = keep;
        if !changed {
            break;
        }
    }
    replaced
}
