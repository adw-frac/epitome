; x86-64's integer instructions for selection. Written by gen_sel.py; do
; not edit. The conventions are those of codegen/targets/aarch64/00-base.ll,
; and docs/design/x86.md has the plan.

define i64 @ADD64rr(i64 "reg"="r64" "tied" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, d) | 00000001 | rr(m, d)" "asm"="addq {m}, {d}" "clobbers"="flags" "nodecode" {
  %r = add i64 %n, %m
  ret i64 %r
}

define i64 @ADD64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(0, d) | ib:s8=imm ; acc:0=d rex(1, 0, 0, 0) | 00000101 | iv:s32=imm ; rex(1, 0, 0, d) | 10000001 | rr(0, d) | iv:s32=imm }" "asm"="addq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = add i64 %n, %imm
  ret i64 %r
}

define i64 @OR64rr(i64 "reg"="r64" "tied" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, d) | 00001001 | rr(m, d)" "asm"="orq {m}, {d}" "clobbers"="flags" "nodecode" {
  %r = or i64 %n, %m
  ret i64 %r
}

define i64 @OR64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(1, d) | ib:s8=imm ; acc:0=d rex(1, 0, 0, 0) | 00001101 | iv:s32=imm ; rex(1, 0, 0, d) | 10000001 | rr(1, d) | iv:s32=imm }" "asm"="orq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = or i64 %n, %imm
  ret i64 %r
}

define i64 @AND64rr(i64 "reg"="r64" "tied" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, d) | 00100001 | rr(m, d)" "asm"="andq {m}, {d}" "clobbers"="flags" "nodecode" {
  %r = and i64 %n, %m
  ret i64 %r
}

define i64 @AND64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(4, d) | ib:s8=imm ; acc:0=d rex(1, 0, 0, 0) | 00100101 | iv:s32=imm ; rex(1, 0, 0, d) | 10000001 | rr(4, d) | iv:s32=imm }" "asm"="andq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = and i64 %n, %imm
  ret i64 %r
}

define i64 @SUB64rr(i64 "reg"="r64" "tied" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, d) | 00101001 | rr(m, d)" "asm"="subq {m}, {d}" "clobbers"="flags" "role"="sub" "nodecode" {
  %r = sub i64 %n, %m
  ret i64 %r
}

define i64 @SUB64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(5, d) | ib:s8=imm ; acc:0=d rex(1, 0, 0, 0) | 00101101 | iv:s32=imm ; rex(1, 0, 0, d) | 10000001 | rr(5, d) | iv:s32=imm }" "asm"="subq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = sub i64 %n, %imm
  ret i64 %r
}

define i64 @XOR64rr(i64 "reg"="r64" "tied" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, d) | 00110001 | rr(m, d)" "asm"="xorq {m}, {d}" "clobbers"="flags" "nodecode" {
  %r = xor i64 %n, %m
  ret i64 %r
}

define i64 @XOR64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(6, d) | ib:s8=imm ; acc:0=d rex(1, 0, 0, 0) | 00110101 | iv:s32=imm ; rex(1, 0, 0, d) | 10000001 | rr(6, d) | iv:s32=imm }" "asm"="xorq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = xor i64 %n, %imm
  ret i64 %r
}

define i64 @IMUL64rr(i64 "reg"="r64" "tied" %n, i64 "reg"="r64" %m) "enc"="rex(1, d, 0, m) | 00001111 | 10101111 | rr(d, m)" "asm"="imulq {m}, {d}" "clobbers"="flags" "nodecode" {
  %r = mul i64 %n, %m
  ret i64 %r
}

define i64 @IMUL64rri(i64 "reg"="r64" %n, i64 "imm" %imm) "enc"="{ rex(1, d, 0, n) | 01101011 | rr(d, n) | ib:s8=imm ; rex(1, d, 0, n) | 01101001 | rr(d, n) | iv:s32=imm }" "asm"="imulq ${imm}, {n}, {d}" "clobbers"="flags" "nodecode" {
  %r = mul i64 %n, %imm
  ret i64 %r
}

define i64 @SHL64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ one:0=imm-1 rex(1, 0, 0, d) | 11010001 | rr(4, d) ; rex(1, 0, 0, d) | 11000001 | rr(4, d) | ib:8=imm }" "asm"="shlq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = shl i64 %n, %imm
  ret i64 %r
}

define i64 @SHL64rCL(i64 "reg"="r64" "tied" %n, i64 "reg"="rcx" %c) "enc"="rex(1, 0, 0, d) | 11010011 | rr(4, d)" "asm"="shlq %cl, {d}" "clobbers"="flags" "nodecode" {
  %r = shl i64 %n, %c
  ret i64 %r
}

define i64 @SHR64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ one:0=imm-1 rex(1, 0, 0, d) | 11010001 | rr(5, d) ; rex(1, 0, 0, d) | 11000001 | rr(5, d) | ib:8=imm }" "asm"="shrq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = lshr i64 %n, %imm
  ret i64 %r
}

define i64 @SHR64rCL(i64 "reg"="r64" "tied" %n, i64 "reg"="rcx" %c) "enc"="rex(1, 0, 0, d) | 11010011 | rr(5, d)" "asm"="shrq %cl, {d}" "clobbers"="flags" "nodecode" {
  %r = lshr i64 %n, %c
  ret i64 %r
}

define i64 @SAR64ri(i64 "reg"="r64" "tied" %n, i64 "imm" %imm) "enc"="{ one:0=imm-1 rex(1, 0, 0, d) | 11010001 | rr(7, d) ; rex(1, 0, 0, d) | 11000001 | rr(7, d) | ib:8=imm }" "asm"="sarq ${imm}, {d}" "clobbers"="flags" "nodecode" {
  %r = ashr i64 %n, %imm
  ret i64 %r
}

define i64 @SAR64rCL(i64 "reg"="r64" "tied" %n, i64 "reg"="rcx" %c) "enc"="rex(1, 0, 0, d) | 11010011 | rr(7, d)" "asm"="sarq %cl, {d}" "clobbers"="flags" "nodecode" {
  %r = ashr i64 %n, %c
  ret i64 %r
}

define i64 @NEG64r(i64 "reg"="r64" "tied" %n) "enc"="rex(1, 0, 0, d) | 11110111 | rr(3, d)" "asm"="negq {d}" "clobbers"="flags" "nodecode" {
  %r = sub i64 0, %n
  ret i64 %r
}

define i64 @NOT64r(i64 "reg"="r64" "tied" %n) "enc"="rex(1, 0, 0, d) | 11110111 | rr(2, d)" "asm"="notq {d}" "nodecode" {
  %r = xor i64 %n, -1
  ret i64 %r
}

define i32 @ADD32rr(i32 "reg"="r32" "tied" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, d) | 00000001 | rr(m, d)" "asm"="addl {m}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = add i32 %n, %m
  ret i32 %r
}

define i32 @ADD32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ rex(0, 0, 0, d) | 10000011 | rr(0, d) | ib:s8=imm ; acc:0=d rex(0, 0, 0, 0) | 00000101 | iv:s32=imm ; rex(0, 0, 0, d) | 10000001 | rr(0, d) | iv:s32=imm }" "asm"="addl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = add i32 %n, %imm
  ret i32 %r
}

define i32 @OR32rr(i32 "reg"="r32" "tied" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, d) | 00001001 | rr(m, d)" "asm"="orl {m}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = or i32 %n, %m
  ret i32 %r
}

define i32 @OR32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ rex(0, 0, 0, d) | 10000011 | rr(1, d) | ib:s8=imm ; acc:0=d rex(0, 0, 0, 0) | 00001101 | iv:s32=imm ; rex(0, 0, 0, d) | 10000001 | rr(1, d) | iv:s32=imm }" "asm"="orl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = or i32 %n, %imm
  ret i32 %r
}

define i32 @AND32rr(i32 "reg"="r32" "tied" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, d) | 00100001 | rr(m, d)" "asm"="andl {m}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = and i32 %n, %m
  ret i32 %r
}

define i32 @AND32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ rex(0, 0, 0, d) | 10000011 | rr(4, d) | ib:s8=imm ; acc:0=d rex(0, 0, 0, 0) | 00100101 | iv:s32=imm ; rex(0, 0, 0, d) | 10000001 | rr(4, d) | iv:s32=imm }" "asm"="andl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = and i32 %n, %imm
  ret i32 %r
}

define i32 @SUB32rr(i32 "reg"="r32" "tied" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, d) | 00101001 | rr(m, d)" "asm"="subl {m}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = sub i32 %n, %m
  ret i32 %r
}

define i32 @SUB32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ rex(0, 0, 0, d) | 10000011 | rr(5, d) | ib:s8=imm ; acc:0=d rex(0, 0, 0, 0) | 00101101 | iv:s32=imm ; rex(0, 0, 0, d) | 10000001 | rr(5, d) | iv:s32=imm }" "asm"="subl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = sub i32 %n, %imm
  ret i32 %r
}

define i32 @XOR32rr(i32 "reg"="r32" "tied" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, d) | 00110001 | rr(m, d)" "asm"="xorl {m}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = xor i32 %n, %m
  ret i32 %r
}

define i32 @XOR32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ rex(0, 0, 0, d) | 10000011 | rr(6, d) | ib:s8=imm ; acc:0=d rex(0, 0, 0, 0) | 00110101 | iv:s32=imm ; rex(0, 0, 0, d) | 10000001 | rr(6, d) | iv:s32=imm }" "asm"="xorl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = xor i32 %n, %imm
  ret i32 %r
}

define i32 @IMUL32rr(i32 "reg"="r32" "tied" %n, i32 "reg"="r32" %m) "enc"="rex(0, d, 0, m) | 00001111 | 10101111 | rr(d, m)" "asm"="imull {m}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = mul i32 %n, %m
  ret i32 %r
}

define i32 @IMUL32rri(i32 "reg"="r32" %n, i32 "imm" %imm) "enc"="{ rex(0, d, 0, n) | 01101011 | rr(d, n) | ib:s8=imm ; rex(0, d, 0, n) | 01101001 | rr(d, n) | iv:s32=imm }" "asm"="imull ${imm}, {n}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = mul i32 %n, %imm
  ret i32 %r
}

define i32 @SHL32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ one:0=imm-1 rex(0, 0, 0, d) | 11010001 | rr(4, d) ; rex(0, 0, 0, d) | 11000001 | rr(4, d) | ib:8=imm }" "asm"="shll ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = shl i32 %n, %imm
  ret i32 %r
}

