//! Parses every `.ll` file in `tests/corpus`, prints it, and checks the
//! output matches the input once comments and blank lines are removed. The
//! printed text must also parse and print to itself.
//!
//! The corpus was made with `clang -S -emit-llvm`; see the `.c` and `.cpp`
//! files next to it.

use std::path::Path;

/// Lines without comments, trailing spaces or blank lines.
fn significant_lines(text: &str) -> Vec<String> {
    text.lines().map(|l| strip_comment(l).trim_end().to_string()).filter(|l| !l.is_empty()).collect()
}

/// Removes a `;` comment that is not inside a string.
fn strip_comment(line: &str) -> &str {
    let mut in_string = false;
    for (i, c) in line.char_indices() {
        match c {
            '"' => in_string = !in_string,
            ';' if !in_string => return &line[..i],
            _ => {}
        }
    }
    line
}

fn check(path: &Path) -> Result<(), String> {
    let src = std::fs::read_to_string(path).unwrap();
    let m = draconian_ir::parse_module(&src).map_err(|e| format!("{}:{e}", path.display()))?;
    let printed = m.to_string();
    let want = significant_lines(&src);
    let got = significant_lines(&printed);
    for (i, (w, g)) in want.iter().zip(&got).enumerate() {
        if w != g {
            return Err(format!("{}: line {} differs\n want: {w}\n  got: {g}", path.display(), i + 1));
        }
    }
    if want.len() != got.len() {
        return Err(format!("{}: {} lines, expected {}", path.display(), got.len(), want.len()));
    }
    let again = draconian_ir::parse_module(&printed).map_err(|e| format!("{} (reprinted):{e}", path.display()))?;
    if again.to_string() != printed {
        return Err(format!("{}: printing is not stable", path.display()));
    }
    Ok(())
}

#[test]
fn corpus_round_trips() {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus");
    let mut files: Vec<_> = std::fs::read_dir(&dir)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "ll"))
        .collect();
    files.sort();
    assert!(!files.is_empty());
    let failures: Vec<String> = files.iter().filter_map(|f| check(f).err()).collect();
    assert!(failures.is_empty(), "{} of {} files failed:\n{}", failures.len(), files.len(), failures.join("\n"));
}
