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
;   "writeback"           read and written: the base of a post-increment
;                         access, whose stepped value is a further result
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
define ptr @ADRP(ptr "sym" %s) "enc"="1 immlo:2=s%4 10000 immhi:19=s/4 d:5" "asm"="adrp {d}, {s:page}" "role"="adrp" "nomatch" {
  ret ptr %s
}

define ptr @ADDpageoff(ptr "reg"="xsp" %n, ptr "sym" %s) "enc"="1 0 0 100010 0 imm12:12=s n:5 d:5" "asm"="add {d}, {n}, {s:pageoff}" "dclass"="xsp" "role"="pageoff" "nomatch" "nodecode" {
  ret ptr %n
}

; Addresses of symbols defined in other libraries, from the global offset
; table: the table entry's page, then a load of the entry.
define ptr @ADRPgot(ptr "sym" %s) "enc"="1 immlo:2=s%4 10000 immhi:19=s/4 d:5" "asm"="adrp {d}, {s:gotpage}" "role"="adrp.got" "nomatch" "nodecode" {
  ret ptr %s
}

define ptr @LDRgot(ptr "reg"="xsp" %n, ptr "sym" %s) "enc"="11 111 0 01 01 imm12:12=s/8 n:5 d:5" "asm"="ldr {d}, [{n}, {s:gotpageoff}]" "role"="ldr.got" "nomatch" "nodecode" {
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

; Post-increment: load or store at the base, then step the base. The
; stepped base is a second result, written back to the base register.

define { i8, ptr } @LDRBpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldrb {d}, [{n}], #{off}" "zext"="8" {
  %v = load i8, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i8, ptr } poison, i8 %v, 0
  %b = insertvalue { i8, ptr } %a, ptr %next, 1
  ret { i8, ptr } %b
}

define { i16, ptr } @LDRHpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldrh {d}, [{n}], #{off}" "zext"="16" {
  %v = load i16, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i16, ptr } poison, i16 %v, 0
  %b = insertvalue { i16, ptr } %a, ptr %next, 1
  ret { i16, ptr } %b
}

define { i32, ptr } @LDRWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load i32, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i32, ptr } poison, i32 %v, 0
  %b = insertvalue { i32, ptr } %a, ptr %next, 1
  ret { i32, ptr } %b
}

define { i64, ptr } @LDRXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load i64, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %v, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define { ptr, ptr } @LDRPpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load ptr, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { ptr, ptr } poison, ptr %v, 0
  %b = insertvalue { ptr, ptr } %a, ptr %next, 1
  ret { ptr, ptr } %b
}

define { i32, ptr } @LDRSBWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 11 0 off:s9 01 n:5 d:5" "asm"="ldrsb {d}, [{n}], #{off}" {
  %v = load i8, ptr %n
  %x = sext i8 %v to i32
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i32, ptr } poison, i32 %x, 0
  %b = insertvalue { i32, ptr } %a, ptr %next, 1
  ret { i32, ptr } %b
}

define { i64, ptr } @LDRSBXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsb {d}, [{n}], #{off}" {
  %v = load i8, ptr %n
  %x = sext i8 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %x, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define { i32, ptr } @LDRSHWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 11 0 off:s9 01 n:5 d:5" "asm"="ldrsh {d}, [{n}], #{off}" {
  %v = load i16, ptr %n
  %x = sext i16 %v to i32
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i32, ptr } poison, i32 %x, 0
  %b = insertvalue { i32, ptr } %a, ptr %next, 1
  ret { i32, ptr } %b
}

define { i64, ptr } @LDRSHXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsh {d}, [{n}], #{off}" {
  %v = load i16, ptr %n
  %x = sext i16 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %x, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define { i64, ptr } @LDRSWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsw {d}, [{n}], #{off}" {
  %v = load i32, ptr %n
  %x = sext i32 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %x, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define ptr @STRBpost(i8 "reg"="w" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="strb {t}, [{n}], #{off}" {
  store i8 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRHpost(i16 "reg"="w" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="strh {t}, [{n}], #{off}" {
  store i16 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRWpost(i32 "reg"="w" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store i32 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRXpost(i64 "reg"="x" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store i64 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRPpost(ptr "reg"="x" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store ptr %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
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

; Register offsets with sign extension of the loaded value: ldrsw, ldrsh,
; ldrsb into X, and halfwords.
define i64 @LDRSWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 0 00 10 1 m:5 011 1 10 n:5 d:5" "asm"="ldrsw {d}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}

define i64 @LDRSWroW(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="10 111 0 00 10 1 m:5 110 1 10 n:5 d:5" "asm"="ldrsw {d}, [{n}, {m}, sxtw #2]" {
  %e = sext i32 %m to i64
  %o = shl i64 %e, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}

define i16 @LDRHroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldrh {d}, [{n}, {m}, lsl #1]" "zext"="16" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i16, ptr %p
  ret i16 %v
}

define i32 @LDRSHWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldrsh {d}, [{n}, {m}, lsl #1]" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i16, ptr %p
  %r = sext i16 %v to i32
  ret i32 %r
}

define i64 @LDRSHXroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 10 1 m:5 011 1 10 n:5 d:5" "asm"="ldrsh {d}, [{n}, {m}, lsl #1]" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i16, ptr %p
  %r = sext i16 %v to i64
  ret i64 %r
}

define i64 @LDRSBXroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 10 1 m:5 011 0 10 n:5 d:5" "asm"="ldrsb {d}, [{n}, {m}]" {
  %p = getelementptr i8, ptr %n, i64 %m
  %v = load i8, ptr %p
  %r = sext i8 %v to i64
  ret i64 %r
}

define void @STRHroX(i16 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="strh {t}, [{n}, {m}, lsl #1]" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  store i16 %t, ptr %p
  ret void
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
; Atomics: acquire loads, release stores and fences. (Weaker atomic loads and
; stores are plain ones, which are single-copy atomic when aligned.)

define i8 @LDARB(ptr "reg"="xsp" %n) "enc"="00 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldarb {d}, [{n}]" {
  %v = load atomic i8, ptr %n acquire, align 1
  ret i8 %v
}

define void @STLRB(i8 "reg"="w" %t, ptr "reg"="xsp" %n) "enc"="00 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlrb {t}, [{n}]" {
  store atomic i8 %t, ptr %n release, align 1
  ret void
}

define i16 @LDARH(ptr "reg"="xsp" %n) "enc"="01 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldarh {d}, [{n}]" {
  %v = load atomic i16, ptr %n acquire, align 2
  ret i16 %v
}

define void @STLRH(i16 "reg"="w" %t, ptr "reg"="xsp" %n) "enc"="01 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlrh {t}, [{n}]" {
  store atomic i16 %t, ptr %n release, align 2
  ret void
}

define i32 @LDARW(ptr "reg"="xsp" %n) "enc"="10 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldar {d}, [{n}]" {
  %v = load atomic i32, ptr %n acquire, align 4
  ret i32 %v
}

define void @STLRW(i32 "reg"="w" %t, ptr "reg"="xsp" %n) "enc"="10 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlr {t}, [{n}]" {
  store atomic i32 %t, ptr %n release, align 4
  ret void
}

define i64 @LDARX(ptr "reg"="xsp" %n) "enc"="11 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldar {d}, [{n}]" {
  %v = load atomic i64, ptr %n acquire, align 8
  ret i64 %v
}

define void @STLRX(i64 "reg"="x" %t, ptr "reg"="xsp" %n) "enc"="11 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlr {t}, [{n}]" {
  store atomic i64 %t, ptr %n release, align 8
  ret void
}

define ptr @LDARP(ptr "reg"="xsp" %n) "enc"="11 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldar {d}, [{n}]" "nodecode" {
  %v = load atomic ptr, ptr %n acquire, align 8
  ret ptr %v
}

define void @STLRP(ptr "reg"="x" %t, ptr "reg"="xsp" %n) "enc"="11 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlr {t}, [{n}]" "nodecode" {
  store atomic ptr %t, ptr %n release, align 8
  ret void
}

define void @DMBISH() "enc"="11010101000000110011 1011 1 01 11111" "asm"="dmb ish" {
  fence seq_cst
  ret void
}

define void @DMBISHLD() "enc"="11010101000000110011 1001 1 01 11111" "asm"="dmb ishld" {
  fence acquire
  ret void
}

; ===========================================================================
; Bit manipulation

declare i32 @llvm.bswap.i32(i32)
declare i64 @llvm.bswap.i64(i64)
declare i16 @llvm.bswap.i16(i16)
declare i32 @llvm.fshl.i32(i32, i32, i32)
declare i64 @llvm.fshl.i64(i64, i64, i64)
declare i32 @llvm.fshr.i32(i32, i32, i32)
declare i64 @llvm.fshr.i64(i64, i64, i64)

declare i32 @llvm.ctlz.i32(i32, i1)
declare i64 @llvm.ctlz.i64(i64, i1)

; Count leading zeros. Selection form makes the second operand false: a
; count of all the bits for zero, which is what clz gives.
define i32 @CLZW(i32 "reg"="w" %n) "enc"="0 1 0 11010110 00000 00010 0 n:5 d:5" "asm"="clz {d}, {n}" {
  %r = call i32 @llvm.ctlz.i32(i32 %n, i1 false)
  ret i32 %r
}

define i64 @CLZX(i64 "reg"="x" %n) "enc"="1 1 0 11010110 00000 00010 0 n:5 d:5" "asm"="clz {d}, {n}" {
  %r = call i64 @llvm.ctlz.i64(i64 %n, i1 false)
  ret i64 %r
}

define i32 @REVW(i32 "reg"="w" %n) "enc"="0 1 0 11010110 00000 0000 10 n:5 d:5" "asm"="rev {d}, {n}" {
  %r = call i32 @llvm.bswap.i32(i32 %n)
  ret i32 %r
}

define i64 @REVX(i64 "reg"="x" %n) "enc"="1 1 0 11010110 00000 0000 11 n:5 d:5" "asm"="rev {d}, {n}" {
  %r = call i64 @llvm.bswap.i64(i64 %n)
  ret i64 %r
}

; Swapping the bytes of each half: the low half is the 16-bit byte swap.
define i16 @REV16W(i16 "reg"="w" %n) "enc"="0 1 0 11010110 00000 0000 01 n:5 d:5" "asm"="rev16 {d}, {n}" {
  %r = call i16 @llvm.bswap.i16(i16 %n)
  ret i16 %r
}

; extr d, n, m, #lsb is the low half of n:m shifted right by lsb: a funnel
; shift by a constant, and a rotation when n and m are the same.
define i32 @EXTRWl(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %c) "enc"="0 00 100111 0 0 m:5 imms:6=(32-c)%32 n:5 d:5" "asm"="extr {d}, {n}, {m}, #{=32-c}" "nodecode" {
  %r = call i32 @llvm.fshl.i32(i32 %n, i32 %m, i32 %c)
  ret i32 %r
}

define i64 @EXTRXl(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %c) "enc"="1 00 100111 1 0 m:5 imms:6=(64-c)%64 n:5 d:5" "asm"="extr {d}, {n}, {m}, #{=64-c}" "nodecode" {
  %r = call i64 @llvm.fshl.i64(i64 %n, i64 %m, i64 %c)
  ret i64 %r
}

define i32 @EXTRW(i32 "reg"="w" %n, i32 "reg"="w" %m, i32 "imm" %c) "enc"="0 00 100111 0 0 m:5 imms:6=c%32 n:5 d:5" "asm"="extr {d}, {n}, {m}, #{c}" {
  %r = call i32 @llvm.fshr.i32(i32 %n, i32 %m, i32 %c)
  ret i32 %r
}

define i64 @EXTRX(i64 "reg"="x" %n, i64 "reg"="x" %m, i64 "imm" %c) "enc"="1 00 100111 1 0 m:5 imms:6=c%64 n:5 d:5" "asm"="extr {d}, {n}, {m}, #{c}" {
  %r = call i64 @llvm.fshr.i64(i64 %n, i64 %m, i64 %c)
  ret i64 %r
}

; ===========================================================================
; Floating point. d registers hold doubles, s registers floats; physical
; registers 32-63 are v0-v31.

; The flags after a floating-point comparison, lazily: the values compared.
; They are set differently from an integer comparison's (an unordered
; result, with a NaN, sets C and V), so these condition forms differ too:
; olt is mi, not lt, which would be true for unordered values.
%fnzcv = type { double, double }

define i1 @cc.f.oeq(%fnzcv %f) "cond"="0" "asm"="eq" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp oeq double %a, %b
  ret i1 %c
}

define i1 @cc.f.une(%fnzcv %f) "cond"="1" "asm"="ne" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp une double %a, %b
  ret i1 %c
}

define i1 @cc.f.ogt(%fnzcv %f) "cond"="12" "asm"="gt" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ogt double %a, %b
  ret i1 %c
}

define i1 @cc.f.oge(%fnzcv %f) "cond"="10" "asm"="ge" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp oge double %a, %b
  ret i1 %c
}

define i1 @cc.f.olt(%fnzcv %f) "cond"="4" "asm"="mi" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp olt double %a, %b
  ret i1 %c
}

define i1 @cc.f.ole(%fnzcv %f) "cond"="9" "asm"="ls" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ole double %a, %b
  ret i1 %c
}

define i1 @cc.f.ugt(%fnzcv %f) "cond"="8" "asm"="hi" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ugt double %a, %b
  ret i1 %c
}

define i1 @cc.f.uge(%fnzcv %f) "cond"="5" "asm"="pl" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp uge double %a, %b
  ret i1 %c
}

define i1 @cc.f.ult(%fnzcv %f) "cond"="11" "asm"="lt" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ult double %a, %b
  ret i1 %c
}

define i1 @cc.f.ule(%fnzcv %f) "cond"="13" "asm"="le" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ule double %a, %b
  ret i1 %c
}

define i1 @cc.f.ord(%fnzcv %f) "cond"="7" "asm"="vc" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ord double %a, %b
  ret i1 %c
}

define i1 @cc.f.uno(%fnzcv %f) "cond"="6" "asm"="vs" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp uno double %a, %b
  ret i1 %c
}

define %fnzcv @FCMPDrr(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 00 1000 n:5 00000" "asm"="fcmp {n}, {m}" "sets"="nzcv" {
  %f0 = insertvalue %fnzcv poison, double %n, 0
  %f = insertvalue %fnzcv %f0, double %m, 1
  ret %fnzcv %f
}

define %fnzcv @FCMPDr0(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 00000 00 1000 n:5 01000" "asm"="fcmp {n}, #0.0" "sets"="nzcv" {
  %f0 = insertvalue %fnzcv poison, double %n, 0
  %f = insertvalue %fnzcv %f0, double 0.0, 1
  ret %fnzcv %f
}

define double @FADDD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0010 10 n:5 d:5" "asm"="fadd {d}, {n}, {m}" {
  %r = fadd double %n, %m
  ret double %r
}

define double @FSUBD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0011 10 n:5 d:5" "asm"="fsub {d}, {n}, {m}" {
  %r = fsub double %n, %m
  ret double %r
}

define double @FMULD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0000 10 n:5 d:5" "asm"="fmul {d}, {n}, {m}" {
  %r = fmul double %n, %m
  ret double %r
}

