; The x86-64 description: what frames are made with (frame.rs), by role;
; none of it is selected for IR.
;
; The callee-saved registers are pushed and popped (roles push.r64 and
; pop.r64): one byte each, two with REX, where a store or load at an
; offset from rsp takes five or more.

define void @PUSH64r(i64 "reg"="r64" %r) "enc"="rex(0, 0, 0, r) | 01010 o:3=r&7" "asm"="pushq {r}" "role"="push.r64" "nomatch" "nodecode" {
  ret void
}

define i64 @POP64r() "enc"="rex(0, 0, 0, d) | 01011 o:3=d&7" "asm"="popq {d}" "role"="pop.r64" "nomatch" "nodecode" {
  ret i64 0
}

; The rest of the frame made and unmade by subtracting from and adding to
; rsp (roles frame.subi and frame.addi), with an 8-bit immediate where it
; fits: four bytes, where leaq takes eight. (They clobber the flags, which
; are dead where frames are made and unmade.)
define i64 @FRAMESUB64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(5, d) | ib:s8=imm ; rex(1, 0, 0, d) | 10000001 | rr(5, d) | iv:s32=imm }" "asm"="subq ${imm}, {d}" "clobbers"="flags" "role"="frame.subi" "nomatch" "nodecode" {
  %r = sub i64 %n, %imm
  ret i64 %r
}

define i64 @FRAMEADD64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(0, d) | ib:s8=imm ; rex(1, 0, 0, d) | 10000001 | rr(0, d) | iv:s32=imm }" "asm"="addq ${imm}, {d}" "clobbers"="flags" "role"="frame.addi" "nomatch" "nodecode" {
  %r = add i64 %n, %imm
  ret i64 %r
}
