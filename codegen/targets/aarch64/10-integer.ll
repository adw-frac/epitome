; The AArch64 description: integer arithmetic, logic, shifts, extensions,
; moves and constants, and address arithmetic. The conventions are in
; 00-base.ll.

; ===========================================================================
; Arithmetic

define i32 @ADDWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="add {d}, {n}, {m}" {
  %r = add i32 %n, %m
  ret i32 %r
}

define i64 @ADDXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="add {d}, {n}, {m}" "role"="add" {
  %r = add i64 %n, %m
  ret i64 %r
}

define i32 @ADDWrs(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 00 0 m:5 imm6:6=sh%32 n:5 d:5" "asm"="add {d}, {n}, {m}, lsl #{sh}" {
  %s = shl i32 %m, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i64 @ADDXrs(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="add {d}, {n}, {m}, lsl #{sh}" {
  %s = shl i64 %m, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i32 @ADDWrs_lsr(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 01 0 m:5 imm6:6=sh%32 n:5 d:5" "asm"="add {d}, {n}, {m}, lsr #{sh}" {
  %s = lshr i32 %m, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i32 @ADDWrs_asr(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %sh) "enc"="0 0 0 01011 10 0 m:5 imm6:6=sh%32 n:5 d:5" "asm"="add {d}, {n}, {m}, asr #{sh}" {
  %s = ashr i32 %m, %sh
  %r = add i32 %n, %s
  ret i32 %r
}

define i32 @SUBWrs_lsr(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 01 0 m:5 imm6:6=sh%32 n:5 d:5" "asm"="sub {d}, {n}, {m}, lsr #{sh}" {
  %s = lshr i32 %m, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

define i32 @SUBWrs_asr(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 10 0 m:5 imm6:6=sh%32 n:5 d:5" "asm"="sub {d}, {n}, {m}, asr #{sh}" {
  %s = ashr i32 %m, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

; Multiplying by 2^k + 1 is adding a value to itself shifted left by k;
; the constant fits when log2(c - 1) is defined.
define i32 @ADDWmul(i32 "reg"="w" %n, i32 "imm" %c) "enc"="0 0 0 01011 00 0 m:5=n imm6:6=log2(c-1)%32 n:5 d:5" "asm"="add {d}, {n}, {n}, lsl #{=log2(c-1)}" "nodecode" {
  %r = mul i32 %n, %c
  ret i32 %r
}

; And by 1 - 2^k: subtracting it shifted from itself.
define i32 @SUBWmul(i32 "reg"="w" %n, i32 "imm" %c) "enc"="0 1 0 01011 00 0 m:5=n imm6:6=log2(1-c)%32 n:5 d:5" "asm"="sub {d}, {n}, {n}, lsl #{=log2(1-c)}" "nodecode" {
  %r = mul i32 %n, %c
  ret i32 %r
}

define i64 @ADDXrs_lsr(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 0 0 01011 01 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="add {d}, {n}, {m}, lsr #{sh}" {
  %s = lshr i64 %m, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @ADDXrs_asr(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 0 0 01011 10 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="add {d}, {n}, {m}, asr #{sh}" {
  %s = ashr i64 %m, %sh
  %r = add i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrs_lsr(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 1 0 01011 01 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="sub {d}, {n}, {m}, lsr #{sh}" {
  %s = lshr i64 %m, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i64 @SUBXrs_asr(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 1 0 01011 10 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="sub {d}, {n}, {m}, asr #{sh}" {
  %s = ashr i64 %m, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

; Multiplying by 2^k + 1 is adding a value to itself shifted left by k;
; the constant fits when log2(c - 1) is defined.
define i64 @ADDXmul(i64 "reg"="x" %n, i64 "imm" %c) "enc"="1 0 0 01011 00 0 m:5=n imm6:6=log2(c-1)%64 n:5 d:5" "asm"="add {d}, {n}, {n}, lsl #{=log2(c-1)}" "nodecode" {
  %r = mul i64 %n, %c
  ret i64 %r
}

; And by 1 - 2^k: subtracting it shifted from itself.
define i64 @SUBXmul(i64 "reg"="x" %n, i64 "imm" %c) "enc"="1 1 0 01011 00 0 m:5=n imm6:6=log2(1-c)%64 n:5 d:5" "asm"="sub {d}, {n}, {n}, lsl #{=log2(1-c)}" "nodecode" {
  %r = mul i64 %n, %c
  ret i64 %r
}

define i32 @ADDWri(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 0 0 100010 0 imm:12 n:5 d:5" "asm"="add {d}, {n}, #{imm}" "dclass"="wsp" {
  %r = add i32 %n, %imm
  ret i32 %r
}

define i64 @ADDXri(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 0 0 100010 0 imm:12 n:5 d:5" "asm"="add {d}, {n}, #{imm}" "dclass"="xsp" "role"="addi" {
  %r = add i64 %n, %imm
  ret i64 %r
}

; Immediates of whole 4KB pages, for large frames.
define i64 @ADDXri12(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 0 0 100010 1 imm12:12=imm/4096 n:5 d:5" "asm"="add {d}, {n}, #{=imm/4096}, lsl #12" "dclass"="xsp" "role"="addi12" {
  %r = add i64 %n, %imm
  ret i64 %r
}

define i64 @SUBXri12(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 1 0 100010 1 imm12:12=imm/4096 n:5 d:5" "asm"="sub {d}, {n}, #{=imm/4096}, lsl #12" "dclass"="xsp" "role"="subi12" {
  %r = sub i64 %n, %imm
  ret i64 %r
}

; add with a negative immediate is sub.
define i32 @SUBWri_neg(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 1 0 100010 0 imm12:12=0-imm n:5 d:5" "asm"="sub {d}, {n}, #{=0-imm}" "dclass"="wsp" "nodecode" {
  %r = add i32 %n, %imm
  ret i32 %r
}

define i64 @SUBXri_neg(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 1 0 100010 0 imm12:12=0-imm n:5 d:5" "asm"="sub {d}, {n}, #{=0-imm}" "dclass"="xsp" "nodecode" "role"="addi.neg" {
  %r = add i64 %n, %imm
  ret i64 %r
}

define i32 @SUBWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 1 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="sub {d}, {n}, {m}" {
  %r = sub i32 %n, %m
  ret i32 %r
}

define i64 @SUBXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 1 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="sub {d}, {n}, {m}" {
  %r = sub i64 %n, %m
  ret i64 %r
}

define i32 @SUBWrs(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %sh) "enc"="0 1 0 01011 00 0 m:5 imm6:6=sh%32 n:5 d:5" "asm"="sub {d}, {n}, {m}, lsl #{sh}" {
  %s = shl i32 %m, %sh
  %r = sub i32 %n, %s
  ret i32 %r
}

define i64 @SUBXrs(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 1 0 01011 00 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="sub {d}, {n}, {m}, lsl #{sh}" {
  %s = shl i64 %m, %sh
  %r = sub i64 %n, %s
  ret i64 %r
}

define i32 @SUBWri(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 1 0 100010 0 imm:12 n:5 d:5" "asm"="sub {d}, {n}, #{imm}" "dclass"="wsp" {
  %r = sub i32 %n, %imm
  ret i32 %r
}

define i64 @SUBXri(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 1 0 100010 0 imm:12 n:5 d:5" "asm"="sub {d}, {n}, #{imm}" "dclass"="xsp" "role"="subi" {
  %r = sub i64 %n, %imm
  ret i64 %r
}

define i32 @NEGW(i32 "reg"="w" %m) "enc"="0 1 0 01011 00 0 m:5 000000 11111 d:5" "asm"="neg {d}, {m}" {
  %r = sub i32 0, %m
  ret i32 %r
}

define i64 @NEGX(i64 "reg"="x" %m) "enc"="1 1 0 01011 00 0 m:5 000000 11111 d:5" "asm"="neg {d}, {m}" {
  %r = sub i64 0, %m
  ret i64 %r
}

define i32 @MULW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 00 11011 000 m:5 0 11111 n:5 d:5" "asm"="mul {d}, {n}, {m}" {
  %r = mul i32 %n, %m
  ret i32 %r
}

define i64 @MULX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 00 11011 000 m:5 0 11111 n:5 d:5" "asm"="mul {d}, {n}, {m}" {
  %r = mul i64 %n, %m
  ret i64 %r
}

define i32 @MADDW(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "reg"="w" %a) "enc"="0 00 11011 000 m:5 0 a:5 n:5 d:5" "asm"="madd {d}, {n}, {m}, {a}" {
  %p = mul i32 %n, %m
  %r = add i32 %p, %a
  ret i32 %r
}

define i64 @MADDX(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "reg"="x" %a) "enc"="1 00 11011 000 m:5 0 a:5 n:5 d:5" "asm"="madd {d}, {n}, {m}, {a}" {
  %p = mul i64 %n, %m
  %r = add i64 %p, %a
  ret i64 %r
}

define i32 @MSUBW(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "reg"="w" %a) "enc"="0 00 11011 000 m:5 1 a:5 n:5 d:5" "asm"="msub {d}, {n}, {m}, {a}" {
  %p = mul i32 %n, %m
  %r = sub i32 %a, %p
  ret i32 %r
}

define i64 @MSUBX(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "reg"="x" %a) "enc"="1 00 11011 000 m:5 1 a:5 n:5 d:5" "asm"="msub {d}, {n}, {m}, {a}" {
  %p = mul i64 %n, %m
  %r = sub i64 %a, %p
  ret i64 %r
}

; Division by zero gives 0 on AArch64; in IR it is undefined, so either is
; a correct reading.
; Widening and high multiplies, for division by constants. The 64-bit
; high halves are written with i128, which never needs a register: the
; whole tree is one instruction.
define i64 @SMULL(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="1 00 11011 001 m:5 0 11111 n:5 d:5" "asm"="smull {d}, {n}, {m}" {
  %a = sext i32 %n to i64
  %b = sext i32 %m to i64
  %r = mul i64 %a, %b
  ret i64 %r
}

define i64 @UMULL(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="1 00 11011 101 m:5 0 11111 n:5 d:5" "asm"="umull {d}, {n}, {m}" {
  %a = zext i32 %n to i64
  %b = zext i32 %m to i64
  %r = mul i64 %a, %b
  ret i64 %r
}

define i64 @SMULH(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 00 11011 010 m:5 0 11111 n:5 d:5" "asm"="smulh {d}, {n}, {m}" {
  %a = sext i64 %n to i128
  %b = sext i64 %m to i128
  %p = mul i128 %a, %b
  %h = lshr i128 %p, 64
  %r = trunc i128 %h to i64
  ret i64 %r
}

define i64 @UMULH(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 00 11011 110 m:5 0 11111 n:5 d:5" "asm"="umulh {d}, {n}, {m}" {
  %a = zext i64 %n to i128
  %b = zext i64 %m to i128
  %p = mul i128 %a, %b
  %h = lshr i128 %p, 64
  %r = trunc i128 %h to i64
  ret i64 %r
}

define i32 @SDIVW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 11010110 m:5 000011 n:5 d:5" "asm"="sdiv {d}, {n}, {m}" {
  %r = sdiv i32 %n, %m
  ret i32 %r
}

define i64 @SDIVX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 11010110 m:5 000011 n:5 d:5" "asm"="sdiv {d}, {n}, {m}" {
  %r = sdiv i64 %n, %m
  ret i64 %r
}

define i32 @UDIVW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 11010110 m:5 000010 n:5 d:5" "asm"="udiv {d}, {n}, {m}" {
  %r = udiv i32 %n, %m
  ret i32 %r
}

define i64 @UDIVX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 11010110 m:5 000010 n:5 d:5" "asm"="udiv {d}, {n}, {m}" {
  %r = udiv i64 %n, %m
  ret i64 %r
}

; ===========================================================================
; Logic

define i32 @ANDWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 00 01010 00 0 m:5 000000 n:5 d:5" "asm"="and {d}, {n}, {m}" {
  %r = and i32 %n, %m
  ret i32 %r
}

define i64 @ANDXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 00 01010 00 0 m:5 000000 n:5 d:5" "asm"="and {d}, {n}, {m}" {
  %r = and i64 %n, %m
  ret i64 %r
}

define i32 @ORRWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 01 01010 00 0 m:5 000000 n:5 d:5" "asm"="orr {d}, {n}, {m}" {
  %r = or i32 %n, %m
  ret i32 %r
}

define i64 @ORRXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 01 01010 00 0 m:5 000000 n:5 d:5" "asm"="orr {d}, {n}, {m}" {
  %r = or i64 %n, %m
  ret i64 %r
}

define i32 @EORWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 10 01010 00 0 m:5 000000 n:5 d:5" "asm"="eor {d}, {n}, {m}" {
  %r = xor i32 %n, %m
  ret i32 %r
}

define i64 @EORXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 10 01010 00 0 m:5 000000 n:5 d:5" "asm"="eor {d}, {n}, {m}" {
  %r = xor i64 %n, %m
  ret i64 %r
}

define i32 @BICW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 00 01010 00 1 m:5 000000 n:5 d:5" "asm"="bic {d}, {n}, {m}" {
  %nm = xor i32 %m, -1
  %r = and i32 %n, %nm
  ret i32 %r
}

define i64 @BICX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 00 01010 00 1 m:5 000000 n:5 d:5" "asm"="bic {d}, {n}, {m}" {
  %nm = xor i64 %m, -1
  %r = and i64 %n, %nm
  ret i64 %r
}

define i32 @MVNW(i32 "reg"="w" %m) "enc"="0 01 01010 00 1 m:5 000000 11111 d:5" "asm"="mvn {d}, {m}" {
  %r = xor i32 %m, -1
  ret i32 %r
}

define i64 @MVNX(i64 "reg"="x" %m) "enc"="1 01 01010 00 1 m:5 000000 11111 d:5" "asm"="mvn {d}, {m}" {
  %r = xor i64 %m, -1
  ret i64 %r
}

define i32 @ANDWri(i32 "reg"="w" %n, i32 "imm" %imm) "enc"="0 00 100100 nimm:13=bitmask32(imm) n:5 d:5" "asm"="and {d}, {n}, #{imm:h32}" "dclass"="wsp" {
  %r = and i32 %n, %imm
  ret i32 %r
}

define i64 @ANDXri(i64 "reg"="x" %n, i64 "imm" %imm) "enc"="1 00 100100 nimm:13=bitmask64(imm) n:5 d:5" "asm"="and {d}, {n}, #{imm:h64}" "dclass"="xsp" {
  %r = and i64 %n, %imm
  ret i64 %r
}

define i32 @ORRWri(i32 "reg"="w" %n, i32 "imm" %imm) "enc"="0 01 100100 nimm:13=bitmask32(imm) n:5 d:5" "asm"="orr {d}, {n}, #{imm:h32}" "dclass"="wsp" {
  %r = or i32 %n, %imm
  ret i32 %r
}

define i64 @ORRXri(i64 "reg"="x" %n, i64 "imm" %imm) "enc"="1 01 100100 nimm:13=bitmask64(imm) n:5 d:5" "asm"="orr {d}, {n}, #{imm:h64}" "dclass"="xsp" {
  %r = or i64 %n, %imm
  ret i64 %r
}

define i32 @EORWri(i32 "reg"="w" %n, i32 "imm" %imm) "enc"="0 10 100100 nimm:13=bitmask32(imm) n:5 d:5" "asm"="eor {d}, {n}, #{imm:h32}" "dclass"="wsp" {
  %r = xor i32 %n, %imm
  ret i32 %r
}

define i64 @EORXri(i64 "reg"="x" %n, i64 "imm" %imm) "enc"="1 10 100100 nimm:13=bitmask64(imm) n:5 d:5" "asm"="eor {d}, {n}, #{imm:h64}" "dclass"="xsp" {
  %r = xor i64 %n, %imm
  ret i64 %r
}

; ===========================================================================
; Shifts

define i32 @LSLVW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 11010110 m:5 001000 n:5 d:5" "asm"="lsl {d}, {n}, {m}" {
  %r = shl i32 %n, %m
  ret i32 %r
}

define i64 @LSLVX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 11010110 m:5 001000 n:5 d:5" "asm"="lsl {d}, {n}, {m}" {
  %r = shl i64 %n, %m
  ret i64 %r
}

define i32 @LSRVW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 11010110 m:5 001001 n:5 d:5" "asm"="lsr {d}, {n}, {m}" {
  %r = lshr i32 %n, %m
  ret i32 %r
}

