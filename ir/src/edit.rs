//! Helpers for passes that change a function: operand visitors, and adding
//! locals, blocks and instructions.
//!
//! Instructions, locals and blocks are never removed from their tables. A
//! pass deletes an instruction by taking it out of its block's list and
//! deletes a block by taking it out of `layout`. The printer and the
//! analyses only look at what is reachable from `layout`.

use std::collections::HashSet;

use crate::module::*;
use crate::types::TypeId;

/// Visits every value operand of an op. Written once for `&Op` and `&mut Op`:
/// default binding modes give `&Value` or `&mut Value` from the same patterns.
macro_rules! visit_values {
    ($op:expr, $f:ident, $($m:tt)?) => {
        match $op {
            Op::Ret(v) => {
                if let Some(v) = v {
                    $f(v)
                }
            }
            Op::Br(_) | Op::Unreachable | Op::Fence { .. } => {}
            Op::CondBr { cond, .. } => $f(cond),
            Op::Switch { value, .. } => $f(value),
            Op::IndirectBr { addr, .. } => $f(addr),
            Op::Invoke { call, .. } | Op::CallBr { call, .. } | Op::Call(call) => {
                let Call { callee, args, bundles, .. } = & $($m)? **call;
                $f(callee);
                for a in args {
                    $f(& $($m)? a.value)
                }
                for b in bundles {
                    for v in & $($m)? b.inputs {
                        $f(v)
                    }
                }
            }
            Op::Resume(v) | Op::Freeze(v) => $f(v),
            Op::CatchSwitch { parent, .. } => {
                if let Some(v) = parent {
                    $f(v)
                }
            }
            Op::CatchRet { pad, .. } | Op::CleanupRet { pad, .. } => $f(pad),
            Op::FNeg { value, .. } => $f(value),
            Op::Binary { lhs, rhs, .. } | Op::ICmp { lhs, rhs, .. } | Op::FCmp { lhs, rhs, .. } => {
                $f(lhs);
                $f(rhs)
            }
            Op::BitExtract { value, offset } => {
                $f(value);
                $f(offset)
            }
            Op::BitInsert { base, value, offset } => {
                $f(base);
                $f(value);
                $f(offset)
            }
            Op::ExtractElement { vector, index } => {
                $f(vector);
                $f(index)
            }
            Op::InsertElement { vector, element, index } => {
                $f(vector);
                $f(element);
                $f(index)
            }
            Op::ShuffleVector { a, b, .. } => {
                $f(a);
                $f(b)
            }
            Op::ExtractValue { aggregate, .. } => $f(aggregate),
            Op::InsertValue { aggregate, element, .. } => {
                $f(aggregate);
                $f(element)
            }
            Op::Alloca { count, .. } => {
                if let Some(v) = count {
                    $f(v)
                }
            }
            Op::Load { ptr, .. } => $f(ptr),
            Op::Store { value, ptr, .. } => {
                $f(value);
                $f(ptr)
            }
            Op::CmpXchg { ptr, cmp, new, .. } => {
                $f(ptr);
                $f(cmp);
                $f(new)
            }
            Op::AtomicRmw { ptr, value, .. } => {
                $f(ptr);
                $f(value)
            }
            Op::Gep { ptr, indices, .. } => {
                $f(ptr);
                for v in indices {
                    $f(v)
                }
            }
            Op::Cast { value, .. } => $f(value),
            Op::Phi { incoming, .. } => {
                for (v, _) in incoming {
                    $f(v)
                }
            }
            Op::Select { cond, then_value, else_value, .. } => {
                $f(cond);
                $f(then_value);
                $f(else_value)
            }
            Op::VaArg { list } => $f(list),
            Op::LandingPad { clauses, .. } => {
                for c in clauses {
                    match c {
                        Clause::Catch(v) | Clause::Filter(v) => $f(v),
                    }
                }
            }
            Op::CatchPad { within, args } => {
                $f(within);
                for v in args {
                    $f(v)
                }
            }
            Op::CleanupPad { within, args } => {
                if let Some(v) = within {
                    $f(v)
                }
                for v in args {
                    $f(v)
                }
            }
        }
    };
}

impl Op {
    /// Calls `f` on every value operand: phi incoming values, callees,
    /// arguments and bundle inputs included. Blocks are not values.
    pub fn for_each_value(&self, mut f: impl FnMut(&Value)) {
        visit_values!(self, f,)
    }

    /// Like `for_each_value`, but allows the operands to be changed.
    pub fn for_each_value_mut(&mut self, mut f: impl FnMut(&mut Value)) {
        visit_values!(self, f, mut)
    }

