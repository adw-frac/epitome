//! Memory SSA: memory as one SSA variable, so that "the last write before
//! this load" is an edge to follow, not a search.
//!
//! Every instruction that may write memory *defines* a new memory version
//! (a `Def`), whose operand is the version before it. Every instruction
//! that only reads memory *uses* the current version (a `Use`). Where paths
//! with different versions meet, a memory phi (`Phi`) merges them. The
//! entry block starts from `LiveOnEntry`, the memory the function is called
//! with. The form follows LLVM's MemorySSA document
//! (<https://llvm.org/docs/MemorySSA.html>).
//!
//! Building it is one walk of the function in reverse postorder. A block
//! with several predecessors gets a phi, filled in once every block is
//! done; then phis whose entries are all one version (or themselves) are
//! removed, as in Braun et al.'s SSA construction (see `ssa.rs`), with a
//! worklist so that each removal re-checks only the phis that used it. The
//! cost is linear in the function's size.
//!
//! The versions say nothing about locations: a store to `%a` is the
//! version a load of `%b` uses, even if they cannot alias. Which write
//! really reaches a load, its *clobber*, is found on demand by `Walker`,
//! which walks up the versions past writes that alias analysis says cannot
//! touch the location. Each question has a budget of alias queries, so a
//! long chain of unrelated stores (a big block) costs a bounded amount per
//! question; when the budget runs out the walker stops where it is, which
//! is a safe answer ("this may clobber"). Answers are cached.
//!
//! A walk goes up through a phi only if the location's pointer is defined
//! above the phi's block (it dominates it), so that it is the same address
//! on every way in. Otherwise, going round a loop would compare the
//! pointer with itself as it was in the previous iteration, which is the
//! same SSA value but another address: the walk stops at the phi.

use std::cell::{Cell, RefCell};

use crate::fx::{FxHashMap as HashMap, FxHashSet as HashSet};

use draconian_ir::module::*;

use crate::aa::{BasicAa, Location};
use crate::cfg;

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug, PartialOrd, Ord)]
pub struct AccessId(pub u32);

impl AccessId {
    /// The memory the function starts with.
    pub const LIVE_ON_ENTRY: AccessId = AccessId(0);

    pub fn index(self) -> usize {
        self.0 as usize
    }
}

#[derive(Clone, Debug, PartialEq)]
pub enum Access {
    LiveOnEntry,
    /// An instruction that may write memory, and the version before it.
    Def {
        inst: InstId,
        block: BlockId,
        prev: AccessId,
    },
    /// An instruction that only reads memory, and the version it reads.
    Use {
        inst: InstId,
        block: BlockId,
        def: AccessId,
    },
    /// The version at the start of a block where paths meet: one entry
    /// per (reachable) predecessor.
    Phi {
        block: BlockId,
        incoming: Vec<(BlockId, AccessId)>,
    },
}

pub struct MemorySsa {
    pub accesses: Vec<Access>,
    /// The access of each instruction that touches memory.
    of_inst: HashMap<InstId, AccessId>,
    /// The phi at the start of each block that has one.
    phi_of: HashMap<BlockId, AccessId>,
    /// Numbers for printing: definitions and phis from 1, in order.
    number: Vec<u32>,
}

impl MemorySsa {
    pub fn build(aa: &BasicAa, f: &Function) -> MemorySsa {
        let rpo = cfg::reverse_postorder(f);
        let preds = f.predecessors();
        let mut reachable = vec![false; f.blocks.len()];
        for &b in &rpo {
            reachable[b.index()] = true;
        }
        let mut accesses = vec![Access::LiveOnEntry];
        let mut of_inst = HashMap::default();
        let mut phi_of: HashMap<BlockId, AccessId> = HashMap::default();
        let mut out: Vec<Option<AccessId>> = vec![None; f.blocks.len()];
        let new = |accesses: &mut Vec<Access>, a: Access| {
            accesses.push(a);
            AccessId(accesses.len() as u32 - 1)
        };
        for (k, &b) in rpo.iter().enumerate() {
            let ps: Vec<BlockId> = preds[b.index()].iter().copied().filter(|p| reachable[p.index()]).collect();
            let mut cur = if k == 0 {
                AccessId::LIVE_ON_ENTRY
            } else if let [p] = ps[..]
                && let Some(o) = out[p.index()]
            {
                // One way in, already walked (a block's only predecessor
                // comes before it in reverse postorder).
                o
            } else {
                let phi = new(&mut accesses, Access::Phi { block: b, incoming: vec![] });
                phi_of.insert(b, phi);
                phi
            };
            for &i in &f.blocks[b.index()].insts {
                let e = aa.effects(&f.insts[i.index()]);
                if e.mods {
                    cur = new(&mut accesses, Access::Def { inst: i, block: b, prev: cur });
                    of_inst.insert(i, cur);
                } else if e.refs {
                    let u = new(&mut accesses, Access::Use { inst: i, block: b, def: cur });
                    of_inst.insert(i, u);
                }
            }
            out[b.index()] = Some(cur);
        }
        // The phis' entries, now that every block's last version is known.
        for (&b, &phi) in &phi_of {
            let incoming: Vec<(BlockId, AccessId)> = preds[b.index()]
                .iter()
                .filter(|p| reachable[p.index()])
                .map(|&p| (p, out[p.index()].expect("a reachable block was walked")))
                .collect();
            accesses[phi.index()] = Access::Phi { block: b, incoming };
        }
        let mut m = MemorySsa { accesses, of_inst, phi_of, number: vec![] };
        m.remove_trivial_phis();
        m.renumber();
        m
    }

