//! `-` on the command line is the standard stream, as for clang and opt:
//! `-o -` writes to standard output and an input of `-` reads standard
//! input. Neither may make a file called `-`.

use std::io::Write;
use std::process::{Command, Stdio};

#[test]
fn opt_writes_and_reads_the_standard_streams() {
    let dir = std::env::temp_dir().join(format!("epitome-stdio-opt-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    let mut child = Command::new(env!("CARGO_BIN_EXE_epitome-opt"))
        .args(["-", "-o", "-"])
        .current_dir(&dir)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    child.stdin.take().unwrap().write_all(b"define i32 @f() {\n  %x = add i32 3, 4\n  ret i32 %x\n}\n").unwrap();
    let out = child.wait_with_output().unwrap();
    assert!(out.status.success(), "{}", String::from_utf8_lossy(&out.stderr));
    assert!(String::from_utf8_lossy(&out.stdout).contains("ret i32 7"));
    assert!(!dir.join("-").exists(), "made a file called -");
}
