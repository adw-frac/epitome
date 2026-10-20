//! Instruction selection: covering each block's IR with patterns from the
//! machine description, longest match first. See `docs/design/isel.md`.

use std::collections::{HashMap, HashSet};

use epitome_ir::module::*;
use epitome_ir::types::{Type, TypeId};

use crate::machine::{Holds, Narrow};
use crate::mir::*;
use crate::prepare::{self, Ctx};
use crate::target::{Class, Head, Key, Kind, Src, Target, bin_bits, sext, wide_bits};

/// The arrangement of a vector of `len` lanes of `bits` bits: `4s`, `16b`.
pub fn arrangement(len: u32, bits: u32) -> String {
    format!("{len}{}", lane_suffix(bits))
}

pub fn lane_suffix(bits: u32) -> &'static str {
    match bits {
        8 => "b",
        16 => "h",
        32 => "s",
        _ => "d",
    }
}

/// A value or block being matched against a pattern.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
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
    /// Higher is better: the IR instructions it covers less the machine
    /// instructions it emits and the constants it must make in registers;
    /// then more covered; then no branch added.
    cost: (i64, usize, bool),
    /// Instructions whose values are further results, and the operand of
    /// the first emitted instruction that receives each.
    extras: Vec<(InstId, usize)>,
}

/// Counters for measuring the matcher: roots matched, trie steps taken,
/// candidate matches found, and those that passed validation.
/// Matching counts, for `--stats`: counted per thread (shared counters
/// would make every match contend for their cache line), and added to the
/// totals by `flush` when a thread finishes.
pub mod stats {
    use std::cell::Cell;
    use std::sync::atomic::{AtomicU64, Ordering};

    pub struct Counter {
        total: AtomicU64,
        slot: usize,
    }

    pub static ROOTS: Counter = Counter { total: AtomicU64::new(0), slot: 0 };
    pub static STEPS: Counter = Counter { total: AtomicU64::new(0), slot: 1 };
    pub static CANDIDATES: Counter = Counter { total: AtomicU64::new(0), slot: 2 };
    pub static VALID: Counter = Counter { total: AtomicU64::new(0), slot: 3 };
    pub static NANOS: Counter = Counter { total: AtomicU64::new(0), slot: 4 };
    pub static WALK_NANOS: Counter = Counter { total: AtomicU64::new(0), slot: 5 };
    const ALL: [&Counter; 6] = [&ROOTS, &STEPS, &CANDIDATES, &VALID, &NANOS, &WALK_NANOS];

    thread_local! {
        static LOCAL: [Cell<u64>; 6] = const { [const { Cell::new(0) }; 6] };
    }

    pub fn add(c: &Counter, n: u64) {
        LOCAL.with(|l| l[c.slot].set(l[c.slot].get() + n));
    }

    /// Adds this thread's counts to the totals.
    pub fn flush() {
        LOCAL.with(|l| {
            for c in ALL {
                c.total.fetch_add(l[c.slot].replace(0), Ordering::Relaxed);
            }
        });
    }

    pub fn get(c: &Counter) -> u64 {
        c.total.load(Ordering::Relaxed)
    }
}

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
    /// The instructions of each block by their head and first operand, in
    /// block order: where `find_extra` looks for a pattern's extra root,
    /// without scanning the rest of the block for each one.
    by_head: HashMap<(BlockId, Head, Term), Vec<InstId>>,
    /// The block being emitted, and its place in the layout.
    cur: usize,
    /// Blocks on a cycle.
    in_loop: Vec<bool>,
    /// Constants made once in the entry block, for use in loops.
    hoisted: HashMap<(i64, bool), VReg>,
    /// Constants made in registers in each block, by (block, value, wide)
    /// for integers and (block, bits, class) for floating point: a later
    /// use in the same block takes the same register.
    block_ints: HashMap<(usize, i64, bool), VReg>,
    block_floats: HashMap<(usize, u64, Class), VReg>,
    /// The addresses of globals made in each block, for later uses there.
    block_addrs: HashMap<(usize, ConstId), VReg>,
    /// `move_wide_of` for 32 and 64 bits.
    move_wide: [Option<(usize, usize, u32)>; 2],
    hoisted_addr: HashMap<ConstId, VReg>,
    /// The registers holding each part of a small struct parameter.
    agg_params: HashMap<LocalId, Vec<VReg>>,
    /// Where a variadic function's variable arguments start, from the
    /// stack pointer on entry.
    va_offset: i64,
    /// AAPCS64's register save areas of a variadic function: the slots
    /// and sizes of the integer and the vector registers' areas.
    va_areas: Option<(usize, i64, usize, i64)>,
    /// Blocks that end in a tail call: they have no successors, and no
    /// copies for phis.
    tail_blocks: HashSet<BlockId>,
    /// For the next call emitted, from an invoke: its landing pad's block
    /// and action.
    landing_next: Option<(usize, usize)>,
}

/// The inline assembly a call calls, if it does.
fn inline_asm<'m>(m: &'m Module, call: &Call) -> Option<&'m InlineAsm> {
    let Value::Const(c) = call.callee else { return None };
    match &m.constant(c).kind {
        ConstKind::InlineAsm(a) => Some(a),
        _ => None,
    }
}

/// One constraint of inline assembly (LLVM's syntax: `=&r`, `*m`, `0`,
/// `{x0}`, `~{memory}`).
#[derive(Debug, Default)]
struct Constraint {
    output: bool,
    early: bool,
    indirect: bool,
    clobber: bool,
    /// The codes of its first alternative: letters, a register, a digit.
    codes: String,
}

fn parse_constraints(text: &str) -> Vec<Constraint> {
    let mut out = Vec::new();
    for part in text.split(',').filter(|p| !p.is_empty()) {
        let mut c = Constraint::default();
        let mut rest = part;
        if let Some(r) = rest.strip_prefix('~') {
            c.clobber = true;
            rest = r;
        }
        if let Some(r) = rest.strip_prefix('=') {
            c.output = true;
            rest = r;
        }
        if let Some(r) = rest.strip_prefix('&') {
            c.early = true;
            rest = r;
        }
        if let Some(r) = rest.strip_prefix('*') {
            c.indirect = true;
            rest = r;
        }
        c.codes = rest.split('|').next().unwrap_or("").to_string();
        out.push(c);
    }
    out
}

/// Roughly how many instructions an inline assembly template is: its
/// statements that are not labels, directives or comments.
fn statements(template: &str, comment: &str) -> u32 {
    template
        .split(['\n', ';'])
        .map(|l| {
            let l = l.split(comment).next().unwrap_or("").trim();
            // Leading labels.
            let mut l = l;
            while let Some((label, rest)) = l.split_once(':')
                && !label.is_empty()
                && label.chars().all(|c| c.is_alphanumeric() || c == '_' || c == '.' || c == '$')
            {
                l = rest.trim();
            }
            l.to_string()
        })
        .filter(|l| !l.is_empty() && !l.starts_with('.'))
        .count() as u32
}

fn side_effects(op: &Op) -> bool {
    matches!(
        op,
        Op::Store { .. }
            | Op::Call(_)
            | Op::Fence { .. }
            | Op::AtomicRmw { .. }
            | Op::CmpXchg { .. }
            | Op::VaArg { .. }
    ) || matches!(op, Op::Load { volatile: true, .. } | Op::Load { atomic: Some(_), .. })
}

