; NEON intrinsics with generic forms (clang -O2 of C using arm_neon.h):
; minimums and maximums, saturating arithmetic, rounding, and reductions
; across lanes, faddv's pairwise order included.
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @ops(ptr noundef captures(none) initializes((32, 112)) %0, ptr noundef captures(none) initializes((32, 64)) %1, ptr noundef captures(none) initializes((32, 64)) %2, ptr noundef captures(none) initializes((32, 64)) %3) local_unnamed_addr #0 {
  %5 = load <4 x float>, ptr %0, align 16, !tbaa !6
  %6 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %7 = load <4 x float>, ptr %6, align 16, !tbaa !6
  %8 = tail call <4 x float> @llvm.aarch64.neon.fmin.v4f32(<4 x float> %5, <4 x float> %7)
  %9 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store <4 x float> %8, ptr %9, align 16, !tbaa !6
  %10 = tail call <4 x float> @llvm.aarch64.neon.fmax.v4f32(<4 x float> %5, <4 x float> %7)
  %11 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store <4 x float> %10, ptr %11, align 16, !tbaa !6
  %12 = tail call <4 x float> @llvm.aarch64.neon.fminnm.v4f32(<4 x float> %5, <4 x float> %7)
  %13 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store <4 x float> %12, ptr %13, align 16, !tbaa !6
  %14 = tail call <4 x float> @llvm.aarch64.neon.fmaxnm.v4f32(<4 x float> %5, <4 x float> %7)
  %15 = getelementptr inbounds nuw i8, ptr %0, i64 80
  store <4 x float> %14, ptr %15, align 16, !tbaa !6
  %16 = tail call <4 x float> @llvm.roundeven.v4f32(<4 x float> %5)
  %17 = getelementptr inbounds nuw i8, ptr %0, i64 96
  store <4 x float> %16, ptr %17, align 16, !tbaa !6
  %18 = load <16 x i8>, ptr %1, align 16, !tbaa !6
  %19 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %20 = load <16 x i8>, ptr %19, align 16, !tbaa !6
  %21 = tail call <16 x i8> @llvm.aarch64.neon.uqsub.v16i8(<16 x i8> %18, <16 x i8> %20)
  %22 = getelementptr inbounds nuw i8, ptr %1, i64 32
  store <16 x i8> %21, ptr %22, align 16, !tbaa !6
  %23 = tail call <16 x i8> @llvm.aarch64.neon.uqadd.v16i8(<16 x i8> %18, <16 x i8> %20)
  %24 = getelementptr inbounds nuw i8, ptr %1, i64 48
  store <16 x i8> %23, ptr %24, align 16, !tbaa !6
  %25 = load <8 x i16>, ptr %2, align 16, !tbaa !6
  %26 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %27 = load <8 x i16>, ptr %26, align 16, !tbaa !6
  %28 = tail call <8 x i16> @llvm.aarch64.neon.sqadd.v8i16(<8 x i16> %25, <8 x i16> %27)
  %29 = getelementptr inbounds nuw i8, ptr %2, i64 32
  store <8 x i16> %28, ptr %29, align 16, !tbaa !6
  %30 = tail call <8 x i16> @llvm.aarch64.neon.sqsub.v8i16(<8 x i16> %25, <8 x i16> %27)
  %31 = getelementptr inbounds nuw i8, ptr %2, i64 48
  store <8 x i16> %30, ptr %31, align 16, !tbaa !6
  %32 = load <4 x i32>, ptr %3, align 16, !tbaa !6
  %33 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %34 = load <4 x i32>, ptr %33, align 16, !tbaa !6
  %35 = tail call <4 x i32> @llvm.aarch64.neon.umax.v4i32(<4 x i32> %32, <4 x i32> %34)
  %36 = getelementptr inbounds nuw i8, ptr %3, i64 32
  store <4 x i32> %35, ptr %36, align 16, !tbaa !6
  %37 = tail call <4 x i32> @llvm.aarch64.neon.umin.v4i32(<4 x i32> %32, <4 x i32> %34)
  %38 = getelementptr inbounds nuw i8, ptr %3, i64 48
  store <4 x i32> %37, ptr %38, align 16, !tbaa !6
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: read) uwtable(sync)
define float @red(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1, ptr noundef readonly captures(none) %2, ptr noundef readonly captures(none) %3, ptr noundef readonly captures(none) %4) local_unnamed_addr #1 {
  %6 = load <4 x float>, ptr %0, align 16, !tbaa !6
  %7 = tail call float @llvm.aarch64.neon.faddv.f32.v4f32(<4 x float> %6)
  %8 = load <2 x float>, ptr %3, align 8, !tbaa !6
  %9 = tail call float @llvm.aarch64.neon.faddv.f32.v2f32(<2 x float> %8)
  %10 = fadd float %7, %9
  %11 = load <2 x double>, ptr %4, align 16, !tbaa !6
  %12 = tail call double @llvm.aarch64.neon.faddv.f64.v2f64(<2 x double> %11)
  %13 = fptrunc double %12 to float
  %14 = fadd float %10, %13
  %15 = load <16 x i8>, ptr %1, align 16, !tbaa !6
  %16 = tail call i8 @llvm.vector.reduce.add.v16i8(<16 x i8> %15)
  %17 = uitofp i8 %16 to float
  %18 = fadd float %14, %17
  %19 = tail call i8 @llvm.vector.reduce.umax.v16i8(<16 x i8> %15)
  %20 = zext i8 %19 to i32
  %21 = shl nuw nsw i32 %20, 1
  %22 = uitofp nneg i32 %21 to float
  %23 = fadd float %18, %22
  %24 = load <4 x i32>, ptr %2, align 16, !tbaa !6
  %25 = tail call i32 @llvm.vector.reduce.smin.v4i32(<4 x i32> %24)
  %26 = mul nsw i32 %25, 3
  %27 = sitofp i32 %26 to float
  %28 = fadd float %23, %27
  %29 = tail call float @llvm.aarch64.neon.fmaxv.f32.v4f32(<4 x float> %6)
  %30 = tail call float @llvm.fmuladd.f32(float %29, float 5.000000e+00, float %28)
  %31 = tail call float @llvm.aarch64.neon.fminnmv.f32.v4f32(<4 x float> %6)
  %32 = tail call float @llvm.fmuladd.f32(float %31, float 7.000000e+00, float %30)
  %33 = tail call i32 @llvm.aarch64.neon.uaddlv.i32.v16i8(<16 x i8> %15)
  %34 = and i32 %33, 65535
  %35 = mul nuw nsw i32 %34, 11
  %36 = uitofp nneg i32 %35 to float
  %37 = fadd float %32, %36
  ret float %37
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x float> @llvm.aarch64.neon.fmin.v4f32(<4 x float>, <4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x float> @llvm.aarch64.neon.fmax.v4f32(<4 x float>, <4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x float> @llvm.aarch64.neon.fminnm.v4f32(<4 x float>, <4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x float> @llvm.aarch64.neon.fmaxnm.v4f32(<4 x float>, <4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x float> @llvm.roundeven.v4f32(<4 x float>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <16 x i8> @llvm.aarch64.neon.uqsub.v16i8(<16 x i8>, <16 x i8>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <16 x i8> @llvm.aarch64.neon.uqadd.v16i8(<16 x i8>, <16 x i8>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <8 x i16> @llvm.aarch64.neon.sqadd.v8i16(<8 x i16>, <8 x i16>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <8 x i16> @llvm.aarch64.neon.sqsub.v8i16(<8 x i16>, <8 x i16>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.umax.v4i32(<4 x i32>, <4 x i32>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.neon.umin.v4i32(<4 x i32>, <4 x i32>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare float @llvm.aarch64.neon.faddv.f32.v4f32(<4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare float @llvm.aarch64.neon.faddv.f32.v2f32(<2 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare double @llvm.aarch64.neon.faddv.f64.v2f64(<2 x double>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.vector.reduce.add.v16i8(<16 x i8>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.vector.reduce.umax.v16i8(<16 x i8>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.vector.reduce.smin.v4i32(<4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare float @llvm.aarch64.neon.fmaxv.f32.v4f32(<4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare float @llvm.aarch64.neon.fminnmv.f32.v4f32(<4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.neon.uaddlv.i32.v16i8(<16 x i8>) #3

attributes #0 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: read) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { mustprogress nocallback nofree nosync nounwind willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!6 = !{!7, !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
