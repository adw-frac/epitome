; @twist: combine: sub_const x1
; @twist: constcall: 1 calls worked out
; @twist: combine: add_zero x1
; @main: constcall: 1 calls worked out
; @main: combine: (constant to the right) x1


@count = global i32 0

define i64 @twist(i64 %a, i64 %n) {
entry:
  %stop = icmp sle i64 %n, 0
  br i1 %stop, label %done, label %more

more:                                             ; preds = %entry
  call void @effect()
  %m = add i64 %n, -1
  %r = call i64 @twist(i64 %a, i64 %m)
  ret i64 %r

done:                                             ; preds = %entry
  ret i64 %a
}

define i32 @sum_to(i32 %n) {
entry:
  br label %loop

loop:                                             ; preds = %loop, %entry
  %i = phi i32 [ 0, %entry ], [ %i1, %loop ]
  %t = phi i32 [ 0, %entry ], [ %t1, %loop ]
  %i1 = add i32 %i, 1
  %t1 = add i32 %t, %i1
  %c = icmp slt i32 %i1, %n
  br i1 %c, label %loop, label %out

out:                                              ; preds = %loop
  ret i32 %t1
}

define i32 @main() {
  %b = call i64 @twist(i64 5, i64 1)
  %b32 = trunc i64 %b to i32
  %r = add i32 %b32, 55
  ret i32 %r
}

define void @effect() {
  %c = load i32, ptr @count
  %c1 = add i32 %c, 1
  store i32 %c1, ptr @count
  ret void
}
