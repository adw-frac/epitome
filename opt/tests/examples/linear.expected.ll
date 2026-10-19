; @many: combine: (constant to the right) x1, (dead) x5, (folded) x1, (linear) x1, sub_add_add x1
; @scaled: combine: (dead) x6, (linear) x2, mul_pow2 x1
; @negative: combine: (dead) x2, (linear) x1, sub_const x1
; @shared: combine: sub_add_cancel x1


define i32 @many(i32 %x) {
  %g = sub i32 -16, %x
  ret i32 %g
}

define i64 @scaled(i64 %x, i64 %y) {
  %1 = shl i64 %y, 2
  %f = add i64 %x, %1
  ret i64 %f
}

define i32 @negative(i32 %x, i32 %y) {
  %1 = sub i32 -5, %x
  %c = sub i32 %1, %y
  ret i32 %c
}

define i32 @shared(i32 %x, i32 %y) {
  %a = add i32 %x, %y
  %c = mul i32 %a, %y
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