    /// Removes phis whose entries are one version, or themselves, and
    /// points everything that used them at that version.
    fn remove_trivial_phis(&mut self) {
        let n = self.accesses.len();
        let mut forward: Vec<Option<AccessId>> = vec![None; n];
        fn resolve(forward: &mut [Option<AccessId>], mut a: AccessId) -> AccessId {
            let start = a;
            while let Some(b) = forward[a.index()] {
                a = b;
            }
            // Path compression.
            let mut x = start;
            while let Some(b) = forward[x.index()] {
                forward[x.index()] = Some(a);
                x = b;
            }
            a
        }
        // The phis that use each phi, to re-check when it goes.
        let mut users: HashMap<AccessId, Vec<AccessId>> = HashMap::default();
        let mut work: Vec<AccessId> = Vec::new();
        for (k, a) in self.accesses.iter().enumerate() {
            if let Access::Phi { incoming, .. } = a {
                work.push(AccessId(k as u32));
                for &(_, v) in incoming {
                    if matches!(self.accesses[v.index()], Access::Phi { .. }) {
                        users.entry(v).or_default().push(AccessId(k as u32));
                    }
                }
            }
        }
        while let Some(phi) = work.pop() {
            if forward[phi.index()].is_some() {
                continue;
            }
            let Access::Phi { incoming, .. } = &self.accesses[phi.index()] else { continue };
            let entries: Vec<AccessId> = incoming.iter().map(|&(_, v)| v).collect();
            let mut only = None;
            let mut trivial = true;
            for v in entries {
                let v = resolve(&mut forward, v);
                if v == phi || only == Some(v) {
                    continue;
                }
                if only.is_some() {
                    trivial = false;
                    break;
                }
                only = Some(v);
            }
            // A phi that only takes its own value is in a loop nothing
            // enters; it stays (it is unreachable in practice).
            if let (true, Some(v)) = (trivial, only) {
                forward[phi.index()] = Some(v);
                work.extend(users.get(&phi).into_iter().flatten().copied());
            }
        }
        // Everything points past the removed phis.
        for k in 0..n {
            let a = std::mem::replace(&mut self.accesses[k], Access::LiveOnEntry);
            self.accesses[k] = match a {
                Access::Def { inst, block, prev } => Access::Def { inst, block, prev: resolve(&mut forward, prev) },
                Access::Use { inst, block, def } => Access::Use { inst, block, def: resolve(&mut forward, def) },
                Access::Phi { block, incoming } => Access::Phi {
                    block,
                    incoming: incoming.into_iter().map(|(p, v)| (p, resolve(&mut forward, v))).collect(),
                },
                Access::LiveOnEntry => Access::LiveOnEntry,
            };
        }
        self.phi_of.retain(|_, phi| forward[phi.index()].is_none());
    }

    fn renumber(&mut self) {
        let live_phis: HashSet<AccessId> = self.phi_of.values().copied().collect();
        self.number = vec![0; self.accesses.len()];
        let mut next = 1;
        for (k, a) in self.accesses.iter().enumerate() {
            let counted = match a {
                Access::Def { .. } => true,
                Access::Phi { .. } => live_phis.contains(&AccessId(k as u32)),
                _ => false,
            };
            if counted {
                self.number[k] = next;
                next += 1;
            }
        }
    }

    /// The access of an instruction, if it touches memory.
    pub fn access_of(&self, i: InstId) -> Option<AccessId> {
        self.of_inst.get(&i).copied()
    }

    /// The phi at the start of block `b`, if it has one.
    pub fn phi_at(&self, b: BlockId) -> Option<AccessId> {
        self.phi_of.get(&b).copied()
    }

