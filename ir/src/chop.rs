//! Autochop: counting every elective change to the code, so that a
//! miscompilation can be found by binary search to the one change that
//! causes it.
//!
//! Every elective change is a *step*: a rule applied, a value merged, a
//! call inlined, a pattern chosen. Before making one, a pass asks
//! `allow(|| description)`, and makes the change only if the answer is
//! yes. Mandatory work (legalising, lowering) never asks.
//!
//! Steps are counted per function, functions being numbered in module
//! order (those with bodies, from 0). A limit `F:T` lets:
//!
//! - functions before `F` make every step;
//! - function `F` make its first `T` steps;
//! - functions after `F` make none.
//!
//! Each function's count depends only on its own work, never on which
//! thread did it or when, so a limit means the same with any number of
//! threads. A search (see `search`) first finds the first function whose
//! steps make a test fail, then the first failing step in it.
//!
//! The counter for the function being worked on lives in a thread-local,
//! installed by whoever runs passes on it (`Session::enter`), so passes
//! need no extra arguments: they call `allow`. With no counter installed,
//! everything is allowed.

use std::cell::RefCell;
use std::sync::Mutex;

/// How far elective changes may go: see the module's documentation.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Limit {
    pub func: usize,
    pub steps: u64,
}

impl Limit {
    /// `F` (no steps in `F`) or `F:T`.
    pub fn parse(s: &str) -> Option<Limit> {
        let (f, t) = match s.split_once(':') {
            Some((f, t)) => (f, t.parse().ok()?),
            None => (s, 0),
        };
        Some(Limit { func: f.parse().ok()?, steps: t })
    }

    /// How many steps function `index` may make.
    fn allowed(&self, index: usize) -> u64 {
        use std::cmp::Ordering::*;
        match index.cmp(&self.func) {
            Less => u64::MAX,
            Equal => self.steps,
            Greater => 0,
        }
    }
}

impl std::fmt::Display for Limit {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}:{}", self.func, self.steps)
    }
}

/// One function's count.
#[derive(Clone, Debug, Default)]
pub struct Counter {
    /// Steps made.
    pub steps: u64,
    /// Steps refused by the limit.
    pub refused: u64,
    allowed: u64,
    /// The last step allowed in the function the limit stops in, which is
    /// the one a search reports.
    pub last: Option<String>,
}

impl Counter {
    fn allow(&mut self, what: impl FnOnce() -> String) -> bool {
        if self.steps >= self.allowed {
            self.refused += 1;
            return false;
        }
        self.steps += 1;
        // Only the limit's own step is described, so counting costs an
        // increment.
        if self.steps == self.allowed {
            self.last = Some(what());
        }
        true
    }
}

thread_local! {
    static CURRENT: RefCell<Option<(usize, Counter)>> = const { RefCell::new(None) };
}

/// Whether the elective change `what` describes may be made; counts it if
/// so. Outside a function being counted, always yes.
pub fn allow(what: impl FnOnce() -> String) -> bool {
    CURRENT.with(|c| match &mut *c.borrow_mut() {
        Some((_, counter)) => counter.allow(what),
        None => true,
    })
}

/// The counts of one run of a tool over a module.
pub struct Session {
    limit: Option<Limit>,
    counters: Mutex<Vec<Counter>>,
}

/// While alive, the thread counts steps for one function.
pub struct Guard<'s> {
    session: &'s Session,
}

impl Session {
    /// For `functions` functions, under `limit` (none: everything allowed,
    /// only counted).
    pub fn new(functions: usize, limit: Option<Limit>) -> Session {
        let counters = (0..functions)
            .map(|k| Counter { allowed: limit.map_or(u64::MAX, |l| l.allowed(k)), ..Default::default() })
            .collect();
        Session { limit, counters: Mutex::new(counters) }
    }

    pub fn limit(&self) -> Option<Limit> {
        self.limit
    }

    /// Counts this thread's steps for function `index` until the guard is
    /// dropped. A function's passes may enter it many times; its count
    /// goes on from where it was.
    pub fn enter(&self, index: usize) -> Guard<'_> {
        let counter = std::mem::take(&mut self.counters.lock().unwrap()[index]);
        CURRENT.with(|c| {
            let previous = c.borrow_mut().replace((index, counter));
            assert!(previous.is_none(), "steps are already being counted for function {}", previous.unwrap().0);
        });
        Guard { session: self }
    }

    /// Each function's count, by index.
    pub fn counts(&self) -> Vec<Counter> {
        self.counters.lock().unwrap().clone()
    }

    /// Where the limit stopped, if it stopped in a function: the function's
    /// index, and the description of its last step allowed.
    pub fn stopped_at(&self) -> Option<(usize, u64, Option<String>)> {
        let l = self.limit?;
        let c = self.counters.lock().unwrap().get(l.func)?.clone();
        Some((l.func, c.steps, c.last))
    }
}

impl Drop for Guard<'_> {
    fn drop(&mut self) {
        let (index, counter) = CURRENT.with(|c| c.borrow_mut().take()).expect("a counter is installed");
        self.session.counters.lock().unwrap()[index] = counter;
    }
}

