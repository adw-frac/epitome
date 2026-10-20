; The AArch64 description: vectors. The conventions are in 00-base.ll.

; ===========================================================================
; Vectors (Advanced SIMD). 128-bit vectors live in q registers, 64-bit ones
; in d registers; templates print them with their arrangement, v3.4s. A
; vector of i1 is a mask: lanes of all ones or all zeros, as comparisons
; make them, in a q register.
;
; This file is written by gen_vectors.py (one entry per arrangement), but
; is data like the rest.

define <16 x i8> @ADDv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="add {d:16b}, {n:16b}, {m:16b}" {
  %r = add <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @SUBv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:16b}, {n:16b}, {m:16b}" {
  %r = sub <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @MULv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:16b}, {n:16b}, {m:16b}" {
  %r = mul <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @ANDv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @ORRv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @EORv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @BICv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <16 x i8> %m, splat (i8 -1)
  %r = and <16 x i8> %n, %nm
  ret <16 x i8> %r
}

define <16 x i8> @MVNv16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <16 x i8> %n, splat (i8 -1)
  ret <16 x i8> %r
}

define <16 x i8> @NEGv16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 10000 01011 10 n:5 d:5" "asm"="neg {d:16b}, {n:16b}" {
  %r = sub <16 x i8> zeroinitializer, %n
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.abs.v16i8(<16 x i8>, i1)

define <16 x i8> @ABSv16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 00 10000 01011 10 n:5 d:5" "asm"="abs {d:16b}, {n:16b}" {
  %r = call <16 x i8> @llvm.abs.v16i8(<16 x i8> %n, i1 false)
  ret <16 x i8> %r
}

define <16 x i8> @SHLv16b(<16 x i8> "reg"="q" %n, <16 x i8> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 0001 sh:3 01010 1 n:5 d:5" "asm"="shl {d:16b}, {n:16b}, #{sh}" {
  %r = shl <16 x i8> %n, %sh
  ret <16 x i8> %r
}

define <16 x i8> @USHRv16b(<16 x i8> "reg"="q" %n, <16 x i8> "imm" %sh) "feature"="neon" "enc"="0 1 1 011110 0001 amt:3=8-sh 00000 1 n:5 d:5" "asm"="ushr {d:16b}, {n:16b}, #{sh}" {
  %r = lshr <16 x i8> %n, %sh
  ret <16 x i8> %r
}

define <16 x i8> @SSHRv16b(<16 x i8> "reg"="q" %n, <16 x i8> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 0001 amt:3=8-sh 00000 1 n:5 d:5" "asm"="sshr {d:16b}, {n:16b}, #{sh}" {
  %r = ashr <16 x i8> %n, %sh
  ret <16 x i8> %r
}

define <16 x i1> @CMEQv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp eq <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGTv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp sgt <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGEv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp sge <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHIv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp ugt <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHSv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %r = icmp uge <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGTsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp slt <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMGEsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp sle <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHIsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp ult <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @CMHSsv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:16b}, {m:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp ule <16 x i8> %n, %m
  ret <16 x i1> %r
}

define <16 x i8> @BSLv16b(<16 x i1> "reg"="q" "tied" %c, <16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" {
  %r = select <16 x i1> %c, <16 x i8> %n, <16 x i8> %m
  ret <16 x i8> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <16 x i8> @MASKv16b(<16 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 0001001 00000 1 n:5 d:5" "asm"="ushr {d:16b}, {n:16b}, #7" "nodecode" {
  %r = zext <16 x i1> %n to <16 x i8>
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.smax.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SMAXv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.smax.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.smin.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SMINv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.smin.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.umax.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @UMAXv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.umax.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.umin.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @UMINv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.umin.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

define <16 x i8> @DUPv16b(i8 "reg"="w" %n) "feature"="neon" "enc"="0 1 0 01110000 00001 0 0001 1 n:5 d:5" "asm"="dup {d:16b}, {n}" "role"="dup.16b" {
  %i = insertelement <16 x i8> poison, i8 %n, i64 0
  %r = shufflevector <16 x i8> %i, <16 x i8> poison, <16 x i32> zeroinitializer
  ret <16 x i8> %r
}

define <8 x i16> @ADDv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="add {d:8h}, {n:8h}, {m:8h}" {
  %r = add <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @SUBv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:8h}, {n:8h}, {m:8h}" {
  %r = sub <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @MULv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:8h}, {n:8h}, {m:8h}" {
  %r = mul <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @ANDv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @ORRv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @EORv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @BICv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <8 x i16> %m, splat (i16 -1)
  %r = and <8 x i16> %n, %nm
  ret <8 x i16> %r
}

define <8 x i16> @MVNv8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <8 x i16> %n, splat (i16 -1)
  ret <8 x i16> %r
}

define <8 x i16> @NEGv8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 01 10000 01011 10 n:5 d:5" "asm"="neg {d:8h}, {n:8h}" {
  %r = sub <8 x i16> zeroinitializer, %n
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.abs.v8i16(<8 x i16>, i1)

define <8 x i16> @ABSv8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 01 10000 01011 10 n:5 d:5" "asm"="abs {d:8h}, {n:8h}" {
  %r = call <8 x i16> @llvm.abs.v8i16(<8 x i16> %n, i1 false)
  ret <8 x i16> %r
}

define <8 x i16> @SHLv8h(<8 x i16> "reg"="q" %n, <8 x i16> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 001 sh:4 01010 1 n:5 d:5" "asm"="shl {d:8h}, {n:8h}, #{sh}" {
  %r = shl <8 x i16> %n, %sh
  ret <8 x i16> %r
}

define <8 x i16> @USHRv8h(<8 x i16> "reg"="q" %n, <8 x i16> "imm" %sh) "feature"="neon" "enc"="0 1 1 011110 001 amt:4=16-sh 00000 1 n:5 d:5" "asm"="ushr {d:8h}, {n:8h}, #{sh}" {
  %r = lshr <8 x i16> %n, %sh
  ret <8 x i16> %r
}

define <8 x i16> @SSHRv8h(<8 x i16> "reg"="q" %n, <8 x i16> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 001 amt:4=16-sh 00000 1 n:5 d:5" "asm"="sshr {d:8h}, {n:8h}, #{sh}" {
  %r = ashr <8 x i16> %n, %sh
  ret <8 x i16> %r
}

define <8 x i1> @CMEQv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp eq <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp sgt <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp sge <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp ugt <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %r = icmp uge <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp slt <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp sle <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp ult <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSsv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:8h}, {m:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp ule <8 x i16> %n, %m
  ret <8 x i1> %r
}

define <8 x i16> @BSLv8h(<8 x i1> "reg"="q" "tied" %c, <8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <8 x i1> %c, <8 x i16> %n, <8 x i16> %m
  ret <8 x i16> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <8 x i16> @MASKv8h(<8 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 0010001 00000 1 n:5 d:5" "asm"="ushr {d:8h}, {n:8h}, #15" "nodecode" {
  %r = zext <8 x i1> %n to <8 x i16>
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.smax.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SMAXv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.smax.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.smin.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SMINv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.smin.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.umax.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @UMAXv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.umax.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.umin.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @UMINv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.umin.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

define <8 x i16> @DUPv8h(i16 "reg"="w" %n) "feature"="neon" "enc"="0 1 0 01110000 00010 0 0001 1 n:5 d:5" "asm"="dup {d:8h}, {n}" "role"="dup.8h" {
  %i = insertelement <8 x i16> poison, i16 %n, i64 0
  %r = shufflevector <8 x i16> %i, <8 x i16> poison, <8 x i32> zeroinitializer
  ret <8 x i16> %r
}

define <4 x i32> @ADDv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="add {d:4s}, {n:4s}, {m:4s}" {
  %r = add <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @SUBv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:4s}, {n:4s}, {m:4s}" {
  %r = sub <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @MULv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:4s}, {n:4s}, {m:4s}" {
  %r = mul <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @ANDv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @ORRv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @EORv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @BICv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <4 x i32> %m, splat (i32 -1)
  %r = and <4 x i32> %n, %nm
  ret <4 x i32> %r
}

define <4 x i32> @MVNv4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <4 x i32> %n, splat (i32 -1)
  ret <4 x i32> %r
}

define <4 x i32> @NEGv4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 10 10000 01011 10 n:5 d:5" "asm"="neg {d:4s}, {n:4s}" {
  %r = sub <4 x i32> zeroinitializer, %n
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.abs.v4i32(<4 x i32>, i1)

define <4 x i32> @ABSv4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 10000 01011 10 n:5 d:5" "asm"="abs {d:4s}, {n:4s}" {
  %r = call <4 x i32> @llvm.abs.v4i32(<4 x i32> %n, i1 false)
  ret <4 x i32> %r
}

define <4 x i32> @SHLv4s(<4 x i32> "reg"="q" %n, <4 x i32> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 01 sh:5 01010 1 n:5 d:5" "asm"="shl {d:4s}, {n:4s}, #{sh}" {
  %r = shl <4 x i32> %n, %sh
  ret <4 x i32> %r
}

define <4 x i32> @USHRv4s(<4 x i32> "reg"="q" %n, <4 x i32> "imm" %sh) "feature"="neon" "enc"="0 1 1 011110 01 amt:5=32-sh 00000 1 n:5 d:5" "asm"="ushr {d:4s}, {n:4s}, #{sh}" {
  %r = lshr <4 x i32> %n, %sh
  ret <4 x i32> %r
}

define <4 x i32> @SSHRv4s(<4 x i32> "reg"="q" %n, <4 x i32> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 01 amt:5=32-sh 00000 1 n:5 d:5" "asm"="sshr {d:4s}, {n:4s}, #{sh}" {
  %r = ashr <4 x i32> %n, %sh
  ret <4 x i32> %r
}

define <4 x i1> @CMEQv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp eq <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp sgt <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp sge <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp ugt <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = icmp uge <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp slt <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp sle <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp ult <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSsv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp ule <4 x i32> %n, %m
  ret <4 x i1> %r
}

define <4 x i32> @BSLv4s(<4 x i1> "reg"="q" "tied" %c, <4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <4 x i1> %c, <4 x i32> %n, <4 x i32> %m
  ret <4 x i32> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <4 x i32> @MASKv4s(<4 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 0100001 00000 1 n:5 d:5" "asm"="ushr {d:4s}, {n:4s}, #31" "nodecode" {
  %r = zext <4 x i1> %n to <4 x i32>
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.smax.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SMAXv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.smin.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SMINv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.smin.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.umax.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @UMAXv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.umax.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.umin.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @UMINv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.umin.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @DUPv4s(i32 "reg"="w" %n) "feature"="neon" "enc"="0 1 0 01110000 00100 0 0001 1 n:5 d:5" "asm"="dup {d:4s}, {n}" "role"="dup.4s" {
  %i = insertelement <4 x i32> poison, i32 %n, i64 0
  %r = shufflevector <4 x i32> %i, <4 x i32> poison, <4 x i32> zeroinitializer
  ret <4 x i32> %r
}

define <2 x i64> @ADDv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 m:5 10000 1 n:5 d:5" "asm"="add {d:2d}, {n:2d}, {m:2d}" {
  %r = add <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @SUBv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:2d}, {n:2d}, {m:2d}" {
  %r = sub <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @ANDv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" {
  %r = and <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @ORRv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" {
  %r = or <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @EORv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" {
  %r = xor <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @BICv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:16b}, {n:16b}, {m:16b}" {
  %nm = xor <2 x i64> %m, splat (i64 -1)
  %r = and <2 x i64> %n, %nm
  ret <2 x i64> %r
}

define <2 x i64> @MVNv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:16b}, {n:16b}" {
  %r = xor <2 x i64> %n, splat (i64 -1)
  ret <2 x i64> %r
}

define <2 x i64> @NEGv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 11 10000 01011 10 n:5 d:5" "asm"="neg {d:2d}, {n:2d}" {
  %r = sub <2 x i64> zeroinitializer, %n
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.abs.v2i64(<2 x i64>, i1)

define <2 x i64> @ABSv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 11 10000 01011 10 n:5 d:5" "asm"="abs {d:2d}, {n:2d}" {
  %r = call <2 x i64> @llvm.abs.v2i64(<2 x i64> %n, i1 false)
  ret <2 x i64> %r
}