define double @FDIVD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0001 10 n:5 d:5" "asm"="fdiv {d}, {n}, {m}" {
  %r = fdiv double %n, %m
  ret double %r
}

define double @FNEGD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000010 10000 n:5 d:5" "asm"="fneg {d}, {n}" {
  %r = fneg double %n
  ret double %r
}

declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare double @llvm.fmuladd.f64(double, double, double)

define double @FABSD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000001 10000 n:5 d:5" "asm"="fabs {d}, {n}" {
  %r = call double @llvm.fabs.f64(double %n)
  ret double %r
}

define double @FSQRTD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000011 10000 n:5 d:5" "asm"="fsqrt {d}, {n}" {
  %r = call double @llvm.sqrt.f64(double %n)
  ret double %r
}

define double @FMADDD(double "reg"="d" %n, double "reg"="d" %m, double "reg"="d" %a) "enc"="0 0 0 11111 01 0 m:5 0 a:5 n:5 d:5" "asm"="fmadd {d}, {n}, {m}, {a}" {
  %r = call double @llvm.fmuladd.f64(double %n, double %m, double %a)
  ret double %r
}

define double @FCSELD(i1 "cond" %c, double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 c:4 11 n:5 d:5" "asm"="fcsel {d}, {n}, {m}, {c}" {
  %r = select i1 %c, double %n, double %m
  ret double %r
}

define double @FMOVDr(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000000 10000 n:5 d:5" "asm"="fmov {d}, {n}" "copy"="d" {
  ret double %n
}

define double @SCVTFDX(i64 "reg"="x" %n) "enc"="1 0 0 11110 01 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i64 %n to double
  ret double %r
}

define double @UCVTFDX(i64 "reg"="x" %n) "enc"="1 0 0 11110 01 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i64 %n to double
  ret double %r
}

define i64 @FCVTZSXD(double "reg"="d" %n) "enc"="1 0 0 11110 01 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi double %n to i64
  ret i64 %r
}

define i64 @FCVTZUXD(double "reg"="d" %n) "enc"="1 0 0 11110 01 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui double %n to i64
  ret i64 %r
}

define double @SCVTFDW(i32 "reg"="w" %n) "enc"="0 0 0 11110 01 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i32 %n to double
  ret double %r
}

define double @UCVTFDW(i32 "reg"="w" %n) "enc"="0 0 0 11110 01 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i32 %n to double
  ret double %r
}

define i32 @FCVTZSWD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi double %n to i32
  ret i32 %r
}

define i32 @FCVTZUWD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui double %n to i32
  ret i32 %r
}

define double @LDRDui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.d" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load double, ptr %p
  ret double %v
}

define void @STRDui(double "reg"="d" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.d" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  ret void
}

define double @LDURDi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load double, ptr %p
  ret double %v
}

define void @STURDi(double "reg"="d" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  ret void
}

define double @LDRDroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load double, ptr %p
  ret double %v
}

define void @STRDroX(double "reg"="d" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store double %t, ptr %p
  ret void
}

define { double, ptr } @LDRDpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load double, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { double, ptr } poison, double %v, 0
  %b = insertvalue { double, ptr } %a, ptr %next, 1
  ret { double, ptr } %b
}

define ptr @STRDpost(double "reg"="d" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store double %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define double @select.d(i1 "reg"="w" %c, double "reg"="d" %a, double "reg"="d" %b) "recipe"="select.d.expand" {
  %r = select i1 %c, double %a, double %b
  ret double %r
}

define double @select.d.expand(i1 %c, double %a, double %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call double @FCSELD(i1 %ne, double %a, double %b)
  ret double %r
}

define %fnzcv @FCMPSrr(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 00 1000 n:5 00000" "asm"="fcmp {n}, {m}" "sets"="nzcv" {
  %a = fpext float %n to double
  %b = fpext float %m to double
  %f0 = insertvalue %fnzcv poison, double %a, 0
  %f = insertvalue %fnzcv %f0, double %b, 1
  ret %fnzcv %f
}

define %fnzcv @FCMPSr0(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 00000 00 1000 n:5 01000" "asm"="fcmp {n}, #0.0" "sets"="nzcv" {
  %a = fpext float %n to double
  %f0 = insertvalue %fnzcv poison, double %a, 0
  %f = insertvalue %fnzcv %f0, double 0.0, 1
  ret %fnzcv %f
}

define float @FADDS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0010 10 n:5 d:5" "asm"="fadd {d}, {n}, {m}" {
  %r = fadd float %n, %m
  ret float %r
}

define float @FSUBS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0011 10 n:5 d:5" "asm"="fsub {d}, {n}, {m}" {
  %r = fsub float %n, %m
  ret float %r
}

define float @FMULS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0000 10 n:5 d:5" "asm"="fmul {d}, {n}, {m}" {
  %r = fmul float %n, %m
  ret float %r
}

define float @FDIVS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0001 10 n:5 d:5" "asm"="fdiv {d}, {n}, {m}" {
  %r = fdiv float %n, %m
  ret float %r
}

define float @FNEGS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000010 10000 n:5 d:5" "asm"="fneg {d}, {n}" {
  %r = fneg float %n
  ret float %r
}

declare float @llvm.fabs.f32(float)
declare float @llvm.sqrt.f32(float)
declare float @llvm.fmuladd.f32(float, float, float)

define float @FABSS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000001 10000 n:5 d:5" "asm"="fabs {d}, {n}" {
  %r = call float @llvm.fabs.f32(float %n)
  ret float %r
}

define float @FSQRTS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000011 10000 n:5 d:5" "asm"="fsqrt {d}, {n}" {
  %r = call float @llvm.sqrt.f32(float %n)
  ret float %r
}

define float @FMADDS(float "reg"="s" %n, float "reg"="s" %m, float "reg"="s" %a) "enc"="0 0 0 11111 00 0 m:5 0 a:5 n:5 d:5" "asm"="fmadd {d}, {n}, {m}, {a}" {
  %r = call float @llvm.fmuladd.f32(float %n, float %m, float %a)
  ret float %r
}

define float @FCSELS(i1 "cond" %c, float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 c:4 11 n:5 d:5" "asm"="fcsel {d}, {n}, {m}, {c}" {
  %r = select i1 %c, float %n, float %m
  ret float %r
}

define float @FMOVSr(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000000 10000 n:5 d:5" "asm"="fmov {d}, {n}" "copy"="s" {
  ret float %n
}

define float @SCVTFSX(i64 "reg"="x" %n) "enc"="1 0 0 11110 00 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i64 %n to float
  ret float %r
}

define float @UCVTFSX(i64 "reg"="x" %n) "enc"="1 0 0 11110 00 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i64 %n to float
  ret float %r
}

define i64 @FCVTZSXS(float "reg"="s" %n) "enc"="1 0 0 11110 00 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi float %n to i64
  ret i64 %r
}

define i64 @FCVTZUXS(float "reg"="s" %n) "enc"="1 0 0 11110 00 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui float %n to i64
  ret i64 %r
}

define float @SCVTFSW(i32 "reg"="w" %n) "enc"="0 0 0 11110 00 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i32 %n to float
  ret float %r
}

define float @UCVTFSW(i32 "reg"="w" %n) "enc"="0 0 0 11110 00 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i32 %n to float
  ret float %r
}

define i32 @FCVTZSWS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi float %n to i32
  ret i32 %r
}

define i32 @FCVTZUWS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui float %n to i32
  ret i32 %r
}

define float @LDRSui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 01 01 imm12:12=off/4 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]"  {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load float, ptr %p
  ret float %v
}

define void @STRSui(float "reg"="s" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 01 00 imm12:12=off/4 n:5 t:5" "asm"="str {t}, [{n}, #{off}]"  {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  ret void
}

define float @LDURSi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load float, ptr %p
  ret float %v
}

define void @STURSi(float "reg"="s" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  ret void
}

define float @LDRSroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load float, ptr %p
  ret float %v
}

define void @STRSroX(float "reg"="s" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  store float %t, ptr %p
  ret void
}

define { float, ptr } @LDRSpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load float, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { float, ptr } poison, float %v, 0
  %b = insertvalue { float, ptr } %a, ptr %next, 1
  ret { float, ptr } %b
}

define ptr @STRSpost(float "reg"="s" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store float %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define float @select.s(i1 "reg"="w" %c, float "reg"="s" %a, float "reg"="s" %b) "recipe"="select.s.expand" {
  %r = select i1 %c, float %a, float %b
  ret float %r
}

define float @select.s.expand(i1 %c, float %a, float %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call float @FCSELS(i1 %ne, float %a, float %b)
  ret float %r
}

; Between the two widths.
define double @FCVTDS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 0001 01 10000 n:5 d:5" "asm"="fcvt {d}, {n}" {
  %r = fpext float %n to double
  ret double %r
}

define float @FCVTSD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 0001 00 10000 n:5 d:5" "asm"="fcvt {d}, {n}" {
  %r = fptrunc double %n to float
  ret float %r
}

; Between the register files, bit for bit.
define double @FMOVDX(i64 "reg"="x" %n) "enc"="1 00 11110 01 1 00 111 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="fmov.d.x" {
  %r = bitcast i64 %n to double
  ret double %r
}

define i64 @FMOVXD(double "reg"="d" %n) "enc"="1 00 11110 01 1 00 110 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="fmov.x.d" {
  %r = bitcast double %n to i64
  ret i64 %r
}

define float @FMOVSW(i32 "reg"="w" %n) "enc"="0 00 11110 00 1 00 111 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="fmov.s.w" {
  %r = bitcast i32 %n to float
  ret float %r
}

define i32 @FMOVWS(float "reg"="s" %n) "enc"="0 00 11110 00 1 00 110 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="fmov.w.s" {
  %r = bitcast float %n to i32
  ret i32 %r
}

; ===========================================================================
; Vectors (Advanced SIMD). 128-bit vectors live in q registers, 64-bit ones
; in d registers; templates print them with their arrangement, v3.4s. A
; vector of i1 is a mask: lanes of all ones or all zeros, as comparisons
; make them, in a q register.
;
; This section is written by gen_aarch64_vectors.py (one entry per
; arrangement), but is data like the rest.

define <16 x i8> @ADDv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="add {d:16b}, {n:16b}, {m:16b}" {
  %r = add <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @SUBv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:16b}, {n:16b}, {m:16b}" {
  %r = sub <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @MULv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:16b}, {n:16b}, {m:16b}" {
  %r = mul <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @ANDv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @ORRv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @EORv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @BICv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <16 x i8> %m, splat (i8 -1)
  %r = and <16 x i8> %n, %nm
  ret <16 x i8> %r
}

define <16 x i8> @MVNv16b(<16 x i8> "reg"="q" %n) "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <16 x i8> %n, splat (i8 -1)
  ret <16 x i8> %r
}

define <16 x i8> @NEGv16b(<16 x i8> "reg"="q" %n) "enc"="0 1 1 01110 00 10000 01011 10 n:5 d:5" "asm"="neg {d:16b}, {n:16b}" {
  %r = sub <16 x i8> zeroinitializer, %n
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.abs.v16i8(<16 x i8>, i1)

define <16 x i8> @ABSv16b(<16 x i8> "reg"="q" %n) "enc"="0 1 0 01110 00 10000 01011 10 n:5 d:5" "asm"="abs {d:16b}, {n:16b}" {
  %r = call <16 x i8> @llvm.abs.v16i8(<16 x i8> %n, i1 false)
  ret <16 x i8> %r
}

define <16 x i8> @SHLv16b(<16 x i8> "reg"="q" %n, <16 x i8> "imm" %sh) "enc"="0 1 0 011110 immhb:7=8+sh 01010 1 n:5 d:5" "asm"="shl {d:16b}, {n:16b}, #{sh}" {
  %r = shl <16 x i8> %n, %sh
  ret <16 x i8> %r
}

define <16 x i8> @USHRv16b(<16 x i8> "reg"="q" %n, <16 x i8> "imm" %sh) "enc"="0 1 1 011110 immhb:7=16-sh 00000 1 n:5 d:5" "asm"="ushr {d:16b}, {n:16b}, #{sh}" {
  %r = lshr <16 x i8> %n, %sh
  ret <16 x i8> %r
}

define <16 x i8> @SSHRv16b(<16 x i8> "reg"="q" %n, <16 x i8> "imm" %sh) "enc"="0 1 0 011110 immhb:7=16-sh 00000 1 n:5 d:5" "asm"="sshr {d:16b}, {n:16b}, #{sh}" {
  %r = ashr <16 x i8> %n, %sh
  ret <16 x i8> %r
}

define <16 x i1> @CMEQv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp eq <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGTv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp sgt <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGEv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp sge <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHIv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp ugt <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHSv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp uge <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGTsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp slt <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGEsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp sle <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHIsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp ult <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHSsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp ule <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i8> @BSLv16b(<16 x i1> "reg"="q" "tied" %c, <16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" {
  %r = select <16 x i1> %c, <16 x i8> %n, <16 x i8> %m
  ret <16 x i8> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <16 x i8> @MASKv16b(<16 x i1> "reg"="q" %n) "enc"="0 1 1 011110 0001001 00000 1 n:5 d:5" "asm"="ushr {d:16b}, {n:16b}, #7" "nodecode" {
  %r = zext <16 x i1> %n to <16 x i8>
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.smax.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SMAXv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.smax.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.smin.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SMINv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.smin.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.umax.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @UMAXv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.umax.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.umin.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @UMINv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.umin.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

define <16 x i8> @DUPv16b(i8 "reg"="w" %n) "enc"="0 1 0 01110000 00001 0 0001 1 n:5 d:5" "asm"="dup {d:16b}, {n}" "role"="dup.16b" {
  %i = insertelement <16 x i8> poison, i8 %n, i64 0
  %r = shufflevector <16 x i8> %i, <16 x i8> poison, <16 x i32> zeroinitializer
  ret <16 x i8> %r
}

define <8 x i16> @ADDv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="add {d:8h}, {n:8h}, {m:8h}" {
  %r = add <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @SUBv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:8h}, {n:8h}, {m:8h}" {
  %r = sub <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @MULv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:8h}, {n:8h}, {m:8h}" {
  %r = mul <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @ANDv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @ORRv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @EORv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @BICv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <8 x i16> %m, splat (i16 -1)
  %r = and <8 x i16> %n, %nm
  ret <8 x i16> %r
}

define <8 x i16> @MVNv8h(<8 x i16> "reg"="q" %n) "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <8 x i16> %n, splat (i16 -1)
  ret <8 x i16> %r
}

