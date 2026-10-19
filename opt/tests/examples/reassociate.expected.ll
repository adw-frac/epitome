; @f: combine: (dead) x5, (reassociated) x2, add_add_const x1
; @f: cse: 3 merged, 0 loads reused, 0 stores forwarded
; @f: combine: (dead) x1, add_zero x1, xor_self x1


define i32 @f(i32 %a, i32 %b, i32 %c) {
  %1 = add i32 %a, %b
  %u = add i32 %1, 8
  ret i32 %u
}
