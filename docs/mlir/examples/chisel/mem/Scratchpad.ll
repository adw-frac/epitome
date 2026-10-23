; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

@_arc_mod_name_Scratchpad = internal constant [11 x i8] c"Scratchpad\00"
@arcRuntimeModel_Scratchpad = global { i64, i64, ptr, ptr } { i64 1, i64 120, ptr @_arc_mod_name_Scratchpad, ptr null }

declare noalias noundef nonnull align 16 ptr @arcRuntimeIR_allocInstance(ptr, ptr)

declare void @arcRuntimeIR_deleteInstance(ptr)

declare void @arcRuntimeIR_onEval(ptr noalias nofree captures(none))

declare void @arcRuntimeIR_onInitialized(ptr noalias nofree captures(none))

declare void @exit(i32)

define void @Scratchpad_main() {
  %1 = call ptr @arcRuntimeIR_allocInstance(ptr @arcRuntimeModel_Scratchpad, ptr null)
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
  call void @Scratchpad_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @arcRuntimeIR_deleteInstance(ptr %1)
  ret void
}

define void @Scratchpad_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i1, ptr %3, align 1
  %5 = getelementptr i8, ptr %0, i32 113
  %6 = load i1, ptr %5, align 1
  store i1 %4, ptr %5, align 1
  %7 = xor i1 %6, %4
  %8 = and i1 %7, %4
  br i1 %8, label %9, label %28

9:                                                ; preds = %1
  %10 = getelementptr i8, ptr %0, i32 27
  %11 = load i1, ptr %10, align 1
  br i1 %11, label %12, label %23

12:                                               ; preds = %9
  %13 = getelementptr i8, ptr %0, i32 28
  %14 = load i4, ptr %13, align 1
  %15 = getelementptr i8, ptr %0, i32 32
  %16 = load i32, ptr %15, align 4
  %17 = getelementptr i8, ptr %0, i32 48
  %18 = zext i4 %14 to i5
  %19 = icmp ult i5 %18, -16
  %20 = getelementptr i32, ptr %17, i5 %18
  br i1 %19, label %21, label %22

21:                                               ; preds = %12
  store i32 %16, ptr %20, align 4
  br label %22

22:                                               ; preds = %21, %12
  br label %23

23:                                               ; preds = %22, %9
  %24 = getelementptr i8, ptr %0, i32 26
  %25 = load i4, ptr %24, align 1
  %26 = getelementptr i8, ptr %0, i32 112
  store i4 %25, ptr %26, align 1
  %27 = getelementptr i8, ptr %0, i32 114
  store i1 true, ptr %27, align 1
  br label %28

28:                                               ; preds = %23, %1
  %29 = getelementptr i8, ptr %0, i32 114
  %30 = load i1, ptr %29, align 1
  %31 = getelementptr i8, ptr %0, i32 112
  %32 = load i4, ptr %31, align 1
  %33 = getelementptr i8, ptr %0, i32 48
  %34 = zext i4 %32 to i5
  %35 = icmp ult i5 %34, -16
  %36 = getelementptr i32, ptr %33, i5 %34
  br i1 %35, label %37, label %39

37:                                               ; preds = %28
  %38 = load i32, ptr %36, align 4
  br label %40

39:                                               ; preds = %28
  br label %40

40:                                               ; preds = %37, %39
  %41 = phi i32 [ 0, %39 ], [ %38, %37 ]
  br label %42

42:                                               ; preds = %40
  %43 = select i1 %30, i32 %41, i32 0
  %44 = getelementptr i8, ptr %0, i32 116
  store i32 %43, ptr %44, align 4
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
