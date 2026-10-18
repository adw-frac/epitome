//! Runs the pipeline on real programs and checks they still behave the
//! same.
//!
//! Each C file in `tests/programs` is compiled to IR by clang in several
//! configurations. For each, the test:
//!
//! 1. builds and runs the original IR, recording its output;
//! 2. runs the pipeline with 1 thread and with 8, and checks the printed
//!    modules are identical;
//! 3. checks every function with `cfg::verify`;
//! 4. builds the result with clang, which runs LLVM's own verifier, runs
//!    it, and compares the output with step 1.
//!
//! The test is skipped when `clang` is not installed.

use std::path::{Path, PathBuf};
use std::process::Command;

use smaugian_opt::inline::OptLevel;
use smaugian_opt::pipeline::{self, Options};

/// Clang flags for each configuration. `noinline` is removed from the
/// output of the optimised ones, so our inliner has something to do.
const CONFIGS: &[(&str, &[&str])] = &[
    ("unopt", &["-O1", "-Xclang", "-disable-llvm-passes"]),
    ("O2", &["-O2", "-fno-inline-functions"]),
    ("O2-g", &["-O2", "-g", "-fno-inline-functions"]),
    ("unopt-g", &["-O1", "-g", "-Xclang", "-disable-llvm-passes"]),
];

fn have_clang() -> bool {
    Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success())
}

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!(
            "{cmd:?} failed:\n{}{}",
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

fn build_and_run(ll: &Path, exe: &Path) -> Result<String, String> {
    let out =
        Command::new("clang").args(["-x", "ir"]).arg(ll).arg("-o").arg(exe).output().map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&out.stderr);
    if !out.status.success() {
        return Err(format!("clang failed on {}:\n{stderr}", ll.display()));
    }
    // LLVM drops invalid debug info with only a warning.
    if stderr.contains("debug info") || stderr.contains("!dbg") {
        return Err(format!("clang rejected debug info in {}:\n{stderr}", ll.display()));
    }
    run(&mut Command::new(exe))
}

fn strip_noinline(ir: &str) -> String {
    ir.lines()
        .map(|l| if l.starts_with("attributes #") { l.replace(" noinline", "") } else { l.to_string() })
        .collect::<Vec<_>>()
        .join("\n")
        + "\n"
}

fn check(program: &Path, config: &str, flags: &[&str], level: OptLevel, tmp: &Path) -> Result<String, String> {
    let stem = format!("{}.{config}.{level:?}", program.file_stem().unwrap().to_string_lossy());
    let src_ll = tmp.join(format!("{stem}.ll"));
    run(Command::new("clang").args(["-S", "-emit-llvm", "-w"]).args(flags).arg(program).arg("-o").arg(&src_ll))?;
    let text = strip_noinline(&std::fs::read_to_string(&src_ll).unwrap());
    std::fs::write(&src_ll, &text).unwrap();
    let want = build_and_run(&src_ll, &tmp.join(format!("{stem}.orig")))?;

    let mut outputs = Vec::new();
    let mut summary = String::new();
    for threads in [1, 8] {
        let mut m = smaugian_ir::parse_module(&text).map_err(|e| format!("{stem}: parse: {e}"))?;
        let report = pipeline::run(&mut m, &Options { threads, level, ..Options::default() });
        for (g, f) in m.functions() {
            let errors = smaugian_opt::cfg::verify(f, m.global(g).name.as_deref().unwrap_or(""));
            if !errors.is_empty() {
                return Err(format!("{stem}: {}", errors.join("\n")));
            }
        }
        if threads == 1 {
            summary = format!(
                "{stem}: {} inlined, {} tail and {} other recursive calls removed, {} deleted",
                report.inlined,
                report.tail_calls,
                report.frame_calls,
                report.deleted.len()
            );
        }
        outputs.push(m.to_string());
    }
    if outputs[0] != outputs[1] {
        return Err(format!("{stem}: output differs between 1 and 8 threads"));
    }
    let out_ll = tmp.join(format!("{stem}.out.ll"));
    std::fs::write(&out_ll, &outputs[0]).unwrap();
    let got = build_and_run(&out_ll, &tmp.join(format!("{stem}.out")))?;
    if got != want {
        return Err(format!("{stem}: output changed\n--- want\n{want}--- got\n{got}"));
    }
    // The output must also read back in and print the same.
    let again = smaugian_ir::parse_module(&outputs[0]).map_err(|e| format!("{stem}: reparse: {e}"))?;
    if again.to_string() != outputs[0] {
        return Err(format!("{stem}: output does not round-trip"));
    }
    Ok(summary)
}

#[test]
fn programs_behave_the_same() {
    if !have_clang() {
        eprintln!("clang not found; skipping");
        return;
    }
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/programs");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("programs");
    std::fs::create_dir_all(&tmp).unwrap();
    let mut programs: Vec<PathBuf> = std::fs::read_dir(&dir)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "c"))
        .collect();
    programs.sort();
    let mut failures = Vec::new();
    for p in &programs {
        for (config, flags) in CONFIGS {
            let levels: &[OptLevel] =
                if *config == "O2" { &[OptLevel::O2, OptLevel::O3, OptLevel::Oz] } else { &[OptLevel::O2] };
            for &level in levels {
                match check(p, config, flags, level, &tmp) {
                    Ok(summary) => eprintln!("ok {summary}"),
                    Err(e) => failures.push(e),
                }
            }
        }
    }
    assert!(failures.is_empty(), "{} failures:\n{}", failures.len(), failures.join("\n\n"));
}
