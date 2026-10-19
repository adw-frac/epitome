; @factor: combine: (dead) x2, factor_add_mul x1
; @mul_plus_self: combine: (dead) x1, add_mul_self x1, mul_pow2 x1
; @bits: combine: (dead) x4, add_and_or x1, add_xor_and x1
; @distribute: combine: (dead) x2, factor_or_and x1


define i32 @factor(i32 %x, i32 %y, i32 %z) {
  %1 = add i32 %y, %z
  %s = mul i32 %x, %1
  ret i32 %s
}

define i32 @mul_plus_self(i32 %x) {
  %s = shl i32 %x, 3
  ret i32 %s
}

define i32 @bits(i32 %x, i32 %y) {
  %s = add i32 %y, %x
  %t = or i32 %y, %x
  %r = xor i32 %s, %t
  ret i32 %r
}

define i32 @distribute(i32 %x, i32 %y, i32 %z) {
  %1 = or i32 %y, %z
  %o = and i32 %x, %1
  ret i32 %o
}
