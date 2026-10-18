//! Instruction selection: covering each block's IR with patterns from the
//! machine description, longest match first. See `docs/design/isel.md`.

use std::collections::{HashMap, HashSet};

use smaugian_ir::module::*;
use smaugian_ir::types::{Type, TypeId};

use crate::mir::*;
use crate::prepare::{self, Ctx};
use crate::target::{Class, Head, Key, Kind, Src, Target, bin_bits, sext, wide_bits};

/// A value or block being matched against a pattern.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Term {
    V(Value),
    B(BlockId),
    /// The instruction a match is rooted at.
    Root(InstId),
}

#[derive(Clone, Debug)]
struct Match {
    pat: usize,
    params: Vec<Option<Term>>,
    next: Option<BlockId>,
    covered: Vec<InstId>,
    cost: (usize, bool, i64),
    /// Instructions whose values are further results, and the operand of
    /// the first emitted instruction that receives each.
    extras: Vec<(InstId, usize)>,
}

/// Counters for measuring the matcher: roots matched, trie steps taken,
/// candidate matches found, and those that passed validation.
pub mod stats {
    use std::sync::atomic::{AtomicU64, Ordering};
    pub static ROOTS: AtomicU64 = AtomicU64::new(0);
    pub static STEPS: AtomicU64 = AtomicU64::new(0);
    pub static CANDIDATES: AtomicU64 = AtomicU64::new(0);
    pub static VALID: AtomicU64 = AtomicU64::new(0);
    pub static NANOS: AtomicU64 = AtomicU64::new(0);
    pub static WALK_NANOS: AtomicU64 = AtomicU64::new(0);

    pub fn add(c: &AtomicU64, n: u64) {
        c.fetch_add(n, Ordering::Relaxed);
    }

    pub fn get(c: &AtomicU64) -> u64 {
        c.load(Ordering::Relaxed)
    }
}

/// Registers arguments and results are passed in.
pub const ARG_REGS: usize = 8;

pub struct Sel<'a, 'b> {
    t: &'a Target,
    cx: &'a mut Ctx<'b>,
    f: &'a Function,
    fname: String,
    pub mf: MFunc,
    vreg: HashMap<LocalId, VReg>,
    bmap: HashMap<BlockId, usize>,
    uses: Vec<u32>,
    inst_block: Vec<Option<BlockId>>,
    pos: Vec<usize>,
    /// The bits above which a register is known to be zero.
    zbits: HashMap<VReg, u32>,
    /// Instructions whose values are wanted in registers.
    needed: HashSet<InstId>,
    covered: HashSet<InstId>,
    chosen: HashMap<InstId, Match>,
    /// The block being emitted, and its place in the layout.
    cur: usize,
    /// Blocks on a cycle.
    in_loop: Vec<bool>,
    /// Constants made once in the entry block, for use in loops.
    hoisted: HashMap<(i64, bool), VReg>,
    hoisted_addr: HashMap<ConstId, VReg>,
}

fn side_effects(op: &Op) -> bool {
    matches!(op, Op::Store { .. } | Op::Call(_) | Op::Fence { .. } | Op::AtomicRmw { .. } | Op::CmpXchg { .. })
        || matches!(op, Op::Load { volatile: true, .. })
}

impl<'a, 'b> Sel<'a, 'b> {
    pub fn new(t: &'a Target, cx: &'a mut Ctx<'b>, f: &'a Function, fname: &str, global: bool) -> Self {
        let mut uses = vec![0u32; f.locals.len()];
        for i in f.insts_in_order() {
            f.insts[i.index()].op.for_each_value(|v| {
                if let Value::Local(x) = v {
                    uses[x.index()] += 1;
                }
            });
        }
        let inst_block = f.inst_blocks();
        let mut pos = vec![0usize; f.insts.len()];
        for &b in &f.layout {
            for (k, &i) in f.blocks[b.index()].insts.iter().enumerate() {
                pos[i.index()] = k;
            }
        }
        let mut mf = MFunc {
            name: fname.to_string(),
            global,
            blocks: Vec::new(),
            vwide: Vec::new(),
            slots: Vec::new(),
            frame_size: 0,
        };
        let mut bmap = HashMap::new();
        for (k, &b) in f.layout.iter().enumerate() {
            bmap.insert(b, k);
            mf.blocks.push(MBlock { label: String::new(), insts: Vec::new(), succs: Vec::new(), term_start: 0 });
        }
        Sel {
            t,
            cx,
            f,
            fname: fname.to_string(),
            mf,
            vreg: HashMap::new(),
            bmap,
            uses,
            inst_block,
            pos,
            zbits: HashMap::new(),
            needed: HashSet::new(),
            covered: HashSet::new(),
            chosen: HashMap::new(),
            cur: 0,
            in_loop: Vec::new(),
            hoisted: HashMap::new(),
            hoisted_addr: HashMap::new(),
        }
    }

    fn err<T>(&self, msg: impl std::fmt::Display) -> Result<T, String> {
        Err(format!("@{}: {msg}", self.fname))
    }

    fn ty_of(&self, v: Value) -> TypeId {
        match v {
            Value::Local(x) => self.f.locals[x.index()].ty,
            Value::Const(c) => self.cx.m.constant(c).ty,
            Value::Metadata(_) => unreachable!(),
        }
    }

    fn bits(&self, ty: TypeId) -> u32 {
        match self.cx.m.types.get(ty) {
            Type::Int(b) => *b,
            Type::Ptr(_) => 64,
            _ => 0,
        }
    }

