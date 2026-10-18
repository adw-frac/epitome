; AArch64 integer instructions, as data. See docs/design/isel.md.
;
; Each function with an "enc" attribute is one machine instruction: its body
; is what the instruction does, its parameters are its operands, "enc" is its
; encoding (most significant bit first, as in the Arm Architecture Reference
; Manual) and "asm" its assembly. The result is the operand called `d`.
;
; Operand kinds, from parameter attributes:
;   "reg"="w" / "x"       register; number 31 is the zero register
;   "reg"="wsp" / "xsp"   register; number 31 is the stack pointer
;   "imm"                 constant; it fits if the encoding can hold it
;   "label"               branch target
;   "sym"                 symbol (fixed up by the linker)
;   "cond"                condition, filled in by a condition form (cc.*)
;   "tied"                in the same register as the result
;
; Other attributes:
;   "sets"="nzcv"         returns the flags; which of them are right
;   "cond"="11"           a condition form, with its encoding
;   "reads"="nv"          the flags a condition form reads
;   "recipe"="f"          IR with no single instruction; f emits it
;   "nodecode"            not offered by the disassembler
;   "zext"="8"            the result is zero above this many bits
;   "copy"                a register-to-register move of this class
;   "inverse"="CBNZW"     the branch taken when this one is not (a "cond"
;                         operand is inverted too)
;   "dclass"="wsp"        the result's register class, if not w or x
;   "nomatch"             not a pattern for selection
;   "role"="..."          used by the code generator by role, not matched

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

; The flags, lazily: the two values last compared, sign-extended (which
; keeps both their signed and unsigned order).
%nzcv = type { i64, i64 }

; ===========================================================================
; Condition forms

define i1 @cc.eq(%nzcv %f) "cond"="0" "asm"="eq" "reads"="z" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp eq i64 %a, %b
  ret i1 %c
}

define i1 @cc.ne(%nzcv %f) "cond"="1" "asm"="ne" "reads"="z" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp ne i64 %a, %b
  ret i1 %c
}

define i1 @cc.hs(%nzcv %f) "cond"="2" "asm"="hs" "reads"="c" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp uge i64 %a, %b
  ret i1 %c
}

define i1 @cc.lo(%nzcv %f) "cond"="3" "asm"="lo" "reads"="c" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp ult i64 %a, %b
  ret i1 %c
}

define i1 @cc.hi(%nzcv %f) "cond"="8" "asm"="hi" "reads"="cz" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp ugt i64 %a, %b
  ret i1 %c
}

define i1 @cc.ls(%nzcv %f) "cond"="9" "asm"="ls" "reads"="cz" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp ule i64 %a, %b
  ret i1 %c
}

define i1 @cc.ge(%nzcv %f) "cond"="10" "asm"="ge" "reads"="nv" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp sge i64 %a, %b
  ret i1 %c
}

define i1 @cc.lt(%nzcv %f) "cond"="11" "asm"="lt" "reads"="nv" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp slt i64 %a, %b
  ret i1 %c
}

define i1 @cc.gt(%nzcv %f) "cond"="12" "asm"="gt" "reads"="nzv" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp sgt i64 %a, %b
  ret i1 %c
}

define i1 @cc.le(%nzcv %f) "cond"="13" "asm"="le" "reads"="nzv" {
  %a = extractvalue %nzcv %f, 0
  %b = extractvalue %nzcv %f, 1
  %c = icmp sle i64 %a, %b
  ret i1 %c
}

; ===========================================================================
; Comparisons: they return the flags

define %nzcv @CMPWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 1 1 01011 00 0 m:5 000000 n:5 11111" "asm"="cmp {n}, {m}" "sets"="nzcv" {
  %a = sext i32 %n to i64
  %b = sext i32 %m to i64
  %f0 = insertvalue %nzcv poison, i64 %a, 0
  %f = insertvalue %nzcv %f0, i64 %b, 1
  ret %nzcv %f
}

