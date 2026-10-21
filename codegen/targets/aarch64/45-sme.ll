; The Scalable Matrix Extension (SME): enough to multiply matrices of f32
; with outer products into the ZA array, a tile at a time.
;
; In streaming mode, between smstart and smstop, the machine has its own
; vector length (SVL: 512 bits on Apple's M4, so a tile of 32-bit elements
; is 16 x 16), and the Z and P registers and the ZA array. Epitome does not
; allocate Z or P registers: these entries name fixed ones in their
; encodings, and a recipe joins the instructions that use them, so that
; nothing else comes between. ZA's tile za0.s is the one used.
;
; - smstart and smstop zero every vector register, so they clobber d0-d31:
;   the frame saves the callee-saved d8-d15 of a function that uses them,
;   and no floating-point value stays in a register across them.
; - In streaming mode, Advanced SIMD and floating-point instructions are not
;   allowed (without FEAT_SME_FA64), so code between smstart and smstop is
;   integer arithmetic, loads and stores of integers, and these entries.
; - A slice of ZA is chosen by w12 (w12 to w15 can choose one) plus an
;   immediate; the recipes set w12 just before each use, and say so with
;   "clobbers".
;
; The intrinsics are Epitome's own (llvm.epitome.sme.*), as LLVM's
; llvm.aarch64.sme.* take scalable vectors and predicates as values, which
; Epitome does not allocate. Encodings are checked against clang's assembler
; (-march=armv9-a+sme).

declare void @llvm.epitome.sme.start()
declare void @llvm.epitome.sme.stop()
declare void @llvm.epitome.sme.zero.za()
declare void @llvm.epitome.sme.ptrue.p0.s()
declare void @llvm.epitome.sme.whilelt.p1.s(i64)
declare void @llvm.epitome.sme.fmopa.za0.s(ptr, ptr)
declare void @llvm.epitome.sme.ld1w.za0h.s(ptr, i32)
declare void @llvm.epitome.sme.st1w.za0h.s(ptr, i32)

; Streaming mode and ZA on, and off: PSTATE.SM and PSTATE.ZA together.
define void @SMSTART() "feature"="sme" "enc"="11010101000000110100011101111111" "asm"="smstart" "clobbers"="d0-d31" {
  call void @llvm.epitome.sme.start()
  ret void
}

define void @SMSTOP() "feature"="sme" "enc"="11010101000000110100011001111111" "asm"="smstop" "clobbers"="d0-d31" {
  call void @llvm.epitome.sme.stop()
  ret void
}

; All of ZA to zero.
define void @ZEROZA() "feature"="sme" "enc"="11000000000010000000000011111111" "asm"="zero {lb}za{rb}" {
  call void @llvm.epitome.sme.zero.za()
  ret void
}

; Predicates: p0 all 32-bit lanes; p1 the first n of them, for a tile's
; columns (n may be less than a tile is wide, at the edge of a matrix).
define void @PTRUEP0S() "feature"="sme" "enc"="00100101100110001110001111100000" "asm"="ptrue p0.s" {
  call void @llvm.epitome.sme.ptrue.p0.s()
  ret void
}

define void @WHILELTP1S(i64 "reg"="x" %n) "feature"="sme" "enc"="00100101 10 1 n:5 000101 11111 0 0001" "asm"="whilelt p1.s, xzr, {n}" {
  call void @llvm.epitome.sme.whilelt.p1.s(i64 %n)
  ret void
}

; The pieces of the recipes below: they use the registers the recipes
; leave them, so they are not chosen alone.
declare void @llvm.epitome.sme.piece()

define void @LD1WZ0P0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000000 101000 a:5 00000" "asm"="ld1w {lb}z0.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ1P1(ptr "reg"="xsp" %b) "feature"="sme" "enc"="1010010101000000 101001 b:5 00001" "asm"="ld1w {lb}z1.s{rb}, p1/z, [{b}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA0S() "feature"="sme" "enc"="10000000100000010010000000000000" "asm"="fmopa za0.s, p0/m, p1/m, z0.s, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVW12(i32 "reg"="w" %s) "feature"="sme" "enc"="00101010000 s:5 00000011111 01100" "asm"="mov w12, {s}" "clobbers"="x12" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZA0HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010011111000001 p:5 00000" "asm"="ld1w {lb}za0h.s[w12, 0]{rb}, p1/z, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZA0HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010111111000001 p:5 00000" "asm"="st1w {lb}za0h.s[w12, 0]{rb}, p1, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

; za0.s += a x b, the outer product of a column of 32-bit floats at a (all
; lanes, p0) and a row at b (the first lanes, p1).
define void @sme.fmopa(ptr "reg"="xsp" %a, ptr "reg"="xsp" %b) "feature"="sme" "recipe"="sme.fmopa.expand" {
  call void @llvm.epitome.sme.fmopa.za0.s(ptr %a, ptr %b)
  ret void
}

define void @sme.fmopa.expand(ptr %a, ptr %b) {
  call void @LD1WZ0P0(ptr %a)
  call void @LD1WZ1P1(ptr %b)
  call void @FMOPAZA0S()
  ret void
}

; Row `slice` of za0.s from memory at p, and to it: the first lanes (p1).
define void @sme.ld1w.za0h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.ld1w.za0h.expand" {
  call void @llvm.epitome.sme.ld1w.za0h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.ld1w.za0h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @LD1WZA0HW12(ptr %p)
  ret void
}

define void @sme.st1w.za0h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.st1w.za0h.expand" {
  call void @llvm.epitome.sme.st1w.za0h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.st1w.za0h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @ST1WZA0HW12(ptr %p)
  ret void
}

; ---------------------------------------------------------------------------
; Four tiles at once: za0.s to za3.s hold a 64 x 16 block (rows 0-15, 16-31,
; 32-47, 48-63). For each k, a column of 64 elements is four vectors loaded
; from one address with "mul vl" offsets (z0-z3), the row of 16 one more
; (z4), and four outer products into the four tiles do not wait for each
; other.

declare void @llvm.epitome.sme.fmopa4.za.s(ptr, ptr)
declare void @llvm.epitome.sme.ld1w.za1h.s(ptr, i32)
declare void @llvm.epitome.sme.ld1w.za2h.s(ptr, i32)
declare void @llvm.epitome.sme.ld1w.za3h.s(ptr, i32)
declare void @llvm.epitome.sme.st1w.za1h.s(ptr, i32)
declare void @llvm.epitome.sme.st1w.za2h.s(ptr, i32)
declare void @llvm.epitome.sme.st1w.za3h.s(ptr, i32)

