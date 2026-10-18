; smaugian-opt: -O2
; Regression: a blockaddress names %L in @caller, so inlining into
; @caller must not merge %L away, and @caller itself is not inlined.
declare i32 @printf(ptr, ...)
@fmt = private constant [4 x i8] c"%p\0A\00"
@tbl = global ptr blockaddress(@caller, %L)
define internal i32 @small(i32 %x) {
  %y = add i32 %x, 1
  ret i32 %y
}
define i32 @caller(i32 %a) {
entry:
  %v = call i32 @small(i32 %a)
  br label %L
L:
  ret i32 %v
}
define i32 @main() {
  %v = call i32 @caller(i32 1)
  ret i32 %v
}
