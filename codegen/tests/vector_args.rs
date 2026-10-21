//! Vectors no register holds, passed and returned by value, as LLVM's
//! AArch64 backend passes them (`prepare::vector_abi`): `<4 x i64>` and
//! `<8 x float>` as 128-bit parts, past the registers on the stack;
//! `<3 x float>` and `<3 x i32>` widened to four lanes; `<2 x i8>` and
//! `<4 x i8>` with their lanes widened to fill 64 bits.
//!
//! `tests/vector_args/callee.ll` has the functions and `caller.ll` calls
//! them; each is built by us and by clang, and every pairing is linked
//! with `main.c` and run on this machine: each must print what clang's
//! build of both does.

use std::path::PathBuf;
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn run(cmd: &mut Command) -> String {
    let out = cmd.output().unwrap_or_else(|e| panic!("{cmd:?}: {e}"));
    assert!(out.status.success(), "{cmd:?} failed:\n{}", String::from_utf8_lossy(&out.stderr));
    String::from_utf8_lossy(&out.stdout).into_owned()
}

#[test]
fn vectors_pass_as_llvms_do() {
    let clang = Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !(clang && cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/vector_args");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("vector_args");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = Target::aarch64();
    let mut objects = Vec::new();
    for name in ["callee", "caller"] {
        let ll = dir.join(format!("{name}.ll"));
        let theirs = tmp.join(format!("{name}.clang.o"));
        run(Command::new("clang").arg("-c").arg(&ll).arg("-o").arg(&theirs));
        let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
        let ours = tmp.join(format!("{name}.ours.o"));
        std::fs::write(&ours, compile(&t, &mut m, &Options::default()).unwrap().object_file(&t).unwrap()).unwrap();
        objects.push((theirs, ours));
    }
    let mut outputs = Vec::new();
    for (k, (callee, caller)) in [(0, 0), (0, 1), (1, 0), (1, 1)].iter().enumerate() {
        let pick = |p: &(PathBuf, PathBuf), which: usize| if which == 0 { p.0.clone() } else { p.1.clone() };
        let exe = tmp.join(format!("main{k}"));
        run(Command::new("clang")
            .arg(pick(&objects[0], *callee))
            .arg(pick(&objects[1], *caller))
            .arg(dir.join("main.c"))
            .arg("-o")
            .arg(&exe));
        outputs.push(run(&mut Command::new(&exe)));
    }
    for (k, who) in ["caller ours", "callee ours", "both ours"].iter().enumerate() {
        assert_eq!(outputs[k + 1], outputs[0], "{who}: differs from clang's build");
    }
}
