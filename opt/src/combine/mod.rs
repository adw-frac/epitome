//! The combiner: rewrites instructions into simpler equivalents, driven by
//! the rules in `opt/rules/combine.rules`.
//!
//! - `dsl`: the rule language and its parser.
//! - `tree`: the discrimination tree that finds the rules matching an
//!   instruction without trying each one.
//! - `eval`: constants, rule expressions and conditions, and folding.
//!
//! The pass works through a list of instructions, starting with all of
//! them. For each it:
//!
//! 1. deletes it if nothing uses it and it has no side effects;
//! 2. puts it in canonical form: a constant operand of a commutative
//!    operation or comparison moves to the right;
//! 3. folds it if all its operands are constant, or if it is a phi whose
//!    entries are all the same value;
//! 4. otherwise tries the rules that match, best first.
//!
//! When an instruction is replaced, its users go back on the list, since
//! they may now match something, and so do the instructions it used,
//! which may now be unused. Use lists make each replacement cost the
//! number of users, not the size of the function. New instructions are
//! queued to go before the one they replace, and the blocks are rebuilt
//! once at the end.

pub mod dsl;
pub mod eval;
pub mod tree;

use std::collections::{BTreeMap, HashMap};
use std::sync::OnceLock;

use smaugian_ir::apint::ApInt;
use smaugian_ir::float::FloatKind;
use smaugian_ir::module::*;
use smaugian_ir::types::{Type, TypeId};

use crate::table::{ConstTable as Constants, TypeTable as Types};

use crate::ctx::Shared;
use dsl::{FloatLit, Head, Lit, Repl, Subject as Who};
use eval::{Env, Folded, IntConst};
use tree::{Match, Matcher, Shape, Subject};

/// The standard rules, compiled once.
pub fn standard() -> &'static Matcher {
    static M: OnceLock<Matcher> = OnceLock::new();
    M.get_or_init(|| {
        let rules = dsl::parse_rules(include_str!("../../rules/combine.rules"))
            .unwrap_or_else(|e| panic!("opt/rules/combine.rules: {e}"));
        Matcher::new(rules)
    })
}

/// How often each rule (or built-in step) fired.
#[derive(Default, Debug, Clone)]
pub struct Stats {
    pub fired: BTreeMap<String, usize>,
}

impl Stats {
    fn hit(&mut self, name: &str) {
        *self.fired.entry(name.to_string()).or_default() += 1;
    }

    pub fn total(&self) -> usize {
        self.fired.values().sum()
    }

    pub fn merge(&mut self, other: &Stats) {
        for (k, v) in &other.fired {
            *self.fired.entry(k.clone()).or_default() += v;
        }
    }
}

/// Runs the combiner on one function.
pub fn run(sh: &Shared, f: &mut Function, matcher: &Matcher) -> Stats {
    if !f.has_body {
        return Stats::default();
    }
    let mut c = Combiner::new(sh, f, matcher);
    c.run();
    c.finish();
    c.stats
}

struct Combiner<'s, 'm, 'f> {
    sh: &'s Shared<'m>,
    f: &'f mut Function,
    matcher: &'s Matcher,
    /// The instructions using each local, once per operand.
    uses: Vec<Vec<InstId>>,
    erased: Vec<bool>,
    block_of: Vec<Option<BlockId>>,
    /// New instructions to place before an existing one.
    before: HashMap<InstId, Vec<InstId>>,
    work: Vec<InstId>,
    queued: Vec<bool>,
    /// What replaced each local, for debug records.
    replaced: HashMap<LocalId, Value>,
    /// Debug records of erased instructions, waiting for the next one.
    pending_records: Vec<DebugRecord>,
    stats: Stats,
}

fn inst_has_result(f: &Function, i: InstId) -> bool {
    f.insts[i.index()].result.is_some()
}