define <2 x i64> @SHLv2d(<2 x i64> "reg"="q" %n, <2 x i64> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 1 sh:6 01010 1 n:5 d:5" "asm"="shl {d:2d}, {n:2d}, #{sh}" {
  %r = shl <2 x i64> %n, %sh
  ret <2 x i64> %r
}

define <2 x i64> @USHRv2d(<2 x i64> "reg"="q" %n, <2 x i64> "imm" %sh) "feature"="neon" "enc"="0 1 1 011110 1 amt:6=64-sh 00000 1 n:5 d:5" "asm"="ushr {d:2d}, {n:2d}, #{sh}" {
  %r = lshr <2 x i64> %n, %sh
  ret <2 x i64> %r
}

define <2 x i64> @SSHRv2d(<2 x i64> "reg"="q" %n, <2 x i64> "imm" %sh) "feature"="neon" "enc"="0 1 0 011110 1 amt:6=64-sh 00000 1 n:5 d:5" "asm"="sshr {d:2d}, {n:2d}, #{sh}" {
  %r = ashr <2 x i64> %n, %sh
  ret <2 x i64> %r
}

define <2 x i1> @CMEQv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp eq <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp sgt <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp sge <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp ugt <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = icmp uge <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp slt <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp sle <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp ult <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSsv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp ule <2 x i64> %n, %m
  ret <2 x i1> %r
}

define <2 x i64> @BSLv2d(<2 x i1> "reg"="q" "tied" %c, <2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x i64> %n, <2 x i64> %m
  ret <2 x i64> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <2 x i64> @MASKv2d(<2 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 1000001 00000 1 n:5 d:5" "asm"="ushr {d:2d}, {n:2d}, #63" "nodecode" {
  %r = zext <2 x i1> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @DUPv2d(i64 "reg"="x" %n) "feature"="neon" "enc"="0 1 0 01110000 01000 0 0001 1 n:5 d:5" "asm"="dup {d:2d}, {n}" "role"="dup.2d" {
  %i = insertelement <2 x i64> poison, i64 %n, i64 0
  %r = shufflevector <2 x i64> %i, <2 x i64> poison, <2 x i32> zeroinitializer
  ret <2 x i64> %r
}

define <8 x i8> @ADDv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="add {d:8b}, {n:8b}, {m:8b}" {
  %r = add <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @SUBv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:8b}, {n:8b}, {m:8b}" {
  %r = sub <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @MULv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:8b}, {n:8b}, {m:8b}" {
  %r = mul <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @ANDv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:8b}, {n:8b}, {m:8b}" {
  %r = and <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @ORRv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:8b}, {n:8b}, {m:8b}" {
  %r = or <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @EORv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:8b}, {n:8b}, {m:8b}" {
  %r = xor <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @BICv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:8b}, {n:8b}, {m:8b}" {
  %nm = xor <8 x i8> %m, splat (i8 -1)
  %r = and <8 x i8> %n, %nm
  ret <8 x i8> %r
}

define <8 x i8> @MVNv8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:8b}, {n:8b}" {
  %r = xor <8 x i8> %n, splat (i8 -1)
  ret <8 x i8> %r
}

define <8 x i8> @NEGv8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 00 10000 01011 10 n:5 d:5" "asm"="neg {d:8b}, {n:8b}" {
  %r = sub <8 x i8> zeroinitializer, %n
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.abs.v8i8(<8 x i8>, i1)

define <8 x i8> @ABSv8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 10000 01011 10 n:5 d:5" "asm"="abs {d:8b}, {n:8b}" {
  %r = call <8 x i8> @llvm.abs.v8i8(<8 x i8> %n, i1 false)
  ret <8 x i8> %r
}

define <8 x i8> @SHLv8b(<8 x i8> "reg"="v" %n, <8 x i8> "imm" %sh) "feature"="neon" "enc"="0 0 0 011110 0001 sh:3 01010 1 n:5 d:5" "asm"="shl {d:8b}, {n:8b}, #{sh}" {
  %r = shl <8 x i8> %n, %sh
  ret <8 x i8> %r
}

define <8 x i8> @USHRv8b(<8 x i8> "reg"="v" %n, <8 x i8> "imm" %sh) "feature"="neon" "enc"="0 0 1 011110 0001 amt:3=8-sh 00000 1 n:5 d:5" "asm"="ushr {d:8b}, {n:8b}, #{sh}" {
  %r = lshr <8 x i8> %n, %sh
  ret <8 x i8> %r
}

define <8 x i8> @SSHRv8b(<8 x i8> "reg"="v" %n, <8 x i8> "imm" %sh) "feature"="neon" "enc"="0 0 0 011110 0001 amt:3=8-sh 00000 1 n:5 d:5" "asm"="sshr {d:8b}, {n:8b}, #{sh}" {
  %r = ashr <8 x i8> %n, %sh
  ret <8 x i8> %r
}

define <8 x i1> @CMEQv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp eq <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp sgt <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp sge <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp ugt <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %r = icmp uge <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGTsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp slt <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMGEsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp sle <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHIsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp ult <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @CMHSsv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:8b}, {m:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp ule <8 x i8> %n, %m
  ret <8 x i1> %r
}

define <8 x i8> @BSLv8b(<8 x i1> "reg"="q" "tied" %c, <8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" {
  %r = select <8 x i1> %c, <8 x i8> %n, <8 x i8> %m
  ret <8 x i8> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <8 x i8> @MASKv8b(<8 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 011110 0001001 00000 1 n:5 d:5" "asm"="ushr {d:8b}, {n:8b}, #7" "nodecode" {
  %r = zext <8 x i1> %n to <8 x i8>
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.smax.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SMAXv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.smax.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.smin.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SMINv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.smin.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.umax.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @UMAXv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.umax.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.umin.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @UMINv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.umin.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

define <8 x i8> @DUPv8b(i8 "reg"="w" %n) "feature"="neon" "enc"="0 0 0 01110000 00001 0 0001 1 n:5 d:5" "asm"="dup {d:8b}, {n}" "role"="dup.8b" {
  %i = insertelement <8 x i8> poison, i8 %n, i64 0
  %r = shufflevector <8 x i8> %i, <8 x i8> poison, <8 x i32> zeroinitializer
  ret <8 x i8> %r
}

define <4 x i16> @ADDv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="add {d:4h}, {n:4h}, {m:4h}" {
  %r = add <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @SUBv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:4h}, {n:4h}, {m:4h}" {
  %r = sub <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @MULv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:4h}, {n:4h}, {m:4h}" {
  %r = mul <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @ANDv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:8b}, {n:8b}, {m:8b}" {
  %r = and <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @ORRv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:8b}, {n:8b}, {m:8b}" {
  %r = or <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @EORv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:8b}, {n:8b}, {m:8b}" {
  %r = xor <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @BICv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:8b}, {n:8b}, {m:8b}" {
  %nm = xor <4 x i16> %m, splat (i16 -1)
  %r = and <4 x i16> %n, %nm
  ret <4 x i16> %r
}

define <4 x i16> @MVNv4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:8b}, {n:8b}" {
  %r = xor <4 x i16> %n, splat (i16 -1)
  ret <4 x i16> %r
}

define <4 x i16> @NEGv4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 01 10000 01011 10 n:5 d:5" "asm"="neg {d:4h}, {n:4h}" {
  %r = sub <4 x i16> zeroinitializer, %n
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.abs.v4i16(<4 x i16>, i1)

define <4 x i16> @ABSv4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 01 10000 01011 10 n:5 d:5" "asm"="abs {d:4h}, {n:4h}" {
  %r = call <4 x i16> @llvm.abs.v4i16(<4 x i16> %n, i1 false)
  ret <4 x i16> %r
}

define <4 x i16> @SHLv4h(<4 x i16> "reg"="v" %n, <4 x i16> "imm" %sh) "feature"="neon" "enc"="0 0 0 011110 001 sh:4 01010 1 n:5 d:5" "asm"="shl {d:4h}, {n:4h}, #{sh}" {
  %r = shl <4 x i16> %n, %sh
  ret <4 x i16> %r
}

define <4 x i16> @USHRv4h(<4 x i16> "reg"="v" %n, <4 x i16> "imm" %sh) "feature"="neon" "enc"="0 0 1 011110 001 amt:4=16-sh 00000 1 n:5 d:5" "asm"="ushr {d:4h}, {n:4h}, #{sh}" {
  %r = lshr <4 x i16> %n, %sh
  ret <4 x i16> %r
}

define <4 x i16> @SSHRv4h(<4 x i16> "reg"="v" %n, <4 x i16> "imm" %sh) "feature"="neon" "enc"="0 0 0 011110 001 amt:4=16-sh 00000 1 n:5 d:5" "asm"="sshr {d:4h}, {n:4h}, #{sh}" {
  %r = ashr <4 x i16> %n, %sh
  ret <4 x i16> %r
}

define <4 x i1> @CMEQv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp eq <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp sgt <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp sge <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp ugt <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %r = icmp uge <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGTsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp slt <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMGEsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp sle <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHIsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp ult <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @CMHSsv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:4h}, {m:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp ule <4 x i16> %n, %m
  ret <4 x i1> %r
}

define <4 x i16> @BSLv4h(<4 x i1> "reg"="q" "tied" %c, <4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" "nodecode" {
  %r = select <4 x i1> %c, <4 x i16> %n, <4 x i16> %m
  ret <4 x i16> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <4 x i16> @MASKv4h(<4 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 011110 0010001 00000 1 n:5 d:5" "asm"="ushr {d:4h}, {n:4h}, #15" "nodecode" {
  %r = zext <4 x i1> %n to <4 x i16>
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.smax.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SMAXv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.smax.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.smin.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SMINv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.smin.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.umax.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @UMAXv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.umax.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.umin.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @UMINv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.umin.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

define <4 x i16> @DUPv4h(i16 "reg"="w" %n) "feature"="neon" "enc"="0 0 0 01110000 00010 0 0001 1 n:5 d:5" "asm"="dup {d:4h}, {n}" "role"="dup.4h" {
  %i = insertelement <4 x i16> poison, i16 %n, i64 0
  %r = shufflevector <4 x i16> %i, <4 x i16> poison, <4 x i32> zeroinitializer
  ret <4 x i16> %r
}

define <2 x i32> @ADDv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="add {d:2s}, {n:2s}, {m:2s}" {
  %r = add <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @SUBv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 10000 1 n:5 d:5" "asm"="sub {d:2s}, {n:2s}, {m:2s}" {
  %r = sub <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @MULv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10011 1 n:5 d:5" "asm"="mul {d:2s}, {n:2s}, {m:2s}" {
  %r = mul <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @ANDv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:8b}, {n:8b}, {m:8b}" {
  %r = and <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @ORRv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:8b}, {n:8b}, {m:8b}" {
  %r = or <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @EORv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:8b}, {n:8b}, {m:8b}" {
  %r = xor <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @BICv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {d:8b}, {n:8b}, {m:8b}" {
  %nm = xor <2 x i32> %m, splat (i32 -1)
  %r = and <2 x i32> %n, %nm
  ret <2 x i32> %r
}

define <2 x i32> @MVNv2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {d:8b}, {n:8b}" {
  %r = xor <2 x i32> %n, splat (i32 -1)
  ret <2 x i32> %r
}

define <2 x i32> @NEGv2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 10 10000 01011 10 n:5 d:5" "asm"="neg {d:2s}, {n:2s}" {
  %r = sub <2 x i32> zeroinitializer, %n
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.abs.v2i32(<2 x i32>, i1)

define <2 x i32> @ABSv2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 10 10000 01011 10 n:5 d:5" "asm"="abs {d:2s}, {n:2s}" {
  %r = call <2 x i32> @llvm.abs.v2i32(<2 x i32> %n, i1 false)
  ret <2 x i32> %r
}

define <2 x i32> @SHLv2s(<2 x i32> "reg"="v" %n, <2 x i32> "imm" %sh) "feature"="neon" "enc"="0 0 0 011110 01 sh:5 01010 1 n:5 d:5" "asm"="shl {d:2s}, {n:2s}, #{sh}" {
  %r = shl <2 x i32> %n, %sh
  ret <2 x i32> %r
}