define %nzcv @CMPXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 1 1 01011 00 0 m:5 000000 n:5 11111" "asm"="cmp {n}, {m}" "sets"="nzcv" {
  %f0 = insertvalue %nzcv poison, i64 %n, 0
  %f = insertvalue %nzcv %f0, i64 %m, 1
  ret %nzcv %f
}

define %nzcv @CMPWri(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 1 1 100010 0 imm:12 n:5 11111" "asm"="cmp {n}, #{imm}" "sets"="nzcv" {
  %a = sext i32 %n to i64
  %b = sext i32 %imm to i64
  %f0 = insertvalue %nzcv poison, i64 %a, 0
  %f = insertvalue %nzcv %f0, i64 %b, 1
  ret %nzcv %f
}

define %nzcv @CMPXri(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 1 1 100010 0 imm:12 n:5 11111" "asm"="cmp {n}, #{imm}" "sets"="nzcv" {
  %f0 = insertvalue %nzcv poison, i64 %n, 0
  %f = insertvalue %nzcv %f0, i64 %imm, 1
  ret %nzcv %f
}

; cmn n, #k sets the flags of n + k, which are those of comparing n with -k.
define %nzcv @CMNWri(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 0 1 100010 0 imm12:12=0-imm n:5 11111" "asm"="cmn {n}, #{=0-imm}" "sets"="nzcv" {
  %a = sext i32 %n to i64
  %b = sext i32 %imm to i64
  %f0 = insertvalue %nzcv poison, i64 %a, 0
  %f = insertvalue %nzcv %f0, i64 %b, 1
  ret %nzcv %f
}

define %nzcv @CMNXri(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 0 1 100010 0 imm12:12=0-imm n:5 11111" "asm"="cmn {n}, #{=0-imm}" "sets"="nzcv" {
  %f0 = insertvalue %nzcv poison, i64 %n, 0
  %f = insertvalue %nzcv %f0, i64 %imm, 1
  ret %nzcv %f
}

; tst sets N and Z from n & m, and clears C and V. A comparison of the
; result with 0 would set C, so conditions reading C cannot follow it.
define %nzcv @TSTWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 11 01010 00 0 m:5 000000 n:5 11111" "asm"="tst {n}, {m}" "sets"="nzv" {
  %r = and i32 %n, %m
  %a = sext i32 %r to i64
  %f0 = insertvalue %nzcv poison, i64 %a, 0
  %f = insertvalue %nzcv %f0, i64 0, 1
  ret %nzcv %f
}

define %nzcv @TSTXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 11 01010 00 0 m:5 000000 n:5 11111" "asm"="tst {n}, {m}" "sets"="nzv" {
  %r = and i64 %n, %m
  %f0 = insertvalue %nzcv poison, i64 %r, 0
  %f = insertvalue %nzcv %f0, i64 0, 1
  ret %nzcv %f
}

define %nzcv @TSTWri(i32 "reg"="w" %n, i32 "imm" %imm) "enc"="0 11 100100 nimm:13=bitmask32(imm) n:5 11111" "asm"="tst {n}, #{imm:h32}" "sets"="nzv" {
  %r = and i32 %n, %imm
  %a = sext i32 %r to i64
  %f0 = insertvalue %nzcv poison, i64 %a, 0
  %f = insertvalue %nzcv %f0, i64 0, 1
  ret %nzcv %f
}

define %nzcv @TSTXri(i64 "reg"="x" %n, i64 "imm" %imm) "enc"="1 11 100100 nimm:13=bitmask64(imm) n:5 11111" "asm"="tst {n}, #{imm:h64}" "sets"="nzv" {
  %r = and i64 %n, %imm
  %f0 = insertvalue %nzcv poison, i64 %r, 0
  %f = insertvalue %nzcv %f0, i64 0, 1
  ret %nzcv %f
}

; ===========================================================================
; Branches. indirectbr to a label operand means "jump there"; ret void
; means "fall through".

define void @B(ptr "label" %dest) "enc"="000101 imm26:s26=dest/4" "asm"="b {dest}" {
  indirectbr ptr %dest, []
}

