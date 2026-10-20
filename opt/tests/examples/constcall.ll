; draconian-opt: --passes=combine --no-inline
; Calls on constants worked out by following the callee: a recursive call
; that returns at once, and a loop that only computes. A path that stores
; keeps its call, and so does one with an argument not known.

define i64 @twist(i64 %a, i64 %n) {
entry:
  %stop = icmp sle i64 %n, 0
  br i1 %stop, label %done, label %more

more:
  call void @effect()
  %m = sub i64 %n, 1
  %r = call i64 @twist(i64 %a, i64 %m)
  %z = call i64 @twist(i64 0, i64 0)
  %s = add i64 %r, %z
  ret i64 %s

done:
  ret i64 %a
}

define i32 @sum_to(i32 %n) {
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i1, %loop ]
  %t = phi i32 [ 0, %entry ], [ %t1, %loop ]
  %i1 = add i32 %i, 1
  %t1 = add i32 %t, %i1
  %c = icmp slt i32 %i1, %n
  br i1 %c, label %loop, label %out

out:
  ret i32 %t1
}

define i32 @main() {
  %a = call i32 @sum_to(i32 10)
  %b = call i64 @twist(i64 5, i64 1)
  %b32 = trunc i64 %b to i32
  %r = add i32 %a, %b32
  ret i32 %r
}

@count = global i32 0

define void @effect() {
  %c = load i32, ptr @count
  %c1 = add i32 %c, 1
  store i32 %c1, ptr @count
  ret void
}