    fn vbits(&self, v: Value) -> u32 {
        self.bits(self.ty_of(v))
    }

    fn vreg_of(&mut self, x: LocalId) -> VReg {
        if let Some(&v) = self.vreg.get(&x) {
            return v;
        }
        let wide = self.bits(self.f.locals[x.index()].ty) > 32;
        let v = self.mf.new_vreg(wide);
        self.vreg.insert(x, v);
        v
    }

    /// Gives `r` the register of `v`, when the two hold the same bits and
    /// `v`'s register is written once (a phi's is written in each
    /// predecessor, so it cannot be shared). Returns false if it cannot.
    fn alias(&mut self, r: LocalId, v: Value) -> bool {
        let Value::Local(x) = v else { return false };
        let single_def = match self.f.locals[x.index()].def {
            LocalDef::Param(_) => true,
            LocalDef::Inst(d) => !self.f.insts[d.index()].op.is_phi(),
            _ => false,
        };
        if !single_def || self.vreg.contains_key(&r) {
            return false;
        }
        let s = self.vreg_of(x);
        self.vreg.insert(r, s);
        true
    }

    fn push(&mut self, inst: MInst) {
        self.mf.blocks[self.cur].insts.push(inst);
    }

    // -----------------------------------------------------------------------
    // Matching

    /// The head and operands of an IR instruction, as patterns see it.
    fn head_of(&self, i: InstId) -> Option<(Head, Vec<Term>)> {
        let f = self.f;
        let inst = &f.insts[i.index()];
        let res_bits = inst.result.map(|r| self.bits(f.locals[r.index()].ty)).unwrap_or(0);
        let v = Term::V;
        Some(match &inst.op {
            Op::Binary { op, lhs, rhs, .. } => (Head::Bin(*op, bin_bits(*op, res_bits)), vec![v(*lhs), v(*rhs)]),
            Op::ICmp { pred, lhs, rhs, .. } => (Head::ICmp(*pred, self.vbits(*lhs)), vec![v(*lhs), v(*rhs)]),
            Op::Select { cond, then_value, else_value, .. } => {
                (Head::Select(wide_bits(res_bits)), vec![v(*cond), v(*then_value), v(*else_value)])
            }
            Op::Cast { op, value, .. } => (Head::Cast(*op, self.vbits(*value), wide_bits(res_bits)), vec![v(*value)]),
            Op::Load { ptr, .. } => (Head::Load(res_bits), vec![v(*ptr)]),
            Op::Store { value, ptr, .. } => (Head::Store(self.vbits(*value)), vec![v(*value), v(*ptr)]),
            Op::Gep { ptr, indices, .. } if indices.len() == 1 => (Head::Gep, vec![v(*ptr), v(indices[0])]),
            Op::CondBr { cond, then_dest, else_dest } => {
                (Head::CondBr, vec![v(*cond), Term::B(*then_dest), Term::B(*else_dest)])
            }
            Op::Br(b) => (Head::Br, vec![Term::B(*b)]),
            Op::Ret(None) => (Head::Ret, vec![]),
            Op::Unreachable => (Head::Unreachable, vec![]),
            Op::Call(call) => {
                let id = self.intrinsic_id(call)?;
                (Head::Intrinsic(id, res_bits), call.args.iter().map(|a| v(a.value)).collect())
            }
            _ => return None,
        })
    }

    fn intrinsic_id(&self, call: &Call) -> Option<u16> {
        let name = prepare::callee_name(self.cx.m, call)?;
        self.t.intrinsics.iter().position(|x| *x == name).map(|i| i as u16)
    }

    /// Can instruction `i` be folded into a pattern rooted at `root`?
    fn foldable(&self, i: InstId, root: InstId) -> bool {
        let f = self.f;
        if i == root || self.inst_block[i.index()] != self.inst_block[root.index()] || self.covered.contains(&i) {
            return false;
        }
        let inst = &f.insts[i.index()];
        let Some(r) = inst.result else { return false };
        if self.uses[r.index()] != 1 || inst.op.is_phi() {
            return false;
        }
        match &inst.op {
            Op::Load { volatile: false, atomic: None, .. } => {
                // Nothing may write memory between the load and the root.
                let b = self.inst_block[i.index()].unwrap();
                let insts = &f.blocks[b.index()].insts;
                let (a, z) = (self.pos[i.index()], self.pos[root.index()]);
                a < z && !insts[a + 1..z].iter().any(|&k| side_effects(&f.insts[k.index()].op))
            }
            op => !side_effects(op) && !matches!(op, Op::Alloca { .. } | Op::Call(_)),
        }
    }

    fn expand(&self, t: Term, root: InstId) -> Option<(Head, Vec<Term>, InstId)> {
        let i = match t {
            Term::Root(i) => i,
            Term::V(Value::Local(x)) => match self.f.locals[x.index()].def {
                LocalDef::Inst(i) if self.foldable(i, root) => i,
                _ => return None,
            },
            _ => return None,
        };
        let (h, kids) = self.head_of(i)?;
        Some((h, kids, i))
    }

