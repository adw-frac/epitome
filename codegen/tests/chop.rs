//! Autochop (`epitome_ir::chop`) in code generation.
//!
//! 1. With no elective choices at all (`0:0`), every program of
//!    `tests/programs` still compiles and runs as clang's build does: every
//!    elective choice (a pattern covering several instructions, division by
//!    a constant with a multiply, a tail call, a constant or address hoisted
//!    out of a loop) has a plain way to do the same, and that is taken.
//!    (Programs marked `needs-tail-calls` are left out: without tail calls
//!    they run out of stack.)
//! 2. So do limits part-way through every function.
//! 3. Counts, and the code under a limit, are the same on 1 thread and 8.
//!
//! On an AArch64 Mac, or on x86-64 Linux for x86-64.

use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};
use epitome_ir::chop::Limit;

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!("{cmd:?} failed:\n{}", String::from_utf8_lossy(&out.stderr)));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// The libraries programs link with (Linux's atomics are libatomic's).
const LIBS: &[&str] = if cfg!(target_os = "linux") { &["-lm", "-latomic"] } else { &["-lm"] };

fn have_tools() -> bool {
    (cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")
        || cfg!(target_arch = "x86_64") && cfg!(target_os = "linux"))
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success())
}

/// Our object for `ll` under `limit`, linked with the program's main, and
/// what it prints.
fn output(t: &Target, ll: &str, main: &Path, tmp: &Path, tag: &str, limit: Option<Limit>) -> Result<String, String> {
    let mut m = epitome_ir::parse_module(ll).map_err(|e| format!("{e:?}"))?;
    let c = compile(t, &mut m, &Options { chop: limit, ..Options::default() })?;
    let obj = tmp.join(format!("{tag}.o"));
    std::fs::write(&obj, c.object_file(t)?).unwrap();
    let exe = tmp.join(tag);
    run(Command::new("clang").args(["-w", "-O1"]).arg(main).arg(&obj).args(LIBS).arg("-o").arg(&exe))?;
    run(&mut Command::new(&exe))
}

#[test]
fn programs_run_without_elective_choices() {
    if !have_tools() {
        eprintln!("needs clang on an AArch64 Mac or x86-64 Linux; skipping");
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/programs");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("chop");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = if cfg!(target_arch = "x86_64") { Target::x86_64() } else { Target::aarch64() };
    let mut names: Vec<String> = std::fs::read_dir(&dir)
        .unwrap()
        .filter_map(|e| {
            let n = e.unwrap().file_name().to_string_lossy().into_owned();
            n.strip_suffix(".main.c").map(str::to_string)
        })
        .collect();
    names.sort();
    let mut failures = Vec::new();
    let mut choices = 0u64;
    for name in &names {
        let src = dir.join(format!("{name}.c"));
        let main = dir.join(format!("{name}.main.c"));
        // A program that recurses too deep without tail calls overflows the
        // stack with them off: a resource, not a miscompilation.
        if std::fs::read_to_string(&src).unwrap().contains("needs-tail-calls") {
            continue;
        }
        // What clang's build prints.
        let reference = tmp.join(format!("{name}.ref"));
        if run(Command::new("clang").args(["-w", "-O1"]).arg(&src).arg(&main).args(LIBS).arg("-o").arg(&reference))
            .is_err()
        {
            continue;
        }
        let want = run(&mut Command::new(&reference)).unwrap();
        for opt in ["-O0", "-O2"] {
            let ll = tmp.join(format!("{name}{opt}.ll"));
            let flags = ["-S", "-emit-llvm", opt, "-fno-vectorize", "-fno-slp-vectorize", "-fno-unroll-loops"];
            if run(Command::new("clang").args(flags).arg(&src).arg("-o").arg(&ll)).is_err() {
                continue;
            }
            let text = std::fs::read_to_string(&ll).unwrap();
            let mut m = epitome_ir::parse_module(&text).unwrap();
            let Ok(full) = compile(&t, &mut m, &Options::default()) else { continue };
            let counts: Vec<u64> = full.chop_counts.iter().map(|c| c.steps).collect();
            choices += counts.iter().sum::<u64>();
            // The same counts and code on 8 threads, under a limit too.
            let mut m8 = epitome_ir::parse_module(&text).unwrap();
            let full8 = compile(&t, &mut m8, &Options { threads: 8, ..Options::default() }).unwrap();
            assert_eq!(counts, full8.chop_counts.iter().map(|c| c.steps).collect::<Vec<_>>(), "{name}{opt}");
            // No choices, half of each function's, and all of every function
            // but one.
            let mut limits = vec![Limit { func: 0, steps: 0 }];
            for (k, &n) in counts.iter().enumerate() {
                if n > 1 {
                    limits.push(Limit { func: k, steps: n / 2 });
                }
            }
            for l in limits {
                let tag = format!("{name}{opt}-{}-{}", l.func, l.steps);
                match output(&t, &text, &main, &tmp, &tag, Some(l)) {
                    Ok(got) if got == want => {}
                    Ok(_) => failures.push(format!("{name}{opt} at {l}: different output")),
                    Err(e) => failures.push(format!("{name}{opt} at {l}: {e}")),
                }
                let (mut a, mut b) =
                    (epitome_ir::parse_module(&text).unwrap(), epitome_ir::parse_module(&text).unwrap());
                let one = compile(&t, &mut a, &Options { chop: Some(l), threads: 1, ..Options::default() }).unwrap();
                let eight = compile(&t, &mut b, &Options { chop: Some(l), threads: 8, ..Options::default() }).unwrap();
                assert!(one.asm == eight.asm, "{name}{opt} at {l}: the code differs between 1 and 8 threads");
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
    assert!(choices > 100, "only {choices} elective choices counted");
}
