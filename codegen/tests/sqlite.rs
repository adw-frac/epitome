//! Builds SQLite with draconian-llc and checks it answers SQL as clang's
//! build does.
//!
//! SQLite is not in this repository: set `DRACONIAN_SQLITE` to a directory
//! holding the amalgamation (`sqlite3.c`, `shell.c`, `sqlite3.h`), from
//! <https://sqlite.org/download.html>. Without it the test does nothing.
//!
//! Four builds of `sqlite3.c`, each linked with `shell.c` built by clang:
//!
//! 1. clang alone, `-O2`: the reference;
//! 2. clang `-O2` IR (without vectorising), compiled by draconian-llc;
//! 3. clang `-O2` IR as it is, vectorised, compiled by draconian-llc;
//! 4. clang `-O0` IR, through draconian-opt, compiled by draconian-llc.
//!
//! Builds 2 to 4 are made twice, from our assembly and from our own
//! Mach-O object file, which must also say what clang's assembler makes of
//! our assembly. Each runs the scripts in `tests/sqlite/`, and must print
//! what the reference prints.
//!
//! Builds 2 and 3 are also compiled to ELF (assembly and our own object
//! file, from the same IR; the convention is still Apple's, which does not
//! matter to the encoding), and our object must say what clang's assembler
//! makes of our assembly (see `ElfFile::canonical`), and must disassemble
//! back to that assembly with draconian-objdump's code. They are not run:
//! there is no Linux here.

use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use draconian_codegen::abi::Syntax;
use draconian_codegen::objdump::{self, Image};
use draconian_codegen::target::Target;
use draconian_codegen::{Options, compile, elf, macho};

/// Mnemonics objdump may print for an instruction we print another way.
const ALIASES: &[(&str, &str)] = &[
    ("add", "mov"),
    ("mov", "orr"),
    ("mov", "movz"),
    ("mov", "movn"),
    ("neg", "sub"),
    ("sshll", "sxtl"),
    ("ushll", "uxtl"),
    ("sshll2", "sxtl2"),
    ("ushll2", "uxtl2"),
    ("ror", "extr"),
];

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

/// Our assembly and object file for `ll`, after draconian-opt if
/// `optimise`.
fn ours(t: &Target, ll: &Path, optimise: bool) -> Result<(String, Vec<u8>), String> {
    let text = std::fs::read_to_string(ll).map_err(|e| e.to_string())?;
    let mut m = draconian_ir::parse_module(&text).map_err(|e| format!("{e:?}"))?;
    if optimise {
        draconian_opt::pipeline::run(&mut m, &draconian_opt::pipeline::Options::default());
        m = draconian_ir::parse_module(&m.to_string()).map_err(|e| format!("{e:?}"))?;
    }
    let compiled = compile(t, &mut m, &Options::default())?;
    let object = compiled.object_file(t)?;
    Ok((compiled.asm, object))
}

#[test]
fn sqlite_answers_as_clangs_build() {
    let Ok(src) = std::env::var("DRACONIAN_SQLITE") else {
        eprintln!("DRACONIAN_SQLITE is not set; skipping");
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
        let (asm, object) = ours(&t, ll, optimise).unwrap();
        let s = tmp.join(format!("sqlite3.{name}.s"));
        std::fs::write(&s, asm).unwrap();
        let o = tmp.join(format!("sqlite3.{name}.o"));
        std::fs::write(&o, &object).unwrap();
        // Our object says what the assembler's says.
        let theirs = tmp.join(format!("sqlite3.{name}.assembled.o"));
        run(Command::new("clang").arg("-c").arg(&s).arg("-o").arg(&theirs)).unwrap();
        let a = macho::read(&object).unwrap().canonical();
        let b = macho::read(&std::fs::read(&theirs).unwrap()).unwrap().canonical();
        if a == b {
            println!("ok {name} Mach-O object is the assembler's");
        } else {
            failures.push(format!(
                "{name}: our Mach-O object differs:\n{}",
                draconian_codegen::object::differences(&a, &b, 8).join("\n")
            ));
        }
        // Built from our assembly, and from our own object file.
        for (build, input) in [(name.to_string(), &s), (format!("{name}, object"), &o)] {
            let exe = tmp.join(format!("sqlite3.{name}.from-{}", if input == &s { "asm" } else { "object" }));
            run(Command::new("clang").arg(input).arg(&shell).arg("-o").arg(&exe)).unwrap();
            for script in ["workload.sql", "heavy.sql"] {
                let want = run_sql(&reference, &scripts.join(script)).unwrap();
                let got = run_sql(&exe, &scripts.join(script)).unwrap();
                if got == want {
                    println!("ok {build} {script}");
                } else {
                    failures.push(format!("{build}: {script} differs"));
                }
            }
        }
    }

    // ELF: our object against the assembler's, and read back.
    for (name, ll) in [("llc", &o2), ("llc-vec", &vec)] {
        let text = std::fs::read_to_string(ll).unwrap();
        let mut m = draconian_ir::parse_module(&text).unwrap();
        let opts = Options { syntax: Some(Syntax::Elf), ..Options::default() };
        let compiled = compile(&t, &mut m, &opts).unwrap();
        let s = tmp.join(format!("sqlite3.{name}.elf.s"));
        std::fs::write(&s, &compiled.asm).unwrap();
        let theirs = tmp.join(format!("sqlite3.{name}.elf.o"));
        run(Command::new("clang").args(["--target=aarch64-linux-gnu", "-c"]).arg(&s).arg("-o").arg(&theirs)).unwrap();
        let bytes = elf::write(&compiled.object(&t).unwrap());
        let mine = tmp.join(format!("sqlite3.{name}.elf.ours.o"));
        std::fs::write(&mine, &bytes).unwrap();
        let a = elf::read(&bytes).unwrap().canonical();
        let b = elf::read(&std::fs::read(&theirs).unwrap()).unwrap().canonical();
        if a != b {
            failures.push(format!(
                "{name}: our ELF object differs:\n{}",
                draconian_codegen::object::differences(&a, &b, 8).join("\n")
            ));
            continue;
        }
        match objdump::reads_back(&t, &Image::read(&bytes).unwrap(), &compiled.asm, ALIASES) {
            Ok(n) => println!("ok {name} ELF object, {n} instructions read back"),
            Err(e) => failures.push(format!("{name}: {e}")),
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
