//! Autochop (`draconian_ir::chop`) in the optimiser.
//!
//! 1. Counts are the same on 1 thread and on 8, and so is the output under
//!    any limit, so a limit means one thing.
//! 2. With a wrong combine rule planted, a search over limits, building and
//!    running the program at each, finds exactly that rule, in the function
//!    that uses it.
//! 3. A limit of `0:0` makes no elective change: the output is the input
//!    as the printer writes it.

use std::path::PathBuf;
use std::process::Command;

use draconian_ir::chop::{self, Found, Limit};
use draconian_opt::pipeline::{self, Options};

fn have_clang() -> bool {
    Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success())
}

fn dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/chop")
}

fn tmp() -> PathBuf {
    let t = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("chop");
    std::fs::create_dir_all(&t).unwrap();
    t
}

/// The test program's IR: clang's, before its own optimisation, so that
/// every pass has work (allocas, calls, loops).
fn program_ir() -> String {
    let ll = tmp().join("prog.ll");
    let ok = Command::new("clang")
        .args(["-S", "-emit-llvm", "-O1", "-Xclang", "-disable-llvm-passes", "-o"])
        .arg(&ll)
        .arg(dir().join("prog.c"))
        .status()
        .is_ok_and(|s| s.success());
    assert!(ok, "clang could not compile prog.c");
    std::fs::read_to_string(&ll).unwrap()
}

fn optimise(src: &str, threads: usize, chop: Option<Limit>, rules: Option<&str>) -> (String, pipeline::Report) {
    let mut m = draconian_ir::parse_module(src).unwrap();
    let opts = Options { threads, chop, extra_rules: rules.map(str::to_string), ..Options::default() };
    let report = pipeline::run(&mut m, &opts);
    (m.to_string(), report)
}

/// What the program prints, built from `ll` by clang.
fn run_ir(ll: &str, name: &str) -> Option<String> {
    let t = tmp();
    let (src, exe) = (t.join(format!("{name}.ll")), t.join(name));
    std::fs::write(&src, ll).unwrap();
    let built = Command::new("clang").arg("-w").arg(&src).arg("-o").arg(&exe).status().is_ok_and(|s| s.success());
    if !built {
        return None;
    }
    let out = Command::new(&exe).output().ok()?;
    Some(String::from_utf8_lossy(&out.stdout).into_owned())
}

#[test]
fn counts_and_limits_do_not_depend_on_threads() {
    if !have_clang() {
        eprintln!("needs clang; skipping");
        return;
    }
    let src = program_ir();
    let (out1, r1) = optimise(&src, 1, None, None);
    let (out8, r8) = optimise(&src, 8, None, None);
    let counts = |r: &pipeline::Report| r.chop_counts.iter().map(|c| c.steps).collect::<Vec<_>>();
    assert_eq!(counts(&r1), counts(&r8));
    assert_eq!(out1, out8);
    assert!(counts(&r1).iter().sum::<u64>() > 20, "too few steps counted: {:?}", counts(&r1));
    // Every limit at a function boundary, and some inside functions.
    for (k, &n) in counts(&r1).iter().enumerate() {
        for steps in [0, n / 2, n] {
            let l = Limit { func: k, steps };
            let (a, ra) = optimise(&src, 1, Some(l), None);
            let (b, rb) = optimise(&src, 8, Some(l), None);
            assert!(a == b, "limit {l}: the output differs between 1 and 8 threads");
            assert_eq!(ra.chop_stopped, rb.chop_stopped, "limit {l}");
        }
    }
}

#[test]
fn no_steps_is_no_change() {
    if !have_clang() {
        eprintln!("needs clang; skipping");
        return;
    }
    let src = program_ir();
    let printed = draconian_ir::parse_module(&src).unwrap().to_string();
    let (out, _) = optimise(&src, 4, Some(Limit { func: 0, steps: 0 }), None);
    assert!(out == printed, "a limit of 0:0 changed the module");
}

#[test]
fn search_finds_a_planted_wrong_rule() {
    if !have_clang() {
        eprintln!("needs clang; skipping");
        return;
    }
    let src = program_ir();
    // Wrong: x * 7 is not x << 3.
    let bad = "bad_mul7: mul(x, 7) -> shl(x, 3)\n";
    let want = run_ir(&draconian_ir::parse_module(&src).unwrap().to_string(), "want").expect("the program runs");
    let (_, full) = optimise(&src, 4, None, Some(bad));
    let steps: Vec<u64> = full.chop_counts.iter().map(|c| c.steps).collect();
    let mut runs = 0;
    let found = chop::search(&steps, |l| {
        runs += 1;
        let (out, _) = optimise(&src, 4, Some(l), Some(bad));
        run_ir(&out, "got").as_deref() == Some(want.as_str())
    });
    let Found::Step(l) = found else { panic!("the search found {found:?}") };
    let (_, at) = optimise(&src, 4, Some(l), Some(bad));
    let (k, _, last) = at.chop_stopped.clone().unwrap();
    let name = &at.chop_names[k];
    let what = last.unwrap_or_default();
    assert!(name == "seven" || what.contains("bad_mul7"), "found @{name}: {what}");
    assert!(what.contains("combine bad_mul7"), "the step found is {what:?}, in @{name}");
    let total: u64 = steps.iter().sum();
    let bound = 2 + (steps.len() as f64).log2().ceil() as usize + (steps[k] as f64).log2().ceil() as usize + 2;
    assert!(runs <= bound, "{runs} runs for {} functions and {total} steps", steps.len());
}
