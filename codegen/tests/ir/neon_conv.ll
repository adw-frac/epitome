; NEON conversions of floats to integers by each rounding, and saturating
; narrowings (clang -O2 of C using arm_neon.h).
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @conv(ptr noundef writeonly captures(none) initializes((0, 80)) %0, ptr noundef writeonly captures(none) initializes((0, 80)) %1, ptr noundef readonly captures(none) %2, ptr noundef writeonly captures(none) initializes((0, 8)) %3, ptr noundef writeonly captures(none) initializes((0, 8)) %4, ptr noundef writeonly captures(none) initializes((0, 8)) %5, ptr noundef readonly captures(none) %6, ptr noundef readonly captures(none) %7) local_unnamed_addr #0 {
  %9 = load <4 x float>, ptr %2, align 16, !tbaa !6
  %10 = tail call <4 x i32> @llvm.aarch64.neon.fcvtns.v4i32.v4f32(<4 x float> %9)
  store <4 x i32> %10, ptr %0, align 16, !tbaa !6
  %11 = tail call <4 x i32> @llvm.aarch64.neon.fcvtas.v4i32.v4f32(<4 x float> %9)
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store <4 x i32> %11, ptr %12, align 16, !tbaa !6
  %13 = tail call <4 x i32> @llvm.aarch64.neon.fcvtms.v4i32.v4f32(<4 x float> %9)
  %14 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store <4 x i32> %13, ptr %14, align 16, !tbaa !6
  %15 = tail call <4 x i32> @llvm.aarch64.neon.fcvtps.v4i32.v4f32(<4 x float> %9)
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store <4 x i32> %15, ptr %16, align 16, !tbaa !6
  %17 = tail call <4 x i32> @llvm.aarch64.neon.fcvtzs.v4i32.v4f32(<4 x float> %9)
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store <4 x i32> %17, ptr %18, align 16, !tbaa !6
  %19 = tail call <4 x i32> @llvm.aarch64.neon.fcvtnu.v4i32.v4f32(<4 x float> %9)
  store <4 x i32> %19, ptr %1, align 16, !tbaa !6
  %20 = tail call <4 x i32> @llvm.aarch64.neon.fcvtau.v4i32.v4f32(<4 x float> %9)
  %21 = getelementptr inbounds nuw i8, ptr %1, i64 16
  store <4 x i32> %20, ptr %21, align 16, !tbaa !6
  %22 = tail call <4 x i32> @llvm.aarch64.neon.fcvtmu.v4i32.v4f32(<4 x float> %9)
  %23 = getelementptr inbounds nuw i8, ptr %1, i64 32
  store <4 x i32> %22, ptr %23, align 16, !tbaa !6
  %24 = tail call <4 x i32> @llvm.aarch64.neon.fcvtpu.v4i32.v4f32(<4 x float> %9)
  %25 = getelementptr inbounds nuw i8, ptr %1, i64 48
  store <4 x i32> %24, ptr %25, align 16, !tbaa !6
  %26 = tail call <4 x i32> @llvm.aarch64.neon.fcvtzu.v4i32.v4f32(<4 x float> %9)
  %27 = getelementptr inbounds nuw i8, ptr %1, i64 64
  store <4 x i32> %26, ptr %27, align 16, !tbaa !6
  %28 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %29 = tail call <4 x i16> @llvm.aarch64.neon.sqxtn.v4i16(<4 x i32> %28)
  store <4 x i16> %29, ptr %3, align 8, !tbaa !6
  %30 = load <4 x i32>, ptr %7, align 16, !tbaa !6
  %31 = tail call <4 x i16> @llvm.aarch64.neon.uqxtn.v4i16(<4 x i32> %30)
  store <4 x i16> %31, ptr %4, align 8, !tbaa !6
  %32 = load <4 x i32>, ptr %6, align 16, !tbaa !6
  %33 = tail call <4 x i16> @llvm.aarch64.neon.sqxtun.v4i16(<4 x i32> %32)
  store <4 x i16> %33, ptr %5, align 8, !tbaa !6
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtns.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtas.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtms.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtps.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtzs.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtnu.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtau.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtmu.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtpu.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.fcvtzu.v4i32.v4f32(<4 x float>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.sqxtn.v4i16(<4 x i32>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.uqxtn.v4i16(<4 x i32>) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i16> @llvm.aarch64.neon.sqxtun.v4i16(<4 x i32>) #1

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
