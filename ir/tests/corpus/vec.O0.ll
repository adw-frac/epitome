; ModuleID = 'vec.c'
source_filename = "vec.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define <4 x float> @vadd(<4 x float> noundef %0, <4 x float> noundef %1) #0 {
  %3 = alloca <4 x float>, align 16
  %4 = alloca <4 x float>, align 16
  store <4 x float> %0, ptr %3, align 16
  store <4 x float> %1, ptr %4, align 16
  %5 = load <4 x float>, ptr %3, align 16
  %6 = load <4 x float>, ptr %4, align 16
  %7 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %6, <4 x float> splat (float 2.000000e+00), <4 x float> %5)
  ret <4 x float> %7
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define <4 x i32> @vshuf(<4 x i32> noundef %0, <4 x i32> noundef %1) #0 {
  %3 = alloca <4 x i32>, align 16
  %4 = alloca <4 x i32>, align 16
  store <4 x i32> %0, ptr %3, align 16
  store <4 x i32> %1, ptr %4, align 16
  %5 = load <4 x i32>, ptr %3, align 16
  %6 = load <4 x i32>, ptr %4, align 16
  %7 = shufflevector <4 x i32> %5, <4 x i32> %6, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x i32> %7
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define float @vsum(<4 x float> noundef %0) #0 {
  %2 = alloca <4 x float>, align 16
  store <4 x float> %0, ptr %2, align 16
  %3 = load <4 x float>, ptr %2, align 16
  %4 = extractelement <4 x float> %3, i32 0
  %5 = load <4 x float>, ptr %2, align 16
  %6 = extractelement <4 x float> %5, i32 1
  %7 = fadd float %4, %6
  %8 = load <4 x float>, ptr %2, align 16
  %9 = extractelement <4 x float> %8, i32 2
  %10 = fadd float %7, %9
  %11 = load <4 x float>, ptr %2, align 16
  %12 = extractelement <4 x float> %11, i32 3
  %13 = fadd float %10, %12
  ret float %13
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @atom(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i8, align 1
  %8 = alloca i32, align 4
  store ptr %0, ptr %2, align 8
  %9 = load ptr, ptr %2, align 8
  store i32 1, ptr %3, align 4
  %10 = load i32, ptr %3, align 4
  %11 = atomicrmw add ptr %9, i32 %10 seq_cst, align 4
  store i32 %11, ptr %4, align 4
  %12 = load i32, ptr %4, align 4
  store i32 0, ptr %5, align 4
  %13 = load ptr, ptr %2, align 8
  store i32 5, ptr %6, align 4
  %14 = load i32, ptr %5, align 4
  %15 = load i32, ptr %6, align 4
  %16 = cmpxchg ptr %13, i32 %14, i32 %15 acq_rel acquire, align 4
  %17 = extractvalue { i32, i1 } %16, 0
  %18 = extractvalue { i32, i1 } %16, 1
  br i1 %18, label %20, label %19

19:                                               ; preds = %1
  store i32 %17, ptr %5, align 4
  br label %20

20:                                               ; preds = %19, %1
  %21 = zext i1 %18 to i8
  store i8 %21, ptr %7, align 1
  %22 = load i8, ptr %7, align 1
  %23 = trunc i8 %22 to i1
  %24 = load ptr, ptr %2, align 8
  %25 = load atomic i32, ptr %24 acquire, align 4
  store i32 %25, ptr %8, align 4
  %26 = load i32, ptr %8, align 4
  ret i32 %26
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define zeroext i1 @overflow(i32 noundef %0, i32 noundef %1, ptr noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca ptr, align 8
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  store ptr %2, ptr %6, align 8
  %7 = load i32, ptr %4, align 4
  %8 = load i32, ptr %5, align 4
  %9 = load ptr, ptr %6, align 8
  %10 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %7, i32 %8)
  %11 = extractvalue { i32, i1 } %10, 1
  %12 = extractvalue { i32, i1 } %10, 0
  store i32 %12, ptr %9, align 4
  ret i1 %11
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @bits(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = call i32 @llvm.ctpop.i32(i32 %3)
  %5 = load i32, ptr %2, align 4
  %6 = or i32 %5, 1
  %7 = call i32 @llvm.ctlz.i32(i32 %6, i1 false)
  %8 = add nsw i32 %4, %7
  %9 = load i32, ptr %2, align 4
  %10 = or i32 %9, 8
  %11 = call i32 @llvm.cttz.i32(i32 %10, i1 false)
  %12 = add nsw i32 %8, %11
  ret i32 %12
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctpop.i32(i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctlz.i32(i32, i1 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.cttz.i32(i32, i1 immarg) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i128 @big(i128 noundef %0) #0 {
  %2 = alloca i128, align 16
  store i128 %0, ptr %2, align 16
  %3 = load i128, ptr %2, align 16
  %4 = mul nsw i128 %3, 1267650600228229401496703205376
  %5 = add nsw i128 %4, 12345678901234567890
  ret i128 %5
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define { double, double } @cmul([2 x double] noundef %0, [2 x double] noundef %1) #0 {
  %3 = alloca { double, double }, align 8
  %4 = alloca { double, double }, align 8
  %5 = alloca { double, double }, align 8
  store [2 x double] %0, ptr %4, align 8
  store [2 x double] %1, ptr %5, align 8
  %6 = getelementptr inbounds nuw { double, double }, ptr %4, i32 0, i32 0
  %7 = load double, ptr %6, align 8
  %8 = getelementptr inbounds nuw { double, double }, ptr %4, i32 0, i32 1
  %9 = load double, ptr %8, align 8
  %10 = getelementptr inbounds nuw { double, double }, ptr %5, i32 0, i32 0
  %11 = load double, ptr %10, align 8
  %12 = getelementptr inbounds nuw { double, double }, ptr %5, i32 0, i32 1
  %13 = load double, ptr %12, align 8
  %14 = fmul double %7, %11
  %15 = fmul double %9, %13
  %16 = fmul double %7, %13
  %17 = fmul double %9, %11
  %18 = fsub double %14, %15
  %19 = fadd double %16, %17
  %20 = fcmp uno double %18, %18
  br i1 %20, label %21, label %27, !prof !6

21:                                               ; preds = %2
  %22 = fcmp uno double %19, %19
  br i1 %22, label %23, label %27, !prof !6

23:                                               ; preds = %21
  %24 = call { double, double } @__muldc3(double noundef %7, double noundef %9, double noundef %11, double noundef %13) #2
  %25 = extractvalue { double, double } %24, 0
  %26 = extractvalue { double, double } %24, 1
  br label %27

27:                                               ; preds = %23, %21, %2
  %28 = phi double [ %18, %2 ], [ %18, %21 ], [ %25, %23 ]
  %29 = phi double [ %19, %2 ], [ %19, %21 ], [ %26, %23 ]
  %30 = getelementptr inbounds nuw { double, double }, ptr %3, i32 0, i32 0
  %31 = getelementptr inbounds nuw { double, double }, ptr %3, i32 0, i32 1
  store double %28, ptr %30, align 8
  store double %29, ptr %31, align 8
  %32 = load { double, double }, ptr %3, align 8
  ret { double, double } %32
}

declare { double, double } @__muldc3(double, double, double, double)

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!6 = !{!"branch_weights", i32 1, i32 1048575}