define <8 x i16> @NEGv8h(<8 x i16> "reg"="q" %n) "enc"="0 1 1 01110 01 10000 01011 10 n:5 d:5" "asm"="neg {d:8h}, {n:8h}" {
  %r = sub <8 x i16> zeroinitializer, %n
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.abs.v8i16(<8 x i16>, i1)

define <8 x i16> @ABSv8h(<8 x i16> "reg"="q" %n) "enc"="0 1 0 01110 01 10000 01011 10 n:5 d:5" "asm"="abs {d:8h}, {n:8h}" {
  %r = call <8 x i16> @llvm.abs.v8i16(<8 x i16> %n, i1 false)
  ret <8 x i16> %r
}

define <8 x i16> @SHLv8h(<8 x i16> "reg"="q" %n, <8 x i16> "imm" %sh) "enc"="0 1 0 011110 immhb:7=16+sh 01010 1 n:5 d:5" "asm"="shl {d:8h}, {n:8h}, #{sh}" {
  %r = shl <8 x i16> %n, %sh
  ret <8 x i16> %r
}

define <8 x i16> @USHRv8h(<8 x i16> "reg"="q" %n, <8 x i16> "imm" %sh) "enc"="0 1 1 011110 immhb:7=32-sh 00000 1 n:5 d:5" "asm"="ushr {d:8h}, {n:8h}, #{sh}" {
  %r = lshr <8 x i16> %n, %sh
  ret <8 x i16> %r
}

define <8 x i16> @SSHRv8h(<8 x i16> "reg"="q" %n, <8 x i16> "imm" %sh) "enc"="0 1 0 011110 immhb:7=32-sh 00000 1 n:5 d:5" "asm"="sshr {d:8h}, {n:8h}, #{sh}" {
  %r = ashr <8 x i16> %n, %sh
  ret <8 x i16> %r
}

define <8 x i1> @CMEQv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp eq <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp sgt <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp sge <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp ugt <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp uge <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp slt <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp sle <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp ult <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp ule <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i16> @BSLv8h(<8 x i1> "reg"="q" "tied" %c, <8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <8 x i1> %c, <8 x i16> %n, <8 x i16> %m
  ret <8 x i16> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <8 x i16> @MASKv8h(<8 x i1> "reg"="q" %n) "enc"="0 1 1 011110 0010001 00000 1 n:5 d:5" "asm"="ushr {d:8h}, {n:8h}, #15" "nodecode" {
  %r = zext <8 x i1> %n to <8 x i16>
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.smax.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SMAXv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.smax.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.smin.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SMINv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.smin.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.umax.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @UMAXv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.umax.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.umin.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @UMINv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.umin.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

define <8 x i16> @DUPv8h(i16 "reg"="w" %n) "enc"="0 1 0 01110000 00010 0 0001 1 n:5 d:5" "asm"="dup {d:8h}, {n}" "role"="dup.8h" {
  %i = insertelement <8 x i16> poison, i16 %n, i64 0
  %r = shufflevector <8 x i16> %i, <8 x i16> poison, <8 x i32> zeroinitializer
  ret <8 x i16> %r
}

define <4 x i32> @ADDv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="add {d:4s}, {n:4s}, {m:4s}" {
  %r = add <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @SUBv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:4s}, {n:4s}, {m:4s}" {
  %r = sub <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @MULv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:4s}, {n:4s}, {m:4s}" {
  %r = mul <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @ANDv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @ORRv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @EORv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @BICv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <4 x i32> %m, splat (i32 -1)
  %r = and <4 x i32> %n, %nm
  ret <4 x i32> %r
}

define <4 x i32> @MVNv4s(<4 x i32> "reg"="q" %n) "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <4 x i32> %n, splat (i32 -1)
  ret <4 x i32> %r
}

define <4 x i32> @NEGv4s(<4 x i32> "reg"="q" %n) "enc"="0 1 1 01110 10 10000 01011 10 n:5 d:5" "asm"="neg {d:4s}, {n:4s}" {
  %r = sub <4 x i32> zeroinitializer, %n
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.abs.v4i32(<4 x i32>, i1)

define <4 x i32> @ABSv4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 10 10000 01011 10 n:5 d:5" "asm"="abs {d:4s}, {n:4s}" {
  %r = call <4 x i32> @llvm.abs.v4i32(<4 x i32> %n, i1 false)
  ret <4 x i32> %r
}

define <4 x i32> @SHLv4s(<4 x i32> "reg"="q" %n, <4 x i32> "imm" %sh) "enc"="0 1 0 011110 immhb:7=32+sh 01010 1 n:5 d:5" "asm"="shl {d:4s}, {n:4s}, #{sh}" {
  %r = shl <4 x i32> %n, %sh
  ret <4 x i32> %r
}

define <4 x i32> @USHRv4s(<4 x i32> "reg"="q" %n, <4 x i32> "imm" %sh) "enc"="0 1 1 011110 immhb:7=64-sh 00000 1 n:5 d:5" "asm"="ushr {d:4s}, {n:4s}, #{sh}" {
  %r = lshr <4 x i32> %n, %sh
  ret <4 x i32> %r
}

define <4 x i32> @SSHRv4s(<4 x i32> "reg"="q" %n, <4 x i32> "imm" %sh) "enc"="0 1 0 011110 immhb:7=64-sh 00000 1 n:5 d:5" "asm"="sshr {d:4s}, {n:4s}, #{sh}" {
  %r = ashr <4 x i32> %n, %sh
  ret <4 x i32> %r
}

define <4 x i1> @CMEQv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp eq <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp sgt <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp sge <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp ugt <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp uge <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp slt <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp sle <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp ult <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp ule <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i32> @BSLv4s(<4 x i1> "reg"="q" "tied" %c, <4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <4 x i1> %c, <4 x i32> %n, <4 x i32> %m
  ret <4 x i32> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <4 x i32> @MASKv4s(<4 x i1> "reg"="q" %n) "enc"="0 1 1 011110 0100001 00000 1 n:5 d:5" "asm"="ushr {d:4s}, {n:4s}, #31" "nodecode" {
  %r = zext <4 x i1> %n to <4 x i32>
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.smax.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SMAXv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.smin.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SMINv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.smin.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.umax.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @UMAXv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.umax.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.umin.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @UMINv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.umin.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @DUPv4s(i32 "reg"="w" %n) "enc"="0 1 0 01110000 00100 0 0001 1 n:5 d:5" "asm"="dup {d:4s}, {n}" "role"="dup.4s" {
  %i = insertelement <4 x i32> poison, i32 %n, i64 0
  %r = shufflevector <4 x i32> %i, <4 x i32> poison, <4 x i32> zeroinitializer
  ret <4 x i32> %r
}

define <2 x i64> @ADDv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 m:5 10000 1 n:5 d:5" "asm"="add {d:2d}, {n:2d}, {m:2d}" {
  %r = add <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @SUBv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:2d}, {n:2d}, {m:2d}" {
  %r = sub <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @ANDv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @ORRv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @EORv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @BICv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <2 x i64> %m, splat (i64 -1)
  %r = and <2 x i64> %n, %nm
  ret <2 x i64> %r
}

define <2 x i64> @MVNv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <2 x i64> %n, splat (i64 -1)
  ret <2 x i64> %r
}

define <2 x i64> @NEGv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 1 01110 11 10000 01011 10 n:5 d:5" "asm"="neg {d:2d}, {n:2d}" {
  %r = sub <2 x i64> zeroinitializer, %n
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.abs.v2i64(<2 x i64>, i1)

define <2 x i64> @ABSv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 0 01110 11 10000 01011 10 n:5 d:5" "asm"="abs {d:2d}, {n:2d}" {
  %r = call <2 x i64> @llvm.abs.v2i64(<2 x i64> %n, i1 false)
  ret <2 x i64> %r
}

define <2 x i64> @SHLv2d(<2 x i64> "reg"="q" %n, <2 x i64> "imm" %sh) "enc"="0 1 0 011110 immhb:7=64+sh 01010 1 n:5 d:5" "asm"="shl {d:2d}, {n:2d}, #{sh}" {
  %r = shl <2 x i64> %n, %sh
  ret <2 x i64> %r
}

define <2 x i64> @USHRv2d(<2 x i64> "reg"="q" %n, <2 x i64> "imm" %sh) "enc"="0 1 1 011110 immhb:7=128-sh 00000 1 n:5 d:5" "asm"="ushr {d:2d}, {n:2d}, #{sh}" {
  %r = lshr <2 x i64> %n, %sh
  ret <2 x i64> %r
}

define <2 x i64> @SSHRv2d(<2 x i64> "reg"="q" %n, <2 x i64> "imm" %sh) "enc"="0 1 0 011110 immhb:7=128-sh 00000 1 n:5 d:5" "asm"="sshr {d:2d}, {n:2d}, #{sh}" {
  %r = ashr <2 x i64> %n, %sh
  ret <2 x i64> %r
}

define <2 x i1> @CMEQv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp eq <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp sgt <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp sge <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp ugt <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp uge <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp slt <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp sle <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp ult <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp ule <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i64> @BSLv2d(<2 x i1> "reg"="q" "tied" %c, <2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x i64> %n, <2 x i64> %m
  ret <2 x i64> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <2 x i64> @MASKv2d(<2 x i1> "reg"="q" %n) "enc"="0 1 1 011110 1000001 00000 1 n:5 d:5" "asm"="ushr {d:2d}, {n:2d}, #63" "nodecode" {
  %r = zext <2 x i1> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @DUPv2d(i64 "reg"="x" %n) "enc"="0 1 0 01110000 01000 0 0001 1 n:5 d:5" "asm"="dup {d:2d}, {n}" "role"="dup.2d" {
  %i = insertelement <2 x i64> poison, i64 %n, i64 0
  %r = shufflevector <2 x i64> %i, <2 x i64> poison, <2 x i32> zeroinitializer
  ret <2 x i64> %r
}

define <8 x i8> @ADDv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="add {d:8b}, {n:8b}, {m:8b}" {
  %r = add <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @SUBv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:8b}, {n:8b}, {m:8b}" {
  %r = sub <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @MULv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:8b}, {n:8b}, {m:8b}" {
  %r = mul <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @ANDv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:8b}, {n:8b}, {m:8b}" {
  %r = and <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @ORRv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:8b}, {n:8b}, {m:8b}" {
  %r = or <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @EORv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:8b}, {n:8b}, {m:8b}" {
  %r = xor <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @BICv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:8b}, {n:8b}, {m:8b}" {
  %nm = xor <8 x i8> %m, splat (i8 -1)
  %r = and <8 x i8> %n, %nm
  ret <8 x i8> %r
}

define <8 x i8> @MVNv8b(<8 x i8> "reg"="v" %n) "enc"="0 0 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:8b}, {n:8b}" {
  %r = xor <8 x i8> %n, splat (i8 -1)
  ret <8 x i8> %r
}

define <8 x i8> @NEGv8b(<8 x i8> "reg"="v" %n) "enc"="0 0 1 01110 00 10000 01011 10 n:5 d:5" "asm"="neg {d:8b}, {n:8b}" {
  %r = sub <8 x i8> zeroinitializer, %n
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.abs.v8i8(<8 x i8>, i1)

define <8 x i8> @ABSv8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 10000 01011 10 n:5 d:5" "asm"="abs {d:8b}, {n:8b}" {
  %r = call <8 x i8> @llvm.abs.v8i8(<8 x i8> %n, i1 false)
  ret <8 x i8> %r
}

define <8 x i8> @SHLv8b(<8 x i8> "reg"="v" %n, <8 x i8> "imm" %sh) "enc"="0 0 0 011110 immhb:7=8+sh 01010 1 n:5 d:5" "asm"="shl {d:8b}, {n:8b}, #{sh}" {
  %r = shl <8 x i8> %n, %sh
  ret <8 x i8> %r
}

define <8 x i8> @USHRv8b(<8 x i8> "reg"="v" %n, <8 x i8> "imm" %sh) "enc"="0 0 1 011110 immhb:7=16-sh 00000 1 n:5 d:5" "asm"="ushr {d:8b}, {n:8b}, #{sh}" {
  %r = lshr <8 x i8> %n, %sh
  ret <8 x i8> %r
}

define <8 x i8> @SSHRv8b(<8 x i8> "reg"="v" %n, <8 x i8> "imm" %sh) "enc"="0 0 0 011110 immhb:7=16-sh 00000 1 n:5 d:5" "asm"="sshr {d:8b}, {n:8b}, #{sh}" {
  %r = ashr <8 x i8> %n, %sh
  ret <8 x i8> %r
}

define <8 x i1> @CMEQv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp eq <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp sgt <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp sge <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp ugt <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp uge <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp slt <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp sle <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp ult <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp ule <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i8> @BSLv8b(<8 x i1> "reg"="q" "tied" %c, <8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" {
  %r = select <8 x i1> %c, <8 x i8> %n, <8 x i8> %m
  ret <8 x i8> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <8 x i8> @MASKv8b(<8 x i1> "reg"="q" %n) "enc"="0 0 1 011110 0001001 00000 1 n:5 d:5" "asm"="ushr {d:8b}, {n:8b}, #7" "nodecode" {
  %r = zext <8 x i1> %n to <8 x i8>
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.smax.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SMAXv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.smax.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.smin.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SMINv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.smin.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.umax.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @UMAXv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.umax.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.umin.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @UMINv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.umin.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

define <8 x i8> @DUPv8b(i8 "reg"="w" %n) "enc"="0 0 0 01110000 00001 0 0001 1 n:5 d:5" "asm"="dup {d:8b}, {n}" "role"="dup.8b" {
  %i = insertelement <8 x i8> poison, i8 %n, i64 0
  %r = shufflevector <8 x i8> %i, <8 x i8> poison, <8 x i32> zeroinitializer
  ret <8 x i8> %r
}

define <4 x i16> @ADDv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="add {d:4h}, {n:4h}, {m:4h}" {
  %r = add <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @SUBv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:4h}, {n:4h}, {m:4h}" {
  %r = sub <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @MULv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:4h}, {n:4h}, {m:4h}" {
  %r = mul <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @ANDv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:8b}, {n:8b}, {m:8b}" {
  %r = and <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @ORRv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:8b}, {n:8b}, {m:8b}" {
  %r = or <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @EORv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:8b}, {n:8b}, {m:8b}" {
  %r = xor <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @BICv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:8b}, {n:8b}, {m:8b}" {
  %nm = xor <4 x i16> %m, splat (i16 -1)
  %r = and <4 x i16> %n, %nm
  ret <4 x i16> %r
}

define <4 x i16> @MVNv4h(<4 x i16> "reg"="v" %n) "enc"="0 0 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:8b}, {n:8b}" {
  %r = xor <4 x i16> %n, splat (i16 -1)
  ret <4 x i16> %r
}

