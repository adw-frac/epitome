; Input for tests/metadata.rs. The .expected.ll file is clang's output for it.
define void @f(i32 %a) !dbg !3 {
  %x = alloca i32, align 4, !DIAssignID !9
    #dbg_value(i32 %a, !DILocalVariable(name: "v1", scope: !3, file: !1, line: 1, type: !4), !DIExpression(), !DILocation(line: 11, scope: !3))
    #dbg_assign(i32 %a, !DILocalVariable(name: "v2", scope: !3, file: !1, line: 1, type: !4), !DIExpression(), !9, ptr %x, !DIExpression(), !DILocation(line: 12, scope: !3))
  call void @llvm.foo(metadata !{!"callarg"}), !dbg !DILocation(line: 13, scope: !3), !annotation !{!"ann"}
  store i32 %a, ptr %x, align 4, !annotation !{!"ann2"}, !dbg !DILocation(line: 14, scope: !3)
  ret void, !dbg !DILocation(line: 15, scope: !3)
}
declare void @llvm.foo(metadata)
!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!7}
!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "a.c", directory: "/")
!2 = !DISubroutineType(types: !{})
!3 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 1, type: !2, spFlags: DISPFlagDefinition, unit: !0)
!4 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !{i32 2, !"Debug Info Version", i32 3}
!9 = distinct !DIAssignID()
