; Input for tests/metadata.rs. The .expected.ll file is clang's output for it.
source_filename = "d.c"

@g = global i32 0, align 4, !dbg !0

define i32 @f(i32 %a, i32 %b, ptr %p) !dbg !10 {
entry:
  %x = alloca i32, align 4, !DIAssignID !30
    #dbg_declare(ptr %x, !20, !DIExpression(), !22)
    #dbg_assign(i32 poison, !20, !DIExpression(), !30, ptr %x, !DIExpression(), !22)
  %s = add i32 %a, %b, !dbg !DILocation(line: 4, column: 7, scope: !10)
    #dbg_value(!DIArgList(i32 %a, i32 %b), !20, !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_plus, DW_OP_stack_value), !22)
    #dbg_value(i32 %s, !20, !DIExpression(DW_OP_LLVM_fragment, 0, 16), !22)
    #dbg_value(ptr %p, !20, !DIExpression(DW_OP_deref, DW_OP_constu, 18446744073709551615, DW_OP_minus), !22)
    #dbg_label(!25, !22)
  call void @llvm.foo(metadata i32 %s, metadata !20, metadata !DIExpression()), !dbg !22, !annotation !{!"hi"}
  ret i32 %s, !dbg !22
}

declare void @llvm.foo(metadata, metadata, metadata)

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!7, !8}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "g", scope: !2, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "clang \22x\22", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
!3 = !DIFile(filename: "d.c", directory: "/tmp", checksumkind: CSK_MD5, checksum: "0123456789abcdef0123456789abcdef")
!4 = !{!0}
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !{i32 7, !"Dwarf Version", i32 5}
!8 = !{i32 2, !"Debug Info Version", i32 3}
!10 = distinct !DISubprogram(name: "f", scope: !3, file: !3, line: 3, type: !11, scopeLine: 3, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !13)
!11 = !DISubroutineType(types: !12)
!12 = !{!6, !6, !6, null}
!13 = !{}
!14 = !DICompositeType(tag: DW_TAG_array_type, baseType: !6, size: 320, elements: !15)
!15 = !{!16}
!16 = !DISubrange(count: 10, lowerBound: -1)
!17 = !DIEnumerator(name: "BIG", value: 18446744073709551615, isUnsigned: true)
!18 = !DIEnumerator(name: "NEG", value: -5)
!20 = !DILocalVariable(name: "x", scope: !10, file: !3, line: 4, type: !6)
!22 = !DILocation(line: 4, column: 7, scope: !10)
!25 = !DILabel(scope: !10, name: "L", file: !3, line: 5)
!30 = distinct !DIAssignID()
