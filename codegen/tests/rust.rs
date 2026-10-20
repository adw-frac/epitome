//! Whole Rust programs (`tests/rust/*.rs`) compiled by epitome: rustc
//! writes a program's IR and links it, with our object for its crate in
//! place of its own, against its standard library; the program must print
//! what rustc's own build of it does. At `-C opt-level=0` and `2`; the
//! programs need panics to unwind through and be caught in our code
//! (landing pads, exception tables), and arithmetic with overflow checks.
//! On an AArch64 Mac only (the binaries are run).

use std::path::PathBuf;
use std::process::Command;

use epitome_codegen::assembler::Assembler;
use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!(
            "{cmd:?} failed ({}):\n{}{}",
            out.status,
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// What the program `name` prints, built by rustc, and built by rustc with
/// our object at `opt` (the link command rustc prints, its object for the
/// crate replaced).
fn outputs(name: &str, opt: u32) -> Result<(String, String), String> {
    let src = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(format!("tests/rust/{name}.rs"));
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join(format!("rust-{name}-O{opt}"));
    let _ = std::fs::remove_dir_all(&tmp);
    std::fs::create_dir_all(&tmp).unwrap();
    let link = run(Command::new("rustc")
        .current_dir(&tmp)
        .args(["--edition", "2021", "-C", &format!("opt-level={opt}"), "-C", "codegen-units=1"])
        .args(["--emit=llvm-ir,link", "-C", "save-temps", "--print", "link-args"])
        .arg(&src)
        .args(["-o", "theirs"]))?;
    let want = run(&mut Command::new(tmp.join("theirs")))?;

    let ll = std::fs::read_to_string(tmp.join("theirs.ll")).unwrap();
    let mut m = epitome_ir::parse_module(&ll).map_err(|e| format!("{e:?}"))?;
    let t = Target::aarch64();
    let compiled = compile(&t, &mut m, &Options::default())?;
    let bytes = compiled.object_file(&t)?;
    let assembled = Assembler::new(&t).assemble(&compiled.asm, None)?.file(&t)?;
    if bytes != assembled {
        return Err(format!("{name}: the object assembled from our assembly differs"));
    }
    std::fs::write(tmp.join("ours.o"), bytes).unwrap();

    // rustc's link command (one line, its arguments quoted), with ours.
    let ours = link
        .split(' ')
        .map(|a| {
            let bare = a.trim_matches('"');
            if bare.starts_with("theirs.") && bare.ends_with("-cgu.0.rcgu.o") {
                "\"ours.o\"".to_string()
            } else if bare == "theirs" {
                "\"ours\"".to_string()
            } else {
                a.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join(" ");
    if !ours.contains("\"ours.o\"") {
        return Err(format!("{name}: no object for the crate in rustc's link command:\n{link}"));
    }
    run(Command::new("sh").current_dir(&tmp).arg("-c").arg(ours.trim()))?;
    Ok((want, run(&mut Command::new(tmp.join("ours")))?))
}

fn check(name: &str) {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("rustc").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs rustc on an AArch64 Mac; skipping");
        return;
    }
    for opt in [0, 2] {
        let (want, got) = outputs(name, opt).unwrap();
        assert_eq!(got, want, "{name} at opt-level={opt}");
    }
}

#[test]
fn panics_unwind_and_are_caught() {
    check("panics");
}

#[test]
fn overflow_checks() {
    check("overflow");
}

#[test]
fn saturating_arithmetic() {
    check("saturating");
}

#[test]
fn wide_multiplication_overflow() {
    check("widemul");
}

#[test]
fn three_way_comparisons() {
    check("compare");
}
