//! Builds SQLite with smaugian-llc and checks it answers SQL as clang's
//! build does.
//!
//! SQLite is not in this repository: set `SMAUGIAN_SQLITE` to a directory
//! holding the amalgamation (`sqlite3.c`, `shell.c`, `sqlite3.h`), from
//! <https://sqlite.org/download.html>. Without it the test does nothing.
//!
//! Four builds of `sqlite3.c`, each linked with `shell.c` built by clang:
//!
//! 1. clang alone, `-O2`: the reference;
//! 2. clang `-O2` IR (without vectorising), compiled by smaugian-llc;
//! 3. clang `-O2` IR as it is, vectorised, compiled by smaugian-llc;
//! 4. clang `-O0` IR, through smaugian-opt, compiled by smaugian-llc.
//!
//! Each runs the scripts in `tests/sqlite/`, and must print what the
//! reference prints.

use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use smaugian_codegen::target::Target;
use smaugian_codegen::{Options, compile};

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!("{cmd:?} failed:\n{}", String::from_utf8_lossy(&out.stderr)));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

fn run_sql(exe: &Path, script: &Path) -> Result<String, String> {
    let input = std::fs::File::open(script).map_err(|e| e.to_string())?;
    let out = Command::new(exe).stdin(Stdio::from(input)).output().map_err(|e| e.to_string())?;
    Ok(format!("{}{}", String::from_utf8_lossy(&out.stdout), String::from_utf8_lossy(&out.stderr)))
}

/// Our assembly for `ll`, after smaugian-opt if `optimise`.
fn ours(t: &Target, ll: &Path, optimise: bool) -> Result<String, String> {
    let text = std::fs::read_to_string(ll).map_err(|e| e.to_string())?;
    let mut m = smaugian_ir::parse_module(&text).map_err(|e| format!("{e:?}"))?;
    if optimise {
        smaugian_opt::pipeline::run(&mut m, &smaugian_opt::pipeline::Options::default());
        m = smaugian_ir::parse_module(&m.to_string()).map_err(|e| format!("{e:?}"))?;
    }
    Ok(compile(t, &mut m, &Options::default())?.asm)
}

#[test]
fn sqlite_answers_as_clangs_build() {
    let Ok(src) = std::env::var("SMAUGIAN_SQLITE") else {
        eprintln!("SMAUGIAN_SQLITE is not set; skipping");
        return;
    };
    let src = PathBuf::from(src);
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("sqlite");
    std::fs::create_dir_all(&tmp).unwrap();
    let scripts = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/sqlite");
    let t = Target::aarch64();
    let c = src.join("sqlite3.c");
    let shell = tmp.join("shell.o");
    run(Command::new("clang").args(["-O2", "-c"]).arg("-I").arg(&src).arg(src.join("shell.c")).arg("-o").arg(&shell))
        .unwrap();

    let reference = tmp.join("sqlite3-ref");
    run(Command::new("clang").args(["-O2"]).arg(&c).arg(&shell).arg("-o").arg(&reference)).unwrap();

    let o2 = tmp.join("sqlite3.O2.ll");
    run(Command::new("clang")
        .args(["-O2", "-fno-vectorize", "-fno-slp-vectorize", "-S", "-emit-llvm"])
        .arg(&c)
        .arg("-o")
        .arg(&o2))
    .unwrap();
    let vec = tmp.join("sqlite3.vec.ll");
    run(Command::new("clang").args(["-O2", "-S", "-emit-llvm"]).arg(&c).arg("-o").arg(&vec)).unwrap();
    let o0 = tmp.join("sqlite3.O0.ll");
    run(Command::new("clang")
        .args(["-O0", "-Xclang", "-disable-O0-optnone", "-S", "-emit-llvm"])
        .arg(&c)
        .arg("-o")
        .arg(&o0))
    .unwrap();

    let mut failures = Vec::new();
    for (name, ll, optimise) in [("llc", &o2, false), ("llc-vec", &vec, false), ("opt+llc", &o0, true)] {
        let asm = ours(&t, ll, optimise).unwrap();
        let s = tmp.join(format!("sqlite3.{name}.s"));
        std::fs::write(&s, asm).unwrap();
        let exe = tmp.join(format!("sqlite3.{name}"));
        run(Command::new("clang").arg(&s).arg(&shell).arg("-o").arg(&exe)).unwrap();
        for script in ["workload.sql", "heavy.sql"] {
            let want = run_sql(&reference, &scripts.join(script)).unwrap();
            let got = run_sql(&exe, &scripts.join(script)).unwrap();
            if got == want {
                println!("ok {name} {script}");
            } else {
                failures.push(format!("{name}: {script} differs"));
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