    fn lit_key(&self, t: Term) -> Option<Key> {
        let Term::V(Value::Const(c)) = t else { return None };
        let k = self.cx.m.constant(c);
        let bits = self.bits(k.ty);
        match &k.kind {
            ConstKind::Int(a) => Some(Key::Lit(sext(a.low_u64(), bits), bits)),
            ConstKind::Null | ConstKind::Zero => Some(Key::Lit(0, bits)),
            _ => None,
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn walk(
        &self,
        node: usize,
        pending: &mut Vec<Term>,
        binds: &mut Vec<Term>,
        covered: &mut Vec<InstId>,
        root: InstId,
        out: &mut Vec<(usize, Vec<Term>, Vec<InstId>)>,
    ) {
        stats::add(&stats::STEPS, 1);
        let trie = &self.t.trie;
        let Some(t) = pending.pop() else {
            for &p in &trie.nodes[node].accept {
                out.push((p, binds.clone(), covered.clone()));
            }
            return;
        };
        let next = &trie.nodes[node];
        if !matches!(t, Term::Root(_))
            && let Some(c) = next.get(&Key::Wild)
        {
            binds.push(t);
            self.walk(c, pending, binds, covered, root, out);
            binds.pop();
        }
        if let Some(k) = self.lit_key(t)
            && let Some(c) = next.get(&k)
        {
            self.walk(c, pending, binds, covered, root, out);
        }
        if let Some((h, kids, i)) = self.expand(t, root)
            && let Some(c) = next.get(&Key::Head(h))
        {
            let mut orders = vec![kids.clone()];
            if h.commutative() && kids.len() == 2 && kids[0] != kids[1] {
                orders.push(vec![kids[1], kids[0]]);
            }
            for order in orders {
                let n = pending.len();
                pending.extend(order.iter().rev().copied());
                covered.push(i);
                self.walk(c, pending, binds, covered, root, out);
                covered.pop();
                pending.truncate(n);
            }
        }
        pending.push(t);
    }

    /// The value of an IR constant as an immediate of `bits` bits.
    fn imm_of(&self, t: Term, bits: u32) -> Option<i64> {
        let Term::V(Value::Const(c)) = t else { return None };
        let k = self.cx.m.constant(c);
        let kb = self.bits(k.ty);
        match &k.kind {
            ConstKind::Int(a) if kb == 1 && bits > 1 => Some((a.low_u64() & 1) as i64),
            ConstKind::Int(a) => Some(sext(a.low_u64(), kb)),
            ConstKind::Null | ConstKind::Zero => Some(0),
            _ => None,
        }
    }

    fn is_zero_like(&self, t: Term) -> bool {
        let Term::V(Value::Const(c)) = t else { return false };
        match &self.cx.m.constant(c).kind {
            ConstKind::Int(a) => a.is_zero(),
            ConstKind::Null | ConstKind::Zero | ConstKind::Undef | ConstKind::Poison => true,
            _ => false,
        }
    }

    /// Whether instruction `i` can encode these immediates, remembered: the
    /// same few values come up again and again.
    fn fits(&self, i: usize, vals: Vec<Option<i64>>) -> bool {
        self.t.fits_cached(i, vals)
    }

    /// Matches tree `t` against value `v`, binding parameters.
    fn match_leaves(&self, t: &crate::target::Tree, v: Term, params: &mut [Option<Term>]) -> bool {
        use crate::target::Tree;
        match t {
            Tree::Leaf(p) => match params[*p] {
                Some(prev) => prev == v,
                None => {
                    params[*p] = Some(v);
                    true
                }
            },
            Tree::Lit(k, bits) => self.lit_key(v) == Some(Key::Lit(*k, *bits)),
            _ => false,
        }
    }

    /// An instruction after `root` in its block that `t` matches with the
    /// parameters bound so far, binding the rest.
    fn find_extra(&self, t: &crate::target::Tree, root: InstId, params: &mut Vec<Option<Term>>) -> Option<InstId> {
        let crate::target::Tree::Op(h, kids) = t else { return None };
        let b = self.inst_block[root.index()]?;
        let insts = &self.f.blocks[b.index()].insts;
        for &x in &insts[self.pos[root.index()] + 1..] {
            if self.covered.contains(&x) || self.chosen.get(&x).is_some_and(|m| m.covered.len() > 1) {
                continue;
            }
            let Some((xh, terms)) = self.head_of(x) else { continue };
            if xh != *h || terms.len() != kids.len() {
                continue;
            }
            let mut trial = params.clone();
            if kids.iter().zip(&terms).all(|(k, &v)| self.match_leaves(k, v, &mut trial)) {
                *params = trial;
                return Some(x);
            }
        }
        None
    }

    /// Checks a match from the trie, and scores it.
    fn validate(
        &self,
        pat: usize,
        binds: &[Term],
        mut covered: Vec<InstId>,
        layout_next: Option<BlockId>,
    ) -> Option<Match> {
        let p = &self.t.patterns[pat];
        let mut params: Vec<Option<Term>> = vec![None; p.params.len()];
        let mut next = None;
        for (slot, &t) in p.wild.iter().zip(binds) {
            match slot {
                Some(i) => {
                    if params[*i].is_some_and(|prev| prev != t) {
                        return None;
                    }
                    params[*i] = Some(t);
                }
                None => match t {
                    Term::B(b) => next = Some(b),
                    _ => return None,
                },
            }
        }
        // Further results: another instruction in the block, after this
        // one, computing what the instruction also writes back.
        let mut extras = Vec::new();
        for (tree, operand) in &p.extra {
            let x = self.find_extra(tree, covered[0], &mut params)?;
            covered.push(x);
            extras.push((x, *operand));
        }
        let mut materialize = 0i64;
        for (i, pp) in p.params.iter().enumerate() {
            let Some(t) = params[i] else { continue };
            match pp.kind {
                Kind::Reg(class) => {
                    let Term::V(v) = t else { return None };
                    let bits = self.vbits(v);
                    if bits == 0 || bits > 64 || (bits > 32) != (pp.bits > 32) {
                        return None;
                    }
                    if let Value::Const(_) = v {
                        let zr = matches!(class, Class::W | Class::X) && self.is_zero_like(t);
                        if !zr {
                            materialize += 1;
                        }
                    }
                }
                Kind::Imm => {
                    self.imm_of(t, pp.bits)?;
                }
                Kind::Label => {
                    if !matches!(t, Term::B(_)) {
                        return None;
                    }
                }
                Kind::Sym | Kind::Cond => return None,
            }
        }
        // Immediates must fit their instructions.
        for e in &p.emit {
            let vals: Vec<Option<i64>> = e
                .args
                .iter()
                .map(|a| match a {
                    Src::Imm(v) => Some(*v),
                    Src::Param(i) if p.params[*i].kind == Kind::Imm => {
                        params[*i].and_then(|t| self.imm_of(t, p.params[*i].bits))
                    }
                    _ => None,
                })
                .collect();
            if vals.iter().any(Option::is_some) && !self.fits(e.instr, vals) {
                return None;
            }
        }
        let extra_branch = next.is_some() && next != layout_next;
        let cost = (covered.len(), !extra_branch, -(p.emit.len() as i64) - materialize - i64::from(extra_branch));
        Some(Match { pat, params, next, covered, cost, extras })
    }

    fn best_match(&self, root: InstId, layout_next: Option<BlockId>) -> Option<Match> {
        let started = std::time::Instant::now();
        let m = self.best_match_inner(root, layout_next);
        stats::add(&stats::NANOS, started.elapsed().as_nanos() as u64);
        stats::add(&stats::ROOTS, 1);
        m
    }

    fn best_match_inner(&self, root: InstId, layout_next: Option<BlockId>) -> Option<Match> {
        let mut raw = Vec::new();
        let mut pending = vec![Term::Root(root)];
        let t0 = std::time::Instant::now();
        self.walk(0, &mut pending, &mut Vec::new(), &mut Vec::new(), root, &mut raw);
        stats::add(&stats::WALK_NANOS, t0.elapsed().as_nanos() as u64);
        let mut best: Option<Match> = None;
        stats::add(&stats::CANDIDATES, raw.len() as u64);
        for (pat, binds, covered) in raw {
            let Some(m) = self.validate(pat, &binds, covered, layout_next) else { continue };
            stats::add(&stats::VALID, 1);
            let better = match &best {
                None => true,
                Some(b) => m.cost > b.cost || (m.cost == b.cost && m.pat < b.pat),
            };
            if better {
                best = Some(m);
            }
        }
        best
    }

    // -----------------------------------------------------------------------
    // Choosing, bottom up

    fn is_free_cast(&self, i: InstId) -> bool {
        match &self.f.insts[i.index()].op {
            Op::Cast { op, .. } => {
                matches!(
                    op,
                    CastOp::Trunc | CastOp::BitCast | CastOp::PtrToInt | CastOp::IntToPtr | CastOp::AddrSpaceCast
                )
            }
            Op::Freeze(_) => true,
            _ => false,
        }
    }

    fn need_value(&mut self, v: Value) {
        if let Value::Local(x) = v
            && let LocalDef::Inst(i) = self.f.locals[x.index()].def
        {
            self.needed.insert(i);
        }
    }

    fn choose_block(&mut self, b: BlockId, layout_next: Option<BlockId>) -> Result<(), String> {
        let f = self.f;
        // Values used by other blocks or by phis are wanted in registers.
        let insts = f.blocks[b.index()].insts.clone();
        for &i in insts.iter().rev() {
            if self.covered.contains(&i) {
                continue;
            }
            let inst = &f.insts[i.index()];
            let wanted = inst.op.is_terminator() || side_effects(&inst.op) || self.needed.contains(&i);
            if !wanted {
                continue;
            }
            match &inst.op {
                Op::Phi { .. } => continue,
                Op::Call(call) if self.intrinsic_id(call).is_none() => {
                    for a in &call.args {
                        self.need_value(a.value);
                    }
                    self.need_value(call.callee);
                    continue;
                }
                Op::Ret(Some(v)) => {
                    self.need_value(*v);
                    continue;
                }
                Op::Br(_) => continue,
                Op::Alloca { .. } => continue,
                _ => {}
            }
            // A cast that a pattern covers with more (smulh ends in a
            // truncation) is matched; otherwise it is free.
            if self.is_free_cast(i)
                && let Some(m) = self.best_match(i, layout_next)
                && m.covered.len() > 1
            {
                for &c in &m.covered {
                    if c != i {
                        self.covered.insert(c);
                    }
                }
                for t in m.params.iter().flatten() {
                    if let Term::V(v) = t {
                        self.need_value(*v);
                    }
                }
                self.chosen.insert(i, m);
                continue;
            }
            if self.is_free_cast(i) {
                let mut wide = false;
                inst.op.for_each_value(|v| wide |= self.vbits(*v) > 64);
                if wide {
                    return self.err(format!("no instruction for `{}`", self.describe(i)));
                }
                inst.op.for_each_value(|v| {
                    if let Value::Local(x) = v
                        && let LocalDef::Inst(d) = f.locals[x.index()].def
                    {
                        self.needed.insert(d);
                    }
                });
                continue;
            }
            let Some(m) = self.best_match(i, layout_next) else {
                return self.err(format!("no instruction for `{}`", self.describe(i)));
            };
            for &c in &m.covered {
                if c != i {
                    self.covered.insert(c);
                    // A further result may have been chosen on its own
                    // already; this match computes it now.
                    self.chosen.remove(&c);
                }
            }
            for t in m.params.iter().flatten() {
                if let Term::V(v) = t {
                    self.need_value(*v);
                }
            }
            self.chosen.insert(i, m);
        }
        Ok(())
    }

    fn describe(&self, i: InstId) -> String {
        format!("{:?}", self.f.insts[i.index()].op)
    }

    // -----------------------------------------------------------------------
    // Emitting

    /// A register holding value `v`, made in the current block if `v` is a
    /// constant. `class` says whether the zero register will do for 0.
    fn reg_for(&mut self, v: Value, class: Class) -> Result<Reg, String> {
        match v {
            Value::Local(x) => Ok(Reg::V(self.vreg_of(x))),
            Value::Const(c) => self.const_reg(c, class),
            Value::Metadata(_) => self.err("metadata as an operand"),
        }
    }

    fn const_reg(&mut self, c: ConstId, class: Class) -> Result<Reg, String> {
        let k = self.cx.m.constant(c).clone();
        let bits = self.bits(k.ty);
        let wide = class.is_64() || bits > 32;
        let zr_ok = matches!(class, Class::W | Class::X);
        match &k.kind {
            ConstKind::Int(a) => {
                let v = sext(a.low_u64(), bits);
                self.int_reg(v, wide, zr_ok)
            }
            ConstKind::Null | ConstKind::Zero | ConstKind::Undef | ConstKind::Poison => self.int_reg(0, wide, zr_ok),
            _ => {
                let Some((g, off)) = prepare::const_address(self.cx, c) else {
                    return self.err(format!("unsupported constant {:?}", k.kind));
                };
                if self.hoisting() {
                    if let Some(&r) = self.hoisted_addr.get(&c) {
                        return Ok(Reg::V(r));
                    }
                    let saved = std::mem::take(&mut self.in_loop);
                    let r = self.in_entry(|s| s.const_reg(c, class));
                    self.in_loop = saved;
                    let r = r?;
                    if let Reg::V(x) = r {
                        self.hoisted_addr.insert(c, x);
                    }
                    return Ok(r);
                }
                let name = self.cx.m.global(g).name.clone().unwrap_or_default();
                let d = self.mf.new_vreg(true);
                let adrp = self.t.by_role("adrp");
                let pageoff = self.t.by_role("pageoff");
                self.push(MInst::new(adrp, vec![MOp::Reg(Reg::V(d)), MOp::Sym(name.clone())]));
                self.push(MInst::new(pageoff, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(d)), MOp::Sym(name)]));
                if off == 0 {
                    return Ok(Reg::V(d));
                }
                let r = self.mf.new_vreg(true);
                let add = self.t.by_name["ADDXri"];
                let sub = self.t.by_name["SUBXri_neg"];
                if self.t.instrs[add].fits(&[None, None, Some(off)]) {
                    self.push(MInst::new(add, vec![MOp::Reg(Reg::V(r)), MOp::Reg(Reg::V(d)), MOp::Imm(off)]));
                } else if self.t.instrs[sub].fits(&[None, None, Some(off)]) {
                    self.push(MInst::new(sub, vec![MOp::Reg(Reg::V(r)), MOp::Reg(Reg::V(d)), MOp::Imm(off)]));
                } else {
                    let o = self.int_reg(off, true, false)?;
                    let addr = self.t.by_name["ADDXrr"];
                    self.push(MInst::new(addr, vec![MOp::Reg(Reg::V(r)), MOp::Reg(Reg::V(d)), MOp::Reg(o)]));
                }
                Ok(Reg::V(r))
            }
        }
    }