    pub fn get(&self, a: AccessId) -> &Access {
        &self.accesses[a.index()]
    }

    /// The version an access reads or follows: a use's definition, a
    /// definition's previous version.
    pub fn defining(&self, a: AccessId) -> Option<AccessId> {
        match self.accesses[a.index()] {
            Access::Def { prev, .. } => Some(prev),
            Access::Use { def, .. } => Some(def),
            _ => None,
        }
    }

    /// How many definitions, uses and (live) phis there are.
    pub fn counts(&self) -> (usize, usize, usize) {
        let defs = self.accesses.iter().filter(|a| matches!(a, Access::Def { .. })).count();
        let uses = self.accesses.iter().filter(|a| matches!(a, Access::Use { .. })).count();
        (defs, uses, self.phi_of.len())
    }

    /// `liveOnEntry`, or a definition's or phi's number.
    pub fn name(&self, a: AccessId) -> String {
        if a == AccessId::LIVE_ON_ENTRY { "liveOnEntry".to_string() } else { self.number[a.index()].to_string() }
    }

    /// An access as LLVM's printer writes it: `3 = MemoryDef(2)`,
    /// `MemoryUse(3)`, `4 = MemoryPhi({loop,3},{entry,1})`, with block names
    /// from `block`.
    pub fn describe(&self, a: AccessId, block: &dyn Fn(BlockId) -> String) -> String {
        match &self.accesses[a.index()] {
            Access::LiveOnEntry => "liveOnEntry".to_string(),
            Access::Def { prev, .. } => format!("{} = MemoryDef({})", self.name(a), self.name(*prev)),
            Access::Use { def, .. } => format!("MemoryUse({})", self.name(*def)),
            Access::Phi { incoming, .. } => {
                let parts: Vec<String> =
                    incoming.iter().map(|&(p, v)| format!("{{{},{}}}", block(p), self.name(v))).collect();
                format!("{} = MemoryPhi({})", self.name(a), parts.join(","))
            }
        }
    }
}

/// What a walk found.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Clobber {
    /// The write that may change the location (a `Def`), the phi where
    /// paths with different writes meet, or `LiveOnEntry`.
    pub at: AccessId,
    /// False if the walk stopped at `at` because its budget ran out: `at`
    /// is then only "as far as we looked", which is still safe to treat as
    /// a clobber.
    pub exact: bool,
}

/// Counts, for `--stats` and for checking costs stay bounded.
#[derive(Clone, Copy, Default, Debug)]
pub struct WalkStats {
    pub queries: u64,
    pub cache_hits: u64,
    /// Alias queries made (one per write looked at).
    pub steps: u64,
    pub gave_up: u64,
}

/// A path's result inside a walk: a clobber, or a return to a phi being
/// explored further up (a loop that writes nothing that matters).
#[derive(Clone, Copy, PartialEq, Eq)]
enum Reach {
    Found(Clobber),
    Back(AccessId),
}

/// Answers "which write reaches this access?", on demand.
pub struct Walker<'a, 's, 'm> {
    ssa: &'a MemorySsa,
    aa: &'a BasicAa<'s, 'm>,
    f: &'a Function,
    /// Alias queries allowed per question.
    pub budget: u32,
    cache: RefCell<HashMap<(AccessId, Location), Clobber>>,
    stats: Cell<WalkStats>,
    dom: cfg::DomTree,
    /// The block of each instruction.
    block_of: Vec<Option<BlockId>>,
}

impl<'a, 's, 'm> Walker<'a, 's, 'm> {
    /// The default budget: as many writes as CSE looks back over.
    pub const BUDGET: u32 = 64;

    pub fn new(ssa: &'a MemorySsa, aa: &'a BasicAa<'s, 'm>, f: &'a Function) -> Self {
        Walker {
            ssa,
            aa,
            f,
            budget: Self::BUDGET,
            cache: Default::default(),
            stats: Default::default(),
            dom: cfg::DomTree::new(f),
            block_of: f.inst_blocks(),
        }
    }

    /// Whether `v` has the same value on every way into block `b`: it is a
    /// constant or a parameter, or defined in a block that strictly
    /// dominates `b`.
    fn fixed_at(&self, v: Value, b: BlockId) -> bool {
        let Value::Local(l) = v else { return true };
        match self.f.locals[l.index()].def {
            LocalDef::Inst(i) => self.block_of[i.index()].is_some_and(|d| d != b && self.dom.dominates(d, b)),
            _ => true,
        }
    }

    pub fn stats(&self) -> WalkStats {
        self.stats.get()
    }

