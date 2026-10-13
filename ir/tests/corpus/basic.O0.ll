; ModuleID = 'basic.c'
source_filename = "basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.point = type { i32, double, [8 x i8] }

@.str = private unnamed_addr constant [15 x i8] c"hello \22world\22\0A\00", align 1
@msg = global ptr @.str, align 8
@table = global [4 x i32] [i32 1, i32 2, i32 3, i32 4], align 4
@ftab = global [3 x float] [float 0x3FB99999A0000000, float 1.500000e+00, float -2.000000e+00], align 4
@dvals = global [2 x double] [double 3.141590e+00, double 1.000000e+300], align 8
@ld = global double 1.250000e+00, align 8
@fp = global ptr @classify, align 8
@ext_var = external global i32, align 4
@tls_var = thread_local global i32 0, align 4
@__const.main.p = private unnamed_addr constant { i32, [4 x i8], double, [8 x i8] } { i32 1, [4 x i8] zeroinitializer, double 2.000000e+00, [8 x i8] c"pt\00\00\00\00\00\00" }, align 8
@.str.1 = private unnamed_addr constant [10 x i8] c"%d %f %s\0A\00", align 1
@counter = internal global i32 3, align 4

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @sum(i32 noundef %0, ...) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  call void @llvm.va_start.p0(ptr %3)
  store i32 0, ptr %4, align 4
  store i32 0, ptr %5, align 4
  br label %7

7:                                                ; preds = %16, %1
  %8 = load i32, ptr %5, align 4
  %9 = load i32, ptr %2, align 4
  %10 = icmp slt i32 %8, %9
  br i1 %10, label %11, label %19

11:                                               ; preds = %7
  %12 = va_arg ptr %3, i32
  store i32 %12, ptr %6, align 4
  %13 = load i32, ptr %6, align 4
  %14 = load i32, ptr %4, align 4
  %15 = add nsw i32 %14, %13
  store i32 %15, ptr %4, align 4
  br label %16

16:                                               ; preds = %11
  %17 = load i32, ptr %5, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, ptr %5, align 4
  br label %7, !llvm.loop !6