define <2 x i32> @USHRv2s(<2 x i32> "reg"="v" %n, <2 x i32> "imm" %sh) "feature"="neon" "enc"="0 0 1 011110 01 amt:5=32-sh 00000 1 n:5 d:5" "asm"="ushr {d:2s}, {n:2s}, #{sh}" {
  %r = lshr <2 x i32> %n, %sh
  ret <2 x i32> %r
}

define <2 x i32> @SSHRv2s(<2 x i32> "reg"="v" %n, <2 x i32> "imm" %sh) "feature"="neon" "enc"="0 0 0 011110 01 amt:5=32-sh 00000 1 n:5 d:5" "asm"="sshr {d:2s}, {n:2s}, #{sh}" {
  %r = ashr <2 x i32> %n, %sh
  ret <2 x i32> %r
}

define <2 x i1> @CMEQv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmeq {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp eq <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmgt {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp sgt <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmge {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp sge <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 00110 1 n:5 d:5" "asm"="cmhi {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp ugt <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 00111 1 n:5 d:5" "asm"="cmhs {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = icmp uge <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGTsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmgt {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp slt <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMGEsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmge {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp sle <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHIsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 rm:5=n 00110 1 rn:5=m d:5" "asm"="cmhi {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp ult <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @CMHSsv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 rm:5=n 00111 1 rn:5=m d:5" "asm"="cmhs {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp ule <2 x i32> %n, %m
  ret <2 x i1> %r
}

define <2 x i32> @BSLv2s(<2 x i1> "reg"="q" "tied" %c, <2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x i32> %n, <2 x i32> %m
  ret <2 x i32> %r
}

; A mask's lanes, all ones or zeros, as 1 or 0.
define <2 x i32> @MASKv2s(<2 x i1> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 011110 0100001 00000 1 n:5 d:5" "asm"="ushr {d:2s}, {n:2s}, #31" "nodecode" {
  %r = zext <2 x i1> %n to <2 x i32>
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.smax.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SMAXv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="smax {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.smax.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.smin.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SMINv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="smin {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.smin.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.umax.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @UMAXv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 01100 1 n:5 d:5" "asm"="umax {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.umax.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.umin.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @UMINv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 01101 1 n:5 d:5" "asm"="umin {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.umin.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

define <2 x i32> @DUPv2s(i32 "reg"="w" %n) "feature"="neon" "enc"="0 0 0 01110000 00100 0 0001 1 n:5 d:5" "asm"="dup {d:2s}, {n}" "role"="dup.2s" {
  %i = insertelement <2 x i32> poison, i32 %n, i64 0
  %r = shufflevector <2 x i32> %i, <2 x i32> poison, <2 x i32> zeroinitializer
  ret <2 x i32> %r
}

define i8 @UMOVb(<16 x i8> "reg"="q" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 0 0 01110000 imm5:5=idx*2+1 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.b}[{idx}]" {
  %r = extractelement <16 x i8> %n, i64 %idx
  ret i8 %r
}

define <16 x i8> @INSb(<16 x i8> "reg"="q" "tied" %old, i8 "reg"="w" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*2+1 0 0011 1 n:5 d:5" "asm"="mov {d:.b}[{idx}], {n}" "role"="ins.b" {
  %r = insertelement <16 x i8> %old, i8 %n, i64 %idx
  ret <16 x i8> %r
}

define i16 @UMOVh(<8 x i16> "reg"="q" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 0 0 01110000 imm5:5=idx*4+2 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.h}[{idx}]" {
  %r = extractelement <8 x i16> %n, i64 %idx
  ret i16 %r
}

define <8 x i16> @INSh(<8 x i16> "reg"="q" "tied" %old, i16 "reg"="w" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*4+2 0 0011 1 n:5 d:5" "asm"="mov {d:.h}[{idx}], {n}" "role"="ins.h" {
  %r = insertelement <8 x i16> %old, i16 %n, i64 %idx
  ret <8 x i16> %r
}

define i32 @UMOVs(<4 x i32> "reg"="q" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 0 0 01110000 imm5:5=idx*8+4 0 0111 1 n:5 d:5" "asm"="mov {d}, {n:.s}[{idx}]" {
  %r = extractelement <4 x i32> %n, i64 %idx
  ret i32 %r
}

define <4 x i32> @INSs(<4 x i32> "reg"="q" "tied" %old, i32 "reg"="w" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*8+4 0 0011 1 n:5 d:5" "asm"="mov {d:.s}[{idx}], {n}" "role"="ins.s" {
  %r = insertelement <4 x i32> %old, i32 %n, i64 %idx
  ret <4 x i32> %r
}

define i64 @UMOVd(<2 x i64> "reg"="q" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*16+8 0 0111 1 n:5 d:5" "asm"="mov {d}, {n:.d}[{idx}]" {
  %r = extractelement <2 x i64> %n, i64 %idx
  ret i64 %r
}

define <2 x i64> @INSd(<2 x i64> "reg"="q" "tied" %old, i64 "reg"="x" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*16+8 0 0011 1 n:5 d:5" "asm"="mov {d:.d}[{idx}], {n}" "role"="ins.d" {
  %r = insertelement <2 x i64> %old, i64 %n, i64 %idx
  ret <2 x i64> %r
}

define <4 x float> @FADDv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 0 0 1 m:5 11010 1 n:5 d:5" "asm"="fadd {d:4s}, {n:4s}, {m:4s}" {
  %r = fadd <4 x float> %n, %m
  ret <4 x float> %r
}

define <4 x float> @FSUBv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 1 0 1 m:5 11010 1 n:5 d:5" "asm"="fsub {d:4s}, {n:4s}, {m:4s}" {
  %r = fsub <4 x float> %n, %m
  ret <4 x float> %r
}

define <4 x float> @FMULv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 0 1 m:5 11011 1 n:5 d:5" "asm"="fmul {d:4s}, {n:4s}, {m:4s}" {
  %r = fmul <4 x float> %n, %m
  ret <4 x float> %r
}

define <4 x float> @FDIVv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 0 1 m:5 11111 1 n:5 d:5" "asm"="fdiv {d:4s}, {n:4s}, {m:4s}" {
  %r = fdiv <4 x float> %n, %m
  ret <4 x float> %r
}

declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>)

define <4 x float> @FMLAv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m, <4 x float> "reg"="q" "tied" %a) "feature"="neon" "enc"="0 1 0 01110 0 0 1 m:5 11001 1 n:5 d:5" "asm"="fmla {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %n, <4 x float> %m, <4 x float> %a)
  ret <4 x float> %r
}

define <4 x float> @FNEGv4s(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 1 0 10000 01111 10 n:5 d:5" "asm"="fneg {d:4s}, {n:4s}" {
  %r = fneg <4 x float> %n
  ret <4 x float> %r
}

define <4 x i1> @FCMEQv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmeq {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = fcmp oeq <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGEv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmge {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = fcmp oge <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGTv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 1 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmgt {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %r = fcmp ogt <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGEsv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmge {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = fcmp ole <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @FCMGTsv4s(<4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 1 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmgt {d:4s}, {m:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = fcmp olt <4 x float> %n, %m
  ret <4 x i1> %r
}

define <4 x float> @BSLv4sf(<4 x i1> "reg"="q" "tied" %c, <4 x float> "reg"="q" %n, <4 x float> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <4 x i1> %c, <4 x float> %n, <4 x float> %m
  ret <4 x float> %r
}

define <4 x float> @SCVTFv4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 0 0 10000 11101 10 n:5 d:5" "asm"="scvtf {d:4s}, {n:4s}" {
  %r = sitofp <4 x i32> %n to <4 x float>
  ret <4 x float> %r
}

define <4 x float> @UCVTFv4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 0 0 10000 11101 10 n:5 d:5" "asm"="ucvtf {d:4s}, {n:4s}" {
  %r = uitofp <4 x i32> %n to <4 x float>
  ret <4 x float> %r
}

define <4 x i32> @FCVTZSv4s(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzs {d:4s}, {n:4s}" {
  %r = fptosi <4 x float> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @FCVTZUv4s(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzu {d:4s}, {n:4s}" {
  %r = fptoui <4 x float> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x float> @DUPf4s(float "reg"="s" %n) "feature"="neon" "enc"="0 1 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {d:4s}, {n:.s}[0]" {
  %i = insertelement <4 x float> poison, float %n, i64 0
  %r = shufflevector <4 x float> %i, <4 x float> poison, <4 x i32> zeroinitializer
  ret <4 x float> %r
}

define float @DUPes(<4 x float> "reg"="q" %n, i64 "imm" %idx) "feature"="neon" "enc"="01 0 11110000 imm5:5=idx*8+4 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.s}[{idx}]" {
  %r = extractelement <4 x float> %n, i64 %idx
  ret float %r
}

define <2 x double> @FADDv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 0 1 1 m:5 11010 1 n:5 d:5" "asm"="fadd {d:2d}, {n:2d}, {m:2d}" {
  %r = fadd <2 x double> %n, %m
  ret <2 x double> %r
}

define <2 x double> @FSUBv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 1 1 1 m:5 11010 1 n:5 d:5" "asm"="fsub {d:2d}, {n:2d}, {m:2d}" {
  %r = fsub <2 x double> %n, %m
  ret <2 x double> %r
}

define <2 x double> @FMULv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 1 1 m:5 11011 1 n:5 d:5" "asm"="fmul {d:2d}, {n:2d}, {m:2d}" {
  %r = fmul <2 x double> %n, %m
  ret <2 x double> %r
}

define <2 x double> @FDIVv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 1 1 m:5 11111 1 n:5 d:5" "asm"="fdiv {d:2d}, {n:2d}, {m:2d}" {
  %r = fdiv <2 x double> %n, %m
  ret <2 x double> %r
}

declare <2 x double> @llvm.fmuladd.v2f64(<2 x double>, <2 x double>, <2 x double>)

define <2 x double> @FMLAv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m, <2 x double> "reg"="q" "tied" %a) "feature"="neon" "enc"="0 1 0 01110 0 1 1 m:5 11001 1 n:5 d:5" "asm"="fmla {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x double> @llvm.fmuladd.v2f64(<2 x double> %n, <2 x double> %m, <2 x double> %a)
  ret <2 x double> %r
}

define <2 x double> @FNEGv2d(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 1 1 10000 01111 10 n:5 d:5" "asm"="fneg {d:2d}, {n:2d}" {
  %r = fneg <2 x double> %n
  ret <2 x double> %r
}

define <2 x i1> @FCMEQv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 0 1 1 m:5 11100 1 n:5 d:5" "asm"="fcmeq {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = fcmp oeq <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 1 1 m:5 11100 1 n:5 d:5" "asm"="fcmge {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = fcmp oge <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 1 1 1 m:5 11100 1 n:5 d:5" "asm"="fcmgt {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %r = fcmp ogt <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEsv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 0 1 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmge {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = fcmp ole <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTsv2d(<2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 1 1 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmgt {d:2d}, {m:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = fcmp olt <2 x double> %n, %m
  ret <2 x i1> %r
}

define <2 x double> @BSLv2df(<2 x i1> "reg"="q" "tied" %c, <2 x double> "reg"="q" %n, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:16b}, {n:16b}, {m:16b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x double> %n, <2 x double> %m
  ret <2 x double> %r
}

define <2 x double> @SCVTFv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 0 1 10000 11101 10 n:5 d:5" "asm"="scvtf {d:2d}, {n:2d}" {
  %r = sitofp <2 x i64> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @UCVTFv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 0 1 10000 11101 10 n:5 d:5" "asm"="ucvtf {d:2d}, {n:2d}" {
  %r = uitofp <2 x i64> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x i64> @FCVTZSv2d(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 1 1 10000 11011 10 n:5 d:5" "asm"="fcvtzs {d:2d}, {n:2d}" {
  %r = fptosi <2 x double> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @FCVTZUv2d(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 1 1 10000 11011 10 n:5 d:5" "asm"="fcvtzu {d:2d}, {n:2d}" {
  %r = fptoui <2 x double> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x double> @DUPf2d(double "reg"="d" %n) "feature"="neon" "enc"="0 1 0 01110000 01000 0 0000 1 n:5 d:5" "asm"="dup {d:2d}, {n:.d}[0]" {
  %i = insertelement <2 x double> poison, double %n, i64 0
  %r = shufflevector <2 x double> %i, <2 x double> poison, <2 x i32> zeroinitializer
  ret <2 x double> %r
}

define double @DUPed(<2 x double> "reg"="q" %n, i64 "imm" %idx) "feature"="neon" "enc"="01 0 11110000 imm5:5=idx*16+8 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[{idx}]" {
  %r = extractelement <2 x double> %n, i64 %idx
  ret double %r
}

define <2 x float> @FADDv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 0 0 1 m:5 11010 1 n:5 d:5" "asm"="fadd {d:2s}, {n:2s}, {m:2s}" {
  %r = fadd <2 x float> %n, %m
  ret <2 x float> %r
}

define <2 x float> @FSUBv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 1 0 1 m:5 11010 1 n:5 d:5" "asm"="fsub {d:2s}, {n:2s}, {m:2s}" {
  %r = fsub <2 x float> %n, %m
  ret <2 x float> %r
}

define <2 x float> @FMULv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 0 0 1 m:5 11011 1 n:5 d:5" "asm"="fmul {d:2s}, {n:2s}, {m:2s}" {
  %r = fmul <2 x float> %n, %m
  ret <2 x float> %r
}

define <2 x float> @FDIVv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 0 0 1 m:5 11111 1 n:5 d:5" "asm"="fdiv {d:2s}, {n:2s}, {m:2s}" {
  %r = fdiv <2 x float> %n, %m
  ret <2 x float> %r
}

declare <2 x float> @llvm.fmuladd.v2f32(<2 x float>, <2 x float>, <2 x float>)

define <2 x float> @FMLAv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m, <2 x float> "reg"="v" "tied" %a) "feature"="neon" "enc"="0 0 0 01110 0 0 1 m:5 11001 1 n:5 d:5" "asm"="fmla {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x float> @llvm.fmuladd.v2f32(<2 x float> %n, <2 x float> %m, <2 x float> %a)
  ret <2 x float> %r
}

define <2 x float> @FNEGv2s(<2 x float> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 1 0 10000 01111 10 n:5 d:5" "asm"="fneg {d:2s}, {n:2s}" {
  %r = fneg <2 x float> %n
  ret <2 x float> %r
}

define <2 x i1> @FCMEQv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmeq {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = fcmp oeq <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 0 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmge {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = fcmp oge <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 1 0 1 m:5 11100 1 n:5 d:5" "asm"="fcmgt {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %r = fcmp ogt <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGEsv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 0 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmge {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = fcmp ole <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @FCMGTsv2s(<2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 1 0 1 rm:5=n 11100 1 rn:5=m d:5" "asm"="fcmgt {d:2s}, {m:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = fcmp olt <2 x float> %n, %m
  ret <2 x i1> %r
}

define <2 x float> @BSLv2sf(<2 x i1> "reg"="q" "tied" %c, <2 x float> "reg"="v" %n, <2 x float> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {d:8b}, {n:8b}, {m:8b}" "nodecode" {
  %r = select <2 x i1> %c, <2 x float> %n, <2 x float> %m
  ret <2 x float> %r
}

define <2 x float> @SCVTFv2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 0 0 10000 11101 10 n:5 d:5" "asm"="scvtf {d:2s}, {n:2s}" {
  %r = sitofp <2 x i32> %n to <2 x float>
  ret <2 x float> %r
}

define <2 x float> @UCVTFv2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 0 0 10000 11101 10 n:5 d:5" "asm"="ucvtf {d:2s}, {n:2s}" {
  %r = uitofp <2 x i32> %n to <2 x float>
  ret <2 x float> %r
}

define <2 x i32> @FCVTZSv2s(<2 x float> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzs {d:2s}, {n:2s}" {
  %r = fptosi <2 x float> %n to <2 x i32>
  ret <2 x i32> %r
}

define <2 x i32> @FCVTZUv2s(<2 x float> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 1 0 10000 11011 10 n:5 d:5" "asm"="fcvtzu {d:2s}, {n:2s}" {
  %r = fptoui <2 x float> %n to <2 x i32>
  ret <2 x i32> %r
}

define <8 x i16> @SXTL8h(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 011110 0001000 10100 1 n:5 d:5" "asm"="sxtl {d:8h}, {n:8b}" {
  %r = sext <8 x i8> %n to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @SXTL28h(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 011110 0001000 10100 1 n:5 d:5" "asm"="sxtl2 {d:8h}, {n:16b}" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %r = sext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @UXTL8h(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 011110 0001000 10100 1 n:5 d:5" "asm"="uxtl {d:8h}, {n:8b}" {
  %r = zext <8 x i8> %n to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @UXTL28h(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 0001000 10100 1 n:5 d:5" "asm"="uxtl2 {d:8h}, {n:16b}" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %r = zext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i8> @XTN8b(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 00 10000 10010 10 n:5 d:5" "asm"="xtn {d:8b}, {n:8h}" {
  %r = trunc <8 x i16> %n to <8 x i8>
  ret <8 x i8> %r
}

define <16 x i8> @XTN216b(<8 x i8> "reg"="v" "tied" %lo, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 10000 10010 10 m:5 d:5" "asm"="xtn2 {d:16b}, {m:8h}" {
  %t = trunc <8 x i16> %m to <8 x i8>
  %r = shufflevector <8 x i8> %lo, <8 x i8> %t, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %r
}

define <4 x i32> @SXTL4s(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 011110 0010000 10100 1 n:5 d:5" "asm"="sxtl {d:4s}, {n:4h}" {
  %r = sext <4 x i16> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @SXTL24s(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 011110 0010000 10100 1 n:5 d:5" "asm"="sxtl2 {d:4s}, {n:8h}" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %r = sext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @UXTL4s(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 011110 0010000 10100 1 n:5 d:5" "asm"="uxtl {d:4s}, {n:4h}" {
  %r = zext <4 x i16> %n to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @UXTL24s(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 0010000 10100 1 n:5 d:5" "asm"="uxtl2 {d:4s}, {n:8h}" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %r = zext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i16> @XTN4h(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 01 10000 10010 10 n:5 d:5" "asm"="xtn {d:4h}, {n:4s}" {
  %r = trunc <4 x i32> %n to <4 x i16>
  ret <4 x i16> %r
}

define <8 x i16> @XTN28h(<4 x i16> "reg"="v" "tied" %lo, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 10000 10010 10 m:5 d:5" "asm"="xtn2 {d:8h}, {m:4s}" {
  %t = trunc <4 x i32> %m to <4 x i16>
  %r = shufflevector <4 x i16> %lo, <4 x i16> %t, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %r
}

define <2 x i64> @SXTL2d(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 011110 0100000 10100 1 n:5 d:5" "asm"="sxtl {d:2d}, {n:2s}" {
  %r = sext <2 x i32> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @SXTL22d(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 011110 0100000 10100 1 n:5 d:5" "asm"="sxtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %r = sext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @UXTL2d(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 011110 0100000 10100 1 n:5 d:5" "asm"="uxtl {d:2d}, {n:2s}" {
  %r = zext <2 x i32> %n to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @UXTL22d(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 011110 0100000 10100 1 n:5 d:5" "asm"="uxtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %r = zext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i32> @XTN2s(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 10 10000 10010 10 n:5 d:5" "asm"="xtn {d:2s}, {n:2d}" {
  %r = trunc <2 x i64> %n to <2 x i32>
  ret <2 x i32> %r
}

define <4 x i32> @XTN24s(<2 x i32> "reg"="v" "tied" %lo, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 10000 10010 10 m:5 d:5" "asm"="xtn2 {d:4s}, {m:2d}" {
  %t = trunc <2 x i64> %m to <2 x i32>
  %r = shufflevector <2 x i32> %lo, <2 x i32> %t, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %r
}

define <8 x i8> @LOW16x8(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i8> %r
}

define <8 x i8> @HIGH16x8(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <8 x i8> %r
}

define <16 x i8> @JOIN16x8(<8 x i8> "reg"="v" "tied" %lo, <8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <8 x i8> %lo, <8 x i8> %n, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %r
}

define <4 x i16> @LOW8x16(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i16> %r
}

define <4 x i16> @HIGH8x16(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  ret <4 x i16> %r
}

define <8 x i16> @JOIN8x16(<4 x i16> "reg"="v" "tied" %lo, <4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <4 x i16> %lo, <4 x i16> %n, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %r
}

define <2 x i32> @LOW4x32(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  ret <2 x i32> %r
}

define <2 x i32> @HIGH4x32(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  ret <2 x i32> %r
}

define <4 x i32> @JOIN4x32(<2 x i32> "reg"="v" "tied" %lo, <2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <2 x i32> %lo, <2 x i32> %n, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %r
}

define <1 x i64> @LOW2x64(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:8b}, {n:8b}" "nodecode" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <1 x i32> <i32 0>
  ret <1 x i64> %r
}

define <1 x i64> @HIGH2x64(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d}, {n:.d}[1]" "nodecode" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <1 x i32> <i32 1>
  ret <1 x i64> %r
}

define <2 x i64> @JOIN2x64(<1 x i64> "reg"="v" "tied" %lo, <1 x i64> "reg"="v" %n) "feature"="neon" "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {d:.d}[1], {n:.d}[0]" "nodecode" {
  %r = shufflevector <1 x i64> %lo, <1 x i64> %n, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %r
}

define <16 x i8> @ADDV16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 00 11000 11011 10 n:5 d:5" "asm"="addv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @SMAXV16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 00 11000 01010 10 n:5 d:5" "asm"="smaxv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @SMINV16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 00 11000 11010 10 n:5 d:5" "asm"="sminv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @UMAXV16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 11000 01010 10 n:5 d:5" "asm"="umaxv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <16 x i8> @UMINV16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 00 11000 11010 10 n:5 d:5" "asm"="uminv {d:b}, {n:16b}" "nomatch" {
  ret <16 x i8> %n
}

define <8 x i16> @ADDV8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 01 11000 11011 10 n:5 d:5" "asm"="addv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @SMAXV8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 01 11000 01010 10 n:5 d:5" "asm"="smaxv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @SMINV8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 01 11000 11010 10 n:5 d:5" "asm"="sminv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @UMAXV8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 01 11000 01010 10 n:5 d:5" "asm"="umaxv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <8 x i16> @UMINV8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 01 11000 11010 10 n:5 d:5" "asm"="uminv {d:h}, {n:8h}" "nomatch" {
  ret <8 x i16> %n
}

define <4 x i32> @ADDV4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 11000 11011 10 n:5 d:5" "asm"="addv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @SMAXV4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 11000 01010 10 n:5 d:5" "asm"="smaxv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @SMINV4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 11000 11010 10 n:5 d:5" "asm"="sminv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @UMAXV4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 10 11000 01010 10 n:5 d:5" "asm"="umaxv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <4 x i32> @UMINV4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 1 01110 10 11000 11010 10 n:5 d:5" "asm"="uminv {d:s}, {n:4s}" "nomatch" {
  ret <4 x i32> %n
}

define <2 x i64> @ADDPd(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="01 0 11110 11 11000 11011 10 n:5 d:5" "asm"="addp {d:d}, {n:2d}" "nomatch" {
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

define <16 x i8> @LDRQui.16xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.q" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <16 x i8>, ptr %p
  ret <16 x i8> %v
}

define void @STRQui.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.q" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <16 x i8> %t, ptr %p
  ret void
}

define <16 x i8> @LDURQ.16xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <16 x i8>, ptr %p
  ret <16 x i8> %v
}

define void @STURQ.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <16 x i8> %t, ptr %p
  ret void
}

define <16 x i8> @LDRQroX.16xi8(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <16 x i8>, ptr %p
  ret <16 x i8> %v
}

define void @STRQroX.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <16 x i8> %t, ptr %p
  ret void
}

define { <16 x i8>, ptr } @LDRQpost.16xi8(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load <16 x i8>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <16 x i8>, ptr } poison, <16 x i8> %v, 0
  %b = insertvalue { <16 x i8>, ptr } %a, ptr %next, 1
  ret { <16 x i8>, ptr } %b
}

define ptr @STRQpost.16xi8(<16 x i8> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store <16 x i8> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <8 x i16> @LDRQui.8xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i16>, ptr %p
  ret <8 x i16> %v
}

define void @STRQui.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i16> %t, ptr %p
  ret void
}

define <8 x i16> @LDURQ.8xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i16>, ptr %p
  ret <8 x i16> %v
}

define void @STURQ.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i16> %t, ptr %p
  ret void
}

define <8 x i16> @LDRQroX.8xi16(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <8 x i16>, ptr %p
  ret <8 x i16> %v
}

define void @STRQroX.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <8 x i16> %t, ptr %p
  ret void
}

define { <8 x i16>, ptr } @LDRQpost.8xi16(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <8 x i16>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <8 x i16>, ptr } poison, <8 x i16> %v, 0
  %b = insertvalue { <8 x i16>, ptr } %a, ptr %next, 1
  ret { <8 x i16>, ptr } %b
}

define ptr @STRQpost.8xi16(<8 x i16> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <8 x i16> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <4 x i32> @LDRQui.4xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i32>, ptr %p
  ret <4 x i32> %v
}

define void @STRQui.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i32> %t, ptr %p
  ret void
}

define <4 x i32> @LDURQ.4xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i32>, ptr %p
  ret <4 x i32> %v
}

define void @STURQ.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i32> %t, ptr %p
  ret void
}

define <4 x i32> @LDRQroX.4xi32(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <4 x i32>, ptr %p
  ret <4 x i32> %v
}

define void @STRQroX.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <4 x i32> %t, ptr %p
  ret void
}

