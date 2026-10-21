; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

@_arc_mod_name_Fir = internal constant [4 x i8] c"Fir\00"
@arcRuntimeModel_Fir = global { i64, i64, ptr, ptr } { i64 1, i64 34, ptr @_arc_mod_name_Fir, ptr null }

declare noalias noundef nonnull align 16 ptr @arcRuntimeIR_allocInstance(ptr, ptr)

declare void @arcRuntimeIR_deleteInstance(ptr)

declare void @arcRuntimeIR_onEval(ptr noalias nofree captures(none))

declare void @arcRuntimeIR_onInitialized(ptr noalias nofree captures(none))

declare void @exit(i32)

define void @Fir_main() {
  %1 = call ptr @arcRuntimeIR_allocInstance(ptr @arcRuntimeModel_Fir, ptr null)
  call void @arcRuntimeIR_onInitialized(ptr %1)
  %2 = getelementptr i8, ptr %1, i32 16
  %3 = load i64, ptr %2, align 8
  br label %4

4:                                                ; preds = %7, %0
  %5 = phi i64 [ %9, %7 ], [ %3, %0 ]
  %6 = icmp ne i64 %5, -1
  br i1 %6, label %7, label %10

7:                                                ; preds = %4
  %8 = phi i64 [ %5, %4 ]
  store i64 %8, ptr %1, align 8
  call void @arcRuntimeIR_onEval(ptr %1)
  call void @Fir_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @arcRuntimeIR_deleteInstance(ptr %1)
  ret void
}

define void @Fir_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i1, ptr %3, align 1
  %5 = getelementptr i8, ptr %0, i32 28
  %6 = load i1, ptr %5, align 1
  store i1 %4, ptr %5, align 1
  %7 = xor i1 %6, %4
  %8 = and i1 %7, %4
  br i1 %8, label %9, label %29

9:                                                ; preds = %1
  %10 = getelementptr i8, ptr %0, i32 25
  %11 = load i1, ptr %10, align 1
  br i1 %11, label %12, label %16

12:                                               ; preds = %9
  %13 = getelementptr i8, ptr %0, i32 29
  store i8 0, ptr %13, align 1
  %14 = getelementptr i8, ptr %0, i32 30
  store i8 0, ptr %14, align 1
  %15 = getelementptr i8, ptr %0, i32 31
  store i8 0, ptr %15, align 1
  br label %28

16:                                               ; preds = %9
  %17 = getelementptr i8, ptr %0, i32 27
  %18 = load i1, ptr %17, align 1
  br i1 %18, label %19, label %27

19:                                               ; preds = %16
  %20 = getelementptr i8, ptr %0, i32 29
  %21 = load i8, ptr %20, align 1
  %22 = getelementptr i8, ptr %0, i32 26
  %23 = load i8, ptr %22, align 1
  store i8 %23, ptr %20, align 1
  %24 = getelementptr i8, ptr %0, i32 30
  %25 = load i8, ptr %24, align 1
  store i8 %21, ptr %24, align 1
  %26 = getelementptr i8, ptr %0, i32 31
  store i8 %25, ptr %26, align 1
  br label %27

27:                                               ; preds = %19, %16
  br label %28

28:                                               ; preds = %12, %27
  br label %29

29:                                               ; preds = %28, %1
  %30 = getelementptr i8, ptr %0, i32 31
  %31 = load i8, ptr %30, align 1
  %32 = getelementptr i8, ptr %0, i32 30
  %33 = load i8, ptr %32, align 1
  %34 = getelementptr i8, ptr %0, i32 29
  %35 = load i8, ptr %34, align 1
  %36 = getelementptr i8, ptr %0, i32 26
  %37 = load i8, ptr %36, align 1
  %38 = zext i8 %31 to i13
  %39 = zext i8 %33 to i10
  %40 = mul i10 %39, 3
  %41 = zext i10 %40 to i12
  %42 = zext i8 %35 to i10
  %43 = mul i10 %42, 3
  %44 = zext i10 %43 to i11
  %45 = zext i8 %37 to i11
  %46 = add i11 %45, %44
  %47 = zext i11 %46 to i12
  %48 = add i12 %47, %41
  %49 = zext i12 %48 to i13
  %50 = add i13 %49, %38
  %51 = zext i13 %50 to i16
  %52 = getelementptr i8, ptr %0, i32 32
  store i16 %51, ptr %52, align 2
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
