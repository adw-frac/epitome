; Input for tests/metadata.rs. The .expected.ll file is clang's output for it.
@g = global i32 0, !m1 !{!"g"}
declare !m2 !{!"decl"} void @d()
define void @f1(ptr %p) !m3 !{!"f1"} {
  call void @llvm.foo(metadata !{!"callarg"}), !m4 !{!"call-att"}
  ret void, !m5 !{!"ret-att"}
}
define void @f2() !m6 !{!"f2"} {
  ret void, !m7 !{!"f2-ret"}
}
declare void @llvm.foo(metadata)
!named = !{!400, !401}
!400 = !{!"named-a"}
!401 = !{!"named-b"}
!tree = !{!100}
!100 = !{!101, !103}
!101 = !{!102}
!102 = !{!"D"}
!103 = !{!"C"}
!200 = !{!"unused"}
!300 = !DIExpression(DW_OP_deref)
!x = !{!301}
!301 = !{!300, !302}
!302 = !{!"a"}
!303 = !{!"a"}
!y = !{!303, !304}
!304 = !{!{!"a"}}
