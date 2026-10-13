
@g = global i32 0, align 4, !dbg !0

define i32 @f(i32 %a, i32 %b, ptr %p) !dbg !8 {
entry:
  %x = alloca i32, align 4, !DIAssignID !12
    #dbg_declare(ptr %x, !13, !DIExpression(), !14)
    #dbg_assign(i32 poison, !13, !DIExpression(), !12, ptr %x, !DIExpression(), !14)
  %s = add i32 %a, %b, !dbg !14
    #dbg_value(!DIArgList(i32 %a, i32 %b), !13, !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_plus, DW_OP_stack_value), !14)
    #dbg_value(i32 %s, !13, !DIExpression(DW_OP_LLVM_fragment, 0, 16), !14)
    #dbg_value(ptr %p, !13, !DIExpression(DW_OP_deref, DW_OP_constu, 18446744073709551615, DW_OP_minus), !14)
    #dbg_label(!15, !14)
  call void @llvm.foo(metadata i32 %s, metadata !13, metadata !DIExpression()), !dbg !14, !annotation !16
  ret i32 %s, !dbg !14
}

declare void @llvm.foo(metadata, metadata, metadata)

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!6, !7}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "g", scope: !2, file: !3, line: 1, type: !5, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "clang \22x\22", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
!3 = !DIFile(filename: "d.c", directory: "/tmp", checksumkind: CSK_MD5, checksum: "0123456789abcdef0123456789abcdef")
!4 = !{!0}
!5 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!6 = !{i32 7, !"Dwarf Version", i32 5}
!7 = !{i32 2, !"Debug Info Version", i32 3}
!8 = distinct !DISubprogram(name: "f", scope: !3, file: !3, line: 3, type: !9, scopeLine: 3, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !11)
!9 = !DISubroutineType(types: !10)
!10 = !{!5, !5, !5, null}
!11 = !{}
!12 = distinct !DIAssignID()
!13 = !DILocalVariable(name: "x", scope: !8, file: !3, line: 4, type: !5)
!14 = !DILocation(line: 4, column: 7, scope: !8)
!15 = !DILabel(scope: !8, name: "L", file: !3, line: 5)
!16 = !{!"hi"}
