
define i32 @f(ptr %p) {
  %a = load i32, ptr %p, align 4, !range !0, !noundef !1, !annotation !2, !zzz !3, !aaa !4
  %b = load i32, ptr %p, align 4, !zzz !3, !aaa !4
  ret i32 %a
}

define void @g() !prof !5 !zzz !3 !aaa !4 {
  ret void
}

!0 = !{i32 0, i32 10}
!1 = !{}
!2 = !{!"ann"}
!3 = !{!"z"}
!4 = !{!"a"}
!5 = !{!"function_entry_count", i64 1}
