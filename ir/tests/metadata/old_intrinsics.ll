; Input for tests/metadata.rs. The .expected.ll file is clang's output for it.
define void @f(i32 %a) !dbg !3 {
  call void @llvm.dbg.value(metadata i32 %a, metadata !5, metadata !DIExpression()), !dbg !6
  ret void, !dbg !6
}
declare void @llvm.dbg.value(metadata, metadata, metadata)
!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!7}
!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "a.c", directory: "/")
!2 = !DISubroutineType(types: !{})
!3 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 1, type: !2, spFlags: DISPFlagDefinition, unit: !0)
!4 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!5 = !DILocalVariable(name: "a", arg: 1, scope: !3, file: !1, line: 1, type: !4)
!6 = !DILocation(line: 1, scope: !3)
!7 = !{i32 2, !"Debug Info Version", i32 3}