define { <4 x i32>, ptr } @LDRQpost.4xi32(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <4 x i32>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <4 x i32>, ptr } poison, <4 x i32> %v, 0
  %b = insertvalue { <4 x i32>, ptr } %a, ptr %next, 1
  ret { <4 x i32>, ptr } %b
}

define ptr @STRQpost.4xi32(<4 x i32> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <4 x i32> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x i64> @LDRQui.2xi64(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i64>, ptr %p
  ret <2 x i64> %v
}

define void @STRQui.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i64> %t, ptr %p
  ret void
}

define <2 x i64> @LDURQ.2xi64(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i64>, ptr %p
  ret <2 x i64> %v
}

define void @STURQ.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i64> %t, ptr %p
  ret void
}

define <2 x i64> @LDRQroX.2xi64(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x i64>, ptr %p
  ret <2 x i64> %v
}

define void @STRQroX.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x i64> %t, ptr %p
  ret void
}

define { <2 x i64>, ptr } @LDRQpost.2xi64(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x i64>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x i64>, ptr } poison, <2 x i64> %v, 0
  %b = insertvalue { <2 x i64>, ptr } %a, ptr %next, 1
  ret { <2 x i64>, ptr } %b
}

define ptr @STRQpost.2xi64(<2 x i64> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x i64> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <4 x float> @LDRQui.4xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x float>, ptr %p
  ret <4 x float> %v
}

