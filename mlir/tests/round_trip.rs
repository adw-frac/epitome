//! Parses every `.mlir` file in `tests/corpus`, prints it, and checks the
//! output matches the input once comments, indentation and blank lines are
//! removed. The printed text must also parse and print to itself.
//!
//! The corpus is the examples in `docs/mlir/examples`, printed in the
//! generic form by `circt-opt` and torch-mlir's `torch-mlir-opt` and
//! Python bindings (`--mlir-print-op-generic`), with and without
//! locations (`.loc.mlir`, `--mlir-print-debuginfo`). See
//! `docs/mlir/06-observed-behaviour.md` for the tools' versions.

use std::path::Path;

/// Lines without comments, indentation, trailing spaces or blank lines.
fn significant_lines(text: &str) -> Vec<String> {
    text.lines().map(|l| strip_comment(l).trim().to_string()).filter(|l| !l.is_empty()).collect()
}

/// Removes a `//` comment that is not inside a string.
fn strip_comment(line: &str) -> &str {
    let b = line.as_bytes();
    let mut in_string = false;
    let mut i = 0;
    while i < b.len() {
        match b[i] {
            b'\\' if in_string => i += 1,
            b'"' => in_string = !in_string,
            b'/' if !in_string && b.get(i + 1) == Some(&b'/') => return &line[..i],
            _ => {}
        }
        i += 1;
    }
    line
}

fn check(path: &Path) -> Result<(), String> {
    let src = std::fs::read_to_string(path).unwrap();
    let m = epitome_mlir::parse_module(&src).map_err(|e| format!("{}:{e}", path.display()))?;
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
    let again = epitome_mlir::parse_module(&printed).map_err(|e| format!("{} (reprinted):{e}", path.display()))?;
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
        .filter(|p| p.extension().is_some_and(|e| e == "mlir"))
        .collect();
    files.sort();
    assert!(!files.is_empty());
    let failures: Vec<String> = files.iter().filter_map(|f| check(f).err()).collect();
    assert!(failures.is_empty(), "{} of {} files failed:\n{}", failures.len(), files.len(), failures.join("\n"));
}

/// `text` with every value renamed by order of first appearance, `%0`,
/// `%1` and so on, keeping `#n` result numbers: MLIR's generic printer
/// numbers values where the custom form names them (`%int1`).
fn renumbered(text: &str) -> String {
    let b = text.as_bytes();
    let mut names: std::collections::HashMap<&str, usize> = std::collections::HashMap::new();
    let mut out = String::with_capacity(text.len());
    let mut i = 0;
    let mut in_string = false;
    while i < b.len() {
        let c = b[i];
        if c == b'"' && (i == 0 || b[i - 1] != b'\\') {
            in_string = !in_string;
        }
        if c == b'%' && !in_string {
            let mut j = i + 1;
            while j < b.len() && (b[j].is_ascii_alphanumeric() || matches!(b[j], b'_' | b'$' | b'.' | b'-')) {
                j += 1;
            }
            let n = names.len();
            let k = *names.entry(&text[i + 1..j]).or_insert(n);
            out += &format!("%v{k}");
            i = j;
            continue;
        }
        out.push(c as char);
        i += 1;
    }
    out
}

/// torch-mlir's files in their custom form, read and printed generically,
/// must match what torch-mlir's own tools print for them (the corpus).
#[test]
fn custom_forms_match_the_generic_form() {
    let examples = Path::new(env!("CARGO_MANIFEST_DIR")).join("../docs/mlir/examples/pytorch");
    let corpus = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus");
    let mut files: Vec<_> = std::fs::read_dir(&examples)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| {
            let name = p.file_name().unwrap().to_str().unwrap();
            // Dynamic shapes use `torch.bind_symbolic_shape`, not read yet.
            (name.ends_with(".torch.mlir") || name.ends_with(".raw.mlir")) && !name.contains("dynamic")
        })
        .collect();
    files.sort();
    assert!(files.len() >= 10);
    let mut failures = Vec::new();
    for path in &files {
        let generic = corpus.join(format!("pytorch__{}", path.file_name().unwrap().to_str().unwrap()));
        let src = std::fs::read_to_string(path).unwrap();
        if src.starts_with("// FAILED") {
            // A record of an export torch-mlir could not do, with no IR.
            continue;
        }
        let m = match epitome_mlir::parse_module(&src) {
            Ok(m) => m,
            Err(e) => {
                failures.push(format!("{}:{e}", path.display()));
                continue;
            }
        };
        let want = significant_lines(&renumbered(&std::fs::read_to_string(&generic).unwrap()));
        let got = significant_lines(&renumbered(&m.to_string()));
        if let Some((i, (w, g))) = want.iter().zip(&got).enumerate().find(|(_, (w, g))| w != g) {
            failures.push(format!("{}: line {} differs\n want: {w}\n  got: {g}", path.display(), i + 1));
        } else if want.len() != got.len() {
            failures.push(format!("{}: {} lines, expected {}", path.display(), got.len(), want.len()));
        }
    }
    assert!(failures.is_empty(), "{} of {} files failed:\n{}", failures.len(), files.len(), failures.join("\n"));
}
