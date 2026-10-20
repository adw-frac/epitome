; epitome-opt: --passes=loops
; licm: a load of a global nothing in the loop writes, and arithmetic on
; it, move to a new preheader; the load that changes each time stays.
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
@scale = global i32 3
define i32 @sum(ptr %a, ptr noalias %out, i64 %n, i32 %k) {
entry:
  %e0 = icmp sgt i64 %n, 0
  br i1 %e0, label %loop, label %done
loop:
  %i = phi i64 [ 0, %entry ], [ %i1, %loop ]
  %acc = phi i32 [ 0, %entry ], [ %acc1, %loop ]
  %s = load i32, ptr @scale          ; nothing in the loop writes @scale
  %m = mul i32 %s, %k                ; invariant arithmetic
  %p = getelementptr inbounds i32, ptr %a, i64 %i
  %x = load i32, ptr %p              ; varies
  %y = mul i32 %x, %m
  %acc1 = add i32 %acc, %y
  %o = getelementptr inbounds i32, ptr %out, i64 %i
  store i32 %y, ptr %o               ; to noalias %out: not @scale
  %i1 = add i64 %i, 1
  %c = icmp slt i64 %i1, %n
  br i1 %c, label %loop, label %done
done:
  %r = phi i32 [ 0, %entry ], [ %acc1, %loop ]
  ret i32 %r
}