    /// Runs `make` in the entry block, before its terminator, and returns
    /// what it made: for constants used in loops, made once.
    fn in_entry(&mut self, make: impl FnOnce(&mut Self) -> Result<Reg, String>) -> Result<Reg, String> {
        let cur = self.cur;
        let saved = std::mem::take(&mut self.mf.blocks[0].insts);
        self.cur = 0;
        let r = make(self);
        let made = std::mem::replace(&mut self.mf.blocks[0].insts, saved);
        let at = self.mf.blocks[0].term_start.min(self.mf.blocks[0].insts.len());
        let n = made.len();
        self.mf.blocks[0].insts.splice(at..at, made);
        self.mf.blocks[0].term_start = at + n;
        self.cur = cur;
        r
    }

    fn hoisting(&self) -> bool {
        self.cur != 0 && self.in_loop.get(self.cur).copied().unwrap_or(false)
    }

    /// A register holding integer `v`.
    pub fn int_reg(&mut self, v: i64, wide: bool, zr_ok: bool) -> Result<Reg, String> {
        let v = if wide { v } else { v as i32 as i64 };
        if v == 0 && zr_ok {
            return Ok(Reg::P(31));
        }
        if self.hoisting() {
            if let Some(&r) = self.hoisted.get(&(v, wide)) {
                return Ok(Reg::V(r));
            }
            let r = self.in_entry(|s| s.make_int(v, wide))?;
            if let Reg::V(x) = r {
                self.hoisted.insert((v, wide), x);
            }
            return Ok(r);
        }
        self.make_int(v, wide)
    }

