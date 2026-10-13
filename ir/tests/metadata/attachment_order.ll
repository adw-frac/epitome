; Input for tests/metadata.rs. The .expected.ll file is clang's output for it.
define i32 @f(ptr %p) {
  %a = load i32, ptr %p, align 4, !zzz !{!"z"}, !annotation !{!"ann"}, !range !{i32 0, i32 10}, !noundef !{}, !aaa !{!"a"}
  %b = load i32, ptr %p, align 4, !aaa !{!"a"}, !zzz !{!"z"}
  ret i32 %a
}
define void @g() !zzz !{!"z"} !aaa !{!"a"} !prof !{!"function_entry_count", i64 1} {
  ret void
}