define void @LD1WZ1P0VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000001 101000 a:5 00001" "asm"="ld1w {lb}z1.s{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ2P0VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000010 101000 a:5 00010" "asm"="ld1w {lb}z2.s{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ3P0VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000011 101000 a:5 00011" "asm"="ld1w {lb}z3.s{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ4P1(ptr "reg"="xsp" %b) "feature"="sme" "enc"="1010010101000000 101001 b:5 00100" "asm"="ld1w {lb}z4.s{rb}, p1/z, [{b}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA0Z4() "feature"="sme" "enc"="10000000100001000010000000000000" "asm"="fmopa za0.s, p0/m, p1/m, z0.s, z4.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA1Z4() "feature"="sme" "enc"="10000000100001000010000000100001" "asm"="fmopa za1.s, p0/m, p1/m, z1.s, z4.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA2Z4() "feature"="sme" "enc"="10000000100001000010000001000010" "asm"="fmopa za2.s, p0/m, p1/m, z2.s, z4.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA3Z4() "feature"="sme" "enc"="10000000100001000010000001100011" "asm"="fmopa za3.s, p0/m, p1/m, z3.s, z4.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZA1HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010011111000001 p:5 00100" "asm"="ld1w {lb}za1h.s[w12, 0]{rb}, p1/z, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZA2HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010011111000001 p:5 01000" "asm"="ld1w {lb}za2h.s[w12, 0]{rb}, p1/z, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZA3HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010011111000001 p:5 01100" "asm"="ld1w {lb}za3h.s[w12, 0]{rb}, p1/z, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZA1HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010111111000001 p:5 00100" "asm"="st1w {lb}za1h.s[w12, 0]{rb}, p1, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZA2HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010111111000001 p:5 01000" "asm"="st1w {lb}za2h.s[w12, 0]{rb}, p1, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZA3HW12(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010111111000001 p:5 01100" "asm"="st1w {lb}za3h.s[w12, 0]{rb}, p1, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

; za0.s-za3.s += a x b: a column of 64 elements at a (all lanes), a row at b
; (the first lanes, p1).
define void @sme.fmopa4(ptr "reg"="xsp" %a, ptr "reg"="xsp" %b) "feature"="sme" "recipe"="sme.fmopa4.expand" {
  call void @llvm.epitome.sme.fmopa4.za.s(ptr %a, ptr %b)
  ret void
}

define void @sme.fmopa4.expand(ptr %a, ptr %b) {
  call void @LD1WZ0P0(ptr %a)
  call void @LD1WZ1P0VL1(ptr %a)
  call void @LD1WZ2P0VL2(ptr %a)
  call void @LD1WZ3P0VL3(ptr %a)
  call void @LD1WZ4P1(ptr %b)
  call void @FMOPAZA0Z4()
  call void @FMOPAZA1Z4()
  call void @FMOPAZA2Z4()
  call void @FMOPAZA3Z4()
  ret void
}

define void @sme.ld1w.za1h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.ld1w.za1h.expand" {
  call void @llvm.epitome.sme.ld1w.za1h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.ld1w.za1h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @LD1WZA1HW12(ptr %p)
  ret void
}

define void @sme.st1w.za1h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.st1w.za1h.expand" {
  call void @llvm.epitome.sme.st1w.za1h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.st1w.za1h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @ST1WZA1HW12(ptr %p)
  ret void
}

define void @sme.ld1w.za2h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.ld1w.za2h.expand" {
  call void @llvm.epitome.sme.ld1w.za2h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.ld1w.za2h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @LD1WZA2HW12(ptr %p)
  ret void
}

define void @sme.st1w.za2h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.st1w.za2h.expand" {
  call void @llvm.epitome.sme.st1w.za2h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.st1w.za2h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @ST1WZA2HW12(ptr %p)
  ret void
}

define void @sme.ld1w.za3h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.ld1w.za3h.expand" {
  call void @llvm.epitome.sme.ld1w.za3h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.ld1w.za3h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @LD1WZA3HW12(ptr %p)
  ret void
}

define void @sme.st1w.za3h(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.st1w.za3h.expand" {
  call void @llvm.epitome.sme.st1w.za3h.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.st1w.za3h.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @ST1WZA3HW12(ptr %p)
  ret void
}

; ---------------------------------------------------------------------------
; Four tiles side by side: za0.s to za3.s hold a 16 x 64 block (columns 0-15,
; 16-31, 32-47, 48-63). For each k, a column of 16 elements (z0) by a row of
; 64 loaded as four vectors from one address (z4-z7): 256 contiguous bytes
; of the row, so that a matrix streamed from memory has four lines in
; flight, not one.

declare void @llvm.epitome.sme.fmopa4w.za.s(ptr, ptr)

