; draconian-opt: -O2
; Regression: a weak definition may be replaced at link time, so it is
; not inlined.
declare i32 @printf(ptr, ...)
@fmt = private constant [4 x i8] c"%d\0A\00"
define weak i32 @get() {
  ret i32 1
}
define i32 @main() {
  %v = call i32 @get()
  call i32 (ptr, ...) @printf(ptr @fmt, i32 %v)
  ret i32 0
}
