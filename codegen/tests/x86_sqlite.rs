//! Builds SQLite for x86-64 with epitome-llc and checks it answers SQL as
//! clang's build does, on an x86-64 Linux machine with clang (elsewhere the
//! test is skipped).
//!
//! As `tests/sqlite.rs`, SQLite is not in this repository: set
//! `EPITOME_SQLITE` to a directory holding the amalgamation (`sqlite3.c`,
//! `shell.c`, `sqlite3.h`). Without it the test does nothing.
//!
//! Three builds of `sqlite3.c`, each linked with `shell.c` built by clang:
//! clang `-O2` IR without vectorising, the same vectorised, and clang `-O0`
//! IR through epitome-opt; each compiled by epitome-llc and assembled by
//! epitome-as. Each must answer `tests/sqlite/*.sql` as clang's own `-O2`
//! build does; the vectorised build's code and relocations must be clang's
//! assembler's of our assembly; and epitome-objdump must read its object
//! back as our assembly.

use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use epitome_codegen::abi::Syntax;
use epitome_codegen::assembler::Assembler;
use epitome_codegen::objdump::{self, Image};
use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

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

/// The `.text` of an object, and its relocations.
type Text = (Vec<u8>, Vec<(u64, String, String, i64)>);

fn text_of(t: &Target, bytes: &[u8]) -> Result<Text, String> {
    let img = Image::read(bytes, &t.machine)?;
    let s = img.sections.iter().find(|s| s.name == ".text").ok_or("no .text")?;
    let mut relocs: Vec<_> =
        s.relocs.iter().map(|r| (r.offset, r.type_name.clone(), r.target.clone(), r.addend)).collect();
    relocs.sort();
    Ok((s.data.clone(), relocs))
}

#[test]
fn x86_sqlite_answers_as_clangs_build() {
    if !(cfg!(target_arch = "x86_64") && cfg!(target_os = "linux")) {
        eprintln!("not an x86-64 Linux machine: skipped");
        return;
    }
    let Ok(src) = std::env::var("EPITOME_SQLITE") else {
        eprintln!("EPITOME_SQLITE is not set; skipping");
        return;
    };
    let src = PathBuf::from(src);
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("x86_sqlite");
    std::fs::create_dir_all(&tmp).unwrap();
    let scripts = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/sqlite");
    let t = Target::x86_64();
    let c = src.join("sqlite3.c");
    let shell = tmp.join("shell.o");
    run(Command::new("clang").args(["-O2", "-c"]).arg("-I").arg(&src).arg(src.join("shell.c")).arg("-o").arg(&shell))
        .unwrap();
    let reference = tmp.join("sqlite3-ref");
    run(Command::new("clang").args(["-O2"]).arg(&c).arg(&shell).args(["-lm", "-o"]).arg(&reference)).unwrap();

    let mut failures = Vec::new();
    let builds: [(&str, &[&str], bool); 3] = [
        ("O2", &["-O2", "-fno-vectorize", "-fno-slp-vectorize"], false),
        ("vec", &["-O2"], false),
        ("opt", &["-O0", "-Xclang", "-disable-O0-optnone"], true),
    ];
    for (name, flags, optimise) in builds {
        let ll = tmp.join(format!("sqlite3.{name}.ll"));
        run(Command::new("clang").args(flags).args(["-S", "-emit-llvm"]).arg(&c).arg("-o").arg(&ll)).unwrap();
        let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
        if optimise {
            epitome_opt::pipeline::run(&mut m, &epitome_opt::pipeline::Options::default());
            m = epitome_ir::parse_module(&m.to_string()).unwrap();
        }
        let compiled = match compile(&t, &mut m, &Options::default()) {
            Ok(c) => c,
            Err(e) => {
                failures.push(format!("{name}: {e}"));
                continue;
            }
        };
        let s = tmp.join(format!("sqlite3.{name}.s"));
        std::fs::write(&s, &compiled.asm).unwrap();
        let ours = Assembler::new(&t).assemble(&compiled.asm, Some(Syntax::Elf)).and_then(|a| a.file(&t)).unwrap();
        let o = tmp.join(format!("sqlite3.{name}.o"));
        std::fs::write(&o, &ours).unwrap();
        let exe = tmp.join(format!("sqlite3.{name}"));
        run(Command::new("clang").arg(&o).arg(&shell).args(["-lm", "-o"]).arg(&exe)).unwrap();
        for script in ["workload.sql", "heavy.sql"] {
            let want = run_sql(&reference, &scripts.join(script)).unwrap();
            let got = run_sql(&exe, &scripts.join(script)).unwrap();
            if got != want {
                failures.push(format!("{name}: {script} differs"));
            }
        }
        if name == "vec" {
            let theirs = tmp.join(format!("sqlite3.{name}.clang.o"));
            run(Command::new("clang").args(["--target=x86_64-linux-gnu", "-c"]).arg(&s).arg("-o").arg(&theirs))
                .unwrap();
            if text_of(&t, &ours).unwrap() != text_of(&t, &std::fs::read(&theirs).unwrap()).unwrap() {
                failures.push(format!("{name}: the code or relocations differ from clang's assembler's"));
            }
            let img = Image::read(&ours, &t.machine).unwrap();
            if let Err(e) = objdump::reads_back(&t, &img, &compiled.asm, &[]) {
                failures.push(format!("{name}: {e}"));
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