/// Instructions that can be deleted when nothing uses them.
fn is_pure(op: &Op) -> bool {
    matches!(
        op,
        Op::Binary { .. }
            | Op::ICmp { .. }
            | Op::FCmp { .. }
            | Op::Select { .. }
            | Op::Cast { .. }
            | Op::FNeg { .. }
            | Op::Freeze(_)
            | Op::Gep { .. }
            | Op::Phi { .. }
            | Op::ExtractValue { .. }
            | Op::InsertValue { .. }
            | Op::ExtractElement { .. }
            | Op::InsertElement { .. }
            | Op::ShuffleVector { .. }
            | Op::BitExtract { .. }
            | Op::BitInsert { .. }
            | Op::Alloca { .. }
            | Op::Load { volatile: false, atomic: None, .. }
    )
}

/// The operation and operands the matcher sees for an instruction.
fn head_of(op: &Op) -> Option<(Head, [Value; 3])> {
    let pad = Value::Const(ConstId(0));
    Some(match *op {
        Op::Binary { op, lhs, rhs, .. } => (Head::Bin(op), [lhs, rhs, pad]),
        Op::ICmp { pred, lhs, rhs, .. } => (Head::ICmp(pred), [lhs, rhs, pad]),
        Op::Select { cond, then_value, else_value, .. } => (Head::Select, [cond, then_value, else_value]),
        Op::Cast { op, value, .. } => (Head::Cast(op), [value, pad, pad]),
        Op::FNeg { value, .. } => (Head::FNeg, [value, pad, pad]),
        Op::Freeze(v) => (Head::Freeze, [v, pad, pad]),
        _ => return None,
    })
}

/// The matcher's view of a function: instructions erased by the combiner
/// are invisible.
struct View<'a> {
    f: &'a Function,
    erased: &'a [bool],
    consts: &'a Constants,
    types: &'a Types,
}

impl Subject for View<'_> {
    fn shape(&self, v: Value) -> Shape {
        match v {
            Value::Local(l) => match self.f.locals[l.index()].def {
                LocalDef::Inst(i) if !self.erased.get(i.index()).copied().unwrap_or(false) => {
                    match head_of(&self.f.insts[i.index()].op) {
                        Some((h, ops)) => Shape::Op(h, ops),
                        None => Shape::Opaque,
                    }
                }
                _ => Shape::Opaque,
            },
            Value::Const(c) => Shape::Const(c),
            Value::Metadata(_) => Shape::Opaque,
        }
    }

    fn lits(&self, c: ConstId) -> Vec<Lit> {
        eval::lits_of(self.consts, self.types, c)
    }

    fn is_int_const(&self, c: ConstId) -> bool {
        eval::int_const(self.consts, self.types, c).is_some()
    }
}

impl<'s, 'm, 'f> Combiner<'s, 'm, 'f> {
    fn new(sh: &'s Shared<'m>, f: &'f mut Function, matcher: &'s Matcher) -> Self {
        let mut c = Combiner {
            sh,
            uses: vec![Vec::new(); f.locals.len()],
            erased: vec![false; f.insts.len()],
            block_of: f.inst_blocks(),
            before: HashMap::new(),
            work: Vec::new(),
            queued: vec![false; f.insts.len()],
            replaced: HashMap::new(),
            pending_records: Vec::new(),
            stats: Stats::default(),
            f,
            matcher,
        };
        let order: Vec<InstId> = c.f.insts_in_order().collect();
        for &i in &order {
            c.add_uses(i);
        }
        // Visit in program order: the list is a stack.
        for &i in order.iter().rev() {
            c.push(i);
        }
        c
    }

    fn grow(&mut self) {
        self.uses.resize(self.f.locals.len(), Vec::new());
        self.erased.resize(self.f.insts.len(), false);
        self.queued.resize(self.f.insts.len(), false);
        self.block_of.resize(self.f.insts.len(), None);
    }

    fn add_uses(&mut self, i: InstId) {
        let mut ls = Vec::new();
        self.f.insts[i.index()].op.for_each_value(|v| {
            if let Value::Local(l) = v {
                ls.push(*l);
            }
        });
        for l in ls {
            self.uses[l.index()].push(i);
        }
    }

    fn push(&mut self, i: InstId) {
        if !self.queued[i.index()] && !self.erased[i.index()] {
            self.queued[i.index()] = true;
            self.work.push(i);
        }
    }