define i64 @LSRVX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 11010110 m:5 001001 n:5 d:5" "asm"="lsr {d}, {n}, {m}" {
  %r = lshr i64 %n, %m
  ret i64 %r
}

define i32 @ASRVW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 11010110 m:5 001010 n:5 d:5" "asm"="asr {d}, {n}, {m}" {
  %r = ashr i32 %n, %m
  ret i32 %r
}

define i64 @ASRVX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 11010110 m:5 001010 n:5 d:5" "asm"="asr {d}, {n}, {m}" {
  %r = ashr i64 %n, %m
  ret i64 %r
}

; Shifts by a constant are bitfield moves.
define i32 @LSLWri(i32 "reg"="w" %n, i32 "imm" %sh) "enc"="0 10 100110 0 immr:6=(32-sh)%32 imms:6=31-sh n:5 d:5" "asm"="lsl {d}, {n}, #{sh}" {
  %r = shl i32 %n, %sh
  ret i32 %r
}

define i64 @LSLXri(i64 "reg"="x" %n, i64 "imm" %sh) "enc"="1 10 100110 1 immr:6=(64-sh)%64 imms:6=63-sh n:5 d:5" "asm"="lsl {d}, {n}, #{sh}" {
  %r = shl i64 %n, %sh
  ret i64 %r
}

