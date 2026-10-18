; smaugian-opt: --no-inline
; Regression: a switch reaches %done twice from %entry, so every phi the
; recursion pass adds there needs two entries for %entry, one per edge.
declare i32 @printf(ptr, ...)
@fmt = private constant [4 x i8] c"%d\0A\00"

define internal i32 @f(i32 %n) {
entry:
  switch i32 %n, label %rec [ i32 0, label %done
                              i32 1, label %done ]
rec:
  %a = sub i32 %n, 1
  %r = call i32 @f(i32 %a)
  %s = add i32 %r, %n
  br label %done
done:
  %p = phi i32 [ 0, %entry ], [ 0, %entry ], [ %s, %rec ]
  ret i32 %p
}

define i32 @main() {
  %v = call i32 @f(i32 100)
  call i32 (ptr, ...) @printf(ptr @fmt, i32 %v)
  ret i32 0
}
