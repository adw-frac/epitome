; epitome-opt: --passes=combine
; Linear combinations: sums and differences of a value, scaled by constants,
; collected into one coefficient per value and a constant.
define i32 @many(i32 %x) {
  ; (x + 1) - (x + 3) + x - 2 * (x + 7)
  %a = add i32 %x, 1
  %b = add i32 %x, 3
  %c = sub i32 %a, %b
  %d = add i32 %c, %x
  %e = add i32 %x, 7
  %f = shl i32 %e, 1
  %g = sub i32 %d, %f
  ret i32 %g
}

; x * 3 - x * 2 is x; what is left of y is 4 * y.
define i64 @scaled(i64 %x, i64 %y) {
  %a = mul i64 %x, 3
  %b = mul i64 %x, 2
  %c = sub i64 %a, %b
  %d = shl i64 %y, 1
  %e = add i64 %c, %d
  %f = add i64 %e, %d
  ret i64 %f
}

; Only negative terms: the constant comes first.
define i32 @negative(i32 %x, i32 %y) {
  %a = sub i32 0, %x
  %b = sub i32 %a, %y
  %c = sub i32 %b, 5
  ret i32 %c
}

; A value with another use stays a leaf.
define i32 @shared(i32 %x, i32 %y) {
  %a = add i32 %x, %y
  %b = sub i32 %a, %x
  %c = mul i32 %a, %b
  ret i32 %c
}

define i32 @main() {
  %m = call i32 @many(i32 5)
  %s = call i64 @scaled(i64 2, i64 3)
  %s32 = trunc i64 %s to i32
  %n = call i32 @negative(i32 1, i32 2)
  %h = call i32 @shared(i32 3, i32 4)
  %t = add i32 %m, %s32
  %u = add i32 %t, %n
  %v = add i32 %u, %h
  %r = and i32 %v, 255
  ret i32 %r
}
