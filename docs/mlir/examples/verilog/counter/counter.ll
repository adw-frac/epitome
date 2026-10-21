; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

@_arc_mod_name_counter = internal constant [8 x i8] c"counter\00"
@arcRuntimeModel_counter = global { i64, i64, ptr, ptr } { i64 1, i64 30, ptr @_arc_mod_name_counter, ptr null }

declare noalias noundef nonnull align 16 ptr @arcRuntimeIR_allocInstance(ptr, ptr)

declare void @arcRuntimeIR_deleteInstance(ptr)

declare void @arcRuntimeIR_onEval(ptr noalias nofree captures(none))

declare void @arcRuntimeIR_onInitialized(ptr noalias nofree captures(none))

declare void @exit(i32)

define void @counter_main() {
  %1 = call ptr @arcRuntimeIR_allocInstance(ptr @arcRuntimeModel_counter, ptr null)
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
  call void @counter_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @arcRuntimeIR_deleteInstance(ptr %1)
  ret void
}

define void @counter_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i1, ptr %3, align 1
  %5 = getelementptr i8, ptr %0, i32 27
  %6 = load i1, ptr %5, align 1
  store i1 %4, ptr %5, align 1
  %7 = xor i1 %6, %4
  %8 = and i1 %7, %4
  br i1 %8, label %9, label %22

9:                                                ; preds = %1
  %10 = getelementptr i8, ptr %0, i32 28
  %11 = load i8, ptr %10, align 1
  %12 = getelementptr i8, ptr %0, i32 25
  %13 = load i1, ptr %12, align 1
  %14 = getelementptr i8, ptr %0, i32 26
  %15 = load i1, ptr %14, align 1
  %16 = add i8 %11, 1
  %17 = xor i1 %13, true
  %18 = and i1 %15, %17
  %19 = select i1 %18, i8 %16, i8 0
  %20 = or i1 %13, %15
  %21 = select i1 %20, i8 %19, i8 %11
  store i8 %21, ptr %10, align 1
  br label %22

22:                                               ; preds = %9, %1
  %23 = getelementptr i8, ptr %0, i32 28
  %24 = load i8, ptr %23, align 1
  %25 = getelementptr i8, ptr %0, i32 29
  store i8 %24, ptr %25, align 1
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
