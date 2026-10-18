//! Hand-written IR covering forms the clang corpus does not, plus parse errors.

use draconian_ir::parse_module;

/// Lines without comments, trailing spaces or blank lines.
fn significant_lines(text: &str) -> Vec<String> {
    text.lines()
        .map(|l| {
            let mut in_string = false;
            let mut end = l.len();
            for (i, c) in l.char_indices() {
                match c {
                    '"' => in_string = !in_string,
                    ';' if !in_string => {
                        end = i;
                        break;
                    }
                    _ => {}
                }
            }
            l[..end].trim_end().to_string()
        })
        .filter(|l| !l.is_empty())
        .collect()
}

#[test]
fn features_round_trip_exactly() {
    let src = include_str!("features/features.ll");
    let m = parse_module(src).unwrap_or_else(|e| panic!("features.ll:{e}"));
    let printed = m.to_string();
    let want = significant_lines(src);
    let got = significant_lines(&printed);
    for (w, g) in want.iter().zip(&got) {
        assert_eq!(w, g);
    }
    assert_eq!(want.len(), got.len());
}

/// Parses `src` and returns the error as `line:column: message`.
fn error(src: &str) -> String {
    match parse_module(src) {
        Ok(_) => panic!("expected an error for:\n{src}"),
        Err(e) => e.to_string(),
    }
}

#[test]
fn errors_have_positions() {
    assert_eq!(error("@g = global i32 x"), "1:17: expected a constant, found 'x'");
    assert_eq!(error("define void @f() {\n  ret i32 %x\n}"), "2:11: use of undefined value '%x'");
    assert_eq!(error("@p = global ptr @nowhere"), "1:17: use of undefined global '@nowhere'");
    assert_eq!(error("@g = global i8 256"), "1:16: integer constant does not fit its type");
    assert_eq!(
        error("define void @f() {\n  %a = add i32 1, 2\n}"),
        "3:1: expected a terminator instruction before '}'"
    );
    assert_eq!(error("@g = global i32* null"), "1:16: typed pointers are not supported; use 'ptr', found '*'");
    assert_eq!(error("!0 = !{!1}"), "1:8: use of undefined metadata '!1'");
    assert_eq!(error("@s = global [2 x i8] c\"abc\""), "1:22: string constant does not match its array type");
}

#[test]
fn forward_references_and_type_checks() {
    // A value used before its definition, with a matching type.
    let ok = "define i32 @f(i1 %c) {\nentry:\n  br label %b\n\nb:\n  %p = phi i32 [ 0, %entry ], [ %n, %b ]\n  %n = add i32 %p, 1\n  br i1 %c, label %b, label %e\n\ne:\n  ret i32 %n\n}\n";
    parse_module(ok).unwrap();
    // The same value used with two types.
    let bad = "define void @f() {\n  %a = add i32 %b, 1\n  %b = add i64 1, 1\n  ret void\n}";
    assert_eq!(error(bad), "2:16: value used with a different type from its definition");
    // Numbered values must increase.
    let bad = "define void @f() {\n  %1 = add i32 1, 1\n  %0 = add i32 1, 1\n  ret void\n}";
    assert!(error(bad).starts_with("3:3: instruction expected to be numbered '%2' or higher"));
}
