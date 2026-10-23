; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

@_arc_mod_name_GCD = internal constant [4 x i8] c"GCD\00"
@arcRuntimeModel_GCD = global { i64, i64, ptr, ptr } { i64 1, i64 41, ptr @_arc_mod_name_GCD, ptr null }

declare noalias noundef nonnull align 16 ptr @arcRuntimeIR_allocInstance(ptr, ptr)

declare void @arcRuntimeIR_deleteInstance(ptr)

declare void @arcRuntimeIR_onEval(ptr noalias nofree captures(none))

declare void @arcRuntimeIR_onInitialized(ptr noalias nofree captures(none))

declare void @exit(i32)

define void @GCD_main() {
  %1 = call ptr @arcRuntimeIR_allocInstance(ptr @arcRuntimeModel_GCD, ptr null)
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
  call void @GCD_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @arcRuntimeIR_deleteInstance(ptr %1)
  ret void
}

define void @GCD_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i1, ptr %3, align 1
  %5 = getelementptr i8, ptr %0, i32 36
  %6 = load i1, ptr %5, align 1
  store i1 %4, ptr %5, align 1
  %7 = xor i1 %6, %4
  %8 = and i1 %7, %4
  br i1 %8, label %9, label %29

9:                                                ; preds = %1
  %10 = getelementptr i8, ptr %0, i32 32
  %11 = load i16, ptr %10, align 2
  %12 = getelementptr i8, ptr %0, i32 34
  %13 = load i16, ptr %12, align 2
  %14 = icmp ugt i16 %11, %13
  %15 = getelementptr i8, ptr %0, i32 30
  %16 = load i1, ptr %15, align 1
  %17 = getelementptr i8, ptr %0, i32 26
  %18 = load i16, ptr %17, align 2
  %19 = sub i16 %11, %13
  %20 = select i1 %14, i16 %19, i16 %11
  %21 = select i1 %16, i16 %18, i16 %20
  store i16 %21, ptr %10, align 2
  %22 = load i16, ptr %12, align 2
  %23 = load i1, ptr %15, align 1
  %24 = getelementptr i8, ptr %0, i32 28
  %25 = load i16, ptr %24, align 2
  %26 = sub i16 %22, %11
  %27 = select i1 %14, i16 %22, i16 %26
  %28 = select i1 %23, i16 %25, i16 %27
  store i16 %28, ptr %12, align 2
  br label %29

29:                                               ; preds = %9, %1
  %30 = getelementptr i8, ptr %0, i32 32
  %31 = load i16, ptr %30, align 2
  %32 = getelementptr i8, ptr %0, i32 38
  store i16 %31, ptr %32, align 2
  %33 = getelementptr i8, ptr %0, i32 34
  %34 = load i16, ptr %33, align 2
  %35 = icmp eq i16 %34, 0
  %36 = getelementptr i8, ptr %0, i32 40
  store i1 %35, ptr %36, align 1
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
