//! C++ exceptions and x86-64 code of ours, on an x86-64 Linux machine with
//! clang++ (elsewhere the test is skipped), as `tests/unwind.rs` checks on
//! an AArch64 Mac:
//!
//! 1. an exception thrown from a callback that functions of ours call
//!    (`tests/unwind/through.c`) unwinds through them, by our `.eh_frame`,
//!    to `main`'s `catch`;
//! 2. functions of ours with landing pads (`tests/unwind/catch.cpp`) catch,
//!    clean up and rethrow as clang's build of them does, by our exception
//!    tables; the object assembled from our assembly is the one we write.

use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_codegen::abi::Syntax;
use epitome_codegen::assembler::Assembler;
use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!("{cmd:?} failed:\n{}", String::from_utf8_lossy(&out.stderr)));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

fn ready() -> bool {
    let ok = cfg!(target_arch = "x86_64")
        && cfg!(target_os = "linux")
        && Command::new("clang++").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang++ on an x86-64 Linux machine; skipping");
    }
    ok
}

/// Our object for `src` (C or C++) at `opt`, checked against the one
/// epitome-as makes of our assembly.
fn ours(t: &Target, src: &Path, tmp: &Path, cc: &str, opt: &str) -> PathBuf {
    let stem = src.file_stem().unwrap().to_string_lossy().into_owned();
    let ll = tmp.join(format!("{stem}{opt}.ll"));
    run(Command::new(cc).args(["-S", "-emit-llvm", opt]).arg(src).arg("-o").arg(&ll)).unwrap();
    let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
    let compiled = compile(t, &mut m, &Options::default()).unwrap();
    let bytes = compiled.object_file(t).unwrap();
    let assembled = Assembler::new(t).assemble(&compiled.asm, Some(Syntax::Elf)).and_then(|a| a.file(t)).unwrap();
    assert!(bytes == assembled, "{stem}{opt}: the object assembled from our assembly differs");
    let o = tmp.join(format!("{stem}{opt}.o"));
    std::fs::write(&o, bytes).unwrap();
    o
}

#[test]
fn x86_exceptions_unwind_through_our_frames() {
    if !ready() {
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/unwind");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("x86_unwind");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = Target::x86_64();
    for opt in ["-O0", "-O2"] {
        let o = ours(&t, &dir.join("through.c"), &tmp, "clang", opt);
        let exe = tmp.join(format!("through{opt}"));
        run(Command::new("clang++").args(["-std=c++17"]).arg(dir.join("main.cpp")).arg(&o).arg("-o").arg(&exe))
            .unwrap();
        assert_eq!(run(&mut Command::new(&exe)).unwrap(), "-50\ncaught boom 7\ncaught boom 8\n", "{opt}");
    }
}

#[test]
fn x86_landing_pads_catch_and_clean_up() {
    if !ready() {
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/unwind");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("x86_landing");
    std::fs::create_dir_all(&tmp).unwrap();
    let reference = tmp.join("reference");
    run(Command::new("clang++")
        .args(["-std=c++17"])
        .arg(dir.join("main_catch.cpp"))
        .arg(dir.join("catch.cpp"))
        .arg("-o")
        .arg(&reference))
    .unwrap();
    let want = run(&mut Command::new(&reference)).unwrap();
    let t = Target::x86_64();
    for opt in ["-O0", "-O2"] {
        let o = ours(&t, &dir.join("catch.cpp"), &tmp, "clang++", opt);
        let exe = tmp.join(format!("catch{opt}"));
        run(Command::new("clang++").args(["-std=c++17"]).arg(dir.join("main_catch.cpp")).arg(&o).arg("-o").arg(&exe))
            .unwrap();
        assert_eq!(run(&mut Command::new(&exe)).unwrap(), want, "{opt}");
    }
}
