; The AArch64 description: instructions for what reads or changes the
; machine's state, as intrinsics name them: the floating-point control
; and status registers, the virtual counter, breakpoints and halts, hints
; and barriers, and pointer authentication (Armv8.3's PAC). Written by
; hand from Arm's instruction descriptions; the generic intrinsics that
; become these are in `intrinsics.rs`.

declare i64 @llvm.aarch64.get.fpcr()

define i64 @MRSfpcr() "enc"="1101010100111 011 0100 0100 000 d:5" "asm"="mrs {d}, fpcr" {
  %r = call i64 @llvm.aarch64.get.fpcr()
  ret i64 %r
}

declare void @llvm.aarch64.set.fpcr(i64)

define void @MSRfpcr(i64 "reg"="x" %t) "enc"="1101010100011 011 0100 0100 000 t:5" "asm"="msr fpcr, {t}" {
  call void @llvm.aarch64.set.fpcr(i64 %t)
  ret void
}

declare i64 @llvm.aarch64.get.fpsr()

define i64 @MRSfpsr() "enc"="1101010100111 011 0100 0100 001 d:5" "asm"="mrs {d}, fpsr" {
  %r = call i64 @llvm.aarch64.get.fpsr()
  ret i64 %r
}

declare void @llvm.aarch64.set.fpsr(i64)

define void @MSRfpsr(i64 "reg"="x" %t) "enc"="1101010100011 011 0100 0100 001 t:5" "asm"="msr fpsr, {t}" {
  call void @llvm.aarch64.set.fpsr(i64 %t)
  ret void
}

; The virtual counter, which code at EL0 reads (llvm.readsteadycounter,
; and llvm.readcyclecounter on Apple's systems, which give no cycle
; counter to it).
declare i64 @llvm.readsteadycounter()

define i64 @MRScntvct() "enc"="1101010100111 011 1110 0000 010 d:5" "asm"="mrs {d}, cntvct_el0" {
  %r = call i64 @llvm.readsteadycounter()
  ret i64 %r
}

; Breakpoints and halts with an immediate (debugtrap is brk #0xf000,
; ubsantrap brk #(0x5500 + its kind)).
declare void @llvm.aarch64.break(i32)

define void @BRKimm(i32 "imm" %imm) "enc"="11010100 001 imm:16 000 00" "asm"="brk #{imm}" {
  call void @llvm.aarch64.break(i32 %imm)
  ret void
}

declare void @llvm.aarch64.hlt(i32)

define void @HLTimm(i32 "imm" %imm) "enc"="11010100 010 imm:16 000 00" "asm"="hlt #{imm}" {
  call void @llvm.aarch64.hlt(i32 %imm)
  ret void
}

declare void @llvm.aarch64.hint(i32)

define void @HINTimm(i32 "imm" %imm) "enc"="11010101000000110010 imm:7 11111" "asm"="hint #{imm}" {
  call void @llvm.aarch64.hint(i32 %imm)
  ret void
}

; Barriers by their option (15 is sy, 11 ish...).
declare void @llvm.aarch64.dmb(i32)

define void @DMBimm(i32 "imm" %crm) "enc"="11010101000000110011 crm:4 101 11111" "asm"="dmb #{crm}" {
  call void @llvm.aarch64.dmb(i32 %crm)
  ret void
}

declare void @llvm.aarch64.dsb(i32)

define void @DSBimm(i32 "imm" %crm) "enc"="11010101000000110011 crm:4 100 11111" "asm"="dsb #{crm}" {
  call void @llvm.aarch64.dsb(i32 %crm)
  ret void
}

declare void @llvm.aarch64.clrex()

define void @CLREX() "enc"="11010101000000110011 1111 010 11111" "asm"="clrex" {
  call void @llvm.aarch64.clrex()
  ret void
}

; Narrowing to single precision rounding to odd (so that a second rounding,
; to half, is as if it were the only one), and JavaScript's conversion to
; an integer (wrapping, modulo 2^32).
declare float @llvm.aarch64.sisd.fcvtxn(double)

define float @FCVTXNs(double "reg"="d" %n) "enc"="01 1 11110 0 1 10000 10110 10 n:5 d:5" "asm"="fcvtxn {d}, {n}" {
  %r = call float @llvm.aarch64.sisd.fcvtxn(double %n)
  ret float %r
}

declare <2 x float> @llvm.aarch64.neon.fcvtxn.v2f32.v2f64(<2 x double>)

define <2 x float> @FCVTXNv2s(<2 x double> "reg"="q" %n) "feature"="neon" "enc"="0 0 1 01110 0 1 10000 10110 10 n:5 d:5" "asm"="fcvtxn {d:2s}, {n:2d}" {
  %r = call <2 x float> @llvm.aarch64.neon.fcvtxn.v2f32.v2f64(<2 x double> %n)
  ret <2 x float> %r
}

declare i32 @llvm.aarch64.fjcvtzs(double)

define i32 @FJCVTZS(double "reg"="d" %n) "enc"="0 00 11110 01 1 11 110 000000 n:5 d:5" "asm"="fjcvtzs {d}, {n}" {
  %r = call i32 @llvm.aarch64.fjcvtzs(double %n)
  ret i32 %r
}

; Pointer authentication, by key (0 IA, 1 IB, 2 DA, 3 DB): sign, check
; (auth), strip, and the generic code (pacga). (The pointer is changed in
; its register: tied, as `%old`.)
declare i64 @llvm.ptrauth.sign(i64, i32, i64)
declare i64 @llvm.ptrauth.auth(i64, i32, i64)
declare i64 @llvm.ptrauth.strip(i64, i32)
declare i64 @llvm.ptrauth.sign.generic(i64, i64)

define i64 @PACIA(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000000 n:5 d:5" "asm"="pacia {d}, {n}" {
  %r = call i64 @llvm.ptrauth.sign(i64 %old, i32 0, i64 %n)
  ret i64 %r
}

define i64 @PACIB(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000001 n:5 d:5" "asm"="pacib {d}, {n}" {
  %r = call i64 @llvm.ptrauth.sign(i64 %old, i32 1, i64 %n)
  ret i64 %r
}

define i64 @PACDA(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000010 n:5 d:5" "asm"="pacda {d}, {n}" {
  %r = call i64 @llvm.ptrauth.sign(i64 %old, i32 2, i64 %n)
  ret i64 %r
}

define i64 @PACDB(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000011 n:5 d:5" "asm"="pacdb {d}, {n}" {
  %r = call i64 @llvm.ptrauth.sign(i64 %old, i32 3, i64 %n)
  ret i64 %r
}

define i64 @AUTIA(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000100 n:5 d:5" "asm"="autia {d}, {n}" {
  %r = call i64 @llvm.ptrauth.auth(i64 %old, i32 0, i64 %n)
  ret i64 %r
}

define i64 @AUTIB(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000101 n:5 d:5" "asm"="autib {d}, {n}" {
  %r = call i64 @llvm.ptrauth.auth(i64 %old, i32 1, i64 %n)
  ret i64 %r
}

define i64 @AUTDA(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000110 n:5 d:5" "asm"="autda {d}, {n}" {
  %r = call i64 @llvm.ptrauth.auth(i64 %old, i32 2, i64 %n)
  ret i64 %r
}

define i64 @AUTDB(i64 "reg"="x" "tied" %old, i64 "reg"="xsp" %n) "enc"="1 1 0 11010110 00001 000111 n:5 d:5" "asm"="autdb {d}, {n}" {
  %r = call i64 @llvm.ptrauth.auth(i64 %old, i32 3, i64 %n)
  ret i64 %r
}

define i64 @XPACI(i64 "reg"="x" "tied" %old) "enc"="1 1 0 11010110 00001 010000 11111 d:5" "asm"="xpaci {d}" {
  %r = call i64 @llvm.ptrauth.strip(i64 %old, i32 0)
  ret i64 %r
}

define i64 @XPACIb(i64 "reg"="x" "tied" %old) "enc"="1 1 0 11010110 00001 010000 11111 d:5" "asm"="xpaci {d}" "nodecode" {
  %r = call i64 @llvm.ptrauth.strip(i64 %old, i32 1)
  ret i64 %r
}

define i64 @XPACD(i64 "reg"="x" "tied" %old) "enc"="1 1 0 11010110 00001 010001 11111 d:5" "asm"="xpacd {d}" {
  %r = call i64 @llvm.ptrauth.strip(i64 %old, i32 2)
  ret i64 %r
}

define i64 @XPACDb(i64 "reg"="x" "tied" %old) "enc"="1 1 0 11010110 00001 010001 11111 d:5" "asm"="xpacd {d}" "nodecode" {
  %r = call i64 @llvm.ptrauth.strip(i64 %old, i32 3)
  ret i64 %r
}

define i64 @PACGA(i64 "reg"="x" %n, i64 "reg"="xsp" %m) "enc"="1 0 0 11010110 m:5 001100 n:5 d:5" "asm"="pacga {d}, {n}, {m}" {
  %r = call i64 @llvm.ptrauth.sign.generic(i64 %n, i64 %m)
  ret i64 %r
}

; Loads that mark the place exclusive (for a store-exclusive), plain and
; acquiring. (80-asm.ll's assembly entries decode them.)
declare i64 @llvm.aarch64.ldxr.p0(ptr)

define i64 @LDXRX(ptr "reg"="xsp" %n) "enc"="11 001000 010 11111 0 11111 n:5 d:5" "asm"="ldxr {d}, [{n}]" "nodecode" {
  %r = call i64 @llvm.aarch64.ldxr.p0(ptr %n)
  ret i64 %r
}

declare i64 @llvm.aarch64.ldaxr.p0(ptr)

define i64 @LDAXRX(ptr "reg"="xsp" %n) "enc"="11 001000 010 11111 1 11111 n:5 d:5" "asm"="ldaxr {d}, [{n}]" "nodecode" {
  %r = call i64 @llvm.aarch64.ldaxr.p0(ptr %n)
  ret i64 %r
}
