; draconian-opt: -O2 --recursion=stack
; Regression: the cycle's members are noinline, so it is not collapsed;
; each member's own self-call is still removed.
declare i32 @printf(ptr, ...)
@fmt = private constant [4 x i8] c"%d\0A\00"
define internal i32 @a(i32 %n) noinline {
entry:
  %c = icmp sle i32 %n, 0
  br i1 %c, label %base, label %rec
base:
  ret i32 1
rec:
  %m = sub i32 %n, 1
  %x = call i32 @b(i32 %m)
  %y = call i32 @a(i32 %m)
  %s = add i32 %x, %y
  %s2 = urem i32 %s, 100003
  ret i32 %s2
}
define internal i32 @b(i32 %n) noinline {
entry:
  %c = icmp sle i32 %n, 0
  br i1 %c, label %base, label %rec
base:
  ret i32 2
rec:
  %m = sub i32 %n, 1
  %x = call i32 @c(i32 %m)
  %y = mul i32 %x, 3
  %z = call i32 @b(i32 %m)
  %s = add i32 %y, %z
  %s2 = urem i32 %s, 100003
  ret i32 %s2
}
define internal i32 @c(i32 %n) noinline {
entry:
  %buf = alloca [4 x i32]
  store i32 %n, ptr %buf
  %x = call i32 @a(i32 %n)
  %v = load i32, ptr %buf
  %s = add i32 %x, %v
  ret i32 %s
}
define i32 @main() {
  %v = call i32 @a(i32 15)
  call i32 (ptr, ...) @printf(ptr @fmt, i32 %v)
  %w = call i32 @b(i32 12)
  call i32 (ptr, ...) @printf(ptr @fmt, i32 %w)
  ret i32 0
}
