; The AArch64 description: arithmetic on extended registers, written by
; gen_extend.py. The conventions are in 00-base.ll.
;
; add/sub (extended register): the second operand is a 32-bit (or narrower)
; register, sign- or zero-extended and shifted left by 0 to 4:
;   sf op S 01011 00 1 Rm option imm3 Rn Rd
; with option uxtb 000, uxth 001, uxtw 010, sxtb 100, sxth 101, sxtw 110.
; The first operand and the result may be the stack pointer.

define i64 @ADDXrx_uxtb(i64 "reg"="xsp" %n, i8 "reg"="w" %m) "enc"="1 0 0 01011 00 1 m:5 000 000 n:5 d:5" "asm"="add {d}, {n}, {m}, uxtb" "dclass"="xsp" {
  %e = zext i8 %m to i64
  %r = add i64 %n, %e
  ret i64 %r
}

define i64 @ADDXrx_uxtbs(i64 "reg"="xsp" %n, i8 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 000 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, uxtb #{sh}" "dclass"="xsp" {
  %e = zext i8 %m to i64
  %s = shl i64 %e, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @ADDXrx_uxth(i64 "reg"="xsp" %n, i16 "reg"="w" %m) "enc"="1 0 0 01011 00 1 m:5 001 000 n:5 d:5" "asm"="add {d}, {n}, {m}, uxth" "dclass"="xsp" {
  %e = zext i16 %m to i64
  %r = add i64 %n, %e
  ret i64 %r
}

define i64 @ADDXrx_uxths(i64 "reg"="xsp" %n, i16 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 001 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, uxth #{sh}" "dclass"="xsp" {
  %e = zext i16 %m to i64
  %s = shl i64 %e, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @ADDXrx_uxtw(i64 "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="1 0 0 01011 00 1 m:5 010 000 n:5 d:5" "asm"="add {d}, {n}, {m}, uxtw" "dclass"="xsp" {
  %e = zext i32 %m to i64
  %r = add i64 %n, %e
  ret i64 %r
}

define i64 @ADDXrx_uxtws(i64 "reg"="xsp" %n, i32 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 010 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, uxtw #{sh}" "dclass"="xsp" {
  %e = zext i32 %m to i64
  %s = shl i64 %e, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @ADDXrx_sxtb(i64 "reg"="xsp" %n, i8 "reg"="w" %m) "enc"="1 0 0 01011 00 1 m:5 100 000 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtb" "dclass"="xsp" {
  %e = sext i8 %m to i64
  %r = add i64 %n, %e
  ret i64 %r
}

define i64 @ADDXrx_sxtbs(i64 "reg"="xsp" %n, i8 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 100 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtb #{sh}" "dclass"="xsp" {
  %e = sext i8 %m to i64
  %s = shl i64 %e, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @ADDXrx_sxth(i64 "reg"="xsp" %n, i16 "reg"="w" %m) "enc"="1 0 0 01011 00 1 m:5 101 000 n:5 d:5" "asm"="add {d}, {n}, {m}, sxth" "dclass"="xsp" {
  %e = sext i16 %m to i64
  %r = add i64 %n, %e
  ret i64 %r
}

define i64 @ADDXrx_sxths(i64 "reg"="xsp" %n, i16 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 101 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, sxth #{sh}" "dclass"="xsp" {
  %e = sext i16 %m to i64
  %s = shl i64 %e, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @ADDXrx_sxtw(i64 "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="1 0 0 01011 00 1 m:5 110 000 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtw" "dclass"="xsp" {
  %e = sext i32 %m to i64
  %r = add i64 %n, %e
  ret i64 %r
}

define i64 @ADDXrx_sxtws(i64 "reg"="xsp" %n, i32 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 110 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtw #{sh}" "dclass"="xsp" {
  %e = sext i32 %m to i64
  %s = shl i64 %e, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i32 @ADDWrx_uxtb(i32 "reg"="wsp" %n, i8 "reg"="w" %m) "enc"="0 0 0 01011 00 1 m:5 000 000 n:5 d:5" "asm"="add {d}, {n}, {m}, uxtb" "dclass"="wsp" {
  %e = zext i8 %m to i32
  %r = add i32 %n, %e
  ret i32 %r
}

define i32 @ADDWrx_uxtbs(i32 "reg"="wsp" %n, i8 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 00 1 m:5 000 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, uxtb #{sh}" "dclass"="wsp" {
  %e = zext i8 %m to i32
  %s = shl i32 %e, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i32 @ADDWrx_uxth(i32 "reg"="wsp" %n, i16 "reg"="w" %m) "enc"="0 0 0 01011 00 1 m:5 001 000 n:5 d:5" "asm"="add {d}, {n}, {m}, uxth" "dclass"="wsp" {
  %e = zext i16 %m to i32
  %r = add i32 %n, %e
  ret i32 %r
}

define i32 @ADDWrx_uxths(i32 "reg"="wsp" %n, i16 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 00 1 m:5 001 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, uxth #{sh}" "dclass"="wsp" {
  %e = zext i16 %m to i32
  %s = shl i32 %e, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i32 @ADDWrx_sxtb(i32 "reg"="wsp" %n, i8 "reg"="w" %m) "enc"="0 0 0 01011 00 1 m:5 100 000 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtb" "dclass"="wsp" {
  %e = sext i8 %m to i32
  %r = add i32 %n, %e
  ret i32 %r
}

define i32 @ADDWrx_sxtbs(i32 "reg"="wsp" %n, i8 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 00 1 m:5 100 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtb #{sh}" "dclass"="wsp" {
  %e = sext i8 %m to i32
  %s = shl i32 %e, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i32 @ADDWrx_sxth(i32 "reg"="wsp" %n, i16 "reg"="w" %m) "enc"="0 0 0 01011 00 1 m:5 101 000 n:5 d:5" "asm"="add {d}, {n}, {m}, sxth" "dclass"="wsp" {
  %e = sext i16 %m to i32
  %r = add i32 %n, %e
  ret i32 %r
}

define i32 @ADDWrx_sxths(i32 "reg"="wsp" %n, i16 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 00 1 m:5 101 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, sxth #{sh}" "dclass"="wsp" {
  %e = sext i16 %m to i32
  %s = shl i32 %e, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i64 @SUBXrx_uxtb(i64 "reg"="xsp" %n, i8 "reg"="w" %m) "enc"="1 1 0 01011 00 1 m:5 000 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxtb" "dclass"="xsp" {
  %e = zext i8 %m to i64
  %r = sub i64 %n, %e
  ret i64 %r
}

define i64 @SUBXrx_uxtbs(i64 "reg"="xsp" %n, i8 "reg"="w" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 1 m:5 000 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxtb #{sh}" "dclass"="xsp" {
  %e = zext i8 %m to i64
  %s = shl i64 %e, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrx_uxth(i64 "reg"="xsp" %n, i16 "reg"="w" %m) "enc"="1 1 0 01011 00 1 m:5 001 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxth" "dclass"="xsp" {
  %e = zext i16 %m to i64
  %r = sub i64 %n, %e
  ret i64 %r
}

define i64 @SUBXrx_uxths(i64 "reg"="xsp" %n, i16 "reg"="w" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 1 m:5 001 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxth #{sh}" "dclass"="xsp" {
  %e = zext i16 %m to i64
  %s = shl i64 %e, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrx_uxtw(i64 "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="1 1 0 01011 00 1 m:5 010 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxtw" "dclass"="xsp" {
  %e = zext i32 %m to i64
  %r = sub i64 %n, %e
  ret i64 %r
}

define i64 @SUBXrx_uxtws(i64 "reg"="xsp" %n, i32 "reg"="w" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 1 m:5 010 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxtw #{sh}" "dclass"="xsp" {
  %e = zext i32 %m to i64
  %s = shl i64 %e, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrx_sxtb(i64 "reg"="xsp" %n, i8 "reg"="w" %m) "enc"="1 1 0 01011 00 1 m:5 100 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxtb" "dclass"="xsp" {
  %e = sext i8 %m to i64
  %r = sub i64 %n, %e
  ret i64 %r
}

define i64 @SUBXrx_sxtbs(i64 "reg"="xsp" %n, i8 "reg"="w" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 1 m:5 100 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxtb #{sh}" "dclass"="xsp" {
  %e = sext i8 %m to i64
  %s = shl i64 %e, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrx_sxth(i64 "reg"="xsp" %n, i16 "reg"="w" %m) "enc"="1 1 0 01011 00 1 m:5 101 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxth" "dclass"="xsp" {
  %e = sext i16 %m to i64
  %r = sub i64 %n, %e
  ret i64 %r
}

define i64 @SUBXrx_sxths(i64 "reg"="xsp" %n, i16 "reg"="w" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 1 m:5 101 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxth #{sh}" "dclass"="xsp" {
  %e = sext i16 %m to i64
  %s = shl i64 %e, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrx_sxtw(i64 "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="1 1 0 01011 00 1 m:5 110 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxtw" "dclass"="xsp" {
  %e = sext i32 %m to i64
  %r = sub i64 %n, %e
  ret i64 %r
}

define i64 @SUBXrx_sxtws(i64 "reg"="xsp" %n, i32 "reg"="w" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 1 m:5 110 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxtw #{sh}" "dclass"="xsp" {
  %e = sext i32 %m to i64
  %s = shl i64 %e, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i32 @SUBWrx_uxtb(i32 "reg"="wsp" %n, i8 "reg"="w" %m) "enc"="0 1 0 01011 00 1 m:5 000 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxtb" "dclass"="wsp" {
  %e = zext i8 %m to i32
  %r = sub i32 %n, %e
  ret i32 %r
}

define i32 @SUBWrx_uxtbs(i32 "reg"="wsp" %n, i8 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 00 1 m:5 000 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxtb #{sh}" "dclass"="wsp" {
  %e = zext i8 %m to i32
  %s = shl i32 %e, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

define i32 @SUBWrx_uxth(i32 "reg"="wsp" %n, i16 "reg"="w" %m) "enc"="0 1 0 01011 00 1 m:5 001 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxth" "dclass"="wsp" {
  %e = zext i16 %m to i32
  %r = sub i32 %n, %e
  ret i32 %r
}

define i32 @SUBWrx_uxths(i32 "reg"="wsp" %n, i16 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 00 1 m:5 001 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, uxth #{sh}" "dclass"="wsp" {
  %e = zext i16 %m to i32
  %s = shl i32 %e, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

define i32 @SUBWrx_sxtb(i32 "reg"="wsp" %n, i8 "reg"="w" %m) "enc"="0 1 0 01011 00 1 m:5 100 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxtb" "dclass"="wsp" {
  %e = sext i8 %m to i32
  %r = sub i32 %n, %e
  ret i32 %r
}

define i32 @SUBWrx_sxtbs(i32 "reg"="wsp" %n, i8 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 00 1 m:5 100 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxtb #{sh}" "dclass"="wsp" {
  %e = sext i8 %m to i32
  %s = shl i32 %e, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

define i32 @SUBWrx_sxth(i32 "reg"="wsp" %n, i16 "reg"="w" %m) "enc"="0 1 0 01011 00 1 m:5 101 000 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxth" "dclass"="wsp" {
  %e = sext i16 %m to i32
  %r = sub i32 %n, %e
  ret i32 %r
}

define i32 @SUBWrx_sxths(i32 "reg"="wsp" %n, i16 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 00 1 m:5 101 imm3:3=sh%5 n:5 d:5" "asm"="sub {d}, {n}, {m}, sxth #{sh}" "dclass"="wsp" {
  %e = sext i16 %m to i32
  %s = shl i32 %e, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

; Sign extension of the low bits, written as a shift left and an arithmetic
; shift right by the same amount: sxtb, sxth and sxtw read the low bits.

define i32 @SXTBWsh(i32 "reg"="w" %n) "enc"="0 00 100110 0 000000 000111 n:5 d:5" "asm"="sxtb {d}, {n}" "nodecode" {
  %a = shl i32 %n, 24
  %r = ashr i32 %a, 24
  ret i32 %r
}

define i32 @SXTHWsh(i32 "reg"="w" %n) "enc"="0 00 100110 0 000000 001111 n:5 d:5" "asm"="sxth {d}, {n}" "nodecode" {
  %a = shl i32 %n, 16
  %r = ashr i32 %a, 16
  ret i32 %r
}

define i64 @SXTBXsh(i64 "reg"="x" %n) "enc"="1 00 100110 1 000000 000111 n:5 d:5" "asm"="sxtb {d}, {n:w}" "nodecode" {
  %a = shl i64 %n, 56
  %r = ashr i64 %a, 56
  ret i64 %r
}

define i64 @SXTHXsh(i64 "reg"="x" %n) "enc"="1 00 100110 1 000000 001111 n:5 d:5" "asm"="sxth {d}, {n:w}" "nodecode" {
  %a = shl i64 %n, 48
  %r = ashr i64 %a, 48
  ret i64 %r
}

define i64 @SXTWXsh(i64 "reg"="x" %n) "enc"="1 00 100110 1 000000 011111 n:5 d:5" "asm"="sxtw {d}, {n:w}" "nodecode" {
  %a = shl i64 %n, 32
  %r = ashr i64 %a, 32
  ret i64 %r
}

; Widening multiply-add and -subtract: 32-bit operands, extended, multiplied
; into 64 bits, plus or minus a 64-bit addend.
;   1 00 11011 U 01 Rm o0 Ra Rn Rd  (U: unsigned; o0: subtract)

define i64 @SMADDL(i32 "reg"="w" %n, i32 "reg"="w" %m, i64 "reg"="x" %a) "enc"="1 00 11011 001 m:5 0 a:5 n:5 d:5" "asm"="smaddl {d}, {n}, {m}, {a}" {
  %x = sext i32 %n to i64
  %y = sext i32 %m to i64
  %p = mul i64 %x, %y
  %r = add i64 %a, %p
  ret i64 %r
}

define i64 @SMSUBL(i32 "reg"="w" %n, i32 "reg"="w" %m, i64 "reg"="x" %a) "enc"="1 00 11011 001 m:5 1 a:5 n:5 d:5" "asm"="smsubl {d}, {n}, {m}, {a}" {
  %x = sext i32 %n to i64
  %y = sext i32 %m to i64
  %p = mul i64 %x, %y
  %r = sub i64 %a, %p
  ret i64 %r
}

define i64 @UMADDL(i32 "reg"="w" %n, i32 "reg"="w" %m, i64 "reg"="x" %a) "enc"="1 00 11011 101 m:5 0 a:5 n:5 d:5" "asm"="umaddl {d}, {n}, {m}, {a}" {
  %x = zext i32 %n to i64
  %y = zext i32 %m to i64
  %p = mul i64 %x, %y
  %r = add i64 %a, %p
  ret i64 %r
}

define i64 @UMSUBL(i32 "reg"="w" %n, i32 "reg"="w" %m, i64 "reg"="x" %a) "enc"="1 00 11011 101 m:5 1 a:5 n:5 d:5" "asm"="umsubl {d}, {n}, {m}, {a}" {
  %x = zext i32 %n to i64
  %y = zext i32 %m to i64
  %p = mul i64 %x, %y
  %r = sub i64 %a, %p
  ret i64 %r
}