    /// Calls `f` on every successor operand of a terminator. Phi incoming
    /// blocks are not successors.
    pub fn for_each_successor_mut(&mut self, mut f: impl FnMut(&mut BlockId)) {
        match self {
            Op::Br(b) => f(b),
            Op::CondBr { then_dest, else_dest, .. } => {
                f(then_dest);
                f(else_dest)
            }
            Op::Switch { default, cases, .. } => {
                f(default);
                cases.iter_mut().for_each(|c| f(&mut c.1))
            }
            Op::IndirectBr { dests, .. } => dests.iter_mut().for_each(f),
            Op::Invoke { normal, unwind, .. } => {
                f(normal);
                f(unwind)
            }
            Op::CallBr { default, indirect, .. } => {
                f(default);
                indirect.iter_mut().for_each(f)
            }
            Op::CatchSwitch { handlers, unwind, .. } => {
                handlers.iter_mut().for_each(&mut f);
                if let Some(u) = unwind {
                    f(u)
                }
            }
            Op::CatchRet { dest, .. } => f(dest),
            Op::CleanupRet { unwind: Some(u), .. } => f(u),
            _ => {}
        }
    }

    /// Calls `f` on every block operand: successors and phi incoming blocks.
    pub fn for_each_block_mut(&mut self, mut f: impl FnMut(&mut BlockId)) {
        if let Op::Phi { incoming, .. } = self {
            incoming.iter_mut().for_each(|(_, b)| f(b));
        } else {
            self.for_each_successor_mut(f);
        }
    }

    pub fn is_phi(&self) -> bool {
        matches!(self, Op::Phi { .. })
    }
}

impl Function {
    /// The type of block labels. Only valid for a function with a body.
    pub fn label_type(&self) -> TypeId {
        self.locals[self.blocks[self.layout[0].index()].local.index()].ty
    }

    pub fn entry(&self) -> BlockId {
        self.layout[0]
    }

    pub fn add_local(&mut self, name: Option<String>, ty: TypeId, def: LocalDef) -> LocalId {
        let id = LocalId(self.locals.len() as u32);
        self.locals.push(Local { name, ty, def });
        id
    }

    /// A new, empty block. It is not placed in `layout`.
    pub fn add_block(&mut self, name: Option<String>) -> BlockId {
        let label = self.label_type();
        let id = BlockId(self.blocks.len() as u32);
        let local = self.add_local(name, label, LocalDef::Block(id));
        self.blocks.push(Block { local, insts: Vec::new() });
        id
    }

    /// A new instruction that is not yet in any block. `result` gives the
    /// name and type of the value it defines, if any.
    pub fn add_inst(&mut self, op: Op, result: Option<(Option<String>, TypeId)>) -> InstId {
        let id = InstId(self.insts.len() as u32);
        let result = result.map(|(name, ty)| self.add_local(name, ty, LocalDef::Inst(id)));
        self.insts.push(Inst { result, op, attachments: Vec::new(), debug_records: Vec::new() });
        id
    }

    /// Adds an instruction at the end of block `b`.
    pub fn push_inst(&mut self, b: BlockId, op: Op, result: Option<(Option<String>, TypeId)>) -> InstId {
        let i = self.add_inst(op, result);
        self.blocks[b.index()].insts.push(i);
        i
    }

    /// The value an instruction defines. Panics if it defines none.
    pub fn result(&self, i: InstId) -> Value {
        Value::Local(self.insts[i.index()].result.expect("instruction has no result"))
    }

    pub fn block_name(&self, b: BlockId) -> Option<&str> {
        self.locals[self.blocks[b.index()].local.index()].name.as_deref()
    }

    /// The last instruction of a block, which is its terminator once the
    /// body is complete.
    pub fn terminator(&self, b: BlockId) -> Option<InstId> {
        self.blocks[b.index()].insts.last().copied()
    }

    /// The successors of block `b`, in operand order, possibly repeated.
    pub fn successors(&self, b: BlockId) -> Vec<BlockId> {
        match self.terminator(b) {
            Some(t) => self.insts[t.index()].op.successors(),
            None => Vec::new(),
        }
    }

    /// For each block, its distinct predecessors in layout order.
    pub fn predecessors(&self) -> Vec<Vec<BlockId>> {
        let mut preds: Vec<Vec<BlockId>> = vec![Vec::new(); self.blocks.len()];
        for &b in &self.layout {
            for s in self.successors(b) {
                if !preds[s.index()].contains(&b) {
                    preds[s.index()].push(b);
                }
            }
        }
        preds
    }

    /// For each instruction, the block it is in, if it is in one.
    pub fn inst_blocks(&self) -> Vec<Option<BlockId>> {
        let mut map = vec![None; self.insts.len()];
        for &b in &self.layout {
            for &i in &self.blocks[b.index()].insts {
                map[i.index()] = Some(b);
            }
        }
        map
    }

