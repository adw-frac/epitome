; draconian-opt: --passes=combine,cse
; Reassociation: chains of one operation sorted by rank, constants outermost,
; so constants fold and chains with the same leaves become the same (CSE).
define i32 @f(i32 %a, i32 %b, i32 %c) {
  %x = add i32 %a, 3
  %y = add i32 %x, %b
  %z = add i32 %y, 5
  %p = add i32 %c, %a
  %q = add i32 %p, %b
  %r = add i32 %a, %b
  %s = add i32 %r, %c
  %t = xor i32 %q, %s
  %u = add i32 %t, %z
  ret i32 %u
}