define i32 @SHL32rCL(i32 "reg"="r32" "tied" %n, i32 "reg"="rcx" %c) "enc"="rex(0, 0, 0, d) | 11010011 | rr(4, d)" "asm"="shll %cl, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = shl i32 %n, %c
  ret i32 %r
}

define i32 @SHR32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ one:0=imm-1 rex(0, 0, 0, d) | 11010001 | rr(5, d) ; rex(0, 0, 0, d) | 11000001 | rr(5, d) | ib:8=imm }" "asm"="shrl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = lshr i32 %n, %imm
  ret i32 %r
}

define i32 @SHR32rCL(i32 "reg"="r32" "tied" %n, i32 "reg"="rcx" %c) "enc"="rex(0, 0, 0, d) | 11010011 | rr(5, d)" "asm"="shrl %cl, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = lshr i32 %n, %c
  ret i32 %r
}

define i32 @SAR32ri(i32 "reg"="r32" "tied" %n, i32 "imm" %imm) "enc"="{ one:0=imm-1 rex(0, 0, 0, d) | 11010001 | rr(7, d) ; rex(0, 0, 0, d) | 11000001 | rr(7, d) | ib:8=imm }" "asm"="sarl ${imm}, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = ashr i32 %n, %imm
  ret i32 %r
}

define i32 @SAR32rCL(i32 "reg"="r32" "tied" %n, i32 "reg"="rcx" %c) "enc"="rex(0, 0, 0, d) | 11010011 | rr(7, d)" "asm"="sarl %cl, {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = ashr i32 %n, %c
  ret i32 %r
}

define i32 @NEG32r(i32 "reg"="r32" "tied" %n) "enc"="rex(0, 0, 0, d) | 11110111 | rr(3, d)" "asm"="negl {d}" "clobbers"="flags" "zext"="32" "nodecode" {
  %r = sub i32 0, %n
  ret i32 %r
}

define i32 @NOT32r(i32 "reg"="r32" "tied" %n) "enc"="rex(0, 0, 0, d) | 11110111 | rr(2, d)" "asm"="notl {d}" "zext"="32" "nodecode" {
  %r = xor i32 %n, -1
  ret i32 %r
}

define i64 @MOV64rr(i64 "reg"="r64" %n) "enc"="rex(1, n, 0, d) | 10001001 | rr(n, d)" "asm"="movq {n}, {d}" "copy"="r64" "nodecode" {
  ret i64 %n
}

define i32 @MOV32rr(i32 "reg"="r32" %n) "enc"="rex(0, n, 0, d) | 10001001 | rr(n, d)" "asm"="movl {n}, {d}" "copy"="r32" "zext"="32" "nodecode" {
  ret i32 %n
}

define i32 @MOV32ri(i32 "imm" %imm) "enc"="{ rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:s32=imm ; rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:32=imm }" "asm"="movl ${imm}, {d}" "zext"="32" "nodecode" {
  ret i32 %imm
}

define i64 @MOV64ri32(i64 "imm" %imm) "enc"="rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:32=imm" "asm"="movl ${imm}, {d:r32}" "nodecode" {
  ret i64 %imm
}

define i64 @MOV64ri(i64 "imm" %imm) "enc"="rex(1, 0, 0, d) | 11000111 | rr(0, d) | iv:s32=imm" "asm"="movq ${imm}, {d}" "nodecode" {
  ret i64 %imm
}

define i64 @MOVABS64ri(i64 "imm" %imm) "enc"="rex(1, 0, 0, d) | 10111 o:3=d&7 | io:s64=imm" "asm"="movabsq ${imm}, {d}" "nodecode" {
  ret i64 %imm
}

define i32 @MOVZBL32(i8 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) ; 0100 W:1=0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110110 | rr(d, n)" "asm"="movzbl {n:r8}, {d:r32}" "zext"="8" "role"="zext.8" "nodecode" {
  %r = zext i8 %n to i32
  ret i32 %r
}

define i32 @MOVZWL32(i16 "reg"="r32" %n) "enc"="rex(0, d, 0, n) | 00001111 | 10110111 | rr(d, n)" "asm"="movzwl {n:r16}, {d:r32}" "zext"="16" "role"="zext.16" "nodecode" {
  %r = zext i16 %n to i32
  ret i32 %r
}

define i32 @MOVSBL32(i8 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) ; 0100 W:1=0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10111110 | rr(d, n)" "asm"="movsbl {n:r8}, {d:r32}" "role"="sext.8" "nodecode" {
  %r = sext i8 %n to i32
  ret i32 %r
}

define i32 @MOVSWL32(i16 "reg"="r32" %n) "enc"="rex(0, d, 0, n) | 00001111 | 10111111 | rr(d, n)" "asm"="movswl {n:r16}, {d:r32}" "role"="sext.16" "nodecode" {
  %r = sext i16 %n to i32
  ret i32 %r
}

define i64 @MOVZBL64(i8 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) ; 0100 W:1=0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110110 | rr(d, n)" "asm"="movzbl {n:r8}, {d:r32}" "zext"="8" "nodecode" {
  %r = zext i8 %n to i64
  ret i64 %r
}

define i64 @MOVZWL64(i16 "reg"="r32" %n) "enc"="rex(0, d, 0, n) | 00001111 | 10110111 | rr(d, n)" "asm"="movzwl {n:r16}, {d:r32}" "zext"="16" "nodecode" {
  %r = zext i16 %n to i64
  ret i64 %r
}

define i64 @MOVSBQ64(i8 "reg"="r32" %n) "enc"="rex(1, d, 0, n) | 00001111 | 10111110 | rr(d, n)" "asm"="movsbq {n:r8}, {d}" "nodecode" {
  %r = sext i8 %n to i64
  ret i64 %r
}

define i64 @MOVSWQ64(i16 "reg"="r32" %n) "enc"="rex(1, d, 0, n) | 00001111 | 10111111 | rr(d, n)" "asm"="movswq {n:r16}, {d}" "nodecode" {
  %r = sext i16 %n to i64
  ret i64 %r
}

define i32 @MOVZBL1(i1 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) ; 0100 W:1=0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110110 | rr(d, n)" "asm"="movzbl {n:r8}, {d}" "zext"="1" "role"="zext.1" "nodecode" {
  %r = zext i1 %n to i32
  ret i32 %r
}

define i64 @MOVZBQ1(i1 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) ; 0100 W:1=0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110110 | rr(d, n)" "asm"="movzbl {n:r8}, {d:r32}" "zext"="1" "nodecode" {
  %r = zext i1 %n to i64
  ret i64 %r
}

define i64 @MOVSLQ(i32 "reg"="r32" %n) "enc"="rex(1, d, 0, n) | 01100011 | rr(d, n)" "asm"="movslq {n}, {d}" "role"="sext.32" "nodecode" {
  %r = sext i32 %n to i64
  ret i64 %r
}

define ptr @LEA64ri(ptr "reg"="r64" %n, i64 "imm" %imm) "enc"="rex(1, d, 4, n) | 10001101 | rm(d, n, 4, 1, imm, 0, 1)" "asm"="leaq {imm}({n}), {d}" "role"="addi" "nodecode" {
  %r = getelementptr i8, ptr %n, i64 %imm
  ret ptr %r
}

define ptr @LEA64rr(ptr "reg"="r64" %n, i64 "reg"="r64" %m) "enc"="{ if(m!=4) rex(1, d, m, n) | 10001101 | rm(d, n, m, 1, 0, 0, 1) }" "asm"="leaq ({n},{m}), {d}" "role"="add" "nodecode" {
  %r = getelementptr i8, ptr %n, i64 %m
  ret ptr %r
}

define i64 @LEA64add(i64 "reg"="r64" %n, i64 "reg"="r64" %m) "enc"="{ if(m!=4) rex(1, d, m, n) | 10001101 | rm(d, n, m, 1, 0, 0, 1) }" "asm"="leaq ({n},{m}), {d}" "nodecode" {
  %r = add i64 %n, %m
  ret i64 %r
}

define i64 @LEA64addi(i64 "reg"="r64" %n, i64 "imm" %imm) "enc"="rex(1, d, 4, n) | 10001101 | rm(d, n, 4, 1, imm, 0, 1)" "asm"="leaq {imm}({n}), {d}" "nodecode" {
  %r = add i64 %n, %imm
  ret i64 %r
}

define ptr @LEArip(ptr "sym" %s) "enc"="rex(1, d, 0, 0) | 10001101 | rm(d, 16, 4, 1, 0, s, 1)" "asm"="leaq {s}(%rip), {d}" "reloc"="pc32x" "role"="addr" "nomatch" "nodecode" {
  ret ptr %s
}

define ptr @MOVgot(ptr "sym" %s) "enc"="rex(1, d, 0, 0) | 10001011 | rm(d, 16, 4, 1, 0, s, 1)" "asm"="movq {s}(%rip), {d}" "reloc"="gotpcrel" "role"="got" "nomatch" "nodecode" {
  ret ptr %s
}

define i64 @MOVgottpoff(ptr "sym" %s) "enc"="rex(1, d, 0, 0) | 10001011 | rm(d, 16, 4, 1, 0, s, 1)" "asm"="movq {s}(%rip), {d}" "reloc"="gottpoff" "role"="tls.ie" "nomatch" "nodecode" {
  ret i64 0
}

define ptr @MOVfs0() "enc"="01100100 | rex(1, d, 0, 0) | 10001011 | 00 r:3=d&7 100 | 00100101 | 00000000 | 00000000 | 00000000 | 00000000" "asm"="movq %fs:0, {d}" "role"="thread.pointer" {
  %p = call ptr @llvm.thread.pointer.p0()
  ret ptr %p
}

declare ptr @llvm.thread.pointer.p0()

define i64 @LDI64(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, d, 4, n) | 10001011 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movq {off}({n}), {d}" "role"="load.x,load.r64" "dclass"="r64" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load i64, ptr %a
  ret i64 %r
}

define i32 @LDI32(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(0, d, 4, n) | 10001011 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movl {off}({n}), {d}" "role"="load.w" "zext"="32" "dclass"="r32" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load i32, ptr %a
  ret i32 %r
}

define i8 @LDI8(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(0, d, 4, n) | 00001111 | 10110110 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movzbl {off}({n}), {d:r32}" "role"="load.b" "zext"="8" "dclass"="r32" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load i8, ptr %a
  ret i8 %r
}

