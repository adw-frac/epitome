; The x86-64 description: short forms that peephole.rs puts in place of
; longer ones where the flags they clobber are dead. Not selected.
;
; Zero by xor of a register with itself (role zero.<class>): two bytes,
; three with REX, where a move of 0 takes five. A 32-bit write clears the
; register's top half, so it zeroes 64-bit registers too.

define i32 @ZERO32r() "enc"="rex(0, d, 0, d) | 00110001 | rr(d, d)" "asm"="xorl {d}, {d}" "clobbers"="flags" "zext"="32" "role"="zero.r32" "nomatch" "nodecode" {
  ret i32 0
}

define i64 @ZERO64r() "enc"="rex(0, d, 0, d) | 00110001 | rr(d, d)" "asm"="xorl {d:r32}, {d:r32}" "clobbers"="flags" "role"="zero.r64" "nomatch" "nodecode" {
  ret i64 0
}
