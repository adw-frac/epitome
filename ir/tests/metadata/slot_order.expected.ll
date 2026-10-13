
@g = global i32 0, !m1 !0

declare !m2 !10 void @d()

define void @f1(ptr %p) !m3 !11 {
  call void @llvm.foo(metadata !12), !m4 !13
  ret void, !m5 !14
}

define void @f2() !m6 !15 {
  ret void, !m7 !16
}

declare void @llvm.foo(metadata)

!named = !{!1, !2}
!tree = !{!3}
!x = !{!7}
!y = !{!8, !9}

!0 = !{!"g"}
!1 = !{!"named-a"}
!2 = !{!"named-b"}
!3 = !{!4, !6}
!4 = !{!5}
!5 = !{!"D"}
!6 = !{!"C"}
!7 = !{!DIExpression(DW_OP_deref), !8}
!8 = !{!"a"}
!9 = !{!8}
!10 = !{!"decl"}
!11 = !{!"f1"}
!12 = !{!"callarg"}
!13 = !{!"call-att"}
!14 = !{!"ret-att"}
!15 = !{!"f2"}
!16 = !{!"f2-ret"}
