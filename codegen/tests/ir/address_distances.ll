; Pointers as integers, of values and of constants, and the distance
; between two places in one global as a number in data.
target triple = "arm64-apple-macosx14.0.0"
@g = global [4 x i64] [i64 1, i64 2, i64 3, i64 4]
@d = global i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @g, i64 24) to i64), i64 ptrtoint (ptr @g to i64))
define i64 @dist(ptr %p) {
  %a = ptrtoint ptr %p to i64
  %b = sub i64 %a, ptrtoint (ptr @g to i64)
  ret i64 %b
}
define i64 @stored() {
  %v = load i64, ptr @d
  ret i64 %v
}
define ptr @at(i64 %k) {
  %p = getelementptr i64, ptr @g, i64 %k
  ret ptr %p
}
