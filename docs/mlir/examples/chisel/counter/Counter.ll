; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

@_arc_mod_name_Counter = internal constant [8 x i8] c"Counter\00"
@arcRuntimeModel_Counter = global { i64, i64, ptr, ptr } { i64 1, i64 30, ptr @_arc_mod_name_Counter, ptr null }

declare noalias noundef nonnull align 16 ptr @arcRuntimeIR_allocInstance(ptr, ptr)

declare void @arcRuntimeIR_deleteInstance(ptr)

declare void @arcRuntimeIR_onEval(ptr noalias nofree captures(none))

declare void @arcRuntimeIR_onInitialized(ptr noalias nofree captures(none))

declare void @exit(i32)

define void @Counter_main() {
  %1 = call ptr @arcRuntimeIR_allocInstance(ptr @arcRuntimeModel_Counter, ptr null)
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
  call void @Counter_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @arcRuntimeIR_deleteInstance(ptr %1)
  ret void
}

define void @Counter_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i1, ptr %3, align 1
  %5 = getelementptr i8, ptr %0, i32 27
  %6 = load i1, ptr %5, align 1
  store i1 %4, ptr %5, align 1
  %7 = xor i1 %6, %4
  %8 = and i1 %7, %4
  br i1 %8, label %9, label %23

9:                                                ; preds = %1
  %10 = getelementptr i8, ptr %0, i32 25
  %11 = load i1, ptr %10, align 1
  br i1 %11, label %12, label %14

12:                                               ; preds = %9
  %13 = getelementptr i8, ptr %0, i32 28
  store i8 0, ptr %13, align 1
  br label %22

14:                                               ; preds = %9
  %15 = getelementptr i8, ptr %0, i32 26
  %16 = load i1, ptr %15, align 1
  br i1 %16, label %17, label %21

17:                                               ; preds = %14
  %18 = getelementptr i8, ptr %0, i32 28
  %19 = load i8, ptr %18, align 1
  %20 = add i8 %19, 1
  store i8 %20, ptr %18, align 1
  br label %21

21:                                               ; preds = %17, %14
  br label %22

22:                                               ; preds = %12, %21
  br label %23

23:                                               ; preds = %22, %1
  %24 = getelementptr i8, ptr %0, i32 28
  %25 = load i8, ptr %24, align 1
  %26 = getelementptr i8, ptr %0, i32 29
  store i8 %25, ptr %26, align 1
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
