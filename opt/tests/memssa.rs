//! Memory SSA and its walker (`src/memssa.rs`).
//!
//! 1. Soundness, against a search that knows nothing of memory SSA: for
//!    every load and store, every path back from it must reach the clobber
//!    the walker gave without passing a write that alias analysis says may
//!    touch the location, and without going up through a memory phi where
//!    the pointer is not the same on every way in. On a hand-written example,
//!    on random control flow, and on the C test programs.
//! 2. The printed analysis of the example is as expected.
//! 3. Costs stay bounded: big blocks, long chains of joins and deep loops
//!    take time in proportion to their size, and no question makes more
//!    alias queries than its budget.

use std::collections::HashSet;
use std::fmt::Write;
use std::path::PathBuf;
use std::process::Command;

use epitome_ir::module::*;
use epitome_opt::aa::BasicAa;
use epitome_opt::cfg::DomTree;
use epitome_opt::ctx::parallel_phase;
use epitome_opt::memssa::{Access, AccessId, MemorySsa, Walker};

fn examples() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/memssa")
}

/// Runs `check` on every function with a body, as the analysis sees it.
fn each_function(src: &str, mut check: impl FnMut(&str, &BasicAa, &Function)) {
    let mut m = epitome_ir::parse_module(src).unwrap();
    let funcs: Vec<(GlobalId, String)> = m
        .functions()
        .filter(|(_, f)| f.has_body)
        .map(|(g, _)| (g, m.global(g).name.clone().unwrap_or_default()))
        .collect();
    parallel_phase(&mut m, Default::default(), |sh| {
        for (g, _) in &funcs {
            sh.publish(*g, sh.take(*g));
        }
        for (g, name) in &funcs {
            let f = sh.published(*g).unwrap();
            let aa = BasicAa::new(sh, f);
            check(name, &aa, f);
        }
    });
}

/// Whether `v` is the same value on every way into `b` (as the walker
/// requires before going up through a join).
fn fixed_at(f: &Function, dom: &DomTree, blocks: &[Option<BlockId>], v: Value, b: BlockId) -> bool {
    match v {
        Value::Local(l) => match f.locals[l.index()].def {
            LocalDef::Inst(i) => blocks[i.index()].is_some_and(|d| d != b && dom.dominates(d, b)),
            _ => true,
        },
        _ => true,
    }
}

/// Checks every load's and store's clobber by searching back over the
/// CFG. Returns the number of accesses checked.
fn check_function(name: &str, aa: &BasicAa, f: &Function) -> usize {
    let ssa = MemorySsa::build(aa, f);
    let walker = Walker::new(&ssa, aa, f);
    let dom = DomTree::new(f);
    let blocks = f.inst_blocks();
    let preds = f.predecessors();
    let pos = |i: InstId| {
        let b = blocks[i.index()].unwrap();
        (b, f.blocks[b.index()].insts.iter().position(|&x| x == i).unwrap())
    };
    let entry = f.entry();
    let mut checked = 0;
    for i in f.insts_in_order() {
        let Some(c) = walker.clobber_of(i) else { continue };
        if !c.exact {
            continue;
        }
        let loc = walker.location_of(i).unwrap();
        let what = format!("@{name}: the access at instruction {} (clobber {})", i.0, ssa.name(c.at));
        // Where the search stops.
        let stop_inst = match ssa.get(c.at) {
            Access::Def { inst, .. } => {
                assert!(
                    aa.mod_ref(f, &f.insts[inst.index()], loc).mods,
                    "{what}: the clobber does not write the location"
                );
                Some(*inst)
            }
            _ => None,
        };
        let stop_block = match ssa.get(c.at) {
            Access::Phi { block, .. } => Some(*block),
            _ => None,
        };
        let live_on_entry = c.at == AccessId::LIVE_ON_ENTRY;
        // (block, how many of its instructions to look at, from the end).
        let (b0, k0) = pos(i);
        let mut work = vec![(b0, k0)];
        let mut entered: HashSet<BlockId> = HashSet::new();
        while let Some((b, upto)) = work.pop() {
            let insts = &f.blocks[b.index()].insts;
            let mut stopped = false;
            for &w in insts[..upto].iter().rev() {
                if Some(w) == stop_inst {
                    stopped = true;
                    break;
                }
                if aa.effects(&f.insts[w.index()]).mods {
                    assert!(
                        !aa.mod_ref(f, &f.insts[w.index()], loc).mods,
                        "{what}: a path passes instruction {}, which may write the location",
                        w.0
                    );
                }
            }
            if stopped || stop_block == Some(b) {
                continue;
            }
            if b == entry {
                assert!(live_on_entry, "{what}: a path reaches the entry without passing the clobber");
                continue;
            }
            let ps: Vec<BlockId> = preds[b.index()].iter().copied().filter(|p| dom.is_reachable(*p)).collect();
            // Through a join where memory differs by the way in (a memory
            // phi), the pointer must be the same on every way in. (A join
            // with no phi has one version on every way in; and a loop with
            // a write in it always has a phi at its head.)
            if ps.len() > 1 && ssa.phi_at(b).is_some() {
                assert!(
                    fixed_at(f, &dom, &blocks, loc.ptr, b),
                    "{what}: the walk went up through a join where the pointer is not fixed"
                );
            }
            for p in ps {
                if entered.insert(p) {
                    work.push((p, f.blocks[p.index()].insts.len()));
                }
            }
        }
        checked += 1;
    }
    checked
}