define <4 x i16> @NEGv4h(<4 x i16> "reg"="v" %n) "enc"="0 0 1 01110 01 10000 01011 10 n:5 d:5" "asm"="neg {d:4h}, {n:4h}" {
  %r = sub <4 x i16> zeroinitializer, %n
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.abs.v4i16(<4 x i16>, i1)

define <4 x i16> @ABSv4h(<4 x i16> "reg"="v" %n) "enc"="0 0 0 01110 01 10000 01011 10 n:5 d:5" "asm"="abs {d:4h}, {n:4h}" {
  %r = call <4 x i16> @llvm.abs.v4i16(<4 x i16> %n, i1 false)
  ret <4 x i16> %r
}

define <4 x i16> @SHLv4h(<4 x i16> "reg"="v" %n, <4 x i16> "imm" %sh) "enc"="0 0 0 011110 immhb:7=16+sh 01010 1 n:5 d:5" "asm"="shl {d:4h}, {n:4h}, #{sh}" {
  %r = shl <4 x i16> %n, %sh
  ret <4 x i16> %r
}

define <4 x i16> @USHRv4h(<4 x i16> "reg"="v" %n, <4 x i16> "imm" %sh) "enc"="0 0 1 011110 immhb:7=32-sh 00000 1 n:5 d:5" "asm"="ushr {d:4h}, {n:4h}, #{sh}" {
  %r = lshr <4 x i16> %n, %sh
  ret <4 x i16> %r
}

define <4 x i16> @SSHRv4h(<4 x i16> "reg"="v" %n, <4 x i16> "imm" %sh) "enc"="0 0 0 011110 immhb:7=32-sh 00000 1 n:5 d:5" "asm"="sshr {d:4h}, {n:4h}, #{sh}" {
  %r = ashr <4 x i16> %n, %sh
  ret <4 x i16> %r
}

define <4 x i1> @CMEQv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp eq <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp sgt <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp sge <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp ugt <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp uge <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp slt <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp sle <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp ult <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp ule <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i16> @BSLv4h(<4 x i1> "reg"="q" "tied" %c, <4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" "nodecode" {
  %r = select <4 x i1> %c, <4 x i16> %n, <4 x i16> %m
  ret <4 x i16> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <4 x i16> @MASKv4h(<4 x i1> "reg"="q" %n) "enc"="0 0 1 011110 0010001 00000 1 n:5 d:5" "asm"="ushr {d:4h}, {n:4h}, #15" "nodecode" {
  %r = zext <4 x i1> %n to <4 x i16>
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.smax.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SMAXv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.smax.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.smin.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SMINv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.smin.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.umax.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @UMAXv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.umax.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.umin.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @UMINv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.umin.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

define <4 x i16> @DUPv4h(i16 "reg"="w" %n) "enc"="0 0 0 01110000 00010 0 0001 1 n:5 d:5" "asm"="dup {d:4h}, {n}" "role"="dup.4h" {
  %i = insertelement <4 x i16> poison, i16 %n, i64 0
  %r = shufflevector <4 x i16> %i, <4 x i16> poison, <4 x i32> zeroinitializer
  ret <4 x i16> %r
}

define <2 x i32> @ADDv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="add {d:2s}, {n:2s}, {m:2s}" {
  %r = add <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @SUBv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:2s}, {n:2s}, {m:2s}" {
  %r = sub <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @MULv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:2s}, {n:2s}, {m:2s}" {
  %r = mul <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @ANDv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:8b}, {n:8b}, {m:8b}" {
  %r = and <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @ORRv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:8b}, {n:8b}, {m:8b}" {
  %r = or <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @EORv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:8b}, {n:8b}, {m:8b}" {
  %r = xor <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @BICv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:8b}, {n:8b}, {m:8b}" {
  %nm = xor <2 x i32> %m, splat (i32 -1)
  %r = and <2 x i32> %n, %nm
  ret <2 x i32> %r
}

define <2 x i32> @MVNv2s(<2 x i32> "reg"="v" %n) "enc"="0 0 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:8b}, {n:8b}" {
  %r = xor <2 x i32> %n, splat (i32 -1)
  ret <2 x i32> %r
}

define <2 x i32> @NEGv2s(<2 x i32> "reg"="v" %n) "enc"="0 0 1 01110 10 10000 01011 10 n:5 d:5" "asm"="neg {d:2s}, {n:2s}" {
  %r = sub <2 x i32> zeroinitializer, %n
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.abs.v2i32(<2 x i32>, i1)

define <2 x i32> @ABSv2s(<2 x i32> "reg"="v" %n) "enc"="0 0 0 01110 10 10000 01011 10 n:5 d:5" "asm"="abs {d:2s}, {n:2s}" {
  %r = call <2 x i32> @llvm.abs.v2i32(<2 x i32> %n, i1 false)
  ret <2 x i32> %r
}

define <2 x i32> @SHLv2s(<2 x i32> "reg"="v" %n, <2 x i32> "imm" %sh) "enc"="0 0 0 011110 immhb:7=32+sh 01010 1 n:5 d:5" "asm"="shl {d:2s}, {n:2s}, #{sh}" {
  %r = shl <2 x i32> %n, %sh
  ret <2 x i32> %r
}

define <2 x i32> @USHRv2s(<2 x i32> "reg"="v" %n, <2 x i32> "imm" %sh) "enc"="0 0 1 011110 immhb:7=64-sh 00000 1 n:5 d:5" "asm"="ushr {d:2s}, {n:2s}, #{sh}" {
  %r = lshr <2 x i32> %n, %sh
  ret <2 x i32> %r
}

define <2 x i32> @SSHRv2s(<2 x i32> "reg"="v" %n, <2 x i32> "imm" %sh) "enc"="0 0 0 011110 immhb:7=64-sh 00000 1 n:5 d:5" "asm"="sshr {d:2s}, {n:2s}, #{sh}" {
  %r = ashr <2 x i32> %n, %sh
  ret <2 x i32> %r
}

define <2 x i1> @CMEQv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp eq <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp sgt <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp sge <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp ugt <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp uge <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp slt <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp sle <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp ult <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp ule <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i32> @BSLv2s(<2 x i1> "reg"="q" "tied" %c, <2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x i32> %n, <2 x i32> %m
  ret <2 x i32> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <2 x i32> @MASKv2s(<2 x i1> "reg"="q" %n) "enc"="0 0 1 011110 0100001 00000 1 n:5 d:5" "asm"="ushr {d:2s}, {n:2s}, #31" "nodecode" {
  %r = zext <2 x i1> %n to <2 x i32>
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.smax.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SMAXv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.smax.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.smin.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SMINv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.smin.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.umax.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @UMAXv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.umax.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.umin.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @UMINv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.umin.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

define <2 x i32> @DUPv2s(i32 "reg"="w" %n) "enc"="0 0 0 01110000 00100 0 0001 1 n:5 d:5" "asm"="dup {d:2s}, {n}" "role"="dup.2s" {
  %i = insertelement <2 x i32> poison, i32 %n, i64 0
  %r = shufflevector <2 x i32> %i, <2 x i32> poison, <2 x i32> zeroinitializer
  ret <2 x i32> %r
}

define i8 @UMOVb(<16 x i8> "reg"="q" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*2+1 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.b}[{idx}]" {
  %r = extractelement <16 x i8> %n, i64 %idx
  ret i8 %r
}

define <16 x i8> @INSb(<16 x i8> "reg"="q" "tied" %old, i8 "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*2+1 0 0011 1 n:5 d:5" "asm"="mov {d:.b}[{idx}], {n}" "role"="ins.b" {
  %r = insertelement <16 x i8> %old, i8 %n, i64 %idx
  ret <16 x i8> %r
}

define i16 @UMOVh(<8 x i16> "reg"="q" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*4+2 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.h}[{idx}]" {
  %r = extractelement <8 x i16> %n, i64 %idx
  ret i16 %r
}

define <8 x i16> @INSh(<8 x i16> "reg"="q" "tied" %old, i16 "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*4+2 0 0011 1 n:5 d:5" "asm"="mov {d:.h}[{idx}], {n}" "role"="ins.h" {
  %r = insertelement <8 x i16> %old, i16 %n, i64 %idx
  ret <8 x i16> %r
}

define i32 @UMOVs(<4 x i32> "reg"="q" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*8+4 0 0111 1 n:5 d:5" "asm"="mov {d}, {n:.s}[{idx}]" {
  %r = extractelement <4 x i32> %n, i64 %idx
  ret i32 %r
}

define <4 x i32> @INSs(<4 x i32> "reg"="q" "tied" %old, i32 "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*8+4 0 0011 1 n:5 d:5" "asm"="mov {d:.s}[{idx}], {n}" "role"="ins.s" {
  %r = insertelement <4 x i32> %old, i32 %n, i64 %idx
  ret <4 x i32> %r
}

define i64 @UMOVd(<2 x i64> "reg"="q" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*16+8 0 0111 1 n:5 d:5" "asm"="mov {d}, {n:.d}[{idx}]" {
  %r = extractelement <2 x i64> %n, i64 %idx
  ret i64 %r
}

define <2 x i64> @INSd(<2 x i64> "reg"="q" "tied" %old, i64 "reg"="x" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*16+8 0 0011 1 n:5 d:5" "asm"="mov {d:.d}[{idx}], {n}" "role"="ins.d" {
  %r = insertelement <2 x i64> %old, i64 %n, i64 %idx
  ret <2 x i64> %r
}

define <4 x float> @FADDv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 0 01110 0 0 1 m:5 11010 1 n:5 d:5" "asm"="fadd {d:4s}, {n:4s}, {m:4s}" {
  %r = fadd <4 x float> %n, %m
  ret <4 x float> %r
}

define <4 x float> @FSUBv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 0 01110 1 0 1 m:5 11010 1 n:5 d:5" "asm"="fsub {d:4s}, {n:4s}, {m:4s}" {
  %r = fsub <4 x float> %n, %m
  ret <4 x float> %r
}

define <4 x float> @FMULv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 0 0 1 m:5 11011 1 n:5 d:5" "asm"="fmul {d:4s}, {n:4s}, {m:4s}" {
  %r = fmul <4 x float> %n, %m
  ret <4 x float> %r
}

define <4 x float> @FDIVv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 0 0 1 m:5 11111 1 n:5 d:5" "asm"="fdiv {d:4s}, {n:4s}, {m:4s}" {
  %r = fdiv <4 x float> %n, %m
  ret <4 x float> %r
}

declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>)

define <4 x float> @FMLAv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m, <4 x float> "reg"="q" "tied" %a) "enc"="0 1 0 01110 0 0 1 m:5 11001 1 n:5 d:5" "asm"="fmla {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %n, <4 x float> %m, <4 x float> %a)
  ret <4 x float> %r
}

define <4 x float> @FNEGv4s(<4 x float> "reg"="q" %n) "enc"="0 1 1 01110 1 0 10000 01111 10 n:5 d:5" "asm"="fneg {d:4s}, {n:4s}" {
  %r = fneg <4 x float> %n
  ret <4 x float> %r
}

define <4 x i1> @FCMEQv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 0 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmeq {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = fcmp oeq <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGEv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmge {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = fcmp oge <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGTv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 1 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmgt {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = fcmp ogt <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGEsv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 0 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmge {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = fcmp ole <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGTsv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 1 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmgt {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = fcmp olt <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x float> @BSLv4sf(<4 x i1> "reg"="q" "tied" %c, <4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <4 x i1> %c, <4 x float> %n, <4 x float> %m
  ret <4 x float> %r
}

define <4 x float> @SCVTFv4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 0 0 10000 11101 10 n:5 d:5" "asm"="scvtf {d:4s}, {n:4s}" {
  %r = sitofp <4 x i32> %n to <4 x float>
  ret <4 x float> %r
}

define <4 x float> @UCVTFv4s(<4 x i32> "reg"="q" %n) "enc"="0 1 1 01110 0 0 10000 11101 10 n:5 d:5" "asm"="ucvtf {d:4s}, {n:4s}" {
  %r = uitofp <4 x i32> %n to <4 x float>
  ret <4 x float> %r
}

define <4 x i32> @FCVTZSv4s(<4 x float> "reg"="q" %n) "enc"="0 1 0 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzs {d:4s}, {n:4s}" {
  %r = fptosi <4 x float> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @FCVTZUv4s(<4 x float> "reg"="q" %n) "enc"="0 1 1 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzu {d:4s}, {n:4s}" {
  %r = fptoui <4 x float> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x float> @DUPf4s(float "reg"="s" %n) "enc"="0 1 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {d:4s}, {n:.s}[0]" {
  %i = insertelement <4 x float> poison, float %n, i64 0
  %r = shufflevector <4 x float> %i, <4 x float> poison, <4 x i32> zeroinitializer
  ret <4 x float> %r
}

define float @DUPes(<4 x float> "reg"="q" %n, i64 "imm" %idx) "enc"="01 0 11110000 imm5:5=idx*8+4 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.s}[{idx}]" {
  %r = extractelement <4 x float> %n, i64 %idx
  ret float %r
}

define <2 x double> @FADDv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 0 01110 0 1 1 m:5 11010 1 n:5 d:5" "asm"="fadd {d:2d}, {n:2d}, {m:2d}" {
  %r = fadd <2 x double> %n, %m
  ret <2 x double> %r
}

define <2 x double> @FSUBv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 0 01110 1 1 1 m:5 11010 1 n:5 d:5" "asm"="fsub {d:2d}, {n:2d}, {m:2d}" {
  %r = fsub <2 x double> %n, %m
  ret <2 x double> %r
}

define <2 x double> @FMULv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 0 1 1 m:5 11011 1 n:5 d:5" "asm"="fmul {d:2d}, {n:2d}, {m:2d}" {
  %r = fmul <2 x double> %n, %m
  ret <2 x double> %r
}

define <2 x double> @FDIVv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 0 1 1 m:5 11111 1 n:5 d:5" "asm"="fdiv {d:2d}, {n:2d}, {m:2d}" {
  %r = fdiv <2 x double> %n, %m
  ret <2 x double> %r
}

declare <2 x double> @llvm.fmuladd.v2f64(<2 x double>, <2 x double>, <2 x double>)

define <2 x double> @FMLAv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m, <2 x double> "reg"="q" "tied" %a) "enc"="0 1 0 01110 0 1 1 m:5 11001 1 n:5 d:5" "asm"="fmla {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> %n, <2 x double> %m, <2 x double> %a)
  ret <2 x double> %r
}

define <2 x double> @FNEGv2d(<2 x double> "reg"="q" %n) "enc"="0 1 1 01110 1 1 10000 01111 10 n:5 d:5" "asm"="fneg {d:2d}, {n:2d}" {
  %r = fneg <2 x double> %n
  ret <2 x double> %r
}

