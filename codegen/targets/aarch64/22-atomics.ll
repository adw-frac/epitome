; The AArch64 description: atomic read-modify-write (FEAT_LSE). Written by
; gen_atomics.py; the conventions are in 00-base.ll.
;
; Each instruction loads the old value into its result and writes the new
; one, with the ordering in its name: none (monotonic), a (acquire), l
; (release), al (acquire and release, and sequentially consistent). An
; operation or ordering missing here (nand, the floating-point ones) is a
; compare-and-swap loop (prepare.rs); without LSE, the outline helpers.

declare i8 @llvm.epitome.cmpxchg.i8(ptr, i8, i8, i32)
declare i16 @llvm.epitome.cmpxchg.i16(ptr, i16, i16, i32)
declare i32 @llvm.epitome.cmpxchg.i32(ptr, i32, i32, i32)
declare i64 @llvm.epitome.cmpxchg.i64(ptr, i64, i64, i32)

; --- i8
define i8 @SWPB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 1 000 00 n:5 d:5" "asm"="swpb {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @SWPAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 1 000 00 n:5 d:5" "asm"="swpab {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @SWPLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 1 000 00 n:5 d:5" "asm"="swplb {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i8 %m release
  ret i8 %r
}

define i8 @SWPALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 1 000 00 n:5 d:5" "asm"="swpalb {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDADDB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddb {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDADDAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddab {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDADDLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddlb {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDADDALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddalb {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDEORB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorb {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDEORAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorab {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDEORLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorlb {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDEORALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeoralb {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDSETB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetb {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDSETAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetab {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDSETLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetlb {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDSETALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetalb {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDSMAXB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxb {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDSMAXAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxab {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDSMAXLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxlb {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDSMAXALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxalb {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDSMINB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminb {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDSMINAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminab {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDSMINLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminlb {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDSMINALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminalb {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDUMAXB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxb {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDUMAXAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxab {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDUMAXLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxlb {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDUMAXALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxalb {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDUMINB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 111 00 n:5 d:5" "asm"="lduminb {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @LDUMINAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 111 00 n:5 d:5" "asm"="lduminab {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @LDUMINLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminlb {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i8 %m release
  ret i8 %r
}

define i8 @LDUMINALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminalb {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @LDCLRB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrb {m}, {d}, [{n}]" {
  %nm = xor i8 %m, -1
  %r = atomicrmw and ptr %n, i8 %nm monotonic
  ret i8 %r
}

define i8 @rmw.and.i8(ptr "reg"="xsp" %n, i8 "reg"="w" %m) "feature"="lse" "recipe"="rmw.and.i8.expand" {
  %r = atomicrmw and ptr %n, i8 %m monotonic
  ret i8 %r
}

define i8 @rmw.and.i8.expand(ptr %n, i8 %m) {
  %mw = zext i8 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i8
  %r = call i8 @LDCLRB(i8 %nm, ptr %n)
  ret i8 %r
}

define i8 @LDCLRAB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrab {m}, {d}, [{n}]" {
  %nm = xor i8 %m, -1
  %r = atomicrmw and ptr %n, i8 %nm acquire
  ret i8 %r
}

define i8 @rmw.anda.i8(ptr "reg"="xsp" %n, i8 "reg"="w" %m) "feature"="lse" "recipe"="rmw.anda.i8.expand" {
  %r = atomicrmw and ptr %n, i8 %m acquire
  ret i8 %r
}

define i8 @rmw.anda.i8.expand(ptr %n, i8 %m) {
  %mw = zext i8 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i8
  %r = call i8 @LDCLRAB(i8 %nm, ptr %n)
  ret i8 %r
}

define i8 @LDCLRLB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 0 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrlb {m}, {d}, [{n}]" {
  %nm = xor i8 %m, -1
  %r = atomicrmw and ptr %n, i8 %nm release
  ret i8 %r
}

define i8 @rmw.andl.i8(ptr "reg"="xsp" %n, i8 "reg"="w" %m) "feature"="lse" "recipe"="rmw.andl.i8.expand" {
  %r = atomicrmw and ptr %n, i8 %m release
  ret i8 %r
}

define i8 @rmw.andl.i8.expand(ptr %n, i8 %m) {
  %mw = zext i8 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i8
  %r = call i8 @LDCLRLB(i8 %nm, ptr %n)
  ret i8 %r
}

define i8 @LDCLRALB(i8 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 111 0 00 1 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclralb {m}, {d}, [{n}]" {
  %nm = xor i8 %m, -1
  %r = atomicrmw and ptr %n, i8 %nm seq_cst
  ret i8 %r
}

define i8 @rmw.andal.i8(ptr "reg"="xsp" %n, i8 "reg"="w" %m) "feature"="lse" "recipe"="rmw.andal.i8.expand" {
  %r = atomicrmw and ptr %n, i8 %m seq_cst
  ret i8 %r
}

define i8 @rmw.andal.i8.expand(ptr %n, i8 %m) {
  %mw = zext i8 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i8
  %r = call i8 @LDCLRALB(i8 %nm, ptr %n)
  ret i8 %r
}

define i8 @CASB(i8 "reg"="w" "tied" %old, i8 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 001000 1 0 1 d:5 0 11111 n:5 new:5" "asm"="casb {d}, {new}, [{n}]" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 0)
  ret i8 %r
}

define i8 @CASAB(i8 "reg"="w" "tied" %old, i8 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 001000 1 1 1 d:5 0 11111 n:5 new:5" "asm"="casab {d}, {new}, [{n}]" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 1)
  ret i8 %r
}

define i8 @CASLB(i8 "reg"="w" "tied" %old, i8 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 001000 1 0 1 d:5 1 11111 n:5 new:5" "asm"="caslb {d}, {new}, [{n}]" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 2)
  ret i8 %r
}

define i8 @CASALB(i8 "reg"="w" "tied" %old, i8 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="00 001000 1 1 1 d:5 1 11111 n:5 new:5" "asm"="casalb {d}, {new}, [{n}]" {
  %r = call i8 @llvm.epitome.cmpxchg.i8(ptr %n, i8 %old, i8 %new, i32 3)
  ret i8 %r
}


; --- i16
define i16 @SWPH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 1 000 00 n:5 d:5" "asm"="swph {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @SWPAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 1 000 00 n:5 d:5" "asm"="swpah {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @SWPLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 1 000 00 n:5 d:5" "asm"="swplh {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i16 %m release
  ret i16 %r
}

define i16 @SWPALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 1 000 00 n:5 d:5" "asm"="swpalh {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDADDH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddh {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDADDAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddah {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDADDLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddlh {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDADDALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddalh {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDEORH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorh {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDEORAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorah {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDEORLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorlh {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDEORALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeoralh {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDSETH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldseth {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDSETAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetah {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDSETLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetlh {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDSETALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetalh {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDSMAXH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxh {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDSMAXAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxah {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDSMAXLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxlh {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDSMAXALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxalh {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDSMINH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminh {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDSMINAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminah {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDSMINLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminlh {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDSMINALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminalh {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDUMAXH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxh {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDUMAXAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxah {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDUMAXLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxlh {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDUMAXALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxalh {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDUMINH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 111 00 n:5 d:5" "asm"="lduminh {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @LDUMINAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 111 00 n:5 d:5" "asm"="lduminah {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @LDUMINLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminlh {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i16 %m release
  ret i16 %r
}

define i16 @LDUMINALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminalh {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @LDCLRH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrh {m}, {d}, [{n}]" {
  %nm = xor i16 %m, -1
  %r = atomicrmw and ptr %n, i16 %nm monotonic
  ret i16 %r
}

define i16 @rmw.and.i16(ptr "reg"="xsp" %n, i16 "reg"="w" %m) "feature"="lse" "recipe"="rmw.and.i16.expand" {
  %r = atomicrmw and ptr %n, i16 %m monotonic
  ret i16 %r
}

define i16 @rmw.and.i16.expand(ptr %n, i16 %m) {
  %mw = zext i16 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i16
  %r = call i16 @LDCLRH(i16 %nm, ptr %n)
  ret i16 %r
}

define i16 @LDCLRAH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrah {m}, {d}, [{n}]" {
  %nm = xor i16 %m, -1
  %r = atomicrmw and ptr %n, i16 %nm acquire
  ret i16 %r
}

define i16 @rmw.anda.i16(ptr "reg"="xsp" %n, i16 "reg"="w" %m) "feature"="lse" "recipe"="rmw.anda.i16.expand" {
  %r = atomicrmw and ptr %n, i16 %m acquire
  ret i16 %r
}

define i16 @rmw.anda.i16.expand(ptr %n, i16 %m) {
  %mw = zext i16 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i16
  %r = call i16 @LDCLRAH(i16 %nm, ptr %n)
  ret i16 %r
}

define i16 @LDCLRLH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 0 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrlh {m}, {d}, [{n}]" {
  %nm = xor i16 %m, -1
  %r = atomicrmw and ptr %n, i16 %nm release
  ret i16 %r
}

define i16 @rmw.andl.i16(ptr "reg"="xsp" %n, i16 "reg"="w" %m) "feature"="lse" "recipe"="rmw.andl.i16.expand" {
  %r = atomicrmw and ptr %n, i16 %m release
  ret i16 %r
}

define i16 @rmw.andl.i16.expand(ptr %n, i16 %m) {
  %mw = zext i16 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i16
  %r = call i16 @LDCLRLH(i16 %nm, ptr %n)
  ret i16 %r
}

define i16 @LDCLRALH(i16 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 111 0 00 1 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclralh {m}, {d}, [{n}]" {
  %nm = xor i16 %m, -1
  %r = atomicrmw and ptr %n, i16 %nm seq_cst
  ret i16 %r
}

define i16 @rmw.andal.i16(ptr "reg"="xsp" %n, i16 "reg"="w" %m) "feature"="lse" "recipe"="rmw.andal.i16.expand" {
  %r = atomicrmw and ptr %n, i16 %m seq_cst
  ret i16 %r
}

define i16 @rmw.andal.i16.expand(ptr %n, i16 %m) {
  %mw = zext i16 %m to i32
  %nw = call i32 @MVNW(i32 %mw)
  %nm = trunc i32 %nw to i16
  %r = call i16 @LDCLRALH(i16 %nm, ptr %n)
  ret i16 %r
}

define i16 @CASH(i16 "reg"="w" "tied" %old, i16 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 001000 1 0 1 d:5 0 11111 n:5 new:5" "asm"="cash {d}, {new}, [{n}]" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 0)
  ret i16 %r
}

define i16 @CASAH(i16 "reg"="w" "tied" %old, i16 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 001000 1 1 1 d:5 0 11111 n:5 new:5" "asm"="casah {d}, {new}, [{n}]" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 1)
  ret i16 %r
}

define i16 @CASLH(i16 "reg"="w" "tied" %old, i16 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 001000 1 0 1 d:5 1 11111 n:5 new:5" "asm"="caslh {d}, {new}, [{n}]" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 2)
  ret i16 %r
}

define i16 @CASALH(i16 "reg"="w" "tied" %old, i16 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="01 001000 1 1 1 d:5 1 11111 n:5 new:5" "asm"="casalh {d}, {new}, [{n}]" {
  %r = call i16 @llvm.epitome.cmpxchg.i16(ptr %n, i16 %old, i16 %new, i32 3)
  ret i16 %r
}


; --- i32
define i32 @SWPW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 1 000 00 n:5 d:5" "asm"="swp {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @SWPAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 1 000 00 n:5 d:5" "asm"="swpa {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @SWPLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 1 000 00 n:5 d:5" "asm"="swpl {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i32 %m release
  ret i32 %r
}

define i32 @SWPALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 1 000 00 n:5 d:5" "asm"="swpal {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDADDW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldadd {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDADDAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldadda {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDADDLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddl {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDADDALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddal {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDEORW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeor {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDEORAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeora {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDEORLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorl {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDEORALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeoral {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDSETW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldset {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDSETAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldseta {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDSETLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetl {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDSETALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetal {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDSMAXW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmax {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDSMAXAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxa {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDSMAXLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxl {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDSMAXALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxal {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDSMINW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsmin {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDSMINAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsmina {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDSMINLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminl {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDSMINALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminal {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDUMAXW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumax {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDUMAXAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxa {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDUMAXLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxl {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDUMAXALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxal {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDUMINW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 111 00 n:5 d:5" "asm"="ldumin {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @LDUMINAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 111 00 n:5 d:5" "asm"="ldumina {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @LDUMINLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminl {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i32 %m release
  ret i32 %r
}

define i32 @LDUMINALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminal {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @LDCLRW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclr {m}, {d}, [{n}]" {
  %nm = xor i32 %m, -1
  %r = atomicrmw and ptr %n, i32 %nm monotonic
  ret i32 %r
}

define i32 @rmw.and.i32(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "feature"="lse" "recipe"="rmw.and.i32.expand" {
  %r = atomicrmw and ptr %n, i32 %m monotonic
  ret i32 %r
}

define i32 @rmw.and.i32.expand(ptr %n, i32 %m) {
  %nm = call i32 @MVNW(i32 %m)
  %r = call i32 @LDCLRW(i32 %nm, ptr %n)
  ret i32 %r
}

define i32 @LDCLRAW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclra {m}, {d}, [{n}]" {
  %nm = xor i32 %m, -1
  %r = atomicrmw and ptr %n, i32 %nm acquire
  ret i32 %r
}

define i32 @rmw.anda.i32(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "feature"="lse" "recipe"="rmw.anda.i32.expand" {
  %r = atomicrmw and ptr %n, i32 %m acquire
  ret i32 %r
}

define i32 @rmw.anda.i32.expand(ptr %n, i32 %m) {
  %nm = call i32 @MVNW(i32 %m)
  %r = call i32 @LDCLRAW(i32 %nm, ptr %n)
  ret i32 %r
}

define i32 @LDCLRLW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 0 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrl {m}, {d}, [{n}]" {
  %nm = xor i32 %m, -1
  %r = atomicrmw and ptr %n, i32 %nm release
  ret i32 %r
}

define i32 @rmw.andl.i32(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "feature"="lse" "recipe"="rmw.andl.i32.expand" {
  %r = atomicrmw and ptr %n, i32 %m release
  ret i32 %r
}

define i32 @rmw.andl.i32.expand(ptr %n, i32 %m) {
  %nm = call i32 @MVNW(i32 %m)
  %r = call i32 @LDCLRLW(i32 %nm, ptr %n)
  ret i32 %r
}

define i32 @LDCLRALW(i32 "reg"="w" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 111 0 00 1 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclral {m}, {d}, [{n}]" {
  %nm = xor i32 %m, -1
  %r = atomicrmw and ptr %n, i32 %nm seq_cst
  ret i32 %r
}

define i32 @rmw.andal.i32(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "feature"="lse" "recipe"="rmw.andal.i32.expand" {
  %r = atomicrmw and ptr %n, i32 %m seq_cst
  ret i32 %r
}

define i32 @rmw.andal.i32.expand(ptr %n, i32 %m) {
  %nm = call i32 @MVNW(i32 %m)
  %r = call i32 @LDCLRALW(i32 %nm, ptr %n)
  ret i32 %r
}

define i32 @CASW(i32 "reg"="w" "tied" %old, i32 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 001000 1 0 1 d:5 0 11111 n:5 new:5" "asm"="cas {d}, {new}, [{n}]" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 0)
  ret i32 %r
}

define i32 @CASAW(i32 "reg"="w" "tied" %old, i32 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 001000 1 1 1 d:5 0 11111 n:5 new:5" "asm"="casa {d}, {new}, [{n}]" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 1)
  ret i32 %r
}

define i32 @CASLW(i32 "reg"="w" "tied" %old, i32 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 001000 1 0 1 d:5 1 11111 n:5 new:5" "asm"="casl {d}, {new}, [{n}]" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 2)
  ret i32 %r
}

define i32 @CASALW(i32 "reg"="w" "tied" %old, i32 "reg"="w" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="10 001000 1 1 1 d:5 1 11111 n:5 new:5" "asm"="casal {d}, {new}, [{n}]" {
  %r = call i32 @llvm.epitome.cmpxchg.i32(ptr %n, i32 %old, i32 %new, i32 3)
  ret i32 %r
}


; --- i64
define i64 @SWPX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 1 000 00 n:5 d:5" "asm"="swp {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @SWPAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 1 000 00 n:5 d:5" "asm"="swpa {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @SWPLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 1 000 00 n:5 d:5" "asm"="swpl {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i64 %m release
  ret i64 %r
}

define i64 @SWPALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 1 000 00 n:5 d:5" "asm"="swpal {m}, {d}, [{n}]" {
  %r = atomicrmw xchg ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDADDX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldadd {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDADDAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 000 00 n:5 d:5" "asm"="ldadda {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDADDLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddl {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDADDALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 000 00 n:5 d:5" "asm"="ldaddal {m}, {d}, [{n}]" {
  %r = atomicrmw add ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDEORX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeor {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDEORAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 010 00 n:5 d:5" "asm"="ldeora {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDEORLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeorl {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDEORALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 010 00 n:5 d:5" "asm"="ldeoral {m}, {d}, [{n}]" {
  %r = atomicrmw xor ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDSETX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldset {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDSETAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 011 00 n:5 d:5" "asm"="ldseta {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDSETLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetl {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDSETALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 011 00 n:5 d:5" "asm"="ldsetal {m}, {d}, [{n}]" {
  %r = atomicrmw or ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDSMAXX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmax {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDSMAXAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxa {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDSMAXLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxl {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDSMAXALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 100 00 n:5 d:5" "asm"="ldsmaxal {m}, {d}, [{n}]" {
  %r = atomicrmw max ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDSMINX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsmin {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDSMINAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 101 00 n:5 d:5" "asm"="ldsmina {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDSMINLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminl {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDSMINALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 101 00 n:5 d:5" "asm"="ldsminal {m}, {d}, [{n}]" {
  %r = atomicrmw min ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDUMAXX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumax {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDUMAXAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxa {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDUMAXLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxl {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDUMAXALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 110 00 n:5 d:5" "asm"="ldumaxal {m}, {d}, [{n}]" {
  %r = atomicrmw umax ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDUMINX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 111 00 n:5 d:5" "asm"="ldumin {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @LDUMINAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 111 00 n:5 d:5" "asm"="ldumina {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @LDUMINLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminl {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i64 %m release
  ret i64 %r
}

define i64 @LDUMINALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 111 00 n:5 d:5" "asm"="lduminal {m}, {d}, [{n}]" {
  %r = atomicrmw umin ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @LDCLRX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclr {m}, {d}, [{n}]" {
  %nm = xor i64 %m, -1
  %r = atomicrmw and ptr %n, i64 %nm monotonic
  ret i64 %r
}

define i64 @rmw.and.i64(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="lse" "recipe"="rmw.and.i64.expand" {
  %r = atomicrmw and ptr %n, i64 %m monotonic
  ret i64 %r
}

define i64 @rmw.and.i64.expand(ptr %n, i64 %m) {
  %nm = call i64 @MVNX(i64 %m)
  %r = call i64 @LDCLRX(i64 %nm, ptr %n)
  ret i64 %r
}

define i64 @LDCLRAX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 0 1 m:5 0 001 00 n:5 d:5" "asm"="ldclra {m}, {d}, [{n}]" {
  %nm = xor i64 %m, -1
  %r = atomicrmw and ptr %n, i64 %nm acquire
  ret i64 %r
}

define i64 @rmw.anda.i64(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="lse" "recipe"="rmw.anda.i64.expand" {
  %r = atomicrmw and ptr %n, i64 %m acquire
  ret i64 %r
}

define i64 @rmw.anda.i64.expand(ptr %n, i64 %m) {
  %nm = call i64 @MVNX(i64 %m)
  %r = call i64 @LDCLRAX(i64 %nm, ptr %n)
  ret i64 %r
}

define i64 @LDCLRLX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 0 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclrl {m}, {d}, [{n}]" {
  %nm = xor i64 %m, -1
  %r = atomicrmw and ptr %n, i64 %nm release
  ret i64 %r
}

define i64 @rmw.andl.i64(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="lse" "recipe"="rmw.andl.i64.expand" {
  %r = atomicrmw and ptr %n, i64 %m release
  ret i64 %r
}

define i64 @rmw.andl.i64.expand(ptr %n, i64 %m) {
  %nm = call i64 @MVNX(i64 %m)
  %r = call i64 @LDCLRLX(i64 %nm, ptr %n)
  ret i64 %r
}

define i64 @LDCLRALX(i64 "reg"="x" %m, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 111 0 00 1 1 1 m:5 0 001 00 n:5 d:5" "asm"="ldclral {m}, {d}, [{n}]" {
  %nm = xor i64 %m, -1
  %r = atomicrmw and ptr %n, i64 %nm seq_cst
  ret i64 %r
}

define i64 @rmw.andal.i64(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "feature"="lse" "recipe"="rmw.andal.i64.expand" {
  %r = atomicrmw and ptr %n, i64 %m seq_cst
  ret i64 %r
}

define i64 @rmw.andal.i64.expand(ptr %n, i64 %m) {
  %nm = call i64 @MVNX(i64 %m)
  %r = call i64 @LDCLRALX(i64 %nm, ptr %n)
  ret i64 %r
}

define i64 @CASX(i64 "reg"="x" "tied" %old, i64 "reg"="x" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 001000 1 0 1 d:5 0 11111 n:5 new:5" "asm"="cas {d}, {new}, [{n}]" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 0)
  ret i64 %r
}

define i64 @CASAX(i64 "reg"="x" "tied" %old, i64 "reg"="x" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 001000 1 1 1 d:5 0 11111 n:5 new:5" "asm"="casa {d}, {new}, [{n}]" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 1)
  ret i64 %r
}

define i64 @CASLX(i64 "reg"="x" "tied" %old, i64 "reg"="x" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 001000 1 0 1 d:5 1 11111 n:5 new:5" "asm"="casl {d}, {new}, [{n}]" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 2)
  ret i64 %r
}

define i64 @CASALX(i64 "reg"="x" "tied" %old, i64 "reg"="x" %new, ptr "reg"="xsp" %n) "feature"="lse" "enc"="11 001000 1 1 1 d:5 1 11111 n:5 new:5" "asm"="casal {d}, {new}, [{n}]" {
  %r = call i64 @llvm.epitome.cmpxchg.i64(ptr %n, i64 %old, i64 %new, i32 3)
  ret i64 %r
}

