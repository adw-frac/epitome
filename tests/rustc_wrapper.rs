//! `epitome-rustc` as Cargo's `RUSTC_WRAPPER`, on a workspace of a library
//! with a build script (which writes into `OUT_DIR`) and a program using
//! it: the library is built without LLVM's back end (its archive made by
//! `epitome-rustc`), the program runs and prints what it should, and a
//! second build, in a target directory of its own, takes the library from
//! the cache (`EPITOME_RUSTC_CACHE`) and prints the same. On an AArch64
//! Mac, with Cargo.

use std::path::Path;
use std::process::Command;

const LIB: &str = r#"include!(concat!(env!("OUT_DIR"), "/table.rs"));
pub fn mix(x: u64) -> u64 {
    TABLE.iter().fold(x, |a, &t| a.rotate_left(7) ^ t.wrapping_mul(0x9E37_79B9_7F4A_7C15))
}
pub fn greeting() -> String {
    format!("hello from {}", env!("CARGO_PKG_NAME"))
}
"#;

const BUILD: &str = r#"fn main() {
    let out = std::env::var("OUT_DIR").unwrap();
    let table: Vec<String> = (1..=16u64).map(|i| (i * i * 2654435761).to_string()).collect();
    std::fs::write(format!("{out}/table.rs"), format!("pub const TABLE: [u64; 16] = [{}];", table.join(", "))).unwrap();
}
"#;

const MAIN: &str = r#"fn main() {
    println!("{} {}", mixer::greeting(), (0..1000u64).map(mixer::mix).fold(0, |a, b| a ^ b));
}
"#;

fn write(path: &Path, text: &str) {
    std::fs::create_dir_all(path.parent().unwrap()).unwrap();
    std::fs::write(path, text).unwrap();
}

#[test]
fn libraries_without_llvm_and_from_the_cache() {
    if !(cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) {
        eprintln!("needs an AArch64 Mac; skipping");
        return;
    }
    let tmp = Path::new(env!("CARGO_TARGET_TMPDIR")).join("rustc_wrapper");
    let _ = std::fs::remove_dir_all(&tmp);
    let ws = tmp.join("ws");
    write(&ws.join("Cargo.toml"), "[workspace]\nmembers = [\"mixer\", \"app\"]\nresolver = \"2\"\n");
    write(&ws.join("mixer/Cargo.toml"), "[package]\nname = \"mixer\"\nversion = \"0.1.0\"\nedition = \"2021\"\n");
    write(&ws.join("mixer/build.rs"), BUILD);
    write(&ws.join("mixer/src/lib.rs"), LIB);
    write(
        &ws.join("app/Cargo.toml"),
        "[package]\nname = \"app\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\nmixer = { path = \"../mixer\" }\n",
    );
    write(&ws.join("app/src/main.rs"), MAIN);
    let cache = tmp.join("cache");
    let run = |target: &str| -> (String, String) {
        let target = tmp.join(target);
        let out = Command::new("cargo")
            .args(["run", "--release", "-q", "-p", "app"])
            .current_dir(&ws)
            .env("RUSTC_WRAPPER", env!("CARGO_BIN_EXE_epitome-rustc"))
            .env("CARGO_TARGET_DIR", &target)
            .env("EPITOME_RUSTC_CACHE", &cache)
            .output()
            .unwrap();
        assert!(out.status.success(), "{}", String::from_utf8_lossy(&out.stderr));
        let log = std::fs::read_to_string(target.join("release/epitome-rustc.log")).unwrap_or_default();
        (String::from_utf8_lossy(&out.stdout).into_owned(), log)
    };
    let (first, log) = run("t1");
    assert!(first.starts_with("hello from mixer "), "{first}");
    assert!(log.contains("mixer: ours (library) |"), "{log}");
    assert!(log.contains("app: ours (binary)"), "{log}");
    let (second, log) = run("t2");
    assert_eq!(first, second);
    assert!(log.contains("mixer: ours (library, cached)"), "{log}");
}