define void @Bcc(i1 "cond" %c, ptr "label" %dest) "enc"="01010100 imm19:s19=dest/4 0 c:4" "asm"="b.{c} {dest}" "inverse"="Bcc" {
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @CBZW(i32 "reg"="w" %t, ptr "label" %dest) "enc"="0 011010 0 imm19:s19=dest/4 t:5" "asm"="cbz {t}, {dest}" "inverse"="CBNZW" {
  %c = icmp eq i32 %t, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @CBNZW(i32 "reg"="w" %t, ptr "label" %dest) "enc"="0 011010 1 imm19:s19=dest/4 t:5" "asm"="cbnz {t}, {dest}" "inverse"="CBZW" {
  %c = icmp ne i32 %t, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @CBZX(i64 "reg"="x" %t, ptr "label" %dest) "enc"="1 011010 0 imm19:s19=dest/4 t:5" "asm"="cbz {t}, {dest}" "inverse"="CBNZX" {
  %c = icmp eq i64 %t, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @CBNZX(i64 "reg"="x" %t, ptr "label" %dest) "enc"="1 011010 1 imm19:s19=dest/4 t:5" "asm"="cbnz {t}, {dest}" "inverse"="CBZX" {
  %c = icmp ne i64 %t, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

; Branch on a boolean in a register: test bit 0.
define void @TBNZb(i1 "reg"="w" %t, ptr "label" %dest) "enc"="0 011011 1 00000 imm14:s14=dest/4 t:5" "asm"="tbnz {t}, #0, {dest}" "inverse"="TBZb" {
  br i1 %t, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBZb(i1 "reg"="w" %t, ptr "label" %dest) "enc"="0 011011 0 00000 imm14:s14=dest/4 t:5" "asm"="tbz {t}, #0, {dest}" "inverse"="TBNZb" {
  br i1 %t, label %next, label %taken
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @RET() "enc"="1101011 0 0 10 11111 0000 0 0 11110 00000" "asm"="ret" {
  ret void
}

define void @BRK() "enc"="11010100 001 0000000000000001 000 00" "asm"="brk #0x1" {
  unreachable
}

define void @BL(ptr "sym" %s) "enc"="100101 imm26:s26=s/4" "asm"="bl {s}" "role"="call" "nomatch" {
  ret void
}

define void @BLR(ptr "reg"="x" %n) "enc"="1101011 0 0 01 11111 0000 0 0 n:5 00000" "asm"="blr {n}" "role"="callr" "nomatch" {
  ret void
}

; ===========================================================================
; Selects

define i32 @CSELW(i1 "cond" %c, i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 11010100 m:5 c:4 0 0 n:5 d:5" "asm"="csel {d}, {n}, {m}, {c}" {
  %r = select i1 %c, i32 %n, i32 %m
  ret i32 %r
}

define i64 @CSELX(i1 "cond" %c, i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 11010100 m:5 c:4 0 0 n:5 d:5" "asm"="csel {d}, {n}, {m}, {c}" {
  %r = select i1 %c, i64 %n, i64 %m
  ret i64 %r
}

define ptr @CSELP(i1 "cond" %c, ptr "reg"="x" %n, ptr "reg"="x" %m) "enc"="1 0 0 11010100 m:5 c:4 0 0 n:5 d:5" "asm"="csel {d}, {n}, {m}, {c}" "nodecode" {
  %r = select i1 %c, ptr %n, ptr %m
  ret ptr %r
}

; cset is csinc d, wzr, wzr with the condition inverted: 1 if c, else 0.
define i1 @CSET(i1 "cond" %c) "enc"="0 0 0 11010100 11111 inv:4=c^1 0 1 11111 d:5" "asm"="cset {d}, {c}" "zext"="1" {
  ret i1 %c
}

; ===========================================================================
; Arithmetic

define i32 @ADDWrr(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0 0 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="add {d}, {n}, {m}" {
  %r = add i32 %n, %m
  ret i32 %r
}

define i64 @ADDXrr(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="1 0 0 01011 00 0 m:5 000000 n:5 d:5" "asm"="add {d}, {n}, {m}" {
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

define i32 @ADDWri(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 0 0 100010 0 imm:12 n:5 d:5" "asm"="add {d}, {n}, #{imm}" "dclass"="wsp" {
  %r = add i32 %n, %imm
  ret i32 %r
}

define i64 @ADDXri(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 0 0 100010 0 imm:12 n:5 d:5" "asm"="add {d}, {n}, #{imm}" "dclass"="xsp" "role"="addi" {
  %r = add i64 %n, %imm
  ret i64 %r
}

; add with a negative immediate is sub.
define i32 @SUBWri_neg(i32 "reg"="wsp" %n, i32 "imm" %imm) "enc"="0 1 0 100010 0 imm12:12=0-imm n:5 d:5" "asm"="sub {d}, {n}, #{=0-imm}" "dclass"="wsp" "nodecode" {
  %r = add i32 %n, %imm
  ret i32 %r
}

define i64 @SUBXri_neg(i64 "reg"="xsp" %n, i64 "imm" %imm) "enc"="1 1 0 100010 0 imm12:12=0-imm n:5 d:5" "asm"="sub {d}, {n}, #{=0-imm}" "dclass"="xsp" "nodecode" {
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

define i32 @SXTBW(i8 "reg"="w" %n) "enc"="0 00 100110 0 000000 000111 n:5 d:5" "asm"="sxtb {d}, {n}" {
  %r = sext i8 %n to i32
  ret i32 %r
}

define i64 @SXTBX(i8 "reg"="w" %n) "enc"="1 00 100110 1 000000 000111 n:5 d:5" "asm"="sxtb {d}, {n}" {
  %r = sext i8 %n to i64
  ret i64 %r
}

define i32 @SXTHW(i16 "reg"="w" %n) "enc"="0 00 100110 0 000000 001111 n:5 d:5" "asm"="sxth {d}, {n}" {
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

define i32 @SBFX1W(i1 "reg"="w" %n) "enc"="0 00 100110 0 000000 000000 n:5 d:5" "asm"="sbfx {d}, {n}, #0, #1" {
  %r = sext i1 %n to i32
  ret i32 %r
}

define i64 @SBFX1X(i1 "reg"="w" %n) "enc"="1 00 100110 1 000000 000000 n:5 d:5" "asm"="sbfx {d}, {n:x}, #0, #1" {
  %r = sext i1 %n to i64
  ret i64 %r
}

define i32 @UXTBW(i8 "reg"="w" %n) "enc"="0 10 100110 0 000000 000111 n:5 d:5" "asm"="uxtb {d}, {n}" "zext"="8" {
  %r = zext i8 %n to i32
  ret i32 %r
}

define i32 @UXTHW(i16 "reg"="w" %n) "enc"="0 10 100110 0 000000 001111 n:5 d:5" "asm"="uxth {d}, {n}" "zext"="16" {
  %r = zext i16 %n to i32
  ret i32 %r
}

define i32 @UXT1W(i1 "reg"="w" %n) "enc"="0 00 100100 0 000000 000000 n:5 d:5" "asm"="and {d}, {n}, #0x1" "zext"="1" {
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
define ptr @ADRP(ptr "sym" %s) "enc"="1 immlo:2=s%4 10000 immhi:19=s/4 d:5" "asm"="adrp {d}, {s}@PAGE" "role"="adrp" "nomatch" {
  ret ptr %s
}

define ptr @ADDpageoff(ptr "reg"="xsp" %n, ptr "sym" %s) "enc"="1 0 0 100010 0 imm12:12=s n:5 d:5" "asm"="add {d}, {n}, {s}@PAGEOFF" "dclass"="xsp" "role"="pageoff" "nomatch" "nodecode" {
  ret ptr %n
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

; ===========================================================================
; Loads and stores, with an unsigned offset scaled by the size.

define i8 @LDRBui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 01 imm12:12=off n:5 d:5" "asm"="ldrb {d}, [{n}, #{off}]" "zext"="8" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  ret i8 %v
}

define i16 @LDRHui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="01 111 0 01 01 imm12:12=off/2 n:5 d:5" "asm"="ldrh {d}, [{n}, #{off}]" "zext"="16" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i16, ptr %p
  ret i16 %v
}

define i32 @LDRWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 01 01 imm12:12=off/4 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %p
  ret i32 %v
}

define i64 @LDRXui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.x" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i64, ptr %p
  ret i64 %v
}

define ptr @LDRPui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load ptr, ptr %p
  ret ptr %v
}

define i32 @LDRSBWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 11 imm12:12=off n:5 d:5" "asm"="ldrsb {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  %r = sext i8 %v to i32
  ret i32 %r
}

define i64 @LDRSBXui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 10 imm12:12=off n:5 d:5" "asm"="ldrsb {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  %r = sext i8 %v to i64
  ret i64 %r
}

define i32 @LDRSHWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="01 111 0 01 11 imm12:12=off/2 n:5 d:5" "asm"="ldrsh {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i16, ptr %p
  %r = sext i16 %v to i32
  ret i32 %r
}

define i64 @LDRSWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 01 10 imm12:12=off/4 n:5 d:5" "asm"="ldrsw {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}

define void @STRBui(i8 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 00 imm12:12=off n:5 t:5" "asm"="strb {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i8 %t, ptr %p
  ret void
}

define void @STRHui(i16 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="01 111 0 01 00 imm12:12=off/2 n:5 t:5" "asm"="strh {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i16 %t, ptr %p
  ret void
}

define void @STRWui(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 01 00 imm12:12=off/4 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %p
  ret void
}

define void @STRXui(i64 "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.x" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %p
  ret void
}

define void @STRPui(ptr "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store ptr %t, ptr %p
  ret void
}

; Negative or unaligned offsets: unscaled, signed 9 bits.
define i8 @LDURBi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldurb {d}, [{n}, #{off}]" "zext"="8" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  ret i8 %v
}

define i32 @LDURWi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %p
  ret i32 %v
}

define i64 @LDURXi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i64, ptr %p
  ret i64 %v
}

define ptr @LDURPi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load ptr, ptr %p
  ret ptr %v
}

define void @STURBi(i8 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="sturb {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i8 %t, ptr %p
  ret void
}

define void @STURWi(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %p
  ret void
}

define void @STURXi(i64 "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %p
  ret void
}

define void @STURPi(ptr "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store ptr %t, ptr %p
  ret void
}

; Register offsets, shifted by the size.
define i32 @LDRWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  ret i32 %v
}

define i64 @LDRXroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i64, ptr %p
  ret i64 %v
}

define ptr @LDRProX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load ptr, ptr %p
  ret ptr %v
}

define i8 @LDRBroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 01 1 m:5 011 0 10 n:5 d:5" "asm"="ldrb {d}, [{n}, {m}]" "zext"="8" {
  %p = getelementptr i8, ptr %n, i64 %m
  %v = load i8, ptr %p
  ret i8 %v
}

define i32 @LDRSBWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 11 1 m:5 011 0 10 n:5 d:5" "asm"="ldrsb {d}, [{n}, {m}]" {
  %p = getelementptr i8, ptr %n, i64 %m
  %v = load i8, ptr %p
  %r = sext i8 %v to i32
  ret i32 %r
}

define i32 @LDRWroW(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="10 111 0 00 01 1 m:5 110 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, sxtw #2]" {
  %e = sext i32 %m to i64
  %o = shl i64 %e, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  ret i32 %v
}

define void @STRWroX(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 0 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  store i32 %t, ptr %p
  ret void
}

define void @STRXroX(i64 "reg"="x" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 0 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store i64 %t, ptr %p
  ret void
}

define void @STRBroX(i8 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 00 1 m:5 011 0 10 n:5 t:5" "asm"="strb {t}, [{n}, {m}]" {
  %p = getelementptr i8, ptr %n, i64 %m
  store i8 %t, ptr %p
  ret void
}

define void @STRWroW(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="10 111 0 00 00 1 m:5 110 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, sxtw #2]" {
  %e = sext i32 %m to i64
  %o = shl i64 %e, 2
  %p = getelementptr i8, ptr %n, i64 %o
  store i32 %t, ptr %p
  ret void
}

; ===========================================================================
; Recipes: IR with no single instruction.

define i32 @srem.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="srem.w.expand" {
  %r = srem i32 %a, %b
  ret i32 %r
}

define i32 @srem.w.expand(i32 %a, i32 %b) {
  %q = call i32 @SDIVW(i32 %a, i32 %b)
  %r = call i32 @MSUBW(i32 %q, i32 %b, i32 %a)
  ret i32 %r
}

define i64 @srem.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="srem.x.expand" {
  %r = srem i64 %a, %b
  ret i64 %r
}

define i64 @srem.x.expand(i64 %a, i64 %b) {
  %q = call i64 @SDIVX(i64 %a, i64 %b)
  %r = call i64 @MSUBX(i64 %q, i64 %b, i64 %a)
  ret i64 %r
}

define i32 @urem.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="urem.w.expand" {
  %r = urem i32 %a, %b
  ret i32 %r
}

define i32 @urem.w.expand(i32 %a, i32 %b) {
  %q = call i32 @UDIVW(i32 %a, i32 %b)
  %r = call i32 @MSUBW(i32 %q, i32 %b, i32 %a)
  ret i32 %r
}

define i64 @urem.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="urem.x.expand" {
  %r = urem i64 %a, %b
  ret i64 %r
}

define i64 @urem.x.expand(i64 %a, i64 %b) {
  %q = call i64 @UDIVX(i64 %a, i64 %b)
  %r = call i64 @MSUBX(i64 %q, i64 %b, i64 %a)
  ret i64 %r
}

; A select on a boolean in a register: test bit 0, then csel.
define i32 @select.w(i1 "reg"="w" %c, i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="select.w.expand" {
  %r = select i1 %c, i32 %a, i32 %b
  ret i32 %r
}

define i32 @select.w.expand(i1 %c, i32 %a, i32 %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call i32 @CSELW(i1 %ne, i32 %a, i32 %b)
  ret i32 %r
}

define i64 @select.x(i1 "reg"="w" %c, i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="select.x.expand" {
  %r = select i1 %c, i64 %a, i64 %b
  ret i64 %r
}

define i64 @select.x.expand(i1 %c, i64 %a, i64 %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call i64 @CSELX(i1 %ne, i64 %a, i64 %b)
  ret i64 %r
}

define ptr @select.p(i1 "reg"="w" %c, ptr "reg"="x" %a, ptr "reg"="x" %b) "recipe"="select.p.expand" {
  %r = select i1 %c, ptr %a, ptr %b
  ret ptr %r
}

define ptr @select.p.expand(i1 %c, ptr %a, ptr %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call ptr @CSELP(i1 %ne, ptr %a, ptr %b)
  ret ptr %r
}

; Minimum and maximum: compare, then select.

declare i32 @llvm.smax.i32(i32, i32)

define i32 @smax.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="smax.w.expand" {
  %r = call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smax.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.gt(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.smax.i64(i64, i64)

define i64 @smax.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="smax.x.expand" {
  %r = call i64 @llvm.smax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smax.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.gt(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

declare i32 @llvm.smin.i32(i32, i32)

define i32 @smin.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="smin.w.expand" {
  %r = call i32 @llvm.smin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smin.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.lt(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.smin.i64(i64, i64)

define i64 @smin.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="smin.x.expand" {
  %r = call i64 @llvm.smin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smin.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.lt(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

declare i32 @llvm.umax.i32(i32, i32)

define i32 @umax.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="umax.w.expand" {
  %r = call i32 @llvm.umax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umax.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.hi(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.umax.i64(i64, i64)

define i64 @umax.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="umax.x.expand" {
  %r = call i64 @llvm.umax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umax.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.hi(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

declare i32 @llvm.umin.i32(i32, i32)

define i32 @umin.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="umin.w.expand" {
  %r = call i32 @llvm.umin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umin.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.lo(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.umin.i64(i64, i64)

define i64 @umin.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="umin.x.expand" {
  %r = call i64 @llvm.umin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umin.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.lo(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}
