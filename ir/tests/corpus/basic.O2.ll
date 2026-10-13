; ModuleID = 'basic.c'
source_filename = "basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@.str = private unnamed_addr constant [15 x i8] c"hello \22world\22\0A\00", align 1
@msg = local_unnamed_addr global ptr @.str, align 8
@table = local_unnamed_addr global [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 4
@ftab = local_unnamed_addr global [3 x float] [float 0x3FB99999A0000000, float 1.500000e+00, float -2.000000e+00], align 4
@dvals = local_unnamed_addr global [2 x double] [double 3.141590e+00, double 1.000000e+300], align 8
@ld = local_unnamed_addr global double 1.250000e+00, align 8
@fp = local_unnamed_addr global ptr @classify, align 8
@ext_var = external local_unnamed_addr global i32, align 4
@tls_var = thread_local local_unnamed_addr global i32 0, align 4
@.str.1 = private unnamed_addr constant [10 x i8] c"%d %f %s\0A\00", align 1
@switch.table.classify = private unnamed_addr constant [6 x i32] [i32 10, i32 20, i32 -1, i32 -1, i32 -1, i32 7], align 4
@switch.table.main = private unnamed_addr constant [6 x i32] [i32 13, i32 23, i32 2, i32 2, i32 2, i32 10], align 4

; Function Attrs: nofree norecurse nosync nounwind ssp uwtable(sync)
define i32 @sum(i32 noundef %0, ...) local_unnamed_addr #0 {
  %2 = alloca ptr, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %2) #11
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = icmp sgt i32 %0, 0
  br i1 %3, label %6, label %4

4:                                                ; preds = %6, %1
  %5 = phi i32 [ 0, %1 ], [ %10, %6 ]
  call void @llvm.va_end.p0(ptr nonnull %2)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %2) #11
  ret i32 %5

6:                                                ; preds = %1, %6
  %7 = phi i32 [ %10, %6 ], [ 0, %1 ]
  %8 = phi i32 [ %11, %6 ], [ 0, %1 ]
  %9 = va_arg ptr %2, i32
  %10 = add nsw i32 %9, %7
  %11 = add nuw nsw i32 %8, 1
  %12 = icmp eq i32 %11, %0
  br i1 %12, label %4, label %6, !llvm.loop !6
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
define range(i32 -1, 21) i32 @classify(i32 noundef %0) #3 {
  %2 = icmp ult i32 %0, 6
  br i1 %2, label %3, label %7

3:                                                ; preds = %1
  %4 = zext nneg i32 %0 to i64
  %5 = getelementptr inbounds nuw [6 x i32], ptr @switch.table.classify, i64 0, i64 %4
  %6 = load i32, ptr %5, align 4
  br label %7

7:                                                ; preds = %1, %3
  %8 = phi i32 [ %6, %3 ], [ -1, %1 ]
  ret i32 %8
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: read) uwtable(sync)
define double @dot(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #4 {
  %3 = load i32, ptr %0, align 8, !tbaa !8
  %4 = load i32, ptr %1, align 8, !tbaa !8
  %5 = mul nsw i32 %4, %3
  %6 = sitofp i32 %5 to double
  %7 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %8 = load double, ptr %7, align 8, !tbaa !14
  %9 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %10 = load double, ptr %9, align 8, !tbaa !14
  %11 = tail call double @llvm.fmuladd.f64(double %8, double %10, double %6)
  ret double %11
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define i64 @mix(i64 noundef %0, i32 noundef %1, i16 noundef signext %2, i8 noundef zeroext %3) local_unnamed_addr #3 {
  %5 = lshr i64 %0, 3
  %6 = shl i32 %1, 2
  %7 = zext i32 %6 to i64
  %8 = xor i64 %5, %7
  %9 = sext i16 %2 to i64
  %10 = zext i8 %3 to i64
  %11 = mul nsw i64 %10, %9
  %12 = urem i64 %11, 7
  %13 = or i32 %1, 1
  %14 = zext i32 %13 to i64
  %15 = udiv i64 %0, %14
  %16 = add i64 %15, %12
  %17 = xor i64 %8, %16
  ret i64 %17
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define float @fmaths(float noundef %0, float noundef %1) local_unnamed_addr #3 {
  %3 = fdiv float %0, %1
  %4 = fneg float %0
  %5 = tail call float @llvm.fmuladd.f32(float %4, float 2.500000e+00, float %3)
  %6 = fptosi float %1 to i32
  %7 = sitofp i32 %6 to float
  %8 = fadd float %5, %7
  ret float %8
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #5

; Function Attrs: nofree norecurse nounwind ssp memory(argmem: readwrite) uwtable(sync)
define void @copy(ptr noundef initializes((0, 16)) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #6 {
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1, i64 16, i1 false), !tbaa.struct !15
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 0, ptr %3, align 1
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #7

; Function Attrs: nofree norecurse nosync nounwind ssp memory(read, inaccessiblemem: none) uwtable(sync)
define i32 @loop(ptr noundef readonly captures(none) %0, i32 noundef %1) local_unnamed_addr #8 {
  %3 = icmp sgt i32 %1, 0
  br i1 %3, label %9, label %4

4:                                                ; preds = %2
  %5 = load i32, ptr @ext_var, align 4
  %6 = tail call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tls_var)
  %7 = load i32, ptr %6, align 4
  %8 = add nsw i32 %7, %5
  br label %18