define <2 x i1> @FCMEQv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 0 01110 0 1 1 m:5 11100 1 n:5 d:5" "asm"="fcmeq {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = fcmp oeq <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 0 1 1 m:5 11100 1 n:5 d:5" "asm"="fcmge {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = fcmp oge <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 1 1 1 m:5 11100 1 n:5 d:5" "asm"="fcmgt {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = fcmp ogt <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEsv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 0 1 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmge {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = fcmp ole <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTsv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 1 1 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmgt {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = fcmp olt <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x double> @BSLv2df(<2 x i1> "reg"="q" "tied" %c, <2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x double> %n, <2 x double> %m
  ret <2 x double> %r
}

define <2 x double> @SCVTFv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 0 01110 0 1 10000 11101 10 n:5 d:5" "asm"="scvtf {d:2d}, {n:2d}" {
  %r = sitofp <2 x i64> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @UCVTFv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 1 01110 0 1 10000 11101 10 n:5 d:5" "asm"="ucvtf {d:2d}, {n:2d}" {
  %r = uitofp <2 x i64> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x i64> @FCVTZSv2d(<2 x double> "reg"="q" %n) "enc"="0 1 0 01110 1 1 10000 11011 10 n:5 d:5" "asm"="fcvtzs {d:2d}, {n:2d}" {
  %r = fptosi <2 x double> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @FCVTZUv2d(<2 x double> "reg"="q" %n) "enc"="0 1 1 01110 1 1 10000 11011 10 n:5 d:5" "asm"="fcvtzu {d:2d}, {n:2d}" {
  %r = fptoui <2 x double> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x double> @DUPf2d(double "reg"="d" %n) "enc"="0 1 0 01110000 01000 0 0000 1 n:5 d:5" "asm"="dup {d:2d}, {n:.d}[0]" {
  %i = insertelement <2 x double> poison, double %n, i64 0
  %r = shufflevector <2 x double> %i, <2 x double> poison, <2 x i32> zeroinitializer
  ret <2 x double> %r
}

define double @DUPed(<2 x double> "reg"="q" %n, i64 "imm" %idx) "enc"="01 0 11110000 imm5:5=idx*16+8 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[{idx}]" {
  %r = extractelement <2 x double> %n, i64 %idx
  ret double %r
}

define <2 x float> @FADDv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 0 01110 0 0 1 m:5 11010 1 n:5 d:5" "asm"="fadd {d:2s}, {n:2s}, {m:2s}" {
  %r = fadd <2 x float> %n, %m
  ret <2 x float> %r
}

define <2 x float> @FSUBv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 0 01110 1 0 1 m:5 11010 1 n:5 d:5" "asm"="fsub {d:2s}, {n:2s}, {m:2s}" {
  %r = fsub <2 x float> %n, %m
  ret <2 x float> %r
}

define <2 x float> @FMULv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 0 0 1 m:5 11011 1 n:5 d:5" "asm"="fmul {d:2s}, {n:2s}, {m:2s}" {
  %r = fmul <2 x float> %n, %m
  ret <2 x float> %r
}

define <2 x float> @FDIVv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 0 0 1 m:5 11111 1 n:5 d:5" "asm"="fdiv {d:2s}, {n:2s}, {m:2s}" {
  %r = fdiv <2 x float> %n, %m
  ret <2 x float> %r
}

declare <2 x float> @llvm.fmuladd.v2f32(<2 x float>, <2 x float>, <2 x float>)

define <2 x float> @FMLAv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m, <2 x float> "reg"="v" "tied" %a) "enc"="0 0 0 01110 0 0 1 m:5 11001 1 n:5 d:5" "asm"="fmla {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x float> @llvm.fmuladd.v2f32(<2 x float> %n, <2 x float> %m, <2 x float> %a)
  ret <2 x float> %r
}

define <2 x float> @FNEGv2s(<2 x float> "reg"="v" %n) "enc"="0 0 1 01110 1 0 10000 01111 10 n:5 d:5" "asm"="fneg {d:2s}, {n:2s}" {
  %r = fneg <2 x float> %n
  ret <2 x float> %r
}

define <2 x i1> @FCMEQv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 0 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmeq {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = fcmp oeq <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmge {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = fcmp oge <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 1 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmgt {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = fcmp ogt <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEsv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 0 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmge {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = fcmp ole <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTsv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 1 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmgt {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = fcmp olt <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x float> @BSLv2sf(<2 x i1> "reg"="q" "tied" %c, <2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x float> %n, <2 x float> %m
  ret <2 x float> %r
}

define <2 x float> @SCVTFv2s(<2 x i32> "reg"="v" %n) "enc"="0 0 0 01110 0 0 10000 11101 10 n:5 d:5" "asm"="scvtf {d:2s}, {n:2s}" {
  %r = sitofp <2 x i32> %n to <2 x float>
  ret <2 x float> %r
}

define <2 x float> @UCVTFv2s(<2 x i32> "reg"="v" %n) "enc"="0 0 1 01110 0 0 10000 11101 10 n:5 d:5" "asm"="ucvtf {d:2s}, {n:2s}" {
  %r = uitofp <2 x i32> %n to <2 x float>
  ret <2 x float> %r
}

define <2 x i32> @FCVTZSv2s(<2 x float> "reg"="v" %n) "enc"="0 0 0 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzs {d:2s}, {n:2s}" {
  %r = fptosi <2 x float> %n to <2 x i32>
  ret <2 x i32> %r
}

define <2 x i32> @FCVTZUv2s(<2 x float> "reg"="v" %n) "enc"="0 0 1 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzu {d:2s}, {n:2s}" {
  %r = fptoui <2 x float> %n to <2 x i32>
  ret <2 x i32> %r
}

define <8 x i16> @SXTL8h(<8 x i8> "reg"="v" %n) "enc"="0 0 0 011110 0001000 10100 1 n:5 d:5" "asm"="sxtl {d:8h}, {n:8b}" {
  %r = sext <8 x i8> %n to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @SXTL28h(<16 x i8> "reg"="q" %n) "enc"="0 1 0 011110 0001000 10100 1 n:5 d:5" "asm"="sxtl2 {d:8h}, {n:16b}" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %r = sext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @UXTL8h(<8 x i8> "reg"="v" %n) "enc"="0 0 1 011110 0001000 10100 1 n:5 d:5" "asm"="uxtl {d:8h}, {n:8b}" {
  %r = zext <8 x i8> %n to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @UXTL28h(<16 x i8> "reg"="q" %n) "enc"="0 1 1 011110 0001000 10100 1 n:5 d:5" "asm"="uxtl2 {d:8h}, {n:16b}" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %r = zext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i8> @XTN8b(<8 x i16> "reg"="q" %n) "enc"="0 0 0 01110 00 10000 10010 10 n:5 d:5" "asm"="xtn {d:8b}, {n:8h}" {
  %r = trunc <8 x i16> %n to <8 x i8>
  ret <8 x i8> %r
}

define <16 x i8> @XTN216b(<8 x i8> "reg"="v" "tied" %lo, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 00 10000 10010 10 m:5 d:5" "asm"="xtn2 {d:16b}, {m:8h}" {
  %t = trunc <8 x i16> %m to <8 x i8>
  %r = shufflevector <8 x i8> %lo, <8 x i8> %t, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %r
}

define <4 x i32> @SXTL4s(<4 x i16> "reg"="v" %n) "enc"="0 0 0 011110 0010000 10100 1 n:5 d:5" "asm"="sxtl {d:4s}, {n:4h}" {
  %r = sext <4 x i16> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @SXTL24s(<8 x i16> "reg"="q" %n) "enc"="0 1 0 011110 0010000 10100 1 n:5 d:5" "asm"="sxtl2 {d:4s}, {n:8h}" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %r = sext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @UXTL4s(<4 x i16> "reg"="v" %n) "enc"="0 0 1 011110 0010000 10100 1 n:5 d:5" "asm"="uxtl {d:4s}, {n:4h}" {
  %r = zext <4 x i16> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @UXTL24s(<8 x i16> "reg"="q" %n) "enc"="0 1 1 011110 0010000 10100 1 n:5 d:5" "asm"="uxtl2 {d:4s}, {n:8h}" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %r = zext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i16> @XTN4h(<4 x i32> "reg"="q" %n) "enc"="0 0 0 01110 01 10000 10010 10 n:5 d:5" "asm"="xtn {d:4h}, {n:4s}" {
  %r = trunc <4 x i32> %n to <4 x i16>
  ret <4 x i16> %r
}

define <8 x i16> @XTN28h(<4 x i16> "reg"="v" "tied" %lo, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 01 10000 10010 10 m:5 d:5" "asm"="xtn2 {d:8h}, {m:4s}" {
  %t = trunc <4 x i32> %m to <4 x i16>
  %r = shufflevector <4 x i16> %lo, <4 x i16> %t, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %r
}

define <2 x i64> @SXTL2d(<2 x i32> "reg"="v" %n) "enc"="0 0 0 011110 0100000 10100 1 n:5 d:5" "asm"="sxtl {d:2d}, {n:2s}" {
  %r = sext <2 x i32> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @SXTL22d(<4 x i32> "reg"="q" %n) "enc"="0 1 0 011110 0100000 10100 1 n:5 d:5" "asm"="sxtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %r = sext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @UXTL2d(<2 x i32> "reg"="v" %n) "enc"="0 0 1 011110 0100000 10100 1 n:5 d:5" "asm"="uxtl {d:2d}, {n:2s}" {
  %r = zext <2 x i32> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @UXTL22d(<4 x i32> "reg"="q" %n) "enc"="0 1 1 011110 0100000 10100 1 n:5 d:5" "asm"="uxtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %r = zext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i32> @XTN2s(<2 x i64> "reg"="q" %n) "enc"="0 0 0 01110 10 10000 10010 10 n:5 d:5" "asm"="xtn {d:2s}, {n:2d}" {
  %r = trunc <2 x i64> %n to <2 x i32>
  ret <2 x i32> %r
}

define <4 x i32> @XTN24s(<2 x i32> "reg"="v" "tied" %lo, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 10 10000 10010 10 m:5 d:5" "asm"="xtn2 {d:4s}, {m:2d}" {
  %t = trunc <2 x i64> %m to <2 x i32>
  %r = shufflevector <2 x i32> %lo, <2 x i32> %t, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %r
}

define <8 x i8> @LOW16x8(<16 x i8> "reg"="q" %n) "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i8> %r
}

define <8 x i8> @HIGH16x8(<16 x i8> "reg"="q" %n) "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <8 x i8> %r
}

define <16 x i8> @JOIN16x8(<8 x i8> "reg"="v" "tied" %lo, <8 x i8> "reg"="v" %n) "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <8 x i8> %lo, <8 x i8> %n, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %r
}

define <4 x i16> @LOW8x16(<8 x i16> "reg"="q" %n) "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i16> %r
}

define <4 x i16> @HIGH8x16(<8 x i16> "reg"="q" %n) "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  ret <4 x i16> %r
}

define <8 x i16> @JOIN8x16(<4 x i16> "reg"="v" "tied" %lo, <4 x i16> "reg"="v" %n) "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <4 x i16> %lo, <4 x i16> %n, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %r
}

define <2 x i32> @LOW4x32(<4 x i32> "reg"="q" %n) "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  ret <2 x i32> %r
}

define <2 x i32> @HIGH4x32(<4 x i32> "reg"="q" %n) "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  ret <2 x i32> %r
}

define <4 x i32> @JOIN4x32(<2 x i32> "reg"="v" "tied" %lo, <2 x i32> "reg"="v" %n) "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <2 x i32> %lo, <2 x i32> %n, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %r
}

define <1 x i64> @LOW2x64(<2 x i64> "reg"="q" %n) "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <1 x i32> <i32 0>
  ret <1 x i64> %r
}

define <1 x i64> @HIGH2x64(<2 x i64> "reg"="q" %n) "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <1 x i32> <i32 1>
  ret <1 x i64> %r
}

define <2 x i64> @JOIN2x64(<1 x i64> "reg"="v" "tied" %lo, <1 x i64> "reg"="v" %n) "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <1 x i64> %lo, <1 x i64> %n, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %r
}

define <16 x i8> @ADDV16b(<16 x i8> "reg"="q" %n) "enc"="0 1 0 01110 00 11000 11011 10 n:5 d:5" "asm"="addv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @SMAXV16b(<16 x i8> "reg"="q" %n) "enc"="0 1 0 01110 00 11000 01010 10 n:5 d:5" "asm"="smaxv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @SMINV16b(<16 x i8> "reg"="q" %n) "enc"="0 1 0 01110 00 11000 11010 10 n:5 d:5" "asm"="sminv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @UMAXV16b(<16 x i8> "reg"="q" %n) "enc"="0 1 1 01110 00 11000 01010 10 n:5 d:5" "asm"="umaxv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @UMINV16b(<16 x i8> "reg"="q" %n) "enc"="0 1 1 01110 00 11000 11010 10 n:5 d:5" "asm"="uminv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <8 x i16> @ADDV8h(<8 x i16> "reg"="q" %n) "enc"="0 1 0 01110 01 11000 11011 10 n:5 d:5" "asm"="addv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @SMAXV8h(<8 x i16> "reg"="q" %n) "enc"="0 1 0 01110 01 11000 01010 10 n:5 d:5" "asm"="smaxv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @SMINV8h(<8 x i16> "reg"="q" %n) "enc"="0 1 0 01110 01 11000 11010 10 n:5 d:5" "asm"="sminv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @UMAXV8h(<8 x i16> "reg"="q" %n) "enc"="0 1 1 01110 01 11000 01010 10 n:5 d:5" "asm"="umaxv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @UMINV8h(<8 x i16> "reg"="q" %n) "enc"="0 1 1 01110 01 11000 11010 10 n:5 d:5" "asm"="uminv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <4 x i32> @ADDV4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 10 11000 11011 10 n:5 d:5" "asm"="addv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @SMAXV4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 10 11000 01010 10 n:5 d:5" "asm"="smaxv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @SMINV4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 10 11000 11010 10 n:5 d:5" "asm"="sminv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @UMAXV4s(<4 x i32> "reg"="q" %n) "enc"="0 1 1 01110 10 11000 01010 10 n:5 d:5" "asm"="umaxv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @UMINV4s(<4 x i32> "reg"="q" %n) "enc"="0 1 1 01110 10 11000 11010 10 n:5 d:5" "asm"="uminv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <2 x i64> @ADDPd(<2 x i64> "reg"="q" %n) "enc"="01 0 11110 11 11000 11011 10 n:5 d:5" "asm"="addp {d:d}, {n:2d}" "nomatch" {
  ret <2 x i64> %n
}

declare i8 @llvm.vector.reduce.add.v16i8(<16 x i8>)

define i8 @reduce.add.v16i8(<16 x i8> "reg"="q" %v) "recipe"="reduce.add.v16i8.expand" {
  %r = call i8 @llvm.vector.reduce.add.v16i8(<16 x i8> %v)
  ret i8 %r
}

define i8 @reduce.add.v16i8.expand(<16 x i8> %v) {
  %t = call <16 x i8> @ADDV16b(<16 x i8> %v)
  %r = call i8 @UMOVb(<16 x i8> %t, i64 0)
  ret i8 %r
}

declare i16 @llvm.vector.reduce.add.v8i16(<8 x i16>)

define i16 @reduce.add.v8i16(<8 x i16> "reg"="q" %v) "recipe"="reduce.add.v8i16.expand" {
  %r = call i16 @llvm.vector.reduce.add.v8i16(<8 x i16> %v)
  ret i16 %r
}

define i16 @reduce.add.v8i16.expand(<8 x i16> %v) {
  %t = call <8 x i16> @ADDV8h(<8 x i16> %v)
  %r = call i16 @UMOVh(<8 x i16> %t, i64 0)
  ret i16 %r
}

declare i32 @llvm.vector.reduce.add.v4i32(<4 x i32>)

define i32 @reduce.add.v4i32(<4 x i32> "reg"="q" %v) "recipe"="reduce.add.v4i32.expand" {
  %r = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> %v)
  ret i32 %r
}

define i32 @reduce.add.v4i32.expand(<4 x i32> %v) {
  %t = call <4 x i32> @ADDV4s(<4 x i32> %v)
  %r = call i32 @UMOVs(<4 x i32> %t, i64 0)
  ret i32 %r
}

declare i8 @llvm.vector.reduce.smax.v16i8(<16 x i8>)

define i8 @reduce.smax.v16i8(<16 x i8> "reg"="q" %v) "recipe"="reduce.smax.v16i8.expand" {
  %r = call i8 @llvm.vector.reduce.smax.v16i8(<16 x i8> %v)
  ret i8 %r
}

