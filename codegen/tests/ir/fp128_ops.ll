; Quad precision (fp128), as the runtime does it (its functions from
; Rust's compiler_builtins, which the driver links): arithmetic, each
; comparison, conversions both ways, the sign, constants, selects, phis,
; and fp128 passed between functions.
target triple = "arm64-apple-macosx14.0.0"
define void @arith(ptr %o, ptr %a, ptr %b) {
  %x = load fp128, ptr %a
  %y = load fp128, ptr %b
  %r0 = fadd fp128 %x, %y
  %p0 = getelementptr fp128, ptr %o, i64 0
  store fp128 %r0, ptr %p0
  %r1 = fsub fp128 %x, %y
  %p1 = getelementptr fp128, ptr %o, i64 1
  store fp128 %r1, ptr %p1
  %r2 = fmul fp128 %x, %y
  %p2 = getelementptr fp128, ptr %o, i64 2
  store fp128 %r2, ptr %p2
  %r3 = fdiv fp128 %x, %y
  %p3 = getelementptr fp128, ptr %o, i64 3
  store fp128 %r3, ptr %p3
  %n = fneg fp128 %x
  %p4 = getelementptr fp128, ptr %o, i64 4
  store fp128 %n, ptr %p4
  %ab = call fp128 @llvm.fabs.f128(fp128 %x)
  %p5 = getelementptr fp128, ptr %o, i64 5
  store fp128 %ab, ptr %p5
  %cs = call fp128 @llvm.copysign.f128(fp128 %x, fp128 %y)
  %p6 = getelementptr fp128, ptr %o, i64 6
  store fp128 %cs, ptr %p6
  %c1 = fadd fp128 %x, 0xL00000000000000003FFF000000000000
  %p7 = getelementptr fp128, ptr %o, i64 7
  store fp128 %c1, ptr %p7
  ret void
}
define void @compare(ptr %o, ptr %a, ptr %b) {
  %x = load fp128, ptr %a
  %y = load fp128, ptr %b
  %c0 = fcmp oeq fp128 %x, %y
  %z0 = zext i1 %c0 to i8
  %q0 = getelementptr i8, ptr %o, i64 0
  store i8 %z0, ptr %q0
  %c1 = fcmp one fp128 %x, %y
  %z1 = zext i1 %c1 to i8
  %q1 = getelementptr i8, ptr %o, i64 1
  store i8 %z1, ptr %q1
  %c2 = fcmp olt fp128 %x, %y
  %z2 = zext i1 %c2 to i8
  %q2 = getelementptr i8, ptr %o, i64 2
  store i8 %z2, ptr %q2
  %c3 = fcmp ole fp128 %x, %y
  %z3 = zext i1 %c3 to i8
  %q3 = getelementptr i8, ptr %o, i64 3
  store i8 %z3, ptr %q3
  %c4 = fcmp ogt fp128 %x, %y
  %z4 = zext i1 %c4 to i8
  %q4 = getelementptr i8, ptr %o, i64 4
  store i8 %z4, ptr %q4
  %c5 = fcmp oge fp128 %x, %y
  %z5 = zext i1 %c5 to i8
  %q5 = getelementptr i8, ptr %o, i64 5
  store i8 %z5, ptr %q5
  %c6 = fcmp ord fp128 %x, %y
  %z6 = zext i1 %c6 to i8
  %q6 = getelementptr i8, ptr %o, i64 6
  store i8 %z6, ptr %q6
  %c7 = fcmp uno fp128 %x, %y
  %z7 = zext i1 %c7 to i8
  %q7 = getelementptr i8, ptr %o, i64 7
  store i8 %z7, ptr %q7
  %c8 = fcmp ueq fp128 %x, %y
  %z8 = zext i1 %c8 to i8
  %q8 = getelementptr i8, ptr %o, i64 8
  store i8 %z8, ptr %q8
  %c9 = fcmp une fp128 %x, %y
  %z9 = zext i1 %c9 to i8
  %q9 = getelementptr i8, ptr %o, i64 9
  store i8 %z9, ptr %q9
  %c10 = fcmp ult fp128 %x, %y
  %z10 = zext i1 %c10 to i8
  %q10 = getelementptr i8, ptr %o, i64 10
  store i8 %z10, ptr %q10
  %c11 = fcmp ule fp128 %x, %y
  %z11 = zext i1 %c11 to i8
  %q11 = getelementptr i8, ptr %o, i64 11
  store i8 %z11, ptr %q11
  %c12 = fcmp ugt fp128 %x, %y
  %z12 = zext i1 %c12 to i8
  %q12 = getelementptr i8, ptr %o, i64 12
  store i8 %z12, ptr %q12
  %c13 = fcmp uge fp128 %x, %y
  %z13 = zext i1 %c13 to i8
  %q13 = getelementptr i8, ptr %o, i64 13
  store i8 %z13, ptr %q13
  ret void
}
define void @convert(ptr %o, ptr %a, ptr %d) {
  %x = load fp128, ptr %a
  %v = load double, ptr %d
  %t0 = fptrunc fp128 %x to double
  store double %t0, ptr %o
  %t1 = fptrunc fp128 %x to float
  %p1 = getelementptr i8, ptr %o, i64 8
  store float %t1, ptr %p1
  %t2 = fptrunc fp128 %x to half
  %p2 = getelementptr i8, ptr %o, i64 12
  store half %t2, ptr %p2
  %e0 = fpext double %v to fp128
  %p3 = getelementptr i8, ptr %o, i64 16
  store fp128 %e0, ptr %p3
  %f = fptrunc double %v to float
  %e1 = fpext float %f to fp128
  %p4 = getelementptr i8, ptr %o, i64 32
  store fp128 %e1, ptr %p4
  %i0 = fptosi fp128 %e0 to i64
  %p5 = getelementptr i8, ptr %o, i64 48
  store i64 %i0, ptr %p5
  %i1 = fptosi fp128 %e0 to i32
  %p6 = getelementptr i8, ptr %o, i64 56
  store i32 %i1, ptr %p6
  %i2 = fptosi fp128 %e0 to i128
  %p7 = getelementptr i8, ptr %o, i64 64
  store i128 %i2, ptr %p7
  %s0 = sitofp i64 %i0 to fp128
  %p8 = getelementptr i8, ptr %o, i64 80
  store fp128 %s0, ptr %p8
  %s1 = uitofp i32 %i1 to fp128
  %p9 = getelementptr i8, ptr %o, i64 96
  store fp128 %s1, ptr %p9
  %s2 = sitofp i128 %i2 to fp128
  %p10 = getelementptr i8, ptr %o, i64 112
  store fp128 %s2, ptr %p10
  ret void
}
; Passed to, and returned from, a function of the module; a select and a
; phi of them.
define internal fp128 @mid(fp128 %a, fp128 %b, i1 %c) noinline {
  %s = fadd fp128 %a, %b
  %h = fmul fp128 %s, 0xL00000000000000003FFE000000000000
  %r = select i1 %c, fp128 %h, fp128 %a
  ret fp128 %r
}
define void @calls(ptr %o, ptr %a, ptr %b, i32 %n) {
entry:
  %x = load fp128, ptr %a
  %y = load fp128, ptr %b
  br label %loop
loop:
  %acc = phi fp128 [ %x, %entry ], [ %next, %loop ]
  %k = phi i32 [ 0, %entry ], [ %k1, %loop ]
  %odd = trunc i32 %k to i1
  %next = call fp128 @mid(fp128 %acc, fp128 %y, i1 %odd)
  %k1 = add i32 %k, 1
  %done = icmp eq i32 %k1, %n
  br i1 %done, label %out, label %loop
out:
  store fp128 %next, ptr %o
  ret void
}
declare fp128 @llvm.fabs.f128(fp128)
declare fp128 @llvm.copysign.f128(fp128, fp128)