define i32 @LSRWri(i32 "reg"="w" %n, i32 "imm" %sh) "enc"="0 10 100110 0 immr:6=sh%32 011111 n:5 d:5" "asm"="lsr {d}, {n}, #{sh}" {
  %r = lshr i32 %n, %sh
  ret i32 %r
}

define i64 @LSRXri(i64 "reg"="x" %n, i64 "imm" %sh) "enc"="1 10 100110 1 immr:6=sh%64 111111 n:5 d:5" "asm"="lsr {d}, {n}, #{sh}" {
  %r = lshr i64 %n, %sh
  ret i64 %r
}

define i32 @ASRWri(i32 "reg"="w" %n, i32 "imm" %sh) "enc"="0 00 100110 0 immr:6=sh%32 011111 n:5 d:5" "asm"="asr {d}, {n}, #{sh}" {
  %r = ashr i32 %n, %sh
  ret i32 %r
}

define i64 @ASRXri(i64 "reg"="x" %n, i64 "imm" %sh) "enc"="1 00 100110 1 immr:6=sh%64 111111 n:5 d:5" "asm"="asr {d}, {n}, #{sh}" {
  %r = ashr i64 %n, %sh
  ret i64 %r
}

; ===========================================================================
; Extensions. Values narrower than 32 bits live in W registers, with
; whatever is above them undefined.