    /// The location a load or store accesses.
    pub fn location_of(&self, i: InstId) -> Option<Location> {
        let inst = &self.f.insts[i.index()];
        match &inst.op {
            Op::Load { ptr, .. } => Some(self.aa.location(*ptr, self.f.locals[inst.result?.index()].ty)),
            Op::Store { ptr, value, .. } => {
                let ty = match value {
                    Value::Local(l) => self.f.locals[l.index()].ty,
                    Value::Const(c) => self.aa.const_type(*c),
                    Value::Metadata(_) => return None,
                };
                Some(self.aa.location(*ptr, ty))
            }
            _ => None,
        }
    }

    /// The write that reaches a load (or, for a store, the write before it
    /// to the bytes it writes), if the instruction is a load or store.
    pub fn clobber_of(&self, i: InstId) -> Option<Clobber> {
        let a = self.ssa.access_of(i)?;
        let loc = self.location_of(i)?;
        Some(self.clobber(self.ssa.defining(a)?, loc))
    }

    /// The nearest write at or above version `start` that may change `loc`.
    pub fn clobber(&self, start: AccessId, loc: Location) -> Clobber {
        let mut st = self.stats.get();
        st.queries += 1;
        if let Some(&c) = self.cache.borrow().get(&(start, loc)) {
            st.cache_hits += 1;
            self.stats.set(st);
            return c;
        }
        self.stats.set(st);
        let mut budget = self.budget;
        let mut exploring = HashSet::default();
        let mut outer = false;
        let c = match self.walk(start, loc, &mut budget, &mut exploring, &mut outer) {
            Reach::Found(c) => c,
            // Only phis being explored can be returned to, and none is.
            Reach::Back(_) => unreachable!("a walk ended inside a phi"),
        };
        if !c.exact {
            let mut st = self.stats.get();
            st.gave_up += 1;
            self.stats.set(st);
        }
        self.cache.borrow_mut().insert((start, loc), c);
        c
    }

    /// Walks up from `a`. `outer` is set if the walk came back to a phi
    /// being explored further up, whose answer is not known yet.
    fn walk(
        &self,
        mut a: AccessId,
        loc: Location,
        budget: &mut u32,
        exploring: &mut HashSet<AccessId>,
        outer: &mut bool,
    ) -> Reach {
        loop {
            if let Some(&c) = self.cache.borrow().get(&(a, loc)) {
                return Reach::Found(c);
            }
            match &self.ssa.accesses[a.index()] {
                Access::LiveOnEntry => return Reach::Found(Clobber { at: a, exact: true }),
                Access::Use { .. } => unreachable!("a use is never a version"),
                Access::Def { inst, prev, .. } => {
                    if *budget == 0 {
                        return Reach::Found(Clobber { at: a, exact: false });
                    }
                    *budget -= 1;
                    let mut st = self.stats.get();
                    st.steps += 1;
                    self.stats.set(st);
                    if self.aa.mod_ref(self.f, &self.f.insts[inst.index()], loc).mods {
                        return Reach::Found(Clobber { at: a, exact: true });
                    }
                    a = *prev;
                }
                Access::Phi { incoming, block } => {
                    if exploring.contains(&a) {
                        return Reach::Back(a);
                    }
                    if !self.fixed_at(loc.ptr, *block) {
                        return Reach::Found(Clobber { at: a, exact: true });
                    }
                    if *budget == 0 {
                        return Reach::Found(Clobber { at: a, exact: false });
                    }
                    *budget -= 1;
                    exploring.insert(a);
                    // The same write on every way in is the clobber;
                    // different ones make the phi itself the clobber. A way
                    // that comes back here (a loop writing nothing that
                    // matters) adds nothing.
                    let mut found: Option<Clobber> = None;
                    let mut result = None;
                    let mut reached_outer = false;
                    for &(_, v) in incoming {
                        let mut inner = false;
                        let r = self.walk(v, loc, budget, exploring, &mut inner);
                        reached_outer |= inner;
                        match r {
                            Reach::Back(p) if p == a => {}
                            // Back to a phi further up: this phi's answer
                            // depends on that one's, so it is its own.
                            Reach::Back(_) => {
                                reached_outer = true;
                                result = Some(Clobber { at: a, exact: true });
                                break;
                            }
                            Reach::Found(c) if !c.exact => {
                                result = Some(Clobber { at: a, exact: false });
                                break;
                            }
                            Reach::Found(c) => match found {
                                None => found = Some(c),
                                Some(prev) if prev.at == c.at => {}
                                Some(_) => {
                                    result = Some(Clobber { at: a, exact: true });
                                    break;
                                }
                            },
                        }
                    }
                    exploring.remove(&a);
                    let c = result.or(found).unwrap_or(Clobber { at: a, exact: true });
                    // An answer that came back to no phi further up, and did
                    // not run out of budget, is the same however the phi was
                    // reached: kept, so that paths meeting here again (a
                    // chain of diamonds) do not explore it again.
                    if c.exact && !reached_outer {
                        self.cache.borrow_mut().insert((a, loc), c);
                    }
                    *outer |= reached_outer;
                    return Reach::Found(c);
                }
            }
        }
    }
}