define void @LD1WZ4P0(ptr "reg"="xsp" %b) "feature"="sme" "enc"="1010010101000000 101000 b:5 00100" "asm"="ld1w {lb}z4.s{rb}, p0/z, [{b}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ5P0VL1(ptr "reg"="xsp" %b) "feature"="sme" "enc"="1010010101000001 101000 b:5 00101" "asm"="ld1w {lb}z5.s{rb}, p0/z, [{b}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ6P0VL2(ptr "reg"="xsp" %b) "feature"="sme" "enc"="1010010101000010 101000 b:5 00110" "asm"="ld1w {lb}z6.s{rb}, p0/z, [{b}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ7P0VL3(ptr "reg"="xsp" %b) "feature"="sme" "enc"="1010010101000011 101000 b:5 00111" "asm"="ld1w {lb}z7.s{rb}, p0/z, [{b}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA1Z0Z5() "feature"="sme" "enc"="10000000100001010010000000000001" "asm"="fmopa za1.s, p0/m, p1/m, z0.s, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA2Z0Z6() "feature"="sme" "enc"="10000000100001100010000000000010" "asm"="fmopa za2.s, p0/m, p1/m, z0.s, z6.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMOPAZA3Z0Z7() "feature"="sme" "enc"="10000000100001110010000000000011" "asm"="fmopa za3.s, p0/m, p1/m, z0.s, z7.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

; za0.s-za3.s += a x b: a column of 16 at a, a row of 64 at b (all lanes:
; p1 must be all true).
define void @sme.fmopa4w(ptr "reg"="xsp" %a, ptr "reg"="xsp" %b) "feature"="sme" "recipe"="sme.fmopa4w.expand" {
  call void @llvm.epitome.sme.fmopa4w.za.s(ptr %a, ptr %b)
  ret void
}

define void @sme.fmopa4w.expand(ptr %a, ptr %b) {
  call void @LD1WZ0P0(ptr %a)
  call void @LD1WZ4P0(ptr %b)
  call void @LD1WZ5P0VL1(ptr %b)
  call void @LD1WZ6P0VL2(ptr %b)
  call void @LD1WZ7P0VL3(ptr %b)
  call void @FMOPAZA0Z4()
  call void @FMOPAZA1Z0Z5()
  call void @FMOPAZA2Z0Z6()
  call void @FMOPAZA3Z0Z7()
  ret void
}

; ---------------------------------------------------------------------------
; A vertical slice of za0.s, a column of the tile, to memory: with a
; horizontal load of each row before, it transposes a 16 x 16 block.

declare void @llvm.epitome.sme.st1w.za0v.s(ptr, i32)

define void @ST1WZA0VW12P0(ptr "reg"="xsp" %p) "feature"="sme" "enc"="1110000010111111100000 p:5 00000" "asm"="st1w {lb}za0v.s[w12, 0]{rb}, p0, [{p}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @sme.st1w.za0v(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.st1w.za0v.expand" {
  call void @llvm.epitome.sme.st1w.za0v.s(ptr %p, i32 %slice)
  ret void
}

define void @sme.st1w.za0v.expand(ptr %p, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @ST1WZA0VW12P0(ptr %p)
  ret void
}

; ---------------------------------------------------------------------------
; BF16: widening outer products, za.s += the sum over each pair of halves
; of z0.h and z4.h (bfmopa, SME_B16F32), with every half active (ptrue
; .h, which also makes every word active). A row of f32 becomes a row of
; BF16 pairs with ld2w (even and odd elements apart), bfcvt and bfcvtnt
; (rounding to nearest, into the bottom and top half of each word), and
; goes into a horizontal slice of za0.s (mova), to be transposed a word at
; a time.

declare void @llvm.epitome.sme.ptrue.p0.h()
declare void @llvm.epitome.sme.ptrue.p1.h()
declare void @llvm.epitome.sme.bfmopa4w.za.s(ptr, ptr)
declare void @llvm.epitome.sme.bf16.row.za0h(ptr, i32)

define void @PTRUEP0H() "feature"="sme" "enc"="00100101010110001110001111100000" "asm"="ptrue p0.h" {
  call void @llvm.epitome.sme.ptrue.p0.h()
  ret void
}

define void @PTRUEP1H() "feature"="sme" "enc"="00100101010110001110001111100001" "asm"="ptrue p1.h" {
  call void @llvm.epitome.sme.ptrue.p1.h()
  ret void
}

define void @BFMOPAZA0Z0Z4() "feature"="sme" "enc"="10000001100001000010000000000000" "asm"="bfmopa za0.s, p0/m, p1/m, z0.h, z4.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @BFMOPAZA1Z0Z5() "feature"="sme" "enc"="10000001100001010010000000000001" "asm"="bfmopa za1.s, p0/m, p1/m, z0.h, z5.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @BFMOPAZA2Z0Z6() "feature"="sme" "enc"="10000001100001100010000000000010" "asm"="bfmopa za2.s, p0/m, p1/m, z0.h, z6.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @BFMOPAZA3Z0Z7() "feature"="sme" "enc"="10000001100001110010000000000011" "asm"="bfmopa za3.s, p0/m, p1/m, z0.h, z7.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD2WZ2Z3P0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010100100000111000 a:5 00010" "asm"="ld2w {lb} z2.s, z3.s {rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @BFCVTZ1Z2() "feature"="sme" "enc"="01100101100010101010000001000001" "asm"="bfcvt z1.h, p0/m, z2.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @BFCVTNTZ1Z3() "feature"="sme" "enc"="01100100100010101010000001100001" "asm"="bfcvtnt z1.h, p0/m, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZA0HW12Z1() "feature"="sme" "enc"="11000000100000000000000000100000" "asm"="mova za0h.s[w12, 0], p0/m, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

; za0.s-za3.s += a x b in BF16: at a, 16 pairs (a column of a block of 16
; rows, two k each); at b, 64 pairs (a row of 64 columns, two k each).
define void @sme.bfmopa4w(ptr "reg"="xsp" %a, ptr "reg"="xsp" %b) "feature"="sme" "recipe"="sme.bfmopa4w.expand" {
  call void @llvm.epitome.sme.bfmopa4w.za.s(ptr %a, ptr %b)
  ret void
}

define void @sme.bfmopa4w.expand(ptr %a, ptr %b) {
  call void @LD1WZ0P0(ptr %a)
  call void @LD1WZ4P0(ptr %b)
  call void @LD1WZ5P0VL1(ptr %b)
  call void @LD1WZ6P0VL2(ptr %b)
  call void @LD1WZ7P0VL3(ptr %b)
  call void @BFMOPAZA0Z0Z4()
  call void @BFMOPAZA1Z0Z5()
  call void @BFMOPAZA2Z0Z6()
  call void @BFMOPAZA3Z0Z7()
  ret void
}

; 32 f32 at p as 16 BF16 pairs, into horizontal slice %slice of za0.s.
define void @sme.bf16.row(ptr "reg"="xsp" %p, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.bf16.row.expand" {
  call void @llvm.epitome.sme.bf16.row.za0h(ptr %p, i32 %slice)
  ret void
}

define void @sme.bf16.row.expand(ptr %p, i32 %slice) {
  call void @LD2WZ2Z3P0(ptr %p)
  call void @BFCVTZ1Z2()
  call void @BFCVTNTZ1Z3()
  call void @MOVW12(i32 %slice)
  call void @MOVAZA0HW12Z1()
  ret void
}

; ---------------------------------------------------------------------------
; Int8: four-way outer products of signed bytes into 32-bit integers
; (smopa, SME_I8I32), every byte active (ptrue .b). A row of A is quantised
; in streaming SVE: its largest magnitude (fabs, fmax, fmaxv), 127 over it
; (fdivr), and each element times that, rounded (frintn, fcvtzs) and
; stored as a byte (st1b of words). A row of a tile becomes f32 again
; (mova, scvtf), scaled by its column's and its row's scales (fmul) and
; added to C.

declare void @llvm.epitome.sme.ptrue.p0.b()
declare void @llvm.epitome.sme.ptrue.p1.b()
declare void @llvm.epitome.sme.smopa4w.za.s(ptr, ptr)
declare void @llvm.epitome.sme.absmax.start()
declare void @llvm.epitome.sme.absmax.add(ptr)
declare void @llvm.epitome.sme.absmax.end(ptr)
declare void @llvm.epitome.sme.quantize16(ptr, ptr)
declare void @llvm.epitome.sme.i8.out.za0(ptr, ptr, ptr, i32)
declare void @llvm.epitome.sme.i8.out.za1(ptr, ptr, ptr, i32)
declare void @llvm.epitome.sme.i8.out.za2(ptr, ptr, ptr, i32)
declare void @llvm.epitome.sme.i8.out.za3(ptr, ptr, ptr, i32)

define void @PTRUEP0B() "feature"="sme" "enc"="00100101000110001110001111100000" "asm"="ptrue p0.b" {
  call void @llvm.epitome.sme.ptrue.p0.b()
  ret void
}

define void @PTRUEP1B() "feature"="sme" "enc"="00100101000110001110001111100001" "asm"="ptrue p1.b" {
  call void @llvm.epitome.sme.ptrue.p1.b()
  ret void
}

define void @MOVZ5ZERO() "feature"="sme" "enc"="00100101101110001100000000000101" "asm"="mov z5.s, #0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ1P0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000000101000 a:5 00001" "asm"="ld1w {lb}z1.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FABSZ1() "feature"="sme" "enc"="00000100100111001010000000100001" "asm"="fabs z1.s, p0/m, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ5Z1() "feature"="sme" "enc"="01100101100001101000000000100101" "asm"="fmax z5.s, p0/m, z5.s, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXVS5() "feature"="sme" "enc"="01100101100001100010000010100101" "asm"="fmaxv s5, p0, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @DUPZ5S5() "feature"="sme" "enc"="00000101001001000010000010100101" "asm"="mov z5.s, s5" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZ5P0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010101000000111000 a:5 00101" "asm"="st1w {lb}z5.s{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVZ3127() "feature"="sme" "enc"="00100101101110001100111111100011" "asm"="mov z3.s, #127" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SCVTFZ3() "feature"="sme" "enc"="01100101100101001010000001100011" "asm"="scvtf z3.s, p0/m, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FDIVRZ5Z3() "feature"="sme" "enc"="01100101100011001000000001100101" "asm"="fdivr z5.s, p0/m, z5.s, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ1Z5() "feature"="sme" "enc"="01100101100001010000100000100001" "asm"="fmul z1.s, z1.s, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FRINTNZ1() "feature"="sme" "enc"="01100101100000001010000000100001" "asm"="frintn z1.s, p0/m, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FCVTZSZ1() "feature"="sme" "enc"="01100101100111001010000000100001" "asm"="fcvtzs z1.s, p0/m, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1BZ1S(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010001000000111000 a:5 00001" "asm"="st1b {lb}z1.s{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ1ZA0H() "feature"="sme" "enc"="11000000100000100000000000000001" "asm"="mova z1.s, p0/m, za0h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SMOPAZA0Z0Z4() "feature"="sme" "enc"="10100000100001000010000000000000" "asm"="smopa za0.s, p0/m, p1/m, z0.b, z4.b" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ1ZA1H() "feature"="sme" "enc"="11000000100000100000000010000001" "asm"="mova z1.s, p0/m, za1h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SMOPAZA1Z0Z5() "feature"="sme" "enc"="10100000100001010010000000000001" "asm"="smopa za1.s, p0/m, p1/m, z0.b, z5.b" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ1ZA2H() "feature"="sme" "enc"="11000000100000100000000100000001" "asm"="mova z1.s, p0/m, za2h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SMOPAZA2Z0Z6() "feature"="sme" "enc"="10100000100001100010000000000010" "asm"="smopa za2.s, p0/m, p1/m, z0.b, z6.b" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ1ZA3H() "feature"="sme" "enc"="11000000100000100000000110000001" "asm"="mova z1.s, p0/m, za3h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SMOPAZA3Z0Z7() "feature"="sme" "enc"="10100000100001110010000000000011" "asm"="smopa za3.s, p0/m, p1/m, z0.b, z7.b" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SCVTFZ1() "feature"="sme" "enc"="01100101100101001010000000100001" "asm"="scvtf z1.s, p0/m, z1.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ2P0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000000101000 a:5 00010" "asm"="ld1w {lb}z2.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ1Z2() "feature"="sme" "enc"="01100101100000100000100000100001" "asm"="fmul z1.s, z1.s, z2.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1RWZ3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1000010101000000110000 a:5 00011" "asm"="ld1rw {lb}z3.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ1Z3() "feature"="sme" "enc"="01100101100000110000100000100001" "asm"="fmul z1.s, z1.s, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FADDZ1Z2() "feature"="sme" "enc"="01100101100000100000000000100001" "asm"="fadd z1.s, z1.s, z2.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZ1P0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010101000000111000 a:5 00001" "asm"="st1w {lb}z1.s{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @sme.smopa4w(ptr "reg"="xsp" %a, ptr "reg"="xsp" %b) "feature"="sme" "recipe"="sme.smopa4w.expand" {
  call void @llvm.epitome.sme.smopa4w.za.s(ptr %a, ptr %b)
  ret void
}

define void @sme.smopa4w.expand(ptr %a, ptr %b) {
  call void @LD1WZ0P0(ptr %a)
  call void @LD1WZ4P0(ptr %b)
  call void @LD1WZ5P0VL1(ptr %b)
  call void @LD1WZ6P0VL2(ptr %b)
  call void @LD1WZ7P0VL3(ptr %b)
  call void @SMOPAZA0Z0Z4()
  call void @SMOPAZA1Z0Z5()
  call void @SMOPAZA2Z0Z6()
  call void @SMOPAZA3Z0Z7()
  ret void
}

define void @sme.absmax.start() "feature"="sme" "recipe"="sme.absmax.start.expand" {
  call void @llvm.epitome.sme.absmax.start()
  ret void
}

define void @sme.absmax.start.expand() {
  call void @MOVZ5ZERO()
  ret void
}

define void @sme.absmax.add(ptr "reg"="xsp" %p) "feature"="sme" "recipe"="sme.absmax.add.expand" {
  call void @llvm.epitome.sme.absmax.add(ptr %p)
  ret void
}

define void @sme.absmax.add.expand(ptr %p) {
  call void @LD1WZ1P0(ptr %p)
  call void @FABSZ1()
  call void @FMAXZ5Z1()
  ret void
}

define void @sme.absmax.end(ptr "reg"="xsp" %p) "feature"="sme" "recipe"="sme.absmax.end.expand" {
  call void @llvm.epitome.sme.absmax.end(ptr %p)
  ret void
}

define void @sme.absmax.end.expand(ptr %p) {
  call void @FMAXVS5()
  call void @DUPZ5S5()
  call void @ST1WZ5P0(ptr %p)
  call void @MOVZ3127()
  call void @SCVTFZ3()
  call void @FDIVRZ5Z3()
  ret void
}

define void @sme.quantize16(ptr "reg"="xsp" %src, ptr "reg"="xsp" %dst) "feature"="sme" "recipe"="sme.quantize16.expand" {
  call void @llvm.epitome.sme.quantize16(ptr %src, ptr %dst)
  ret void
}

define void @sme.quantize16.expand(ptr %src, ptr %dst) {
  call void @LD1WZ1P0(ptr %src)
  call void @FMULZ1Z5()
  call void @FRINTNZ1()
  call void @FCVTZSZ1()
  call void @ST1BZ1S(ptr %dst)
  ret void
}

define void @sme.i8.out.za0(ptr "reg"="xsp" %c, ptr "reg"="xsp" %ws, ptr "reg"="xsp" %am, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.i8.out.za0.expand" {
  call void @llvm.epitome.sme.i8.out.za0(ptr %c, ptr %ws, ptr %am, i32 %slice)
  ret void
}

define void @sme.i8.out.za0.expand(ptr %c, ptr %ws, ptr %am, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @MOVAZ1ZA0H()
  call void @SCVTFZ1()
  call void @LD1WZ2P0(ptr %ws)
  call void @FMULZ1Z2()
  call void @LD1RWZ3(ptr %am)
  call void @FMULZ1Z3()
  call void @LD1WZ2P0(ptr %c)
  call void @FADDZ1Z2()
  call void @ST1WZ1P0(ptr %c)
  ret void
}

define void @sme.i8.out.za1(ptr "reg"="xsp" %c, ptr "reg"="xsp" %ws, ptr "reg"="xsp" %am, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.i8.out.za1.expand" {
  call void @llvm.epitome.sme.i8.out.za1(ptr %c, ptr %ws, ptr %am, i32 %slice)
  ret void
}

define void @sme.i8.out.za1.expand(ptr %c, ptr %ws, ptr %am, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @MOVAZ1ZA1H()
  call void @SCVTFZ1()
  call void @LD1WZ2P0(ptr %ws)
  call void @FMULZ1Z2()
  call void @LD1RWZ3(ptr %am)
  call void @FMULZ1Z3()
  call void @LD1WZ2P0(ptr %c)
  call void @FADDZ1Z2()
  call void @ST1WZ1P0(ptr %c)
  ret void
}

define void @sme.i8.out.za2(ptr "reg"="xsp" %c, ptr "reg"="xsp" %ws, ptr "reg"="xsp" %am, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.i8.out.za2.expand" {
  call void @llvm.epitome.sme.i8.out.za2(ptr %c, ptr %ws, ptr %am, i32 %slice)
  ret void
}

define void @sme.i8.out.za2.expand(ptr %c, ptr %ws, ptr %am, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @MOVAZ1ZA2H()
  call void @SCVTFZ1()
  call void @LD1WZ2P0(ptr %ws)
  call void @FMULZ1Z2()
  call void @LD1RWZ3(ptr %am)
  call void @FMULZ1Z3()
  call void @LD1WZ2P0(ptr %c)
  call void @FADDZ1Z2()
  call void @ST1WZ1P0(ptr %c)
  ret void
}

define void @sme.i8.out.za3(ptr "reg"="xsp" %c, ptr "reg"="xsp" %ws, ptr "reg"="xsp" %am, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.i8.out.za3.expand" {
  call void @llvm.epitome.sme.i8.out.za3(ptr %c, ptr %ws, ptr %am, i32 %slice)
  ret void
}

define void @sme.i8.out.za3.expand(ptr %c, ptr %ws, ptr %am, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @MOVAZ1ZA3H()
  call void @SCVTFZ1()
  call void @LD1WZ2P0(ptr %ws)
  call void @FMULZ1Z2()
  call void @LD1RWZ3(ptr %am)
  call void @FMULZ1Z3()
  call void @LD1WZ2P0(ptr %c)
  call void @FADDZ1Z2()
  call void @ST1WZ1P0(ptr %c)
  ret void
}

; ---------------------------------------------------------------------------
; FP8 (E4M3) to BF16, 32 weights at a time: a byte t becomes
; ((t & 0x80) << 8) | (((t & 0x7f) << 4) + bias), where bias, in z16-z19
; for the four vectors of a row of a panel, is (120 + e) << 7 for a column
; scaled by 2^e: the exponent moved from E4M3's bias (7) to BF16's (127),
; plus the scale. What a table of (FP8 value, scale) to BF16 would hold,
; worked out: SVE's gathers are not allowed in streaming mode on a machine
; without FEAT_SME_FA64 (M4). Zero and subnormal codes are never stored.

declare void @llvm.epitome.sme.fp8.bias(ptr)
declare void @llvm.epitome.sme.fp8.dequant(ptr, ptr)

define void @LSLZ2Z1H4() "feature"="sme" "enc"="00000100001101001001110000100010" "asm"="lsl z2.h, z1.h, #4" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ2H7F0() "feature"="sme" "enc"="00000101100000000110010011000010" "asm"="and z2.h, z2.h, #0x7f0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ1H8() "feature"="sme" "enc"="00000100001110001001110000100001" "asm"="lsl z1.h, z1.h, #8" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ1H8000() "feature"="sme" "enc"="00000101100000000000110000000001" "asm"="and z1.h, z1.h, #0x8000" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ORRZ2Z1() "feature"="sme" "enc"="00000100011000010011000001000010" "asm"="orr z2.d, z2.d, z1.d" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ1HVL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100000101000 a:5 00001" "asm"="ld1b {lb}z1.h{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ2VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100000111000 a:5 00010" "asm"="st1h {lb}z2.h{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1HZ16VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010010100000101000 a:5 10000" "asm"="ld1h {lb}z16.h{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ2Z16H() "feature"="sme" "enc"="00000100011100000000000001000010" "asm"="add z2.h, z2.h, z16.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ1HVL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100001101000 a:5 00001" "asm"="ld1b {lb}z1.h{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ2VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100001111000 a:5 00010" "asm"="st1h {lb}z2.h{rb}, p0, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1HZ17VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010010100001101000 a:5 10001" "asm"="ld1h {lb}z17.h{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ2Z17H() "feature"="sme" "enc"="00000100011100010000000001000010" "asm"="add z2.h, z2.h, z17.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ1HVL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100010101000 a:5 00001" "asm"="ld1b {lb}z1.h{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ2VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100010111000 a:5 00010" "asm"="st1h {lb}z2.h{rb}, p0, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1HZ18VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010010100010101000 a:5 10010" "asm"="ld1h {lb}z18.h{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ2Z18H() "feature"="sme" "enc"="00000100011100100000000001000010" "asm"="add z2.h, z2.h, z18.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ1HVL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100011101000 a:5 00001" "asm"="ld1b {lb}z1.h{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ2VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100011111000 a:5 00010" "asm"="st1h {lb}z2.h{rb}, p0, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1HZ19VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010010100011101000 a:5 10011" "asm"="ld1h {lb}z19.h{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ2Z19H() "feature"="sme" "enc"="00000100011100110000000001000010" "asm"="add z2.h, z2.h, z19.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

; The biases of a panel's 64 columns, each twice (two rows of a pair), into
; z16-z19.
define void @sme.fp8.bias(ptr "reg"="xsp" %p) "feature"="sme" "recipe"="sme.fp8.bias.expand" {
  call void @llvm.epitome.sme.fp8.bias(ptr %p)
  ret void
}

define void @sme.fp8.bias.expand(ptr %p) {
  call void @LD1HZ16VL0(ptr %p)
  call void @LD1HZ17VL1(ptr %p)
  call void @LD1HZ18VL2(ptr %p)
  call void @LD1HZ19VL3(ptr %p)
  ret void
}

; A row of a panel, 128 FP8 weights at src, as 128 BF16 at dst.
define void @sme.fp8.dequant(ptr "reg"="xsp" %src, ptr "reg"="xsp" %dst) "feature"="sme" "recipe"="sme.fp8.dequant.expand" {
  call void @llvm.epitome.sme.fp8.dequant(ptr %src, ptr %dst)
  ret void
}

define void @sme.fp8.dequant.expand(ptr %src, ptr %dst) {
  call void @LD1BZ1HVL0(ptr %src)
  call void @LSLZ2Z1H4()
  call void @ANDZ2H7F0()
  call void @ADDZ2Z16H()
  call void @LSLZ1H8()
  call void @ANDZ1H8000()
  call void @ORRZ2Z1()
  call void @ST1HZ2VL0(ptr %dst)
  call void @LD1BZ1HVL1(ptr %src)
  call void @LSLZ2Z1H4()
  call void @ANDZ2H7F0()
  call void @ADDZ2Z17H()
  call void @LSLZ1H8()
  call void @ANDZ1H8000()
  call void @ORRZ2Z1()
  call void @ST1HZ2VL1(ptr %dst)
  call void @LD1BZ1HVL2(ptr %src)
  call void @LSLZ2Z1H4()
  call void @ANDZ2H7F0()
  call void @ADDZ2Z18H()
  call void @LSLZ1H8()
  call void @ANDZ1H8000()
  call void @ORRZ2Z1()
  call void @ST1HZ2VL2(ptr %dst)
  call void @LD1BZ1HVL3(ptr %src)
  call void @LSLZ2Z1H4()
  call void @ANDZ2H7F0()
  call void @ADDZ2Z19H()
  call void @LSLZ1H8()
  call void @ANDZ1H8000()
  call void @ORRZ2Z1()
  call void @ST1HZ2VL3(ptr %dst)
  ret void
}

; ---------------------------------------------------------------------------
; The FP8 conversion and int8's quantising and scaling again, four vectors
; side by side in registers of their own (z20-z31) rather than one after
; another through z1-z3: a streaming SVE instruction waits for the one
; before it when that is its input, so a single chain runs at their latency.

define void @LD1BZ20HVL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100000101000 a:5 10100" "asm"="ld1b {lb}z20.h{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ24Z20H4() "feature"="sme" "enc"="00000100001101001001111010011000" "asm"="lsl z24.h, z20.h, #4" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ24H7F0() "feature"="sme" "enc"="00000101100000000110010011011000" "asm"="and z24.h, z24.h, #0x7f0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ24Z16H() "feature"="sme" "enc"="00000100011100000000001100011000" "asm"="add z24.h, z24.h, z16.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ20H8() "feature"="sme" "enc"="00000100001110001001111010010100" "asm"="lsl z20.h, z20.h, #8" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ20H8000() "feature"="sme" "enc"="00000101100000000000110000010100" "asm"="and z20.h, z20.h, #0x8000" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ORRZ24Z20() "feature"="sme" "enc"="00000100011101000011001100011000" "asm"="orr z24.d, z24.d, z20.d" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ24VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100000111000 a:5 11000" "asm"="st1h {lb}z24.h{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ24VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000000101000 a:5 11000" "asm"="ld1w {lb}z24.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ20ZA0H() "feature"="sme" "enc"="11000000100000100000000000010100" "asm"="mova z20.s, p0/m, za0h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SCVTFZ20() "feature"="sme" "enc"="01100101100101001010001010010100" "asm"="scvtf z20.s, p0/m, z20.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ20Z24() "feature"="sme" "enc"="01100101100110000000101010010100" "asm"="fmul z20.s, z20.s, z24.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ20Z3() "feature"="sme" "enc"="01100101100000110000101010010100" "asm"="fmul z20.s, z20.s, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ28VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000000101000 a:5 11100" "asm"="ld1w {lb}z28.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FADDZ20Z28() "feature"="sme" "enc"="01100101100111000000001010010100" "asm"="fadd z20.s, z20.s, z28.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZ20VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010101000000111000 a:5 10100" "asm"="st1w {lb}z20.s{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVZ24ZERO() "feature"="sme" "enc"="00100101101110001100000000011000" "asm"="mov z24.s, #0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ20VL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000000101000 a:5 10100" "asm"="ld1w {lb}z20.s{rb}, p0/z, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FABSZ20() "feature"="sme" "enc"="00000100100111001010001010010100" "asm"="fabs z20.s, p0/m, z20.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ24Z20() "feature"="sme" "enc"="01100101100001101000001010011000" "asm"="fmax z24.s, p0/m, z24.s, z20.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ20Z5() "feature"="sme" "enc"="01100101100001010000101010010100" "asm"="fmul z20.s, z20.s, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FRINTNZ20() "feature"="sme" "enc"="01100101100000001010001010010100" "asm"="frintn z20.s, p0/m, z20.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FCVTZSZ20() "feature"="sme" "enc"="01100101100111001010001010010100" "asm"="fcvtzs z20.s, p0/m, z20.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1BZ20SVL0(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010001000000111000 a:5 10100" "asm"="st1b {lb}z20.s{rb}, p0, [{a}]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ21HVL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100001101000 a:5 10101" "asm"="ld1b {lb}z21.h{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ25Z21H4() "feature"="sme" "enc"="00000100001101001001111010111001" "asm"="lsl z25.h, z21.h, #4" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ25H7F0() "feature"="sme" "enc"="00000101100000000110010011011001" "asm"="and z25.h, z25.h, #0x7f0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ25Z17H() "feature"="sme" "enc"="00000100011100010000001100111001" "asm"="add z25.h, z25.h, z17.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ21H8() "feature"="sme" "enc"="00000100001110001001111010110101" "asm"="lsl z21.h, z21.h, #8" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ21H8000() "feature"="sme" "enc"="00000101100000000000110000010101" "asm"="and z21.h, z21.h, #0x8000" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ORRZ25Z21() "feature"="sme" "enc"="00000100011101010011001100111001" "asm"="orr z25.d, z25.d, z21.d" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ25VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100001111000 a:5 11001" "asm"="st1h {lb}z25.h{rb}, p0, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ25VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000001101000 a:5 11001" "asm"="ld1w {lb}z25.s{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ21ZA1H() "feature"="sme" "enc"="11000000100000100000000010010101" "asm"="mova z21.s, p0/m, za1h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SCVTFZ21() "feature"="sme" "enc"="01100101100101001010001010110101" "asm"="scvtf z21.s, p0/m, z21.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ21Z25() "feature"="sme" "enc"="01100101100110010000101010110101" "asm"="fmul z21.s, z21.s, z25.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ21Z3() "feature"="sme" "enc"="01100101100000110000101010110101" "asm"="fmul z21.s, z21.s, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ29VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000001101000 a:5 11101" "asm"="ld1w {lb}z29.s{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FADDZ21Z29() "feature"="sme" "enc"="01100101100111010000001010110101" "asm"="fadd z21.s, z21.s, z29.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZ21VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010101000001111000 a:5 10101" "asm"="st1w {lb}z21.s{rb}, p0, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVZ25ZERO() "feature"="sme" "enc"="00100101101110001100000000011001" "asm"="mov z25.s, #0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ21VL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000001101000 a:5 10101" "asm"="ld1w {lb}z21.s{rb}, p0/z, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FABSZ21() "feature"="sme" "enc"="00000100100111001010001010110101" "asm"="fabs z21.s, p0/m, z21.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ25Z21() "feature"="sme" "enc"="01100101100001101000001010111001" "asm"="fmax z25.s, p0/m, z25.s, z21.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ21Z5() "feature"="sme" "enc"="01100101100001010000101010110101" "asm"="fmul z21.s, z21.s, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FRINTNZ21() "feature"="sme" "enc"="01100101100000001010001010110101" "asm"="frintn z21.s, p0/m, z21.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FCVTZSZ21() "feature"="sme" "enc"="01100101100111001010001010110101" "asm"="fcvtzs z21.s, p0/m, z21.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1BZ21SVL1(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010001000001111000 a:5 10101" "asm"="st1b {lb}z21.s{rb}, p0, [{a}, #1, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ22HVL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100010101000 a:5 10110" "asm"="ld1b {lb}z22.h{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ26Z22H4() "feature"="sme" "enc"="00000100001101001001111011011010" "asm"="lsl z26.h, z22.h, #4" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ26H7F0() "feature"="sme" "enc"="00000101100000000110010011011010" "asm"="and z26.h, z26.h, #0x7f0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ26Z18H() "feature"="sme" "enc"="00000100011100100000001101011010" "asm"="add z26.h, z26.h, z18.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ22H8() "feature"="sme" "enc"="00000100001110001001111011010110" "asm"="lsl z22.h, z22.h, #8" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ22H8000() "feature"="sme" "enc"="00000101100000000000110000010110" "asm"="and z22.h, z22.h, #0x8000" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ORRZ26Z22() "feature"="sme" "enc"="00000100011101100011001101011010" "asm"="orr z26.d, z26.d, z22.d" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ26VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100010111000 a:5 11010" "asm"="st1h {lb}z26.h{rb}, p0, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ26VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000010101000 a:5 11010" "asm"="ld1w {lb}z26.s{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ22ZA2H() "feature"="sme" "enc"="11000000100000100000000100010110" "asm"="mova z22.s, p0/m, za2h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SCVTFZ22() "feature"="sme" "enc"="01100101100101001010001011010110" "asm"="scvtf z22.s, p0/m, z22.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ22Z26() "feature"="sme" "enc"="01100101100110100000101011010110" "asm"="fmul z22.s, z22.s, z26.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ22Z3() "feature"="sme" "enc"="01100101100000110000101011010110" "asm"="fmul z22.s, z22.s, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ30VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000010101000 a:5 11110" "asm"="ld1w {lb}z30.s{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FADDZ22Z30() "feature"="sme" "enc"="01100101100111100000001011010110" "asm"="fadd z22.s, z22.s, z30.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZ22VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010101000010111000 a:5 10110" "asm"="st1w {lb}z22.s{rb}, p0, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVZ26ZERO() "feature"="sme" "enc"="00100101101110001100000000011010" "asm"="mov z26.s, #0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ22VL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000010101000 a:5 10110" "asm"="ld1w {lb}z22.s{rb}, p0/z, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FABSZ22() "feature"="sme" "enc"="00000100100111001010001011010110" "asm"="fabs z22.s, p0/m, z22.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ26Z22() "feature"="sme" "enc"="01100101100001101000001011011010" "asm"="fmax z26.s, p0/m, z26.s, z22.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ22Z5() "feature"="sme" "enc"="01100101100001010000101011010110" "asm"="fmul z22.s, z22.s, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FRINTNZ22() "feature"="sme" "enc"="01100101100000001010001011010110" "asm"="frintn z22.s, p0/m, z22.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FCVTZSZ22() "feature"="sme" "enc"="01100101100111001010001011010110" "asm"="fcvtzs z22.s, p0/m, z22.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1BZ22SVL2(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010001000010111000 a:5 10110" "asm"="st1b {lb}z22.s{rb}, p0, [{a}, #2, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1BZ23HVL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010000100011101000 a:5 10111" "asm"="ld1b {lb}z23.h{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ27Z23H4() "feature"="sme" "enc"="00000100001101001001111011111011" "asm"="lsl z27.h, z23.h, #4" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ27H7F0() "feature"="sme" "enc"="00000101100000000110010011011011" "asm"="and z27.h, z27.h, #0x7f0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ADDZ27Z19H() "feature"="sme" "enc"="00000100011100110000001101111011" "asm"="add z27.h, z27.h, z19.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LSLZ23H8() "feature"="sme" "enc"="00000100001110001001111011110111" "asm"="lsl z23.h, z23.h, #8" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ23H8000() "feature"="sme" "enc"="00000101100000000000110000010111" "asm"="and z23.h, z23.h, #0x8000" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ORRZ27Z23() "feature"="sme" "enc"="00000100011101110011001101111011" "asm"="orr z27.d, z27.d, z23.d" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1HZ27VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010010100011111000 a:5 11011" "asm"="st1h {lb}z27.h{rb}, p0, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ27VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000011101000 a:5 11011" "asm"="ld1w {lb}z27.s{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVAZ23ZA3H() "feature"="sme" "enc"="11000000100000100000000110010111" "asm"="mova z23.s, p0/m, za3h.s[w12, 0]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @SCVTFZ23() "feature"="sme" "enc"="01100101100101001010001011110111" "asm"="scvtf z23.s, p0/m, z23.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ23Z27() "feature"="sme" "enc"="01100101100110110000101011110111" "asm"="fmul z23.s, z23.s, z27.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ23Z3() "feature"="sme" "enc"="01100101100000110000101011110111" "asm"="fmul z23.s, z23.s, z3.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ31VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000011101000 a:5 11111" "asm"="ld1w {lb}z31.s{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FADDZ23Z31() "feature"="sme" "enc"="01100101100111110000001011110111" "asm"="fadd z23.s, z23.s, z31.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1WZ23VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010101000011111000 a:5 10111" "asm"="st1w {lb}z23.s{rb}, p0, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MOVZ27ZERO() "feature"="sme" "enc"="00100101101110001100000000011011" "asm"="mov z27.s, #0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @LD1WZ23VL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1010010101000011101000 a:5 10111" "asm"="ld1w {lb}z23.s{rb}, p0/z, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FABSZ23() "feature"="sme" "enc"="00000100100111001010001011110111" "asm"="fabs z23.s, p0/m, z23.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ27Z23() "feature"="sme" "enc"="01100101100001101000001011111011" "asm"="fmax z27.s, p0/m, z27.s, z23.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMULZ23Z5() "feature"="sme" "enc"="01100101100001010000101011110111" "asm"="fmul z23.s, z23.s, z5.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FRINTNZ23() "feature"="sme" "enc"="01100101100000001010001011110111" "asm"="frintn z23.s, p0/m, z23.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FCVTZSZ23() "feature"="sme" "enc"="01100101100111001010001011110111" "asm"="fcvtzs z23.s, p0/m, z23.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ST1BZ23SVL3(ptr "reg"="xsp" %a) "feature"="sme" "enc"="1110010001000011111000 a:5 10111" "asm"="st1b {lb}z23.s{rb}, p0, [{a}, #3, mul vl]" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ24Z25() "feature"="sme" "enc"="01100101100001101000001100111000" "asm"="fmax z24.s, p0/m, z24.s, z25.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ26Z27() "feature"="sme" "enc"="01100101100001101000001101111010" "asm"="fmax z26.s, p0/m, z26.s, z27.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXZ24Z26() "feature"="sme" "enc"="01100101100001101000001101011000" "asm"="fmax z24.s, p0/m, z24.s, z26.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @FMAXVS5Z24() "feature"="sme" "enc"="01100101100001100010001100000101" "asm"="fmaxv s5, p0, z24.s" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

declare void @llvm.epitome.sme.fp8.dequant4(ptr, ptr)

define void @sme.fp8.dequant4(ptr "reg"="xsp" %src, ptr "reg"="xsp" %dst) "feature"="sme" "recipe"="sme.fp8.dequant4.expand" {
  call void @llvm.epitome.sme.fp8.dequant4(ptr %src, ptr %dst)
  ret void
}

define void @sme.fp8.dequant4.expand(ptr %src, ptr %dst) {
  call void @LD1BZ20HVL0(ptr %src)
  call void @LD1BZ21HVL1(ptr %src)
  call void @LD1BZ22HVL2(ptr %src)
  call void @LD1BZ23HVL3(ptr %src)
  call void @LSLZ24Z20H4()
  call void @LSLZ25Z21H4()
  call void @LSLZ26Z22H4()
  call void @LSLZ27Z23H4()
  call void @ANDZ24H7F0()
  call void @ANDZ25H7F0()
  call void @ANDZ26H7F0()
  call void @ANDZ27H7F0()
  call void @ADDZ24Z16H()
  call void @ADDZ25Z17H()
  call void @ADDZ26Z18H()
  call void @ADDZ27Z19H()
  call void @LSLZ20H8()
  call void @LSLZ21H8()
  call void @LSLZ22H8()
  call void @LSLZ23H8()
  call void @ANDZ20H8000()
  call void @ANDZ21H8000()
  call void @ANDZ22H8000()
  call void @ANDZ23H8000()
  call void @ORRZ24Z20()
  call void @ORRZ25Z21()
  call void @ORRZ26Z22()
  call void @ORRZ27Z23()
  call void @ST1HZ24VL0(ptr %dst)
  call void @ST1HZ25VL1(ptr %dst)
  call void @ST1HZ26VL2(ptr %dst)
  call void @ST1HZ27VL3(ptr %dst)
  ret void
}

declare void @llvm.epitome.sme.i8.colscales(ptr)

define void @sme.i8.colscales(ptr "reg"="xsp" %p) "feature"="sme" "recipe"="sme.i8.colscales.expand" {
  call void @llvm.epitome.sme.i8.colscales(ptr %p)
  ret void
}

define void @sme.i8.colscales.expand(ptr %p) {
  call void @LD1WZ24VL0(ptr %p)
  call void @LD1WZ25VL1(ptr %p)
  call void @LD1WZ26VL2(ptr %p)
  call void @LD1WZ27VL3(ptr %p)
  ret void
}

declare void @llvm.epitome.sme.i8.out4(ptr, ptr, i32)

define void @sme.i8.out4(ptr "reg"="xsp" %c, ptr "reg"="xsp" %am, i32 "reg"="w" %slice) "feature"="sme" "recipe"="sme.i8.out4.expand" {
  call void @llvm.epitome.sme.i8.out4(ptr %c, ptr %am, i32 %slice)
  ret void
}

define void @sme.i8.out4.expand(ptr %c, ptr %am, i32 %slice) {
  call void @MOVW12(i32 %slice)
  call void @MOVAZ20ZA0H()
  call void @MOVAZ21ZA1H()
  call void @MOVAZ22ZA2H()
  call void @MOVAZ23ZA3H()
  call void @SCVTFZ20()
  call void @SCVTFZ21()
  call void @SCVTFZ22()
  call void @SCVTFZ23()
  call void @FMULZ20Z24()
  call void @FMULZ21Z25()
  call void @FMULZ22Z26()
  call void @FMULZ23Z27()
  call void @LD1RWZ3(ptr %am)
  call void @FMULZ20Z3()
  call void @FMULZ21Z3()
  call void @FMULZ22Z3()
  call void @FMULZ23Z3()
  call void @LD1WZ28VL0(ptr %c)
  call void @LD1WZ29VL1(ptr %c)
  call void @LD1WZ30VL2(ptr %c)
  call void @LD1WZ31VL3(ptr %c)
  call void @FADDZ20Z28()
  call void @FADDZ21Z29()
  call void @FADDZ22Z30()
  call void @FADDZ23Z31()
  call void @ST1WZ20VL0(ptr %c)
  call void @ST1WZ21VL1(ptr %c)
  call void @ST1WZ22VL2(ptr %c)
  call void @ST1WZ23VL3(ptr %c)
  ret void
}

declare void @llvm.epitome.sme.absmax4.start()

define void @sme.absmax4.start() "feature"="sme" "recipe"="sme.absmax4.start.expand" {
  call void @llvm.epitome.sme.absmax4.start()
  ret void
}

define void @sme.absmax4.start.expand() {
  call void @MOVZ24ZERO()
  call void @MOVZ25ZERO()
  call void @MOVZ26ZERO()
  call void @MOVZ27ZERO()
  ret void
}

declare void @llvm.epitome.sme.absmax4.add(ptr)

define void @sme.absmax4.add(ptr "reg"="xsp" %p) "feature"="sme" "recipe"="sme.absmax4.add.expand" {
  call void @llvm.epitome.sme.absmax4.add(ptr %p)
  ret void
}

define void @sme.absmax4.add.expand(ptr %p) {
  call void @LD1WZ20VL0(ptr %p)
  call void @LD1WZ21VL1(ptr %p)
  call void @LD1WZ22VL2(ptr %p)
  call void @LD1WZ23VL3(ptr %p)
  call void @FABSZ20()
  call void @FABSZ21()
  call void @FABSZ22()
  call void @FABSZ23()
  call void @FMAXZ24Z20()
  call void @FMAXZ25Z21()
  call void @FMAXZ26Z22()
  call void @FMAXZ27Z23()
  ret void
}

declare void @llvm.epitome.sme.absmax4.end(ptr)

define void @sme.absmax4.end(ptr "reg"="xsp" %p) "feature"="sme" "recipe"="sme.absmax4.end.expand" {
  call void @llvm.epitome.sme.absmax4.end(ptr %p)
  ret void
}

define void @sme.absmax4.end.expand(ptr %p) {
  call void @FMAXZ24Z25()
  call void @FMAXZ26Z27()
  call void @FMAXZ24Z26()
  call void @FMAXVS5Z24()
  call void @DUPZ5S5()
  call void @ST1WZ5P0(ptr %p)
  call void @MOVZ3127()
  call void @SCVTFZ3()
  call void @FDIVRZ5Z3()
  ret void
}

declare void @llvm.epitome.sme.quantize64(ptr, ptr)

define void @sme.quantize64(ptr "reg"="xsp" %src, ptr "reg"="xsp" %dst) "feature"="sme" "recipe"="sme.quantize64.expand" {
  call void @llvm.epitome.sme.quantize64(ptr %src, ptr %dst)
  ret void
}

define void @sme.quantize64.expand(ptr %src, ptr %dst) {
  call void @LD1WZ20VL0(ptr %src)
  call void @LD1WZ21VL1(ptr %src)
  call void @LD1WZ22VL2(ptr %src)
  call void @LD1WZ23VL3(ptr %src)
  call void @FMULZ20Z5()
  call void @FMULZ21Z5()
  call void @FMULZ22Z5()
  call void @FMULZ23Z5()
  call void @FRINTNZ20()
  call void @FRINTNZ21()
  call void @FRINTNZ22()
  call void @FRINTNZ23()
  call void @FCVTZSZ20()
  call void @FCVTZSZ21()
  call void @FCVTZSZ22()
  call void @FCVTZSZ23()
  call void @ST1BZ20SVL0(ptr %dst)
  call void @ST1BZ21SVL1(ptr %dst)
  call void @ST1BZ22SVL2(ptr %dst)
  call void @ST1BZ23SVL3(ptr %dst)
  ret void
}

; FP8 to BF16 in four instructions a vector rather than six: with t<<4 the
; sign lands in bit 11, and (t & 0x80) * 0xF0 (mla) moves it to bit 15:
; (t << 4) + bias + (t & 0x80) * 0xF0. z12 holds 0xF0 (sme.fp8.init).

define void @MOVZ12HF0() "feature"="sme" "enc"="00000101110000000110010001101100" "asm"="mov z12.h, #0xf0" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ20H80() "feature"="sme" "enc"="00000101100000000100110000010100" "asm"="and z20.h, z20.h, #0x80" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MLAZ24Z20Z12() "feature"="sme" "enc"="00000100010011000100001010011000" "asm"="mla z24.h, p0/m, z20.h, z12.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ21H80() "feature"="sme" "enc"="00000101100000000100110000010101" "asm"="and z21.h, z21.h, #0x80" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MLAZ25Z21Z12() "feature"="sme" "enc"="00000100010011000100001010111001" "asm"="mla z25.h, p0/m, z21.h, z12.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ22H80() "feature"="sme" "enc"="00000101100000000100110000010110" "asm"="and z22.h, z22.h, #0x80" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MLAZ26Z22Z12() "feature"="sme" "enc"="00000100010011000100001011011010" "asm"="mla z26.h, p0/m, z22.h, z12.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @ANDZ23H80() "feature"="sme" "enc"="00000101100000000100110000010111" "asm"="and z23.h, z23.h, #0x80" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

define void @MLAZ27Z23Z12() "feature"="sme" "enc"="00000100010011000100001011111011" "asm"="mla z27.h, p0/m, z23.h, z12.h" "nomatch" {
  call void @llvm.epitome.sme.piece()
  ret void
}

declare void @llvm.epitome.sme.fp8.init()

define void @sme.fp8.init() "feature"="sme" "recipe"="sme.fp8.init.expand" {
  call void @llvm.epitome.sme.fp8.init()
  ret void
}

define void @sme.fp8.init.expand() {
  call void @MOVZ12HF0()
  ret void
}

declare void @llvm.epitome.sme.fp8.dequant4m(ptr, ptr)

define void @sme.fp8.dequant4m(ptr "reg"="xsp" %src, ptr "reg"="xsp" %dst) "feature"="sme" "recipe"="sme.fp8.dequant4m.expand" {
  call void @llvm.epitome.sme.fp8.dequant4m(ptr %src, ptr %dst)
  ret void
}

define void @sme.fp8.dequant4m.expand(ptr %src, ptr %dst) {
  call void @LD1BZ20HVL0(ptr %src)
  call void @LD1BZ21HVL1(ptr %src)
  call void @LD1BZ22HVL2(ptr %src)
  call void @LD1BZ23HVL3(ptr %src)
  call void @LSLZ24Z20H4()
  call void @LSLZ25Z21H4()
  call void @LSLZ26Z22H4()
  call void @LSLZ27Z23H4()
  call void @ANDZ20H80()
  call void @ANDZ21H80()
  call void @ANDZ22H80()
  call void @ANDZ23H80()
  call void @ADDZ24Z16H()
  call void @ADDZ25Z17H()
  call void @ADDZ26Z18H()
  call void @ADDZ27Z19H()
  call void @MLAZ24Z20Z12()
  call void @MLAZ25Z21Z12()
  call void @MLAZ26Z22Z12()
  call void @MLAZ27Z23Z12()
  call void @ST1HZ24VL0(ptr %dst)
  call void @ST1HZ25VL1(ptr %dst)
  call void @ST1HZ26VL2(ptr %dst)
  call void @ST1HZ27VL3(ptr %dst)
  ret void
}