define i16 @LDI16(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(0, d, 4, n) | 00001111 | 10110111 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movzwl {off}({n}), {d:r32}" "role"="load.h" "zext"="16" "dclass"="r32" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load i16, ptr %a
  ret i16 %r
}

define ptr @LDP(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, d, 4, n) | 10001011 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movq {off}({n}), {d}" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load ptr, ptr %a
  ret ptr %r
}

define i32 @LDI8S32(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(0, d, 4, n) | 00001111 | 10111110 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movsbl {off}({n}), {d}" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %a
  %r = sext i8 %v to i32
  ret i32 %r
}

define i32 @LDI16S32(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(0, d, 4, n) | 00001111 | 10111111 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movswl {off}({n}), {d}" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %v = load i16, ptr %a
  %r = sext i16 %v to i32
  ret i32 %r
}

define i64 @LDI8S64(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, d, 4, n) | 00001111 | 10111110 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movsbq {off}({n}), {d}" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %a
  %r = sext i8 %v to i64
  ret i64 %r
}

define i64 @LDI16S64(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, d, 4, n) | 00001111 | 10111111 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movswq {off}({n}), {d}" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %v = load i16, ptr %a
  %r = sext i16 %v to i64
  ret i64 %r
}

define i64 @LDI32S64(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, d, 4, n) | 01100011 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movslq {off}({n}), {d}" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %a
  %r = sext i32 %v to i64
  ret i64 %r
}

define void @STI64(i64 "reg"="r64" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, t, 4, n) | 10001001 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movq {t}, {off}({n})" "role"="store.x,store.r64" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %a
  ret void
}

define void @STI32(i32 "reg"="r32" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(0, t, 4, n) | 10001001 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movl {t}, {off}({n})" "role"="store.w" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %a
  ret void
}

define void @STI16(i16 "reg"="r32" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="01100110 | rex(0, t, 4, n) | 10001001 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movw {t:r16}, {off}({n})" "role"="store.h" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store i16 %t, ptr %a
  ret void
}

define void @STI8(i8 "reg"="r32" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="{ if(t<4) rex(0, t, 4, n) ; 0100 0 R:1=(t)>>3 X:1=(4)>>3 B:1=(n)>>3 } | 10001000 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movb {t:r8}, {off}({n})" "role"="store.b" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store i8 %t, ptr %a
  ret void
}

define void @STP(ptr "reg"="r64" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="rex(1, t, 4, n) | 10001001 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movq {t}, {off}({n})" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store ptr %t, ptr %a
  ret void
}

define %flags @CMP64rr(i64 "reg"="r64" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, n) | 00111001 | rr(m, n)" "asm"="cmpq {m}, {n}" "sets"="zcso" "nodecode" {
  %f0 = insertvalue %flags poison, i64 %n, 0
  %f = insertvalue %flags %f0, i64 %m, 1
  ret %flags %f
}

define %flags @CMP64ri(i64 "reg"="r64" %n, i64 "imm" %imm) "enc"="{ rex(1, 0, 0, n) | 10000011 | rr(7, n) | ib:s8=imm ; acc:0=n rex(1, 0, 0, 0) | 00111101 | iv:s32=imm ; rex(1, 0, 0, n) | 10000001 | rr(7, n) | iv:s32=imm }" "asm"="cmpq ${imm}, {n}" "sets"="zcso" "nodecode" {
  %f0 = insertvalue %flags poison, i64 %n, 0
  %f = insertvalue %flags %f0, i64 %imm, 1
  ret %flags %f
}

define %flags @TEST64rr(i64 "reg"="r64" %n, i64 "reg"="r64" %m) "enc"="rex(1, m, 0, n) | 10000101 | rr(m, n)" "asm"="testq {m}, {n}" "sets"="zcso" "nodecode" {
  %r = and i64 %n, %m
  %f0 = insertvalue %flags poison, i64 %r, 0
  %f = insertvalue %flags %f0, i64 0, 1
  ret %flags %f
}

define %flags @CMP32rr(i32 "reg"="r32" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, n) | 00111001 | rr(m, n)" "asm"="cmpl {m}, {n}" "sets"="zcso" "nodecode" {
  %a = sext i32 %n to i64
  %b = sext i32 %m to i64
  %f0 = insertvalue %flags poison, i64 %a, 0
  %f = insertvalue %flags %f0, i64 %b, 1
  ret %flags %f
}

define %flags @CMP32ri(i32 "reg"="r32" %n, i32 "imm" %imm) "enc"="{ rex(0, 0, 0, n) | 10000011 | rr(7, n) | ib:s8=imm ; acc:0=n rex(0, 0, 0, 0) | 00111101 | iv:s32=imm ; rex(0, 0, 0, n) | 10000001 | rr(7, n) | iv:s32=imm }" "asm"="cmpl ${imm}, {n}" "sets"="zcso" "nodecode" {
  %a = sext i32 %n to i64
  %b = sext i32 %imm to i64
  %f0 = insertvalue %flags poison, i64 %a, 0
  %f = insertvalue %flags %f0, i64 %b, 1
  ret %flags %f
}

define %flags @TEST32rr(i32 "reg"="r32" %n, i32 "reg"="r32" %m) "enc"="rex(0, m, 0, n) | 10000101 | rr(m, n)" "asm"="testl {m}, {n}" "sets"="zcso" "nodecode" {
  %r = and i32 %n, %m
  %x = sext i32 %r to i64
  %f0 = insertvalue %flags poison, i64 %x, 0
  %f = insertvalue %flags %f0, i64 0, 1
  ret %flags %f
}

define void @JMP(ptr "label" %dest) "enc"="{ 11101011 | rel:s8=dest-end ; 11101001 | rel:s32=dest-end }" "asm"="jmp {dest}" "role"="jump" "nodecode" {
  indirectbr ptr %dest, []
}

define void @JCC(i1 "cond" %c, ptr "label" %dest) "enc"="{ 0111 cc:4=c | rel:s8=dest-end ; 00001111 | 1000 cc:4=c | rel:s32=dest-end }" "asm"="j{c} {dest}" "inverse"="JCC" "nodecode" {
  br i1 %c, label %taken, label %next
  taken:
  indirectbr ptr %dest, []
  next:
  ret void
}

define void @CALL(ptr "sym" %s) "enc"="11101000 | rel:s32=s-end" "asm"="callq {s}" "reloc"="plt32" "role"="call" "nomatch" "nodecode" {
  ret void
}

define void @TAILJMP(ptr "sym" %s) "enc"="11101001 | rel:s32=s-end" "asm"="jmp {s}" "reloc"="plt32" "role"="tailcall" "nomatch" "nodecode" {
  ret void
}

define void @CALLr(ptr "reg"="r64" %n) "enc"="rex(0, 0, 0, n) | 11111111 | rr(2, n)" "asm"="callq *{n}" "role"="callr" "nomatch" "nodecode" {
  ret void
}

define void @RET() "enc"="11000011" "asm"="retq" "role"="ret" "nodecode" {
  ret void
}

define void @UD2() "enc"="00001111 | 00001011" "asm"="ud2" "role"="trap" "nodecode" {
  unreachable
}

define i1 @SETCC(i1 "cond" %c) "enc"="{ if(d<4) 00001111 | 1001 cc:4=c | 11 000 rm:3=d&7 ; 0100 0 0 0 B:1=d>>3 | 00001111 | 1001 cc:4=c | 11 000 rm:3=d&7 }" "asm"="set{c} {d:r8}" "dclass"="r32" "nodecode" {
  ret i1 %c
}

define i64 @CMOV64(i1 "cond" %c, i64 "reg"="r64" %n, i64 "reg"="r64" "tied" %m) "enc"="rex(1, d, 0, n) | 00001111 | 0100 cc:4=c | rr(d, n)" "asm"="cmov{c}q {n}, {d}" "nodecode" {
  %r = select i1 %c, i64 %n, i64 %m
  ret i64 %r
}

define i32 @CMOV32(i1 "cond" %c, i32 "reg"="r32" %n, i32 "reg"="r32" "tied" %m) "enc"="rex(0, d, 0, n) | 00001111 | 0100 cc:4=c | rr(d, n)" "asm"="cmov{c}l {n}, {d}" "zext"="32" "nodecode" {
  %r = select i1 %c, i32 %n, i32 %m
  ret i32 %r
}

define ptr @CMOVP(i1 "cond" %c, ptr "reg"="r64" %n, ptr "reg"="r64" "tied" %m) "enc"="rex(1, d, 0, n) | 00001111 | 0100 cc:4=c | rr(d, n)" "asm"="cmov{c}q {n}, {d}" "nodecode" {
  %r = select i1 %c, ptr %n, ptr %m
  ret ptr %r
}

define i64 @SIGN64(i64 "reg"="rax" %a) "enc"="01001000 | 10011001" "asm"="cqto" "dclass"="rdx" "nomatch" "nodecode" {
  %r = ashr i64 %a, 63
  ret i64 %r
}

define i64 @IDIV64q(i64 "reg"="rax" %lo, i64 "reg"="rdx" %hi, i64 "reg"="r64" %b) "enc"="rex(1, 0, 0, b) | 11110111 | rr(7, b)" "asm"="idivq {b}" "dclass"="rax" "clobbers"="%rdx,flags" "nomatch" "nodecode" {
  %r = sdiv i64 %lo, %b
  ret i64 %r
}

define i64 @IDIV64r(i64 "reg"="rax" %lo, i64 "reg"="rdx" %hi, i64 "reg"="r64" %b) "enc"="rex(1, 0, 0, b) | 11110111 | rr(7, b)" "asm"="idivq {b}" "dclass"="rdx" "clobbers"="%rax,flags" "nomatch" "nodecode" {
  %r = srem i64 %lo, %b
  ret i64 %r
}

define i64 @DIV64q(i64 "reg"="rax" %lo, i64 "reg"="rdx" %hi, i64 "reg"="r64" %b) "enc"="rex(1, 0, 0, b) | 11110111 | rr(6, b)" "asm"="divq {b}" "dclass"="rax" "clobbers"="%rdx,flags" "nomatch" "nodecode" {
  %r = udiv i64 %lo, %b
  ret i64 %r
}