define i8 @reduce.smax.v16i8.expand(<16 x i8> %v) {
  %t = call <16 x i8> @SMAXV16b(<16 x i8> %v)
  %r = call i8 @UMOVb(<16 x i8> %t, i64 0)
  ret i8 %r
}

declare i16 @llvm.vector.reduce.smax.v8i16(<8 x i16>)

define i16 @reduce.smax.v8i16(<8 x i16> "reg"="q" %v) "recipe"="reduce.smax.v8i16.expand" {
  %r = call i16 @llvm.vector.reduce.smax.v8i16(<8 x i16> %v)
  ret i16 %r
}

define i16 @reduce.smax.v8i16.expand(<8 x i16> %v) {
  %t = call <8 x i16> @SMAXV8h(<8 x i16> %v)
  %r = call i16 @UMOVh(<8 x i16> %t, i64 0)
  ret i16 %r
}

declare i32 @llvm.vector.reduce.smax.v4i32(<4 x i32>)

define i32 @reduce.smax.v4i32(<4 x i32> "reg"="q" %v) "recipe"="reduce.smax.v4i32.expand" {
  %r = call i32 @llvm.vector.reduce.smax.v4i32(<4 x i32> %v)
  ret i32 %r
}

define i32 @reduce.smax.v4i32.expand(<4 x i32> %v) {
  %t = call <4 x i32> @SMAXV4s(<4 x i32> %v)
  %r = call i32 @UMOVs(<4 x i32> %t, i64 0)
  ret i32 %r
}

declare i8 @llvm.vector.reduce.smin.v16i8(<16 x i8>)

define i8 @reduce.smin.v16i8(<16 x i8> "reg"="q" %v) "recipe"="reduce.smin.v16i8.expand" {
  %r = call i8 @llvm.vector.reduce.smin.v16i8(<16 x i8> %v)
  ret i8 %r
}

define i8 @reduce.smin.v16i8.expand(<16 x i8> %v) {
  %t = call <16 x i8> @SMINV16b(<16 x i8> %v)
  %r = call i8 @UMOVb(<16 x i8> %t, i64 0)
  ret i8 %r
}

declare i16 @llvm.vector.reduce.smin.v8i16(<8 x i16>)

define i16 @reduce.smin.v8i16(<8 x i16> "reg"="q" %v) "recipe"="reduce.smin.v8i16.expand" {
  %r = call i16 @llvm.vector.reduce.smin.v8i16(<8 x i16> %v)
  ret i16 %r
}

define i16 @reduce.smin.v8i16.expand(<8 x i16> %v) {
  %t = call <8 x i16> @SMINV8h(<8 x i16> %v)
  %r = call i16 @UMOVh(<8 x i16> %t, i64 0)
  ret i16 %r
}

declare i32 @llvm.vector.reduce.smin.v4i32(<4 x i32>)

define i32 @reduce.smin.v4i32(<4 x i32> "reg"="q" %v) "recipe"="reduce.smin.v4i32.expand" {
  %r = call i32 @llvm.vector.reduce.smin.v4i32(<4 x i32> %v)
  ret i32 %r
}

define i32 @reduce.smin.v4i32.expand(<4 x i32> %v) {
  %t = call <4 x i32> @SMINV4s(<4 x i32> %v)
  %r = call i32 @UMOVs(<4 x i32> %t, i64 0)
  ret i32 %r
}

declare i8 @llvm.vector.reduce.umax.v16i8(<16 x i8>)

define i8 @reduce.umax.v16i8(<16 x i8> "reg"="q" %v) "recipe"="reduce.umax.v16i8.expand" {
  %r = call i8 @llvm.vector.reduce.umax.v16i8(<16 x i8> %v)
  ret i8 %r
}

define i8 @reduce.umax.v16i8.expand(<16 x i8> %v) {
  %t = call <16 x i8> @UMAXV16b(<16 x i8> %v)
  %r = call i8 @UMOVb(<16 x i8> %t, i64 0)
  ret i8 %r
}

declare i16 @llvm.vector.reduce.umax.v8i16(<8 x i16>)

define i16 @reduce.umax.v8i16(<8 x i16> "reg"="q" %v) "recipe"="reduce.umax.v8i16.expand" {
  %r = call i16 @llvm.vector.reduce.umax.v8i16(<8 x i16> %v)
  ret i16 %r
}

define i16 @reduce.umax.v8i16.expand(<8 x i16> %v) {
  %t = call <8 x i16> @UMAXV8h(<8 x i16> %v)
  %r = call i16 @UMOVh(<8 x i16> %t, i64 0)
  ret i16 %r
}

declare i32 @llvm.vector.reduce.umax.v4i32(<4 x i32>)

define i32 @reduce.umax.v4i32(<4 x i32> "reg"="q" %v) "recipe"="reduce.umax.v4i32.expand" {
  %r = call i32 @llvm.vector.reduce.umax.v4i32(<4 x i32> %v)
  ret i32 %r
}

define i32 @reduce.umax.v4i32.expand(<4 x i32> %v) {
  %t = call <4 x i32> @UMAXV4s(<4 x i32> %v)
  %r = call i32 @UMOVs(<4 x i32> %t, i64 0)
  ret i32 %r
}

declare i8 @llvm.vector.reduce.umin.v16i8(<16 x i8>)

define i8 @reduce.umin.v16i8(<16 x i8> "reg"="q" %v) "recipe"="reduce.umin.v16i8.expand" {
  %r = call i8 @llvm.vector.reduce.umin.v16i8(<16 x i8> %v)
  ret i8 %r
}

define i8 @reduce.umin.v16i8.expand(<16 x i8> %v) {
  %t = call <16 x i8> @UMINV16b(<16 x i8> %v)
  %r = call i8 @UMOVb(<16 x i8> %t, i64 0)
  ret i8 %r
}

declare i16 @llvm.vector.reduce.umin.v8i16(<8 x i16>)

define i16 @reduce.umin.v8i16(<8 x i16> "reg"="q" %v) "recipe"="reduce.umin.v8i16.expand" {
  %r = call i16 @llvm.vector.reduce.umin.v8i16(<8 x i16> %v)
  ret i16 %r
}

define i16 @reduce.umin.v8i16.expand(<8 x i16> %v) {
  %t = call <8 x i16> @UMINV8h(<8 x i16> %v)
  %r = call i16 @UMOVh(<8 x i16> %t, i64 0)
  ret i16 %r
}

declare i32 @llvm.vector.reduce.umin.v4i32(<4 x i32>)

define i32 @reduce.umin.v4i32(<4 x i32> "reg"="q" %v) "recipe"="reduce.umin.v4i32.expand" {
  %r = call i32 @llvm.vector.reduce.umin.v4i32(<4 x i32> %v)
  ret i32 %r
}

define i32 @reduce.umin.v4i32.expand(<4 x i32> %v) {
  %t = call <4 x i32> @UMINV4s(<4 x i32> %v)
  %r = call i32 @UMOVs(<4 x i32> %t, i64 0)
  ret i32 %r
}

declare i64 @llvm.vector.reduce.add.v2i64(<2 x i64>)

define i64 @reduce.add.v2i64(<2 x i64> "reg"="q" %v) "recipe"="reduce.add.v2i64.expand" {
  %r = call i64 @llvm.vector.reduce.add.v2i64(<2 x i64> %v)
  ret i64 %r
}

define i64 @reduce.add.v2i64.expand(<2 x i64> %v) {
  %t = call <2 x i64> @ADDPd(<2 x i64> %v)
  %r = call i64 @UMOVd(<2 x i64> %t, i64 0)
  ret i64 %r
}

define <16 x i8> @LDRQui.16xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.q" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <16 x i8>, ptr %p
  ret <16 x i8> %v
}

define void @STRQui.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.q" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <16 x i8> %t, ptr %p
  ret void
}

define <16 x i8> @LDURQ.16xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <16 x i8>, ptr %p
  ret <16 x i8> %v
}

define void @STURQ.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <16 x i8> %t, ptr %p
  ret void
}

define <16 x i8> @LDRQroX.16xi8(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <16 x i8>, ptr %p
  ret <16 x i8> %v
}

define void @STRQroX.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <16 x i8> %t, ptr %p
  ret void
}

define { <16 x i8>, ptr } @LDRQpost.16xi8(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load <16 x i8>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <16 x i8>, ptr } poison, <16 x i8> %v, 0
  %b = insertvalue { <16 x i8>, ptr } %a, ptr %next, 1
  ret { <16 x i8>, ptr } %b
}

define ptr @STRQpost.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store <16 x i8> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <8 x i16> @LDRQui.8xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i16>, ptr %p
  ret <8 x i16> %v
}

define void @STRQui.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i16> %t, ptr %p
  ret void
}

define <8 x i16> @LDURQ.8xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i16>, ptr %p
  ret <8 x i16> %v
}

define void @STURQ.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i16> %t, ptr %p
  ret void
}

define <8 x i16> @LDRQroX.8xi16(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <8 x i16>, ptr %p
  ret <8 x i16> %v
}

define void @STRQroX.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <8 x i16> %t, ptr %p
  ret void
}

define { <8 x i16>, ptr } @LDRQpost.8xi16(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <8 x i16>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <8 x i16>, ptr } poison, <8 x i16> %v, 0
  %b = insertvalue { <8 x i16>, ptr } %a, ptr %next, 1
  ret { <8 x i16>, ptr } %b
}

define ptr @STRQpost.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <8 x i16> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <4 x i32> @LDRQui.4xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i32>, ptr %p
  ret <4 x i32> %v
}

define void @STRQui.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i32> %t, ptr %p
  ret void
}

define <4 x i32> @LDURQ.4xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i32>, ptr %p
  ret <4 x i32> %v
}

define void @STURQ.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i32> %t, ptr %p
  ret void
}

define <4 x i32> @LDRQroX.4xi32(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <4 x i32>, ptr %p
  ret <4 x i32> %v
}

define void @STRQroX.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <4 x i32> %t, ptr %p
  ret void
}

define { <4 x i32>, ptr } @LDRQpost.4xi32(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <4 x i32>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <4 x i32>, ptr } poison, <4 x i32> %v, 0
  %b = insertvalue { <4 x i32>, ptr } %a, ptr %next, 1
  ret { <4 x i32>, ptr } %b
}

define ptr @STRQpost.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <4 x i32> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x i64> @LDRQui.2xi64(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i64>, ptr %p
  ret <2 x i64> %v
}

define void @STRQui.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i64> %t, ptr %p
  ret void
}

define <2 x i64> @LDURQ.2xi64(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i64>, ptr %p
  ret <2 x i64> %v
}

define void @STURQ.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i64> %t, ptr %p
  ret void
}

define <2 x i64> @LDRQroX.2xi64(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x i64>, ptr %p
  ret <2 x i64> %v
}

define void @STRQroX.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x i64> %t, ptr %p
  ret void
}

define { <2 x i64>, ptr } @LDRQpost.2xi64(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x i64>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x i64>, ptr } poison, <2 x i64> %v, 0
  %b = insertvalue { <2 x i64>, ptr } %a, ptr %next, 1
  ret { <2 x i64>, ptr } %b
}

define ptr @STRQpost.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x i64> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <4 x float> @LDRQui.4xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x float>, ptr %p
  ret <4 x float> %v
}

define void @STRQui.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x float> %t, ptr %p
  ret void
}

define <4 x float> @LDURQ.4xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x float>, ptr %p
  ret <4 x float> %v
}

define void @STURQ.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x float> %t, ptr %p
  ret void
}

define <4 x float> @LDRQroX.4xfloat(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <4 x float>, ptr %p
  ret <4 x float> %v
}

define void @STRQroX.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <4 x float> %t, ptr %p
  ret void
}

define { <4 x float>, ptr } @LDRQpost.4xfloat(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <4 x float>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <4 x float>, ptr } poison, <4 x float> %v, 0
  %b = insertvalue { <4 x float>, ptr } %a, ptr %next, 1
  ret { <4 x float>, ptr } %b
}

define ptr @STRQpost.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <4 x float> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x double> @LDRQui.2xdouble(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x double>, ptr %p
  ret <2 x double> %v
}

define void @STRQui.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x double> %t, ptr %p
  ret void
}

define <2 x double> @LDURQ.2xdouble(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x double>, ptr %p
  ret <2 x double> %v
}

define void @STURQ.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x double> %t, ptr %p
  ret void
}

define <2 x double> @LDRQroX.2xdouble(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x double>, ptr %p
  ret <2 x double> %v
}

define void @STRQroX.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x double> %t, ptr %p
  ret void
}

define { <2 x double>, ptr } @LDRQpost.2xdouble(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x double>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x double>, ptr } poison, <2 x double> %v, 0
  %b = insertvalue { <2 x double>, ptr } %a, ptr %next, 1
  ret { <2 x double>, ptr } %b
}

define ptr @STRQpost.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x double> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <8 x i8> @LDRDui.8xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i8>, ptr %p
  ret <8 x i8> %v
}

define void @STRDui.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i8> %t, ptr %p
  ret void
}

define <8 x i8> @LDURD.8xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i8>, ptr %p
  ret <8 x i8> %v
}

define void @STURD.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i8> %t, ptr %p
  ret void
}

define <8 x i8> @LDRDroX.8xi8(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <8 x i8>, ptr %p
  ret <8 x i8> %v
}

define void @STRDroX.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <8 x i8> %t, ptr %p
  ret void
}

define { <8 x i8>, ptr } @LDRDpost.8xi8(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load <8 x i8>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <8 x i8>, ptr } poison, <8 x i8> %v, 0
  %b = insertvalue { <8 x i8>, ptr } %a, ptr %next, 1
  ret { <8 x i8>, ptr } %b
}

define ptr @STRDpost.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store <8 x i8> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <4 x i16> @LDRDui.4xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i16>, ptr %p
  ret <4 x i16> %v
}

define void @STRDui.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i16> %t, ptr %p
  ret void
}

define <4 x i16> @LDURD.4xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i16>, ptr %p
  ret <4 x i16> %v
}

define void @STURD.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i16> %t, ptr %p
  ret void
}

define <4 x i16> @LDRDroX.4xi16(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <4 x i16>, ptr %p
  ret <4 x i16> %v
}

define void @STRDroX.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <4 x i16> %t, ptr %p
  ret void
}

define { <4 x i16>, ptr } @LDRDpost.4xi16(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <4 x i16>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <4 x i16>, ptr } poison, <4 x i16> %v, 0
  %b = insertvalue { <4 x i16>, ptr } %a, ptr %next, 1
  ret { <4 x i16>, ptr } %b
}

define ptr @STRDpost.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <4 x i16> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x i32> @LDRDui.2xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i32>, ptr %p
  ret <2 x i32> %v
}

define void @STRDui.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i32> %t, ptr %p
  ret void
}

define <2 x i32> @LDURD.2xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i32>, ptr %p
  ret <2 x i32> %v
}

define void @STURD.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i32> %t, ptr %p
  ret void
}

define <2 x i32> @LDRDroX.2xi32(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x i32>, ptr %p
  ret <2 x i32> %v
}

define void @STRDroX.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x i32> %t, ptr %p
  ret void
}

