; The AArch64 description: what is done by calling the runtime (see
; codegen/src/runtime.rs and docs/design/targets.md, "Runtime calls").
;
; Quad precision (fp128): no instruction does its arithmetic, so the
; runtime's functions do (libgcc's and compiler-rt's names, which Rust's
; compiler_builtins has too: __addtf3 and the rest), and a value of it is
; held as <2 x i64> in a q register, where AAPCS64 passes it. Its sign is
; done on its bits.

!target.held = !{!6500}
!6500 = !{!"fp128", !"<2 x i64>"}
; Arithmetic.
declare fp128 @__addtf3(fp128, fp128)
define fp128 @fadd.f128(fp128 %a, fp128 %b) "libcall"="__addtf3" {
  %r = fadd fp128 %a, %b
  ret fp128 %r
}
declare fp128 @__subtf3(fp128, fp128)
define fp128 @fsub.f128(fp128 %a, fp128 %b) "libcall"="__subtf3" {
  %r = fsub fp128 %a, %b
  ret fp128 %r
}
declare fp128 @__multf3(fp128, fp128)
define fp128 @fmul.f128(fp128 %a, fp128 %b) "libcall"="__multf3" {
  %r = fmul fp128 %a, %b
  ret fp128 %r
}
declare fp128 @__divtf3(fp128, fp128)
define fp128 @fdiv.f128(fp128 %a, fp128 %b) "libcall"="__divtf3" {
  %r = fdiv fp128 %a, %b
  ret fp128 %r
}

; Conversions: widening and narrowing, and to and from integers.
declare fp128 @__extendhftf2(half)
define fp128 @fpext.half.f128(half %a) "libcall"="__extendhftf2" {
  %r = fpext half %a to fp128
  ret fp128 %r
}
declare half @__trunctfhf2(fp128)
define half @fptrunc.f128.half(fp128 %a) "libcall"="__trunctfhf2" {
  %r = fptrunc fp128 %a to half
  ret half %r
}
declare fp128 @__extendsftf2(float)
define fp128 @fpext.float.f128(float %a) "libcall"="__extendsftf2" {
  %r = fpext float %a to fp128
  ret fp128 %r
}
declare float @__trunctfsf2(fp128)
define float @fptrunc.f128.float(fp128 %a) "libcall"="__trunctfsf2" {
  %r = fptrunc fp128 %a to float
  ret float %r
}
declare fp128 @__extenddftf2(double)
define fp128 @fpext.double.f128(double %a) "libcall"="__extenddftf2" {
  %r = fpext double %a to fp128
  ret fp128 %r
}
declare double @__trunctfdf2(fp128)
define double @fptrunc.f128.double(fp128 %a) "libcall"="__trunctfdf2" {
  %r = fptrunc fp128 %a to double
  ret double %r
}
declare i32 @__fixtfsi(fp128)
define i32 @fptosi.f128.i32(fp128 %a) "libcall"="__fixtfsi" {
  %r = fptosi fp128 %a to i32
  ret i32 %r
}
declare i32 @__fixunstfsi(fp128)
define i32 @fptoui.f128.i32(fp128 %a) "libcall"="__fixunstfsi" {
  %r = fptoui fp128 %a to i32
  ret i32 %r
}
declare fp128 @__floatsitf(i32)
define fp128 @sitofp.i32.f128(i32 %a) "libcall"="__floatsitf" {
  %r = sitofp i32 %a to fp128
  ret fp128 %r
}
declare fp128 @__floatunsitf(i32)
define fp128 @uitofp.i32.f128(i32 %a) "libcall"="__floatunsitf" {
  %r = uitofp i32 %a to fp128
  ret fp128 %r
}
declare i64 @__fixtfdi(fp128)
define i64 @fptosi.f128.i64(fp128 %a) "libcall"="__fixtfdi" {
  %r = fptosi fp128 %a to i64
  ret i64 %r
}
declare i64 @__fixunstfdi(fp128)
define i64 @fptoui.f128.i64(fp128 %a) "libcall"="__fixunstfdi" {
  %r = fptoui fp128 %a to i64
  ret i64 %r
}
declare fp128 @__floatditf(i64)
define fp128 @sitofp.i64.f128(i64 %a) "libcall"="__floatditf" {
  %r = sitofp i64 %a to fp128
  ret fp128 %r
}
declare fp128 @__floatunditf(i64)
define fp128 @uitofp.i64.f128(i64 %a) "libcall"="__floatunditf" {
  %r = uitofp i64 %a to fp128
  ret fp128 %r
}
declare i128 @__fixtfti(fp128)
define i128 @fptosi.f128.i128(fp128 %a) "libcall"="__fixtfti" {
  %r = fptosi fp128 %a to i128
  ret i128 %r
}
declare i128 @__fixunstfti(fp128)
define i128 @fptoui.f128.i128(fp128 %a) "libcall"="__fixunstfti" {
  %r = fptoui fp128 %a to i128
  ret i128 %r
}
declare fp128 @__floattitf(i128)
define fp128 @sitofp.i128.f128(i128 %a) "libcall"="__floattitf" {
  %r = sitofp i128 %a to fp128
  ret fp128 %r
}
declare fp128 @__floatuntitf(i128)
define fp128 @uitofp.i128.f128(i128 %a) "libcall"="__floatuntitf" {
  %r = uitofp i128 %a to fp128
  ret fp128 %r
}