define i64 @DIV64r(i64 "reg"="rax" %lo, i64 "reg"="rdx" %hi, i64 "reg"="r64" %b) "enc"="rex(1, 0, 0, b) | 11110111 | rr(6, b)" "asm"="divq {b}" "dclass"="rdx" "clobbers"="%rax,flags" "nomatch" "nodecode" {
  %r = urem i64 %lo, %b
  ret i64 %r
}

define i32 @SIGN32(i32 "reg"="rax" %a) "enc"="10011001" "asm"="cltd" "dclass"="rdx" "nomatch" "nodecode" {
  %r = ashr i32 %a, 31
  ret i32 %r
}

define i32 @IDIV32q(i32 "reg"="rax" %lo, i32 "reg"="rdx" %hi, i32 "reg"="r32" %b) "enc"="rex(0, 0, 0, b) | 11110111 | rr(7, b)" "asm"="idivl {b}" "dclass"="rax" "clobbers"="%rdx,flags" "nomatch" "nodecode" {
  %r = sdiv i32 %lo, %b
  ret i32 %r
}

define i32 @IDIV32r(i32 "reg"="rax" %lo, i32 "reg"="rdx" %hi, i32 "reg"="r32" %b) "enc"="rex(0, 0, 0, b) | 11110111 | rr(7, b)" "asm"="idivl {b}" "dclass"="rdx" "clobbers"="%rax,flags" "nomatch" "nodecode" {
  %r = srem i32 %lo, %b
  ret i32 %r
}

define i32 @DIV32q(i32 "reg"="rax" %lo, i32 "reg"="rdx" %hi, i32 "reg"="r32" %b) "enc"="rex(0, 0, 0, b) | 11110111 | rr(6, b)" "asm"="divl {b}" "dclass"="rax" "clobbers"="%rdx,flags" "nomatch" "nodecode" {
  %r = udiv i32 %lo, %b
  ret i32 %r
}

define i32 @DIV32r(i32 "reg"="rax" %lo, i32 "reg"="rdx" %hi, i32 "reg"="r32" %b) "enc"="rex(0, 0, 0, b) | 11110111 | rr(6, b)" "asm"="divl {b}" "dclass"="rdx" "clobbers"="%rax,flags" "nomatch" "nodecode" {
  %r = urem i32 %lo, %b
  ret i32 %r
}

define i64 @sdiv.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="sdiv.64.expand" {
  %r = sdiv i64 %a, %b
  ret i64 %r
}

define i64 @sdiv.64.expand(i64 %a, i64 %b) {
  %h = call i64 @SIGN64(i64 %a)
  %r = call i64 @IDIV64q(i64 %a, i64 %h, i64 %b)
  ret i64 %r
}

define i64 @srem.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="srem.64.expand" {
  %r = srem i64 %a, %b
  ret i64 %r
}

define i64 @srem.64.expand(i64 %a, i64 %b) {
  %h = call i64 @SIGN64(i64 %a)
  %r = call i64 @IDIV64r(i64 %a, i64 %h, i64 %b)
  ret i64 %r
}

define i64 @udiv.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="udiv.64.expand" {
  %r = udiv i64 %a, %b
  ret i64 %r
}

define i64 @udiv.64.expand(i64 %a, i64 %b) {
  %h = call i64 @MOV64zero()
  %r = call i64 @DIV64q(i64 %a, i64 %h, i64 %b)
  ret i64 %r
}

define i64 @urem.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="urem.64.expand" {
  %r = urem i64 %a, %b
  ret i64 %r
}

define i64 @urem.64.expand(i64 %a, i64 %b) {
  %h = call i64 @MOV64zero()
  %r = call i64 @DIV64r(i64 %a, i64 %h, i64 %b)
  ret i64 %r
}

define i64 @MOV64zero() "enc"="rex(0, 0, 0, d) | 10111 o:3=d&7 | 00000000 | 00000000 | 00000000 | 00000000" "asm"="movl $0, {d:r32}" "nomatch" "nodecode" {
  ret i64 0
}

define i32 @sdiv.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="sdiv.32.expand" {
  %r = sdiv i32 %a, %b
  ret i32 %r
}

define i32 @sdiv.32.expand(i32 %a, i32 %b) {
  %h = call i32 @SIGN32(i32 %a)
  %r = call i32 @IDIV32q(i32 %a, i32 %h, i32 %b)
  ret i32 %r
}

define i32 @srem.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="srem.32.expand" {
  %r = srem i32 %a, %b
  ret i32 %r
}

define i32 @srem.32.expand(i32 %a, i32 %b) {
  %h = call i32 @SIGN32(i32 %a)
  %r = call i32 @IDIV32r(i32 %a, i32 %h, i32 %b)
  ret i32 %r
}

define i32 @udiv.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="udiv.32.expand" {
  %r = udiv i32 %a, %b
  ret i32 %r
}

define i32 @udiv.32.expand(i32 %a, i32 %b) {
  %h = call i32 @MOV32zero()
  %r = call i32 @DIV32q(i32 %a, i32 %h, i32 %b)
  ret i32 %r
}

define i32 @urem.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="urem.32.expand" {
  %r = urem i32 %a, %b
  ret i32 %r
}

define i32 @urem.32.expand(i32 %a, i32 %b) {
  %h = call i32 @MOV32zero()
  %r = call i32 @DIV32r(i32 %a, i32 %h, i32 %b)
  ret i32 %r
}

define i32 @MOV32zero() "enc"="rex(0, 0, 0, d) | 10111 o:3=d&7 | 00000000 | 00000000 | 00000000 | 00000000" "asm"="movl $0, {d:r32}" "nomatch" "nodecode" {
  ret i32 0
}