define i32 @SXTBW(i8 "reg"="w" %n) "enc"="0 00 100110 0 000000 000111 n:5 d:5" "asm"="sxtb {d}, {n}" "role"="sext.8" {
  %r = sext i8 %n to i32
  ret i32 %r
}

define i64 @SXTBX(i8 "reg"="w" %n) "enc"="1 00 100110 1 000000 000111 n:5 d:5" "asm"="sxtb {d}, {n}" {
  %r = sext i8 %n to i64
  ret i64 %r
}

define i32 @SXTHW(i16 "reg"="w" %n) "enc"="0 00 100110 0 000000 001111 n:5 d:5" "asm"="sxth {d}, {n}" "role"="sext.16" {
  %r = sext i16 %n to i32
  ret i32 %r
}

define i64 @SXTHX(i16 "reg"="w" %n) "enc"="1 00 100110 1 000000 001111 n:5 d:5" "asm"="sxth {d}, {n}" {
  %r = sext i16 %n to i64
  ret i64 %r
}

define i64 @SXTWX(i32 "reg"="w" %n) "enc"="1 00 100110 1 000000 011111 n:5 d:5" "asm"="sxtw {d}, {n}" {
  %r = sext i32 %n to i64
  ret i64 %r
}

define i32 @SBFX1W(i1 "reg"="w" %n) "enc"="0 00 100110 0 000000 000000 n:5 d:5" "asm"="sbfx {d}, {n}, #0, #1" "role"="sext.1" {
  %r = sext i1 %n to i32
  ret i32 %r
}