impl<'a, 'b> Sel<'a, 'b> {
    pub fn new(
        t: &'a Target,
        abi: &crate::abi::Abi,
        cx: &'a mut Ctx<'b>,
        f: &'a Function,
        fname: &str,
        global: bool,
    ) -> Self {
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
            vclass: Vec::new(),
            asms: Vec::new(),
            slots: Vec::new(),
            frame_size: 0,
            out_size: 0,
            abi: abi.clone(),
            dynamic_stack: false,
            eh: None,
        };
        // A function whose stack pointer moves addresses its frame from a
        // saved register of the convention's, kept from allocation.
        let dynamic = f.insts.iter().any(|i| match &i.op {
            Op::Alloca { count: Some(c), .. } => cx.const_int(*c).is_none(),
            Op::Call(call) => prepare::callee_name(cx.m, call).is_some_and(|n| n.starts_with("llvm.stackrestore")),
            _ => false,
        });
        if dynamic {
            mf.dynamic_stack = true;
            if let Some(b) = abi.base {
                mf.abi.reserved.push(b);
            }
        }
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
            by_head: HashMap::new(),
            cur: 0,
            in_loop: Vec::new(),
            hoisted: HashMap::new(),
            block_ints: HashMap::new(),
            block_floats: HashMap::new(),
            block_addrs: HashMap::new(),
            move_wide: [move_wide_of(t, false), move_wide_of(t, true)],
            hoisted_addr: HashMap::new(),
            agg_params: HashMap::new(),
            va_offset: 0,
            va_areas: None,
            tail_blocks: HashSet::new(),
            landing_next: None,
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
        crate::target::type_bits(self.cx.m, ty)
    }

    fn is_vector(&self, ty: TypeId) -> bool {
        crate::target::is_vector_type(self.cx.m, ty)
    }

    fn vbits(&self, v: Value) -> u32 {
        self.bits(self.ty_of(v))
    }

    fn is_fp(&self, ty: TypeId) -> bool {
        crate::target::is_fp_type(self.cx.m, ty)
    }

    fn hbits(&self, ty: TypeId) -> u32 {
        crate::target::head_bits(self.cx.m, ty)
    }

    fn vhbits(&self, v: Value) -> u32 {
        self.hbits(self.ty_of(v))
    }

    /// What a value of this type is.
    fn holds(&self, ty: TypeId) -> Holds {
        if self.is_vector(ty) {
            Holds::Vector
        } else if self.is_fp(ty) {
            Holds::Float
        } else {
            Holds::Int
        }
    }

    /// The register class a value of this type lives in (the description's
    /// narrowest that holds it).
    fn class_of_ty(&self, ty: TypeId) -> Class {
        let bits = self.bits(ty).max(1);
        let m = &self.t.machine;
        m.value_class(self.holds(ty), bits)
            .or_else(|| m.value_class(Holds::Int, 64))
            .expect("the description has an integer register class")
    }

    /// The class of integers of 64 bits (`wide`) or 32, as pointers and
    /// integers are held.
    fn int_class(&self, wide: bool) -> Class {
        let m = &self.t.machine;
        m.value_class(Holds::Int, if wide { 64 } else { 32 })
            .or_else(|| m.value_class(Holds::Int, 64))
            .expect("the description has an integer register class")
    }

    /// A virtual integer register of 64 bits (`wide`) or 32.
    fn ivreg(&mut self, wide: bool) -> VReg {
        let c = self.int_class(wide);
        self.mf.new_vreg(c)
    }

    /// Does this class hold floating-point values or vectors (which go in
    /// the convention's fp registers)?
    fn fp_class(&self, c: Class) -> bool {
        matches!(self.t.machine.def(c).holds, Some(Holds::Float | Holds::Vector))
    }

    fn class_of(&self, v: Value) -> Class {
        self.class_of_ty(self.ty_of(v))
    }

    fn vreg_of(&mut self, x: LocalId) -> VReg {
        if let Some(&v) = self.vreg.get(&x) {
            return v;
        }
        let ty = self.f.locals[x.index()].ty;
        let class = self.class_of_ty(ty);
        let v = self.mf.new_vreg(class);
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
        let res_hbits = inst.result.map(|r| self.hbits(f.locals[r.index()].ty)).unwrap_or(0);
        let v = Term::V;
        Some(match &inst.op {
            Op::FCmp { pred, lhs, rhs, .. } => (Head::FCmp(*pred, self.vbits(*lhs)), vec![v(*lhs), v(*rhs)]),
            Op::FNeg { value, .. } => (Head::FNeg(res_hbits), vec![v(*value)]),
            Op::Binary { op, lhs, rhs, .. } => {
                let b = if res_hbits & crate::target::VEC != 0 { res_hbits } else { bin_bits(*op, res_bits) };
                (Head::Bin(*op, b), vec![v(*lhs), v(*rhs)])
            }
            Op::ICmp { pred, lhs, rhs, .. } => {
                let hb = self.vhbits(*lhs);
                let b = if hb & crate::target::VEC != 0 { hb } else { self.vbits(*lhs) };
                (Head::ICmp(*pred, b), vec![v(*lhs), v(*rhs)])
            }
            Op::InsertElement { vector, element, index } => {
                (Head::InsertElement(res_hbits), vec![v(*vector), v(*element), v(*index)])
            }
            Op::ExtractElement { vector, index } => {
                (Head::ExtractElement(self.vhbits(*vector)), vec![v(*vector), v(*index)])
            }
            Op::ShuffleVector { a, b, mask } => {
                let lanes = crate::target::mask_lanes(self.cx.m, *mask)?;
                let id = self.t.find_mask(&lanes)?;
                (Head::Shuffle(id, res_hbits), vec![v(*a), v(*b)])
            }
            Op::Select { cond, then_value, else_value, .. } => {
                (Head::Select(wide_bits(res_hbits)), vec![v(*cond), v(*then_value), v(*else_value)])
            }
            Op::Cast { op, value, .. } => (Head::Cast(*op, self.vhbits(*value), wide_bits(res_hbits)), vec![v(*value)]),
            Op::Load { ptr, atomic, .. } if crate::target::acquires(atomic) => {
                (Head::LoadAcq(res_hbits), vec![v(*ptr)])
            }
            Op::Load { ptr, .. } => (Head::Load(res_hbits), vec![v(*ptr)]),
            Op::Store { value, ptr, atomic, .. } if crate::target::releases(atomic) => {
                (Head::StoreRel(self.vhbits(*value)), vec![v(*value), v(*ptr)])
            }
            Op::Store { value, ptr, .. } => (Head::Store(self.vhbits(*value)), vec![v(*value), v(*ptr)]),
            Op::Fence { ordering, .. } => (Head::Fence(*ordering == Ordering::Acquire), vec![]),
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
        crate::target::lit_of(self.cx.m, c).map(|(v, b)| Key::Lit(v, b))
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
            // A floating-point constant: its bits.
            ConstKind::Float(raw) => Some(*raw as i64),
            // A vector whose lanes are all the same: the lane, as for a
            // shift by a splat.
            _ if self.is_vector(k.ty) => {
                crate::target::lit_of(self.cx.m, c).map(|(v, _)| v).filter(|&v| v != crate::target::UNDEF)
            }
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
        // Those with the same head and, its first leaf being bound (the
        // base of a post-increment), the same first operand; else all the
        // rest of the block.
        let first = match kids.first() {
            Some(crate::target::Tree::Leaf(p)) => params[*p],
            _ => None,
        };
        let at = self.pos[root.index()];
        let later: &[InstId] = match first {
            Some(v) => {
                let list = self.by_head.get(&(b, *h, v)).map_or(&[][..], Vec::as_slice);
                &list[list.partition_point(|x| self.pos[x.index()] <= at)..]
            }
            None => &self.f.blocks[b.index()].insts[at + 1..],
        };
        for &x in later {
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
                    let ty = self.ty_of(v);
                    let bits = self.bits(ty);
                    let def = self.t.machine.def(class);
                    let holds = self.holds(ty);
                    if bits == 0
                        || def.holds != Some(holds)
                        || (holds == Holds::Vector && bits != def.bits)
                        || (holds != Holds::Vector && (bits > 64 || (bits > 32) != (pp.bits > 32)))
                    {
                        return None;
                    }
                    if let Value::Const(_) = v {
                        let zr = def.holds == Some(Holds::Int) && self.t.machine.zero_in(class) && self.is_zero_like(t);
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
        // A pattern covering more is better only if what it saves is not
        // spent again on instructions and on making constants in
        // registers: `mul x, 5` then `add 20` is `add w, w0, w0, lsl #2`
        // and an add, not `madd` with both constants made. Ties go to the
        // pattern covering more, since what another leaves uncovered still
        // costs an instruction.
        let spent = p.emit.len() as i64 + materialize;
        let cost = (covered.len() as i64 - spent, covered.len(), !extra_branch);
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
        let mut best_single: Option<Match> = None;
        stats::add(&stats::CANDIDATES, raw.len() as u64);
        for (pat, binds, covered) in raw {
            // Not with an instruction whose features are off.
            if !self.t.patterns[pat].emit.iter().all(|e| self.cx.enabled(e.instr)) {
                continue;
            }
            let Some(m) = self.validate(pat, &binds, covered, layout_next) else { continue };
            stats::add(&stats::VALID, 1);
            let better = |best: &Option<Match>| match best {
                None => true,
                Some(b) => m.cost > b.cost || (m.cost == b.cost && m.pat < b.pat),
            };
            if m.covered.len() == 1 && better(&best_single) {
                best_single = Some(m.clone());
            }
            if better(&best) {
                best = Some(m);
            }
        }
        // A pattern covering several instructions (a load folded into an
        // add, a post-increment) is elective (autochop) when one covering
        // only the root would do; without one, it is needed.
        match best {
            Some(b) if b.covered.len() > 1 && best_single.is_some() => {
                let name = &self.t.patterns[b.pat].name;
                if epitome_ir::chop::allow(|| {
                    format!("select {name} at {}", epitome_ir::printer::inst_name(self.f, root))
                }) {
                    Some(b)
                } else {
                    best_single
                }
            }
            b => b,
        }
    }

    // -----------------------------------------------------------------------
    // Choosing, bottom up

    fn is_free_cast(&self, i: InstId) -> bool {
        match &self.f.insts[i.index()].op {
            // Between the register files, a bit-cast is an fmov.
            Op::Cast { op: CastOp::BitCast, value, .. } => {
                let r = self.f.insts[i.index()].result.unwrap();
                self.is_fp(self.ty_of(*value)) == self.is_fp(self.f.locals[r.index()].ty)
                    && self.bits(self.ty_of(*value)) == self.bits(self.f.locals[r.index()].ty)
            }
            // A mask's lanes are already all ones or all zeros. Where 32-bit
            // values are kept sign-extended, extending one to 64 bits is
            // free (and truncating to 32 bits is not).
            Op::Cast { op: CastOp::SExt, value, .. } => {
                let r = self.f.insts[i.index()].result.unwrap();
                matches!(self.cx.m.types.get(self.ty_of(*value)), Type::Vector { elem, .. } if self.bits(*elem) == 1)
                    || (self.t.machine.narrow == Narrow::Sign
                        && self.bits(self.ty_of(*value)) == 32
                        && self.bits(self.f.locals[r.index()].ty) == 64)
            }
            Op::Cast { op: CastOp::Trunc, value, .. }
                if self.t.machine.narrow == Narrow::Sign
                    && self.bits(self.f.locals[self.f.insts[i.index()].result.unwrap().index()].ty) == 32
                    && !self.is_vector(self.ty_of(*value)) =>
            {
                false
            }
            // Scalar truncations read the low bits of the same register;
            // a vector's is xtn.
            Op::Cast { op, value, .. } => {
                matches!(
                    op,
                    CastOp::Trunc | CastOp::BitCast | CastOp::PtrToInt | CastOp::IntToPtr | CastOp::AddrSpaceCast
                ) && !self.is_vector(self.ty_of(*value))
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
                Op::Resume(v) => {
                    self.need_value(*v);
                    let mut cur = *v;
                    while let Value::Local(x) = cur
                        && let LocalDef::Inst(d) = f.locals[x.index()].def
                        && let Op::InsertValue { aggregate, element, .. } = &f.insts[d.index()].op
                    {
                        self.need_value(*element);
                        cur = *aggregate;
                    }
                    continue;
                }
                Op::LandingPad { .. } => continue,
                Op::Invoke { call, .. } | Op::Call(call) if self.intrinsic_id(call).is_none() => {
                    for a in &call.args {
                        self.need_value(a.value);
                        // The parts of a small struct argument.
                        let mut cur = a.value;
                        while let Value::Local(x) = cur
                            && let LocalDef::Inst(d) = f.locals[x.index()].def
                            && let Op::InsertValue { aggregate, element, .. } = &f.insts[d.index()].op
                        {
                            self.need_value(*element);
                            cur = *aggregate;
                        }
                    }
                    self.need_value(call.callee);
                    continue;
                }
                Op::Ret(Some(v)) => {
                    self.need_value(*v);
                    // The parts of a small aggregate result.
                    let mut cur = *v;
                    while let Value::Local(x) = cur
                        && let LocalDef::Inst(d) = f.locals[x.index()].def
                        && let Op::InsertValue { aggregate, element, .. } = &f.insts[d.index()].op
                    {
                        self.need_value(*element);
                        cur = *aggregate;
                    }
                    continue;
                }
                Op::Br(_) => continue,
                Op::Alloca { count: Some(c), .. } => {
                    self.need_value(*c);
                    continue;
                }
                Op::Alloca { .. } => continue,
                Op::VaArg { list } => {
                    self.need_value(*list);
                    continue;
                }
                // Small structs live as their parts: building one is done
                // by whatever uses it, and taking a part out is a copy.
                Op::InsertValue { .. } => continue,
                Op::ExtractValue { aggregate, indices } => {
                    let mut cur = *aggregate;
                    while let Value::Local(x) = cur
                        && let LocalDef::Inst(d) = f.locals[x.index()].def
                        && let Op::InsertValue { aggregate, element, indices: here } = &f.insts[d.index()].op
                    {
                        if here == indices {
                            self.need_value(*element);
                            break;
                        }
                        cur = *aggregate;
                    }
                    continue;
                }
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
                inst.op.for_each_value(|v| wide |= self.vbits(*v) > 64 && !self.is_vector(self.ty_of(*v)));
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
        // A global's address, made once per block.
        let address = !matches!(self.t.machine.def(class).holds, Some(Holds::Float | Holds::Vector))
            && !matches!(
                self.cx.m.constant(c).kind,
                ConstKind::Int(_)
                    | ConstKind::Null
                    | ConstKind::Zero
                    | ConstKind::Undef
                    | ConstKind::Poison
                    | ConstKind::Expr(ConstExpr::Cast { op: CastOp::IntToPtr, .. })
            );
        if !address {
            return self.const_reg_made(c, class);
        }
        if let Some(&r) = self.block_addrs.get(&(self.cur, c)) {
            return Ok(Reg::V(r));
        }
        let r = self.const_reg_made(c, class)?;
        if let Reg::V(x) = r {
            self.block_addrs.insert((self.cur, c), x);
        }
        Ok(r)
    }

    fn const_reg_made(&mut self, c: ConstId, class: Class) -> Result<Reg, String> {
        let k = self.cx.m.constant(c).clone();
        let holds = self.t.machine.def(class).holds;
        if holds == Some(Holds::Vector) {
            return self.vector_const(c, class);
        }
        // A floating-point constant: its bits, made in an integer register
        // and moved across (zero from the zero register).
        if holds == Some(Holds::Float) {
            let raw = match &k.kind {
                ConstKind::Float(raw) => *raw as u64,
                ConstKind::Zero | ConstKind::Undef | ConstKind::Poison => 0,
                other => return self.err(format!("unsupported floating-point constant {other:?}")),
            };
            if let Some(&r) = self.block_floats.get(&(self.cur, raw, class)) {
                return Ok(Reg::V(r));
            }
            // One instruction, if the description has one that holds it
            // (fmov's 8-bit immediate).
            if raw != 0 {
                for &ci in self.t.constants.iter().filter(|&&ci| self.cx.enabled(ci)) {
                    let ins = &self.t.instrs[ci];
                    let same_file = matches!(ins.operands[0].kind, Kind::Reg(c) if self.t.machine.def(c).file == self.t.machine.def(class).file);
                    if same_file
                        && ins.operands[0].bits == self.t.machine.def(class).bits.min(64)
                        && ins.fits(&[None, Some(raw as i64)])
                    {
                        let d = self.mf.new_vreg(class);
                        self.push(MInst::new(ci, vec![MOp::Reg(Reg::V(d)), MOp::Imm(raw as i64)]));
                        self.block_floats.insert((self.cur, raw, class), d);
                        return Ok(Reg::V(d));
                    }
                }
            }
            let wide = self.t.machine.def(class).bits > 32;
            let g = self.int_reg(raw as i64, wide, true)?;
            let d = self.mf.new_vreg(class);
            self.push(MInst::copy(Reg::V(d), g));
            self.block_floats.insert((self.cur, raw, class), d);
            return Ok(Reg::V(d));
        }
        let bits = self.bits(k.ty);
        let wide = self.t.machine.def(class).bits > 32 || bits > 32;
        let zr_ok = self.t.machine.zero_in(class);
        match &k.kind {
            ConstKind::Int(a) => {
                // A boolean is read by its lowest bit only: true is 1 (one
                // `mov`, and already its zero extension), not -1.
                let v = if bits == 1 { (a.low_u64() & 1) as i64 } else { sext(a.low_u64(), bits) };
                self.int_reg(v, wide, zr_ok)
            }
            ConstKind::Null | ConstKind::Zero | ConstKind::Undef | ConstKind::Poison => self.int_reg(0, wide, zr_ok),
            // An integer made a pointer is the integer.
            ConstKind::Expr(ConstExpr::Cast { op: CastOp::IntToPtr, value })
                if matches!(self.cx.m.constant(*value).kind, ConstKind::Int(_)) =>
            {
                let ConstKind::Int(a) = &self.cx.m.constant(*value).kind else { unreachable!() };
                self.int_reg(a.low_u64() as i64, true, zr_ok)
            }
            _ => {
                let Some((g, off)) = prepare::const_address(self.cx, c) else {
                    return self.err(format!("unsupported constant {:?}", k.kind));
                };
                if let Some(&r) = self.hoisted_addr.get(&c).filter(|_| self.hoisting()) {
                    return Ok(Reg::V(r));
                }
                if self.hoisting()
                    && epitome_ir::chop::allow(|| {
                        format!(
                            "hoist the address of @{} out of the loop",
                            self.cx.m.global(g).name.as_deref().unwrap_or("?")
                        )
                    })
                {
                    let saved = std::mem::take(&mut self.in_loop);
                    let r = self.in_entry(|s| s.const_reg(c, class));
                    self.in_loop = saved;
                    let r = r?;
                    if let Reg::V(x) = r {
                        self.hoisted_addr.insert(c, x);
                    }
                    return Ok(r);
                }
                let gl = self.cx.m.global(g);
                let name = gl.name.clone().unwrap_or_default();
                // Symbols defined elsewhere (another library) are reached
                // through the global offset table, which the loader fills in.
                let declared_only = match &gl.kind {
                    GlobalKind::Function(f) => !f.has_body,
                    GlobalKind::Variable(v) => v.init.is_none(),
                    _ => false,
                };
                let via_got = self.t.machine.external_via_got
                    && (declared_only
                        || (!gl.props.dso_local && !matches!(gl.props.linkage, Linkage::Internal | Linkage::Private)));
                let d = self.ivreg(true);
                if via_got {
                    let adrp = self.t.by_role("got.hi");
                    let ldr = self.t.by_role("got.lo");
                    self.push(MInst::new(adrp, vec![MOp::Reg(Reg::V(d)), MOp::Sym(name.clone())]));
                    self.push(MInst::new(ldr, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(d)), MOp::Sym(name)]));
                } else {
                    let adrp = self.t.by_role("addr.hi");
                    let pageoff = self.t.by_role("addr.lo");
                    self.push(MInst::new(adrp, vec![MOp::Reg(Reg::V(d)), MOp::Sym(name.clone())]));
                    self.push(MInst::new(pageoff, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(d)), MOp::Sym(name)]));
                }
                if off == 0 {
                    return Ok(Reg::V(d));
                }
                let r = self.ivreg(true);
                let add = self.t.by_role("addi");
                let sub = self.t.role("addi.neg");
                if self.t.instrs[add].fits(&[None, None, Some(off)]) {
                    self.push(MInst::new(add, vec![MOp::Reg(Reg::V(r)), MOp::Reg(Reg::V(d)), MOp::Imm(off)]));
                } else if let Some(sub) = sub.filter(|&s| self.t.instrs[s].fits(&[None, None, Some(off)])) {
                    self.push(MInst::new(sub, vec![MOp::Reg(Reg::V(r)), MOp::Reg(Reg::V(d)), MOp::Imm(off)]));
                } else {
                    let o = self.int_reg(off, true, false)?;
                    let addr = self.t.by_role("add");
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

    /// A vector constant: zero with `movi`; a splat by duplicating the lane
    /// from an integer register; otherwise zero, then each nonzero lane
    /// inserted.
    fn vector_const(&mut self, c: ConstId, class: Class) -> Result<Reg, String> {
        let k = self.cx.m.constant(c).clone();
        let Type::Vector { len, elem, .. } = self.cx.m.types.get(k.ty).clone() else {
            return self.err("a vector constant of a scalar type");
        };
        let ebits = self.bits(elem).max(8);
        let lane = |m: &epitome_ir::Module, e: ConstId| -> i64 {
            match &m.constant(e).kind {
                ConstKind::Int(a) => a.low_u64() as i64,
                ConstKind::Float(raw) => *raw as i64,
                _ => 0,
            }
        };
        let lanes: Vec<i64> = match &k.kind {
            ConstKind::Zero | ConstKind::Undef | ConstKind::Poison => vec![0; len as usize],
            ConstKind::Splat(e) => vec![lane(self.cx.m, *e); len as usize],
            ConstKind::Vector(es) => es.iter().map(|&e| lane(self.cx.m, e)).collect(),
            other => return self.err(format!("unsupported vector constant {other:?}")),
        };
        let d = self.mf.new_vreg(class);
        let arr = arrangement(len, ebits);
        if lanes.iter().all(|&l| l == lanes[0]) && lanes[0] != 0 {
            let g = self.int_reg(lanes[0], ebits > 32, true)?;
            let dup = self.t.by_role(&format!("dup.{arr}"));
            self.push(MInst::new(dup, vec![MOp::Reg(Reg::V(d)), MOp::Reg(g)]));
            return Ok(Reg::V(d));
        }
        let zero = self.t.by_role("movi.zero");
        self.push(MInst::new(zero, vec![MOp::Reg(Reg::V(d))]));
        let ins = self.t.by_role(&format!("ins.{}", lane_suffix(ebits)));
        for (k, &l) in lanes.iter().enumerate() {
            if l != 0 {
                let g = self.int_reg(l, ebits > 32, true)?;
                self.push(MInst::new(
                    ins,
                    vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(d)), MOp::Reg(g), MOp::Imm(k as i64)],
                ));
            }
        }
        Ok(Reg::V(d))
    }

    /// A register holding integer `v`.
    pub fn int_reg(&mut self, v: i64, wide: bool, zr_ok: bool) -> Result<Reg, String> {
        let v = if wide { v } else { v as i32 as i64 };
        if v == 0
            && zr_ok
            && let Some(z) = self.t.machine.zero
        {
            return Ok(Reg::P(z));
        }
        if let Some(&r) = self.hoisted.get(&(v, wide)).filter(|_| self.hoisting()) {
            return Ok(Reg::V(r));
        }
        // Only a constant that takes more than one instruction is worth a
        // register for the whole loop: the allocator cannot make one again
        // where registers run short, so a cheap one would only crowd out
        // the loop's own values.
        if self.hoisting()
            && !self.one_instruction(v, wide)
            && epitome_ir::chop::allow(|| format!("hoist the constant {v} out of the loop"))
        {
            let r = self.in_entry(|s| s.make_int(v, wide))?;
            if let Reg::V(x) = r {
                self.hoisted.insert((v, wide), x);
            }
            return Ok(r);
        }
        if let Some(&r) = self.block_ints.get(&(self.cur, v, wide)) {
            return Ok(Reg::V(r));
        }
        let r = self.make_int(v, wide)?;
        if let Reg::V(x) = r {
            self.block_ints.insert((self.cur, v, wide), x);
        }
        Ok(r)
    }

    fn move_wide(&self, wide: bool) -> Option<(usize, usize, u32)> {
        self.move_wide[wide as usize]
    }

    /// A value with one nonzero chunk above the lowest: one shifted `movz`,
    /// which is what an assembler makes of `mov` for such a value (it
    /// prefers movz to movn).
    fn shifted_movz(&self, u: u64, wide: bool) -> bool {
        let Some((movz, _, chunk)) = self.move_wide(wide) else { return false };
        let s = u.trailing_zeros() / chunk * chunk;
        u != 0
            && s > 0
            && s < 64
            && (u >> s) < (1u64 << chunk)
            && self.t.instrs[movz].fits(&[None, Some((u >> s) as i64), Some(s as i64)])
    }

    /// Whether `make_int` makes `v` with one instruction.
    fn one_instruction(&self, v: i64, wide: bool) -> bool {
        let bits = if wide { 64 } else { 32 };
        let u = (v as u64) & (u64::MAX >> (64 - bits));
        self.shifted_movz(u, wide)
            || self.t.constants.iter().any(|&ci| {
                let ins = &self.t.instrs[ci];
                self.cx.enabled(ci) && (ins.operands[0].bits > 32) == wide && ins.fits(&[None, Some(v)])
            })
    }

    fn make_int(&mut self, v: i64, wide: bool) -> Result<Reg, String> {
        let d = self.ivreg(wide);
        // A shifted movz is written out as one, so that we and an assembler
        // say the same.
        let bits = if wide { 64 } else { 32 };
        let u = (v as u64) & (u64::MAX >> (64 - bits));
        let shifted_movz = self.shifted_movz(u, wide);
        // One instruction, if the description has one that holds it.
        for &ci in self.t.constants.iter().filter(|&&ci| !shifted_movz && self.cx.enabled(ci)) {
            let ins = &self.t.instrs[ci];
            if (ins.operands[0].bits > 32) != wide {
                continue;
            }
            if ins.fits(&[None, Some(v)]) {
                self.push(MInst::new(ci, vec![MOp::Reg(Reg::V(d)), MOp::Imm(v)]));
                return Ok(Reg::V(d));
            }
        }
        // Without movz and movk: a high part, plus the low bits by an add.
        let Some((movz, movk, chunk)) = self.move_wide(wide) else {
            return self.make_int_pieces(d, v, wide);
        };
        // Otherwise a chunk at a time.
        let pieces = (bits as u32).div_ceil(chunk);
        let mask = (1u64 << chunk) - 1;
        let u = v as u64;
        let chunks: Vec<(i64, i64)> = (0..pieces)
            .map(|k| (((u >> (chunk * k)) & mask) as i64, (chunk * k) as i64))
            .filter(|(c, _)| *c != 0)
            .collect();
        let (first, rest) = chunks.split_first().expect("zero is made above");
        self.push(MInst::new(movz, vec![MOp::Reg(Reg::V(d)), MOp::Imm(first.0), MOp::Imm(first.1)]));
        for &(c, sh) in rest {
            self.push(MInst::new(movk, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(d)), MOp::Imm(c), MOp::Imm(sh)]));
        }
        Ok(Reg::V(d))
    }

    /// Integer `v` in register `d`, for machines that build constants from a
    /// high part and an added low part (RISC-V's `lui` and `addi`). The low
    /// part is the value's low bits, as a signed number of the width the
    /// add-immediate (`"addi"`, or `"addi.w"` for 32 bits) holds; the high
    /// part is made by one of the description's constant instructions if it
    /// holds it, else made the same way, shifted into place (`"shli"`).
    fn make_int_pieces(&mut self, d: VReg, v: i64, wide: bool) -> Result<Reg, String> {
        let add = if wide { self.t.role("addi") } else { self.t.role("addi.w").or(self.t.role("addi")) }
            .ok_or("no way to make this constant: no \"addi\" instruction")?;
        let fits_add = |t: &Target, x: i64| t.instrs[add].fits(&[None, None, Some(x)]);
        // The add's immediate width, by what it holds.
        let mut k = 1;
        while k < 32 && fits_add(self.t, (1i64 << k) - 1) && fits_add(self.t, -(1i64 << k)) {
            k += 1;
        }
        let lo = (v << (64 - k)) >> (64 - k);
        let mut hi = v.wrapping_sub(lo);
        if !wide {
            hi = hi as i32 as i64;
        }
        let constant = self.t.constants.iter().copied().filter(|&ci| self.cx.enabled(ci)).find(|&ci| {
            let ins = &self.t.instrs[ci];
            (ins.operands[0].bits > 32) == wide && ins.fits(&[None, Some(hi)])
        });
        let base = match constant {
            Some(ci) => {
                let r = self.ivreg(wide);
                self.push(MInst::new(ci, vec![MOp::Reg(Reg::V(r)), MOp::Imm(hi)]));
                Reg::V(r)
            }
            None => {
                let shl = self.t.role("shli").ok_or("no way to make this constant: no \"shli\" instruction")?;
                let sh = hi.trailing_zeros() as i64;
                if sh == 0 || sh >= 64 {
                    return self.err(format!("no way to make the constant {v}"));
                }
                let h = self.make_int(hi >> sh, wide)?;
                let r = self.ivreg(wide);
                self.push(MInst::new(shl, vec![MOp::Reg(Reg::V(r)), MOp::Reg(h), MOp::Imm(sh)]));
                Reg::V(r)
            }
        };
        if lo == 0 {
            self.push(MInst::copy(Reg::V(d), base));
        } else {
            self.push(MInst::new(add, vec![MOp::Reg(Reg::V(d)), MOp::Reg(base), MOp::Imm(lo)]));
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
            && !self.is_vector(self.f.locals[x.index()].ty)
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
                        // A temporary of the register class its producer
                        // writes.
                        let class = match ins.operands[j].kind {
                            Kind::Reg(c) => c,
                            _ => self.int_class(true),
                        };
                        let v = match temps.get(t) {
                            Some(&v) => v,
                            None => {
                                let v = self.mf.new_vreg(class);
                                temps.insert(*t, v);
                                v
                            }
                        };
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
            // A tied operand shares the result's register: copied there
            // first, then updated in place.
            if ins.has_result
                && let MOp::Reg(res) = ops[0]
            {
                for (j, o) in ins.operands.iter().enumerate() {
                    if o.tied
                        && !o.writeback
                        && let MOp::Reg(src) = ops[j]
                        && src != res
                    {
                        self.push(MInst::copy(res, src));
                        ops[j] = MOp::Reg(res);
                    }
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
            let b = self.t.by_role("jump");
            let target = self.bmap[&n];
            self.push(MInst::new(b, vec![MOp::Label(target)]));
        }
        Ok(())
    }

    /// How many 64-bit parts a small struct type passed in registers has:
    /// `[2 x i64]` and the like, as clang passes structs of up to 16 bytes.
    fn parts_of(&self, ty: TypeId) -> Option<usize> {
        let i64t = |t: &TypeId| matches!(self.cx.m.types.get(*t), Type::Int(64));
        match self.cx.m.types.get(ty) {
            Type::Array { len, elem } if *len <= 2 && i64t(elem) => Some(*len as usize),
            Type::Struct { fields, .. } if fields.len() <= 2 && fields.iter().all(i64t) => Some(fields.len()),
            _ => None,
        }
    }

    /// The registers a returned value takes: a small aggregate's parts, or
    /// a struct of integers and pointers (`{ ptr, ptr }`), a field each, in
    /// as many result registers as there are.
    fn result_parts(&self, ty: TypeId) -> Option<usize> {
        if let Type::Struct { fields, .. } = self.cx.m.types.get(ty)
            && fields.len() <= self.mf.abi.results(usize::MAX).len()
            && fields.iter().all(|t| matches!(self.cx.m.types.get(*t), Type::Int(1..=64) | Type::Ptr(0)))
        {
            return Some(fields.len());
        }
        self.parts_of(ty)
    }

    /// The parts of a small struct value: from the `insertvalue`s that
    /// built it, from a constant, or from a parameter's registers.
    fn parts(&mut self, v: Value, n: usize) -> Result<Vec<Reg>, String> {
        if let Value::Local(x) = v
            && let Some(regs) = self.agg_params.get(&x)
        {
            return Ok(regs.iter().map(|&r| Reg::V(r)).collect());
        }
        let mut found: Vec<Option<Value>> = vec![None; n];
        let mut cur = v;
        loop {
            match cur {
                Value::Local(x) => {
                    let LocalDef::Inst(d) = self.f.locals[x.index()].def else {
                        return self.err("a struct value of unknown parts");
                    };
                    match &self.f.insts[d.index()].op {
                        Op::InsertValue { aggregate, element, indices } if indices.len() == 1 => {
                            let k = indices[0] as usize;
                            if k < n && found[k].is_none() {
                                found[k] = Some(*element);
                            }
                            cur = *aggregate;
                        }
                        op => return self.err(format!("a struct value made by {op:?}")),
                    }
                }
                Value::Const(c) => {
                    if let ConstKind::Array(elems) | ConstKind::Struct(elems) = &self.cx.m.constant(c).kind.clone() {
                        for (k, e) in elems.iter().enumerate().take(n) {
                            if found[k].is_none() {
                                found[k] = Some(Value::Const(*e));
                            }
                        }
                    }
                    break;
                }
                Value::Metadata(_) => break,
            }
        }
        let mut regs = Vec::new();
        for part in found {
            regs.push(match part {
                Some(p) => self.reg_for(p, self.int_class(true))?,
                None => self.int_reg(0, true, true)?,
            });
        }
        Ok(regs)
    }

    /// The size in bytes of a value passed as an argument.
    fn arg_size(&self, v: Value) -> u64 {
        match self.vbits(v) {
            0..=8 => 1,
            9..=16 => 2,
            17..=32 => 4,
            _ => 8,
        }
    }

    /// A store of `r`, `size` bytes wide, at `off` from the stack pointer.
    fn store_to_stack(&mut self, r: Reg, size: u64, off: i64, fp: bool) {
        let role = format!("store.{}", mem_size(size, fp));
        let sp = self.t.machine.sp;
        self.push(MInst::new(self.t.by_role(&role), vec![MOp::Reg(r), MOp::Reg(Reg::P(sp)), MOp::Imm(off)]));
    }

    /// Inline assembly: its operands in registers (of the classes their
    /// constraints name, or the registers they name), immediates or
    /// memory, then one `Opcode::Asm` instruction, then its results copied
    /// out.
    fn emit_asm(&mut self, i: InstId) -> Result<(), String> {
        use crate::machine::AsmCode;
        let f = self.f;
        let inst = &f.insts[i.index()];
        let Op::Call(call) = &inst.op else { unreachable!() };
        let a = inline_asm(self.cx.m, call).unwrap().clone();
        let template = String::from_utf8_lossy(&a.asm).into_owned();
        let cons = parse_constraints(&String::from_utf8_lossy(&a.constraints));
        let m = &self.t.machine;
        let fname = self.fname.to_string();
        let bad = |what: String| format!("@{fname}: inline assembly: {what}");
        // The types of the results: one, or a struct of them.
        let result_tys: Vec<TypeId> = match inst.result.map(|r| f.locals[r.index()].ty) {
            None => vec![],
            Some(ty) => match self.cx.m.types.get(ty) {
                Type::Struct { fields, .. } => fields.clone(),
                Type::Void => vec![],
                _ => vec![ty],
            },
        };
        let mut outs: Vec<MOp> = Vec::new();
        let mut ins: Vec<MOp> = Vec::new();
        // For each $N: whether it is an output (and which), or an input.
        let mut operands: Vec<(bool, usize, AsmPrint)> = Vec::new();
        // Results: (output's operand, the register to copy it to).
        let mut results: Vec<(MOp, Class)> = Vec::new();
        let mut before: Vec<MInst> = Vec::new();
        let mut clobbers: Vec<u8> = Vec::new();
        let mut early: Vec<bool> = Vec::new();
        let mut args = call.args.iter().map(|x| x.value);
        let mut next_result = 0;
        let named = |name: &str| -> Option<u8> { name.strip_prefix('{')?.strip_suffix('}').and_then(|n| m.lookup(n)) };
        for c in &cons {
            if c.clobber {
                let name = c.codes.trim_start_matches('{').trim_end_matches('}');
                match m.lookup(name) {
                    Some(p) => clobbers.push(p),
                    None if matches!(name, "memory" | "cc" | "flags" | "dirflag" | "fpsr" | "fpcr" | "nzcv") => {}
                    None => return Err(bad(format!("no register {name} to clobber"))),
                }
                continue;
            }
            if c.output && !c.indirect {
                // A result.
                let ty = *result_tys.get(next_result).ok_or_else(|| bad("more outputs than results".into()))?;
                next_result += 1;
                let (holds, bits) = (self.holds(ty), self.bits(ty).max(1));
                let (op, print) = if let Some(p) = named(&c.codes) {
                    let class = m.value_class_in(m.file_of(p), holds, bits).ok_or_else(|| bad(c.codes.clone()))?;
                    (MOp::Reg(Reg::P(p)), class)
                } else {
                    let code = c.codes.chars().find_map(|k| match m.asm_constraints.get(&k) {
                        Some(AsmCode::Reg { file, print }) => Some((*file, *print)),
                        _ => None,
                    });
                    let (file, print) = code.ok_or_else(|| bad(format!("output constraint {:?}", c.codes)))?;
                    let class = m
                        .value_class_in(file, holds, bits)
                        .ok_or_else(|| bad(format!("no register class of its file holds {:?}", c.codes)))?;
                    let v = self.mf.new_vreg(class);
                    (MOp::Reg(Reg::V(v)), print.unwrap_or(class))
                };
                let class = match &op {
                    MOp::Reg(Reg::V(v)) => self.mf.vclass[*v as usize],
                    _ => print,
                };
                operands.push((true, outs.len(), AsmPrint::Reg(print)));
                early.push(c.early);
                results.push((op.clone(), class));
                outs.push(op);
                continue;
            }
            // An input (or the address of an indirect output).
            let v = args.next().ok_or_else(|| bad("more inputs than arguments".into()))?;
            // Tied to an output: in its register.
            if let Ok(n) = c.codes.parse::<usize>() {
                let (is_out, k, print) = operands.get(n).cloned().ok_or_else(|| bad(format!("no operand {n}")))?;
                if !is_out {
                    return Err(bad(format!("operand {n}, which an input is tied to, is not an output")));
                }
                let class = results[k].1;
                let r = self.reg_for(v, class)?;
                let MOp::Reg(dst) = outs[k] else { unreachable!() };
                before.push(MInst::copy(dst, r));
                operands.push((false, ins.len(), print));
                ins.push(MOp::Reg(dst));
                continue;
            }
            let ty = self.ty_of(v);
            let (holds, bits) = (self.holds(ty), self.bits(ty).max(1));
            if let Some(p) = named(&c.codes) {
                let class = m.value_class_in(m.file_of(p), holds, bits).ok_or_else(|| bad(c.codes.clone()))?;
                let r = self.reg_for(v, class)?;
                before.push(MInst::copy(Reg::P(p), r));
                operands.push((false, ins.len(), AsmPrint::Reg(class)));
                ins.push(MOp::Reg(Reg::P(p)));
                continue;
            }
            let konst = match v {
                Value::Const(_) => self.cx.const_int(v),
                _ => None,
            };
            let mut done = false;
            for k in c.codes.chars() {
                match (k, m.asm_constraints.get(&k), konst) {
                    ('i' | 'n', _, Some(x)) => {
                        operands.push((false, ins.len(), AsmPrint::Imm));
                        ins.push(MOp::Imm(x));
                    }
                    (_, Some(AsmCode::Imm(lo, hi)), Some(x)) if (*lo..=*hi).contains(&x) => {
                        operands.push((false, ins.len(), AsmPrint::Imm));
                        ins.push(MOp::Imm(x));
                    }
                    (_, Some(AsmCode::Zero), Some(0)) if m.zero.is_some() => {
                        let class = self.int_class(bits > 32);
                        operands.push((false, ins.len(), AsmPrint::Reg(class)));
                        ins.push(MOp::Reg(Reg::P(m.zero.unwrap())));
                    }
                    (_, Some(AsmCode::Reg { file, print }), _) => {
                        let class = m
                            .value_class_in(*file, holds, bits)
                            .ok_or_else(|| bad(format!("no register class of its file holds {:?}", c.codes)))?;
                        let r = self.reg_for(v, class)?;
                        operands.push((false, ins.len(), AsmPrint::Reg(print.unwrap_or(class))));
                        ins.push(MOp::Reg(r));
                    }
                    (_, Some(AsmCode::Mem(tpl)), _) => {
                        let class = self.int_class(true);
                        let r = self.reg_for(v, class)?;
                        operands.push((false, ins.len(), AsmPrint::Mem(tpl.clone(), class)));
                        ins.push(MOp::Reg(r));
                    }
                    _ => continue,
                }
                done = true;
                break;
            }
            if !done {
                return Err(bad(format!(
                    "constraint {:?} for {}",
                    c.codes,
                    if konst.is_some() { "a constant" } else { "a value" }
                )));
            }
        }
        for b in before {
            self.push(b);
        }
        let n_outs = outs.len();
        let ops: Vec<MOp> = outs.into_iter().chain(ins).collect();
        let operands = operands.into_iter().map(|(is_out, k, p)| (if is_out { k } else { n_outs + k }, p)).collect();
        let id = self.mf.asms.len();
        let uid = fname.bytes().fold(0xcbf2_9ce4_8422_2325u64, |h, b| (h ^ b as u64).wrapping_mul(0x100_0000_01b3))
            % 1_000_000
            * 1000
            + id as u64;
        let statements = statements(&template, &m.asm_comment);
        self.mf.asms.push(AsmBlock { template, operands, uid, statements, early });
        let mut asm = MInst { op: Opcode::Asm { id: id as u32, outs: n_outs as u16 }, ..MInst::new(0, ops) };
        asm.imp_defs = clobbers;
        self.push(asm);
        // The results, copied out.
        if let Some(r) = inst.result {
            let regs: Vec<VReg> = results
                .iter()
                .map(|(op, class)| {
                    let MOp::Reg(src) = op else { unreachable!() };
                    let d = self.mf.new_vreg(*class);
                    self.push(MInst::copy(Reg::V(d), *src));
                    d
                })
                .collect();
            if result_tys.len() == 1 && !matches!(self.cx.m.types.get(f.locals[r.index()].ty), Type::Struct { .. }) {
                let d = self.vreg_of(r);
                self.push(MInst::copy(Reg::V(d), Reg::V(regs[0])));
            } else {
                self.agg_params.insert(r, regs);
            }
        }
        Ok(())
    }

    /// The symbol a type information operand names (`@_ZTIi`), or `None`
    /// for null (catching everything).
    fn type_name(&self, v: Value) -> Option<String> {
        let Value::Const(c) = v else { return None };
        match &self.cx.m.constant(c).kind {
            ConstKind::Global(g) => self.cx.m.global(*g).name.clone(),
            _ => None,
        }
    }

    /// The action of the landing pad in block `b`: an index into the
    /// function's exception information, added if new.
    fn action_for(&mut self, b: BlockId) -> Result<usize, String> {
        let f = self.f;
        let lp = f.blocks[b.index()].insts.iter().find(|&&i| !f.insts[i.index()].op.is_phi());
        let Some(Op::LandingPad { cleanup, clauses }) = lp.map(|&i| &f.insts[i.index()].op) else {
            return self.err("an invoke whose unwind destination is not a landing pad".to_string());
        };
        let personality = match f.personality.map(|c| &self.cx.m.constant(c).kind) {
            Some(ConstKind::Global(g)) => self.cx.m.global(*g).name.clone().unwrap_or_default(),
            _ => return self.err("a landing pad without a personality routine".to_string()),
        };
        self.mf.eh.get_or_insert_with(|| EhInfo { personality, ..Default::default() });
        // A type's index, from 1, added if new.
        let index = |eh: &mut EhInfo, ti: Option<String>| {
            1 + match eh.types.iter().position(|t| *t == ti) {
                Some(k) => k,
                None => {
                    eh.types.push(ti);
                    eh.types.len() - 1
                }
            } as i64
        };
        let mut filters = Vec::new();
        for c in clauses {
            match c {
                Clause::Catch(v) => {
                    let ti = self.type_name(*v);
                    let eh = self.mf.eh.as_mut().unwrap();
                    filters.push(index(eh, ti));
                }
                Clause::Filter(v) => {
                    let elems = match v {
                        Value::Const(c) => match &self.cx.m.constant(*c).kind {
                            ConstKind::Zero
                                if matches!(
                                    self.cx.m.types.get(self.cx.m.constant(*c).ty),
                                    Type::Array { len: 0, .. }
                                ) =>
                            {
                                vec![]
                            }
                            ConstKind::Array(e) => e.clone(),
                            _ => return self.err("an exception filter not a list of types".to_string()),
                        },
                        _ => return self.err("an exception filter not a constant".to_string()),
                    };
                    let names: Vec<Option<String>> = elems.iter().map(|&e| self.type_name(Value::Const(e))).collect();
                    let eh = self.mf.eh.as_mut().unwrap();
                    let mut list = Vec::new();
                    for ti in names {
                        let k = index(eh, ti);
                        crate::eh::uleb(&mut list, k as u64);
                    }
                    list.push(0);
                    // The same list, if there is one already.
                    let at = (0..eh.specs.len())
                        .find(|&k| eh.specs[k..].starts_with(&list) && (k == 0 || eh.specs[k - 1] == 0))
                        .unwrap_or_else(|| {
                            eh.specs.extend(&list);
                            eh.specs.len() - list.len()
                        });
                    filters.push(-1 - at as i64);
                }
            }
        }
        let eh = self.mf.eh.as_mut().unwrap();
        let action = (*cleanup, filters);
        Ok(match eh.actions.iter().position(|a| *a == action) {
            Some(k) => k,
            None => {
                eh.actions.push(action);
                eh.actions.len() - 1
            }
        })
    }

    /// The `ret` a call can be a tail call before, if it can: it is marked
    /// `tail`, its arguments are all in registers, and the next instruction
    /// returns its result (extended as the call's is), or nothing.
    fn tail_ret(&self, i: InstId, call: &Call, locs: &[crate::abi::ArgLoc]) -> Option<InstId> {
        if !matches!(call.tail, TailKind::Tail | TailKind::MustTail)
            || locs.iter().any(|l| matches!(l, crate::abi::ArgLoc::Stack(_)))
        {
            return None;
        }
        let f = self.f;
        let b = self.inst_block[i.index()]?;
        let next = *f.blocks[b.index()].insts.get(self.pos[i.index()] + 1)?;
        let result = f.insts[i.index()].result;
        match &f.insts[next.index()].op {
            Op::Ret(None) => {}
            Op::Ret(Some(Value::Local(x))) if Some(*x) == result => {}
            // A branch to a block that only returns: what this block gives
            // its phi, or nothing.
            Op::Br(dest) => {
                let insts = &f.blocks[dest.index()].insts;
                let body: Vec<InstId> = insts.iter().copied().filter(|&k| !f.insts[k.index()].op.is_phi()).collect();
                let [only] = body.as_slice() else { return None };
                match &f.insts[only.index()].op {
                    Op::Ret(None) => {}
                    Op::Ret(Some(Value::Local(x))) => {
                        let LocalDef::Inst(phi) = f.locals[x.index()].def else { return None };
                        let Op::Phi { incoming, .. } = &f.insts[phi.index()].op else { return None };
                        let from = incoming.iter().find(|(_, p)| *p == b).map(|(v, _)| *v);
                        if result.is_none_or(|r| from != Some(Value::Local(r))) {
                            return None;
                        }
                    }
                    _ => return None,
                }
            }
            _ => return None,
        }
        let ext = |a: &[Attr]| -> (bool, bool) {
            let has = |w: &str| a.iter().any(|x| matches!(x, Attr::Word(y) if y == w));
            (has("zeroext"), has("signext"))
        };
        (ext(&f.ret_attrs) == ext(&call.ret_attrs)).then_some(next)
    }

    fn emit_call(&mut self, i: InstId) -> Result<(), String> {
        let f = self.f;
        let inst = &f.insts[i.index()];
        let call = inst.op.call().expect("a call");
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
                    let brk = self.t.by_role("trap");
                    self.push(MInst::new(brk, vec![]));
                    return Ok(());
                }
                // AAPCS64's va_list: { __stack, __gr_top, __vr_top,
                // __gr_offs, __vr_offs }: the next stack argument, the ends
                // of the register save areas, and how far below the ends
                // the next saved registers are.
                s if s.starts_with("llvm.va_start") && self.va_areas.is_some() => {
                    let (gs, gr, vs, vr) = self.va_areas.unwrap();
                    let ap = self.reg_for(args[0].value, self.int_class(true))?;
                    let sp = Reg::P(self.t.machine.sp);
                    let (addi, stx, stw) =
                        (self.t.by_role("addi"), self.t.by_role("store.x"), self.t.by_role("store.w"));
                    for (off, at) in
                        [(0, MOp::Incoming(self.va_offset)), (8, MOp::Frame(gs, gr)), (16, MOp::Frame(vs, vr))]
                    {
                        let p = self.ivreg(true);
                        self.push(MInst::new(addi, vec![MOp::Reg(Reg::V(p)), MOp::Reg(sp), at]));
                        self.push(MInst::new(stx, vec![MOp::Reg(Reg::V(p)), MOp::Reg(ap), MOp::Imm(off)]));
                    }
                    for (off, v) in [(24, -gr), (28, -vr)] {
                        let r = self.int_reg(v, false, true)?;
                        self.push(MInst::new(stw, vec![MOp::Reg(r), MOp::Reg(ap), MOp::Imm(off)]));
                    }
                    return Ok(());
                }
                s if s.starts_with("llvm.va_copy") && self.mf.abi.va_list_aapcs64 => {
                    let dst = self.reg_for(args[0].value, self.int_class(true))?;
                    let src = self.reg_for(args[1].value, self.int_class(true))?;
                    let (ldx, stx) = (self.t.by_role("load.x"), self.t.by_role("store.x"));
                    for off in [0, 8, 16, 24] {
                        let p = self.ivreg(true);
                        self.push(MInst::new(ldx, vec![MOp::Reg(Reg::V(p)), MOp::Reg(src), MOp::Imm(off)]));
                        self.push(MInst::new(stx, vec![MOp::Reg(Reg::V(p)), MOp::Reg(dst), MOp::Imm(off)]));
                    }
                    return Ok(());
                }
                // A va_list is a pointer to the next variable argument.
                s if s.starts_with("llvm.va_start") => {
                    let ap = self.reg_for(args[0].value, self.int_class(true))?;
                    let p = self.ivreg(true);
                    self.push(MInst::new(
                        self.t.by_role("addi"),
                        vec![MOp::Reg(Reg::V(p)), MOp::Reg(Reg::P(self.t.machine.sp)), MOp::Incoming(self.va_offset)],
                    ));
                    self.push(MInst::new(
                        self.t.by_role("store.x"),
                        vec![MOp::Reg(Reg::V(p)), MOp::Reg(ap), MOp::Imm(0)],
                    ));
                    return Ok(());
                }
                s if s.starts_with("llvm.va_end") => return Ok(()),
                // The selector a landing pad gets for a type: its index in
                // the function's table of types caught.
                s if s.starts_with("llvm.eh.typeid.for") => {
                    let ti = self.type_name(args[0].value);
                    let k = self.mf.eh.as_ref().and_then(|e| e.types.iter().position(|t| *t == ti));
                    let k = k.ok_or("llvm.eh.typeid.for of a type no landing pad catches")? as i64 + 1;
                    if let Some(r) = inst.result {
                        let v = self.int_reg(k, false, true)?;
                        let d = self.vreg_of(r);
                        self.push(MInst::copy(Reg::V(d), v));
                    }
                    return Ok(());
                }
                s if s.starts_with("llvm.va_copy") => {
                    let dst = self.reg_for(args[0].value, self.int_class(true))?;
                    let src = self.reg_for(args[1].value, self.int_class(true))?;
                    let p = self.ivreg(true);
                    self.push(MInst::new(
                        self.t.by_role("load.x"),
                        vec![MOp::Reg(Reg::V(p)), MOp::Reg(src), MOp::Imm(0)],
                    ));
                    self.push(MInst::new(
                        self.t.by_role("store.x"),
                        vec![MOp::Reg(Reg::V(p)), MOp::Reg(dst), MOp::Imm(0)],
                    ));
                    return Ok(());
                }
                s => return self.err(format!("intrinsic {s} is not supported yet")),
            });
            args.truncate(3);
        }
        // Named arguments are the callee type's parameters; the rest of a
        // variadic call's are variable.
        let named = match self.cx.m.types.get(call.fn_ty) {
            Type::Function { params, varargs: true, .. } => params.len(),
            _ => args.len(),
        };
        let mut shapes: Vec<Vec<crate::abi::Part>> = Vec::new();
        for a in &args {
            let ty = self.ty_of(a.value);
            let sret = a.attrs.iter().any(|x| matches!(x, Attr::Type { name, .. } if name == "sret"));
            let wide = a.attrs.iter().any(|x| matches!(x, Attr::Word(w) if w == crate::wide::WIDE));
            shapes.push(match self.parts_of(ty) {
                Some(n) => vec![crate::abi::Part { size: 8, fp: false, sret: false, wide }; n],
                None => vec![crate::abi::Part { size: self.arg_size(a.value), fp: self.is_fp(ty), sret, wide: false }],
            });
        }
        let (part_locs, stack) = self.mf.abi.assign_parts(&shapes, named);
        self.mf.out_size = self.mf.out_size.max(stack);
        // Each argument in registers, extended as its attributes say; a
        // small struct in one register per part.
        let mut regs = Vec::new();
        let mut locs = Vec::new();
        let mut sizes = Vec::new();
        let mut fps = Vec::new();
        let mut is_named = Vec::new();
        for (k, a) in args.iter().enumerate() {
            let ty = self.ty_of(a.value);
            if let Some(n) = self.parts_of(ty) {
                for (p, r) in self.parts(a.value, n)?.into_iter().enumerate() {
                    regs.push(r);
                    locs.push(part_locs[k][p]);
                    sizes.push(8);
                    fps.push(false);
                    is_named.push(k < named);
                }
                continue;
            }
            let bits = self.vbits(a.value);
            let class = self.class_of(a.value);
            let mut r = self.reg_for(a.value, class)?;
            let fp = self.fp_class(class);
            if !fp {
                r = self.extend_for_abi(r, bits, &a.attrs)?;
            }
            regs.push(r);
            locs.push(part_locs[k][0]);
            sizes.push(shapes[k][0].size);
            fps.push(fp);
            is_named.push(k < named);
        }
        let callee_reg = match (&target, call.callee) {
            (Some(_), _) => None,
            (None, v) => Some(self.reg_for(v, self.int_class(true))?),
        };
        // Stack arguments first, while every argument register is free;
        // a variable argument takes a whole 8-byte slot.
        let mut in_regs = Vec::new();
        for (k, (&loc, &r)) in locs.iter().zip(&regs).enumerate() {
            match loc {
                crate::abi::ArgLoc::Stack(off) => {
                    let size = if !is_named[k] && self.mf.abi.variadic == crate::abi::Variadic::Stack {
                        sizes[k].max(4)
                    } else {
                        sizes[k]
                    };
                    self.store_to_stack(r, if fps[k] { sizes[k] } else { size }, off, fps[k]);
                }
                crate::abi::ArgLoc::Reg(p) => in_regs.push((p, r)),
            }
        }
        for &(p, r) in &in_regs {
            self.push(MInst::copy(Reg::P(p), r));
        }
        // A tail call: when the call's result is what the function returns,
        // its frame goes first, and the callee returns to its caller.
        let tail = if self.landing_next.is_some() { None } else { self.tail_ret(i, call, &locs) };
        // Elective (autochop) unless the call must be a tail call.
        let tail = tail.filter(|_| {
            call.tail == TailKind::MustTail
                || epitome_ir::chop::allow(|| {
                    format!("tail call @{} at {}", name.as_deref().unwrap_or("?"), epitome_ir::printer::inst_name(f, i))
                })
        });
        if let (Some(ret), Some(s), Some(tc)) = (tail, &target, self.t.role("tailcall")) {
            let mut m = MInst::new(tc, vec![MOp::Sym(s.clone())]);
            m.imp_uses = in_regs.iter().map(|&(p, _)| p).collect();
            self.push(m);
            self.covered.insert(ret);
            if let Some(b) = self.inst_block[i.index()] {
                self.tail_blocks.insert(b);
            }
            return Ok(());
        }
        // Through a register: the callee's address goes to a scratch
        // register first, which the epilogue (restoring the saved
        // registers) leaves alone.
        if let (Some(ret), Some(r), Some(tcr), Some(&via)) =
            (tail, callee_reg, self.t.role("tailcallr"), self.mf.abi.scratch.last())
        {
            self.push(MInst::copy(Reg::P(via), r));
            let mut m = MInst::new(tcr, vec![MOp::Reg(Reg::P(via))]);
            m.imp_uses = in_regs.iter().map(|&(p, _)| p).chain([via]).collect();
            self.push(m);
            self.covered.insert(ret);
            if let Some(b) = self.inst_block[i.index()] {
                self.tail_blocks.insert(b);
            }
            return Ok(());
        }
        if call.tail == TailKind::MustTail {
            return self.err("a musttail call that cannot be made a tail call".to_string());
        }
        let mut inst_m = match (&target, callee_reg) {
            (Some(s), _) => MInst::new(self.t.by_role("call"), vec![MOp::Sym(s.clone())]),
            (None, Some(r)) => MInst::new(self.t.by_role("callr"), vec![MOp::Reg(r)]),
            _ => unreachable!(),
        };
        inst_m.imp_uses = in_regs.iter().map(|&(p, _)| p).collect();
        inst_m.imp_defs = self.mf.abi.all_clobbers();
        // From an invoke: where it unwinds to, and what happens there.
        if let Some((lp, action)) = self.landing_next.take() {
            inst_m.ops.push(MOp::Label(lp));
            inst_m.ops.push(MOp::Imm(action as i64));
        }
        self.push(inst_m);
        if let Some(r) = inst.result
            && self.uses[r.index()] > 0
        {
            // A small aggregate ([2 x i64], an i128): one register a part.
            if let Some(n) = self.result_parts(self.f.locals[r.index()].ty) {
                let mut regs = Vec::new();
                for from in self.mf.abi.results(n) {
                    let d = self.ivreg(true);
                    self.push(MInst::copy(Reg::V(d), Reg::P(from)));
                    regs.push(d);
                }
                self.agg_params.insert(r, regs);
                return Ok(());
            }
            let d = self.vreg_of(r);
            let from = if self.is_fp(self.f.locals[r.index()].ty) { self.mf.abi.fp_result } else { self.mf.abi.result };
            self.push(MInst::copy(Reg::V(d), Reg::P(from)));
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
        let role = match (has("zeroext"), has("signext"), bits) {
            (true, _, 1) => "zext.1",
            (true, _, 8) => "zext.8",
            (true, _, 16) => "zext.16",
            (_, true, 1) => "sext.1",
            (_, true, 8) => "sext.8",
            (_, true, 16) => "sext.16",
            _ => return Ok(r),
        };
        let d = self.ivreg(false);
        let ext = self.t.role(role).ok_or_else(|| format!("@{}: no instruction has role {role}", self.fname))?;
        self.push(MInst::new(ext, vec![MOp::Reg(Reg::V(d)), MOp::Reg(r)]));
        Ok(Reg::V(d))
    }

    /// Whether IR instruction `i` is a call of a function that does not
    /// return (`noreturn` on the call or the callee).
    fn ends_flow_by_call(&self, i: InstId) -> bool {
        let Op::Call(call) = &self.f.insts[i.index()].op else { return false };
        let m: &Module = self.cx.m;
        let on = |attrs: &[Attr]| has_word(m, attrs, "noreturn");
        on(&call.fn_attrs)
            || match call.callee {
                Value::Const(c) => match m.constant(c).kind {
                    ConstKind::Global(g) => match &m.global(g).kind {
                        GlobalKind::Function(f) => on(&f.fn_attrs),
                        _ => false,
                    },
                    _ => false,
                },
                _ => false,
            }
    }

    /// Marks the block's last machine instruction, if it is a call, as one
    /// that does not return.
    fn mark_last_call_noreturn(&mut self) -> bool {
        let t = self.t;
        let Some(last) = self.mf.blocks[self.cur].insts.last_mut() else { return false };
        match last.op {
            Opcode::Instr(k) if t.has_role(k, "call") || t.has_role(k, "callr") => {
                last.noreturn = true;
                true
            }
            _ => false,
        }
    }

    /// Marks the machine instructions from `from` (block, index) to the end
    /// of that block as barriers.
    fn mark_barrier(&mut self, from: Option<(usize, usize)>) {
        if let Some((b, at)) = from
            && b == self.cur
        {
            for m in &mut self.mf.blocks[b].insts[at..] {
                m.barrier = true;
            }
        }
    }

    fn emit_block(&mut self, b: BlockId, layout_next: Option<BlockId>) -> Result<(), String> {
        let f = self.f;
        self.cur = self.bmap[&b];
        let insts = f.blocks[b.index()].insts.clone();
        // What each atomic operation emits is marked a barrier when the
        // next instruction starts (the emission has many ways out; a block
        // ends with its terminator, so none is missed).
        let mut atomic_from: Option<(usize, usize)> = None;
        for (k, &i) in insts.iter().enumerate() {
            self.mark_barrier(atomic_from.take());
            let inst = &f.insts[i.index()];
            if is_atomic(&inst.op) {
                atomic_from = Some((self.cur, self.mf.blocks[self.cur].insts.len()));
            }
            if inst.op.is_terminator() {
                self.mf.blocks[self.cur].term_start = self.mf.blocks[self.cur].insts.len();
            }
            // `unreachable` right after a call that does not return (a
            // panic): nothing, the call ends the block.
            if matches!(inst.op, Op::Unreachable)
                && k > 0
                && self.ends_flow_by_call(insts[k - 1])
                && self.mark_last_call_noreturn()
            {
                continue;
            }
            if self.covered.contains(&i) {
                continue;
            }
            match &inst.op {
                Op::Phi { .. } => continue,
                Op::Call(call)
                    if prepare::callee_name(self.cx.m, call)
                        .is_some_and(|n| n.starts_with("llvm.stacksave") || n.starts_with("llvm.stackrestore")) =>
                {
                    let sp = self.t.machine.sp;
                    let addi = self.t.by_role("addi");
                    if let Some(r) = inst.result {
                        let d = self.vreg_of(r);
                        self.push(MInst::new(addi, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::P(sp)), MOp::Imm(0)]));
                    } else if let Some(a) = call.args.first() {
                        let v = self.reg_for(a.value, self.int_class(true))?;
                        self.push(MInst::new(addi, vec![MOp::Reg(Reg::P(sp)), MOp::Reg(v), MOp::Imm(0)]));
                    }
                    continue;
                }
                // An invoke: a call that can unwind to the landing pad,
                // then on to the normal destination.
                Op::Invoke { normal, unwind, .. } => {
                    let action = self.action_for(*unwind)?;
                    self.landing_next = Some((self.bmap[unwind], action));
                    self.emit_call(i)?;
                    if Some(*normal) != layout_next {
                        let target = self.bmap[normal];
                        self.push(MInst::new(self.t.by_role("jump"), vec![MOp::Label(target)]));
                    }
                    continue;
                }
                // A landing pad: the exception and its selector arrive in
                // the convention's registers for them.
                Op::LandingPad { .. } => {
                    if let Some(r) = inst.result {
                        let mut regs = Vec::new();
                        for p in self.mf.abi.eh_regs.clone() {
                            let d = self.ivreg(true);
                            self.push(MInst::copy(Reg::V(d), Reg::P(p)));
                            regs.push(d);
                        }
                        self.agg_params.insert(r, regs);
                    }
                    continue;
                }
                // Unwinding goes on: _Unwind_Resume(exception).
                Op::Resume(v) => {
                    let parts = self.parts(*v, 2)?;
                    let a0 = self.mf.abi.args[0];
                    self.push(MInst::copy(Reg::P(a0), parts[0]));
                    let mut c = MInst::new(self.t.by_role("call"), vec![MOp::Sym("_Unwind_Resume".into())]);
                    c.imp_uses = vec![a0];
                    c.imp_defs = self.mf.abi.all_clobbers();
                    // _Unwind_Resume does not return.
                    c.noreturn = true;
                    self.push(c);
                    continue;
                }
                Op::Call(call) if inline_asm(self.cx.m, call).is_some() => {
                    self.emit_asm(i)?;
                    continue;
                }
                Op::Call(_) if !self.chosen.contains_key(&i) => {
                    self.emit_call(i)?;
                    continue;
                }
                Op::Ret(Some(v)) if self.result_parts(self.ty_of(*v)).is_some() => {
                    let n = self.result_parts(self.ty_of(*v)).unwrap();
                    let parts = self.parts(*v, n)?;
                    let to = self.mf.abi.results(n);
                    for (&p, &r) in to.iter().zip(&parts) {
                        self.push(MInst::copy(Reg::P(p), r));
                    }
                    let mut ret = MInst::new(self.t.by_role("ret"), vec![]);
                    ret.imp_uses = to;
                    self.push(ret);
                    continue;
                }
                Op::Ret(v) => {
                    let mut result = None;
                    if let Some(v) = v {
                        let bits = self.vbits(*v);
                        let class = self.class_of(*v);
                        let mut r = self.reg_for(*v, class)?;
                        let to = if self.fp_class(class) {
                            self.mf.abi.fp_result
                        } else {
                            r = self.extend_for_abi(r, bits, &f.ret_attrs)?;
                            self.mf.abi.result
                        };
                        self.push(MInst::copy(Reg::P(to), r));
                        result = Some(to);
                    }
                    let mut ret = MInst::new(self.t.by_role("ret"), vec![]);
                    ret.imp_uses = result.into_iter().collect();
                    self.push(ret);
                    continue;
                }
                // The next variable argument: load it through the pointer,
                // and step the pointer over its 8-byte slot.
                Op::VaArg { list } => {
                    let ap = self.reg_for(*list, self.int_class(true))?;
                    let p = self.ivreg(true);
                    self.push(MInst::new(
                        self.t.by_role("load.x"),
                        vec![MOp::Reg(Reg::V(p)), MOp::Reg(ap), MOp::Imm(0)],
                    ));
                    if let Some(r) = inst.result {
                        let size = self.arg_size(Value::Local(r));
                        let load = format!("load.{}", mem_size(size, self.is_fp(self.f.locals[r.index()].ty)));
                        let d = self.vreg_of(r);
                        self.push(MInst::new(
                            self.t.by_role(&load),
                            vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::V(p)), MOp::Imm(0)],
                        ));
                    }
                    let q = self.ivreg(true);
                    self.push(MInst::new(
                        self.t.by_role("addi"),
                        vec![MOp::Reg(Reg::V(q)), MOp::Reg(Reg::V(p)), MOp::Imm(8)],
                    ));
                    self.push(MInst::new(
                        self.t.by_role("store.x"),
                        vec![MOp::Reg(Reg::V(q)), MOp::Reg(ap), MOp::Imm(0)],
                    ));
                    continue;
                }
                Op::InsertValue { .. } => continue,
                Op::ExtractValue { aggregate, indices } if indices.len() == 1 => {
                    let Some(r) = inst.result else { continue };
                    // A part of an inline assembly block's results.
                    if let Value::Local(x) = aggregate
                        && let Some(parts) = self.agg_params.get(x)
                        && let Some(&p) = parts.get(indices[0] as usize)
                    {
                        let d = self.vreg_of(r);
                        self.push(MInst::copy(Reg::V(d), Reg::V(p)));
                        continue;
                    }
                    let ty = self.ty_of(*aggregate);
                    // A small struct, or one of scalars built by insertvalue.
                    let n = match self.cx.m.types.get(ty) {
                        Type::Struct { fields, .. } => Some(fields.len()),
                        _ => self.parts_of(ty),
                    }
                    .ok_or("extractvalue from an unsupported aggregate")?;
                    let parts = self.parts(*aggregate, n)?;
                    let d = self.vreg_of(r);
                    self.push(MInst::copy(Reg::V(d), parts[indices[0] as usize]));
                    continue;
                }
                Op::Br(d) => {
                    if Some(*d) != layout_next {
                        let target = self.bmap[d];
                        self.push(MInst::new(self.t.by_role("jump"), vec![MOp::Label(target)]));
                    }
                    continue;
                }
                Op::Alloca { count: Some(c), .. } if self.cx.const_int(*c).is_none() => {
                    // A dynamic alloca (prepare made it `alloca i8, i64 n`,
                    // n a multiple of 16): sp moves down n bytes, and the
                    // memory is above the area for calls' arguments.
                    let (sp, c) = (self.t.machine.sp, *c);
                    let n = self.reg_for(c, self.int_class(true))?;
                    let v = self.ivreg(true);
                    let (addi, sub) =
                        (self.t.by_role("addi"), self.t.role("sub").ok_or("no instruction has role sub")?);
                    self.push(MInst::new(addi, vec![MOp::Reg(Reg::V(v)), MOp::Reg(Reg::P(sp)), MOp::Imm(0)]));
                    self.push(MInst::new(sub, vec![MOp::Reg(Reg::V(v)), MOp::Reg(Reg::V(v)), MOp::Reg(n)]));
                    self.push(MInst::new(addi, vec![MOp::Reg(Reg::P(sp)), MOp::Reg(Reg::V(v)), MOp::Imm(0)]));
                    if let Some(r) = inst.result {
                        let d = self.vreg_of(r);
                        self.push(MInst::new(addi, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::P(sp)), MOp::OutArea]));
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
                        self.t.by_role("addi"),
                        vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::P(self.t.machine.sp)), MOp::Frame(slot, 0)],
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
                let class = self.class_of(v);
                let s = self.reg_for(v, class)?;
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
                if self.tail_blocks.contains(&p) {
                    continue;
                }
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
                    let ty = f.locals[r.index()].ty;
                    let class = self.class_of_ty(ty);
                    let src = self.reg_for(v, class)?;
                    let tmp = self.mf.new_vreg(class);
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
        if self.t.patterns.iter().any(|p| !p.extra.is_empty()) {
            for &b in &layout {
                for &i in &f.blocks[b.index()].insts {
                    if let Some((h, terms)) = self.head_of(i)
                        && let Some(&v) = terms.first()
                    {
                        self.by_head.entry((b, h, v)).or_default().push(i);
                    }
                }
            }
        }
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
        // Parameters arrive where the convention puts them: registers, then
        // the caller's stack.
        self.cur = 0;
        let mut shapes: Vec<Vec<crate::abi::Part>> = Vec::new();
        for p in &f.params {
            let ty = f.locals[p.local.index()].ty;
            let sret = p.attrs.iter().any(|x| matches!(x, Attr::Type { name, .. } if name == "sret"));
            let wide = p.attrs.iter().any(|x| matches!(x, Attr::Word(w) if w == crate::wide::WIDE));
            shapes.push(match self.parts_of(ty) {
                Some(n) => vec![crate::abi::Part { size: 8, fp: false, sret: false, wide }; n],
                None => vec![crate::abi::Part {
                    size: self.arg_size(Value::Local(p.local)),
                    fp: self.is_fp(ty),
                    sret,
                    wide: false,
                }],
            });
        }
        let (part_locs, _) = self.mf.abi.assign_parts(&shapes, shapes.len());
        let sizes: Vec<u64> = shapes.iter().map(|s| s[0].size).collect();
        // A variadic function's variable arguments follow its named ones on
        // the stack, 8-aligned, under conventions that put them there.
        if let Type::Function { varargs: true, .. } = self.cx.m.types.get(f.ty) {
            if self.mf.abi.variadic != crate::abi::Variadic::Stack && !self.mf.abi.va_list_aapcs64 {
                return self
                    .err(format!("defining variadic functions under {} is not supported yet", self.mf.abi.name));
            }
            let end = part_locs
                .iter()
                .flatten()
                .zip(shapes.iter().flatten())
                .filter_map(|(l, part)| match l {
                    crate::abi::ArgLoc::Stack(off) => Some(off + part.size as i64),
                    _ => None,
                })
                .max()
                .unwrap_or(0);
            self.va_offset = (end + 7) / 8 * 8;
            // AAPCS64: the argument registers the named arguments left are
            // saved, x ones in one area and q ones in another, for va_arg
            // to find them (as clang's IR for it does).
            if self.mf.abi.va_list_aapcs64 {
                let used = |regs: &[u8]| {
                    part_locs
                        .iter()
                        .flatten()
                        .filter_map(|l| match l {
                            crate::abi::ArgLoc::Reg(r) => regs.iter().position(|x| x == r).map(|k| k + 1),
                            _ => None,
                        })
                        .max()
                        .unwrap_or(0)
                };
                let (args, fp_args) = (self.mf.abi.args.clone(), self.mf.abi.fp_args.clone());
                let (ngr, nvr) = (used(&args), used(&fp_args));
                let (gr, vr) = (8 * (args.len() - ngr) as i64, 16 * (fp_args.len() - nvr) as i64);
                self.mf.slots.push(Slot { size: gr.max(8) as u64, align: 8, offset: 0 });
                let gs = self.mf.slots.len() - 1;
                self.mf.slots.push(Slot { size: vr.max(16) as u64, align: 16, offset: 0 });
                let vs = self.mf.slots.len() - 1;
                let sp = self.t.machine.sp;
                let (stx, stq) =
                    (self.t.by_role("store.x"), self.t.role("store.q").ok_or("no instruction has role store.q")?);
                for (k, &r) in args.iter().enumerate().skip(ngr) {
                    let at = MOp::Frame(gs, 8 * (k - ngr) as i64);
                    self.push(MInst::new(stx, vec![MOp::Reg(Reg::P(r)), MOp::Reg(Reg::P(sp)), at]));
                }
                for (k, &r) in fp_args.iter().enumerate().skip(nvr) {
                    let at = MOp::Frame(vs, 16 * (k - nvr) as i64);
                    self.push(MInst::new(stq, vec![MOp::Reg(Reg::P(r)), MOp::Reg(Reg::P(sp)), at]));
                }
                self.va_areas = Some((gs, gr, vs, vr));
            }
        }
        for (k, p) in f.params.iter().enumerate() {
            if self.uses[p.local.index()] == 0 {
                continue;
            }
            if self.parts_of(f.locals[p.local.index()].ty).is_some() {
                // A small struct: a register for each part.
                let mut regs = Vec::new();
                for &loc in &part_locs[k] {
                    let d = self.ivreg(true);
                    match loc {
                        crate::abi::ArgLoc::Reg(r) => self.push(MInst::copy(Reg::V(d), Reg::P(r))),
                        crate::abi::ArgLoc::Stack(off) => {
                            let ld = self.t.by_role("load.x");
                            self.push(MInst::new(
                                ld,
                                vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::P(self.t.machine.sp)), MOp::Incoming(off)],
                            ));
                        }
                    }
                    regs.push(d);
                }
                self.agg_params.insert(p.local, regs);
                continue;
            }
            let d = self.vreg_of(p.local);
            match part_locs[k][0] {
                crate::abi::ArgLoc::Reg(r) => self.push(MInst::copy(Reg::V(d), Reg::P(r))),
                crate::abi::ArgLoc::Stack(off) => {
                    let ld = self.t.by_role(&format!("load.{}", mem_size(sizes[k], shapes[k][0].fp)));
                    let sp = self.t.machine.sp;
                    self.push(MInst::new(ld, vec![MOp::Reg(Reg::V(d)), MOp::Reg(Reg::P(sp)), MOp::Incoming(off)]));
                }
            }
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
        // The function's types caught and actions, before any landing pad's
        // code asks for a type's index.
        for &b in &layout {
            if let Some(t) = f.terminator(b)
                && let Op::Invoke { unwind, .. } = &f.insts[t.index()].op
            {
                self.action_for(*unwind)?;
            }
        }
        for (k, &b) in layout.iter().enumerate() {
            let next = layout.get(k + 1).copied();
            self.emit_block(b, next)?;
            let succs = if self.tail_blocks.contains(&b) {
                vec![]
            } else {
                f.successors(b).iter().map(|s| self.bmap[s]).collect()
            };
            self.mf.blocks[self.bmap[&b]].succs = succs;
        }
        self.emit_phi_copies()?;
        Ok(self.mf)
    }
}

