
define void @f(i32 %a) !dbg !3 {
  %x = alloca i32, align 4, !DIAssignID !6
    #dbg_value(i32 %a, !7, !DIExpression(), !9)
    #dbg_assign(i32 %a, !10, !DIExpression(), !6, ptr %x, !DIExpression(), !11)
  call void @llvm.foo(metadata !12), !dbg !13, !annotation !14
  store i32 %a, ptr %x, align 4, !dbg !15, !annotation !16
  ret void, !dbg !17
}

declare void @llvm.foo(metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "a.c", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 1, type: !4, spFlags: DISPFlagDefinition, unit: !0)
!4 = !DISubroutineType(types: !5)
!5 = !{}
!6 = distinct !DIAssignID()
!7 = !DILocalVariable(name: "v1", scope: !3, file: !1, line: 1, type: !8)
!8 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!9 = !DILocation(line: 11, scope: !3)
!10 = !DILocalVariable(name: "v2", scope: !3, file: !1, line: 1, type: !8)
!11 = !DILocation(line: 12, scope: !3)
!12 = !{!"callarg"}
!13 = !DILocation(line: 13, scope: !3)
!14 = !{!"ann"}
!15 = !DILocation(line: 14, scope: !3)
!16 = !{!"ann2"}
!17 = !DILocation(line: 15, scope: !3)
