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
//! 4. ELF exception tables (`tests/unwind/landing.cpp`, for Linux, which
//!    nothing here runs): on AArch64 our object is what clang's assembler
//!    and ours make of our assembly; on RISC-V its code, unwind and
//!    exception tables, and the words they reach personality routines and
//!    types through, are LLVM's of it, byte for byte.

use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_codegen::assembler::Assembler;
use epitome_codegen::elf;
use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

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
        let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
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
        let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
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
    let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).map_err(|e| format!("{e:?}"))?;
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

/// Rust's shape for dropping a value while unwinding: the landing pad
/// saves the exception and invokes the drop, whose own landing pad only
/// calls a function that does not return (`panic_in_cleanup`). Only
/// unwind edges reach those pads, and block layout must keep them for the
/// exception table.
#[test]
fn landing_pads_reached_only_by_unwinding_are_kept() {
    let src = "target triple = \"arm64-apple-macosx14.0.0\"\n\
        declare i1 @may_throw()\n\
        declare void @drop_it()\n\
        declare void @abort() noreturn\n\
        declare i32 @__gxx_personality_v0(...)\n\
        define i1 @f() personality ptr @__gxx_personality_v0 {\n\
        entry:\n  %slot = alloca { ptr, i32 }\n\
          %r = invoke i1 @may_throw() to label %ok unwind label %cleanup\n\
        again:\n  invoke void @drop_it() to label %resume unwind label %terminate\n\
        cleanup:\n  %e = landingpad { ptr, i32 } cleanup\n  %e0 = extractvalue { ptr, i32 } %e, 0\n  %e1 = extractvalue { ptr, i32 } %e, 1\n\
          store ptr %e0, ptr %slot\n  %at = getelementptr i8, ptr %slot, i64 8\n  store i32 %e1, ptr %at\n  br label %again\n\
        ok:\n  call void @drop_it()\n  ret i1 %r\n\
        terminate:\n  %t = landingpad { ptr, i32 } filter [0 x ptr] zeroinitializer\n  call void @abort()\n  unreachable\n\
        resume:\n  %v0 = load ptr, ptr %slot\n  %at2 = getelementptr i8, ptr %slot, i64 8\n  %v1 = load i32, ptr %at2\n\
          %w = insertvalue { ptr, i32 } poison, ptr %v0, 0\n  %v = insertvalue { ptr, i32 } %w, i32 %v1, 1\n  resume { ptr, i32 } %v\n}\n";
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(src).unwrap();
    let compiled = compile(&t, &mut m, &Options::default()).unwrap();
    compiled.object_file(&t).unwrap();
    assert!(compiled.asm.contains("_abort") && compiled.asm.contains("Unwind_Resume"), "{}", compiled.asm);
}

/// ELF objects' exception tables, against the assemblers' (4. above).
#[test]
fn elf_exception_tables_are_the_assemblers() {
    let ok = have("clang++")
        && Command::new("rustc").args(["--print", "sysroot"]).output().is_ok_and(|o| {
            let root = String::from_utf8_lossy(&o.stdout).trim().to_string();
            Path::new(&root).join("lib/rustlib/riscv64gc-unknown-none-elf").exists()
        });
    if !ok {
        eprintln!("needs clang++ and rustc's riscv64gc-unknown-none-elf target; skipping");
        return;
    }
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("unwind-elf");
    std::fs::create_dir_all(&tmp).unwrap();
    let a64 = Target::aarch64();
    let rv = Target::load_path(root.join("targets/riscv64").to_str().unwrap()).unwrap();
    for opt in ["-O0", "-O2"] {
        let ll = tmp.join(format!("landing{opt}.ll"));
        run(Command::new("clang++")
            .args(["--target=aarch64-linux-gnu", "-fPIC", "-S", "-emit-llvm", opt])
            .arg(root.join("tests/unwind/landing.cpp"))
            .arg("-o")
            .arg(&ll))
        .unwrap();
        let src = std::fs::read_to_string(&ll).unwrap();

        // AArch64: clang's assembler and ours, of our assembly.
        let mut m = epitome_ir::parse_module(&src).unwrap();
        let c = compile(&a64, &mut m, &Options::default()).unwrap();
        let ours = elf::read(&c.object_file(&a64).unwrap()).unwrap().canonical(&a64.machine);
        let as_ours = Assembler::new(&a64).assemble(&c.asm, None).unwrap();
        let as_ours = elf::read(&elf::write(&as_ours.object, &a64.machine).unwrap()).unwrap().canonical(&a64.machine);
        let diff = epitome_codegen::object::differences(&ours, &as_ours, 8);
        assert!(diff.is_empty(), "{opt}: epitome-as differs:\n{}", diff.join("\n"));
        let (s, o) = (tmp.join(format!("landing{opt}.s")), tmp.join(format!("landing{opt}.o")));
        std::fs::write(&s, &c.asm).unwrap();
        run(Command::new("clang").args(["--target=aarch64-linux-gnu", "-c", "-o"]).arg(&o).arg(&s)).unwrap();
        let theirs = elf::read(&std::fs::read(&o).unwrap()).unwrap().canonical(&a64.machine);
        let diff = epitome_codegen::object::differences(&ours, &theirs, 8);
        assert!(diff.is_empty(), "{opt}: clang's assembler differs:\n{}", diff.join("\n"));

        // RISC-V: LLVM's assembler, not compressed, not relaxed.
        let mut m = epitome_ir::parse_module(&src).unwrap();
        let c = compile(&rv, &mut m, &Options::default()).unwrap();
        let ours = c.object_file(&rv).unwrap();
        let stem = format!("landing_rv{opt}");
        std::fs::write(tmp.join(format!("{stem}.s")), format!(".option norvc\n.option norelax\n{}", c.asm)).unwrap();
        std::fs::write(
            tmp.join(format!("{stem}.rs")),
            format!("#![no_std]\ncore::arch::global_asm!(include_str!(\"{stem}.s\"), options(raw));\n"),
        )
        .unwrap();
        let o = tmp.join(format!("{stem}.o"));
        run(Command::new("rustc")
            .args(["--target", "riscv64gc-unknown-none-elf", "--crate-type", "lib", "--emit", "obj", "-C"])
            .arg("target-feature=+m,+a,+zbb")
            .arg("-o")
            .arg(&o)
            .arg(tmp.join(format!("{stem}.rs"))))
        .unwrap();
        let theirs = std::fs::read(&o).unwrap();
        for name in [".text", ".eh_frame", ".gcc_except_table", ".data"] {
            assert!(!section(&ours, name).is_empty() || name == ".data", "{opt}: no {name}");
            assert_eq!(section(&ours, name), section(&theirs, name), "{opt}: RISC-V {name} differs from LLVM's");
        }
    }
}