define void @STRQui.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x float> %t, ptr %p
  ret void
}

define <4 x float> @LDURQ.4xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x float>, ptr %p
  ret <4 x float> %v
}

define void @STURQ.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x float> %t, ptr %p
  ret void
}

define <4 x float> @LDRQroX.4xfloat(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <4 x float>, ptr %p
  ret <4 x float> %v
}

define void @STRQroX.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <4 x float> %t, ptr %p
  ret void
}

define { <4 x float>, ptr } @LDRQpost.4xfloat(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <4 x float>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <4 x float>, ptr } poison, <4 x float> %v, 0
  %b = insertvalue { <4 x float>, ptr } %a, ptr %next, 1
  ret { <4 x float>, ptr } %b
}

define ptr @STRQpost.4xfloat(<4 x float> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <4 x float> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x double> @LDRQui.2xdouble(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 11 imm12:12=off/16 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x double>, ptr %p
  ret <2 x double> %v
}

define void @STRQui.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 01 10 imm12:12=off/16 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x double> %t, ptr %p
  ret void
}

define <2 x double> @LDURQ.2xdouble(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x double>, ptr %p
  ret <2 x double> %v
}

define void @STURQ.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x double> %t, ptr %p
  ret void
}

define <2 x double> @LDRQroX.2xdouble(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x double>, ptr %p
  ret <2 x double> %v
}

define void @STRQroX.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="00 111 1 00 10 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #4]" "nodecode" {
  %o = shl i64 %m, 4
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x double> %t, ptr %p
  ret void
}

define { <2 x double>, ptr } @LDRQpost.2xdouble(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 11 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x double>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x double>, ptr } poison, <2 x double> %v, 0
  %b = insertvalue { <2 x double>, ptr } %a, ptr %next, 1
  ret { <2 x double>, ptr } %b
}

define ptr @STRQpost.2xdouble(<2 x double> "reg"="q" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="00 111 1 00 10 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x double> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <8 x i8> @LDRDui.8xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i8>, ptr %p
  ret <8 x i8> %v
}

define void @STRDui.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i8> %t, ptr %p
  ret void
}

define <8 x i8> @LDURD.8xi8(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <8 x i8>, ptr %p
  ret <8 x i8> %v
}

define void @STURD.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <8 x i8> %t, ptr %p
  ret void
}

define <8 x i8> @LDRDroX.8xi8(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <8 x i8>, ptr %p
  ret <8 x i8> %v
}

define void @STRDroX.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <8 x i8> %t, ptr %p
  ret void
}

define { <8 x i8>, ptr } @LDRDpost.8xi8(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load <8 x i8>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <8 x i8>, ptr } poison, <8 x i8> %v, 0
  %b = insertvalue { <8 x i8>, ptr } %a, ptr %next, 1
  ret { <8 x i8>, ptr } %b
}

define ptr @STRDpost.8xi8(<8 x i8> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store <8 x i8> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <4 x i16> @LDRDui.4xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i16>, ptr %p
  ret <4 x i16> %v
}

define void @STRDui.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i16> %t, ptr %p
  ret void
}

define <4 x i16> @LDURD.4xi16(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <4 x i16>, ptr %p
  ret <4 x i16> %v
}

define void @STURD.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <4 x i16> %t, ptr %p
  ret void
}

define <4 x i16> @LDRDroX.4xi16(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <4 x i16>, ptr %p
  ret <4 x i16> %v
}

define void @STRDroX.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <4 x i16> %t, ptr %p
  ret void
}

define { <4 x i16>, ptr } @LDRDpost.4xi16(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <4 x i16>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <4 x i16>, ptr } poison, <4 x i16> %v, 0
  %b = insertvalue { <4 x i16>, ptr } %a, ptr %next, 1
  ret { <4 x i16>, ptr } %b
}

define ptr @STRDpost.4xi16(<4 x i16> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <4 x i16> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x i32> @LDRDui.2xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i32>, ptr %p
  ret <2 x i32> %v
}

define void @STRDui.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i32> %t, ptr %p
  ret void
}

define <2 x i32> @LDURD.2xi32(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x i32>, ptr %p
  ret <2 x i32> %v
}

define void @STURD.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i32> %t, ptr %p
  ret void
}

define <2 x i32> @LDRDroX.2xi32(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x i32>, ptr %p
  ret <2 x i32> %v
}

define void @STRDroX.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x i32> %t, ptr %p
  ret void
}

define { <2 x i32>, ptr } @LDRDpost.2xi32(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x i32>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x i32>, ptr } poison, <2 x i32> %v, 0
  %b = insertvalue { <2 x i32>, ptr } %a, ptr %next, 1
  ret { <2 x i32>, ptr } %b
}

define ptr @STRDpost.2xi32(<2 x i32> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x i32> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x float> @LDRDui.2xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x float>, ptr %p
  ret <2 x float> %v
}

define void @STRDui.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x float> %t, ptr %p
  ret void
}

define <2 x float> @LDURD.2xfloat(ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load <2 x float>, ptr %p
  ret <2 x float> %v
}

define void @STURD.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x float> %t, ptr %p
  ret void
}

define <2 x float> @LDRDroX.2xfloat(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load <2 x float>, ptr %p
  ret <2 x float> %v
}

define void @STRDroX.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="neon" "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store <2 x float> %t, ptr %p
  ret void
}

define { <2 x float>, ptr } @LDRDpost.2xfloat(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load <2 x float>, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { <2 x float>, ptr } poison, <2 x float> %v, 0
  %b = insertvalue { <2 x float>, ptr } %a, ptr %next, 1
  ret { <2 x float>, ptr } %b
}

define ptr @STRDpost.2xfloat(<2 x float> "reg"="v" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "feature"="neon" "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store <2 x float> %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define <2 x i64> @MOVIzero() "feature"="neon" "enc"="0 1 1 0111100000 000 1110 01 00000 d:5" "asm"="movi {d:2d}, #0" "role"="movi.zero" "nomatch" {
  ret <2 x i64> zeroinitializer
}

define <2 x i64> @MOVq(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:16b}, {n:16b}" "copy"="q" "nomatch" {
  ret <2 x i64> %n
}
define i8 @UMOVb64(<8 x i8> "reg"="v" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 0 0 01110000 imm5:5=idx*2+1 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.b}[{idx}]" "nodecode" {
  %r = extractelement <8 x i8> %n, i64 %idx
  ret i8 %r
}

define <8 x i8> @INSb64(<8 x i8> "reg"="v" "tied" %old, i8 "reg"="w" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*2+1 0 0011 1 n:5 d:5" "asm"="mov {d:.b}[{idx}], {n}" "nodecode" {
  %r = insertelement <8 x i8> %old, i8 %n, i64 %idx
  ret <8 x i8> %r
}

define i16 @UMOVh64(<4 x i16> "reg"="v" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 0 0 01110000 imm5:5=idx*4+2 0 0111 1 n:5 d:5" "asm"="umov {d}, {n:.h}[{idx}]" "nodecode" {
  %r = extractelement <4 x i16> %n, i64 %idx
  ret i16 %r
}

define <4 x i16> @INSh64(<4 x i16> "reg"="v" "tied" %old, i16 "reg"="w" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*4+2 0 0011 1 n:5 d:5" "asm"="mov {d:.h}[{idx}], {n}" "nodecode" {
  %r = insertelement <4 x i16> %old, i16 %n, i64 %idx
  ret <4 x i16> %r
}

define i32 @UMOVs64(<2 x i32> "reg"="v" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 0 0 01110000 imm5:5=idx*8+4 0 0111 1 n:5 d:5" "asm"="mov {d}, {n:.s}[{idx}]" "nodecode" {
  %r = extractelement <2 x i32> %n, i64 %idx
  ret i32 %r
}

define <2 x i32> @INSs64(<2 x i32> "reg"="v" "tied" %old, i32 "reg"="w" %n, i64 "imm" %idx) "feature"="neon" "enc"="0 1 0 01110000 imm5:5=idx*8+4 0 0011 1 n:5 d:5" "asm"="mov {d:.s}[{idx}], {n}" "nodecode" {
  %r = insertelement <2 x i32> %old, i32 %n, i64 %idx
  ret <2 x i32> %r
}

define <8 x i16> @SXTLlo8h(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 011110 0001000 10100 1 n:5 d:5" "asm"="sxtl {d:8h}, {n:8b}" "nodecode" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %r = sext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @UXTLlo8h(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 011110 0001000 10100 1 n:5 d:5" "asm"="uxtl {d:8h}, {n:8b}" "nodecode" {
  %h = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %r = zext <8 x i8> %h to <8 x i16>
  ret <8 x i16> %r
}

define <8 x i16> @SMULLv8h(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:8h}, {n:8b}, {m:8b}" {
  %a = sext <8 x i8> %n to <8 x i16>
  %b = sext <8 x i8> %m to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @SMULLlo8h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:8h}, {n:8b}, {m:8b}" "nodecode" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %a = sext <8 x i8> %hn to <8 x i16>
  %b = sext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @SMULL28h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="smull2 {d:8h}, {n:16b}, {m:16b}" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %a = sext <8 x i8> %hn to <8 x i16>
  %b = sext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @UMULLv8h(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:8h}, {n:8b}, {m:8b}" {
  %a = zext <8 x i8> %n to <8 x i16>
  %b = zext <8 x i8> %m to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @UMULLlo8h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:8h}, {n:8b}, {m:8b}" "nodecode" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %a = zext <8 x i8> %hn to <8 x i16>
  %b = zext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <8 x i16> @UMULL28h(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 1100 00 n:5 d:5" "asm"="umull2 {d:8h}, {n:16b}, {m:16b}" {
  %hn = shufflevector <16 x i8> %n, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %hm = shufflevector <16 x i8> %m, <16 x i8> poison, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %a = zext <8 x i8> %hn to <8 x i16>
  %b = zext <8 x i8> %hm to <8 x i16>
  %r = mul <8 x i16> %a, %b
  ret <8 x i16> %r
}

