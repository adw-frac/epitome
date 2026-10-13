; ModuleID = 'basic.c'
source_filename = "basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@.str = private unnamed_addr constant [15 x i8] c"hello \22world\22\0A\00", align 1, !dbg !0
@msg = local_unnamed_addr global ptr @.str, align 8, !dbg !7
@table = local_unnamed_addr global [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 4, !dbg !15
@ftab = local_unnamed_addr global [3 x float] [float 0x3FB99999A0000000, float 1.500000e+00, float -2.000000e+00], align 4, !dbg !20
@dvals = local_unnamed_addr global [2 x double] [double 3.141590e+00, double 1.000000e+300], align 8, !dbg !25
@ld = local_unnamed_addr global double 1.250000e+00, align 8, !dbg !31
@fp = local_unnamed_addr global ptr @classify, align 8, !dbg !34
@ext_var = external local_unnamed_addr global i32, align 4
@tls_var = thread_local local_unnamed_addr global i32 0, align 4, !dbg !44
@.str.1 = private unnamed_addr constant [10 x i8] c"%d %f %s\0A\00", align 1, !dbg !39
@switch.table.classify = private unnamed_addr constant [6 x i32] [i32 10, i32 20, i32 -1, i32 -1, i32 -1, i32 7], align 4
@switch.table.main = private unnamed_addr constant [6 x i32] [i32 13, i32 23, i32 2, i32 2, i32 2, i32 10], align 4

; Function Attrs: nofree norecurse nosync nounwind ssp uwtable(sync)
define i32 @sum(i32 noundef %0, ...) local_unnamed_addr #0 !dbg !58 {
  %2 = alloca ptr, align 8
    #dbg_value(i32 %0, !62, !DIExpression(), !71)
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %2) #11, !dbg !72
    #dbg_value(ptr %2, !63, !DIExpression(DW_OP_deref), !71)
  call void @llvm.va_start.p0(ptr nonnull %2), !dbg !73
    #dbg_value(i32 0, !68, !DIExpression(), !71)
    #dbg_value(i32 0, !69, !DIExpression(), !74)
  %3 = icmp sgt i32 %0, 0, !dbg !75
  br i1 %3, label %6, label %4, !dbg !77

4:                                                ; preds = %6, %1
  %5 = phi i32 [ 0, %1 ], [ %10, %6 ], !dbg !78
    #dbg_value(ptr %2, !63, !DIExpression(DW_OP_deref), !71)
  call void @llvm.va_end.p0(ptr %2), !dbg !79
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %2) #11, !dbg !80
  ret i32 %5, !dbg !81

6:                                                ; preds = %1, %6
  %7 = phi i32 [ %10, %6 ], [ 0, %1 ]
  %8 = phi i32 [ %11, %6 ], [ 0, %1 ]
    #dbg_value(i32 %7, !68, !DIExpression(), !71)
    #dbg_value(i32 %8, !69, !DIExpression(), !74)
  %9 = va_arg ptr %2, i32, !dbg !82
  %10 = add nsw i32 %9, %7, !dbg !83
    #dbg_value(i32 %10, !68, !DIExpression(), !71)
  %11 = add nuw nsw i32 %8, 1, !dbg !84
    #dbg_value(i32 %11, !69, !DIExpression(), !74)
  %12 = icmp eq i32 %11, %0, !dbg !75
  br i1 %12, label %4, label %6, !dbg !77, !llvm.loop !85
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.va_start.p0(ptr) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.va_end.p0(ptr) #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define range(i32 -1, 21) i32 @classify(i32 noundef %0) #3 !dbg !89 {
    #dbg_value(i32 %0, !91, !DIExpression(), !92)
  %2 = icmp ult i32 %0, 6, !dbg !93
  br i1 %2, label %3, label %7, !dbg !93

3:                                                ; preds = %1
  %4 = zext nneg i32 %0 to i64, !dbg !93
  %5 = getelementptr inbounds nuw [6 x i32], ptr @switch.table.classify, i64 0, i64 %4, !dbg !93
  %6 = load i32, ptr %5, align 4, !dbg !93
  br label %7, !dbg !93

