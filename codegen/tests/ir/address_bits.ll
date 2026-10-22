; Addresses made narrower, and floats of their bits, as constants
; (SROA makes these of enums whose fields share a place).
target triple = "arm64-apple-macosx14.0.0"
@g = global [2 x i64] zeroinitializer
define i32 @low(ptr %p) {
  %a = ptrtoint ptr %p to i32
  %r = sub i32 %a, ptrtoint (ptr @g to i32)
  ret i32 %r
}
define i32 @round_trip() {
  %f = fadd float bitcast (i32 ptrtoint (ptr @g to i32) to float), 0.0
  %i = bitcast float %f to i32
  %r = sub i32 %i, ptrtoint (ptr @g to i32)
  ret i32 %r
}
define float @pick(i1 %c, float %x) {
  %r = select i1 %c, float %x, float bitcast (i32 ptrtoint (ptr @g to i32) to float)
  ret float %r
}
define ptr @base() {
  ret ptr @g
}