    /// Queues the instruction defining `v`, if there is one.
    fn push_def(&mut self, v: Value) {
        if let Value::Local(l) = v
            && let LocalDef::Inst(d) = self.f.locals[l.index()].def
        {
            self.push(d);
        }
    }

    fn value_type(&self, v: Value) -> Option<TypeId> {
        match v {
            Value::Local(l) => Some(self.f.locals[l.index()].ty),
            Value::Const(c) => Some(self.sh.consts().get(c).ty),
            Value::Metadata(_) => None,
        }
    }

    fn run(&mut self) {
        // A bound on the work, in case a set of rules undoes itself.
        let mut budget = 20 * self.f.insts.len() + 1000;
        while let Some(i) = self.work.pop() {
            self.queued[i.index()] = false;
            if self.erased[i.index()] {
                continue;
            }
            if budget == 0 {
                self.stats.hit("(stopped: work limit reached)");
                break;
            }
            budget -= 1;
            self.visit(i);
        }
    }

    fn visit(&mut self, i: InstId) {
        let inst = &self.f.insts[i.index()];
        if let Some(r) = inst.result
            && self.uses[r.index()].is_empty()
            && is_pure(&inst.op)
        {
            self.erase(i);
            self.stats.hit("(dead)");
            return;
        }
        if self.canonicalize(i) {
            self.stats.hit("(constant to the right)");
        }
        if let Some(v) = self.fold(i) {
            self.stats.hit("(folded)");
            self.replace(i, v);
            return;
        }
        if inst_has_result(self.f, i)
            && let Some((name, v)) = self.apply_rules(i)
        {
            self.stats.hit(&name);
            self.replace(i, v);
        }
    }

    /// Moves a constant left operand of a commutative operation or a
    /// comparison to the right.
    fn canonicalize(&mut self, i: InstId) -> bool {
        let op = &mut self.f.insts[i.index()].op;
        let commutative = |o: BinOp| {
            matches!(o, BinOp::Add | BinOp::Mul | BinOp::And | BinOp::Or | BinOp::Xor | BinOp::FAdd | BinOp::FMul)
        };
        match op {
            Op::Binary { op, lhs, rhs, .. }
                if commutative(*op) && matches!(lhs, Value::Const(_)) && !matches!(rhs, Value::Const(_)) =>
            {
                std::mem::swap(lhs, rhs);
                true
            }
            Op::ICmp { pred, lhs, rhs, .. } if matches!(lhs, Value::Const(_)) && !matches!(rhs, Value::Const(_)) => {
                std::mem::swap(lhs, rhs);
                *pred = eval::swapped(*pred);
                true
            }
            _ => false,
        }
    }

