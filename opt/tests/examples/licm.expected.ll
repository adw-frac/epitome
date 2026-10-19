; @sum: licm: 2 moved out of loops (1 loads)
; @sum: indvars: loop %loop runs %n times when entered

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

@scale = global i32 3

define i32 @sum(ptr %a, ptr noalias %out, i64 %n, i32 %k) {
entry:
  %e0 = icmp sgt i64 %n, 0
  br i1 %e0, label %loop.preheader, label %done

loop.preheader:                                   ; preds = %entry
  %s = load i32, ptr @scale
  %m = mul i32 %s, %k
  br label %loop

loop:                                             ; preds = %loop, %loop.preheader
  %i = phi i64 [ %i1, %loop ], [ 0, %loop.preheader ]
  %acc = phi i32 [ %acc1, %loop ], [ 0, %loop.preheader ]
  %p = getelementptr inbounds i32, ptr %a, i64 %i
  %x = load i32, ptr %p
  %y = mul i32 %x, %m
  %acc1 = add i32 %acc, %y
  %o = getelementptr inbounds i32, ptr %out, i64 %i
  store i32 %y, ptr %o
  %i1 = add i64 %i, 1
  %c = icmp slt i64 %i1, %n
  br i1 %c, label %loop, label %done

done:                                             ; preds = %loop, %entry
  %r = phi i32 [ 0, %entry ], [ %acc1, %loop ]
  ret i32 %r
}