9:                                                ; preds = %2
  %10 = zext nneg i32 %1 to i64
  br label %20

11:                                               ; preds = %20
  %12 = icmp eq i32 %31, 0
  %13 = load i32, ptr @ext_var, align 4
  %14 = tail call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tls_var)
  %15 = load i32, ptr %14, align 4
  %16 = add nsw i32 %15, %13
  %17 = select i1 %12, i32 %16, i32 %31
  br label %18

18:                                               ; preds = %11, %4
  %19 = phi i32 [ %8, %4 ], [ %17, %11 ]
  ret i32 %19

20:                                               ; preds = %9, %20
  %21 = phi i64 [ 0, %9 ], [ %32, %20 ]
  %22 = phi i32 [ 0, %9 ], [ %31, %20 ]
  %23 = getelementptr inbounds nuw i32, ptr %0, i64 %21
  %24 = load i32, ptr %23, align 4, !tbaa !16
  %25 = icmp sgt i32 %24, %22
  %26 = sub nsw i32 0, %22
  %27 = icmp slt i32 %24, %26
  %28 = sub nsw i32 0, %24
  %29 = select i1 %27, i32 %28, i32 %22
  %30 = select i1 %25, i32 %24, i32 %29
  %31 = freeze i32 %30
  %32 = add nuw nsw i64 %21, 1
  %33 = icmp eq i64 %32, %10
  br i1 %33, label %11, label %20, !llvm.loop !19
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull) #5

; Function Attrs: nounwind ssp uwtable(sync)
define range(i32 -2147483646, -2147483648) i32 @main(i32 noundef %0, ptr noundef readnone captures(none) %1) local_unnamed_addr #9 {
  %3 = tail call i32 (i32, ...) @sum(i32 noundef 3, i32 noundef 1, i32 noundef 2, i32 noundef 3)
  %4 = load ptr, ptr @msg, align 8, !tbaa !20
  %5 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %3, double noundef 5.000000e+00, ptr noundef %4)
  %6 = icmp ult i32 %0, 6
  br i1 %6, label %7, label %11

7:                                                ; preds = %2
  %8 = zext nneg i32 %0 to i64
  %9 = getelementptr inbounds nuw [6 x i32], ptr @switch.table.main, i64 0, i64 %8
  %10 = load i32, ptr %9, align 4
  br label %11

11:                                               ; preds = %2, %7
  %12 = phi i32 [ %10, %7 ], [ 2, %2 ]
  %13 = load ptr, ptr @fp, align 8, !tbaa !23
  %14 = tail call i32 %13(i32 noundef 1) #11
  %15 = add nsw i32 %14, %12
  ret i32 %15
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #10

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

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = !{!9, !10, i64 0}
!9 = !{!"point", !10, i64 0, !13, i64 8, !11, i64 16}
!10 = !{!"int", !11, i64 0}
!11 = !{!"omnipotent char", !12, i64 0}
!12 = !{!"Simple C/C++ TBAA"}
!13 = !{!"double", !11, i64 0}
!14 = !{!9, !13, i64 8}
!15 = !{i64 0, i64 4, !16, i64 8, i64 8, !17, i64 16, i64 8, !18}
!16 = !{!10, !10, i64 0}
!17 = !{!13, !13, i64 0}
!18 = !{!11, !11, i64 0}
!19 = distinct !{!19, !7}
!20 = !{!21, !21, i64 0}
!21 = !{!"p1 omnipotent char", !22, i64 0}
!22 = !{!"any pointer", !11, i64 0}
!23 = !{!22, !22, i64 0}
