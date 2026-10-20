//! Inline assembly on AArch64 (`asm/aarch64.c`): built by clang into IR at
//! `-O0` and `-O2`, compiled by us, linked with a main built by clang, and
//! run, here, on this machine. Each build must print what clang's own build
//! of the same C prints. Our assembly is also assembled by clang, and its
//! code must be ours word for word: that checks the inline assembly we
//! write in, and how our assembler reads it, against another assembler.
//!
//! Skipped unless clang is installed and this is an AArch64 Mac.

use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_codegen::objdump::Image;
use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!("{cmd:?} failed:\n{}", String::from_utf8_lossy(&out.stderr)));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// The code of an object file: its executable sections' bytes.
fn code(bytes: &[u8], t: &Target) -> Vec<u8> {
    let img = Image::read(bytes, &t.machine).unwrap();
    img.sections.iter().filter(|s| s.code).flat_map(|s| s.data.clone()).collect()
}

fn check(t: &Target, dir: &Path, tmp: &Path, opt: &str, want: &str) -> Result<(), String> {
    let ll = tmp.join(format!("aarch64{opt}.ll"));
    run(Command::new("clang").args(["-S", "-emit-llvm", opt]).arg(dir.join("aarch64.c")).arg("-o").arg(&ll))?;
    let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).map_err(|e| format!("{e:?}"))?;
    let compiled = compile(t, &mut m, &Options::default())?;
    let s = tmp.join(format!("aarch64{opt}.s"));
    std::fs::write(&s, &compiled.asm).unwrap();
    let ours = compiled.object_file(t)?;
    let o = tmp.join(format!("aarch64{opt}.o"));
    std::fs::write(&o, &ours).unwrap();
    // Ours, and our assembly assembled by clang.
    let theirs_o = tmp.join(format!("aarch64{opt}.clang.o"));
    run(Command::new("clang").arg("-c").arg(&s).arg("-o").arg(&theirs_o))?;
    if code(&ours, t) != code(&std::fs::read(&theirs_o).unwrap(), t) {
        return Err(format!("{opt}: clang assembles our assembly ({}) to other code", s.display()));
    }
    for (name, obj) in [("ours", &o), ("clang-assembled", &theirs_o)] {
        let exe = tmp.join(format!("aarch64{opt}.{name}"));
        run(Command::new("clang").arg(obj).arg(dir.join("aarch64.main.c")).arg("-o").arg(&exe))?;
        let got = run(&mut Command::new(&exe))?;
        if got != want {
            return Err(format!("{opt} ({name}): printed\n{got}\ninstead of\n{want}"));
        }
    }
    Ok(())
}

#[test]
fn inline_asm_runs_on_aarch64() {
    let ok = Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !(ok && cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let t = Target::aarch64();
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/asm");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("inline-asm");
    std::fs::create_dir_all(&tmp).unwrap();
    let reference = tmp.join("ref");
    run(Command::new("clang")
        .arg("-O2")
        .arg(dir.join("aarch64.c"))
        .arg(dir.join("aarch64.main.c"))
        .arg("-o")
        .arg(&reference))
    .unwrap();
    let want = run(&mut Command::new(&reference)).unwrap();
    let failures: Vec<String> =
        ["-O0", "-O2"].iter().filter_map(|opt| check(&t, &dir, &tmp, opt, &want).err()).collect();
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
