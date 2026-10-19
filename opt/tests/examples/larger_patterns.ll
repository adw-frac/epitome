; draconian-opt: --passes=combine
; Larger patterns: factoring a common operand out, and identities of the
; and, or and xor of the same two values.
define i32 @factor(i32 %x, i32 %y, i32 %z) {
  %a = mul i32 %x, %y
  %b = mul i32 %x, %z
  %s = add i32 %a, %b
  ret i32 %s
}

define i32 @mul_plus_self(i32 %x) {
  %a = mul i32 %x, 7
  %s = add i32 %a, %x
  ret i32 %s
}

define i32 @bits(i32 %x, i32 %y) {
  %a = and i32 %x, %y
  %o = or i32 %x, %y
  %s = add i32 %a, %o
  %x1 = xor i32 %x, %y
  %a1 = and i32 %x, %y
  %t = add i32 %x1, %a1
  %r = xor i32 %s, %t
  ret i32 %r
}

define i32 @distribute(i32 %x, i32 %y, i32 %z) {
  %a = and i32 %x, %y
  %b = and i32 %x, %z
  %o = or i32 %a, %b
  ret i32 %o
}
