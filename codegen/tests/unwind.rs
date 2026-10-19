//! Unwind tables (`src/unwind.rs`).
//!
//! 1. A C++ exception, thrown from a callback that functions of ours call
//!    (recursing, saving registers, one with a variable-length array),
//!    unwinds through them to `main`'s `catch`, on this machine: without
//!    our `__eh_frame` the C++ runtime calls `terminate`.
//! 2. Functions of ours with landing pads (`tests/unwind/catch.cpp`):
//!    exceptions caught by type and all, destructors run, rethrown, and
//!    caught by an inner or an outer `try`, by their exception tables;
//!    the object written directly and the one assembled from our assembly
//!    are the same. (Rust's panics: `tests/rust.rs`.)
//! 3. On RISC-V, our object's `.eh_frame` and `.text` are what LLVM's
//!    assembler (rustc's) makes of our assembly, byte for byte, for C
//!    programs of `tests/programs`. (AArch64's ELF tables are checked so
//!    against clang by `tests/programs.rs`.)

use std::path::{Path, PathBuf};
use std::process::Command;

use draconian_codegen::assembler::Assembler;
use draconian_codegen::elf;
use draconian_codegen::target::Target;
use draconian_codegen::{Options, compile};

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

fn have(cmd: &str) -> bool {
    Command::new(cmd).arg("--version").output().is_ok_and(|o| o.status.success())
}

#[test]
fn exceptions_unwind_through_our_frames() {
    if !(have("clang++") && cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) {
        eprintln!("needs clang++ on an AArch64 Mac; skipping");
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/unwind");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("unwind");
    std::fs::create_dir_all(&tmp).unwrap();
    for opt in ["-O0", "-O2"] {
        let ll = tmp.join(format!("through{opt}.ll"));
        run(Command::new("clang").args(["-S", "-emit-llvm", opt]).arg(dir.join("through.c")).arg("-o").arg(&ll))
            .unwrap();
        let mut m = draconian_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
        let t = Target::aarch64();
        let compiled = compile(&t, &mut m, &Options::default()).unwrap();
        let o = tmp.join(format!("through{opt}.o"));
        std::fs::write(&o, compiled.object_file(&t).unwrap()).unwrap();
        let exe = tmp.join(format!("main{opt}"));
        run(Command::new("clang++").args(["-std=c++17"]).arg(dir.join("main.cpp")).arg(&o).arg("-o").arg(&exe))
            .unwrap();
        let out = run(&mut Command::new(&exe)).unwrap();
        assert_eq!(out, "-50\ncaught boom 7\ncaught boom 8\n", "{opt}");
    }
}

#[test]
fn landing_pads_catch_and_clean_up() {
    if !(have("clang++") && cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) {
        eprintln!("needs clang++ on an AArch64 Mac; skipping");
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/unwind");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("landing");
    std::fs::create_dir_all(&tmp).unwrap();
    // What clang makes of it all.
    let reference = tmp.join("reference");
    run(Command::new("clang++")
        .args(["-std=c++17"])
        .arg(dir.join("main_catch.cpp"))
        .arg(dir.join("catch.cpp"))
        .arg("-o")
        .arg(&reference))
    .unwrap();
    let want = run(&mut Command::new(&reference)).unwrap();
    let t = Target::aarch64();
    for opt in ["-O0", "-O2"] {
        let ll = tmp.join(format!("catch{opt}.ll"));
        run(Command::new("clang++").args(["-S", "-emit-llvm", opt]).arg(dir.join("catch.cpp")).arg("-o").arg(&ll))
            .unwrap();
        let mut m = draconian_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
        let compiled = compile(&t, &mut m, &Options::default()).unwrap();
        let bytes = compiled.object_file(&t).unwrap();
        let assembled = Assembler::new(&t).assemble(&compiled.asm, None).and_then(|a| a.file(&t)).unwrap();
        assert!(bytes == assembled, "{opt}: the object assembled from our assembly differs");
        let o = tmp.join(format!("catch{opt}.o"));
        std::fs::write(&o, bytes).unwrap();
        let exe = tmp.join(format!("catch{opt}"));
        run(Command::new("clang++").args(["-std=c++17"]).arg(dir.join("main_catch.cpp")).arg(&o).arg("-o").arg(&exe))
            .unwrap();
        assert_eq!(run(&mut Command::new(&exe)).unwrap(), want, "{opt}");
    }
}

/// The contents of an ELF object's section.
fn section(bytes: &[u8], name: &str) -> Vec<u8> {
    let f = elf::read(bytes).unwrap();
    f.sections.iter().find(|s| s.name == name).map(|s| s.data.clone()).unwrap_or_default()
}

fn riscv_object(t: &Target, src: &Path, tmp: &Path) -> Result<(), String> {
    let stem = src.file_stem().unwrap().to_string_lossy().into_owned();
    let ll = tmp.join(format!("{stem}.ll"));
    let include = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/riscv/include");
    run(Command::new("clang")
        .args(["--target=aarch64-linux-gnu", "-fno-math-errno", "-O2", "-S", "-emit-llvm", "-I"])
        .arg(&include)
        .arg(src)
        .arg("-o")
        .arg(&ll))?;
    let mut m = draconian_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).map_err(|e| format!("{e:?}"))?;
    let compiled = compile(t, &mut m, &Options::default())?;
    let ours = compiled.object_file(t)?;
    // LLVM's, of our assembly: as a crate's global assembly, not
    // compressed, not relaxed.
    std::fs::write(tmp.join(format!("{stem}.s")), format!(".option norvc\n.option norelax\n{}", compiled.asm)).unwrap();
    std::fs::write(
        tmp.join(format!("{stem}.rs")),
        format!("#![no_std]\ncore::arch::global_asm!(include_str!(\"{stem}.s\"), options(raw));\n"),
    )
    .unwrap();
    let o = tmp.join(format!("{stem}.llvm.o"));
    run(Command::new("rustc")
        .args(["--target", "riscv64gc-unknown-none-elf", "--crate-type", "lib", "--emit", "obj", "-C"])
        .arg("target-feature=+m,+a,+zbb")
        .arg("-o")
        .arg(&o)
        .arg(tmp.join(format!("{stem}.rs"))))?;
    let theirs = std::fs::read(&o).unwrap();
    for name in [".text", ".eh_frame"] {
        let (a, b) = (section(&ours, name), section(&theirs, name));
        if a != b {
            let at = a.iter().zip(&b).position(|(x, y)| x != y).unwrap_or(a.len().min(b.len()));
            return Err(format!(
                "{stem}: {name} differs from LLVM's at byte {at:#x} ({} and {} bytes)",
                a.len(),
                b.len()
            ));
        }
    }
    Ok(())
}

#[test]
fn riscv_tables_are_llvms() {
    let ok = have("clang")
        && Command::new("rustc").args(["--print", "sysroot"]).output().is_ok_and(|o| {
            let root = String::from_utf8_lossy(&o.stdout).trim().to_string();
            Path::new(&root).join("lib/rustlib/riscv64gc-unknown-none-elf").exists()
        });
    if !ok {
        eprintln!("needs clang and rustc's riscv64gc-unknown-none-elf target; skipping");
        return;
    }
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let t = Target::load_path(root.join("targets/riscv64").to_str().unwrap()).unwrap();
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("unwind-riscv");
    std::fs::create_dir_all(&tmp).unwrap();
    let failures: Vec<String> = ["calls", "structs", "vla", "wide", "loops"]
        .iter()
        .filter_map(|n| riscv_object(&t, &root.join(format!("tests/programs/{n}.c")), &tmp).err())
        .collect();
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