/// The size letter in the roles of loads and stores: `load.w` and the like.
fn mem_size(size: u64, fp: bool) -> &'static str {
    match (size, fp) {
        (4, true) => "s",
        (_, true) => "d",
        (1, _) => "b",
        (2, _) => "h",
        (4, _) => "w",
        _ => "x",
    }
}

/// The description's move-wide pair (roles `movz.x`/`movk.x`, or `.w`),
/// and how many bits one moves: the widest immediate `movz` holds
/// unshifted (AArch64's 16).
fn move_wide_of(t: &Target, wide: bool) -> Option<(usize, usize, u32)> {
    let (z, k) = if wide { ("movz.x", "movk.x") } else { ("movz.w", "movk.w") };
    let (movz, movk) = (t.role(z)?, t.role(k)?);
    let fits = |c: u32| t.instrs[movz].fits(&[None, Some((1i64 << c) - 1), Some(0)]);
    let chunk = (1..=32).rev().find(|&c| fits(c))?;
    Some((movz, movk, chunk))
}

/// Whether `attrs` (with their groups) has the keyword attribute `word`.
fn has_word(m: &Module, attrs: &[Attr], word: &str) -> bool {
    attrs.iter().any(|a| match a {
        Attr::Word(w) => w == word,
        Attr::Group(g) => m.attr_groups.iter().find(|x| x.id == *g).is_some_and(|x| has_word(m, &x.attrs, word)),
        _ => false,
    })
}

/// An atomic operation, of any ordering, or a fence.
fn is_atomic(op: &Op) -> bool {
    matches!(
        op,
        Op::Load { atomic: Some(_), .. }
            | Op::Store { atomic: Some(_), .. }
            | Op::AtomicRmw { .. }
            | Op::CmpXchg { .. }
            | Op::Fence { .. }
    )
}
