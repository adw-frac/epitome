; NEON's shifting narrowings, saturating and rounding (clang -O2 of C
; using arm_neon.h), at their edges.
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @shifts(ptr noundef writeonly captures(none) initializes((0, 8)) %0, ptr noundef writeonly captures(none) initializes((0, 8)) %1, ptr noundef writeonly captures(none) initializes((0, 8)) %2, ptr noundef writeonly captures(none) initializes((0, 8)) %3, ptr noundef writeonly captures(none) initializes((0, 8)) %4, ptr noundef writeonly captures(none) initializes((0, 8)) %5, ptr noundef readonly captures(none) %6, ptr noundef readonly captures(none) %7) local_unnamed_addr #0 {
  %9 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %10 = tail call <4 x i16> @llvm.aarch64.neon.sqshrn.v4i16(<4 x i32> %9, i32 3)
  store <4 x i16> %10, ptr %0, align 8, !tbaa !6
  %11 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %12 = tail call <4 x i16> @llvm.aarch64.neon.sqshrun.v4i16(<4 x i32> %11, i32 5)
  store <4 x i16> %12, ptr %1, align 8, !tbaa !6
  %13 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %14 = tail call <4 x i16> @llvm.aarch64.neon.sqrshrn.v4i16(<4 x i32> %13, i32 4)
  store <4 x i16> %14, ptr %2, align 8, !tbaa !6
  %15 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %16 = tail call <4 x i16> @llvm.aarch64.neon.sqrshrun.v4i16(<4 x i32> %15, i32 2)
  store <4 x i16> %16, ptr %3, align 8, !tbaa !6
  %17 = load <4 x i32>, ptr %7, align 16, !tbaa !6
  %18 = tail call <4 x i16> @llvm.aarch64.neon.uqshrn.v4i16(<4 x i32> %17, i32 7)
  store <4 x i16> %18, ptr %4, align 8, !tbaa !6
  %19 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %20 = tail call <4 x i16> @llvm.aarch64.neon.rshrn.v4i16(<4 x i32> %19, i32 9)
  store <4 x i16> %20, ptr %5, align 8, !tbaa !6
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.sqshrn.v4i16(<4 x i32>, i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.sqshrun.v4i16(<4 x i32>, i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.sqrshrn.v4i16(<4 x i32>, i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.sqrshrun.v4i16(<4 x i32>, i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.uqshrn.v4i16(<4 x i32>, i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.rshrn.v4i16(<4 x i32>, i32) #1

attributes #0 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!6 = !{!7, !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