define i64 @smin.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="smin.64.expand" {
  %r = call i64 @llvm.smin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smin.64.expand(i64 %a, i64 %b) {
  %f = call %flags @CMP64rr(i64 %a, i64 %b)
  %c = call i1 @cc.l(%flags %f)
  %r = call i64 @CMOV64(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smax.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="smax.64.expand" {
  %r = call i64 @llvm.smax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smax.64.expand(i64 %a, i64 %b) {
  %f = call %flags @CMP64rr(i64 %a, i64 %b)
  %c = call i1 @cc.g(%flags %f)
  %r = call i64 @CMOV64(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umin.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="umin.64.expand" {
  %r = call i64 @llvm.umin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umin.64.expand(i64 %a, i64 %b) {
  %f = call %flags @CMP64rr(i64 %a, i64 %b)
  %c = call i1 @cc.b(%flags %f)
  %r = call i64 @CMOV64(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umax.64(i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="umax.64.expand" {
  %r = call i64 @llvm.umax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umax.64.expand(i64 %a, i64 %b) {
  %f = call %flags @CMP64rr(i64 %a, i64 %b)
  %c = call i1 @cc.a(%flags %f)
  %r = call i64 @CMOV64(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

define i32 @smin.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="smin.32.expand" {
  %r = call i32 @llvm.smin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smin.32.expand(i32 %a, i32 %b) {
  %f = call %flags @CMP32rr(i32 %a, i32 %b)
  %c = call i1 @cc.l(%flags %f)
  %r = call i32 @CMOV32(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smax.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="smax.32.expand" {
  %r = call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smax.32.expand(i32 %a, i32 %b) {
  %f = call %flags @CMP32rr(i32 %a, i32 %b)
  %c = call i1 @cc.g(%flags %f)
  %r = call i32 @CMOV32(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umin.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="umin.32.expand" {
  %r = call i32 @llvm.umin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umin.32.expand(i32 %a, i32 %b) {
  %f = call %flags @CMP32rr(i32 %a, i32 %b)
  %c = call i1 @cc.b(%flags %f)
  %r = call i32 @CMOV32(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umax.32(i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="umax.32.expand" {
  %r = call i32 @llvm.umax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umax.32.expand(i32 %a, i32 %b) {
  %f = call %flags @CMP32rr(i32 %a, i32 %b)
  %c = call i1 @cc.a(%flags %f)
  %r = call i32 @CMOV32(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.smin.i64(i64, i64)

declare i64 @llvm.smax.i64(i64, i64)

declare i64 @llvm.umin.i64(i64, i64)

declare i64 @llvm.umax.i64(i64, i64)

declare i32 @llvm.smin.i32(i32, i32)

declare i32 @llvm.smax.i32(i32, i32)

declare i32 @llvm.umin.i32(i32, i32)

declare i32 @llvm.umax.i32(i32, i32)

define %flags @TESTB1(i1 "reg"="r32" %n) "enc"="{ acc:0=n 10101000 | 00000001 ; if(n<4) 11110110 | rr(0, n) | 00000001 ; 0100 0 0 0 B:1=n>>3 | 11110110 | rr(0, n) | 00000001 }" "asm"="testb $1, {n:r8}" "sets"="zcso" "nomatch" "nodecode" {
  %x = zext i1 %n to i64
  %f0 = insertvalue %flags poison, i64 %x, 0
  %f = insertvalue %flags %f0, i64 0, 1
  ret %flags %f
}

define i64 @select.64(i1 "reg"="r32" %c, i64 "reg"="r64" %a, i64 "reg"="r64" %b) "recipe"="select.64.expand" {
  %r = select i1 %c, i64 %a, i64 %b
  ret i64 %r
}

define i64 @select.64.expand(i1 %c, i64 %a, i64 %b) {
  %f = call %flags @TESTB1(i1 %c)
  %ne = call i1 @cc.ne(%flags %f)
  %r = call i64 @CMOV64(i1 %ne, i64 %a, i64 %b)
  ret i64 %r
}

define i32 @select.32(i1 "reg"="r32" %c, i32 "reg"="r32" %a, i32 "reg"="r32" %b) "recipe"="select.32.expand" {
  %r = select i1 %c, i32 %a, i32 %b
  ret i32 %r
}

define i32 @select.32.expand(i1 %c, i32 %a, i32 %b) {
  %f = call %flags @TESTB1(i1 %c)
  %ne = call i1 @cc.ne(%flags %f)
  %r = call i32 @CMOV32(i1 %ne, i32 %a, i32 %b)
  ret i32 %r
}

define ptr @select.p(i1 "reg"="r32" %c, ptr "reg"="r64" %a, ptr "reg"="r64" %b) "recipe"="select.p.expand" {
  %r = select i1 %c, ptr %a, ptr %b
  ret ptr %r
}

define ptr @select.p.expand(i1 %c, ptr %a, ptr %b) {
  %f = call %flags @TESTB1(i1 %c)
  %ne = call i1 @cc.ne(%flags %f)
  %r = call ptr @CMOVP(i1 %ne, ptr %a, ptr %b)
  ret ptr %r
}

define i8 @ZEXT1toi8(i1 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) | 00001111 | 10110110 | rr(d, n) ; 0100 0 R:1=d>>3 0 B:1=n>>3 | 00001111 | 10110110 | rr(d, n) }" "asm"="movzbl {n:r8}, {d:r32}" "nomatch" "dclass"="r32" "nodecode" {
  %r = zext i1 %n to i8
  ret i8 %r
}

define i8 @NEGxi8(i8 "reg"="r32" "tied" %n) "enc"="rex(0, 0, 0, d) | 11110111 | rr(3, d)" "asm"="negl {d}" "clobbers"="flags" "nomatch" "dclass"="r32" "nodecode" {
  %r = sub i8 0, %n
  ret i8 %r
}

define i8 @sext.1.i8(i1 "reg"="r32" %n) "recipe"="sext.1.i8.expand" {
  %r = sext i1 %n to i8
  ret i8 %r
}

define i8 @sext.1.i8.expand(i1 %n) {
  %z = call i8 @ZEXT1toi8(i1 %n)
  %r = call i8 @NEGxi8(i8 %z)
  ret i8 %r
}

define i16 @ZEXT1toi16(i1 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) | 00001111 | 10110110 | rr(d, n) ; 0100 0 R:1=d>>3 0 B:1=n>>3 | 00001111 | 10110110 | rr(d, n) }" "asm"="movzbl {n:r8}, {d:r32}" "nomatch" "dclass"="r32" "nodecode" {
  %r = zext i1 %n to i16
  ret i16 %r
}

define i16 @NEGxi16(i16 "reg"="r32" "tied" %n) "enc"="rex(0, 0, 0, d) | 11110111 | rr(3, d)" "asm"="negl {d}" "clobbers"="flags" "nomatch" "dclass"="r32" "nodecode" {
  %r = sub i16 0, %n
  ret i16 %r
}

define i16 @sext.1.i16(i1 "reg"="r32" %n) "recipe"="sext.1.i16.expand" {
  %r = sext i1 %n to i16
  ret i16 %r
}

define i16 @sext.1.i16.expand(i1 %n) {
  %z = call i16 @ZEXT1toi16(i1 %n)
  %r = call i16 @NEGxi16(i16 %z)
  ret i16 %r
}

define i32 @ZEXT1toi32(i1 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) | 00001111 | 10110110 | rr(d, n) ; 0100 0 R:1=d>>3 0 B:1=n>>3 | 00001111 | 10110110 | rr(d, n) }" "asm"="movzbl {n:r8}, {d:r32}" "nomatch" "nodecode" {
  %r = zext i1 %n to i32
  ret i32 %r
}

define i32 @NEGxi32(i32 "reg"="r32" "tied" %n) "enc"="rex(0, 0, 0, d) | 11110111 | rr(3, d)" "asm"="negl {d}" "clobbers"="flags" "nomatch" "nodecode" {
  %r = sub i32 0, %n
  ret i32 %r
}

define i32 @sext.1.i32(i1 "reg"="r32" %n) "recipe"="sext.1.i32.expand" {
  %r = sext i1 %n to i32
  ret i32 %r
}

define i32 @sext.1.i32.expand(i1 %n) {
  %z = call i32 @ZEXT1toi32(i1 %n)
  %r = call i32 @NEGxi32(i32 %z)
  ret i32 %r
}

define i64 @ZEXT1toi64(i1 "reg"="r32" %n) "enc"="{ if(n<4) rex(0, d, 0, n) | 00001111 | 10110110 | rr(d, n) ; 0100 0 R:1=d>>3 0 B:1=n>>3 | 00001111 | 10110110 | rr(d, n) }" "asm"="movzbl {n:r8}, {d:r32}" "nomatch" "nodecode" {
  %r = zext i1 %n to i64
  ret i64 %r
}

define i64 @NEGxi64(i64 "reg"="r64" "tied" %n) "enc"="rex(1, 0, 0, d) | 11110111 | rr(3, d)" "asm"="negq {d}" "clobbers"="flags" "nomatch" "nodecode" {
  %r = sub i64 0, %n
  ret i64 %r
}

define i64 @sext.1.i64(i1 "reg"="r32" %n) "recipe"="sext.1.i64.expand" {
  %r = sext i1 %n to i64
  ret i64 %r
}

define i64 @sext.1.i64.expand(i1 %n) {
  %z = call i64 @ZEXT1toi64(i1 %n)
  %r = call i64 @NEGxi64(i64 %z)
  ret i64 %r
}

define i64 @IMULH64(i64 "reg"="rax" %n, i64 "reg"="r64" %m) "enc"="rex(1, 0, 0, m) | 11110111 | rr(5, m)" "asm"="imulq {m}" "dclass"="rdx" "clobbers"="%rax,flags" "nodecode" {
  %a = sext i64 %n to i128
  %b = sext i64 %m to i128
  %p = mul i128 %a, %b
  %h = lshr i128 %p, 64
  %r = trunc i128 %h to i64
  ret i64 %r
}

define i64 @MULH64(i64 "reg"="rax" %n, i64 "reg"="r64" %m) "enc"="rex(1, 0, 0, m) | 11110111 | rr(4, m)" "asm"="mulq {m}" "dclass"="rdx" "clobbers"="%rax,flags" "nodecode" {
  %a = zext i64 %n to i128
  %b = zext i64 %m to i128
  %p = mul i128 %a, %b
  %h = lshr i128 %p, 64
  %r = trunc i128 %h to i64
  ret i64 %r
}

define i64 @MOVZX32(i32 "reg"="r32" %n) "enc"="rex(0, n, 0, d) | 10001001 | rr(n, d)" "asm"="movl {n}, {d:r32}" "zext"="32" "nodecode" {
  %r = zext i32 %n to i64
  ret i64 %r
}

; Floating point, SSE2's scalar instructions. The flags of a comparison
; (ucomisd) are ZF, PF and CF: unordered sets all three, less than CF,
; equal ZF. Each of the eight predicates a condition tests is one condition
; code; oeq and une are two (prepare splits them: "fcmp-split").
%fflags = type { double, double }
; The flags of the operands the other way round: ucomisd n, m compares m
; with n. Its conditions test the predicates whose operands are swapped:
; olt is ogt the other way round, ugt ult.
%fflagsr = type { double, double }

define i1 @cc.fr.olt(%fflagsr %f) "cond"="7" "asm"="a" "reads"="zcp" {
  %a = extractvalue %fflagsr %f, 0
  %b = extractvalue %fflagsr %f, 1
  %c = fcmp olt double %a, %b
  ret i1 %c
}

define i1 @cc.fr.ole(%fflagsr %f) "cond"="3" "asm"="ae" "reads"="zcp" {
  %a = extractvalue %fflagsr %f, 0
  %b = extractvalue %fflagsr %f, 1
  %c = fcmp ole double %a, %b
  ret i1 %c
}

define i1 @cc.fr.ugt(%fflagsr %f) "cond"="2" "asm"="b" "reads"="zcp" {
  %a = extractvalue %fflagsr %f, 0
  %b = extractvalue %fflagsr %f, 1
  %c = fcmp ugt double %a, %b
  ret i1 %c
}

define i1 @cc.fr.uge(%fflagsr %f) "cond"="6" "asm"="be" "reads"="zcp" {
  %a = extractvalue %fflagsr %f, 0
  %b = extractvalue %fflagsr %f, 1
  %c = fcmp uge double %a, %b
  ret i1 %c
}

define i1 @cc.f.ogt(%fflags %f) "cond"="7" "asm"="a" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp ogt double %a, %b
  ret i1 %c
}

define i1 @cc.f.oge(%fflags %f) "cond"="3" "asm"="ae" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp oge double %a, %b
  ret i1 %c
}

define i1 @cc.f.ult(%fflags %f) "cond"="2" "asm"="b" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp ult double %a, %b
  ret i1 %c
}

define i1 @cc.f.ule(%fflags %f) "cond"="6" "asm"="be" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp ule double %a, %b
  ret i1 %c
}

define i1 @cc.f.ueq(%fflags %f) "cond"="4" "asm"="e" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp ueq double %a, %b
  ret i1 %c
}

define i1 @cc.f.one(%fflags %f) "cond"="5" "asm"="ne" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp one double %a, %b
  ret i1 %c
}

define i1 @cc.f.uno(%fflags %f) "cond"="10" "asm"="p" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp uno double %a, %b
  ret i1 %c
}

define i1 @cc.f.ord(%fflags %f) "cond"="11" "asm"="np" "reads"="zcp" {
  %a = extractvalue %fflags %f, 0
  %b = extractvalue %fflags %f, 1
  %c = fcmp ord double %a, %b
  ret i1 %c
}

define %fflags @UCOMISD(double "reg"="d" %n, double "reg"="d" %m) "enc"="01100110 | rex(0, n, 0, m) | 00001111 | 00101110 | rr(n, m)" "asm"="ucomisd {m}, {n}" "sets"="zcp" "nodecode" {
  %f0 = insertvalue %fflags poison, double %n, 0
  %f = insertvalue %fflags %f0, double %m, 1
  ret %fflags %f
}

define %fflagsr @UCOMISDrev(double "reg"="d" %n, double "reg"="d" %m) "enc"="01100110 | rex(0, m, 0, n) | 00001111 | 00101110 | rr(m, n)" "asm"="ucomisd {n}, {m}" "sets"="zcp" "nodecode" {
  %f0 = insertvalue %fflagsr poison, double %n, 0
  %f = insertvalue %fflagsr %f0, double %m, 1
  ret %fflagsr %f
}

define double @ADDSD(double "reg"="d" "tied" %n, double "reg"="d" %m) "enc"="11110010 | rex(0, d, 0, m) | 00001111 | 01011000 | rr(d, m)" "asm"="addsd {m}, {d}" "nodecode" {
  %r = fadd double %n, %m
  ret double %r
}

define double @SUBSD(double "reg"="d" "tied" %n, double "reg"="d" %m) "enc"="11110010 | rex(0, d, 0, m) | 00001111 | 01011100 | rr(d, m)" "asm"="subsd {m}, {d}" "nodecode" {
  %r = fsub double %n, %m
  ret double %r
}

define double @MULSD(double "reg"="d" "tied" %n, double "reg"="d" %m) "enc"="11110010 | rex(0, d, 0, m) | 00001111 | 01011001 | rr(d, m)" "asm"="mulsd {m}, {d}" "nodecode" {
  %r = fmul double %n, %m
  ret double %r
}

define double @DIVSD(double "reg"="d" "tied" %n, double "reg"="d" %m) "enc"="11110010 | rex(0, d, 0, m) | 00001111 | 01011110 | rr(d, m)" "asm"="divsd {m}, {d}" "nodecode" {
  %r = fdiv double %n, %m
  ret double %r
}

define double @SQRTSD(double "reg"="d" %n) "enc"="11110010 | rex(0, d, 0, n) | 00001111 | 01010001 | rr(d, n)" "asm"="sqrtsd {n}, {d}" "nodecode" {
  %r = call double @llvm.sqrt.f64(double %n)
  ret double %r
}

declare double @llvm.sqrt.f64(double)

define double @LDSD(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="11110010 | rex(0, d, 4, n) | 00001111 | 00010000 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movsd {off}({n}), {d}" "role"="load.d" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load double, ptr %a
  ret double %r
}

define void @STSD(double "reg"="d" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="11110010 | rex(0, t, 4, n) | 00001111 | 00010001 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movsd {t}, {off}({n})" "role"="store.d" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %a
  ret void
}

define double @MOVSDfromi64(i64 "reg"="r64" %n) "enc"="01100110 | rex(1, d, 0, n) | 00001111 | 01101110 | rr(d, n)" "asm"="movq {n}, {d}" "role"="move.d.r64" "nodecode" {
  %r = bitcast i64 %n to double
  ret double %r
}

define i64 @MOVi64fromSD(double "reg"="d" %n) "enc"="01100110 | rex(1, n, 0, d) | 00001111 | 01111110 | rr(n, d)" "asm"="movq {n}, {d}" "role"="move.r64.d" "nodecode" {
  %r = bitcast double %n to i64
  ret i64 %r
}

define double @CVTSITOFPI32SD(i32 "reg"="r32" %n) "enc"="11110010 | rex(0, d, 0, n) | 00001111 | 00101010 | rr(d, n)" "asm"="cvtsi2sd {n}, {d}" "nodecode" {
  %r = sitofp i32 %n to double
  ret double %r
}

define double @CVTSITOFPI64SD(i64 "reg"="r64" %n) "enc"="11110010 | rex(1, d, 0, n) | 00001111 | 00101010 | rr(d, n)" "asm"="cvtsi2sd {n}, {d}" "nodecode" {
  %r = sitofp i64 %n to double
  ret double %r
}

define double @CVTUITOFPI32SD(i32 "reg"="r32" %n) "enc"="11110010 | rex(1, d, 0, n) | 00001111 | 00101010 | rr(d, n)" "asm"="cvtsi2sd {n:r64}, {d}" "nodecode" {
  %r = uitofp i32 %n to double
  ret double %r
}

define i32 @CVTTFPTOSISDI32(double "reg"="d" %n) "enc"="11110010 | rex(0, d, 0, n) | 00001111 | 00101100 | rr(d, n)" "asm"="cvttsd2si {n}, {d}" "dclass"="r32" "nodecode" {
  %r = fptosi double %n to i32
  ret i32 %r
}

define i64 @CVTTFPTOSISDI64(double "reg"="d" %n) "enc"="11110010 | rex(1, d, 0, n) | 00001111 | 00101100 | rr(d, n)" "asm"="cvttsd2si {n}, {d}" "dclass"="r64" "nodecode" {
  %r = fptosi double %n to i64
  ret i64 %r
}

define i32 @CVTTFPTOUISDI32(double "reg"="d" %n) "enc"="11110010 | rex(1, d, 0, n) | 00001111 | 00101100 | rr(d, n)" "asm"="cvttsd2si {n}, {d:r64}" "dclass"="r32" "nodecode" {
  %r = fptoui double %n to i32
  ret i32 %r
}

define double @select.d(i1 "reg"="r32" %c, double "reg"="d" %a, double "reg"="d" %b) "recipe"="select.d.expand" {
  %r = select i1 %c, double %a, double %b
  ret double %r
}

define double @select.d.expand(i1 %c, double %a, double %b) {
  %ai = call i64 @MOVi64fromSD(double %a)
  %bi = call i64 @MOVi64fromSD(double %b)
  %f = call %flags @TESTB1(i1 %c)
  %ne = call i1 @cc.ne(%flags %f)
  %ri = call i64 @CMOV64(i1 %ne, i64 %ai, i64 %bi)
  %r = call double @MOVSDfromi64(i64 %ri)
  ret double %r
}

define double @fneg.d(double "reg"="d" %a) "recipe"="fneg.d.expand" {
  %r = fneg double %a
  ret double %r
}

define double @fneg.d.expand(double %a) {
  %ai = call i64 @MOVi64fromSD(double %a)
  %k = call i64 @MOVABS64ri(i64 -9223372036854775808)
  %x = call i64 @XOR64rr(i64 %ai, i64 %k)
  %r = call double @MOVSDfromi64(i64 %x)
  ret double %r
}

define double @fabs.d(double "reg"="d" %a) "recipe"="fabs.d.expand" {
  %r = call double @llvm.fabs.f64(double %a)
  ret double %r
}

define double @fabs.d.expand(double %a) {
  %ai = call i64 @MOVi64fromSD(double %a)
  %k = call i64 @MOVABS64ri(i64 9223372036854775807)
  %x = call i64 @AND64rr(i64 %ai, i64 %k)
  %r = call double @MOVSDfromi64(i64 %x)
  ret double %r
}

declare double @llvm.fabs.f64(double)

declare double @llvm.fmuladd.f64(double, double, double)

define double @fmuladd.d(double "reg"="d" %a, double "reg"="d" %b, double "reg"="d" %c) "recipe"="fmuladd.d.expand" {
  %r = call double @llvm.fmuladd.f64(double %a, double %b, double %c)
  ret double %r
}

define double @fmuladd.d.expand(double %a, double %b, double %c) {
  %p = call double @MULSD(double %a, double %b)
  %r = call double @ADDSD(double %p, double %c)
  ret double %r
}

define double @uitofp.64.d(i64 "reg"="r64" %x) "recipe"="uitofp.64.d.expand" {
  %r = uitofp i64 %x to double
  ret double %r
}

define double @uitofp.64.d.expand(i64 %x) {
  %h = call i64 @SHR64ri(i64 %x, i64 1)
  %l = call i64 @AND64ri(i64 %x, i64 1)
  %o = call i64 @OR64rr(i64 %h, i64 %l)
  %f1 = call %flags @TEST64rr(i64 %x, i64 %x)
  %n1 = call i1 @cc.l(%flags %f1)
  %t = call i64 @CMOV64(i1 %n1, i64 %o, i64 %x)
  %c = call double @CVTSITOFPI64SD(i64 %t)
  %c2 = call double @ADDSD(double %c, double %c)
  %ci = call i64 @MOVi64fromSD(double %c)
  %c2i = call i64 @MOVi64fromSD(double %c2)
  %f2 = call %flags @TEST64rr(i64 %x, i64 %x)
  %n2 = call i1 @cc.l(%flags %f2)
  %ri = call i64 @CMOV64(i1 %n2, i64 %c2i, i64 %ci)
  %r = call double @MOVSDfromi64(i64 %ri)
  ret double %r
}

define i64 @fptoui.64.d(double "reg"="d" %x) "recipe"="fptoui.64.d.expand" {
  %r = fptoui double %x to i64
  ret i64 %r
}

define i64 @fptoui.64.d.expand(double %x) {
  %a = call i64 @CVTTFPTOSISDI64(double %x)
  %ki = call i64 @MOVABS64ri(i64 4890909195324358656)
  %k = call double @MOVSDfromi64(i64 %ki)
  %y = call double @SUBSD(double %x, double %k)
  %b = call i64 @CVTTFPTOSISDI64(double %y)
  %s = call i64 @SAR64ri(i64 %a, i64 63)
  %m = call i64 @AND64rr(i64 %b, i64 %s)
  %r = call i64 @OR64rr(i64 %a, i64 %m)
  ret i64 %r
}

define %fflags @UCOMISS(float "reg"="s" %n, float "reg"="s" %m) "enc"="rex(0, n, 0, m) | 00001111 | 00101110 | rr(n, m)" "asm"="ucomiss {m}, {n}" "sets"="zcp" "nodecode" {
  %a = fpext float %n to double
  %b = fpext float %m to double
  %f0 = insertvalue %fflags poison, double %a, 0
  %f = insertvalue %fflags %f0, double %b, 1
  ret %fflags %f
}

define %fflagsr @UCOMISSrev(float "reg"="s" %n, float "reg"="s" %m) "enc"="rex(0, m, 0, n) | 00001111 | 00101110 | rr(m, n)" "asm"="ucomiss {n}, {m}" "sets"="zcp" "nodecode" {
  %a = fpext float %n to double
  %b = fpext float %m to double
  %f0 = insertvalue %fflagsr poison, double %a, 0
  %f = insertvalue %fflagsr %f0, double %b, 1
  ret %fflagsr %f
}

define float @ADDSS(float "reg"="s" "tied" %n, float "reg"="s" %m) "enc"="11110011 | rex(0, d, 0, m) | 00001111 | 01011000 | rr(d, m)" "asm"="addss {m}, {d}" "nodecode" {
  %r = fadd float %n, %m
  ret float %r
}

define float @SUBSS(float "reg"="s" "tied" %n, float "reg"="s" %m) "enc"="11110011 | rex(0, d, 0, m) | 00001111 | 01011100 | rr(d, m)" "asm"="subss {m}, {d}" "nodecode" {
  %r = fsub float %n, %m
  ret float %r
}

define float @MULSS(float "reg"="s" "tied" %n, float "reg"="s" %m) "enc"="11110011 | rex(0, d, 0, m) | 00001111 | 01011001 | rr(d, m)" "asm"="mulss {m}, {d}" "nodecode" {
  %r = fmul float %n, %m
  ret float %r
}

define float @DIVSS(float "reg"="s" "tied" %n, float "reg"="s" %m) "enc"="11110011 | rex(0, d, 0, m) | 00001111 | 01011110 | rr(d, m)" "asm"="divss {m}, {d}" "nodecode" {
  %r = fdiv float %n, %m
  ret float %r
}

define float @SQRTSS(float "reg"="s" %n) "enc"="11110011 | rex(0, d, 0, n) | 00001111 | 01010001 | rr(d, n)" "asm"="sqrtss {n}, {d}" "nodecode" {
  %r = call float @llvm.sqrt.f32(float %n)
  ret float %r
}

declare float @llvm.sqrt.f32(float)

define float @LDSS(ptr "reg"="r64" %n, i64 "imm" %off) "enc"="11110011 | rex(0, d, 4, n) | 00001111 | 00010000 | rm(d, n, 4, 1, off, 0, 1)" "asm"="movss {off}({n}), {d}" "role"="load.s" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  %r = load float, ptr %a
  ret float %r
}

define void @STSS(float "reg"="s" %t, ptr "reg"="r64" %n, i64 "imm" %off) "enc"="11110011 | rex(0, t, 4, n) | 00001111 | 00010001 | rm(t, n, 4, 1, off, 0, 1)" "asm"="movss {t}, {off}({n})" "role"="store.s" "nodecode" {
  %a = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %a
  ret void
}

define float @MOVSSfromi32(i32 "reg"="r32" %n) "enc"="01100110 | rex(0, d, 0, n) | 00001111 | 01101110 | rr(d, n)" "asm"="movd {n}, {d}" "role"="move.s.r32" "nodecode" {
  %r = bitcast i32 %n to float
  ret float %r
}

define i32 @MOVi32fromSS(float "reg"="s" %n) "enc"="01100110 | rex(0, n, 0, d) | 00001111 | 01111110 | rr(n, d)" "asm"="movd {n}, {d}" "role"="move.r32.s" "nodecode" {
  %r = bitcast float %n to i32
  ret i32 %r
}

define float @CVTSITOFPI32SS(i32 "reg"="r32" %n) "enc"="11110011 | rex(0, d, 0, n) | 00001111 | 00101010 | rr(d, n)" "asm"="cvtsi2ss {n}, {d}" "nodecode" {
  %r = sitofp i32 %n to float
  ret float %r
}

define float @CVTSITOFPI64SS(i64 "reg"="r64" %n) "enc"="11110011 | rex(1, d, 0, n) | 00001111 | 00101010 | rr(d, n)" "asm"="cvtsi2ss {n}, {d}" "nodecode" {
  %r = sitofp i64 %n to float
  ret float %r
}

define float @CVTUITOFPI32SS(i32 "reg"="r32" %n) "enc"="11110011 | rex(1, d, 0, n) | 00001111 | 00101010 | rr(d, n)" "asm"="cvtsi2ss {n:r64}, {d}" "nodecode" {
  %r = uitofp i32 %n to float
  ret float %r
}

define i32 @CVTTFPTOSISSI32(float "reg"="s" %n) "enc"="11110011 | rex(0, d, 0, n) | 00001111 | 00101100 | rr(d, n)" "asm"="cvttss2si {n}, {d}" "dclass"="r32" "nodecode" {
  %r = fptosi float %n to i32
  ret i32 %r
}

define i64 @CVTTFPTOSISSI64(float "reg"="s" %n) "enc"="11110011 | rex(1, d, 0, n) | 00001111 | 00101100 | rr(d, n)" "asm"="cvttss2si {n}, {d}" "dclass"="r64" "nodecode" {
  %r = fptosi float %n to i64
  ret i64 %r
}

define i32 @CVTTFPTOUISSI32(float "reg"="s" %n) "enc"="11110011 | rex(1, d, 0, n) | 00001111 | 00101100 | rr(d, n)" "asm"="cvttss2si {n}, {d:r64}" "dclass"="r32" "nodecode" {
  %r = fptoui float %n to i32
  ret i32 %r
}

define float @select.s(i1 "reg"="r32" %c, float "reg"="s" %a, float "reg"="s" %b) "recipe"="select.s.expand" {
  %r = select i1 %c, float %a, float %b
  ret float %r
}

define float @select.s.expand(i1 %c, float %a, float %b) {
  %ai = call i32 @MOVi32fromSS(float %a)
  %bi = call i32 @MOVi32fromSS(float %b)
  %f = call %flags @TESTB1(i1 %c)
  %ne = call i1 @cc.ne(%flags %f)
  %ri = call i32 @CMOV32(i1 %ne, i32 %ai, i32 %bi)
  %r = call float @MOVSSfromi32(i32 %ri)
  ret float %r
}

define float @fneg.s(float "reg"="s" %a) "recipe"="fneg.s.expand" {
  %r = fneg float %a
  ret float %r
}

define float @fneg.s.expand(float %a) {
  %ai = call i32 @MOVi32fromSS(float %a)
  %k = call i32 @MOV32ri(i32 -2147483648)
  %x = call i32 @XOR32rr(i32 %ai, i32 %k)
  %r = call float @MOVSSfromi32(i32 %x)
  ret float %r
}

define float @fabs.s(float "reg"="s" %a) "recipe"="fabs.s.expand" {
  %r = call float @llvm.fabs.f32(float %a)
  ret float %r
}

define float @fabs.s.expand(float %a) {
  %ai = call i32 @MOVi32fromSS(float %a)
  %k = call i32 @MOV32ri(i32 2147483647)
  %x = call i32 @AND32rr(i32 %ai, i32 %k)
  %r = call float @MOVSSfromi32(i32 %x)
  ret float %r
}

declare float @llvm.fabs.f32(float)

declare float @llvm.fmuladd.f32(float, float, float)

define float @fmuladd.s(float "reg"="s" %a, float "reg"="s" %b, float "reg"="s" %c) "recipe"="fmuladd.s.expand" {
  %r = call float @llvm.fmuladd.f32(float %a, float %b, float %c)
  ret float %r
}

define float @fmuladd.s.expand(float %a, float %b, float %c) {
  %p = call float @MULSS(float %a, float %b)
  %r = call float @ADDSS(float %p, float %c)
  ret float %r
}

define float @uitofp.64.s(i64 "reg"="r64" %x) "recipe"="uitofp.64.s.expand" {
  %r = uitofp i64 %x to float
  ret float %r
}

define float @uitofp.64.s.expand(i64 %x) {
  %h = call i64 @SHR64ri(i64 %x, i64 1)
  %l = call i64 @AND64ri(i64 %x, i64 1)
  %o = call i64 @OR64rr(i64 %h, i64 %l)
  %f1 = call %flags @TEST64rr(i64 %x, i64 %x)
  %n1 = call i1 @cc.l(%flags %f1)
  %t = call i64 @CMOV64(i1 %n1, i64 %o, i64 %x)
  %c = call float @CVTSITOFPI64SS(i64 %t)
  %c2 = call float @ADDSS(float %c, float %c)
  %ci = call i32 @MOVi32fromSS(float %c)
  %c2i = call i32 @MOVi32fromSS(float %c2)
  %f2 = call %flags @TEST64rr(i64 %x, i64 %x)
  %n2 = call i1 @cc.l(%flags %f2)
  %ri = call i32 @CMOV32(i1 %n2, i32 %c2i, i32 %ci)
  %r = call float @MOVSSfromi32(i32 %ri)
  ret float %r
}

define i64 @fptoui.64.s(float "reg"="s" %x) "recipe"="fptoui.64.s.expand" {
  %r = fptoui float %x to i64
  ret i64 %r
}

define i64 @fptoui.64.s.expand(float %x) {
  %a = call i64 @CVTTFPTOSISSI64(float %x)
  %ki = call i32 @MOV32ri(i32 1593835520)
  %k = call float @MOVSSfromi32(i32 %ki)
  %y = call float @SUBSS(float %x, float %k)
  %b = call i64 @CVTTFPTOSISSI64(float %y)
  %s = call i64 @SAR64ri(i64 %a, i64 63)
  %m = call i64 @AND64rr(i64 %b, i64 %s)
  %r = call i64 @OR64rr(i64 %a, i64 %m)
  ret i64 %r
}

define float @MOVDh(i16 "reg"="r32" %n) "enc"="01100110 | rex(0, d, 0, n) | 00001111 | 01101110 | rr(d, n)" "asm"="movd {n}, {d}" "role"="move.h.w" "nomatch" "nodecode" {
  %r = bitcast i32 0 to float
  ret float %r
}

define i16 @PEXTRWh(float "reg"="s" %n) "enc"="01100110 | rex(0, d, 0, n) | 00001111 | 11000101 | rr(d, n) | 00000000" "asm"="pextrw $0, {n}, {d}" "dclass"="r32" "zext"="16" "role"="move.w.h" "nomatch" "nodecode" {
  ret i16 0
}

define double @CVTSS2SD(float "reg"="s" %n) "enc"="11110011 | rex(0, d, 0, n) | 00001111 | 01011010 | rr(d, n)" "asm"="cvtss2sd {n}, {d}" "nodecode" {
  %r = fpext float %n to double
  ret double %r
}

define float @CVTSD2SS(double "reg"="d" %n) "enc"="11110010 | rex(0, d, 0, n) | 00001111 | 01011010 | rr(d, n)" "asm"="cvtsd2ss {n}, {d}" "nodecode" {
  %r = fptrunc double %n to float
  ret float %r
}

define i8 @LDAI8(ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 00001111 | 10110110 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="movzbl 0({n}), {d:r32}" "dclass"="r32" "nodecode" "zext"="8" {
  %r = load atomic i8, ptr %n acquire, align 1
  ret i8 %r
}

define void @STRI8(i8 "reg"="r32" %t, ptr "reg"="r64" %n) "enc"="{ if(t<4) rex(0, t, 4, n) ; 0100 0 R:1=(t)>>3 X:1=0 B:1=(n)>>3 } | 10001000 | rm(t, n, 4, 1, 0, 0, 1)" "asm"="movb {t:r8}, 0({n})" "nodecode" {
  store atomic i8 %t, ptr %n release, align 1
  ret void
}

define i8 @XCHGI80(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="{ if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 10000110 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgb {d:r8}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @XADDI80(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | { if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 11000000 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddb {d:r8}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @CMPXCHGI80(i8 "reg"="rax" "tied" %old, i8 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | { if(new<4) rex(0, new, 4, n) ; 0100 0 R:1=(new)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110000 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgb {new:r8}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 0)
  ret i8 %r
}

define i8 @XCHGI81(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="{ if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 10000110 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgb {d:r8}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @XADDI81(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | { if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 11000000 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddb {d:r8}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @CMPXCHGI81(i8 "reg"="rax" "tied" %old, i8 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | { if(new<4) rex(0, new, 4, n) ; 0100 0 R:1=(new)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110000 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgb {new:r8}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 1)
  ret i8 %r
}

define i8 @XCHGI82(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="{ if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 10000110 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgb {d:r8}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i8 %m release
  ret i8 %r
}

define i8 @XADDI82(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | { if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 11000000 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddb {d:r8}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i8 %m release
  ret i8 %r
}

define i8 @CMPXCHGI82(i8 "reg"="rax" "tied" %old, i8 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | { if(new<4) rex(0, new, 4, n) ; 0100 0 R:1=(new)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110000 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgb {new:r8}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 2)
  ret i8 %r
}

define i8 @XCHGI83(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="{ if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 10000110 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgb {d:r8}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @XADDI83(i8 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | { if(d<4) rex(0, d, 4, n) ; 0100 0 R:1=(d)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 11000000 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddb {d:r8}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @CMPXCHGI83(i8 "reg"="rax" "tied" %old, i8 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | { if(new<4) rex(0, new, 4, n) ; 0100 0 R:1=(new)>>3 X:1=0 B:1=(n)>>3 } | 00001111 | 10110000 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgb {new:r8}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 3)
  ret i8 %r
}

declare i8 @llvm.epitome.cmpxchg.i8(ptr, i8, i8, i32)

define i16 @LDAI16(ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 00001111 | 10110111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="movzwl 0({n}), {d:r32}" "dclass"="r32" "nodecode" "zext"="16" {
  %r = load atomic i16, ptr %n acquire, align 2
  ret i16 %r
}

define void @STRI16(i16 "reg"="r32" %t, ptr "reg"="r64" %n) "enc"="01100110 | rex(0, t, 4, n) | 10001001 | rm(t, n, 4, 1, 0, 0, 1)" "asm"="movw {t:r16}, 0({n})" "nodecode" {
  store atomic i16 %t, ptr %n release, align 2
  ret void
}

define i16 @XCHGI160(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgw {d:r16}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @XADDI160(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddw {d:r16}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @CMPXCHGI160(i16 "reg"="rax" "tied" %old, i16 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgw {new:r16}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 0)
  ret i16 %r
}

define i16 @XCHGI161(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgw {d:r16}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @XADDI161(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddw {d:r16}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @CMPXCHGI161(i16 "reg"="rax" "tied" %old, i16 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgw {new:r16}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 1)
  ret i16 %r
}

define i16 @XCHGI162(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgw {d:r16}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i16 %m release
  ret i16 %r
}

define i16 @XADDI162(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddw {d:r16}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i16 %m release
  ret i16 %r
}

define i16 @CMPXCHGI162(i16 "reg"="rax" "tied" %old, i16 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgw {new:r16}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 2)
  ret i16 %r
}

define i16 @XCHGI163(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgw {d:r16}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @XADDI163(i16 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddw {d:r16}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @CMPXCHGI163(i16 "reg"="rax" "tied" %old, i16 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="01100110 | 11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgw {new:r16}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 3)
  ret i16 %r
}

declare i16 @llvm.epitome.cmpxchg.i16(ptr, i16, i16, i32)

define i32 @LDAI32(ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 10001011 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="movl 0({n}), {d}" "dclass"="r32" "nodecode" {
  %r = load atomic i32, ptr %n acquire, align 4
  ret i32 %r
}

define void @STRI32(i32 "reg"="r32" %t, ptr "reg"="r64" %n) "enc"="rex(0, t, 4, n) | 10001001 | rm(t, n, 4, 1, 0, 0, 1)" "asm"="movl {t}, 0({n})" "nodecode" {
  store atomic i32 %t, ptr %n release, align 4
  ret void
}

define i32 @XCHGI320(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgl {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @XADDI320(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddl {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @CMPXCHGI320(i32 "reg"="rax" "tied" %old, i32 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgl {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 0)
  ret i32 %r
}

define i32 @XCHGI321(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgl {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @XADDI321(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddl {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @CMPXCHGI321(i32 "reg"="rax" "tied" %old, i32 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgl {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 1)
  ret i32 %r
}

define i32 @XCHGI322(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgl {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i32 %m release
  ret i32 %r
}

define i32 @XADDI322(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddl {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i32 %m release
  ret i32 %r
}

define i32 @CMPXCHGI322(i32 "reg"="rax" "tied" %old, i32 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgl {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 2)
  ret i32 %r
}

define i32 @XCHGI323(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(0, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgl {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @XADDI323(i32 "reg"="r32" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddl {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @CMPXCHGI323(i32 "reg"="rax" "tied" %old, i32 "reg"="r32" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(0, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgl {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 3)
  ret i32 %r
}

declare i32 @llvm.epitome.cmpxchg.i32(ptr, i32, i32, i32)

define i64 @LDAI64(ptr "reg"="r64" %n) "enc"="rex(1, d, 4, n) | 10001011 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="movq 0({n}), {d}" "dclass"="r64" "nodecode" {
  %r = load atomic i64, ptr %n acquire, align 8
  ret i64 %r
}

define void @STRI64(i64 "reg"="r64" %t, ptr "reg"="r64" %n) "enc"="rex(1, t, 4, n) | 10001001 | rm(t, n, 4, 1, 0, 0, 1)" "asm"="movq {t}, 0({n})" "nodecode" {
  store atomic i64 %t, ptr %n release, align 8
  ret void
}

define i64 @XCHGI640(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(1, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgq {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @XADDI640(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddq {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @CMPXCHGI640(i64 "reg"="rax" "tied" %old, i64 "reg"="r64" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgq {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 0)
  ret i64 %r
}

define i64 @XCHGI641(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(1, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgq {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @XADDI641(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddq {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @CMPXCHGI641(i64 "reg"="rax" "tied" %old, i64 "reg"="r64" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgq {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 1)
  ret i64 %r
}

define i64 @XCHGI642(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(1, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgq {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i64 %m release
  ret i64 %r
}

define i64 @XADDI642(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddq {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i64 %m release
  ret i64 %r
}

define i64 @CMPXCHGI642(i64 "reg"="rax" "tied" %old, i64 "reg"="r64" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgq {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 2)
  ret i64 %r
}

define i64 @XCHGI643(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="rex(1, d, 4, n) | 10000111 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="xchgq {d}, 0({n})" "nodecode" {
  %r = atomicrmw xchg ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @XADDI643(i64 "reg"="r64" "tied" %m, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, d, 4, n) | 00001111 | 11000001 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="lock xaddq {d}, 0({n})" "clobbers"="flags" "nodecode" {
  %r = atomicrmw add ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @CMPXCHGI643(i64 "reg"="rax" "tied" %old, i64 "reg"="r64" %new, ptr "reg"="r64" %n) "enc"="11110000 | rex(1, new, 4, n) | 00001111 | 10110001 | rm(new, n, 4, 1, 0, 0, 1)" "asm"="lock cmpxchgq {new}, 0({n})" "dclass"="rax" "clobbers"="flags" "nodecode" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 3)
  ret i64 %r
}

declare i64 @llvm.epitome.cmpxchg.i64(ptr, i64, i64, i32)

define ptr @LDAP(ptr "reg"="r64" %n) "enc"="rex(1, d, 4, n) | 10001011 | rm(d, n, 4, 1, 0, 0, 1)" "asm"="movq 0({n}), {d}" "nodecode" {
  %r = load atomic ptr, ptr %n acquire, align 8
  ret ptr %r
}

define void @STRP(ptr "reg"="r64" %t, ptr "reg"="r64" %n) "enc"="rex(1, t, 4, n) | 10001001 | rm(t, n, 4, 1, 0, 0, 1)" "asm"="movq {t}, 0({n})" "nodecode" {
  store atomic ptr %t, ptr %n release, align 8
  ret void
}

define void @MFENCE() "enc"="00001111 | 10101110 | 11110000" "asm"="mfence" "nodecode" {
  fence seq_cst
  ret void
}

define void @MFENCEA() "enc"="00001111 | 10101110 | 11110000" "asm"="mfence" "nodecode" {
  fence acquire
  ret void
}

define <2 x i64> @MOVAPSrr(<2 x i64> "reg"="x" %n) "enc"="rex(0, d, 0, n) | 00001111 | 00101000 | rr(d, n)" "asm"="movaps {n}, {d}" "copy"="x" "nodecode" {
  ret <2 x i64> %n
}

define <2 x i64> @VMOVAPSxe(<2 x i64> "reg"="xe" %n) "enc"="{ if(n<8) vex(d, 0, n, 1, 0, 0, 0, 0) | 00101000 | rr(d, n) ; if(d<8) vex(n, 0, d, 1, 0, 0, 0, 0) | 00101001 | rr(n, d) ; vex(d, 0, n, 1, 0, 0, 0, 0) | 00101000 | rr(d, n) ; evexr(d, n, 1, 0, 0, 0, 0, 0, 0, 0) | 00101000 | rr(d, n) }" "asm"="vmovaps {n}, {d}" "copy"="xe" "dclass"="xe" "nodecode" {
  ret <2 x i64> %n
}

define <4 x i64> @VMOVAPSye(<4 x i64> "reg"="ye" %n) "enc"="{ if(n<8) vex(d, 0, n, 1, 0, 0, 1, 0) | 00101000 | rr(d, n) ; if(d<8) vex(n, 0, d, 1, 0, 0, 1, 0) | 00101001 | rr(n, d) ; vex(d, 0, n, 1, 0, 0, 1, 0) | 00101000 | rr(d, n) ; evexr(d, n, 1, 0, 0, 1, 0, 0, 0, 0) | 00101000 | rr(d, n) }" "asm"="vmovaps {n}, {d}" "copy"="ye" "dclass"="ye" "nodecode" {
  ret <4 x i64> %n
}

define <8 x i64> @VMOVAPSz(<8 x i64> "reg"="z" %n) "enc"="evexr(d, n, 1, 0, 0, 2, 0, 0, 0, 0) | 00101000 | rr(d, n)" "asm"="vmovaps {n}, {d}" "copy"="z" "nodecode" {
  ret <8 x i64> %n
}

define i64 @KMOVQ(i64 "reg"="k" %n) "enc"="vex(d, 0, n, 1, 1, 0, 0, 0) | 10010000 | rr(d, n)" "asm"="kmovq {n}, {d}" "copy"="k" "dclass"="k" "nodecode" {
  ret i64 %n
}
