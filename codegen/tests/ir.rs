//! Hand-written IR for what crates' code showed us we did wrong or not at
//! all: each `tests/ir/NAME.ll`, built by us and by clang, linked with
//! `NAME.main.c` (built by clang) and run on this machine; the two must
//! print the same. On an AArch64 Mac with clang only.

use std::path::PathBuf;
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn output(obj: &std::path::Path, main: &std::path::Path, exe: &std::path::Path) -> Result<String, String> {
    let st = Command::new("clang").arg(obj).arg(main).arg("-o").arg(exe).status().map_err(|e| e.to_string())?;
    if !st.success() {
        return Err(format!("linking {} failed", exe.display()));
    }
    let o = Command::new(exe).output().map_err(|e| e.to_string())?;
    if !o.status.success() {
        return Err(format!("{} failed", exe.display()));
    }
    Ok(String::from_utf8_lossy(&o.stdout).into_owned())
}

#[test]
fn ir_behaves_as_clangs_build() {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/ir");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("ir");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = Target::aarch64();
    let mut names: Vec<String> = std::fs::read_dir(&dir)
        .unwrap()
        .filter_map(|e| e.ok()?.file_name().to_str()?.strip_suffix(".ll").map(str::to_string))
        .collect();
    names.sort();
    let mut failures = Vec::new();
    for name in &names {
        let ll = dir.join(format!("{name}.ll"));
        let main = dir.join(format!("{name}.main.c"));
        let run = || -> Result<(), String> {
            let src = std::fs::read_to_string(&ll).map_err(|e| e.to_string())?;
            let mut m = epitome_ir::parse_module(&src).map_err(|e| format!("{e:?}"))?;
            let ours = tmp.join(format!("{name}.ours.o"));
            std::fs::write(&ours, compile(&t, &mut m, &Options::default())?.object_file(&t)?).unwrap();
            let theirs = tmp.join(format!("{name}.clang.o"));
            let st = Command::new("clang").arg("-c").arg(&ll).arg("-o").arg(&theirs).status().unwrap();
            if !st.success() {
                return Err("clang could not build it".into());
            }
            let a = output(&ours, &main, &tmp.join(format!("{name}.ours")))?;
            let b = output(&theirs, &main, &tmp.join(format!("{name}.clang")))?;
            if a != b {
                return Err("differs from clang's build".into());
            }
            println!("ok {name}");
            Ok(())
        };
        if let Err(e) = run() {
            failures.push(format!("{name}: {e}"));
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