    /// The value of an instruction whose result is known without running
    /// it: all-constant operands, poison operands, or a phi of one value.
    fn fold(&mut self, i: InstId) -> Option<Value> {
        let sh = self.sh;
        let inst = &self.f.insts[i.index()];
        let r = inst.result?;
        let ty = self.f.locals[r.index()].ty;
        let op = inst.op.clone();
        let is_poison = |v: Value| matches!(v, Value::Const(c) if matches!(sh.consts().get(c).kind, ConstKind::Poison));
        match op {
            Op::Phi { incoming, .. } => {
                let me = Value::Local(r);
                let mut same = None;
                for (v, _) in incoming {
                    if v == me || Some(v) == same {
                        continue;
                    }
                    if same.is_some() {
                        return None;
                    }
                    same = Some(v);
                }
                same
            }
            Op::Binary { op, flags, fmf, lhs, rhs } => {
                if is_poison(lhs) || is_poison(rhs) {
                    return Some(sh.poison(ty));
                }
                let (Value::Const(a), Value::Const(b)) = (lhs, rhs) else { return None };
                if op.is_float() {
                    if !fmf.is_empty() {
                        return None;
                    }
                    let (consts, types) = (sh.consts(), sh.types());
                    let (ConstKind::Float(x), ConstKind::Float(y)) = (&consts.get(a).kind, &consts.get(b).kind) else {
                        return None;
                    };
                    let kind = FloatKind::of(types.get(ty))?;
                    let bits = eval::fold_float(op, kind, *x, *y)?;
                    return Some(Value::Const(sh.intern_const(Constant { ty, kind: ConstKind::Float(bits) })));
                }
                let (x, y) = (self.int(a)?, self.int(b)?);
                match eval::fold_binop(op, flags, x.value, y.value, x.bits)? {
                    Folded::Int(v) => self.int_value(ty, v),
                    Folded::Poison => Some(sh.poison(ty)),
                }
            }
            Op::ICmp { pred, lhs, rhs, .. } => {
                if is_poison(lhs) || is_poison(rhs) {
                    return Some(sh.poison(ty));
                }
                let (Value::Const(a), Value::Const(b)) = (lhs, rhs) else { return None };
                let (x, y) = (self.int(a)?, self.int(b)?);
                self.int_value(ty, eval::fold_icmp(pred, x.value, y.value, x.bits) as u64)
            }
            Op::Select { cond, then_value, else_value, .. } => {
                if is_poison(cond) {
                    return Some(sh.poison(ty));
                }
                let Value::Const(c) = cond else { return None };
                let k = self.int(c)?;
                Some(if k.value != 0 { then_value } else { else_value })
            }
            Op::Cast { op, flags, value, .. } => {
                if is_poison(value) {
                    return Some(sh.poison(ty));
                }
                let Value::Const(c) = value else { return None };
                let x = self.int(c)?;
                let to = eval::int_bits(sh.types(), ty)?;
                match eval::fold_cast(op, flags, x.value, x.bits, to)? {
                    Folded::Int(v) => self.int_value(ty, v),
                    Folded::Poison => Some(sh.poison(ty)),
                }
            }
            Op::FNeg { fmf, value: Value::Const(c) } if fmf.is_empty() => {
                let bits = {
                    let consts = sh.consts();
                    let types = sh.types();
                    let ConstKind::Float(b) = consts.get(c).kind else { return None };
                    let kind = FloatKind::of(types.get(ty))?;
                    let sign = match kind {
                        FloatKind::Half | FloatKind::BFloat => 15,
                        FloatKind::Float => 31,
                        FloatKind::Double => 63,
                        _ => return None,
                    };
                    b ^ (1u128 << sign)
                };
                Some(Value::Const(sh.intern_const(Constant { ty, kind: ConstKind::Float(bits) })))
            }
            Op::Freeze(Value::Const(c)) => {
                let consts = sh.consts();
                let k = &consts.get(c).kind;
                matches!(k, ConstKind::Int(_) | ConstKind::Float(_) | ConstKind::Zero | ConstKind::Null)
                    .then_some(Value::Const(c))
            }
            _ => None,
        }
    }

    fn int(&self, c: ConstId) -> Option<IntConst> {
        eval::int_const(self.sh.consts(), self.sh.types(), c)
    }

    /// An integer constant of type `ty` (a splat for a vector).
    fn int_value(&self, ty: TypeId, v: u64) -> Option<Value> {
        let sh = self.sh;
        let (bits, elem, vector) = {
            let types = sh.types();
            let elem = types.scalar(ty);
            let Type::Int(bits) = *types.get(elem) else { return None };
            (bits, elem, elem != ty)
        };
        let k =
            sh.intern_const(Constant { ty: elem, kind: ConstKind::Int(ApInt::from_u64(bits, v & eval::mask(bits))) });
        Some(Value::Const(if vector { sh.intern_const(Constant { ty, kind: ConstKind::Splat(k) }) } else { k }))
    }

    fn float_value(&self, ty: TypeId, lit: FloatLit) -> Option<Value> {
        let sh = self.sh;
        let (elem, kind, vector) = {
            let types = sh.types();
            let elem = types.scalar(ty);
            (elem, FloatKind::of(types.get(elem))?, elem != ty)
        };
        let v = match lit {
            FloatLit::PosZero => 0.0,
            FloatLit::NegZero => -0.0,
            FloatLit::One => 1.0,
        };
        let bits = smaugian_ir::float::from_f64(kind, v)?;
        let k = sh.intern_const(Constant { ty: elem, kind: ConstKind::Float(bits) });
        Some(Value::Const(if vector { sh.intern_const(Constant { ty, kind: ConstKind::Splat(k) }) } else { k }))
    }