19:                                               ; preds = %7
  call void @llvm.va_end.p0(ptr %3)
  %20 = load i32, ptr %4, align 4
  ret i32 %20
}

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.va_start.p0(ptr) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.va_end.p0(ptr) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @classify(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  %4 = load i32, ptr %3, align 4
  switch i32 %4, label %8 [
    i32 0, label %5
    i32 1, label %6
    i32 5, label %7
  ]

5:                                                ; preds = %1
  store i32 10, ptr %2, align 4
  br label %9

6:                                                ; preds = %1
  store i32 20, ptr %2, align 4
  br label %9

7:                                                ; preds = %1
  store i32 7, ptr %2, align 4
  br label %9

8:                                                ; preds = %1
  store i32 -1, ptr %2, align 4
  br label %9

9:                                                ; preds = %8, %7, %6, %5
  %10 = load i32, ptr %2, align 4
  ret i32 %10
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define double @dot(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = getelementptr inbounds nuw %struct.point, ptr %5, i32 0, i32 0
  %7 = load i32, ptr %6, align 8
  %8 = load ptr, ptr %4, align 8
  %9 = getelementptr inbounds nuw %struct.point, ptr %8, i32 0, i32 0
  %10 = load i32, ptr %9, align 8
  %11 = mul nsw i32 %7, %10
  %12 = sitofp i32 %11 to double
  %13 = load ptr, ptr %3, align 8
  %14 = getelementptr inbounds nuw %struct.point, ptr %13, i32 0, i32 1
  %15 = load double, ptr %14, align 8
  %16 = load ptr, ptr %4, align 8
  %17 = getelementptr inbounds nuw %struct.point, ptr %16, i32 0, i32 1
  %18 = load double, ptr %17, align 8
  %19 = call double @llvm.fmuladd.f64(double %15, double %18, double %12)
  ret double %19
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #2

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i64 @mix(i64 noundef %0, i32 noundef %1, i16 noundef signext %2, i8 noundef zeroext %3) #0 {
  %5 = alloca i64, align 8
  %6 = alloca i32, align 4
  %7 = alloca i16, align 2
  %8 = alloca i8, align 1
  store i64 %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store i16 %2, ptr %7, align 2
  store i8 %3, ptr %8, align 1
  %9 = load i64, ptr %5, align 8
  %10 = lshr i64 %9, 3
  %11 = load i32, ptr %6, align 4
  %12 = shl i32 %11, 2
  %13 = zext i32 %12 to i64
  %14 = xor i64 %10, %13
  %15 = load i16, ptr %7, align 2
  %16 = sext i16 %15 to i64
  %17 = load i8, ptr %8, align 1
  %18 = zext i8 %17 to i64
  %19 = mul i64 %16, %18
  %20 = urem i64 %19, 7
  %21 = load i64, ptr %5, align 8
  %22 = load i32, ptr %6, align 4
  %23 = or i32 %22, 1
  %24 = zext i32 %23 to i64
  %25 = udiv i64 %21, %24
  %26 = add i64 %20, %25
  %27 = xor i64 %14, %26
  ret i64 %27
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define float @fmaths(float noundef %0, float noundef %1) #0 {
  %3 = alloca float, align 4
  %4 = alloca float, align 4
  store float %0, ptr %3, align 4
  store float %1, ptr %4, align 4
  %5 = load float, ptr %3, align 4
  %6 = load float, ptr %4, align 4
  %7 = fdiv float %5, %6
  %8 = load float, ptr %3, align 4
  %9 = fneg float %8
  %10 = call float @llvm.fmuladd.f32(float %9, float 2.500000e+00, float %7)
  %11 = load float, ptr %4, align 4
  %12 = fptosi float %11 to i32
  %13 = sitofp i32 %12 to float
  %14 = fadd float %10, %13
  ret float %14
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #2

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @copy(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %5, ptr align 8 %6, i64 24, i1 false)
  %7 = load ptr, ptr %3, align 8
  %8 = getelementptr inbounds nuw %struct.point, ptr %7, i32 0, i32 2
  %9 = getelementptr inbounds [8 x i8], ptr %8, i64 0, i64 0
  %10 = load ptr, ptr %3, align 8
  %11 = getelementptr inbounds nuw %struct.point, ptr %10, i32 0, i32 2
  %12 = getelementptr inbounds [8 x i8], ptr %11, i64 0, i64 0
  %13 = call i64 @llvm.objectsize.i64.p0(ptr %12, i1 false, i1 true, i1 false)
  %14 = call ptr @__memset_chk(ptr noundef %9, i32 noundef 0, i64 noundef 8, i64 noundef %13) #6
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #3

; Function Attrs: nounwind
declare ptr @__memset_chk(ptr noundef, i32 noundef, i64 noundef, i64 noundef) #4

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.objectsize.i64.p0(ptr, i1 immarg, i1 immarg, i1 immarg) #2

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @loop(ptr noundef %0, i32 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 %1, ptr %4, align 4
  store i32 0, ptr %5, align 4
  store i32 0, ptr %6, align 4
  br label %7

7:                                                ; preds = %43, %2
  %8 = load i32, ptr %6, align 4
  %9 = load i32, ptr %4, align 4
  %10 = icmp slt i32 %8, %9
  br i1 %10, label %11, label %46

11:                                               ; preds = %7
  %12 = load ptr, ptr %3, align 8
  %13 = load i32, ptr %6, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds i32, ptr %12, i64 %14
  %16 = load i32, ptr %15, align 4
  %17 = load i32, ptr %5, align 4
  %18 = icmp sgt i32 %16, %17
  br i1 %18, label %19, label %25

19:                                               ; preds = %11
  %20 = load ptr, ptr %3, align 8
  %21 = load i32, ptr %6, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds i32, ptr %20, i64 %22
  %24 = load i32, ptr %23, align 4
  store i32 %24, ptr %5, align 4
  br label %42

25:                                               ; preds = %11
  %26 = load ptr, ptr %3, align 8
  %27 = load i32, ptr %6, align 4
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds i32, ptr %26, i64 %28
  %30 = load i32, ptr %29, align 4
  %31 = load i32, ptr %5, align 4
  %32 = sub nsw i32 0, %31
  %33 = icmp slt i32 %30, %32
  br i1 %33, label %34, label %41

34:                                               ; preds = %25
  %35 = load ptr, ptr %3, align 8
  %36 = load i32, ptr %6, align 4
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds i32, ptr %35, i64 %37
  %39 = load i32, ptr %38, align 4
  %40 = sub nsw i32 0, %39
  store i32 %40, ptr %5, align 4
  br label %41

41:                                               ; preds = %34, %25
  br label %42

42:                                               ; preds = %41, %19
  br label %43

43:                                               ; preds = %42
  %44 = load i32, ptr %6, align 4
  %45 = add nsw i32 %44, 1
  store i32 %45, ptr %6, align 4
  br label %7, !llvm.loop !8

46:                                               ; preds = %7
  %47 = load i32, ptr %5, align 4
  %48 = icmp ne i32 %47, 0
  br i1 %48, label %49, label %51

49:                                               ; preds = %46
  %50 = load i32, ptr %5, align 4
  br label %56

51:                                               ; preds = %46
  %52 = load i32, ptr @ext_var, align 4
  %53 = call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tls_var)
  %54 = load i32, ptr %53, align 4
  %55 = add nsw i32 %52, %54
  br label %56

56:                                               ; preds = %51, %49
  %57 = phi i32 [ %50, %49 ], [ %55, %51 ]
  ret i32 %57
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull) #2

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca %struct.point, align 8
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %6, ptr align 8 @__const.main.p, i64 24, i1 false)
  %7 = call i32 (i32, ...) @sum(i32 noundef 3, i32 noundef 1, i32 noundef 2, i32 noundef 3)
  %8 = call double @dot(ptr noundef %6, ptr noundef %6)
  %9 = load ptr, ptr @msg, align 8
  %10 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, i32 noundef %7, double noundef %8, ptr noundef %9)
  %11 = load i32, ptr %4, align 4
  %12 = call i32 @classify(i32 noundef %11)
  %13 = load i32, ptr @counter, align 4
  %14 = add nsw i32 %12, %13
  %15 = load ptr, ptr @fp, align 8
  %16 = call i32 %15(i32 noundef 1)
  %17 = add nsw i32 %14, %16
  ret i32 %17
}

declare i32 @printf(ptr noundef, ...) #5

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nosync nounwind willreturn }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { nounwind }

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
!8 = distinct !{!8, !7}
