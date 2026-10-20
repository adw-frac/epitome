; The RISC-V RV64 description: the A extension, atomics, and fences. Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

; Each read-modify-write (amoadd and the rest) loads the old value into its
; result and writes the new one; .aq acquires, .rl releases, .aqrl does
; both and is sequentially consistent (as the psABI's mapping has it). The
; others (8 and 16 bits, compare-and-swap, nand and the rest) are loops of
; lr and sc (prepare.rs, atomics.rs), through
;
;   llvm.epitome.lr.iN(ptr, rank)        lr: the value, reserved
;   llvm.epitome.sc.iN(ptr, value, rank) sc: 0 if it was stored
;
; with rank 1 for .aq, 2 for .rl and 3 for .aqrl. Ordered loads and stores
; are plain ones with fences around them.
declare i32 @llvm.epitome.lr.i32(ptr, i32)
declare i64 @llvm.epitome.lr.i64(ptr, i32)
declare i32 @llvm.epitome.sc.i32(ptr, i32, i32)
declare i32 @llvm.epitome.sc.i64(ptr, i64, i32)

define i32 @AMOSWAPW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00001 00 m:5 n:5 010 d:5 0101111" "asm"="amoswap.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOSWAPWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00001 10 m:5 n:5 010 d:5 0101111" "asm"="amoswap.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOSWAPWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00001 01 m:5 n:5 010 d:5 0101111" "asm"="amoswap.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOSWAPWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00001 11 m:5 n:5 010 d:5 0101111" "asm"="amoswap.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOSWAPD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00001 00 m:5 n:5 011 d:5 0101111" "asm"="amoswap.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOSWAPDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00001 10 m:5 n:5 011 d:5 0101111" "asm"="amoswap.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOSWAPDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00001 01 m:5 n:5 011 d:5 0101111" "asm"="amoswap.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOSWAPDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00001 11 m:5 n:5 011 d:5 0101111" "asm"="amoswap.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xchg ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOADDW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00000 00 m:5 n:5 010 d:5 0101111" "asm"="amoadd.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOADDWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00000 10 m:5 n:5 010 d:5 0101111" "asm"="amoadd.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOADDWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00000 01 m:5 n:5 010 d:5 0101111" "asm"="amoadd.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOADDWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00000 11 m:5 n:5 010 d:5 0101111" "asm"="amoadd.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOADDD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00000 00 m:5 n:5 011 d:5 0101111" "asm"="amoadd.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOADDDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00000 10 m:5 n:5 011 d:5 0101111" "asm"="amoadd.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOADDDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00000 01 m:5 n:5 011 d:5 0101111" "asm"="amoadd.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOADDDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00000 11 m:5 n:5 011 d:5 0101111" "asm"="amoadd.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw add ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOXORW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00100 00 m:5 n:5 010 d:5 0101111" "asm"="amoxor.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOXORWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00100 10 m:5 n:5 010 d:5 0101111" "asm"="amoxor.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOXORWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00100 01 m:5 n:5 010 d:5 0101111" "asm"="amoxor.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOXORWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00100 11 m:5 n:5 010 d:5 0101111" "asm"="amoxor.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOXORD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00100 00 m:5 n:5 011 d:5 0101111" "asm"="amoxor.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOXORDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00100 10 m:5 n:5 011 d:5 0101111" "asm"="amoxor.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOXORDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00100 01 m:5 n:5 011 d:5 0101111" "asm"="amoxor.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOXORDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00100 11 m:5 n:5 011 d:5 0101111" "asm"="amoxor.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw xor ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOANDW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01100 00 m:5 n:5 010 d:5 0101111" "asm"="amoand.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOANDWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01100 10 m:5 n:5 010 d:5 0101111" "asm"="amoand.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOANDWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01100 01 m:5 n:5 010 d:5 0101111" "asm"="amoand.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOANDWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01100 11 m:5 n:5 010 d:5 0101111" "asm"="amoand.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOANDD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01100 00 m:5 n:5 011 d:5 0101111" "asm"="amoand.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOANDDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01100 10 m:5 n:5 011 d:5 0101111" "asm"="amoand.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOANDDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01100 01 m:5 n:5 011 d:5 0101111" "asm"="amoand.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOANDDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01100 11 m:5 n:5 011 d:5 0101111" "asm"="amoand.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw and ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOORW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01000 00 m:5 n:5 010 d:5 0101111" "asm"="amoor.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOORWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01000 10 m:5 n:5 010 d:5 0101111" "asm"="amoor.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOORWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01000 01 m:5 n:5 010 d:5 0101111" "asm"="amoor.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOORWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="01000 11 m:5 n:5 010 d:5 0101111" "asm"="amoor.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOORD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01000 00 m:5 n:5 011 d:5 0101111" "asm"="amoor.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOORDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01000 10 m:5 n:5 011 d:5 0101111" "asm"="amoor.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOORDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01000 01 m:5 n:5 011 d:5 0101111" "asm"="amoor.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOORDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="01000 11 m:5 n:5 011 d:5 0101111" "asm"="amoor.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw or ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOMINW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10000 00 m:5 n:5 010 d:5 0101111" "asm"="amomin.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOMINWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10000 10 m:5 n:5 010 d:5 0101111" "asm"="amomin.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOMINWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10000 01 m:5 n:5 010 d:5 0101111" "asm"="amomin.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOMINWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10000 11 m:5 n:5 010 d:5 0101111" "asm"="amomin.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOMIND(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10000 00 m:5 n:5 011 d:5 0101111" "asm"="amomin.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOMINDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10000 10 m:5 n:5 011 d:5 0101111" "asm"="amomin.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOMINDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10000 01 m:5 n:5 011 d:5 0101111" "asm"="amomin.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOMINDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10000 11 m:5 n:5 011 d:5 0101111" "asm"="amomin.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw min ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOMAXW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10100 00 m:5 n:5 010 d:5 0101111" "asm"="amomax.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOMAXWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10100 10 m:5 n:5 010 d:5 0101111" "asm"="amomax.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOMAXWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10100 01 m:5 n:5 010 d:5 0101111" "asm"="amomax.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOMAXWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="10100 11 m:5 n:5 010 d:5 0101111" "asm"="amomax.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOMAXD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10100 00 m:5 n:5 011 d:5 0101111" "asm"="amomax.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOMAXDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10100 10 m:5 n:5 011 d:5 0101111" "asm"="amomax.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOMAXDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10100 01 m:5 n:5 011 d:5 0101111" "asm"="amomax.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOMAXDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="10100 11 m:5 n:5 011 d:5 0101111" "asm"="amomax.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw max ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOMINUW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11000 00 m:5 n:5 010 d:5 0101111" "asm"="amominu.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOMINUWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11000 10 m:5 n:5 010 d:5 0101111" "asm"="amominu.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOMINUWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11000 01 m:5 n:5 010 d:5 0101111" "asm"="amominu.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOMINUWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11000 11 m:5 n:5 010 d:5 0101111" "asm"="amominu.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOMINUD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11000 00 m:5 n:5 011 d:5 0101111" "asm"="amominu.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOMINUDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11000 10 m:5 n:5 011 d:5 0101111" "asm"="amominu.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOMINUDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11000 01 m:5 n:5 011 d:5 0101111" "asm"="amominu.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOMINUDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11000 11 m:5 n:5 011 d:5 0101111" "asm"="amominu.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umin ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @AMOMAXUW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11100 00 m:5 n:5 010 d:5 0101111" "asm"="amomaxu.w {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @AMOMAXUWAQ(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11100 10 m:5 n:5 010 d:5 0101111" "asm"="amomaxu.w.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @AMOMAXUWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11100 01 m:5 n:5 010 d:5 0101111" "asm"="amomaxu.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i32 %m release
  ret i32 %r
}

define i32 @AMOMAXUWAQRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="11100 11 m:5 n:5 010 d:5 0101111" "asm"="amomaxu.w.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i64 @AMOMAXUD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11100 00 m:5 n:5 011 d:5 0101111" "asm"="amomaxu.d {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @AMOMAXUDAQ(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11100 10 m:5 n:5 011 d:5 0101111" "asm"="amomaxu.d.aq {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @AMOMAXUDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11100 01 m:5 n:5 011 d:5 0101111" "asm"="amomaxu.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i64 %m release
  ret i64 %r
}

define i64 @AMOMAXUDAQRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="11100 11 m:5 n:5 011 d:5 0101111" "asm"="amomaxu.d.aqrl {d}, {m}, ({n})" "feature"="a" {
  %r = atomicrmw umax ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i32 @LRW(ptr "reg"="x" %n) "enc"="00010 00 00000 n:5 010 d:5 0101111" "asm"="lr.w {d}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.lr.i32(ptr %n, i32 0)
  ret i32 %r
}

define i32 @LRWAQ(ptr "reg"="x" %n) "enc"="00010 10 00000 n:5 010 d:5 0101111" "asm"="lr.w.aq {d}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.lr.i32(ptr %n, i32 1)
  ret i32 %r
}

define i32 @LRWAQRL(ptr "reg"="x" %n) "enc"="00010 11 00000 n:5 010 d:5 0101111" "asm"="lr.w.aqrl {d}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.lr.i32(ptr %n, i32 3)
  ret i32 %r
}