define i64 @SBFX1X(i1 "reg"="w" %n) "enc"="1 00 100110 1 000000 000000 n:5 d:5" "asm"="sbfx {d}, {n:x}, #0, #1" {
  %r = sext i1 %n to i64
  ret i64 %r
}

define i32 @UXTBW(i8 "reg"="w" %n) "enc"="0 10 100110 0 000000 000111 n:5 d:5" "asm"="uxtb {d}, {n}" "zext"="8" "role"="zext.8" {
  %r = zext i8 %n to i32
  ret i32 %r
}

define i32 @UXTHW(i16 "reg"="w" %n) "enc"="0 10 100110 0 000000 001111 n:5 d:5" "asm"="uxth {d}, {n}" "zext"="16" "role"="zext.16" {
  %r = zext i16 %n to i32
  ret i32 %r
}

define i32 @UXT1W(i1 "reg"="w" %n) "enc"="0 00 100100 0 000000 000000 n:5 d:5" "asm"="and {d}, {n}, #0x1" "zext"="1" "role"="zext.1" {
  %r = zext i1 %n to i32
  ret i32 %r
}

; Zero extension to 64 bits: writing a W register clears the top half.
define i64 @UXTBX(i8 "reg"="w" %n) "enc"="0 10 100110 0 000000 000111 n:5 d:5" "asm"="uxtb {d:w}, {n}" "zext"="8" "nodecode" {
  %r = zext i8 %n to i64
  ret i64 %r
}

