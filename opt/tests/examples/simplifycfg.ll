; smaugian-opt: --passes=combine,simplifycfg
; Control-flow simplification: branches fold in the combiner, and the
; graph is tidied after.

; A branch on a comparison that folds once a constant is known, and the
; arm that can no longer run disappears.
define i32 @known(i32 %x) {
entry:
  %k = add i32 2, 3
  %c = icmp eq i32 %k, 5
  br i1 %c, label %yes, label %no
yes:
  %a = add i32 %x, 1
  br label %done
no:
  %b = mul i32 %x, 7
  br label %done
done:
  %r = phi i32 [ %a, %yes ], [ %b, %no ]
  ret i32 %r
}

; A switch on a constant.
define i32 @switched(i32 %x) {
entry:
  switch i32 2, label %other [
    i32 1, label %one
    i32 2, label %two
  ]
one:
  ret i32 10
two:
  %t = add i32 %x, 20
  ret i32 %t
other:
  ret i32 30
}

; Arms that only choose a value: a diamond and a triangle become selects.
define i32 @max(i32 %a, i32 %b) {
entry:
  %c = icmp sgt i32 %a, %b
  br i1 %c, label %left, label %right
left:
  br label %join
right:
  br label %join
join:
  %m = phi i32 [ %a, %left ], [ %b, %right ]
  ret i32 %m
}

define i32 @clamp_low(i32 %x) {
entry:
  %neg = icmp slt i32 %x, 0
  br i1 %neg, label %zero, label %join
zero:
  br label %join
join:
  %r = phi i32 [ 0, %zero ], [ %x, %entry ]
  ret i32 %r
}

; A negated condition swaps the targets; an empty block in a loop is
; bypassed.
define i32 @count(i32 %n) {
entry:
  br label %head
head:
  %i = phi i32 [ 0, %entry ], [ %next, %latch ]
  %done = icmp sge i32 %i, %n
  %go = xor i1 %done, true
  br i1 %go, label %body, label %exit
body:
  %next = add i32 %i, 1
  br label %latch
latch:
  br label %head
exit:
  ret i32 %i
}