    /// Tries the rules matching `i`, best first, and builds the
    /// replacement of the first that applies. Returns the rule's name and
    /// the replacement value.
    fn apply_rules(&mut self, i: InstId) -> Option<(String, Value)> {
        let root = self.f.result(i);
        let matches = {
            let consts = self.sh.consts();
            let types = self.sh.types();
            let view = View { f: self.f, erased: &self.erased, consts, types };
            self.matcher.find(&view, root)
        };
        for m in matches {
            if let Some(v) = self.try_match(i, &m) {
                let rule = &self.matcher.rules[self.matcher.variants[m.variant].rule];
                return Some((rule.name.clone(), v));
            }
        }
        None
    }

    fn try_match(&mut self, i: InstId, m: &Match) -> Option<Value> {
        let variant = &self.matcher.variants[m.variant];
        let rule = &self.matcher.rules[variant.rule];
        // Bind the variables; a repeated variable must see the same value.
        let mut bound: Vec<Option<Value>> = vec![None; rule.vars.len()];
        for (slot, &v) in variant.slots.iter().zip(&m.captures) {
            match bound[*slot] {
                Some(prev) if prev != v => return None,
                _ => bound[*slot] = Some(v),
            }
        }
        // Constants and widths for the expressions.
        let root_ty = self.f.locals[self.f.insts[i.index()].result?.index()].ty;
        let (consts, widths, bw) = {
            let cs = self.sh.consts();
            let ts = self.sh.types();
            let consts: Vec<Option<IntConst>> = bound
                .iter()
                .map(|b| match b {
                    Some(Value::Const(c)) => eval::int_const(cs, ts, *c),
                    _ => None,
                })
                .collect();
            let ty_of = |v: Value| match v {
                Value::Local(l) => Some(self.f.locals[l.index()].ty),
                Value::Const(c) => Some(cs.get(c).ty),
                Value::Metadata(_) => None,
            };
            let widths: Vec<Option<u32>> =
                bound.iter().map(|b| b.and_then(ty_of).and_then(|t| eval::int_bits(ts, t))).collect();
            // For a comparison, `bw` is the width of what it compares.
            let bw = match &self.f.insts[i.index()].op {
                Op::ICmp { lhs, .. } => ty_of(*lhs).and_then(|t| eval::int_bits(ts, t)),
                _ => eval::int_bits(ts, root_ty),
            };
            (consts, widths, bw)
        };
        let env = Env { consts: &consts, widths: &widths, bw };
        let type_of = |w: Who| -> Option<TypeId> {
            match w {
                Who::Root => Some(root_ty),
                Who::Var(v) => bound[v].and_then(|x| self.value_type(x)),
            }
        };
        let same_type = |a: Who, b: Who| type_of(a).is_some() && type_of(a) == type_of(b);
        if !rule.conds.iter().all(|c| eval::check(c, &env, &same_type)) {
            return None;
        }
        // Worth it only if no more instructions are made than become unused.
        let made = count_ops(&rule.repl);
        let freed =
            1 + m.interior.iter().filter(|v| matches!(v, Value::Local(l) if self.uses[l.index()].len() == 1)).count();
        if made > freed {
            return None;
        }
        let mut created = Vec::new();
        let result = self.build(&rule.repl, &bound, &env, root_ty, i, &mut created);
        match result {
            Some(v) if self.value_type(v) == Some(root_ty) => {
                // The new instruction in the root's place takes its name.
                if let (Some(&last), Some(r)) = (created.last(), self.f.insts[i.index()].result)
                    && self.f.result(last) == v
                {
                    let name = self.f.locals[r.index()].name.take();
                    let new = self.f.insts[last.index()].result.unwrap();
                    self.f.locals[new.index()].name = name;
                }
                for c in created {
                    self.push(c);
                }
                Some(v)
            }
            _ => {
                // The replacement did not type-check: undo what was built.
                for c in created.into_iter().rev() {
                    self.erase(c);
                }
                None
            }
        }
    }

