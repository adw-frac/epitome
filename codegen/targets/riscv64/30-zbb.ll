; The RISC-V RV64 description: Zbb, basic bit manipulation (feature zbb). Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

declare i64 @llvm.smax.i64(i64, i64)

define i64 @MAX(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000101 m:5 n:5 110 d:5 0110011" "asm"="max {d}, {n}, {m}" "feature"="zbb" {
  %r = call i64 @llvm.smax.i64(i64 %n, i64 %m)
  ret i64 %r
}

declare i32 @llvm.smax.i32(i32, i32)

define i32 @MAXw(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000101 m:5 n:5 110 d:5 0110011" "asm"="max {d}, {n}, {m}" "feature"="zbb" "nodecode" {
  %r = call i32 @llvm.smax.i32(i32 %n, i32 %m)
  ret i32 %r
}

declare i64 @llvm.umax.i64(i64, i64)

define i64 @MAXU(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000101 m:5 n:5 111 d:5 0110011" "asm"="maxu {d}, {n}, {m}" "feature"="zbb" {
  %r = call i64 @llvm.umax.i64(i64 %n, i64 %m)
  ret i64 %r
}

declare i32 @llvm.umax.i32(i32, i32)

define i32 @MAXUw(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000101 m:5 n:5 111 d:5 0110011" "asm"="maxu {d}, {n}, {m}" "feature"="zbb" "nodecode" {
  %r = call i32 @llvm.umax.i32(i32 %n, i32 %m)
  ret i32 %r
}

declare i64 @llvm.smin.i64(i64, i64)

define i64 @MIN(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000101 m:5 n:5 100 d:5 0110011" "asm"="min {d}, {n}, {m}" "feature"="zbb" {
  %r = call i64 @llvm.smin.i64(i64 %n, i64 %m)
  ret i64 %r
}

declare i32 @llvm.smin.i32(i32, i32)

define i32 @MINw(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000101 m:5 n:5 100 d:5 0110011" "asm"="min {d}, {n}, {m}" "feature"="zbb" "nodecode" {
  %r = call i32 @llvm.smin.i32(i32 %n, i32 %m)
  ret i32 %r
}

declare i64 @llvm.umin.i64(i64, i64)

define i64 @MINU(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000101 m:5 n:5 101 d:5 0110011" "asm"="minu {d}, {n}, {m}" "feature"="zbb" {
  %r = call i64 @llvm.umin.i64(i64 %n, i64 %m)
  ret i64 %r
}

declare i32 @llvm.umin.i32(i32, i32)

define i32 @MINUw(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000101 m:5 n:5 101 d:5 0110011" "asm"="minu {d}, {n}, {m}" "feature"="zbb" "nodecode" {
  %r = call i32 @llvm.umin.i32(i32 %n, i32 %m)
  ret i32 %r
}

define i64 @ANDN(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0100000 m:5 n:5 111 d:5 0110011" "asm"="andn {d}, {n}, {m}" "feature"="zbb" {
  %nm = xor i64 %m, -1
  %r = and i64 %n, %nm
  ret i64 %r
}

define i64 @ORN(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0100000 m:5 n:5 110 d:5 0110011" "asm"="orn {d}, {n}, {m}" "feature"="zbb" {
  %nm = xor i64 %m, -1
  %r = or i64 %n, %nm
  ret i64 %r
}

declare i64 @llvm.ctlz.i64(i64, i1)

define i64 @CLZ(i64 "reg"="x" %n) "enc"="0110000 00000 n:5 001 d:5 0010011" "asm"="clz {d}, {n}" "feature"="zbb" {
  %r = call i64 @llvm.ctlz.i64(i64 %n, i1 false)
  ret i64 %r
}

declare i64 @llvm.cttz.i64(i64, i1)

define i64 @CTZ(i64 "reg"="x" %n) "enc"="0110000 00001 n:5 001 d:5 0010011" "asm"="ctz {d}, {n}" "feature"="zbb" {
  %r = call i64 @llvm.cttz.i64(i64 %n, i1 false)
  ret i64 %r
}

declare i64 @llvm.ctpop.i64(i64)

define i64 @CPOP(i64 "reg"="x" %n) "enc"="0110000 00010 n:5 001 d:5 0010011" "asm"="cpop {d}, {n}" "feature"="zbb" {
  %r = call i64 @llvm.ctpop.i64(i64 %n)
  ret i64 %r
}

define i64 @SEXTB64(i8 "reg"="w" %n) "enc"="0110000 00100 n:5 001 d:5 0010011" "asm"="sext.b {d}, {n}" "feature"="zbb" {
  %r = sext i8 %n to i64
  ret i64 %r
}

define i32 @SEXTB32(i8 "reg"="w" %n) "enc"="0110000 00100 n:5 001 d:5 0010011" "asm"="sext.b {d}, {n}" "feature"="zbb" "nodecode" {
  %r = sext i8 %n to i32
  ret i32 %r
}

define i64 @SEXTH64(i16 "reg"="w" %n) "enc"="0110000 00101 n:5 001 d:5 0010011" "asm"="sext.h {d}, {n}" "feature"="zbb" {
  %r = sext i16 %n to i64
  ret i64 %r
}

define i32 @SEXTH32(i16 "reg"="w" %n) "enc"="0110000 00101 n:5 001 d:5 0010011" "asm"="sext.h {d}, {n}" "feature"="zbb" "nodecode" {
  %r = sext i16 %n to i32
  ret i32 %r
}

define i64 @ZEXTH64(i16 "reg"="w" %n) "enc"="0000100 00000 n:5 100 d:5 0111011" "asm"="zext.h {d}, {n}" "feature"="zbb" "zext"="16" {
  %r = zext i16 %n to i64
  ret i64 %r
}

define i32 @ZEXTH32(i16 "reg"="w" %n) "enc"="0000100 00000 n:5 100 d:5 0111011" "asm"="zext.h {d}, {n}" "feature"="zbb" "zext"="16" "nodecode" {
  %r = zext i16 %n to i32
  ret i32 %r
}

declare i64 @llvm.bswap.i64(i64)

define i64 @REV8(i64 "reg"="x" %n) "enc"="011010111000 n:5 101 d:5 0010011" "asm"="rev8 {d}, {n}" "feature"="zbb" {
  %r = call i64 @llvm.bswap.i64(i64 %n)
  ret i64 %r
}
