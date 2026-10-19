; The AArch64 description: bit manipulation. The conventions are in
; 00-base.ll.

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