define { <2 x i32>, ptr } @LDRDpost.2xi32(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x i32>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x i32>, ptr } poison, <2 x i32> %v, 0
  %b = insertvalue { <2 x i32>, ptr } %a, ptr %next, 1
  ret { <2 x i32>, ptr } %b
}

define ptr @STRDpost.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x i32> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x float> @LDRDui.2xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x float>, ptr %p
  ret <2 x float> %v
}

define void @STRDui.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x float> %t, ptr %p
  ret void
}

define <2 x float> @LDURD.2xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x float>, ptr %p
  ret <2 x float> %v
}

define void @STURD.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x float> %t, ptr %p
  ret void
}

define <2 x float> @LDRDroX.2xfloat(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x float>, ptr %p
  ret <2 x float> %v
}

define void @STRDroX.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x float> %t, ptr %p
  ret void
}

define { <2 x float>, ptr } @LDRDpost.2xfloat(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x float>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x float>, ptr } poison, <2 x float> %v, 0
  %b = insertvalue { <2 x float>, ptr } %a, ptr %next, 1
  ret { <2 x float>, ptr } %b
}

define ptr @STRDpost.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x float> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x i64> @MOVIzero() "enc"="0 1 1 0111100000 000 1110 01 00000 d:5" "asm"="movi {d:2d}, #0" "role"="movi.zero" "nomatch" {
  ret <2 x i64> zeroinitializer
}

define <2 x i64> @MOVq(<2 x i64> "reg"="q" %n) "enc"="0 1 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:16b}, {n:16b}" "role"="copy.q" "nomatch" {
  ret <2 x i64> %n
}
define i8 @UMOVb64(<8 x i8> "reg"="v" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*2+1 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.b}[{idx}]" "nodecode" {
  %r = extractelement <8 x i8> %n, i64 %idx
  ret i8 %r
}

define <8 x i8> @INSb64(<8 x i8> "reg"="v" "tied" %old, i8 "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*2+1 0 0011 1 n:5 d:5" "asm"="mov {d:.b}[{idx}], {n}" "nodecode" {
  %r = insertelement <8 x i8> %old, i8 %n, i64 %idx
  ret <8 x i8> %r
}

define i16 @UMOVh64(<4 x i16> "reg"="v" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*4+2 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.h}[{idx}]" "nodecode" {
  %r = extractelement <4 x i16> %n, i64 %idx
  ret i16 %r
}

define <4 x i16> @INSh64(<4 x i16> "reg"="v" "tied" %old, i16 "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*4+2 0 0011 1 n:5 d:5" "asm"="mov {d:.h}[{idx}], {n}" "nodecode" {
  %r = insertelement <4 x i16> %old, i16 %n, i64 %idx
  ret <4 x i16> %r
}

define i32 @UMOVs64(<2 x i32> "reg"="v" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*8+4 0 0111 1 n:5 d:5" "asm"="mov {d}, {n:.s}[{idx}]" "nodecode" {
  %r = extractelement <2 x i32> %n, i64 %idx
  ret i32 %r
}

define <2 x i32> @INSs64(<2 x i32> "reg"="v" "tied" %old, i32 "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*8+4 0 0011 1 n:5 d:5" "asm"="mov {d:.s}[{idx}], {n}" "nodecode" {
  %r = insertelement <2 x i32> %old, i32 %n, i64 %idx
  ret <2 x i32> %r
}

define <8 x i16> @SXTLlo8h(<16 x i8> "reg"="q" %n) "enc"="0 0 0 011110 0001000 10100 1 n:5 d:5" "asm"="sxtl {d:8h}, {n:8b}" "nodecode" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %r = sext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @UXTLlo8h(<16 x i8> "reg"="q" %n) "enc"="0 0 1 011110 0001000 10100 1 n:5 d:5" "asm"="uxtl {d:8h}, {n:8b}" "nodecode" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %r = zext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @SMULLv8h(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:8h}, {n:8b}, {m:8b}" {
  %a = sext <8 x i8> %n to <8 x i16>
  %b = sext <8 x i8> %m to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @SMULLlo8h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 0 0 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:8h}, {n:8b}, {m:8b}" "nodecode" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %a = sext <8 x i8> %hn to <8 x i16>
  %b = sext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @SMULL28h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="smull2 {d:8h}, {n:16b}, {m:16b}" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %a = sext <8 x i8> %hn to <8 x i16>
  %b = sext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @UMULLv8h(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:8h}, {n:8b}, {m:8b}" {
  %a = zext <8 x i8> %n to <8 x i16>
  %b = zext <8 x i8> %m to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @UMULLlo8h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 0 1 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:8h}, {n:8b}, {m:8b}" "nodecode" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %a = zext <8 x i8> %hn to <8 x i16>
  %b = zext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @UMULL28h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="umull2 {d:8h}, {n:16b}, {m:16b}" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %a = zext <8 x i8> %hn to <8 x i16>
  %b = zext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <4 x i32> @SXTLlo4s(<8 x i16> "reg"="q" %n) "enc"="0 0 0 011110 0010000 10100 1 n:5 d:5" "asm"="sxtl {d:4s}, {n:4h}" "nodecode" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %r = sext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @UXTLlo4s(<8 x i16> "reg"="q" %n) "enc"="0 0 1 011110 0010000 10100 1 n:5 d:5" "asm"="uxtl {d:4s}, {n:4h}" "nodecode" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %r = zext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @SMULLv4s(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:4s}, {n:4h}, {m:4h}" {
  %a = sext <4 x i16> %n to <4 x i32>
  %b = sext <4 x i16> %m to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @SMULLlo4s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 0 0 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:4s}, {n:4h}, {m:4h}" "nodecode" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %a = sext <4 x i16> %hn to <4 x i32>
  %b = sext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @SMULL24s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="smull2 {d:4s}, {n:8h}, {m:8h}" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %a = sext <4 x i16> %hn to <4 x i32>
  %b = sext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @UMULLv4s(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:4s}, {n:4h}, {m:4h}" {
  %a = zext <4 x i16> %n to <4 x i32>
  %b = zext <4 x i16> %m to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @UMULLlo4s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 0 1 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:4s}, {n:4h}, {m:4h}" "nodecode" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %a = zext <4 x i16> %hn to <4 x i32>
  %b = zext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @UMULL24s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="umull2 {d:4s}, {n:8h}, {m:8h}" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %a = zext <4 x i16> %hn to <4 x i32>
  %b = zext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <2 x i64> @SXTLlo2d(<4 x i32> "reg"="q" %n) "enc"="0 0 0 011110 0100000 10100 1 n:5 d:5" "asm"="sxtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %r = sext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @UXTLlo2d(<4 x i32> "reg"="q" %n) "enc"="0 0 1 011110 0100000 10100 1 n:5 d:5" "asm"="uxtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %r = zext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @SMULLv2d(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:2d}, {n:2s}, {m:2s}" {
  %a = sext <2 x i32> %n to <2 x i64>
  %b = sext <2 x i32> %m to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @SMULLlo2d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 0 0 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:2d}, {n:2s}, {m:2s}" "nodecode" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %a = sext <2 x i32> %hn to <2 x i64>
  %b = sext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @SMULL22d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="smull2 {d:2d}, {n:4s}, {m:4s}" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %a = sext <2 x i32> %hn to <2 x i64>
  %b = sext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @UMULLv2d(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:2d}, {n:2s}, {m:2s}" {
  %a = zext <2 x i32> %n to <2 x i64>
  %b = zext <2 x i32> %m to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @UMULLlo2d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 0 1 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:2d}, {n:2s}, {m:2s}" "nodecode" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %a = zext <2 x i32> %hn to <2 x i64>
  %b = zext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @UMULL22d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="umull2 {d:2d}, {n:4s}, {m:4s}" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %a = zext <2 x i32> %hn to <2 x i64>
  %b = zext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}
define <2 x i32> @ADDPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:2s}, {n:2s}, {m:2s}" "nomatch" {
  ret <2 x i32> %n
}

declare i32 @llvm.vector.reduce.add.v2i32(<2 x i32>)

define i32 @reduce.add.v2i32(<2 x i32> "reg"="v" %v) "recipe"="reduce.add.v2i32.expand" {
  %r = call i32 @llvm.vector.reduce.add.v2i32(<2 x i32> %v)
  ret i32 %r
}

define i32 @reduce.add.v2i32.expand(<2 x i32> %v) {
  %t = call <2 x i32> @ADDPv2s(<2 x i32> %v, <2 x i32> %v)
  %r = call i32 @UMOVs64(<2 x i32> %t, i64 0)
  ret i32 %r
}

define <8 x i8> @ADDV8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 11000 11011 10 n:5 d:5" "asm"="addv {d:b}, {n:8b}" "nomatch" {
  ret <8 x i8> %n
}

declare i8 @llvm.vector.reduce.add.v8i8(<8 x i8>)

define i8 @reduce.add.v8i8(<8 x i8> "reg"="v" %v) "recipe"="reduce.add.v8i8.expand" {
  %r = call i8 @llvm.vector.reduce.add.v8i8(<8 x i8> %v)
  ret i8 %r
}

define i8 @reduce.add.v8i8.expand(<8 x i8> %v) {
  %t = call <8 x i8> @ADDV8b(<8 x i8> %v)
  %r = call i8 @UMOVb64(<8 x i8> %t, i64 0)
  ret i8 %r
}

define <8 x i8> @SMAXV8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 11000 01010 10 n:5 d:5" "asm"="smaxv {d:b}, {n:8b}" "nomatch" {
  ret <8 x i8> %n
}

declare i8 @llvm.vector.reduce.smax.v8i8(<8 x i8>)

define i8 @reduce.smax.v8i8(<8 x i8> "reg"="v" %v) "recipe"="reduce.smax.v8i8.expand" {
  %r = call i8 @llvm.vector.reduce.smax.v8i8(<8 x i8> %v)
  ret i8 %r
}

define i8 @reduce.smax.v8i8.expand(<8 x i8> %v) {
  %t = call <8 x i8> @SMAXV8b(<8 x i8> %v)
  %r = call i8 @UMOVb64(<8 x i8> %t, i64 0)
  ret i8 %r
}

define <8 x i8> @SMINV8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 11000 11010 10 n:5 d:5" "asm"="sminv {d:b}, {n:8b}" "nomatch" {
  ret <8 x i8> %n
}

declare i8 @llvm.vector.reduce.smin.v8i8(<8 x i8>)

define i8 @reduce.smin.v8i8(<8 x i8> "reg"="v" %v) "recipe"="reduce.smin.v8i8.expand" {
  %r = call i8 @llvm.vector.reduce.smin.v8i8(<8 x i8> %v)
  ret i8 %r
}

define i8 @reduce.smin.v8i8.expand(<8 x i8> %v) {
  %t = call <8 x i8> @SMINV8b(<8 x i8> %v)
  %r = call i8 @UMOVb64(<8 x i8> %t, i64 0)
  ret i8 %r
}

define <8 x i8> @UMAXV8b(<8 x i8> "reg"="v" %n) "enc"="0 0 1 01110 00 11000 01010 10 n:5 d:5" "asm"="umaxv {d:b}, {n:8b}" "nomatch" {
  ret <8 x i8> %n
}

declare i8 @llvm.vector.reduce.umax.v8i8(<8 x i8>)

define i8 @reduce.umax.v8i8(<8 x i8> "reg"="v" %v) "recipe"="reduce.umax.v8i8.expand" {
  %r = call i8 @llvm.vector.reduce.umax.v8i8(<8 x i8> %v)
  ret i8 %r
}

define i8 @reduce.umax.v8i8.expand(<8 x i8> %v) {
  %t = call <8 x i8> @UMAXV8b(<8 x i8> %v)
  %r = call i8 @UMOVb64(<8 x i8> %t, i64 0)
  ret i8 %r
}

define <8 x i8> @UMINV8b(<8 x i8> "reg"="v" %n) "enc"="0 0 1 01110 00 11000 11010 10 n:5 d:5" "asm"="uminv {d:b}, {n:8b}" "nomatch" {
  ret <8 x i8> %n
}

declare i8 @llvm.vector.reduce.umin.v8i8(<8 x i8>)

define i8 @reduce.umin.v8i8(<8 x i8> "reg"="v" %v) "recipe"="reduce.umin.v8i8.expand" {
  %r = call i8 @llvm.vector.reduce.umin.v8i8(<8 x i8> %v)
  ret i8 %r
}

define i8 @reduce.umin.v8i8.expand(<8 x i8> %v) {
  %t = call <8 x i8> @UMINV8b(<8 x i8> %v)
  %r = call i8 @UMOVb64(<8 x i8> %t, i64 0)
  ret i8 %r
}

define <4 x i16> @ADDV4h(<4 x i16> "reg"="v" %n) "enc"="0 0 0 01110 01 11000 11011 10 n:5 d:5" "asm"="addv {d:h}, {n:4h}" "nomatch" {
  ret <4 x i16> %n
}

declare i16 @llvm.vector.reduce.add.v4i16(<4 x i16>)

define i16 @reduce.add.v4i16(<4 x i16> "reg"="v" %v) "recipe"="reduce.add.v4i16.expand" {
  %r = call i16 @llvm.vector.reduce.add.v4i16(<4 x i16> %v)
  ret i16 %r
}

define i16 @reduce.add.v4i16.expand(<4 x i16> %v) {
  %t = call <4 x i16> @ADDV4h(<4 x i16> %v)
  %r = call i16 @UMOVh64(<4 x i16> %t, i64 0)
  ret i16 %r
}

define <4 x i16> @SMAXV4h(<4 x i16> "reg"="v" %n) "enc"="0 0 0 01110 01 11000 01010 10 n:5 d:5" "asm"="smaxv {d:h}, {n:4h}" "nomatch" {
  ret <4 x i16> %n
}

declare i16 @llvm.vector.reduce.smax.v4i16(<4 x i16>)

define i16 @reduce.smax.v4i16(<4 x i16> "reg"="v" %v) "recipe"="reduce.smax.v4i16.expand" {
  %r = call i16 @llvm.vector.reduce.smax.v4i16(<4 x i16> %v)
  ret i16 %r
}

define i16 @reduce.smax.v4i16.expand(<4 x i16> %v) {
  %t = call <4 x i16> @SMAXV4h(<4 x i16> %v)
  %r = call i16 @UMOVh64(<4 x i16> %t, i64 0)
  ret i16 %r
}

define <4 x i16> @SMINV4h(<4 x i16> "reg"="v" %n) "enc"="0 0 0 01110 01 11000 11010 10 n:5 d:5" "asm"="sminv {d:h}, {n:4h}" "nomatch" {
  ret <4 x i16> %n
}

declare i16 @llvm.vector.reduce.smin.v4i16(<4 x i16>)

define i16 @reduce.smin.v4i16(<4 x i16> "reg"="v" %v) "recipe"="reduce.smin.v4i16.expand" {
  %r = call i16 @llvm.vector.reduce.smin.v4i16(<4 x i16> %v)
  ret i16 %r
}

define i16 @reduce.smin.v4i16.expand(<4 x i16> %v) {
  %t = call <4 x i16> @SMINV4h(<4 x i16> %v)
  %r = call i16 @UMOVh64(<4 x i16> %t, i64 0)
  ret i16 %r
}

