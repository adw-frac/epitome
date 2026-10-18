; smaugian-opt: --no-inline
; Regression: a musttail call must stay right before its ret. The stack
; transform reroutes every ret, so @f is left recursive.
declare i32 @printf(ptr, ...)
@fmt = private constant [4 x i8] c"%d\0A\00"
define internal i32 @g(i32 %n) noinline {
  %r = add i32 %n, 1000
  ret i32 %r
}
define internal i32 @f(i32 %n) noinline {
entry:
  %c = icmp sle i32 %n, 0
  br i1 %c, label %base, label %rec
base:
  %t = musttail call i32 @g(i32 %n)
  ret i32 %t
rec:
  %a = sub i32 %n, 1
  %r = call i32 @f(i32 %a)
  %s = add i32 %r, %n
  ret i32 %s
}
define i32 @main() {
  %v = call i32 @f(i32 10)
  call i32 (ptr, ...) @printf(ptr @fmt, i32 %v)
  ret i32 0
}