/// What `analyse_module` found in one function.
pub struct FunctionReport {
    pub defs: usize,
    pub uses: usize,
    pub phis: usize,
    pub walks: WalkStats,
    /// The time to build memory SSA, and to answer every load's and store's
    /// clobber.
    pub build: std::time::Duration,
    pub walk: std::time::Duration,
    /// Comments for the printer, by place.
    pub notes: HashMap<draconian_ir::printer::Place, String>,
}

/// Names of a function's blocks as the printer writes them: `%name`, or
/// `%N` for unnamed ones, numbered as values are.
fn block_names(f: &Function) -> Vec<String> {
    let mut names = vec![String::new(); f.blocks.len()];
    let mut next = 0u32;
    let mut number = |l: LocalId| -> Option<u32> {
        if f.locals[l.index()].name.is_none() {
            next += 1;
            Some(next - 1)
        } else {
            None
        }
    };
    for p in &f.params {
        number(p.local);
    }
    for &b in &f.layout {
        let block = &f.blocks[b.index()];
        names[b.index()] = match number(block.local) {
            Some(n) => format!("%{n}"),
            None => {
                format!("%{}", draconian_ir::printer::ident(f.locals[block.local.index()].name.as_deref().unwrap()))
            }
        };
        for &i in &block.insts {
            if let Some(r) = f.insts[i.index()].result {
                number(r);
            }
        }
    }
    names
}

/// Memory SSA for one function, with every load's and store's clobber
/// asked for (as a printer, or a pass that looks at them all, would).
pub fn analyse(aa: &BasicAa, f: &Function, notes: bool) -> FunctionReport {
    use draconian_ir::printer::Place;
    let t0 = std::time::Instant::now();
    let ssa = MemorySsa::build(aa, f);
    let t1 = std::time::Instant::now();
    let walker = Walker::new(&ssa, aa, f);
    let mut clobbers: HashMap<InstId, Clobber> = HashMap::default();
    for i in f.insts_in_order() {
        if let Some(c) = walker.clobber_of(i) {
            clobbers.insert(i, c);
        }
    }
    let t2 = std::time::Instant::now();
    let (defs, uses, phis) = ssa.counts();
    let mut out = HashMap::default();
    if notes {
        let names = block_names(f);
        let block = |b: BlockId| names[b.index()].clone();
        for &b in &f.layout {
            if let Some(phi) = ssa.phi_at(b) {
                out.insert(Place::Block(b), ssa.describe(phi, &block));
            }
            for &i in &f.blocks[b.index()].insts {
                let Some(a) = ssa.access_of(i) else { continue };
                let mut text = ssa.describe(a, &block);
                if let Some(c) = clobbers.get(&i) {
                    let what = if matches!(ssa.get(a), Access::Def { .. }) { "writes over" } else { "clobbered by" };
                    text.push_str(&format!(" -- {what} {}", ssa.name(c.at)));
                    if !c.exact {
                        text.push_str(&format!(" (gave up after {} checks)", walker.budget));
                    }
                }
                out.insert(Place::Inst(i), text);
            }
        }
    }
    FunctionReport { defs, uses, phis, walks: walker.stats(), build: t1 - t0, walk: t2 - t1, notes: out }
}

/// `analyse` on every function of the module, on `threads` threads; the
/// reports come back by function.
pub fn analyse_module(m: &mut Module, threads: usize, notes: bool) -> Vec<(GlobalId, FunctionReport)> {
    let funcs: Vec<GlobalId> = m.functions().filter(|(_, f)| f.has_body).map(|(g, _)| g).collect();
    let (reports, _) = crate::ctx::parallel_phase(m, Default::default(), |sh| {
        // Every body is published first and only read: alias analysis
        // looks at callees' published bodies, so a callee must not be
        // published or not depending on which thread got there first.
        for &g in &funcs {
            sh.publish(g, sh.take(g));
        }
        crate::par::map(&funcs, threads, |_, &g| {
            let f = sh.published(g).expect("published above");
            let aa = BasicAa::new(sh, f);
            analyse(&aa, f, notes)
        })
    });
    funcs.into_iter().zip(reports).collect()
}