#[test]
fn demo_is_sound_and_prints_as_expected() {
    let src = std::fs::read_to_string(examples().join("demo.ll")).unwrap();
    let mut n = 0;
    each_function(&src, |name, aa, f| n += check_function(name, aa, f));
    assert!(n > 20, "only {n} accesses checked");
    // The printed form.
    let mut m = epitome_ir::parse_module(&src).unwrap();
    let reports = epitome_opt::memssa::analyse_module(&mut m, 1, true);
    let by: std::collections::HashMap<_, _> = reports.into_iter().collect();
    let text =
        epitome_ir::printer::print_module_with(&m, &|g, at| by.get(&g).and_then(|r| r.notes.get(&at).cloned()));
    let expected_path = examples().join("demo.expected.ll");
    if std::env::var("BLESS").is_ok() {
        std::fs::write(&expected_path, &text).unwrap();
    }
    let expected = std::fs::read_to_string(&expected_path).unwrap();
    assert!(text == expected, "the printed analysis differs from demo.expected.ll (BLESS=1 to update):\n{text}");
}

/// A random function: `blocks` blocks of loads and stores through a few
/// pointers (arguments that may alias, a noalias argument, allocas, a
/// global, elements at fixed and variable indices), joined by branches
/// forward and back.
fn random_function(seed: u64, blocks: usize) -> String {
    let mut s = seed.wrapping_mul(0x9e3779b97f4a7c15) | 1;
    let mut rnd = |n: usize| {
        s ^= s << 13;
        s ^= s >> 7;
        s ^= s << 17;
        (s % n as u64) as usize
    };
    let mut out = String::new();
    let _ = writeln!(out, "define void @r{seed}(ptr %p, ptr %q, ptr noalias %n, i64 %i, i1 %c) {{");
    let _ = writeln!(out, "b0:\n  %a = alloca [8 x i32]\n  %b = alloca i32");
    let _ = writeln!(out, "  %ai = getelementptr inbounds [8 x i32], ptr %a, i64 0, i64 %i");
    let _ = writeln!(out, "  %a3 = getelementptr inbounds [8 x i32], ptr %a, i64 0, i64 3");
    let _ = writeln!(out, "  %p1 = getelementptr inbounds i32, ptr %p, i64 1");
    let ptrs = ["%p", "%q", "%n", "%a", "%ai", "%a3", "%b", "%p1", "@g"];
    let mut v = 0;
    for b in 0..blocks {
        if b > 0 {
            let _ = writeln!(out, "b{b}:");
        }
        // A pointer that changes with each pass round a loop.
        let _ = writeln!(out, "  %e{b} = getelementptr inbounds i32, ptr %p, i64 {}", rnd(4));
        for _ in 0..rnd(5) {
            let ptr = if rnd(5) == 0 { format!("%e{b}") } else { ptrs[rnd(ptrs.len())].to_string() };
            if rnd(2) == 0 {
                let _ = writeln!(out, "  %v{v} = load i32, ptr {ptr}");
                v += 1;
            } else {
                let _ = writeln!(out, "  store i32 {}, ptr {ptr}", rnd(100));
            }
            if rnd(12) == 0 {
                let _ = writeln!(out, "  call void @opaque()");
            }
        }
        if b + 1 == blocks {
            let _ = writeln!(out, "  ret void");
        } else {
            let fwd = b + 1 + rnd(blocks - b - 1);
            let other = if rnd(3) == 0 { rnd(b + 1) } else { b + 1 };
            let _ = writeln!(out, "  br i1 %c, label %b{fwd}, label %b{other}");
        }
    }
    out.push_str("}\n");
    out
}