define <4 x i32> @SXTLlo4s(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 011110 0010000 10100 1 n:5 d:5" "asm"="sxtl {d:4s}, {n:4h}" "nodecode" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %r = sext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @UXTLlo4s(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 011110 0010000 10100 1 n:5 d:5" "asm"="uxtl {d:4s}, {n:4h}" "nodecode" {
  %h = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %r = zext <4 x i16> %h to <4 x i32>
  ret <4 x i32> %r
}

define <4 x i32> @SMULLv4s(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:4s}, {n:4h}, {m:4h}" {
  %a = sext <4 x i16> %n to <4 x i32>
  %b = sext <4 x i16> %m to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @SMULLlo4s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:4s}, {n:4h}, {m:4h}" "nodecode" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %a = sext <4 x i16> %hn to <4 x i32>
  %b = sext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @SMULL24s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="smull2 {d:4s}, {n:8h}, {m:8h}" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %a = sext <4 x i16> %hn to <4 x i32>
  %b = sext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @UMULLv4s(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:4s}, {n:4h}, {m:4h}" {
  %a = zext <4 x i16> %n to <4 x i32>
  %b = zext <4 x i16> %m to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @UMULLlo4s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:4s}, {n:4h}, {m:4h}" "nodecode" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %a = zext <4 x i16> %hn to <4 x i32>
  %b = zext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <4 x i32> @UMULL24s(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 1100 00 n:5 d:5" "asm"="umull2 {d:4s}, {n:8h}, {m:8h}" {
  %hn = shufflevector <8 x i16> %n, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %hm = shufflevector <8 x i16> %m, <8 x i16> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %a = zext <4 x i16> %hn to <4 x i32>
  %b = zext <4 x i16> %hm to <4 x i32>
  %r = mul <4 x i32> %a, %b
  ret <4 x i32> %r
}

define <2 x i64> @SXTLlo2d(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 011110 0100000 10100 1 n:5 d:5" "asm"="sxtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %r = sext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @UXTLlo2d(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 011110 0100000 10100 1 n:5 d:5" "asm"="uxtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %r = zext <2 x i32> %h to <2 x i64>
  ret <2 x i64> %r
}

define <2 x i64> @SMULLv2d(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:2d}, {n:2s}, {m:2s}" {
  %a = sext <2 x i32> %n to <2 x i64>
  %b = sext <2 x i32> %m to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @SMULLlo2d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="smull {d:2d}, {n:2s}, {m:2s}" "nodecode" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %a = sext <2 x i32> %hn to <2 x i64>
  %b = sext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @SMULL22d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="smull2 {d:2d}, {n:4s}, {m:4s}" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %a = sext <2 x i32> %hn to <2 x i64>
  %b = sext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @UMULLv2d(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:2d}, {n:2s}, {m:2s}" {
  %a = zext <2 x i32> %n to <2 x i64>
  %b = zext <2 x i32> %m to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @UMULLlo2d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="umull {d:2d}, {n:2s}, {m:2s}" "nodecode" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  %a = zext <2 x i32> %hn to <2 x i64>
  %b = zext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}

define <2 x i64> @UMULL22d(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 1100 00 n:5 d:5" "asm"="umull2 {d:2d}, {n:4s}, {m:4s}" {
  %hn = shufflevector <4 x i32> %n, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %hm = shufflevector <4 x i32> %m, <4 x i32> poison, <2 x i32> <i32 2, i32 3>
  %a = zext <2 x i32> %hn to <2 x i64>
  %b = zext <2 x i32> %hm to <2 x i64>
  %r = mul <2 x i64> %a, %b
  ret <2 x i64> %r
}
define <2 x i32> @ADDPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:2s}, {n:2s}, {m:2s}" "nomatch" {
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

; Population counts: the bits set in each byte. A scalar's count is the
; bytes' counts summed (60-recipes.ll).
declare <8 x i8> @llvm.ctpop.v8i8(<8 x i8>)

define <8 x i8> @CNT8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 10000 00101 10 n:5 d:5" "asm"="cnt {d:8b}, {n:8b}" {
  %r = call <8 x i8> @llvm.ctpop.v8i8(<8 x i8> %n)
  ret <8 x i8> %r
}

; A general register's bits into the low half of a vector register (the
; rest zero), as fmov d, x and fmov s, w do.
define <8 x i8> @FMOVvX(i64 "reg"="x" %n) "feature"="neon" "enc"="1 00 11110 01 1 00 111 000000 n:5 d:5" "asm"="fmov {d:d}, {n}" "nodecode" {
  %r = bitcast i64 %n to <8 x i8>
  ret <8 x i8> %r
}

define <8 x i8> @FMOVvW(i32 "reg"="w" %n) "feature"="neon" "enc"="0 00 11110 00 1 00 111 000000 n:5 d:5" "asm"="fmov {d:s}, {n}" "nodecode" {
  %z = zext i32 %n to i64
  %r = bitcast i64 %z to <8 x i8>
  ret <8 x i8> %r
}

; And back: a 64-bit vector's bits into a general register.
define i64 @FMOVXv(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="1 00 11110 01 1 00 110 000000 n:5 d:5" "asm"="fmov {d}, {n:d}" "nodecode" {
  %r = bitcast <8 x i8> %n to i64
  ret i64 %r
}

define <8 x i8> @ADDV8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 11000 11011 10 n:5 d:5" "asm"="addv {d:b}, {n:8b}" "nomatch" {
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

define <8 x i8> @SMAXV8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 11000 01010 10 n:5 d:5" "asm"="smaxv {d:b}, {n:8b}" "nomatch" {
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

define <8 x i8> @SMINV8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 11000 11010 10 n:5 d:5" "asm"="sminv {d:b}, {n:8b}" "nomatch" {
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

define <8 x i8> @UMAXV8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 00 11000 01010 10 n:5 d:5" "asm"="umaxv {d:b}, {n:8b}" "nomatch" {
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

define <8 x i8> @UMINV8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 00 11000 11010 10 n:5 d:5" "asm"="uminv {d:b}, {n:8b}" "nomatch" {
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

define <4 x i16> @ADDV4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 01 11000 11011 10 n:5 d:5" "asm"="addv {d:h}, {n:4h}" "nomatch" {
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

define <4 x i16> @SMAXV4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 01 11000 01010 10 n:5 d:5" "asm"="smaxv {d:h}, {n:4h}" "nomatch" {
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

define <4 x i16> @SMINV4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 01 11000 11010 10 n:5 d:5" "asm"="sminv {d:h}, {n:4h}" "nomatch" {
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

define <4 x i16> @UMAXV4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 01 11000 01010 10 n:5 d:5" "asm"="umaxv {d:h}, {n:4h}" "nomatch" {
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

define <4 x i16> @UMINV4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 1 01110 01 11000 11010 10 n:5 d:5" "asm"="uminv {d:h}, {n:4h}" "nomatch" {
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

define <2 x double> @FCVTL2d(<2 x float> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl {d:2d}, {n:2s}" {
  %r = fpext <2 x float> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @FCVTLlo2d(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x float> %n, <4 x float> poison, <2 x i32> <i32 0, i32 1>
  %r = fpext <2 x float> %h to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @FCVTL22d(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x float> %n, <4 x float> poison, <2 x i32> <i32 2, i32 3>
  %r = fpext <2 x float> %h to <2 x double>
  ret <2 x double> %r
}

define <2 x float> @FCVTN2s(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 0 0 01110 0 1 10000 10110 10 n:5 d:5" "asm"="fcvtn {d:2s}, {n:2d}" {
  %r = fptrunc <2 x double> %n to <2 x float>
  ret <2 x float> %r
}

define <4 x float> @FCVTN24s(<2 x float> "reg"="v" "tied" %lo, <2 x double> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 0 1 10000 10110 10 m:5 d:5" "asm"="fcvtn2 {d:4s}, {m:2d}" {
  %t = fptrunc <2 x double> %m to <2 x float>
  %r = shufflevector <2 x float> %lo, <2 x float> %t, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x float> %r
}
define <16 x i8> @REV64v16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 00 10000 00000 10 n:5 d:5" "asm"="rev64 {d:16b}, {n:16b}" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <16 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0, i32 15, i32 14, i32 13, i32 12, i32 11, i32 10, i32 9, i32 8>
  ret <16 x i8> %r
}

define <8 x i16> @REV64v8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 01 10000 00000 10 n:5 d:5" "asm"="rev64 {d:8h}, {n:8h}" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <8 x i32> <i32 3, i32 2, i32 1, i32 0, i32 7, i32 6, i32 5, i32 4>
  ret <8 x i16> %r
}

define <4 x i32> @REV64v4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:4s}, {n:4s}" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  ret <4 x i32> %r
}

define <2 x i64> @SWAPv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 10 1110 00 0 rm:5=n 0 1000 0 n:5 d:5" "asm"="ext {d:16b}, {n:16b}, {n:16b}, #8" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x i64> %r
}

define <8 x i8> @REV64v8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 10000 00000 10 n:5 d:5" "asm"="rev64 {d:8b}, {n:8b}" {
  %r = shufflevector <8 x i8> %n, <8 x i8> poison, <8 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0>
  ret <8 x i8> %r
}

define <4 x i16> @REV64v4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 01 10000 00000 10 n:5 d:5" "asm"="rev64 {d:4h}, {n:4h}" {
  %r = shufflevector <4 x i16> %n, <4 x i16> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  ret <4 x i16> %r
}

define <2 x i32> @REV64v2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:2s}, {n:2s}" {
  %r = shufflevector <2 x i32> %n, <2 x i32> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x i32> %r
}

define <4 x float> @REV64v4sf(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:4s}, {n:4s}" "nodecode" {
  %r = shufflevector <4 x float> %n, <4 x float> poison, <4 x i32> <i32 1, i32 0, i32 3, i32 2>
  ret <4 x float> %r
}

define <2 x double> @SWAPv2df(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 1 10 1110 00 0 rm:5=n 0 1000 0 n:5 d:5" "asm"="ext {d:16b}, {n:16b}, {n:16b}, #8" "nodecode" {
  %r = shufflevector <2 x double> %n, <2 x double> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x double> %r
}

define <2 x float> @REV64v2sf(<2 x float> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 10 10000 00000 10 n:5 d:5" "asm"="rev64 {d:2s}, {n:2s}" "nodecode" {
  %r = shufflevector <2 x float> %n, <2 x float> poison, <2 x i32> <i32 1, i32 0>
  ret <2 x float> %r
}
define <16 x i1> @CMTSTv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:16b}, {n:16b}, {m:16b}" "dclass"="q" {
  %a = and <16 x i8> %n, %m
  %r = icmp ne <16 x i8> %a, zeroinitializer
  ret <16 x i1> %r
}

define <16 x i1> @CMNEZv16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 00 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:16b}, {n:16b}, {n:16b}" "dclass"="q" "nodecode" {
  %r = icmp ne <16 x i8> %n, zeroinitializer
  ret <16 x i1> %r
}

declare <16 x i8> @llvm.aarch64.neon.ushl.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @USHLv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.ushl.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.neon.sshl.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SSHLv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.sshl.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

