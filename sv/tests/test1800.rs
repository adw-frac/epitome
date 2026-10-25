//! Runs the lexer over every `.sv` and `.svh` file of the IEEE 1800-2023
//! conformance tests (github.com/andy-thomason/IEEE1800-2023-tests), when
//! `IEEE1800_TESTS` names a checkout of them. Without it the test passes
//! and says it was skipped.

use epitome_sv::lexer::tokenize;
use epitome_sv::source::Source;
use std::path::{Path, PathBuf};

fn files(dir: &Path, out: &mut Vec<PathBuf>) {
    let mut entries: Vec<_> = std::fs::read_dir(dir).unwrap().map(|e| e.unwrap().path()).collect();
    entries.sort();
    for path in entries {
        if path.is_dir() {
            files(&path, out);
        } else if path.extension().is_some_and(|e| e == "sv" || e == "svh") {
            out.push(path);
        }
    }
}

#[test]
fn lex_test1800() {
    let Ok(root) = std::env::var("IEEE1800_TESTS") else {
        eprintln!("IEEE1800_TESTS is not set; skipped");
        return;
    };
    let mut paths = Vec::new();
    files(&Path::new(&root).join("tests"), &mut paths);
    assert!(!paths.is_empty(), "no tests under {root}/tests");
    let (mut lexed, mut rejected, mut wrong) = (0, 0, Vec::new());
    for path in &paths {
        let src = Source::new(path.display().to_string(), std::fs::read_to_string(path).unwrap());
        let should_fail = src.text.contains(":should_fail_because:");
        match tokenize(&src.text) {
            Ok(_) => lexed += 1,
            // A test that should fail may fail in the lexer; which ones
            // should is checked once the parser decides the rest.
            Err(_) if should_fail => rejected += 1,
            Err(e) => wrong.push(e.render(&src)),
        }
    }
    eprintln!("{} files: {lexed} lexed, {rejected} should-fail tests rejected, {} wrong", paths.len(), wrong.len());
    assert!(wrong.is_empty(), "legal files the lexer rejects:\n{}", wrong.join("\n"));
}
