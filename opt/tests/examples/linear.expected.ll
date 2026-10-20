; @many: combine: (constant to the right) x1, (dead) x5, (folded) x1, (linear) x1, sub_add_add x1
; @scaled: combine: (dead) x6, (linear) x2, mul_pow2 x1
; @negative: combine: (dead) x2, (linear) x1, sub_const x1
; @shared: combine: sub_add_cancel x1
; @main: constcall: 4 calls worked out
; @main: combine: (folded) x5


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
  ret i32 13
}