7:                                                ; preds = %1, %3
  %8 = phi i32 [ %6, %3 ], [ -1, %1 ], !dbg !94
  ret i32 %8, !dbg !96
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: read) uwtable(sync)
define double @dot(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #4 !dbg !97 {
    #dbg_value(ptr %0, !110, !DIExpression(), !112)
    #dbg_value(ptr %1, !111, !DIExpression(), !112)
  %3 = load i32, ptr %0, align 8, !dbg !113, !tbaa !114
  %4 = load i32, ptr %1, align 8, !dbg !120, !tbaa !114
  %5 = mul nsw i32 %4, %3, !dbg !121
  %6 = sitofp i32 %5 to double, !dbg !122
  %7 = getelementptr inbounds nuw i8, ptr %0, i64 8, !dbg !123
  %8 = load double, ptr %7, align 8, !dbg !123, !tbaa !124
  %9 = getelementptr inbounds nuw i8, ptr %1, i64 8, !dbg !125
  %10 = load double, ptr %9, align 8, !dbg !125, !tbaa !124
  %11 = tail call double @llvm.fmuladd.f64(double %8, double %10, double %6), !dbg !126
  ret double %11, !dbg !127
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define i64 @mix(i64 noundef %0, i32 noundef %1, i16 noundef signext %2, i8 noundef zeroext %3) local_unnamed_addr #3 !dbg !128 {
    #dbg_value(i64 %0, !135, !DIExpression(), !139)
    #dbg_value(i32 %1, !136, !DIExpression(), !139)
    #dbg_value(i16 %2, !137, !DIExpression(), !139)
    #dbg_value(i8 %3, !138, !DIExpression(), !139)
  %5 = lshr i64 %0, 3, !dbg !140
  %6 = shl i32 %1, 2, !dbg !141
  %7 = zext i32 %6 to i64, !dbg !142
  %8 = xor i64 %5, %7, !dbg !143
  %9 = sext i16 %2 to i64, !dbg !144
  %10 = zext i8 %3 to i64, !dbg !145
  %11 = mul nsw i64 %10, %9, !dbg !146
  %12 = urem i64 %11, 7, !dbg !147
  %13 = or i32 %1, 1, !dbg !148
  %14 = zext i32 %13 to i64, !dbg !149
  %15 = udiv i64 %0, %14, !dbg !150
  %16 = add i64 %15, %12, !dbg !151
  %17 = xor i64 %8, %16, !dbg !152
  ret i64 %17, !dbg !153
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define float @fmaths(float noundef %0, float noundef %1) local_unnamed_addr #3 !dbg !154 {
    #dbg_value(float %0, !158, !DIExpression(), !160)
    #dbg_value(float %1, !159, !DIExpression(), !160)
  %3 = fdiv float %0, %1, !dbg !161
  %4 = fneg float %0, !dbg !162
  %5 = tail call float @llvm.fmuladd.f32(float %4, float 2.500000e+00, float %3), !dbg !162
  %6 = fptosi float %1 to i32, !dbg !163
  %7 = sitofp i32 %6 to float, !dbg !164
  %8 = fadd float %5, %7, !dbg !165
  ret float %8, !dbg !166
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #5

; Function Attrs: nofree norecurse nounwind ssp memory(argmem: readwrite) uwtable(sync)
define void @copy(ptr noundef initializes((0, 24)) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #6 !dbg !167 {
    #dbg_value(ptr %0, !173, !DIExpression(), !175)
    #dbg_value(ptr %1, !174, !DIExpression(), !175)
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1, i64 24, i1 false), !dbg !176, !tbaa.struct !177
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 16, !dbg !181
  store i64 0, ptr %3, align 1, !dbg !181
  ret void, !dbg !182
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #7

; Function Attrs: nofree norecurse nosync nounwind ssp memory(read, inaccessiblemem: none) uwtable(sync)
define i32 @loop(ptr noundef readonly captures(none) %0, i32 noundef %1) local_unnamed_addr #8 !dbg !183 {
    #dbg_value(ptr %0, !188, !DIExpression(), !193)
    #dbg_value(i32 %1, !189, !DIExpression(), !193)
    #dbg_value(i32 0, !190, !DIExpression(), !193)
    #dbg_value(i32 0, !191, !DIExpression(), !194)
  %3 = icmp sgt i32 %1, 0, !dbg !195
  br i1 %3, label %4, label %6, !dbg !197

4:                                                ; preds = %2
  %5 = zext nneg i32 %1 to i64, !dbg !195
  br label %14, !dbg !197

6:                                                ; preds = %14, %2
  %7 = phi i32 [ 0, %2 ], [ %24, %14 ], !dbg !198
  %8 = icmp eq i32 %7, 0, !dbg !199
  %9 = load i32, ptr @ext_var, align 4, !dbg !199
  %10 = tail call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tls_var), !dbg !199
  %11 = load i32, ptr %10, align 4, !dbg !199
  %12 = add nsw i32 %11, %9, !dbg !199
  %13 = select i1 %8, i32 %12, i32 %7, !dbg !199
  ret i32 %13, !dbg !200

