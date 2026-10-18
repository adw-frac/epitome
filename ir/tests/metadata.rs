//! Metadata rules: merging identical nodes, numbering, attachment order and
//! the upgrade of old debug intrinsics. Each `metadata/NAME.ll` input is
//! printed and compared with `NAME.expected.ll`, which is what
//! `clang -S -emit-llvm -x ir NAME.ll` printed for it (less the `ModuleID`,
//! `source_filename` and `target` lines clang adds).

use draconian_ir::parse_module;

/// Lines without comments, blank lines or `source_filename`.
fn significant_lines(text: &str) -> Vec<&str> {
    text.lines().filter(|l| !l.is_empty() && !l.starts_with(';') && !l.starts_with("source_filename")).collect()
}

fn check(name: &str, src: &str, expected: &str) {
    let m = parse_module(src).unwrap_or_else(|e| panic!("{name}.ll:{e}"));
    let printed = m.to_string();
    let got = significant_lines(&printed);
    let want = significant_lines(expected);
    for (i, (w, g)) in want.iter().zip(&got).enumerate() {
        assert_eq!(w, g, "{name}: line {} differs", i + 1);
    }
    assert_eq!(want.len(), got.len(), "{name}: line count differs");
}

macro_rules! cases {
    ($($name:ident),*) => {$(
        #[test]
        fn $name() {
            let name = stringify!($name);
            check(
                name,
                include_str!(concat!("metadata/", stringify!($name), ".ll")),
                include_str!(concat!("metadata/", stringify!($name), ".expected.ll")),
            );
        }
    )*};
}

cases!(attachment_order, debug_records, old_intrinsics, record_order, slot_order);

fn error(src: &str) -> String {
    parse_module(src).map(|_| ()).unwrap_err().to_string()
}

#[test]
fn named_metadata_needs_numbered_nodes() {
    assert_eq!(error("!a = !{!{}}\n"), "1:8: named metadata operands must be numbered nodes such as !0");
}

#[test]
fn debug_intrinsic_needs_location() {
    let src = "define void @f() {\n  call void @llvm.dbg.label(metadata !0)\n  ret void\n}\n\
               declare void @llvm.dbg.label(metadata)\n!0 = !{}\n";
    assert_eq!(error(src), "2:3: debug intrinsic call has no !dbg location");
}

#[test]
fn identical_nodes_merge_but_distinct_and_cyclic_nodes_do_not() {
    let src = "!a = !{!0, !1, !2, !3, !4, !5}\n\
               !0 = !{!\"x\"}\n!1 = !{!\"x\"}\n\
               !2 = distinct !{!\"x\"}\n!3 = distinct !{!\"x\"}\n\
               !4 = !{!4}\n!5 = !{!5}\n";
    let printed = parse_module(src).unwrap().to_string();
    assert!(printed.contains("!a = !{!0, !0, !1, !2, !3, !4}"), "{printed}");
}