/// The limit a tool is asked for: its option, else the environment
/// variable `var` (so that a search can set it for a tool that a build
/// runs).
pub fn limit_from(option: Option<&str>, var: &str) -> Result<Option<Limit>, String> {
    let text = match option {
        Some(s) => Some(s.to_string()),
        None => std::env::var(var).ok().filter(|s| !s.is_empty()),
    };
    match text {
        None => Ok(None),
        Some(t) => Limit::parse(&t).map(Some).ok_or_else(|| format!("a bad chop limit {t:?}: F or F:T")),
    }
}

/// Appends each function's count to the file the environment variable
/// `DRACONIAN_CHOP_COUNTS` names, if any, as lines `tool index steps name`,
/// for a search to read.
pub fn report_counts(tool: &str, names: &[String], steps: &[u64]) -> std::io::Result<()> {
    let Ok(path) = std::env::var("DRACONIAN_CHOP_COUNTS") else { return Ok(()) };
    use std::io::Write;
    let mut f = std::fs::OpenOptions::new().create(true).append(true).open(path)?;
    for (k, n) in steps.iter().enumerate() {
        writeln!(f, "{tool} {k} {n} {}", names.get(k).map_or("?", String::as_str))?;
    }
    Ok(())
}

/// What a search found.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Found {
    /// The first failing limit: function `func`'s step `steps` (from 1).
    Step(Limit),
    /// The test fails with no elective changes at all.
    FailsWithNone,
    /// The test passes with every change: nothing to find.
    PassesWithAll,
}

/// Finds the first step that makes `passes` false, by binary search: first
/// over functions (each function's steps all or none), then over the
/// steps of the function found. `steps[k]` is function `k`'s count with
/// no limit.
///
/// The search assumes that what fails with some steps also fails with
/// more, which holds when the steps are independent. When they are not
/// (an inlined callee is optimised less), the answer is still a step whose
/// limit fails while the one before passes, which `passes` has checked.
pub fn search(steps: &[u64], mut passes: impl FnMut(Limit) -> bool) -> Found {
    let n = steps.len();
    if passes(Limit { func: n, steps: 0 }) {
        return Found::PassesWithAll;
    }
    if !passes(Limit { func: 0, steps: 0 }) {
        return Found::FailsWithNone;
    }
    // Functions: the first `k` all, the rest none. Passes at 0, fails at n.
    let (mut lo, mut hi) = (0usize, n);
    while hi - lo > 1 {
        let mid = (lo + hi) / 2;
        if passes(Limit { func: mid, steps: 0 }) {
            lo = mid;
        } else {
            hi = mid;
        }
    }
    let func = hi - 1;
    // Steps in it: passes with none, fails with all. Its count in the
    // full run may be too few: with the functions after it held back it
    // may do more (inlining their unoptimised bodies brings more to do),
    // so the top is doubled until it fails.
    let (mut lo, mut hi) = (0u64, steps[func].max(1));
    while passes(Limit { func, steps: hi }) {
        lo = hi;
        hi = hi.saturating_mul(2);
        if hi >= 1 << 40 {
            // Every step of it passes, yet all of it with the next
            // function's none fails: the steps are not independent.
            return Found::Step(Limit { func: func + 1, steps: 0 });
        }
    }
    while hi - lo > 1 {
        let mid = lo + (hi - lo) / 2;
        if passes(Limit { func, steps: mid }) {
            lo = mid;
        } else {
            hi = mid;
        }
    }
    Found::Step(Limit { func, steps: hi })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counting_and_limits() {
        let s = Session::new(3, Limit::parse("1:2"));
        let mut made = vec![0; 3];
        for (k, n) in made.iter_mut().enumerate() {
            let _g = s.enter(k);
            for step in 0..5 {
                if allow(|| format!("f{k} step {}", step + 1)) {
                    *n += 1;
                }
            }
        }
        assert_eq!(made, vec![5, 2, 0]);
        assert_eq!(s.stopped_at(), Some((1, 2, Some("f1 step 2".into()))));
        assert!(allow(|| unreachable!()), "outside a function everything is allowed");
    }

    #[test]
    fn search_finds_the_bad_step() {
        // Function 2's step 4 breaks the test.
        let steps = vec![10, 3, 7, 5];
        let bad = Limit { func: 2, steps: 4 };
        let breaks = |l: Limit| l.func > bad.func || (l.func == bad.func && l.steps >= bad.steps);
        let mut tries = 0;
        let found = search(&steps, |l| {
            tries += 1;
            !breaks(l)
        });
        assert_eq!(found, Found::Step(bad));
        assert!(tries < 10, "{tries} tries");
        assert_eq!(search(&steps, |_| true), Found::PassesWithAll);
        // A function that makes more steps than its count says when the
        // functions after it are held back.
        let bad = Limit { func: 1, steps: 9 };
        let breaks = |l: Limit| l.func > bad.func || (l.func == bad.func && l.steps >= bad.steps);
        assert_eq!(search(&steps, |l| !breaks(l)), Found::Step(bad));
        assert_eq!(search(&steps, |_| false), Found::FailsWithNone);
    }
}
