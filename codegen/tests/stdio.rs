//! `-` on the command line is the standard stream, as for clang and llc:
//! `-o -` writes to standard output and an input of `-` reads standard
//! input. Neither may make a file called `-`.

use std::io::Write;
use std::process::{Command, Stdio};

const IR: &str = "define i32 @f() {\n  ret i32 7\n}\n";

/// Runs `exe` with `args` in a fresh directory, `input` on its standard
/// input; returns its standard output and the directory.
fn run(exe: &str, args: &[&str], input: &[u8], name: &str) -> (Vec<u8>, std::path::PathBuf) {
    let dir = std::env::temp_dir().join(format!("epitome-stdio-{name}-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("t.ll"), IR).unwrap();
    let mut child = Command::new(exe)
        .args(args)
        .current_dir(&dir)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    child.stdin.take().unwrap().write_all(input).unwrap();
    let out = child.wait_with_output().unwrap();
    assert!(out.status.success(), "{exe} {args:?}: {}", String::from_utf8_lossy(&out.stderr));
    assert!(!dir.join("-").exists(), "{exe} {args:?} made a file called -");
    (out.stdout, dir)
}

#[test]
fn llc_writes_and_reads_the_standard_streams() {
    let llc = env!("CARGO_BIN_EXE_epitome-llc");
    let (asm, _) = run(llc, &["t.ll", "-o", "-"], b"", "llc-out");
    assert!(String::from_utf8_lossy(&asm).contains("_f:"));
    let (asm, _) = run(llc, &["-"], IR.as_bytes(), "llc-in");
    assert!(String::from_utf8_lossy(&asm).contains("_f:"));
    // An object file to standard output: Mach-O's magic number.
    let (obj, _) = run(llc, &["t.ll", "--filetype=obj", "-o", "-"], b"", "llc-obj");
    assert_eq!(&obj[..4], &[0xcf, 0xfa, 0xed, 0xfe]);
}

#[test]
fn as_writes_and_reads_the_standard_streams() {
    let llc = env!("CARGO_BIN_EXE_epitome-llc");
    let asm = run(llc, &["t.ll", "-o", "-"], b"", "as-src").0;
    let as_ = env!("CARGO_BIN_EXE_epitome-as");
    let (obj, _) = run(as_, &["-", "-o", "-"], &asm, "as");
    assert_eq!(&obj[..4], &[0xcf, 0xfa, 0xed, 0xfe]);
}