    fn make_int(&mut self, v: i64, wide: bool) -> Result<Reg, String> {
        let d = self.mf.new_vreg(wide);
        // One instruction, if the description has one that holds it.
        for &ci in &self.t.constants {
            let ins = &self.t.instrs[ci];
            if (ins.operands[0].bits > 32) != wide {
                continue;
            }
            if ins.fits(&[None, Some(v)]) {
                self.push(MInst::new(ci, vec![MOp::Reg(Reg::V(d)), MOp::Imm(v)]));
                return Ok(Reg::V(d));
            }
        }
        // Otherwise sixteen bits at a time.
        let (movz, movk, pieces) = if wide {
            (self.t.by_role("movz.x"), self.t.by_role("movk.x"), 4)
        } else {
            (self.t.by_role("movz.w"), self.t.by_role("movk.w"), 2)
        };
        let u = v as u64;
        let chunks: Vec<(i64, i64)> =
            (0..pieces).map(|k| (((u >> (16 * k)) & 0xffff) as i64, 16 * k as i64)).filter(|(c, _)| *c != 0).collect();
        let (first, rest) = chunks.split_first().expect("zero is made above");
        self.push(MInst::new(movz, vec![MOp::Reg(Reg::V(d)), MOp::Imm(first.0), MOp::Imm(first.1)]));
        for &(c, sh) in rest {
            self.push(MInst::new(movk, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(d)), MOp::Imm(c), MOp::Imm(sh)]));
        }
        Ok(Reg::V(d))
    }

    fn set_zbits(&mut self, r: Reg, z: u32) {
        if let Reg::V(v) = r {
            self.zbits.insert(v, z);
        }
    }

    fn emit_match(&mut self, root: InstId, m: &Match, layout_next: Option<BlockId>) -> Result<(), String> {
        let p = self.t.patterns[m.pat].clone();
        // Zero extension of a value whose top is already zero is a copy.
        if let Op::Cast { op: CastOp::ZExt, value: Value::Local(x), .. } = self.f.insts[root.index()].op
            && p.nodes == 1
        {
            let from = self.bits(self.f.locals[x.index()].ty);
            let src = self.vreg_of(x);
            if self.zbits.get(&src).is_some_and(|&z| z <= from) {
                let r = self.f.insts[root.index()].result.unwrap();
                if self.alias(r, Value::Local(x)) {
                    return Ok(());
                }
                let d = self.vreg_of(r);
                self.push(MInst::copy(Reg::V(d), Reg::V(src)));
                self.zbits.insert(d, from);
                return Ok(());
            }
        }
        let mut vals: Vec<Option<MOp>> = vec![None; p.params.len()];
        for (i, pp) in p.params.iter().enumerate() {
            let Some(t) = m.params[i] else { continue };
            vals[i] = Some(match (pp.kind, t) {
                (Kind::Reg(class), Term::V(v)) => MOp::Reg(self.reg_for(v, class)?),
                (Kind::Imm, t) => MOp::Imm(self.imm_of(t, pp.bits).unwrap()),
                (Kind::Label, Term::B(b)) => MOp::Label(self.bmap[&b]),
                _ => return self.err("bad operand"),
            });
        }
        let result = self.f.insts[root.index()].result.map(|r| self.vreg_of(r));
        let mut temps: HashMap<usize, VReg> = HashMap::new();
        for (k, e) in p.emit.iter().enumerate() {
            let ins = &self.t.instrs[e.instr];
            let mut ops = Vec::new();
            for (j, a) in e.args.iter().enumerate() {
                ops.push(match a {
                    Src::Result => MOp::Reg(Reg::V(result.ok_or("pattern result without a value")?)),
                    Src::Param(i) => vals[*i].clone().ok_or("an unbound pattern operand")?,
                    Src::Imm(v) => MOp::Imm(*v),
                    Src::Temp(t) => {
                        let wide = ins.operands[j].bits > 32;
                        let v = *temps.entry(*t).or_insert_with(|| self.mf.new_vreg(wide));
                        let _ = k;
                        MOp::Reg(Reg::V(v))
                    }
                });
            }
            // Further results: the base is copied into the register that
            // receives the stepped value, which the instruction updates.
            if k == 0 {
                for &(x, operand) in &m.extras {
                    let r = self.f.insts[x.index()].result.ok_or("a further result without a value")?;
                    let rx = self.vreg_of(r);
                    let MOp::Reg(src) = ops[operand] else {
                        return self.err("a write-back operand that is not a register");
                    };
                    self.push(MInst::copy(Reg::V(rx), src));
                    ops[operand] = MOp::Reg(Reg::V(rx));
                }
            }
            let z = ins.zext;
            if ins.has_result
                && let MOp::Reg(r) = ops[0]
            {
                self.set_zbits(r, z);
            }
            self.push(MInst::new(e.instr, ops));
        }
        if let Some(n) = m.next
            && Some(n) != layout_next
        {
            let b = self.t.by_name["B"];
            let target = self.bmap[&n];
            self.push(MInst::new(b, vec![MOp::Label(target)]));
        }
        Ok(())
    }

    fn emit_call(&mut self, i: InstId) -> Result<(), String> {
        let f = self.f;
        let inst = &f.insts[i.index()];
        let Op::Call(call) = &inst.op else { unreachable!() };
        let name = prepare::callee_name(self.cx.m, call);
        let mut args: Vec<&CallArg> = call.args.iter().collect();
        let mut target = name.clone();
        if let Some(n) = &name
            && n.starts_with("llvm.")
        {
            target = Some(match n.as_str() {
                s if s.starts_with("llvm.memcpy.") => "memcpy".to_string(),
                s if s.starts_with("llvm.memmove.") => "memmove".to_string(),
                s if s.starts_with("llvm.memset.") => "memset".to_string(),
                s if s.starts_with("llvm.trap") => {
                    let brk = self.t.by_name["BRK"];
                    self.push(MInst::new(brk, vec![]));
                    return Ok(());
                }
                s => return self.err(format!("intrinsic {s} is not supported yet")),
            });
            args.truncate(3);
        }
        if let Type::Function { varargs: true, .. } = self.cx.m.types.get(call.fn_ty) {
            return self.err("calls to variadic functions are not supported yet");
        }
        if args.len() > ARG_REGS {
            return self.err("calls with more than eight arguments are not supported yet");
        }
        // Arguments into x0-x7, extended as their attributes say.
        let mut regs = Vec::new();
        for a in &args {
            let bits = self.vbits(a.value);
            let wide = bits > 32;
            let mut r = self.reg_for(a.value, if wide { Class::X } else { Class::W })?;
            r = self.extend_for_abi(r, bits, &a.attrs)?;
            regs.push((r, wide));
        }
        let callee_reg = match (&target, call.callee) {
            (Some(_), _) => None,
            (None, v) => Some(self.reg_for(v, Class::X)?),
        };
        for (k, (r, wide)) in regs.iter().enumerate() {
            let _ = wide;
            self.push(MInst::copy(Reg::P(k as u8), *r));
        }
        let mut inst_m = match (&target, callee_reg) {
            (Some(s), _) => MInst::new(self.t.by_role("call"), vec![MOp::Sym(s.clone())]),
            (None, Some(r)) => MInst::new(self.t.by_role("callr"), vec![MOp::Reg(r)]),
            _ => unreachable!(),
        };
        inst_m.imp_uses = (0..regs.len() as u8).collect();
        inst_m.imp_defs = crate::regalloc::CALL_CLOBBERS.to_vec();
        self.push(inst_m);
        if let Some(r) = inst.result
            && self.uses[r.index()] > 0
        {
            let d = self.vreg_of(r);
            self.push(MInst::copy(Reg::V(d), Reg::P(0)));
        }
        Ok(())
    }

    /// Narrow arguments and results are extended by the caller (callee for
    /// results) when marked `zeroext` or `signext`, as Apple's ABI asks.
    fn extend_for_abi(&mut self, r: Reg, bits: u32, attrs: &[Attr]) -> Result<Reg, String> {
        if bits >= 32 {
            return Ok(r);
        }
        let has = |w: &str| attrs.iter().any(|a| matches!(a, Attr::Word(x) if x == w));
        let name = match (has("zeroext"), has("signext"), bits) {
            (true, _, 1) => "UXT1W",
            (true, _, 8) => "UXTBW",
            (true, _, 16) => "UXTHW",
            (_, true, 1) => "SBFX1W",
            (_, true, 8) => "SXTBW",
            (_, true, 16) => "SXTHW",
            _ => return Ok(r),
        };
        let d = self.mf.new_vreg(false);
        self.push(MInst::new(self.t.by_name[name], vec![MOp::Reg(Reg::V(d)), MOp::Reg(r)]));
        Ok(Reg::V(d))
    }

    fn emit_block(&mut self, b: BlockId, layout_next: Option<BlockId>) -> Result<(), String> {
        let f = self.f;
        self.cur = self.bmap[&b];
        let insts = f.blocks[b.index()].insts.clone();
        for &i in &insts {
            let inst = &f.insts[i.index()];
            if inst.op.is_terminator() {
                self.mf.blocks[self.cur].term_start = self.mf.blocks[self.cur].insts.len();
            }
            if self.covered.contains(&i) {
                continue;
            }
            match &inst.op {
                Op::Phi { .. } => continue,
                Op::Call(_) if !self.chosen.contains_key(&i) => {
                    self.emit_call(i)?;
                    continue;
                }
                Op::Ret(v) => {
                    if let Some(v) = v {
                        let bits = self.vbits(*v);
                        let wide = bits > 32;
                        let r = self.reg_for(*v, if wide { Class::X } else { Class::W })?;
                        let r = self.extend_for_abi(r, bits, &f.ret_attrs)?;
                        self.push(MInst::copy(Reg::P(0), r));
                    }
                    let mut ret = MInst::new(self.t.by_name["RET"], vec![]);
                    if v.is_some() {
                        ret.imp_uses = vec![0];
                    }
                    self.push(ret);
                    continue;
                }
                Op::Br(d) => {
                    if Some(*d) != layout_next {
                        let target = self.bmap[d];
                        self.push(MInst::new(self.t.by_name["B"], vec![MOp::Label(target)]));
                    }
                    continue;
                }
                Op::Alloca { ty, count, align, .. } => {
                    let Some(r) = inst.result else { continue };
                    if self.uses[r.index()] == 0 {
                        continue;
                    }
                    let n = count.and_then(|c| self.cx.const_int(c)).unwrap_or(1) as u64;
                    let size = self.cx.size_of(*ty)? * n;
                    let align = align.unwrap_or(8).max(1);
                    self.mf.slots.push(Slot { size: size.max(1), align, offset: 0 });
                    let slot = self.mf.slots.len() - 1;
                    let d = self.vreg_of(r);
                    self.push(MInst::new(
                        self.t.by_name["ADDXri"],
                        vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::P(31)), MOp::Frame(slot, 0)],
                    ));
                    continue;
                }
                _ => {}
            }
            if self.is_free_cast(i) && !self.chosen.contains_key(&i) {
                let Some(r) = inst.result else { continue };
                if !self.needed.contains(&i) {
                    continue;
                }
                let mut src = None;
                inst.op.for_each_value(|v| src = Some(*v));
                let v = src.unwrap();
                if self.alias(r, v) {
                    continue;
                }
                let bits = self.vbits(v);
                let s = self.reg_for(v, if bits > 32 { Class::X } else { Class::W })?;
                let d = self.vreg_of(r);
                self.push(MInst::copy(Reg::V(d), s));
                continue;
            }
            if let Some(m) = self.chosen.get(&i).cloned() {
                self.emit_match(i, &m, layout_next)?;
            }
        }
        Ok(())
    }

    /// Phis become copies at the end of each predecessor, through
    /// temporaries so that values swapped between phis stay right.
    fn emit_phi_copies(&mut self) -> Result<(), String> {
        let f = self.f;
        for &s in &f.layout {
            let phis: Vec<InstId> =
                f.blocks[s.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect();
            if phis.is_empty() {
                continue;
            }
            let mut preds: Vec<BlockId> = Vec::new();
            for &phi in &phis {
                if let Op::Phi { incoming, .. } = &f.insts[phi.index()].op {
                    for (_, p) in incoming {
                        if !preds.contains(p) {
                            preds.push(*p);
                        }
                    }
                }
            }
            for p in preds {
                let pb = self.bmap[&p];
                let saved = std::mem::take(&mut self.mf.blocks[pb].insts);
                let at = self.mf.blocks[pb].term_start.min(saved.len());
                self.cur = pb;
                let mut finals = Vec::new();
                for &phi in &phis {
                    let Op::Phi { incoming, .. } = &f.insts[phi.index()].op else { unreachable!() };
                    let r = f.insts[phi.index()].result.unwrap();
                    if self.uses[r.index()] == 0 {
                        continue;
                    }
                    let Some(&(v, _)) = incoming.iter().find(|(_, from)| *from == p) else { continue };
                    let wide = self.bits(f.locals[r.index()].ty) > 32;
                    let src = self.reg_for(v, if wide { Class::X } else { Class::W })?;
                    let tmp = self.mf.new_vreg(wide);
                    self.push(MInst::copy(Reg::V(tmp), src));
                    let d = self.vreg_of(r);
                    finals.push(MInst::copy(Reg::V(d), Reg::V(tmp)));
                }
                let mut copies = std::mem::take(&mut self.mf.blocks[pb].insts);
                copies.extend(finals);
                let mut insts = saved;
                let n = copies.len();
                insts.splice(at..at, copies);
                self.mf.blocks[pb].insts = insts;
                self.mf.blocks[pb].term_start = at + n;
            }
        }
        Ok(())
    }

    pub fn run(mut self) -> Result<MFunc, String> {
        let f = self.f;
        let layout = f.layout.clone();
        // Values used by phis or in other blocks are wanted in registers.
        for &b in &layout {
            for &i in &f.blocks[b.index()].insts {
                let phi = f.insts[i.index()].op.is_phi();
                f.insts[i.index()].op.for_each_value(|v| {
                    if let Value::Local(x) = v
                        && let LocalDef::Inst(d) = f.locals[x.index()].def
                        && (phi || self.inst_block[d.index()] != Some(b))
                    {
                        self.needed.insert(d);
                    }
                });
            }
        }
        // Choose bottom-up: later blocks first, so values they need are
        // known when the blocks defining them are covered.
        for (k, &b) in layout.iter().enumerate().rev() {
            let next = layout.get(k + 1).copied();
            self.choose_block(b, next)?;
        }
        // Arguments arrive in x0-x7.
        self.cur = 0;
        if f.params.len() > ARG_REGS {
            return self.err("functions with more than eight parameters are not supported yet");
        }
        for (k, p) in f.params.iter().enumerate() {
            if self.uses[p.local.index()] == 0 {
                continue;
            }
            let d = self.vreg_of(p.local);
            self.push(MInst::copy(Reg::V(d), Reg::P(k as u8)));
        }
        // Which blocks are on a cycle: those that reach themselves.
        let n = layout.len();
        let succ: Vec<Vec<usize>> =
            layout.iter().map(|b| f.successors(*b).iter().map(|s| self.bmap[s]).collect()).collect();
        self.in_loop = (0..n)
            .map(|start| {
                let mut seen = vec![false; n];
                let mut stack = succ[start].clone();
                while let Some(x) = stack.pop() {
                    if x == start {
                        return true;
                    }
                    if !std::mem::replace(&mut seen[x], true) {
                        stack.extend(succ[x].iter().copied());
                    }
                }
                false
            })
            .collect();
        for (k, &b) in layout.iter().enumerate() {
            let next = layout.get(k + 1).copied();
            self.emit_block(b, next)?;
            let succs = f.successors(b).iter().map(|s| self.bmap[s]).collect();
            self.mf.blocks[self.bmap[&b]].succs = succs;
        }
        self.emit_phi_copies()?;
        Ok(self.mf)
    }
}