14:                                               ; preds = %4, %14
  %15 = phi i64 [ 0, %4 ], [ %25, %14 ]
  %16 = phi i32 [ 0, %4 ], [ %24, %14 ]
    #dbg_value(i64 %15, !191, !DIExpression(), !194)
    #dbg_value(i32 %16, !190, !DIExpression(), !193)
  %17 = getelementptr inbounds nuw i32, ptr %0, i64 %15, !dbg !201
  %18 = load i32, ptr %17, align 4, !dbg !201, !tbaa !178
  %19 = icmp sgt i32 %18, %16, !dbg !203
  %20 = sub nsw i32 0, %16, !dbg !203
  %21 = icmp slt i32 %18, %20, !dbg !203
  %22 = sub nsw i32 0, %18, !dbg !203
  %23 = select i1 %21, i32 %22, i32 %16, !dbg !203
  %24 = select i1 %19, i32 %18, i32 %23, !dbg !203
    #dbg_value(i32 %24, !190, !DIExpression(), !193)
  %25 = add nuw nsw i64 %15, 1, !dbg !204
    #dbg_value(i64 %25, !191, !DIExpression(), !194)
  %26 = icmp eq i64 %25, %5, !dbg !195
  br i1 %26, label %6, label %14, !dbg !197, !llvm.loop !205
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull) #5

; Function Attrs: nounwind ssp uwtable(sync)
define range(i32 -2147483646, -2147483648) i32 @main(i32 noundef %0, ptr noundef readnone captures(none) %1) local_unnamed_addr #9 !dbg !207 {
    #dbg_value(i32 %0, !212, !DIExpression(), !215)
    #dbg_value(ptr %1, !213, !DIExpression(), !215)
    #dbg_value(i32 1, !214, !DIExpression(DW_OP_LLVM_fragment, 0, 32), !215)
    #dbg_value(i32 poison, !214, !DIExpression(DW_OP_LLVM_fragment, 32, 32), !215)
    #dbg_value(double 2.000000e+00, !214, !DIExpression(DW_OP_LLVM_fragment, 64, 64), !215)
    #dbg_value(i64 poison, !214, !DIExpression(DW_OP_LLVM_fragment, 128, 64), !215)
  %3 = tail call i32 (i32, ...) @sum(i32 noundef 3, i32 noundef 1, i32 noundef 2, i32 noundef 3), !dbg !216
  %4 = load ptr, ptr @msg, align 8, !dbg !217, !tbaa !218
  %5 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %3, double noundef 5.000000e+00, ptr noundef %4), !dbg !221
    #dbg_value(i32 %0, !91, !DIExpression(), !222)
  %6 = icmp ult i32 %0, 6, !dbg !224
  br i1 %6, label %7, label %11, !dbg !224

7:                                                ; preds = %2
  %8 = zext nneg i32 %0 to i64, !dbg !224
  %9 = getelementptr inbounds nuw [6 x i32], ptr @switch.table.main, i64 0, i64 %8, !dbg !224
  %10 = load i32, ptr %9, align 4, !dbg !224
  br label %11, !dbg !224

11:                                               ; preds = %2, %7
  %12 = phi i32 [ %10, %7 ], [ 2, %2 ], !dbg !225
  %13 = load ptr, ptr @fp, align 8, !dbg !226, !tbaa !227
  %14 = tail call i32 %13(i32 noundef 1) #11, !dbg !226
  %15 = add nsw i32 %14, %12, !dbg !228
  ret i32 %15, !dbg !229
}

; Function Attrs: nofree nounwind
declare !dbg !230 noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #10

