; @f: inlined @sq: cost 1, bonus 12, threshold 100
; @sq: deleted, no longer used


define i32 @f(i32 %a) !dbg !4 {
entry:
  %s = add i32 %a, 1, !dbg !8
    #dbg_value(i32 %s, !9, !DIExpression(), !8)
  %m.i = mul i32 %s, %s, !dbg !10
  ret i32 %m.i, !dbg !8
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "x", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "d.c", directory: "/tmp")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 3, type: !5, scopeLine: 3, spFlags: DISPFlagDefinition, unit: !0)
!5 = !DISubroutineType(types: !6)
!6 = !{!7, !7}
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!8 = !DILocation(line: 4, column: 7, scope: !4)
!9 = !DILocalVariable(name: "x", scope: !4, file: !1, line: 4, type: !7)
!10 = !DILocation(line: 1, column: 3, scope: !11, inlinedAt: !8)
!11 = distinct !DISubprogram(name: "sq", scope: !1, file: !1, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition, unit: !0)