#[test]
fn random_control_flow_is_sound() {
    let mut src = String::from("@g = global i32 0\ndeclare void @opaque()\n");
    for seed in 0..300 {
        src.push_str(&random_function(seed, 2 + (seed as usize % 12)));
    }
    let mut n = 0;
    each_function(&src, |name, aa, f| n += check_function(name, aa, f));
    assert!(n > 2000, "only {n} accesses checked");
}

#[test]
fn c_programs_are_sound() {
    if !Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success()) {
        eprintln!("needs clang; skipping");
        return;
    }
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("memssa");
    std::fs::create_dir_all(&tmp).unwrap();
    let mut sources: Vec<PathBuf> = Vec::new();
    for dir in [root.join("tests/programs"), root.join("../codegen/tests/programs")] {
        for e in std::fs::read_dir(dir).unwrap() {
            let p = e.unwrap().path();
            if p.extension().is_some_and(|x| x == "c") {
                sources.push(p);
            }
        }
    }
    sources.sort();
    let mut n = 0;
    for src in &sources {
        for opt in ["-O0", "-O2"] {
            let ll = tmp.join(format!("{}{opt}.ll", src.file_stem().unwrap().to_string_lossy()));
            let ok = Command::new("clang")
                .args(["-S", "-emit-llvm", opt, "-Xclang", "-disable-O0-optnone", "-o"])
                .arg(&ll)
                .arg(src)
                .status()
                .is_ok_and(|s| s.success());
            if !ok {
                continue;
            }
            let text = std::fs::read_to_string(&ll).unwrap();
            each_function(&text, |name, aa, f| n += check_function(name, aa, f));
        }
    }
    assert!(n > 1000, "only {n} accesses checked");
}

/// The walker's costs for a module: time, and alias queries per question.
fn cost(src: &str) -> (std::time::Duration, u64, u64) {
    let mut m = epitome_ir::parse_module(src).unwrap();
    let t = std::time::Instant::now();
    let reports = epitome_opt::memssa::analyse_module(&mut m, 1, false);
    let elapsed = t.elapsed();
    let steps: u64 = reports.iter().map(|(_, r)| r.walks.steps).sum();
    let queries: u64 = reports.iter().map(|(_, r)| r.walks.queries).sum();
    (elapsed, steps, queries)
}

/// A big block: loads and stores through pointers that may alias, so every
/// question walks up past many writes.
fn big_block(n: usize) -> String {
    let mut s = String::from("define i32 @big(ptr %p, ptr %q) {\nentry:\n");
    for k in 0..n {
        let base = if k % 2 == 0 { "%p" } else { "%q" };
        let _ = writeln!(s, "  %g{k} = getelementptr inbounds i32, ptr {base}, i64 {}", k % 64);
        if k % 3 == 0 {
            let _ = writeln!(s, "  store i32 {k}, ptr %g{k}");
        } else {
            let _ = writeln!(s, "  %l{k} = load i32, ptr %g{k}");
        }
    }
    s.push_str("  ret i32 0\n}\n");
    s
}

