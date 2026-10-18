; @main: not inlined @get: its definition may be replaced at link time


@fmt = private constant [4 x i8] c"%d\0A\00"

declare i32 @printf(ptr, ...)

define weak i32 @get() {
  ret i32 1
}

define i32 @main() {
  %v = call i32 @get()
  %1 = call i32 (ptr, ...) @printf(ptr @fmt, i32 %v)
  ret i32 0
}