attributes #0 = { nofree norecurse nosync nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn }
attributes #3 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: read) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { nofree norecurse nounwind ssp memory(argmem: readwrite) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #7 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { nofree norecurse nosync nounwind ssp memory(read, inaccessiblemem: none) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #10 = { nofree nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #11 = { nounwind }

!llvm.module.flags = !{!50, !51, !52, !53, !54, !55, !56}
!llvm.dbg.cu = !{!9}
!llvm.ident = !{!57}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 7, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "basic.c", directory: "/corpus", checksumkind: CSK_MD5, checksum: "9397bb2eef8bba56d2c05dd4771e9155")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 120, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 15)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(name: "msg", scope: !9, file: !2, line: 7, type: !48, isLocal: false, isDefinition: true)
!9 = distinct !DICompileUnit(language: DW_LANG_C11, file: !2, producer: "Apple clang version 21.0.0 (clang-2100.3.34.2)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !10, globals: !14, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!10 = !{!11, !12, !13}
!11 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!12 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !{!0, !7, !15, !20, !25, !31, !34, !39, !44, !46}
!15 = !DIGlobalVariableExpression(var: !16, expr: !DIExpression())
!16 = distinct !DIGlobalVariable(name: "table", scope: !9, file: !2, line: 8, type: !17, isLocal: false, isDefinition: true)
!17 = !DICompositeType(tag: DW_TAG_array_type, baseType: !13, size: 128, elements: !18)
!18 = !{!19}
!19 = !DISubrange(count: 4)
!20 = !DIGlobalVariableExpression(var: !21, expr: !DIExpression())
!21 = distinct !DIGlobalVariable(name: "ftab", scope: !9, file: !2, line: 9, type: !22, isLocal: false, isDefinition: true)
!22 = !DICompositeType(tag: DW_TAG_array_type, baseType: !12, size: 96, elements: !23)
!23 = !{!24}
!24 = !DISubrange(count: 3)
!25 = !DIGlobalVariableExpression(var: !26, expr: !DIExpression())
!26 = distinct !DIGlobalVariable(name: "dvals", scope: !9, file: !2, line: 10, type: !27, isLocal: false, isDefinition: true)
!27 = !DICompositeType(tag: DW_TAG_array_type, baseType: !28, size: 128, elements: !29)
!28 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!29 = !{!30}
!30 = !DISubrange(count: 2)
!31 = !DIGlobalVariableExpression(var: !32, expr: !DIExpression())
!32 = distinct !DIGlobalVariable(name: "ld", scope: !9, file: !2, line: 11, type: !33, isLocal: false, isDefinition: true)
!33 = !DIBasicType(name: "long double", size: 64, encoding: DW_ATE_float)
!34 = !DIGlobalVariableExpression(var: !35, expr: !DIExpression())
!35 = distinct !DIGlobalVariable(name: "fp", scope: !9, file: !2, line: 18, type: !36, isLocal: false, isDefinition: true)
!36 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !37, size: 64)
!37 = !DISubroutineType(types: !38)
!38 = !{!13, !13}
!39 = !DIGlobalVariableExpression(var: !40, expr: !DIExpression())
!40 = distinct !DIGlobalVariable(scope: null, file: !2, line: 22, type: !41, isLocal: true, isDefinition: true)
!41 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 80, elements: !42)
!42 = !{!43}
!43 = !DISubrange(count: 10)
!44 = !DIGlobalVariableExpression(var: !45, expr: !DIExpression())
!45 = distinct !DIGlobalVariable(name: "tls_var", scope: !9, file: !2, line: 12, type: !13, isLocal: false, isDefinition: true)
!46 = !DIGlobalVariableExpression(var: !47, expr: !DIExpression(DW_OP_constu, 3, DW_OP_stack_value))
!47 = distinct !DIGlobalVariable(name: "counter", scope: !9, file: !2, line: 6, type: !13, isLocal: true, isDefinition: true)
!48 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !49, size: 64)
!49 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4)
!50 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!51 = !{i32 7, !"Dwarf Version", i32 5}
!52 = !{i32 2, !"Debug Info Version", i32 3}
!53 = !{i32 1, !"wchar_size", i32 4}
!54 = !{i32 8, !"PIC Level", i32 2}
!55 = !{i32 7, !"uwtable", i32 1}
!56 = !{i32 7, !"frame-pointer", i32 1}
!57 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!58 = distinct !DISubprogram(name: "sum", scope: !2, file: !2, line: 14, type: !59, scopeLine: 14, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !61)
!59 = !DISubroutineType(types: !60)
!60 = !{!13, !13, null}
!61 = !{!62, !63, !68, !69}
!62 = !DILocalVariable(name: "n", arg: 1, scope: !58, file: !2, line: 14, type: !13)
!63 = !DILocalVariable(name: "ap", scope: !58, file: !2, line: 14, type: !64)
!64 = !DIDerivedType(tag: DW_TAG_typedef, name: "va_list", file: !65, line: 12, baseType: !66)
!65 = !DIFile(filename: "/Library/Developer/CommandLineTools/usr/lib/clang/21/include/__stdarg_va_list.h", directory: "", checksumkind: CSK_MD5, checksum: "7bd78a282b99fcfe41a9e3c566d14f7d")
!66 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !2, baseType: !67)
!67 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64)
!68 = !DILocalVariable(name: "s", scope: !58, file: !2, line: 14, type: !13)
!69 = !DILocalVariable(name: "i", scope: !70, file: !2, line: 14, type: !13)
!70 = distinct !DILexicalBlock(scope: !58, file: !2, line: 14, column: 63)
!71 = !DILocation(line: 0, scope: !58)
!72 = !DILocation(line: 14, column: 23, scope: !58)
!73 = !DILocation(line: 14, column: 35, scope: !58)
!74 = !DILocation(line: 0, scope: !70)
!75 = !DILocation(line: 14, column: 81, scope: !76)
!76 = distinct !DILexicalBlock(scope: !70, file: !2, line: 14, column: 63)
!77 = !DILocation(line: 14, column: 63, scope: !70)
!78 = !DILocation(line: 14, scope: !58)
!79 = !DILocation(line: 14, column: 113, scope: !58)
!80 = !DILocation(line: 14, column: 135, scope: !58)
!81 = !DILocation(line: 14, column: 125, scope: !58)
!82 = !DILocation(line: 14, column: 96, scope: !76)
!83 = !DILocation(line: 14, column: 93, scope: !76)
!84 = !DILocation(line: 14, column: 87, scope: !76)
!85 = distinct !{!85, !77, !86, !87, !88}
!86 = !DILocation(line: 14, column: 96, scope: !70)
!87 = !{!"llvm.loop.mustprogress"}
!88 = !{!"llvm.loop.unroll.disable"}
!89 = distinct !DISubprogram(name: "classify", scope: !2, file: !2, line: 15, type: !37, scopeLine: 15, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !90)
!90 = !{!91}
!91 = !DILocalVariable(name: "x", arg: 1, scope: !89, file: !2, line: 15, type: !13)
!92 = !DILocation(line: 0, scope: !89)
!93 = !DILocation(line: 15, column: 23, scope: !89)
!94 = !DILocation(line: 15, scope: !95)
!95 = distinct !DILexicalBlock(scope: !89, file: !2, line: 15, column: 34)
!96 = !DILocation(line: 15, column: 114, scope: !89)
!97 = distinct !DISubprogram(name: "dot", scope: !2, file: !2, line: 16, type: !98, scopeLine: 16, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !109)
!98 = !DISubroutineType(types: !99)
!99 = !{!28, !100, !100}
!100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !101, size: 64)
!101 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "point", file: !2, line: 5, size: 192, elements: !102)
!102 = !{!103, !104, !105}
!103 = !DIDerivedType(tag: DW_TAG_member, name: "x", scope: !101, file: !2, line: 5, baseType: !13, size: 32)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "y", scope: !101, file: !2, line: 5, baseType: !28, size: 64, offset: 64)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !101, file: !2, line: 5, baseType: !106, size: 64, offset: 128)
!106 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 64, elements: !107)
!107 = !{!108}
!108 = !DISubrange(count: 8)
!109 = !{!110, !111}
!110 = !DILocalVariable(name: "a", arg: 1, scope: !97, file: !2, line: 16, type: !100)
!111 = !DILocalVariable(name: "b", arg: 2, scope: !97, file: !2, line: 16, type: !100)
!112 = !DILocation(line: 0, scope: !97)
!113 = !DILocation(line: 16, column: 58, scope: !97)
!114 = !{!115, !116, i64 0}
!115 = !{!"point", !116, i64 0, !119, i64 8, !117, i64 16}
!116 = !{!"int", !117, i64 0}
!117 = !{!"omnipotent char", !118, i64 0}
!118 = !{!"Simple C/C++ TBAA"}
!119 = !{!"double", !117, i64 0}
!120 = !DILocation(line: 16, column: 65, scope: !97)
!121 = !DILocation(line: 16, column: 60, scope: !97)
!122 = !DILocation(line: 16, column: 55, scope: !97)
!123 = !DILocation(line: 16, column: 72, scope: !97)
!124 = !{!115, !119, i64 8}
!125 = !DILocation(line: 16, column: 79, scope: !97)
!126 = !DILocation(line: 16, column: 67, scope: !97)
!127 = !DILocation(line: 16, column: 48, scope: !97)
!128 = distinct !DISubprogram(name: "mix", scope: !2, file: !2, line: 17, type: !129, scopeLine: 17, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !134)
!129 = !DISubroutineType(types: !130)
!130 = !{!11, !11, !131, !132, !133}
!131 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!132 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!133 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!134 = !{!135, !136, !137, !138}
!135 = !DILocalVariable(name: "a", arg: 1, scope: !128, file: !2, line: 17, type: !11)
!136 = !DILocalVariable(name: "b", arg: 2, scope: !128, file: !2, line: 17, type: !131)
!137 = !DILocalVariable(name: "c", arg: 3, scope: !128, file: !2, line: 17, type: !132)
!138 = !DILocalVariable(name: "d", arg: 4, scope: !128, file: !2, line: 17, type: !133)
!139 = !DILocation(line: 0, scope: !128)
!140 = !DILocation(line: 17, column: 96, scope: !128)
!141 = !DILocation(line: 17, column: 107, scope: !128)
!142 = !DILocation(line: 17, column: 104, scope: !128)
!143 = !DILocation(line: 17, column: 102, scope: !128)
!144 = !DILocation(line: 17, column: 115, scope: !128)
!145 = !DILocation(line: 17, column: 139, scope: !128)
!146 = !DILocation(line: 17, column: 137, scope: !128)
!147 = !DILocation(line: 17, column: 141, scope: !128)
!148 = !DILocation(line: 17, column: 153, scope: !128)
!149 = !DILocation(line: 17, column: 151, scope: !128)
!150 = !DILocation(line: 17, column: 149, scope: !128)
!151 = !DILocation(line: 17, column: 145, scope: !128)
!152 = !DILocation(line: 17, column: 113, scope: !128)
!153 = !DILocation(line: 17, column: 86, scope: !128)
!154 = distinct !DISubprogram(name: "fmaths", scope: !2, file: !2, line: 19, type: !155, scopeLine: 19, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !157)
!155 = !DISubroutineType(types: !156)
!156 = !{!12, !12, !12}
!157 = !{!158, !159}
!158 = !DILocalVariable(name: "a", arg: 1, scope: !154, file: !2, line: 19, type: !12)
!159 = !DILocalVariable(name: "b", arg: 2, scope: !154, file: !2, line: 19, type: !12)
!160 = !DILocation(line: 0, scope: !154)
!161 = !DILocation(line: 19, column: 43, scope: !154)
!162 = !DILocation(line: 19, column: 47, scope: !154)
!163 = !DILocation(line: 19, column: 69, scope: !154)
!164 = !DILocation(line: 19, column: 62, scope: !154)
!165 = !DILocation(line: 19, column: 60, scope: !154)
!166 = !DILocation(line: 19, column: 34, scope: !154)
!167 = distinct !DISubprogram(name: "copy", scope: !2, file: !2, line: 20, type: !168, scopeLine: 20, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !172)
!168 = !DISubroutineType(types: !169)
!169 = !{null, !100, !170}
!170 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !171, size: 64)
!171 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !101)
!172 = !{!173, !174}
!173 = !DILocalVariable(name: "dst", arg: 1, scope: !167, file: !2, line: 20, type: !100)
!174 = !DILocalVariable(name: "src", arg: 2, scope: !167, file: !2, line: 20, type: !170)
!175 = !DILocation(line: 0, scope: !167)
!176 = !DILocation(line: 20, column: 64, scope: !167)
!177 = !{i64 0, i64 4, !178, i64 8, i64 8, !179, i64 16, i64 8, !180}
!178 = !{!116, !116, i64 0}
!179 = !{!119, !119, i64 0}
!180 = !{!117, !117, i64 0}
!181 = !DILocation(line: 20, column: 70, scope: !167)
!182 = !DILocation(line: 20, column: 95, scope: !167)
!183 = distinct !DISubprogram(name: "loop", scope: !2, file: !2, line: 21, type: !184, scopeLine: 21, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !187)
!184 = !DISubroutineType(types: !185)
!185 = !{!13, !186, !13}
!186 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!187 = !{!188, !189, !190, !191}
!188 = !DILocalVariable(name: "a", arg: 1, scope: !183, file: !2, line: 21, type: !186)
!189 = !DILocalVariable(name: "n", arg: 2, scope: !183, file: !2, line: 21, type: !13)
!190 = !DILocalVariable(name: "m", scope: !183, file: !2, line: 21, type: !13)
!191 = !DILocalVariable(name: "i", scope: !192, file: !2, line: 21, type: !13)
!192 = distinct !DILexicalBlock(scope: !183, file: !2, line: 21, column: 38)
!193 = !DILocation(line: 0, scope: !183)
!194 = !DILocation(line: 0, scope: !192)
!195 = !DILocation(line: 21, column: 56, scope: !196)
!196 = distinct !DILexicalBlock(scope: !192, file: !2, line: 21, column: 38)
!197 = !DILocation(line: 21, column: 38, scope: !192)
!198 = !DILocation(line: 21, scope: !183)
!199 = !DILocation(line: 21, column: 128, scope: !183)
!200 = !DILocation(line: 21, column: 121, scope: !183)
!201 = !DILocation(line: 21, column: 70, scope: !202)
!202 = distinct !DILexicalBlock(scope: !196, file: !2, line: 21, column: 70)
!203 = !DILocation(line: 21, column: 75, scope: !202)
!204 = !DILocation(line: 21, column: 61, scope: !196)
!205 = distinct !{!205, !197, !206, !87, !88}
!206 = !DILocation(line: 21, column: 118, scope: !192)
!207 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 22, type: !208, scopeLine: 22, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !9, retainedNodes: !211)
!208 = !DISubroutineType(types: !209)
!209 = !{!13, !13, !210}
!210 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !67, size: 64)
!211 = !{!212, !213, !214}
!212 = !DILocalVariable(name: "argc", arg: 1, scope: !207, file: !2, line: 22, type: !13)
!213 = !DILocalVariable(name: "argv", arg: 2, scope: !207, file: !2, line: 22, type: !210)
!214 = !DILocalVariable(name: "p", scope: !207, file: !2, line: 22, type: !101)
!215 = !DILocation(line: 0, scope: !207)
!216 = !DILocation(line: 22, column: 89, scope: !207)
!217 = !DILocation(line: 22, column: 119, scope: !207)
!218 = !{!219, !219, i64 0}
!219 = !{!"p1 omnipotent char", !220, i64 0}
!220 = !{!"any pointer", !117, i64 0}
!221 = !DILocation(line: 22, column: 68, scope: !207)
!222 = !DILocation(line: 0, scope: !89, inlinedAt: !223)
!223 = distinct !DILocation(line: 22, column: 132, scope: !207)
!224 = !DILocation(line: 15, column: 23, scope: !89, inlinedAt: !223)
!225 = !DILocation(line: 15, scope: !95, inlinedAt: !223)
!226 = !DILocation(line: 22, column: 159, scope: !207)
!227 = !{!220, !220, i64 0}
!228 = !DILocation(line: 22, column: 157, scope: !207)
!229 = !DILocation(line: 22, column: 125, scope: !207)
!230 = !DISubprogram(name: "printf", scope: !231, file: !231, line: 34, type: !232, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!231 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/_printf.h", directory: "", checksumkind: CSK_MD5, checksum: "2d37517bd0342aa326aa1d3660ad4ab4")
!232 = !DISubroutineType(types: !233)
!233 = !{!13, !234, null}
!234 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !48)