define <16 x i8> @shl.v16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "recipe"="shl.v16b.expand" {
  %r = shl <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @shl.v16b.expand(<16 x i8> %n, <16 x i8> %m) {
  %r = call <16 x i8> @USHLv16b(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

define <16 x i8> @lshr.v16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "recipe"="lshr.v16b.expand" {
  %r = lshr <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @lshr.v16b.expand(<16 x i8> %n, <16 x i8> %m) {
  %neg = call <16 x i8> @NEGv16b(<16 x i8> %m)
  %r = call <16 x i8> @USHLv16b(<16 x i8> %n, <16 x i8> %neg)
  ret <16 x i8> %r
}

define <16 x i8> @ashr.v16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "recipe"="ashr.v16b.expand" {
  %r = ashr <16 x i8> %n, %m
  ret <16 x i8> %r
}

define <16 x i8> @ashr.v16b.expand(<16 x i8> %n, <16 x i8> %m) {
  %neg = call <16 x i8> @NEGv16b(<16 x i8> %m)
  %r = call <16 x i8> @SSHLv16b(<16 x i8> %n, <16 x i8> %neg)
  ret <16 x i8> %r
}

define <8 x i1> @CMTSTv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:8h}, {n:8h}, {m:8h}" "dclass"="q" {
  %a = and <8 x i16> %n, %m
  %r = icmp ne <8 x i16> %a, zeroinitializer
  ret <8 x i1> %r
}

define <8 x i1> @CMNEZv8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 01 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:8h}, {n:8h}, {n:8h}" "dclass"="q" "nodecode" {
  %r = icmp ne <8 x i16> %n, zeroinitializer
  ret <8 x i1> %r
}

declare <8 x i16> @llvm.aarch64.neon.ushl.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @USHLv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.ushl.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.sshl.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SSHLv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.sshl.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

define <8 x i16> @shl.v8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "recipe"="shl.v8h.expand" {
  %r = shl <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @shl.v8h.expand(<8 x i16> %n, <8 x i16> %m) {
  %r = call <8 x i16> @USHLv8h(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

define <8 x i16> @lshr.v8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "recipe"="lshr.v8h.expand" {
  %r = lshr <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @lshr.v8h.expand(<8 x i16> %n, <8 x i16> %m) {
  %neg = call <8 x i16> @NEGv8h(<8 x i16> %m)
  %r = call <8 x i16> @USHLv8h(<8 x i16> %n, <8 x i16> %neg)
  ret <8 x i16> %r
}

define <8 x i16> @ashr.v8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "recipe"="ashr.v8h.expand" {
  %r = ashr <8 x i16> %n, %m
  ret <8 x i16> %r
}

define <8 x i16> @ashr.v8h.expand(<8 x i16> %n, <8 x i16> %m) {
  %neg = call <8 x i16> @NEGv8h(<8 x i16> %m)
  %r = call <8 x i16> @SSHLv8h(<8 x i16> %n, <8 x i16> %neg)
  ret <8 x i16> %r
}

define <4 x i1> @CMTSTv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:4s}, {n:4s}, {m:4s}" "dclass"="q" {
  %a = and <4 x i32> %n, %m
  %r = icmp ne <4 x i32> %a, zeroinitializer
  ret <4 x i1> %r
}

define <4 x i1> @CMNEZv4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 10 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:4s}, {n:4s}, {n:4s}" "dclass"="q" "nodecode" {
  %r = icmp ne <4 x i32> %n, zeroinitializer
  ret <4 x i1> %r
}

declare <4 x i32> @llvm.aarch64.neon.ushl.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @USHLv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.ushl.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.sshl.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SSHLv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.sshl.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @shl.v4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "recipe"="shl.v4s.expand" {
  %r = shl <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @shl.v4s.expand(<4 x i32> %n, <4 x i32> %m) {
  %r = call <4 x i32> @USHLv4s(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @lshr.v4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "recipe"="lshr.v4s.expand" {
  %r = lshr <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @lshr.v4s.expand(<4 x i32> %n, <4 x i32> %m) {
  %neg = call <4 x i32> @NEGv4s(<4 x i32> %m)
  %r = call <4 x i32> @USHLv4s(<4 x i32> %n, <4 x i32> %neg)
  ret <4 x i32> %r
}

define <4 x i32> @ashr.v4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "recipe"="ashr.v4s.expand" {
  %r = ashr <4 x i32> %n, %m
  ret <4 x i32> %r
}

define <4 x i32> @ashr.v4s.expand(<4 x i32> %n, <4 x i32> %m) {
  %neg = call <4 x i32> @NEGv4s(<4 x i32> %m)
  %r = call <4 x i32> @SSHLv4s(<4 x i32> %n, <4 x i32> %neg)
  ret <4 x i32> %r
}

define <2 x i1> @CMTSTv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:2d}, {n:2d}, {m:2d}" "dclass"="q" {
  %a = and <2 x i64> %n, %m
  %r = icmp ne <2 x i64> %a, zeroinitializer
  ret <2 x i1> %r
}

define <2 x i1> @CMNEZv2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110 11 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:2d}, {n:2d}, {n:2d}" "dclass"="q" "nodecode" {
  %r = icmp ne <2 x i64> %n, zeroinitializer
  ret <2 x i1> %r
}

declare <2 x i64> @llvm.aarch64.neon.ushl.v2i64(<2 x i64>, <2 x i64>)