    /// The instructions in layout order.
    pub fn insts_in_order(&self) -> impl Iterator<Item = InstId> + '_ {
        self.layout.iter().flat_map(|b| self.blocks[b.index()].insts.iter().copied())
    }

    /// Replaces every use of `from` in instructions placed in the body.
    /// Debug records and metadata are not changed.
    pub fn replace_uses(&mut self, from: Value, to: Value) {
        let order: Vec<InstId> = self.insts_in_order().collect();
        for i in order {
            self.insts[i.index()].op.for_each_value_mut(|v| {
                if *v == from {
                    *v = to;
                }
            });
        }
    }

    /// In the phis of block `b`, renames incoming block `from` to `to`.
    pub fn retarget_phis(&mut self, b: BlockId, from: BlockId, to: BlockId) {
        for k in 0..self.blocks[b.index()].insts.len() {
            let i = self.blocks[b.index()].insts[k];
            let Op::Phi { incoming, .. } = &mut self.insts[i.index()].op else { break };
            for (_, p) in incoming.iter_mut() {
                if *p == from {
                    *p = to;
                }
            }
        }
    }

    /// In the phis of block `b`, removes the entries for incoming block `from`.
    pub fn remove_phi_entries(&mut self, b: BlockId, from: BlockId) {
        for k in 0..self.blocks[b.index()].insts.len() {
            let i = self.blocks[b.index()].insts[k];
            let Op::Phi { incoming, .. } = &mut self.insts[i.index()].op else { break };
            incoming.retain(|(_, p)| *p != from);
        }
    }

    /// Every local name used in the body and the parameter list.
    pub fn names(&self) -> HashSet<String> {
        let mut names: HashSet<String> =
            self.params.iter().filter_map(|p| self.locals[p.local.index()].name.clone()).collect();
        for &b in &self.layout {
            if let Some(n) = self.block_name(b) {
                names.insert(n.to_string());
            }
            for &i in &self.blocks[b.index()].insts {
                if let Some(r) = self.insts[i.index()].result
                    && let Some(n) = &self.locals[r.index()].name
                {
                    names.insert(n.clone());
                }
            }
        }
        names
    }

    /// Moves the instructions of block `b` after position `at` into a new
    /// block placed after `b` in the layout, and returns it. Phis in the
    /// successors of the moved terminator are updated to name the new block.
    pub fn split_block(&mut self, b: BlockId, at: usize, name: Option<String>) -> BlockId {
        let new = self.split_block_unplaced(b, at, name);
        let pos = self.layout.iter().position(|&x| x == b).unwrap();
        self.layout.insert(pos + 1, new);
        new
    }

    /// `split_block`, but the new block is not put in the layout: for a
    /// pass that keeps the order some other way while it works (finding a
    /// block's place in a long layout each time would cost its length).
    pub fn split_block_unplaced(&mut self, b: BlockId, at: usize, name: Option<String>) -> BlockId {
        let tail = self.blocks[b.index()].insts.split_off(at);
        // `split_off` leaves the head with the whole list's capacity; many
        // splits of one long block (inlining thousands of calls) would keep
        // every head's room for all that followed it.
        self.blocks[b.index()].insts.shrink_to_fit();
        let new = self.add_block(name);
        self.blocks[new.index()].insts = tail;
        let mut succs = self.successors(new);
        succs.dedup();
        for s in succs {
            self.retarget_phis(s, b, new);
        }
        new
    }
}

/// Picks fresh local names for a function.
pub struct Names {
    used: HashSet<String>,
    /// For each base asked for, a suffix below which every `base{n}` is
    /// taken: where the next search starts, so that asking for the same
    /// base many times (a function inlined thousands of times) costs one
    /// try each, not one per earlier name. Names only become taken, which
    /// keeps these right, except through `release`, which forgets them.
    next: std::collections::HashMap<String, u64>,
}

impl Names {
    pub fn new(f: &Function) -> Self {
        Names { used: f.names(), next: Default::default() }
    }

    /// `base` if it is free, otherwise `base1`, `base2`, and so on. A name
    /// made only of digits would read as a numbered value, so it gets a `v`
    /// in front.
    pub fn fresh(&mut self, base: &str) -> String {
        let base = if base.bytes().all(|c| c.is_ascii_digit()) { format!("v{base}") } else { base.to_string() };
        if self.used.insert(base.clone()) {
            return base;
        }
        let start = self.next.get(&base).copied().unwrap_or(1);
        let (n, name) =
            (start..).map(|n| (n, format!("{base}{n}"))).find(|(_, name)| self.used.insert(name.clone())).unwrap();
        self.next.insert(base, n + 1);
        name
    }

    /// Reserves a name so that `fresh` never returns it.
    pub fn reserve(&mut self, name: &str) {
        self.used.insert(name.to_string());
    }

    /// Makes a name free again, once nothing that will be printed has it.
    pub fn release(&mut self, name: &str) {
        self.used.remove(name);
        self.next.clear();
    }
}