define i64 @UXTHX(i16 "reg"="w" %n) "enc"="0 10 100110 0 000000 001111 n:5 d:5" "asm"="uxth {d:w}, {n}" "zext"="16" "nodecode" {
  %r = zext i16 %n to i64
  ret i64 %r
}

define i64 @UXTWX(i32 "reg"="w" %m) "enc"="0 01 01010 00 0 m:5 000000 11111 d:5" "asm"="mov {d:w}, {m}" "zext"="32" "nodecode" {
  %r = zext i32 %m to i64
  ret i64 %r
}

define i64 @UXT1X(i1 "reg"="w" %n) "enc"="0 00 100100 0 000000 000000 n:5 d:5" "asm"="and {d:w}, {n}, #0x1" "zext"="1" "nodecode" {
  %r = zext i1 %n to i64
  ret i64 %r
}

; ===========================================================================
; Moves and constants

define i32 @MOVWr(i32 "reg"="w" %m) "enc"="0 01 01010 00 0 m:5 000000 11111 d:5" "asm"="mov {d}, {m}" "copy"="w" {
  ret i32 %m
}

define i64 @MOVXr(i64 "reg"="x" %m) "enc"="1 01 01010 00 0 m:5 000000 11111 d:5" "asm"="mov {d}, {m}" "copy"="x" {
  ret i64 %m
}

; mov to or from sp is add #0.
define i64 @MOVXsp(i64 "reg"="xsp" %n) "enc"="1 0 0 100010 0 000000000000 n:5 d:5" "asm"="mov {d}, {n}" "dclass"="xsp" "copy"="xsp" {
  ret i64 %n
}

define i32 @MOVZWi(i32 "imm" %imm) "enc"="0 10 100101 00 imm:16 d:5" "asm"="mov {d}, #{imm}" "zext"="16" {
  ret i32 %imm
}

define i64 @MOVZXi(i64 "imm" %imm) "enc"="1 10 100101 00 imm:16 d:5" "asm"="mov {d}, #{imm}" "zext"="16" {
  ret i64 %imm
}

define i32 @MOVNWi(i32 "imm" %imm) "enc"="0 00 100101 00 imm16:16=-1-imm d:5" "asm"="mov {d}, #{imm}" {
  ret i32 %imm
}

define i64 @MOVNXi(i64 "imm" %imm) "enc"="1 00 100101 00 imm16:16=-1-imm d:5" "asm"="mov {d}, #{imm}" {
  ret i64 %imm
}

define i32 @MOVWbm(i32 "imm" %imm) "enc"="0 01 100100 nimm:13=bitmask32(imm) 11111 d:5" "asm"="orr {d}, wzr, #{imm:h32}" "dclass"="wsp" {
  ret i32 %imm
}

define i64 @MOVXbm(i64 "imm" %imm) "enc"="1 01 100100 nimm:13=bitmask64(imm) 11111 d:5" "asm"="orr {d}, xzr, #{imm:h64}" "dclass"="xsp" {
  ret i64 %imm
}

; For constants made a piece at a time: movz, then movk for each other
; nonzero 16 bits.
define i32 @MOVZWis(i32 "imm" %imm, i32 "imm" %sh) "enc"="0 10 100101 0 hw:1=sh/16 imm:16 d:5" "asm"="movz {d}, #{imm}, lsl #{sh}" "role"="movz.w" "nomatch" {
  %r = shl i32 %imm, %sh
  ret i32 %r
}

define i64 @MOVZXis(i64 "imm" %imm, i64 "imm" %sh) "enc"="1 10 100101 hw:2=sh/16 imm:16 d:5" "asm"="movz {d}, #{imm}, lsl #{sh}" "role"="movz.x" "nomatch" {
  %r = shl i64 %imm, %sh
  ret i64 %r
}