define <4 x i16> @UMAXV4h(<4 x i16> "reg"="v" %n) "enc"="0 0 1 01110 01 11000 01010 10 n:5 d:5" "asm"="umaxv {d:h}, {n:4h}" "nomatch" {
  ret <4 x i16> %n
}

declare i16 @llvm.vector.reduce.umax.v4i16(<4 x i16>)

define i16 @reduce.umax.v4i16(<4 x i16> "reg"="v" %v) "recipe"="reduce.umax.v4i16.expand" {
  %r = call i16 @llvm.vector.reduce.umax.v4i16(<4 x i16> %v)
  ret i16 %r
}

define i16 @reduce.umax.v4i16.expand(<4 x i16> %v) {
  %t = call <4 x i16> @UMAXV4h(<4 x i16> %v)
  %r = call i16 @UMOVh64(<4 x i16> %t, i64 0)
  ret i16 %r
}

define <4 x i16> @UMINV4h(<4 x i16> "reg"="v" %n) "enc"="0 0 1 01110 01 11000 11010 10 n:5 d:5" "asm"="uminv {d:h}, {n:4h}" "nomatch" {
  ret <4 x i16> %n
}

declare i16 @llvm.vector.reduce.umin.v4i16(<4 x i16>)

define i16 @reduce.umin.v4i16(<4 x i16> "reg"="v" %v) "recipe"="reduce.umin.v4i16.expand" {
  %r = call i16 @llvm.vector.reduce.umin.v4i16(<4 x i16> %v)
  ret i16 %r
}

define i16 @reduce.umin.v4i16.expand(<4 x i16> %v) {
  %t = call <4 x i16> @UMINV4h(<4 x i16> %v)
  %r = call i16 @UMOVh64(<4 x i16> %t, i64 0)
  ret i16 %r
}

define <2 x double> @FCVTL2d(<2 x float> "reg"="v" %n) "enc"="0 0 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl {d:2d}, {n:2s}" {
  %r = fpext <2 x float> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @FCVTLlo2d(<4 x float> "reg"="q" %n) "enc"="0 0 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x float> %n, <4 x float> poison, <2 x i32> <i32 0, i32 1>
  %r = fpext <2 x float> %h to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @FCVTL22d(<4 x float> "reg"="q" %n) "enc"="0 1 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x float> %n, <4 x float> poison, <2 x i32> <i32 2, i32 3>
  %r = fpext <2 x float> %h to <2 x double>
  ret <2 x double> %r
}

define <2 x float> @FCVTN2s(<2 x double> "reg"="q" %n) "enc"="0 0 0 01110 0 1 10000 10110 10 n:5 d:5" "asm"="fcvtn {d:2s}, {n:2d}" {
  %r = fptrunc <2 x double> %n to <2 x float>
  ret <2 x float> %r
}

define <4 x float> @FCVTN24s(<2 x float> "reg"="v" "tied" %lo, <2 x double> "reg"="q" %m) "enc"="0 1 0 01110 0 1 10000 10110 10 m:5 d:5" "asm"="fcvtn2 {d:4s}, {m:2d}" {
  %t = fptrunc <2 x double> %m to <2 x float>
  %r = shufflevector <2 x float> %lo, <2 x float> %t, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x float> %r
}
define <16 x i8> @REV64v16b(<16 x i8> "reg"="q" %n) "enc"="0 1 0 01110 00 10000 00000 10 n:5 d:5" "asm"="rev64 {d:16b}, {n:16b}" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <16 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0, i32 15, i32 14, i32 13, i32 12, i32 11, i32 10, i32 9, i32 8>
  ret <16 x i8> %r
}

define <8 x i16> @REV64v8h(<8 x i16> "reg"="q" %n) "enc"="0 1 0 01110 01 10000 00000 10 n:5 d:5" "asm"="rev64 {d:8h}, {n:8h}" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <8 x i32> <i32 3, i32 2, i32 1, i32 0, i32 7, i32 6, i32 5, i32 4>
  ret <8 x i16> %r
}

define <4 x i32> @REV64v4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:4s}, {n:4s}" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  ret <4 x i32> %r
}

define <2 x i64> @SWAPv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 10 1110 00 0 rm:5=n 0 1000 0 n:5 d:5" "asm"="ext {d:16b}, {n:16b}, {n:16b}, #8" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x i64> %r
}

define <8 x i8> @REV64v8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 10000 00000 10 n:5 d:5" "asm"="rev64 {d:8b}, {n:8b}" {
  %r = shufflevector <8 x i8> %n, <8 x i8> poison, <8 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0>
  ret <8 x i8> %r
}

define <4 x i16> @REV64v4h(<4 x i16> "reg"="v" %n) "enc"="0 0 0 01110 01 10000 00000 10 n:5 d:5" "asm"="rev64 {d:4h}, {n:4h}" {
  %r = shufflevector <4 x i16> %n, <4 x i16> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  ret <4 x i16> %r
}

define <2 x i32> @REV64v2s(<2 x i32> "reg"="v" %n) "enc"="0 0 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:2s}, {n:2s}" {
  %r = shufflevector <2 x i32> %n, <2 x i32> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x i32> %r
}

define <4 x float> @REV64v4sf(<4 x float> "reg"="q" %n) "enc"="0 1 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:4s}, {n:4s}" "nodecode" {
  %r = shufflevector <4 x float> %n, <4 x float> poison, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  ret <4 x float> %r
}

define <2 x double> @SWAPv2df(<2 x double> "reg"="q" %n) "enc"="0 1 10 1110 00 0 rm:5=n 0 1000 0 n:5 d:5" "asm"="ext {d:16b}, {n:16b}, {n:16b}, #8" "nodecode" {
  %r = shufflevector <2 x double> %n, <2 x double> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x double> %r
}

define <2 x float> @REV64v2sf(<2 x float> "reg"="v" %n) "enc"="0 0 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:2s}, {n:2s}" "nodecode" {
  %r = shufflevector <2 x float> %n, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x float> %r
}
define <16 x i1> @CMTSTv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %a = and <16 x i8> %n, %m
  %r = icmp ne <16 x i8> %a, zeroinitializer
  ret <16 x i1> %r
}

define <16 x i1> @CMNEZv16b(<16 x i8> "reg"="q" %n) "enc"="0 1 0 01110 00 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:16b}, {n:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp ne <16 x i8> %n, zeroinitializer
  ret <16 x i1> %r
}

declare <16 x i8> @llvm.aarch64.neon.ushl.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @USHLv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.ushl.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.neon.sshl.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SSHLv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.sshl.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

define <8 x i1> @CMTSTv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %a = and <8 x i16> %n, %m
  %r = icmp ne <8 x i16> %a, zeroinitializer
  ret <8 x i1> %r
}

define <8 x i1> @CMNEZv8h(<8 x i16> "reg"="q" %n) "enc"="0 1 0 01110 01 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:8h}, {n:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp ne <8 x i16> %n, zeroinitializer
  ret <8 x i1> %r
}

declare <8 x i16> @llvm.aarch64.neon.ushl.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @USHLv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 1 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.ushl.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.sshl.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SSHLv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "enc"="0 1 0 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.sshl.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

define <4 x i1> @CMTSTv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %a = and <4 x i32> %n, %m
  %r = icmp ne <4 x i32> %a, zeroinitializer
  ret <4 x i1> %r
}

define <4 x i1> @CMNEZv4s(<4 x i32> "reg"="q" %n) "enc"="0 1 0 01110 10 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:4s}, {n:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp ne <4 x i32> %n, zeroinitializer
  ret <4 x i1> %r
}

declare <4 x i32> @llvm.aarch64.neon.ushl.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @USHLv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 1 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.ushl.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.sshl.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SSHLv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.sshl.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <2 x i1> @CMTSTv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %a = and <2 x i64> %n, %m
  %r = icmp ne <2 x i64> %a, zeroinitializer
  ret <2 x i1> %r
}

define <2 x i1> @CMNEZv2d(<2 x i64> "reg"="q" %n) "enc"="0 1 0 01110 11 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:2d}, {n:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp ne <2 x i64> %n, zeroinitializer
  ret <2 x i1> %r
}

declare <2 x i64> @llvm.aarch64.neon.ushl.v2i64(<2 x i64>, <2 x i64>)

define <2 x i64> @USHLv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 1 01110 11 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.neon.ushl.v2i64(<2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.aarch64.neon.sshl.v2i64(<2 x i64>, <2 x i64>)

define <2 x i64> @SSHLv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "enc"="0 1 0 01110 11 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.neon.sshl.v2i64(<2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

define <8 x i1> @CMTSTv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %a = and <8 x i8> %n, %m
  %r = icmp ne <8 x i8> %a, zeroinitializer
  ret <8 x i1> %r
}

define <8 x i1> @CMNEZv8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:8b}, {n:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp ne <8 x i8> %n, zeroinitializer
  ret <8 x i1> %r
}

declare <8 x i8> @llvm.aarch64.neon.ushl.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @USHLv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 1 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.ushl.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.sshl.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SSHLv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "enc"="0 0 0 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.sshl.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

define <4 x i1> @CMTSTv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %a = and <4 x i16> %n, %m
  %r = icmp ne <4 x i16> %a, zeroinitializer
  ret <4 x i1> %r
}

define <4 x i1> @CMNEZv4h(<4 x i16> "reg"="v" %n) "enc"="0 0 0 01110 01 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:4h}, {n:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp ne <4 x i16> %n, zeroinitializer
  ret <4 x i1> %r
}

declare <4 x i16> @llvm.aarch64.neon.ushl.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @USHLv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 1 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.ushl.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.sshl.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SSHLv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "enc"="0 0 0 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.sshl.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

define <2 x i1> @CMTSTv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %a = and <2 x i32> %n, %m
  %r = icmp ne <2 x i32> %a, zeroinitializer
  ret <2 x i1> %r
}

define <2 x i1> @CMNEZv2s(<2 x i32> "reg"="v" %n) "enc"="0 0 0 01110 10 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:2s}, {n:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp ne <2 x i32> %n, zeroinitializer
  ret <2 x i1> %r
}

declare <2 x i32> @llvm.aarch64.neon.ushl.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @USHLv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 1 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.ushl.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.sshl.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SSHLv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.sshl.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

define <16 x i1> @ANDm16(<16 x i1> "reg"="q" %n, <16 x i1> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <16 x i1> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @ORRm16(<16 x i1> "reg"="q" %n, <16 x i1> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <16 x i1> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @EORm16(<16 x i1> "reg"="q" %n, <16 x i1> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <16 x i1> %n, %m
  ret <16 x i1> %r
}

define <8 x i1> @ANDm8(<8 x i1> "reg"="q" %n, <8 x i1> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <8 x i1> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @ORRm8(<8 x i1> "reg"="q" %n, <8 x i1> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <8 x i1> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @EORm8(<8 x i1> "reg"="q" %n, <8 x i1> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <8 x i1> %n, %m
  ret <8 x i1> %r
}

define <4 x i1> @ANDm4(<4 x i1> "reg"="q" %n, <4 x i1> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <4 x i1> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @ORRm4(<4 x i1> "reg"="q" %n, <4 x i1> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <4 x i1> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @EORm4(<4 x i1> "reg"="q" %n, <4 x i1> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <4 x i1> %n, %m
  ret <4 x i1> %r
}

define <2 x i1> @ANDm2(<2 x i1> "reg"="q" %n, <2 x i1> "reg"="q" %m) "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <2 x i1> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @ORRm2(<2 x i1> "reg"="q" %n, <2 x i1> "reg"="q" %m) "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <2 x i1> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @EORm2(<2 x i1> "reg"="q" %n, <2 x i1> "reg"="q" %m) "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <2 x i1> %n, %m
  ret <2 x i1> %r
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

; ===========================================================================
; Calling conventions and platforms
;
; Each is a list of properties, each a tuple of strings: the property's
; name, then its values. Registers are named as in assembly; "x0-x7" is a
; range.
;
;   args          registers for integer and pointer arguments, in order
;   result        the register an integer or pointer result comes back in
;   clobbers      registers a call may change
;   saved         registers a function must preserve, saving them if used
;   reserved      registers never allocated (the platform's)
;   scratch       registers kept free for spill code
;   frame         the frame pointer and the link register
;   stack-args    how arguments past the registers are laid out on the
;                 stack: "natural" (each at its own size and alignment,
;                 packed) or "slots" (each in an 8-byte slot)
;   variadic      where the variable arguments of a variadic call go:
;                 "stack" (always, in 8-byte slots) or "named" (as named
;                 arguments are)
;   syntax        the assembler's dialect: "macho" or "elf"
;   triples       substrings of a module's target triple that select it
;   fp-args, fp-result, fp-clobbers, fp-saved, fp-scratch
;                 the same, for floating-point values in d0-d31 (only
;                 the low 64 bits of d8-d15 are preserved)

; Apple's arm64 ABI: AAPCS64 with x18 reserved, stack arguments packed,
; variadic arguments on the stack.
!aarch64.abi.darwin = !{!100, !101, !102, !103, !104, !105, !106, !107, !108, !109, !110, !111, !112, !113, !114, !115}
!100 = !{!"args", !"x0-x7"}
!101 = !{!"result", !"x0"}
!102 = !{!"clobbers", !"x0-x18", !"x30"}
!103 = !{!"saved", !"x19-x28"}
!104 = !{!"reserved", !"x18"}
!105 = !{!"scratch", !"x15-x17"}
!106 = !{!"frame", !"x29", !"x30"}
!107 = !{!"stack-args", !"natural"}
!108 = !{!"variadic", !"stack"}
!109 = !{!"syntax", !"macho"}
!110 = !{!"triples", !"apple", !"darwin", !"macos", !"ios"}
!111 = !{!"fp-args", !"d0-d7"}
!112 = !{!"fp-result", !"d0"}
!113 = !{!"fp-clobbers", !"d0-d7", !"d16-d31"}
!114 = !{!"fp-saved", !"d8-d15"}
!115 = !{!"fp-scratch", !"d29-d31"}

; The Procedure Call Standard for the Arm 64-bit Architecture, as used by
; Linux: x18 is an ordinary temporary, stack arguments take 8-byte slots,
; and variadic arguments go where named ones would.
!aarch64.abi.aapcs64 = !{!200, !201, !202, !203, !204, !205, !206, !207, !208, !209, !210, !211, !212, !213, !214, !215}
!200 = !{!"args", !"x0-x7"}
!201 = !{!"result", !"x0"}
!202 = !{!"clobbers", !"x0-x18", !"x30"}
!203 = !{!"saved", !"x19-x28"}
!204 = !{!"reserved"}
!205 = !{!"scratch", !"x15-x17"}
!206 = !{!"frame", !"x29", !"x30"}
!207 = !{!"stack-args", !"slots"}
!208 = !{!"variadic", !"named"}
!209 = !{!"syntax", !"elf"}
!210 = !{!"triples", !"linux", !"elf", !"none"}
!211 = !{!"fp-args", !"d0-d7"}
!212 = !{!"fp-result", !"d0"}
!213 = !{!"fp-clobbers", !"d0-d7", !"d16-d31"}
!214 = !{!"fp-saved", !"d8-d15"}
!215 = !{!"fp-scratch", !"d29-d31"}
