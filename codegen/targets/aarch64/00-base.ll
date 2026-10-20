; The AArch64 machine description, as data. See docs/design/isel.md and
; docs/design/targets.md.
;
; It is in the .ll files of this directory, read in the order of their
; names as one module (codegen/src/target.rs lists them, as it is built in):
;
;   00-base.ll      these conventions, the flags, condition forms,
;                   comparisons, branches and selects
;   01-target.ll    the machine as a whole: registers, parameters, CPUs and
;                   their features, relocations
;   10-integer.ll   arithmetic, logic, shifts, extensions, moves and
;                   constants, address arithmetic
;   20-memory.ll    loads and stores, atomics
;   25-pairs.ll     load and store pairs, written by gen_from_mrs.py from
;                   Arm's machine-readable specification
;   30-bits.ll      bit manipulation
;   40-float.ll     floating point
;   50-vectors.ll   vectors (Advanced SIMD), written by gen_vectors.py
;   60-recipes.ll   recipes: IR with no single instruction
;   70-abi.ll       calling conventions and platforms
;   80-asm.ll       for assembly and disassembly only: the rest of the A64
;                   base, floating-point and Advanced SIMD instructions,
;                   written by gen_mrs_asm.py from Arm's machine-readable
;                   specification, with encodings checked against clang
;
; The order matters where entries compete: of two equal patterns,
; constants or decodings, the first wins.
;
; Each function with an "enc" attribute is one machine instruction: its body
; is what the instruction does, its parameters are its operands, "enc" is its
; encoding (most significant bit first, as in the Arm Architecture Reference
; Manual) and "asm" its assembly. The result is the operand called `d`.
;
; Operand kinds, from parameter attributes:
;   "reg"="w" / "x"       register of that class (01-target.ll lists them);
;                         number 31 is the zero register in w and x, and
;                         the stack pointer in wsp and xsp
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
;   "dclass"="wsp"        the result's register class, if not the one its
;                         type is put in (w, x, s, d, v, q)
;   "nomatch"             not a pattern for selection
;   "role"="..."          used by the code generator by role (load.x,
;                         addr.hi, jump, ...), comma-separated if several;
;                         see docs/design/targets.md
;   "feature"="neon"      used only when this feature is on (comma-separated
;                         if several are needed)
;   "asmonly"             for the assembler and disassembler only; not
;                         selected, and its body says nothing
;   "aliases"="cinc,cset" other mnemonics Arm writes it with
;   "result2"             the second field of the result is a second register
;                         result, the operand called d2 (a load pair's)
;   "reloc"="adrp"        how an object file fixes up its "sym" operand, by
;                         a relocation's name in !target.relocs (01-target.ll)

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

define void @B(ptr "label" %dest) "enc"="000101 imm26:s26=dest/4" "asm"="b {dest}" "role"="jump" {
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

; Testing one bit of a value against zero, the bit given as a mask
; (`(x & 4) == 0`): tbz and tbnz with the bit's number. For 64 bits, a bit
; at 32 or above sets the encoding's top bit (those are also the
; decoders of tbz and tbnz on a 64-bit register's high bits).

define void @TBZWm(i32 "reg"="w" %t, i32 "imm" %m, ptr "label" %dest) "enc"="0 011011 0 b:5=log2(m) imm14:s14=dest/4 t:5" "asm"="tbz {t}, #{=log2(m)}, {dest}" "inverse"="TBNZWm" "nodecode" {
  %a = and i32 %t, %m
  %c = icmp eq i32 %a, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBNZWm(i32 "reg"="w" %t, i32 "imm" %m, ptr "label" %dest) "enc"="0 011011 1 b:5=log2(m) imm14:s14=dest/4 t:5" "asm"="tbnz {t}, #{=log2(m)}, {dest}" "inverse"="TBZWm" "nodecode" {
  %a = and i32 %t, %m
  %c = icmp ne i32 %a, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBZXlo(i64 "reg"="x" %t, i64 "imm" %m, ptr "label" %dest) "enc"="0 011011 0 b:5=log2(m) imm14:s14=dest/4 t:5" "asm"="tbz {t:w}, #{=log2(m)}, {dest}" "inverse"="TBNZXlo" "nodecode" {
  %a = and i64 %t, %m
  %c = icmp eq i64 %a, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBNZXlo(i64 "reg"="x" %t, i64 "imm" %m, ptr "label" %dest) "enc"="0 011011 1 b:5=log2(m) imm14:s14=dest/4 t:5" "asm"="tbnz {t:w}, #{=log2(m)}, {dest}" "inverse"="TBZXlo" "nodecode" {
  %a = and i64 %t, %m
  %c = icmp ne i64 %a, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBZXhi(i64 "reg"="x" %t, i64 "imm" %m, ptr "label" %dest) "enc"="1 011011 0 b:5=log2(m)-32 imm14:s14=dest/4 t:5" "asm"="tbz {t}, #{=log2(m)}, {dest}" "inverse"="TBNZXhi" {
  %a = and i64 %t, %m
  %c = icmp eq i64 %a, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBNZXhi(i64 "reg"="x" %t, i64 "imm" %m, ptr "label" %dest) "enc"="1 011011 1 b:5=log2(m)-32 imm14:s14=dest/4 t:5" "asm"="tbnz {t}, #{=log2(m)}, {dest}" "inverse"="TBZXhi" {
  %a = and i64 %t, %m
  %c = icmp ne i64 %a, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

; A sign test is a test of the top bit: x >= 0 (as LLVM writes it, x > -1)
; is tbz on bit 63 (31), x < 0 tbnz. The 64-bit ones decode bit 63, which
; the mask entries cannot (1 << 63 is negative).

define void @TBZXpos(i64 "reg"="x" %t, ptr "label" %dest) "enc"="1 011011 0 11111 imm14:s14=dest/4 t:5" "asm"="tbz {t}, #63, {dest}" "inverse"="TBNZXneg" {
  %c = icmp sgt i64 %t, -1
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBNZXneg(i64 "reg"="x" %t, ptr "label" %dest) "enc"="1 011011 1 11111 imm14:s14=dest/4 t:5" "asm"="tbnz {t}, #63, {dest}" "inverse"="TBZXpos" {
  %c = icmp slt i64 %t, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBZWpos(i32 "reg"="w" %t, ptr "label" %dest) "enc"="0 011011 0 11111 imm14:s14=dest/4 t:5" "asm"="tbz {t}, #31, {dest}" "inverse"="TBNZWneg" "nodecode" {
  %c = icmp sgt i32 %t, -1
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @TBNZWneg(i32 "reg"="w" %t, ptr "label" %dest) "enc"="0 011011 1 11111 imm14:s14=dest/4 t:5" "asm"="tbnz {t}, #31, {dest}" "inverse"="TBZWpos" "nodecode" {
  %c = icmp slt i32 %t, 0
  br i1 %c, label %taken, label %next
taken:
  indirectbr ptr %dest, []
next:
  ret void
}

define void @RET() "enc"="1101011 0 0 10 11111 0000 0 0 11110 00000" "asm"="ret" "role"="ret" {
  ret void
}

define void @BRK() "enc"="11010100 001 0000000000000001 000 00" "asm"="brk #0x1" "role"="trap" {
  unreachable
}

define void @BL(ptr "sym" %s) "enc"="100101 imm26:s26=s/4" "asm"="bl {s}" "reloc"="call26" "role"="call" "nomatch" {
  ret void
}

; A tail call: the callee returns to this function's caller.
define void @Btail(ptr "sym" %s) "enc"="000101 imm26:s26=s/4" "asm"="b {s}" "reloc"="jump26" "role"="tailcall" "nomatch" "nodecode" {
  ret void
}

; A tail call through a register.
define void @BRtail(ptr "reg"="x" %n) "enc"="1101011 0 0 00 11111 0000 0 0 n:5 00000" "asm"="br {n}" "role"="tailcallr" "nomatch" {
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