define i32 @MOVKWi(i32 "reg"="w" "tied" %old, i32 "imm" %imm, i32 "imm" %sh) "enc"="0 11 100101 0 hw:1=sh/16 imm:16 d:5" "asm"="movk {d}, #{imm}, lsl #{sh}" "role"="movk.w" "nomatch" {
  %m = shl i32 65535, %sh
  %keep = xor i32 %m, -1
  %k = and i32 %old, %keep
  %v = shl i32 %imm, %sh
  %r = or i32 %k, %v
  ret i32 %r
}

define i64 @MOVKXi(i64 "reg"="x" "tied" %old, i64 "imm" %imm, i64 "imm" %sh) "enc"="1 11 100101 hw:2=sh/16 imm:16 d:5" "asm"="movk {d}, #{imm}, lsl #{sh}" "role"="movk.x" "nomatch" {
  %m = shl i64 65535, %sh
  %keep = xor i64 %m, -1
  %k = and i64 %old, %keep
  %v = shl i64 %imm, %sh
  %r = or i64 %k, %v
  ret i64 %r
}

; Addresses of symbols: the 4KB page, then the offset in it.
define ptr @ADRP(ptr "sym" %s) "enc"="1 immlo:2=s&3 10000 immhi:s19=s>>2 d:5" "asm"="adrp {d}, {s}" "reloc"="adrp" "role"="addr.hi" "nomatch" {
  ret ptr %s
}

define ptr @ADDpageoff(ptr "reg"="xsp" %n, ptr "sym" %s) "enc"="1 0 0 100010 0 imm12:12=s n:5 d:5" "asm"="add {d}, {n}, {s}" "reloc"="add_lo12" "dclass"="xsp" "role"="addr.lo" "nomatch" "nodecode" {
  ret ptr %n
}

; Addresses of symbols defined in other libraries, from the global offset
; table: the table entry's page, then a load of the entry.
define ptr @ADRPgot(ptr "sym" %s) "enc"="1 immlo:2=s&3 10000 immhi:s19=s>>2 d:5" "asm"="adrp {d}, {s}" "reloc"="adrp_got" "role"="got.hi" "nomatch" "nodecode" {
  ret ptr %s
}

define ptr @LDRgot(ptr "reg"="xsp" %n, ptr "sym" %s) "enc"="11 111 0 01 01 imm12:12=s/8 n:5 d:5" "asm"="ldr {d}, [{n}, {s}]" "reloc"="ld64_got_lo12" "role"="got.lo" "nomatch" "nodecode" {
  %v = load ptr, ptr %n
  ret ptr %v
}

; ===========================================================================
; Address arithmetic: getelementptr i8 is adding to a pointer.

define ptr @ADDPrr(ptr "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="add {d}, {n}, {m}" "nodecode" {
  %r = getelementptr i8, ptr %n, i64 %m
  ret ptr %r
}

define ptr @ADDPrs(ptr "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 0 m:5 imm6:6=sh%64 n:5 d:5" "asm"="add {d}, {n}, {m}, lsl #{sh}" "nodecode" {
  %s = shl i64 %m, %sh
  %r = getelementptr i8, ptr %n, i64 %s
  ret ptr %r
}

define ptr @ADDPrx(ptr "reg"="xsp" %n, i32 "reg"="w" %m, i64 "imm" %sh) "enc"="1 0 0 01011 00 1 m:5 110 imm3:3=sh%5 n:5 d:5" "asm"="add {d}, {n}, {m}, sxtw #{sh}" "dclass"="xsp" {
  %e = sext i32 %m to i64
  %s = shl i64 %e, %sh
  %r = getelementptr i8, ptr %n, i64 %s
  ret ptr %r
}

define ptr @ADDPri(ptr "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 0 0 100010 0 imm:12 n:5 d:5" "asm"="add {d}, {n}, #{imm}" "dclass"="xsp" "nodecode" {
  %r = getelementptr i8, ptr %n, i64 %imm
  ret ptr %r
}

define ptr @SUBPri_neg(ptr "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 1 0 100010 0 imm12:12=0-imm n:5 d:5" "asm"="sub {d}, {n}, #{=0-imm}" "dclass"="xsp" "nodecode" {
  %r = getelementptr i8, ptr %n, i64 %imm
  ret ptr %r
}

