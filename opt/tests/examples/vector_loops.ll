; Vectorized loops as linalg-vectorize writes them: element-wise over
; three arrays four floats at a time, indexed by a row's offset plus the
; counter; and a row's sum with four vectors of partial results, read at
; the counter plus 0, 4, 8 and 12. lsr steps one pointer for each array
; (loads and stores at constant offsets from it), indvars makes the
; exit tests exact for the step of 4, and the counters count down.

@a = global [98304 x float] zeroinitializer
@b = global [98304 x float] zeroinitializer
@c = global [98304 x float] zeroinitializer
@s = global [64 x float] zeroinitializer


define void @mul(ptr %0, ptr %1, ptr %2) {
  br label %4

4:                                                ; preds = %28, %3
  %5 = phi i64 [ 0, %3 ], [ %29, %28 ]
  %6 = icmp slt i64 %5, 64
  br i1 %6, label %7, label %30

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %11, %7
  %9 = phi i64 [ 0, %7 ], [ %27, %11 ]
  %10 = icmp slt i64 %9, 1536
  br i1 %10, label %11, label %28

11:                                               ; preds = %8
  %12 = mul i64 %5, 1536
  %13 = add i64 0, %12
  %14 = add i64 %13, %9
  %15 = getelementptr float, ptr %0, i64 %14
  %16 = load <4 x float>, ptr %15, align 4
  %17 = mul i64 %5, 1536
  %18 = add i64 0, %17
  %19 = add i64 %18, %9
  %20 = getelementptr float, ptr %1, i64 %19
  %21 = load <4 x float>, ptr %20, align 4
  %22 = fmul <4 x float> %16, %21
  %23 = mul i64 %5, 1536
  %24 = add i64 0, %23
  %25 = add i64 %24, %9
  %26 = getelementptr float, ptr %2, i64 %25
  store <4 x float> %22, ptr %26, align 4
  %27 = add i64 %9, 4
  br label %8

28:                                               ; preds = %8
  %29 = add i64 %5, 1
  br label %4

30:                                               ; preds = %4
  ret void
}

define void @sum(ptr %0, ptr %1) {
  br label %3

3:                                                ; preds = %47, %2
  %4 = phi i64 [ 0, %2 ], [ %62, %47 ]
  %5 = icmp slt i64 %4, 64
  br i1 %5, label %6, label %63

6:                                                ; preds = %3
  %7 = add i64 0, %4
  %8 = add i64 %7, 0
  %9 = getelementptr float, ptr %1, i64 %8
  %10 = load float, ptr %9
  br label %11

11:                                               ; preds = %18, %6
  %12 = phi i64 [ 0, %6 ], [ %46, %18 ]
  %13 = phi <4 x float> [ <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %6 ], [ %24, %18 ]
  %14 = phi <4 x float> [ <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %6 ], [ %31, %18 ]
  %15 = phi <4 x float> [ <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %6 ], [ %38, %18 ]
  %16 = phi <4 x float> [ <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, %6 ], [ %45, %18 ]
  %17 = icmp slt i64 %12, 576
  br i1 %17, label %18, label %47

18:                                               ; preds = %11
  %19 = mul i64 %4, 576
  %20 = add i64 0, %19
  %21 = add i64 %20, %12
  %22 = getelementptr float, ptr %0, i64 %21
  %23 = load <4 x float>, ptr %22, align 4
  %24 = fadd <4 x float> %23, %13
  %25 = add i64 %12, 4
  %26 = mul i64 %4, 576
  %27 = add i64 0, %26
  %28 = add i64 %27, %25
  %29 = getelementptr float, ptr %0, i64 %28
  %30 = load <4 x float>, ptr %29, align 4
  %31 = fadd <4 x float> %30, %14
  %32 = add i64 %12, 8
  %33 = mul i64 %4, 576
  %34 = add i64 0, %33
  %35 = add i64 %34, %32
  %36 = getelementptr float, ptr %0, i64 %35
  %37 = load <4 x float>, ptr %36, align 4
  %38 = fadd <4 x float> %37, %15
  %39 = add i64 %12, 12
  %40 = mul i64 %4, 576
  %41 = add i64 0, %40
  %42 = add i64 %41, %39
  %43 = getelementptr float, ptr %0, i64 %42
  %44 = load <4 x float>, ptr %43, align 4
  %45 = fadd <4 x float> %44, %16
  %46 = add i64 %12, 16
  br label %11

47:                                               ; preds = %11
  %48 = fadd <4 x float> %13, %14
  %49 = fadd <4 x float> %15, %16
  %50 = fadd <4 x float> %48, %49
  %51 = extractelement <4 x float> %50, i64 0
  %52 = extractelement <4 x float> %50, i64 1
  %53 = extractelement <4 x float> %50, i64 2
  %54 = extractelement <4 x float> %50, i64 3
  %55 = fadd float %51, %52
  %56 = fadd float %53, %54
  %57 = fadd float %55, %56
  %58 = fadd float %57, %10
  %59 = add i64 0, %4
  %60 = add i64 %59, 0
  %61 = getelementptr float, ptr %1, i64 %60
  store float %58, ptr %61
  %62 = add i64 %4, 1
  br label %3

63:                                               ; preds = %3
  ret void
}

define i32 @main() {
entry:
  br label %fill

fill:
  %i = phi i64 [ 0, %entry ], [ %i.next, %fill ]
  %k = urem i64 %i, 7
  %kf = uitofp i64 %k to float
  %pa = getelementptr float, ptr @a, i64 %i
  store float %kf, ptr %pa
  %pb = getelementptr float, ptr @b, i64 %i
  %kb = fadd float %kf, 1.000000e+00
  store float %kb, ptr %pb
  %i.next = add i64 %i, 1
  %more = icmp ult i64 %i.next, 98304
  br i1 %more, label %fill, label %run

run:
  call void @mul(ptr @a, ptr @b, ptr @c)
  call void @sum(ptr @c, ptr @s)
  %p = getelementptr float, ptr @s, i64 37
  %v = load float, ptr %p
  %r = fptosi float %v to i32
  %q = getelementptr float, ptr @c, i64 70000
  %w = load float, ptr %q
  %rw = fptosi float %w to i32
  %t = add i32 %r, %rw
  %m = urem i32 %t, 251
  ret i32 %m
}
