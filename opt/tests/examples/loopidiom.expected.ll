; @fill: rotate: 2 loops rotated
; @fill: combine: (folded) x2, br_true x2
; @fill: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 2 blocks merged
; @fill: licm: 1 moved out of loops (0 loads)
; @fill: indvars: loop %col runs 10 times when entered
; @fill: indvars: loop %cols.preheader runs 4 times when entered
; @fill: loopidiom: 1 loops made memsets
; @fill: combine: (dead) x3, (folded) x4, add_zero x1, mul_mul_const x1
; @fill: simplifycfg: 0 unreachable blocks removed, 1 empty blocks bypassed, 0 selects made, 1 blocks merged
; @fill: loopidiom: 1 loops made memsets
; @fill: combine: (dead) x2, (folded) x5
; @fill: simplifycfg: 0 unreachable blocks removed, 1 empty blocks bypassed, 0 selects made, 1 blocks merged
; @ones: indvars: loop %loop runs %n times when entered
; @ones: indvars: 1 exact exit tests, 0 exit values, 0 counters widened
; @ones: loopidiom: 1 loops made memsets
; @ones: combine: (dead) x2, (folded) x2, mul_pow2 x1, sub_zero x1
; @ones: simplifycfg: 0 unreachable blocks removed, 1 empty blocks bypassed, 0 selects made, 0 blocks merged
; @not_a_byte: indvars: loop %loop runs 16 times when entered
; @copy_and_clear: indvars: loop %loop runs 16 times when entered
; @main: not inlined @fill: noinline
; @main: not inlined @ones: noinline
; @main: not inlined @not_a_byte: noinline
; @main: not inlined @copy_and_clear: noinline


@grid = global [4 x [10 x float]] zeroinitializer
@row = global [16 x i32] zeroinitializer
@other = global [16 x i32] zeroinitializer

define void @fill(ptr %p) noinline {
entry:
  tail call void @llvm.memset.p0.i64(ptr %p, i8 0, i64 160, i1 false)
  ret void
}

define void @ones(ptr %p, i64 %n) noinline {
entry:
  %any = icmp sgt i64 %n, 0
  br i1 %any, label %loop.preheader, label %done

loop.preheader:                                   ; preds = %entry
  %0 = shl i64 %n, 2
  tail call void @llvm.memset.p0.i64(ptr %p, i8 -1, i64 %0, i1 false)
  br label %done

done:                                             ; preds = %loop.preheader, %entry
  ret void
}

define void @not_a_byte(ptr %p) noinline {
entry:
  br label %loop

loop:                                             ; preds = %loop, %entry
  %k = phi i64 [ 0, %entry ], [ %k.next, %loop ]
  %a = getelementptr i32, ptr %p, i64 %k
  store i32 1, ptr %a
  %k.next = add i64 %k, 1
  %again = icmp slt i64 %k.next, 16
  br i1 %again, label %loop, label %done

done:                                             ; preds = %loop
  ret void
}

define void @copy_and_clear(ptr %p, ptr %q) noinline {
entry:
  br label %loop

loop:                                             ; preds = %loop, %entry
  %k = phi i64 [ 0, %entry ], [ %k.next, %loop ]
  %a = getelementptr i32, ptr %p, i64 %k
  %b = getelementptr i32, ptr %q, i64 %k
  %x = load i32, ptr %a
  store i32 %x, ptr %b
  store i32 0, ptr %a
  %k.next = add i64 %k, 1
  %again = icmp slt i64 %k.next, 16
  br i1 %again, label %loop, label %done

done:                                             ; preds = %loop
  ret void
}

define i32 @main() {
entry:
  store float 3.000000e+00, ptr getelementptr (float, ptr @grid, i64 17)
  tail call void @fill(ptr @grid)
  %g = load float, ptr getelementptr (float, ptr @grid, i64 17)
  %gz = fcmp oeq float %g, 0.000000e+00
  tail call void @ones(ptr @row, i64 5)
  %r4 = load i32, ptr getelementptr (i32, ptr @row, i64 4)
  %r5 = load i32, ptr getelementptr (i32, ptr @row, i64 5)
  tail call void @not_a_byte(ptr @other)
  %o = load i32, ptr getelementptr (i32, ptr @other, i64 15)
  tail call void @copy_and_clear(ptr @other, ptr @row)
  %c = load i32, ptr getelementptr (i32, ptr @row, i64 15)
  %z = load i32, ptr getelementptr (i32, ptr @other, i64 15)
  %s1 = add i32 %r4, %r5
  %s2 = add i32 %s1, %o
  %s3 = add i32 %s2, %c
  %s4 = add i32 %s3, %z
  %gi = select i1 %gz, i32 10, i32 0
  %s = add i32 %s4, %gi
  ret i32 %s
}

declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
