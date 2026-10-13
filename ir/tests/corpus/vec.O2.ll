; ModuleID = 'vec.c'
source_filename = "vec.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define noundef <4 x float> @vadd(<4 x float> noundef %0, <4 x float> noundef %1) local_unnamed_addr #0 {
  %3 = tail call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %1, <4 x float> splat (float 2.000000e+00), <4 x float> %0)
  ret <4 x float> %3
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define noundef <4 x i32> @vshuf(<4 x i32> noundef %0, <4 x i32> noundef %1) local_unnamed_addr #0 {
  %3 = shufflevector <4 x i32> %0, <4 x i32> %1, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x i32> %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define noundef float @vsum(<4 x float> noundef %0) local_unnamed_addr #0 {
  %2 = shufflevector <4 x float> %0, <4 x float> poison, <4 x i32> <i32 1, i32 poison, i32 poison, i32 poison>
  %3 = fadd <4 x float> %0, %2
  %4 = shufflevector <4 x float> %0, <4 x float> poison, <4 x i32> <i32 2, i32 poison, i32 poison, i32 poison>
  %5 = fadd <4 x float> %4, %3
  %6 = shufflevector <4 x float> %0, <4 x float> poison, <4 x i32> <i32 3, i32 poison, i32 poison, i32 poison>
  %7 = fadd <4 x float> %6, %5
  %8 = extractelement <4 x float> %7, i64 0
  ret float %8
}

; Function Attrs: mustprogress nofree norecurse nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define i32 @atom(ptr noundef captures(none) %0) local_unnamed_addr #2 {
  %2 = atomicrmw add ptr %0, i32 1 seq_cst, align 4
  %3 = cmpxchg ptr %0, i32 0, i32 5 acq_rel acquire, align 4
  %4 = load atomic i32, ptr %0 acquire, align 4
  ret i32 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: write) uwtable(sync)
define noundef zeroext i1 @overflow(i32 noundef %0, i32 noundef %1, ptr noundef writeonly captures(none) initializes((0, 4)) %2) local_unnamed_addr #3 {
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %1)
  %5 = extractvalue { i32, i1 } %4, 1
  %6 = extractvalue { i32, i1 } %4, 0
  store i32 %6, ptr %2, align 4
  ret i1 %5
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define range(i32 0, 67) i32 @bits(i32 noundef %0) local_unnamed_addr #0 {
  %2 = tail call range(i32 0, 33) i32 @llvm.ctpop.i32(i32 %0)
  %3 = or i32 %0, 1
  %4 = tail call range(i32 0, 32) i32 @llvm.ctlz.i32(i32 %3, i1 true)
  %5 = add nuw nsw i32 %4, %2
  %6 = or i32 %0, 8
  %7 = tail call range(i32 0, 4) i32 @llvm.cttz.i32(i32 %6, i1 true)
  %8 = add nuw nsw i32 %5, %7
  ret i32 %8
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctpop.i32(i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctlz.i32(i32, i1 immarg) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.cttz.i32(i32, i1 immarg) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define range(i128 -170141183460469231719341624814649537838, -170141183460469231731687303715884105728) i128 @big(i128 noundef %0) local_unnamed_addr #0 {
  %2 = shl nsw i128 %0, 100
  %3 = or disjoint i128 %2, 12345678901234567890
  ret i128 %3
}

; Function Attrs: nounwind ssp uwtable(sync)
define { double, double } @cmul([2 x double] noundef %0, [2 x double] noundef %1) local_unnamed_addr #4 {
  %3 = extractvalue [2 x double] %0, 0
  %4 = extractvalue [2 x double] %0, 1
  %5 = extractvalue [2 x double] %1, 0
  %6 = extractvalue [2 x double] %1, 1
  %7 = fmul double %3, %5
  %8 = fmul double %4, %6
  %9 = fmul double %3, %6
  %10 = fmul double %4, %5
  %11 = fsub double %7, %8
  %12 = fadd double %9, %10
  %13 = fcmp uno double %11, 0.000000e+00
  br i1 %13, label %14, label %20, !prof !6

14:                                               ; preds = %2
  %15 = fcmp uno double %12, 0.000000e+00
  br i1 %15, label %16, label %20, !prof !6

16:                                               ; preds = %14
  %17 = tail call { double, double } @__muldc3(double noundef %3, double noundef %4, double noundef %5, double noundef %6) #5
  %18 = extractvalue { double, double } %17, 0
  %19 = extractvalue { double, double } %17, 1
  br label %20

20:                                               ; preds = %16, %14, %2
  %21 = phi double [ %11, %2 ], [ %11, %14 ], [ %18, %16 ]
  %22 = phi double [ %12, %2 ], [ %12, %14 ], [ %19, %16 ]
  %23 = insertvalue { double, double } poison, double %21, 0
  %24 = insertvalue { double, double } %23, double %22, 1
  ret { double, double } %24
}

declare { double, double } @__muldc3(double, double, double, double) local_unnamed_addr

attributes #0 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { mustprogress nofree norecurse nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: write) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!6 = !{!"branch_weights", i32 1, i32 1048575}