/// A chain of `n` diamonds, each arm storing: every join is a phi, and a
/// load at the end must look through all of them.
fn diamonds(n: usize) -> String {
    let mut s = String::from(
        "define i32 @chain(i1 %c, ptr %p, ptr noalias %n) {\nentry:\n  store i32 0, ptr %n\n  br label %d0\n",
    );
    for k in 0..n {
        let _ = writeln!(s, "d{k}:\n  br i1 %c, label %l{k}, label %r{k}");
        let _ = writeln!(s, "l{k}:\n  store i32 1, ptr %p\n  br label %j{k}");
        let _ = writeln!(s, "r{k}:\n  store i32 2, ptr %p\n  br label %j{k}");
        let _ = writeln!(s, "j{k}:\n  %x{k} = load i32, ptr %n\n  br label %d{}", k + 1);
    }
    let _ = writeln!(s, "d{n}:\n  %v = load i32, ptr %n\n  ret i32 %v\n}}");
    s
}

/// Loops nested `n` deep, each writing its own memory, with loads of
/// something else inside the innermost.
fn nested_loops(n: usize) -> String {
    let mut s = String::from(
        "@g = global i32 0\ndefine i32 @nest(i64 %t, ptr %p) {\nentry:\n  store i32 1, ptr @g\n  br label %h0\n",
    );
    for k in 0..n {
        let prev = if k == 0 { "entry".to_string() } else { format!("h{}", k - 1) };
        let _ = writeln!(s, "h{k}:\n  %i{k} = phi i64 [ 0, %{prev} ], [ %i{k}n, %x{k} ]");
        let _ = writeln!(s, "  %e{k} = getelementptr inbounds i32, ptr %p, i64 %i{k}\n  store i32 {k}, ptr %e{k}");
        let next = if k + 1 == n { "body".to_string() } else { format!("h{}", k + 1) };
        let _ = writeln!(s, "  br label %{next}");
    }
    let _ = writeln!(s, "body:\n  %v = load i32, ptr @g\n  br label %x{}", n - 1);
    for k in (0..n).rev() {
        let _ = writeln!(s, "x{k}:\n  %i{k}n = add i64 %i{k}, 1\n  %c{k} = icmp ult i64 %i{k}n, %t");
        let out = if k == 0 { "done".to_string() } else { format!("x{}", k - 1) };
        let _ = writeln!(s, "  br i1 %c{k}, label %h{k}, label %{out}");
    }
    s.push_str("done:\n  %r = load i32, ptr @g\n  ret i32 %r\n}\n");
    s
}

#[test]
fn costs_grow_with_size_only() {
    for (name, make) in [
        ("a big block", big_block as fn(usize) -> String),
        ("a chain of diamonds", diamonds),
        ("nested loops", nested_loops),
    ] {
        let (small, large) = match name {
            "nested loops" => (50, 200),
            "a chain of diamonds" => (500, 2000),
            _ => (4000, 16000),
        };
        let best = |n: usize| {
            let src = make(n);
            let mut runs: Vec<(std::time::Duration, u64, u64)> = (0..3).map(|_| cost(&src)).collect();
            runs.sort();
            runs[0]
        };
        let (ta, sa, qa) = best(small);
        let (tb, sb, qb) = best(large);
        for (steps, queries) in [(sa, qa), (sb, qb)] {
            assert!(steps <= queries * Walker::BUDGET as u64, "{name}: {steps} alias queries for {queries} questions");
        }
        if tb > std::time::Duration::from_millis(5) {
            let ratio = tb.as_secs_f64() / ta.as_secs_f64().max(1e-6);
            assert!(ratio < 10.0, "{name}: 4x the size took {ratio:.1}x as long ({tb:?} and {ta:?})");
        }
    }
}
