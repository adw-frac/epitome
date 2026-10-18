; draconian-opt: -O2
; Regression: the debug record before the inlined call moves to the
; instruction that follows it instead of being lost.
define internal i32 @sq(i32 %v) !dbg !30 {
  %m = mul i32 %v, %v, !dbg !31
  ret i32 %m, !dbg !31
}

define i32 @f(i32 %a) !dbg !10 {
entry:
  %s = add i32 %a, 1, !dbg !22
    #dbg_value(i32 %s, !20, !DIExpression(), !22)
  %r = call i32 @sq(i32 %s), !dbg !22
  ret i32 %r, !dbg !22
}

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!7, !8}
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "x", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!3 = !DIFile(filename: "d.c", directory: "/tmp")
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !{i32 7, !"Dwarf Version", i32 5}
!8 = !{i32 2, !"Debug Info Version", i32 3}
!10 = distinct !DISubprogram(name: "f", scope: !3, file: !3, line: 3, type: !11, scopeLine: 3, spFlags: DISPFlagDefinition, unit: !2)
!11 = !DISubroutineType(types: !12)
!12 = !{!6, !6}
!20 = !DILocalVariable(name: "x", scope: !10, file: !3, line: 4, type: !6)
!22 = !DILocation(line: 4, column: 7, scope: !10)
!30 = distinct !DISubprogram(name: "sq", scope: !3, file: !3, line: 1, type: !11, scopeLine: 1, spFlags: DISPFlagDefinition, unit: !2)
!31 = !DILocation(line: 1, column: 3, scope: !30)