; Comparisons: the runtime's three-way comparisons (__lttf2 is negative
; for less, __getf2 negative for less or unordered...), and __unordtf2,
; not zero where either is a NaN.
declare i32 @__eqtf2(fp128, fp128)
declare i32 @__netf2(fp128, fp128)
declare i32 @__lttf2(fp128, fp128)
declare i32 @__letf2(fp128, fp128)
declare i32 @__gttf2(fp128, fp128)
declare i32 @__getf2(fp128, fp128)
declare i32 @__unordtf2(fp128, fp128)
define i1 @fcmp.oeq.f128(fp128 %a, fp128 %b) "lower"="fcmp.oeq.f128.lower" {
  %r = fcmp oeq fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.oeq.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__eqtf2(fp128 %a, fp128 %b)
  %r = icmp eq i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.une.f128(fp128 %a, fp128 %b) "lower"="fcmp.une.f128.lower" {
  %r = fcmp une fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.une.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__netf2(fp128 %a, fp128 %b)
  %r = icmp ne i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.olt.f128(fp128 %a, fp128 %b) "lower"="fcmp.olt.f128.lower" {
  %r = fcmp olt fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.olt.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__lttf2(fp128 %a, fp128 %b)
  %r = icmp slt i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.ole.f128(fp128 %a, fp128 %b) "lower"="fcmp.ole.f128.lower" {
  %r = fcmp ole fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ole.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__letf2(fp128 %a, fp128 %b)
  %r = icmp sle i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.ogt.f128(fp128 %a, fp128 %b) "lower"="fcmp.ogt.f128.lower" {
  %r = fcmp ogt fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ogt.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__gttf2(fp128 %a, fp128 %b)
  %r = icmp sgt i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.oge.f128(fp128 %a, fp128 %b) "lower"="fcmp.oge.f128.lower" {
  %r = fcmp oge fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.oge.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__getf2(fp128 %a, fp128 %b)
  %r = icmp sge i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.ult.f128(fp128 %a, fp128 %b) "lower"="fcmp.ult.f128.lower" {
  %r = fcmp ult fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ult.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__getf2(fp128 %a, fp128 %b)
  %r = icmp slt i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.ule.f128(fp128 %a, fp128 %b) "lower"="fcmp.ule.f128.lower" {
  %r = fcmp ule fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ule.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__gttf2(fp128 %a, fp128 %b)
  %r = icmp sle i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.ugt.f128(fp128 %a, fp128 %b) "lower"="fcmp.ugt.f128.lower" {
  %r = fcmp ugt fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ugt.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__letf2(fp128 %a, fp128 %b)
  %r = icmp sgt i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.uge.f128(fp128 %a, fp128 %b) "lower"="fcmp.uge.f128.lower" {
  %r = fcmp uge fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.uge.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__lttf2(fp128 %a, fp128 %b)
  %r = icmp sge i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.uno.f128(fp128 %a, fp128 %b) "lower"="fcmp.uno.f128.lower" {
  %r = fcmp uno fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.uno.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__unordtf2(fp128 %a, fp128 %b)
  %r = icmp ne i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.ord.f128(fp128 %a, fp128 %b) "lower"="fcmp.ord.f128.lower" {
  %r = fcmp ord fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ord.f128.lower(fp128 %a, fp128 %b) {
  %c = call i32 @__unordtf2(fp128 %a, fp128 %b)
  %r = icmp eq i32 %c, 0
  ret i1 %r
}
define i1 @fcmp.one.f128(fp128 %a, fp128 %b) "lower"="fcmp.one.f128.lower" {
  %r = fcmp one fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.one.f128.lower(fp128 %a, fp128 %b) {
  %u = call i32 @__unordtf2(fp128 %a, fp128 %b)
  %e = call i32 @__eqtf2(fp128 %a, fp128 %b)
  %o = icmp eq i32 %u, 0
  %n = icmp ne i32 %e, 0
  %r = and i1 %o, %n
  ret i1 %r
}
define i1 @fcmp.ueq.f128(fp128 %a, fp128 %b) "lower"="fcmp.ueq.f128.lower" {
  %r = fcmp ueq fp128 %a, %b
  ret i1 %r
}

define i1 @fcmp.ueq.f128.lower(fp128 %a, fp128 %b) {
  %u = call i32 @__unordtf2(fp128 %a, fp128 %b)
  %e = call i32 @__eqtf2(fp128 %a, fp128 %b)
  %o = icmp ne i32 %u, 0
  %n = icmp eq i32 %e, 0
  %r = or i1 %o, %n
  ret i1 %r
}

; The sign, on the bits: negation flips it, the absolute value clears it,
; copysign takes the second's.
define fp128 @fneg.f128(fp128 %a) "lower"="fneg.f128.lower" {
  %r = fneg fp128 %a
  ret fp128 %r
}

define fp128 @fneg.f128.lower(fp128 %a) {
  %i = bitcast fp128 %a to i128
  %x = xor i128 %i, -170141183460469231731687303715884105728
  %r = bitcast i128 %x to fp128
  ret fp128 %r
}

declare fp128 @llvm.fabs.f128(fp128)

define fp128 @fabs.f128(fp128 %a) "lower"="fabs.f128.lower" {
  %r = call fp128 @llvm.fabs.f128(fp128 %a)
  ret fp128 %r
}

define fp128 @fabs.f128.lower(fp128 %a) {
  %i = bitcast fp128 %a to i128
  %x = and i128 %i, 170141183460469231731687303715884105727
  %r = bitcast i128 %x to fp128
  ret fp128 %r
}

declare fp128 @llvm.copysign.f128(fp128, fp128)

define fp128 @copysign.f128(fp128 %a, fp128 %b) "lower"="copysign.f128.lower" {
  %r = call fp128 @llvm.copysign.f128(fp128 %a, fp128 %b)
  ret fp128 %r
}

define fp128 @copysign.f128.lower(fp128 %a, fp128 %b) {
  %i = bitcast fp128 %a to i128
  %j = bitcast fp128 %b to i128
  %m = and i128 %i, 170141183460469231731687303715884105727
  %s = and i128 %j, -170141183460469231731687303715884105728
  %x = or i128 %m, %s
  %r = bitcast i128 %x to fp128
  ret fp128 %r
}

; The C library's, where its long double is quad precision (Linux's on
; AArch64; Apple's long double is a double, and it has none): the
; remainder and the functions of libm.
declare fp128 @fmodl(fp128, fp128)
define fp128 @frem.f128(fp128 %a, fp128 %b) "libcall"="fmodl" "format"="elf" {
  %r = frem fp128 %a, %b
  ret fp128 %r
}
declare fp128 @llvm.sqrt.f128(fp128)
declare fp128 @sqrtl(fp128)
define fp128 @sqrt.f128(fp128 %a) "libcall"="sqrtl" "format"="elf" {
  %r = call fp128 @llvm.sqrt.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.floor.f128(fp128)
declare fp128 @floorl(fp128)
define fp128 @floor.f128(fp128 %a) "libcall"="floorl" "format"="elf" {
  %r = call fp128 @llvm.floor.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.ceil.f128(fp128)
declare fp128 @ceill(fp128)
define fp128 @ceil.f128(fp128 %a) "libcall"="ceill" "format"="elf" {
  %r = call fp128 @llvm.ceil.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.trunc.f128(fp128)
declare fp128 @truncl(fp128)
define fp128 @trunc.f128(fp128 %a) "libcall"="truncl" "format"="elf" {
  %r = call fp128 @llvm.trunc.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.round.f128(fp128)
declare fp128 @roundl(fp128)
define fp128 @round.f128(fp128 %a) "libcall"="roundl" "format"="elf" {
  %r = call fp128 @llvm.round.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.rint.f128(fp128)
declare fp128 @rintl(fp128)
define fp128 @rint.f128(fp128 %a) "libcall"="rintl" "format"="elf" {
  %r = call fp128 @llvm.rint.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.nearbyint.f128(fp128)
declare fp128 @nearbyintl(fp128)
define fp128 @nearbyint.f128(fp128 %a) "libcall"="nearbyintl" "format"="elf" {
  %r = call fp128 @llvm.nearbyint.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.exp.f128(fp128)
declare fp128 @expl(fp128)
define fp128 @exp.f128(fp128 %a) "libcall"="expl" "format"="elf" {
  %r = call fp128 @llvm.exp.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.exp2.f128(fp128)
declare fp128 @exp2l(fp128)
define fp128 @exp2.f128(fp128 %a) "libcall"="exp2l" "format"="elf" {
  %r = call fp128 @llvm.exp2.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.log.f128(fp128)
declare fp128 @logl(fp128)
define fp128 @log.f128(fp128 %a) "libcall"="logl" "format"="elf" {
  %r = call fp128 @llvm.log.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.log2.f128(fp128)
declare fp128 @log2l(fp128)
define fp128 @log2.f128(fp128 %a) "libcall"="log2l" "format"="elf" {
  %r = call fp128 @llvm.log2.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.log10.f128(fp128)
declare fp128 @log10l(fp128)
define fp128 @log10.f128(fp128 %a) "libcall"="log10l" "format"="elf" {
  %r = call fp128 @llvm.log10.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.sin.f128(fp128)
declare fp128 @sinl(fp128)
define fp128 @sin.f128(fp128 %a) "libcall"="sinl" "format"="elf" {
  %r = call fp128 @llvm.sin.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.cos.f128(fp128)
declare fp128 @cosl(fp128)
define fp128 @cos.f128(fp128 %a) "libcall"="cosl" "format"="elf" {
  %r = call fp128 @llvm.cos.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.tan.f128(fp128)
declare fp128 @tanl(fp128)
define fp128 @tan.f128(fp128 %a) "libcall"="tanl" "format"="elf" {
  %r = call fp128 @llvm.tan.f128(fp128 %a)
  ret fp128 %r
}
declare fp128 @llvm.pow.f128(fp128, fp128)
declare fp128 @powl(fp128, fp128)
define fp128 @pow.f128(fp128 %a, fp128 %b) "libcall"="powl" "format"="elf" {
  %r = call fp128 @llvm.pow.f128(fp128 %a, fp128 %b)
  ret fp128 %r
}
declare fp128 @llvm.minnum.f128(fp128, fp128)
declare fp128 @fminl(fp128, fp128)
define fp128 @minnum.f128(fp128 %a, fp128 %b) "libcall"="fminl" "format"="elf" {
  %r = call fp128 @llvm.minnum.f128(fp128 %a, fp128 %b)
  ret fp128 %r
}
declare fp128 @llvm.maxnum.f128(fp128, fp128)
declare fp128 @fmaxl(fp128, fp128)
define fp128 @maxnum.f128(fp128 %a, fp128 %b) "libcall"="fmaxl" "format"="elf" {
  %r = call fp128 @llvm.maxnum.f128(fp128 %a, fp128 %b)
  ret fp128 %r
}
declare fp128 @llvm.fma.f128(fp128, fp128, fp128)
declare fp128 @fmal(fp128, fp128, fp128)
define fp128 @fma.f128(fp128 %a, fp128 %b, fp128 %c) "libcall"="fmal" "format"="elf" {
  %r = call fp128 @llvm.fma.f128(fp128 %a, fp128 %b, fp128 %c)
  ret fp128 %r
}
