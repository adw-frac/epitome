; The RISC-V RV64 description: the M extension, multiplication and division. Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

define i64 @MUL(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 000 d:5 0110011" "asm"="mul {d}, {n}, {m}" "feature"="m" {
  %r = mul i64 %n, %m
  ret i64 %r
}

define i32 @MULW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000001 m:5 n:5 000 d:5 0111011" "asm"="mulw {d}, {n}, {m}" "feature"="m" {
  %r = mul i32 %n, %m
  ret i32 %r
}

define i64 @DIV(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 100 d:5 0110011" "asm"="div {d}, {n}, {m}" "feature"="m" {
  %r = sdiv i64 %n, %m
  ret i64 %r
}

define i32 @DIVW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000001 m:5 n:5 100 d:5 0111011" "asm"="divw {d}, {n}, {m}" "feature"="m" {
  %r = sdiv i32 %n, %m
  ret i32 %r
}

define i64 @DIVU(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 101 d:5 0110011" "asm"="divu {d}, {n}, {m}" "feature"="m" {
  %r = udiv i64 %n, %m
  ret i64 %r
}

define i32 @DIVUW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000001 m:5 n:5 101 d:5 0111011" "asm"="divuw {d}, {n}, {m}" "feature"="m" {
  %r = udiv i32 %n, %m
  ret i32 %r
}

define i64 @REM(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 110 d:5 0110011" "asm"="rem {d}, {n}, {m}" "feature"="m" {
  %r = srem i64 %n, %m
  ret i64 %r
}

define i32 @REMW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000001 m:5 n:5 110 d:5 0111011" "asm"="remw {d}, {n}, {m}" "feature"="m" {
  %r = srem i32 %n, %m
  ret i32 %r
}

define i64 @REMU(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 111 d:5 0110011" "asm"="remu {d}, {n}, {m}" "feature"="m" {
  %r = urem i64 %n, %m
  ret i64 %r
}

define i32 @REMUW(i32 "reg"="w" %n, i32 "reg"="w" %m) "enc"="0000001 m:5 n:5 111 d:5 0111011" "asm"="remuw {d}, {n}, {m}" "feature"="m" {
  %r = urem i32 %n, %m
  ret i32 %r
}

define i64 @MULH(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 001 d:5 0110011" "asm"="mulh {d}, {n}, {m}" "feature"="m" {
  %a = sext i64 %n to i128
  %b = sext i64 %m to i128
  %p = mul i128 %a, %b
  %h = lshr i128 %p, 64
  %r = trunc i128 %h to i64
  ret i64 %r
}

define i64 @MULHU(i64 "reg"="x" %n, i64 "reg"="x" %m) "enc"="0000001 m:5 n:5 011 d:5 0110011" "asm"="mulhu {d}, {n}, {m}" "feature"="m" {
  %a = zext i64 %n to i128
  %b = zext i64 %m to i128
  %p = mul i128 %a, %b
  %h = lshr i128 %p, 64
  %r = trunc i128 %h to i64
  ret i64 %r
}