define <2 x i64> @USHLv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 11 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.neon.ushl.v2i64(<2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.aarch64.neon.sshl.v2i64(<2 x i64>, <2 x i64>)

define <2 x i64> @SSHLv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.neon.sshl.v2i64(<2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

define <2 x i64> @shl.v2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "recipe"="shl.v2d.expand" {
  %r = shl <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @shl.v2d.expand(<2 x i64> %n, <2 x i64> %m) {
  %r = call <2 x i64> @USHLv2d(<2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

define <2 x i64> @lshr.v2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "recipe"="lshr.v2d.expand" {
  %r = lshr <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @lshr.v2d.expand(<2 x i64> %n, <2 x i64> %m) {
  %neg = call <2 x i64> @NEGv2d(<2 x i64> %m)
  %r = call <2 x i64> @USHLv2d(<2 x i64> %n, <2 x i64> %neg)
  ret <2 x i64> %r
}

define <2 x i64> @ashr.v2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "recipe"="ashr.v2d.expand" {
  %r = ashr <2 x i64> %n, %m
  ret <2 x i64> %r
}

define <2 x i64> @ashr.v2d.expand(<2 x i64> %n, <2 x i64> %m) {
  %neg = call <2 x i64> @NEGv2d(<2 x i64> %m)
  %r = call <2 x i64> @SSHLv2d(<2 x i64> %n, <2 x i64> %neg)
  ret <2 x i64> %r
}

define <8 x i1> @CMTSTv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:8b}, {n:8b}, {m:8b}" "dclass"="q" {
  %a = and <8 x i8> %n, %m
  %r = icmp ne <8 x i8> %a, zeroinitializer
  ret <8 x i1> %r
}

define <8 x i1> @CMNEZv8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 00 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:8b}, {n:8b}, {n:8b}" "dclass"="q" "nodecode" {
  %r = icmp ne <8 x i8> %n, zeroinitializer
  ret <8 x i1> %r
}

declare <8 x i8> @llvm.aarch64.neon.ushl.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @USHLv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.ushl.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.sshl.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SSHLv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.sshl.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

define <8 x i8> @shl.v8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "recipe"="shl.v8b.expand" {
  %r = shl <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @shl.v8b.expand(<8 x i8> %n, <8 x i8> %m) {
  %r = call <8 x i8> @USHLv8b(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

define <8 x i8> @lshr.v8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "recipe"="lshr.v8b.expand" {
  %r = lshr <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @lshr.v8b.expand(<8 x i8> %n, <8 x i8> %m) {
  %neg = call <8 x i8> @NEGv8b(<8 x i8> %m)
  %r = call <8 x i8> @USHLv8b(<8 x i8> %n, <8 x i8> %neg)
  ret <8 x i8> %r
}

define <8 x i8> @ashr.v8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "recipe"="ashr.v8b.expand" {
  %r = ashr <8 x i8> %n, %m
  ret <8 x i8> %r
}

define <8 x i8> @ashr.v8b.expand(<8 x i8> %n, <8 x i8> %m) {
  %neg = call <8 x i8> @NEGv8b(<8 x i8> %m)
  %r = call <8 x i8> @SSHLv8b(<8 x i8> %n, <8 x i8> %neg)
  ret <8 x i8> %r
}

define <4 x i1> @CMTSTv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:4h}, {n:4h}, {m:4h}" "dclass"="q" {
  %a = and <4 x i16> %n, %m
  %r = icmp ne <4 x i16> %a, zeroinitializer
  ret <4 x i1> %r
}

define <4 x i1> @CMNEZv4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 01 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:4h}, {n:4h}, {n:4h}" "dclass"="q" "nodecode" {
  %r = icmp ne <4 x i16> %n, zeroinitializer
  ret <4 x i1> %r
}

declare <4 x i16> @llvm.aarch64.neon.ushl.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @USHLv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.ushl.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.sshl.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SSHLv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.sshl.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

define <4 x i16> @shl.v4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "recipe"="shl.v4h.expand" {
  %r = shl <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @shl.v4h.expand(<4 x i16> %n, <4 x i16> %m) {
  %r = call <4 x i16> @USHLv4h(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

define <4 x i16> @lshr.v4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "recipe"="lshr.v4h.expand" {
  %r = lshr <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @lshr.v4h.expand(<4 x i16> %n, <4 x i16> %m) {
  %neg = call <4 x i16> @NEGv4h(<4 x i16> %m)
  %r = call <4 x i16> @USHLv4h(<4 x i16> %n, <4 x i16> %neg)
  ret <4 x i16> %r
}

define <4 x i16> @ashr.v4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "recipe"="ashr.v4h.expand" {
  %r = ashr <4 x i16> %n, %m
  ret <4 x i16> %r
}

define <4 x i16> @ashr.v4h.expand(<4 x i16> %n, <4 x i16> %m) {
  %neg = call <4 x i16> @NEGv4h(<4 x i16> %m)
  %r = call <4 x i16> @SSHLv4h(<4 x i16> %n, <4 x i16> %neg)
  ret <4 x i16> %r
}

define <2 x i1> @CMTSTv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {d:2s}, {n:2s}, {m:2s}" "dclass"="q" {
  %a = and <2 x i32> %n, %m
  %r = icmp ne <2 x i32> %a, zeroinitializer
  ret <2 x i1> %r
}

define <2 x i1> @CMNEZv2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110 10 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {d:2s}, {n:2s}, {n:2s}" "dclass"="q" "nodecode" {
  %r = icmp ne <2 x i32> %n, zeroinitializer
  ret <2 x i1> %r
}

declare <2 x i32> @llvm.aarch64.neon.ushl.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @USHLv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="ushl {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.ushl.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.sshl.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SSHLv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 01000 1 n:5 d:5" "asm"="sshl {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.sshl.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

define <2 x i32> @shl.v2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "recipe"="shl.v2s.expand" {
  %r = shl <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @shl.v2s.expand(<2 x i32> %n, <2 x i32> %m) {
  %r = call <2 x i32> @USHLv2s(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

define <2 x i32> @lshr.v2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "recipe"="lshr.v2s.expand" {
  %r = lshr <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @lshr.v2s.expand(<2 x i32> %n, <2 x i32> %m) {
  %neg = call <2 x i32> @NEGv2s(<2 x i32> %m)
  %r = call <2 x i32> @USHLv2s(<2 x i32> %n, <2 x i32> %neg)
  ret <2 x i32> %r
}

define <2 x i32> @ashr.v2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "recipe"="ashr.v2s.expand" {
  %r = ashr <2 x i32> %n, %m
  ret <2 x i32> %r
}

define <2 x i32> @ashr.v2s.expand(<2 x i32> %n, <2 x i32> %m) {
  %neg = call <2 x i32> @NEGv2s(<2 x i32> %m)
  %r = call <2 x i32> @SSHLv2s(<2 x i32> %n, <2 x i32> %neg)
  ret <2 x i32> %r
}

define <16 x i1> @ANDm16(<16 x i1> "reg"="q" %n, <16 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <16 x i1> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @ORRm16(<16 x i1> "reg"="q" %n, <16 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <16 x i1> %n, %m
  ret <16 x i1> %r
}

define <16 x i1> @EORm16(<16 x i1> "reg"="q" %n, <16 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <16 x i1> %n, %m
  ret <16 x i1> %r
}

define <8 x i1> @ANDm8(<8 x i1> "reg"="q" %n, <8 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <8 x i1> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @ORRm8(<8 x i1> "reg"="q" %n, <8 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <8 x i1> %n, %m
  ret <8 x i1> %r
}

define <8 x i1> @EORm8(<8 x i1> "reg"="q" %n, <8 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <8 x i1> %n, %m
  ret <8 x i1> %r
}

define <4 x i1> @ANDm4(<4 x i1> "reg"="q" %n, <4 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <4 x i1> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @ORRm4(<4 x i1> "reg"="q" %n, <4 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <4 x i1> %n, %m
  ret <4 x i1> %r
}

define <4 x i1> @EORm4(<4 x i1> "reg"="q" %n, <4 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <4 x i1> %n, %m
  ret <4 x i1> %r
}

define <2 x i1> @ANDm2(<2 x i1> "reg"="q" %n, <2 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="and {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = and <2 x i1> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @ORRm2(<2 x i1> "reg"="q" %n, <2 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 00011 1 n:5 d:5" "asm"="orr {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = or <2 x i1> %n, %m
  ret <2 x i1> %r
}

define <2 x i1> @EORm2(<2 x i1> "reg"="q" %n, <2 x i1> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 00011 1 n:5 d:5" "asm"="eor {d:16b}, {n:16b}, {m:16b}" "dclass"="q" "nodecode" {
  %r = xor <2 x i1> %n, %m
  ret <2 x i1> %r
}
declare <16 x i8> @llvm.aarch64.neon.addp.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @ADDPv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.addp.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.neon.umaxp.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @UMAXPv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 10100 1 n:5 d:5" "asm"="umaxp {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.umaxp.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.neon.uminp.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @UMINPv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 00 1 m:5 10101 1 n:5 d:5" "asm"="uminp {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.uminp.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.neon.smaxp.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SMAXPv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 10100 1 n:5 d:5" "asm"="smaxp {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.smaxp.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.neon.sminp.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @SMINPv16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 00 1 m:5 10101 1 n:5 d:5" "asm"="sminp {d:16b}, {n:16b}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.sminp.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <8 x i16> @llvm.aarch64.neon.addp.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @ADDPv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.addp.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.umaxp.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @UMAXPv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 10100 1 n:5 d:5" "asm"="umaxp {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.umaxp.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.uminp.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @UMINPv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 10101 1 n:5 d:5" "asm"="uminp {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.uminp.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.smaxp.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SMAXPv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10100 1 n:5 d:5" "asm"="smaxp {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.smaxp.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.sminp.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SMINPv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10101 1 n:5 d:5" "asm"="sminp {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.sminp.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.sqdmulh.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SQDMULHv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 01 1 m:5 10110 1 n:5 d:5" "asm"="sqdmulh {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.sqdmulh.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <8 x i16> @llvm.aarch64.neon.sqrdmulh.v8i16(<8 x i16>, <8 x i16>)

define <8 x i16> @SQRDMULHv8h(<8 x i16> "reg"="q" %n, <8 x i16> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 01 1 m:5 10110 1 n:5 d:5" "asm"="sqrdmulh {d:8h}, {n:8h}, {m:8h}" {
  %r = call <8 x i16> @llvm.aarch64.neon.sqrdmulh.v8i16(<8 x i16> %n, <8 x i16> %m)
  ret <8 x i16> %r
}

declare <4 x i32> @llvm.aarch64.neon.addp.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @ADDPv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.addp.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.umaxp.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @UMAXPv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 10100 1 n:5 d:5" "asm"="umaxp {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.umaxp.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.uminp.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @UMINPv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 10101 1 n:5 d:5" "asm"="uminp {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.uminp.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.smaxp.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SMAXPv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10100 1 n:5 d:5" "asm"="smaxp {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.smaxp.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.sminp.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SMINPv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10101 1 n:5 d:5" "asm"="sminp {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.sminp.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.sqdmulh.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SQDMULHv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 10 1 m:5 10110 1 n:5 d:5" "asm"="sqdmulh {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.sqdmulh.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.neon.sqrdmulh.v4i32(<4 x i32>, <4 x i32>)

define <4 x i32> @SQRDMULHv4s(<4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="neon" "enc"="0 1 1 01110 10 1 m:5 10110 1 n:5 d:5" "asm"="sqrdmulh {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.neon.sqrdmulh.v4i32(<4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <2 x i64> @llvm.aarch64.neon.addp.v2i64(<2 x i64>, <2 x i64>)

define <2 x i64> @ADDPv2d(<2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="neon" "enc"="0 1 0 01110 11 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.neon.addp.v2i64(<2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

declare <8 x i8> @llvm.aarch64.neon.addp.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @ADDPv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.addp.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.umaxp.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @UMAXPv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 10100 1 n:5 d:5" "asm"="umaxp {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.umaxp.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.uminp.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @UMINPv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 00 1 m:5 10101 1 n:5 d:5" "asm"="uminp {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.uminp.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.smaxp.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SMAXPv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 10100 1 n:5 d:5" "asm"="smaxp {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.smaxp.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.sminp.v8i8(<8 x i8>, <8 x i8>)

define <8 x i8> @SMINPv8b(<8 x i8> "reg"="v" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 00 1 m:5 10101 1 n:5 d:5" "asm"="sminp {d:8b}, {n:8b}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.sminp.v8i8(<8 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

declare <4 x i16> @llvm.aarch64.neon.addp.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @ADDPv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.addp.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.umaxp.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @UMAXPv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 10100 1 n:5 d:5" "asm"="umaxp {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.umaxp.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.uminp.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @UMINPv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 10101 1 n:5 d:5" "asm"="uminp {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.uminp.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.smaxp.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SMAXPv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10100 1 n:5 d:5" "asm"="smaxp {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.smaxp.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.sminp.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SMINPv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10101 1 n:5 d:5" "asm"="sminp {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.sminp.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.sqdmulh.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SQDMULHv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 01 1 m:5 10110 1 n:5 d:5" "asm"="sqdmulh {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.sqdmulh.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <4 x i16> @llvm.aarch64.neon.sqrdmulh.v4i16(<4 x i16>, <4 x i16>)

define <4 x i16> @SQRDMULHv4h(<4 x i16> "reg"="v" %n, <4 x i16> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 01 1 m:5 10110 1 n:5 d:5" "asm"="sqrdmulh {d:4h}, {n:4h}, {m:4h}" {
  %r = call <4 x i16> @llvm.aarch64.neon.sqrdmulh.v4i16(<4 x i16> %n, <4 x i16> %m)
  ret <4 x i16> %r
}

declare <2 x i32> @llvm.aarch64.neon.umaxp.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @UMAXPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 10100 1 n:5 d:5" "asm"="umaxp {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.umaxp.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.uminp.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @UMINPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 10101 1 n:5 d:5" "asm"="uminp {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.uminp.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.smaxp.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SMAXPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10100 1 n:5 d:5" "asm"="smaxp {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.smaxp.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.sminp.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SMINPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10101 1 n:5 d:5" "asm"="sminp {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.sminp.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.sqdmulh.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SQDMULHv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 0 01110 10 1 m:5 10110 1 n:5 d:5" "asm"="sqdmulh {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.sqdmulh.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

declare <2 x i32> @llvm.aarch64.neon.sqrdmulh.v2i32(<2 x i32>, <2 x i32>)

define <2 x i32> @SQRDMULHv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "feature"="neon" "enc"="0 0 1 01110 10 1 m:5 10110 1 n:5 d:5" "asm"="sqrdmulh {d:2s}, {n:2s}, {m:2s}" {
  %r = call <2 x i32> @llvm.aarch64.neon.sqrdmulh.v2i32(<2 x i32> %n, <2 x i32> %m)
  ret <2 x i32> %r
}

define <16 x i8> @DUP0v16b(<16 x i8> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110000 00001 0 0000 1 n:5 d:5" "asm"="dup {d:16b}, {n:.b}[0]" {
  %r = shufflevector <16 x i8> %n, <16 x i8> poison, <16 x i32> zeroinitializer
  ret <16 x i8> %r
}

define <8 x i16> @DUP0v8h(<8 x i16> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110000 00010 0 0000 1 n:5 d:5" "asm"="dup {d:8h}, {n:.h}[0]" {
  %r = shufflevector <8 x i16> %n, <8 x i16> poison, <8 x i32> zeroinitializer
  ret <8 x i16> %r
}

define <4 x i32> @DUP0v4s(<4 x i32> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {d:4s}, {n:.s}[0]" {
  %r = shufflevector <4 x i32> %n, <4 x i32> poison, <4 x i32> zeroinitializer
  ret <4 x i32> %r
}

define <2 x i64> @DUP0v2d(<2 x i64> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110000 01000 0 0000 1 n:5 d:5" "asm"="dup {d:2d}, {n:.d}[0]" {
  %r = shufflevector <2 x i64> %n, <2 x i64> poison, <2 x i32> zeroinitializer
  ret <2 x i64> %r
}

define <8 x i8> @DUP0v8b(<8 x i8> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110000 00001 0 0000 1 n:5 d:5" "asm"="dup {d:8b}, {n:.b}[0]" {
  %r = shufflevector <8 x i8> %n, <8 x i8> poison, <8 x i32> zeroinitializer
  ret <8 x i8> %r
}

define <4 x i16> @DUP0v4h(<4 x i16> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110000 00010 0 0000 1 n:5 d:5" "asm"="dup {d:4h}, {n:.h}[0]" {
  %r = shufflevector <4 x i16> %n, <4 x i16> poison, <4 x i32> zeroinitializer
  ret <4 x i16> %r
}

define <2 x i32> @DUP0v2s(<2 x i32> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {d:2s}, {n:.s}[0]" {
  %r = shufflevector <2 x i32> %n, <2 x i32> poison, <2 x i32> zeroinitializer
  ret <2 x i32> %r
}

define <4 x float> @DUP0v4sf(<4 x float> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {d:4s}, {n:.s}[0]" {
  %r = shufflevector <4 x float> %n, <4 x float> poison, <4 x i32> zeroinitializer
  ret <4 x float> %r
}

define <2 x double> @DUP0v2df(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 1 0 01110000 01000 0 0000 1 n:5 d:5" "asm"="dup {d:2d}, {n:.d}[0]" {
  %r = shufflevector <2 x double> %n, <2 x double> poison, <2 x i32> zeroinitializer
  ret <2 x double> %r
}

define <2 x float> @DUP0v2sf(<2 x float> "reg"="v" %n) "feature"="neon" "enc"="0 0 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {d:2s}, {n:.s}[0]" {
  %r = shufflevector <2 x float> %n, <2 x float> poison, <2 x i32> zeroinitializer
  ret <2 x float> %r
}

declare <16 x i8> @llvm.aarch64.neon.tbl1.v16i8(<16 x i8>, <16 x i8>)

define <16 x i8> @TBL1v16b(<16 x i8> "reg"="q" %n, <16 x i8> "reg"="q" %m) "feature"="neon" "enc"="0 1 001110 000 m:5 0 00 0 00 n:5 d:5" "asm"="tbl {d:16b}, {lb}{n:16b}{rb}, {m:16b}" {
  %r = call <16 x i8> @llvm.aarch64.neon.tbl1.v16i8(<16 x i8> %n, <16 x i8> %m)
  ret <16 x i8> %r
}

declare <8 x i8> @llvm.aarch64.neon.tbl1.v8i8(<16 x i8>, <8 x i8>)

define <8 x i8> @TBL1v8b(<16 x i8> "reg"="q" %n, <8 x i8> "reg"="v" %m) "feature"="neon" "enc"="0 0 001110 000 m:5 0 00 0 00 n:5 d:5" "asm"="tbl {d:8b}, {lb}{n:16b}{rb}, {m:8b}" {
  %r = call <8 x i8> @llvm.aarch64.neon.tbl1.v8i8(<16 x i8> %n, <8 x i8> %m)
  ret <8 x i8> %r
}