    /// Builds a replacement of type `ty`, placing new instructions before
    /// `root`.
    fn build(
        &mut self,
        r: &Repl,
        bound: &[Option<Value>],
        env: &Env,
        ty: TypeId,
        root: InstId,
        created: &mut Vec<InstId>,
    ) -> Option<Value> {
        let sh = self.sh;
        match r {
            Repl::Var(v) => {
                let x = bound[*v]?;
                (self.value_type(x) == Some(ty)).then_some(x)
            }
            Repl::Lit(Lit::Poison) => Some(sh.poison(ty)),
            Repl::Lit(Lit::Float(f)) => self.float_value(ty, *f),
            Repl::Lit(Lit::Int(n)) => self.int_value(ty, *n as u64),
            Repl::Const(e) => {
                let v = eval::eval(e, env)?;
                self.int_value(ty, v as u64)
            }
            Repl::Op(head, args) => {
                let i1 = sh.intern_type(Type::Int(1));
                let shape = sh.ty(ty);
                let bool_ty = match shape {
                    Type::Vector { scalable, len, .. } => sh.intern_type(Type::Vector { scalable, len, elem: i1 }),
                    _ => i1,
                };
                // The type each operand must have.
                let var_ty = |a: &Repl| match a {
                    Repl::Var(v) => bound[*v].and_then(|x| self.value_type(x)),
                    _ => None,
                };
                let operand_tys: Vec<TypeId> = match head {
                    Head::Bin(_) | Head::FNeg | Head::Freeze => vec![ty; head.arity()],
                    Head::Select => vec![bool_ty, ty, ty],
                    Head::ICmp(_) => {
                        let t = args.iter().find_map(var_ty)?;
                        vec![t, t]
                    }
                    Head::Cast(_) => vec![var_ty(&args[0])?],
                };
                let mut ops = Vec::new();
                for (a, &t) in args.iter().zip(&operand_tys) {
                    ops.push(self.build(a, bound, env, t, root, created)?);
                }
                let op = match *head {
                    Head::Bin(op) => {
                        Op::Binary { op, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: ops[0], rhs: ops[1] }
                    }
                    Head::ICmp(pred) => Op::ICmp { pred, samesign: false, lhs: ops[0], rhs: ops[1] },
                    Head::Select => {
                        Op::Select { fmf: FastMath::default(), cond: ops[0], then_value: ops[1], else_value: ops[2] }
                    }
                    Head::Cast(op) => Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value: ops[0] },
                    Head::FNeg => Op::FNeg { fmf: FastMath::default(), value: ops[0] },
                    Head::Freeze => Op::Freeze(ops[0]),
                };
                let new = self.f.add_inst(op, Some((None, ty)));
                self.grow();
                self.block_of[new.index()] = self.block_of[root.index()];
                self.before.entry(root).or_default().push(new);
                self.add_uses(new);
                created.push(new);
                Some(self.f.result(new))
            }
        }
    }

    /// Replaces every use of `i`'s result with `v`, then erases `i`.
    fn replace(&mut self, i: InstId, v: Value) {
        let r = self.f.insts[i.index()].result.unwrap();
        let from = Value::Local(r);
        let users = std::mem::take(&mut self.uses[r.index()]);
        let mut done = Vec::new();
        for u in users {
            if done.contains(&u) {
                continue;
            }
            done.push(u);
            let mut n = 0;
            self.f.insts[u.index()].op.for_each_value_mut(|x| {
                if *x == from {
                    *x = v;
                    n += 1;
                }
            });
            if let Value::Local(l) = v {
                for _ in 0..n {
                    self.uses[l.index()].push(u);
                }
            }
            self.push(u);
        }
        self.replaced.insert(r, v);
        self.erase(i);
    }

    /// Removes an instruction. Its operands lose a use, and go back on the
    /// list in case that leaves them unused.
    fn erase(&mut self, i: InstId) {
        if self.erased[i.index()] {
            return;
        }
        self.erased[i.index()] = true;
        let mut operands = Vec::new();
        self.f.insts[i.index()].op.for_each_value(|v| operands.push(*v));
        for v in operands {
            if let Value::Local(l) = v {
                let list = &mut self.uses[l.index()];
                if let Some(k) = list.iter().position(|&x| x == i) {
                    list.swap_remove(k);
                }
                self.push_def(v);
            }
        }
    }

    /// Rebuilds the blocks with new instructions in place and erased ones
    /// gone, and points debug records at the values that replaced theirs.
    fn finish(&mut self) {
        for b in self.f.layout.clone() {
            let old = std::mem::take(&mut self.f.blocks[b.index()].insts);
            let mut new = Vec::with_capacity(old.len());
            for i in old {
                self.place(i, &mut new);
            }
            self.f.blocks[b.index()].insts = new;
        }
        self.fix_debug_records();
    }

    fn fix_debug_records(&mut self) {
        let sh = self.sh;
        let resolve = |mut v: Value| {
            for _ in 0..1000 {
                match v {
                    Value::Local(l) => match self.replaced.get(&l) {
                        Some(&next) => v = next,
                        None => break,
                    },
                    _ => break,
                }
            }
            v
        };
        let dead = |l: LocalId| matches!(self.f.locals[l.index()].def, LocalDef::Inst(d) if self.erased[d.index()]);
        let fix = |v: Value| -> Value {
            let v = resolve(v);
            match v {
                Value::Local(l) if dead(l) => sh.poison(self.f.locals[l.index()].ty),
                v => v,
            }
        };
        let mut changes: Vec<(InstId, usize, usize, MdId)> = Vec::new();
        for i in self.f.insts_in_order() {
            for (k, r) in self.f.insts[i.index()].debug_records.iter().enumerate() {
                for (j, &arg) in r.args.iter().enumerate() {
                    let data = sh.metadata()[arg.index()].data.clone();
                    let new = match data {
                        Metadata::Value(v @ Value::Local(_)) if fix(v) != v => Some(Metadata::Value(fix(v))),
                        Metadata::Node { distinct, kind, fields }
                            if fields.iter().any(|x| matches!(x.value, MdFieldValue::Value(v) if fix(v) != v)) =>
                        {
                            let fields = fields
                                .into_iter()
                                .map(|x| match x.value {
                                    MdFieldValue::Value(v) => {
                                        MdField { name: x.name, value: MdFieldValue::Value(fix(v)) }
                                    }
                                    _ => x,
                                })
                                .collect();
                            Some(Metadata::Node { distinct, kind, fields })
                        }
                        _ => None,
                    };
                    if let Some(data) = new {
                        changes.push((i, k, j, sh.add_md(data)));
                    }
                }
            }
        }
        for (i, k, j, md) in changes {
            self.f.insts[i.index()].debug_records[k].args[j] = md;
        }
    }

    fn place(&mut self, i: InstId, out: &mut Vec<InstId>) {
        if let Some(list) = self.before.remove(&i) {
            for n in list {
                self.place(n, out);
            }
        }
        if !self.erased[i.index()] {
            out.push(i);
        } else if !self.f.insts[i.index()].debug_records.is_empty() {
            // The records of an erased instruction move to the next one.
            let records = std::mem::take(&mut self.f.insts[i.index()].debug_records);
            self.pending_records.extend(records);
            return;
        }
        if !self.erased[i.index()] && !self.pending_records.is_empty() {
            let mut records = std::mem::take(&mut self.pending_records);
            records.append(&mut self.f.insts[i.index()].debug_records);
            self.f.insts[i.index()].debug_records = records;
        }
    }
}

/// The number of instructions a replacement makes.
fn count_ops(r: &Repl) -> usize {
    match r {
        Repl::Op(_, args) => 1 + args.iter().map(count_ops).sum::<usize>(),
        _ => 0,
    }
}
