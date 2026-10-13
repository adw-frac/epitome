; ModuleID = 'x86.c'
source_filename = "x86.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@ld = dso_local global x86_fp80 0xK3FFF8CCCCCCCCCCCCCCD, align 16
@q = dso_local global fp128 0xL00000000000000004000400000000000, align 16
@gotos.t = internal global [2 x ptr] [ptr blockaddress(@gotos, %9), ptr blockaddress(@gotos, %10)], align 16
@tl = dso_local thread_local global i32 5, align 4

@alias_fn = dso_local alias i32 (), ptr @target_alias

@ifn = dso_local ifunc i32 (), ptr @resolve

; Function Attrs: noinline nounwind optnone uwtable
define dso_local x86_fp80 @addl(x86_fp80 noundef %0, x86_fp80 noundef %1) #0 {
  %3 = alloca x86_fp80, align 16
  %4 = alloca x86_fp80, align 16
  store x86_fp80 %0, ptr %3, align 16
  store x86_fp80 %1, ptr %4, align 16
  %5 = load x86_fp80, ptr %3, align 16
  %6 = load x86_fp80, ptr %4, align 16
  %7 = call x86_fp80 @llvm.fmuladd.f80(x86_fp80 %5, x86_fp80 %6, x86_fp80 0xK3FFBCCCCCCCCCCCCCCCD)
  ret x86_fp80 %7
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare x86_fp80 @llvm.fmuladd.f80(x86_fp80, x86_fp80, x86_fp80) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local fp128 @addq(fp128 noundef %0) #0 {
  %2 = alloca fp128, align 16
  store fp128 %0, ptr %2, align 16
  %3 = load fp128, ptr %2, align 16
  %4 = load fp128, ptr @q, align 16
  %5 = fadd fp128 %3, %4
  ret fp128 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local half @h(half noundef %0) #0 {
  %2 = alloca half, align 2
  store half %0, ptr %2, align 2
  %3 = load half, ptr %2, align 2
  %4 = fpext half %3 to float
  %5 = fmul float %4, 0x3FD3340000000000
  %6 = fptrunc float %5 to half
  ret half %6
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local bfloat @bf(bfloat noundef %0) #0 {
  %2 = alloca bfloat, align 2
  store bfloat %0, ptr %2, align 2
  %3 = load bfloat, ptr %2, align 2
  ret bfloat %3
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @gotos(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  %4 = load i32, ptr %3, align 4
  %5 = and i32 %4, 1
  %6 = sext i32 %5 to i64
  %7 = getelementptr inbounds [2 x ptr], ptr @gotos.t, i64 0, i64 %6
  %8 = load ptr, ptr %7, align 8
  br label %13

9:                                                ; preds = %13
  store i32 1, ptr %2, align 4
  br label %11

10:                                               ; preds = %13
  store i32 2, ptr %2, align 4
  br label %11

11:                                               ; preds = %10, %9
  %12 = load i32, ptr %2, align 4
  ret i32 %12

13:                                               ; preds = %1
  %14 = phi ptr [ %8, %1 ]
  indirectbr ptr %14, [label %9, label %10]
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @asmf(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = call i32 asm sideeffect "bswap $0", "=r,0,~{memory},~{dirflag},~{fpsr},~{flags}"(i32 %4) #3, !srcloc !6
  store i32 %5, ptr %3, align 4
  %6 = load i32, ptr %3, align 4
  ret i32 %6
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @ga(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  %4 = load i32, ptr %3, align 4
  callbr void asm sideeffect "jmp ${1:l}", "r,!i,~{dirflag},~{fpsr},~{flags}"(i32 %4) #3
          to label %5 [label %6], !srcloc !7

5:                                                ; preds = %1
  store i32 0, ptr %2, align 4
  br label %7

6:                                                ; preds = %1
  store i32 1, ptr %2, align 4
  br label %7

7:                                                ; preds = %6, %5
  %8 = load i32, ptr %2, align 4
  ret i32 %8
}

; Function Attrs: noinline nounwind optnone uwtable
define weak dso_local void @wk() #0 {
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @target_alias() #0 {
  ret i32 0
}

; Function Attrs: disable_sanitizer_instrumentation noinline nounwind optnone uwtable
define internal ptr @resolve() #2 {
  ret ptr @target_alias
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { disable_sanitizer_instrumentation noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!6 = !{i64 388}
!7 = !{i64 468}