define i32 @SCW(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00011 00 m:5 n:5 010 d:5 0101111" "asm"="sc.w {d}, {m}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.sc.i32(ptr %n, i32 %m, i32 0)
  ret i32 %r
}

define i32 @SCWRL(i32 "reg"="w" %m, ptr "reg"="x" %n) "enc"="00011 01 m:5 n:5 010 d:5 0101111" "asm"="sc.w.rl {d}, {m}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.sc.i32(ptr %n, i32 %m, i32 2)
  ret i32 %r
}

define i64 @LRD(ptr "reg"="x" %n) "enc"="00010 00 00000 n:5 011 d:5 0101111" "asm"="lr.d {d}, ({n})" "feature"="a" {
  %r = call i64 @llvm.epitome.lr.i64(ptr %n, i32 0)
  ret i64 %r
}

define i64 @LRDAQ(ptr "reg"="x" %n) "enc"="00010 10 00000 n:5 011 d:5 0101111" "asm"="lr.d.aq {d}, ({n})" "feature"="a" {
  %r = call i64 @llvm.epitome.lr.i64(ptr %n, i32 1)
  ret i64 %r
}

define i64 @LRDAQRL(ptr "reg"="x" %n) "enc"="00010 11 00000 n:5 011 d:5 0101111" "asm"="lr.d.aqrl {d}, ({n})" "feature"="a" {
  %r = call i64 @llvm.epitome.lr.i64(ptr %n, i32 3)
  ret i64 %r
}

define i32 @SCD(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00011 00 m:5 n:5 011 d:5 0101111" "asm"="sc.d {d}, {m}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.sc.i64(ptr %n, i64 %m, i32 0)
  ret i32 %r
}

define i32 @SCDRL(i64 "reg"="x" %m, ptr "reg"="x" %n) "enc"="00011 01 m:5 n:5 011 d:5 0101111" "asm"="sc.d.rl {d}, {m}, ({n})" "feature"="a" {
  %r = call i32 @llvm.epitome.sc.i64(ptr %n, i64 %m, i32 2)
  ret i32 %r
}

define void @FENCERRW() "enc"="0000 0010 0011 00000 000 00000 0001111" "asm"="fence r, rw" {
  fence acquire
  ret void
}

define void @FENCERWRW() "enc"="0000 0011 0011 00000 000 00000 0001111" "asm"="fence rw, rw" {
  fence seq_cst
  ret void
}
