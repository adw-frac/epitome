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
