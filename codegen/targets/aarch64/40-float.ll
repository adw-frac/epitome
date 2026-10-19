; The AArch64 description: floating point. The conventions are in
; 00-base.ll.

; ===========================================================================
; Floating point. d registers hold doubles, s registers floats; physical
; registers 32-63 are v0-v31.

; The flags after a floating-point comparison, lazily: the values compared.
; They are set differently from an integer comparison's (an unordered
; result, with a NaN, sets C and V), so these condition forms differ too:
; olt is mi, not lt, which would be true for unordered values.
%fnzcv = type { double, double }

define i1 @cc.f.oeq(%fnzcv %f) "cond"="0" "asm"="eq" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp oeq double %a, %b
  ret i1 %c
}

define i1 @cc.f.une(%fnzcv %f) "cond"="1" "asm"="ne" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp une double %a, %b
  ret i1 %c
}

define i1 @cc.f.ogt(%fnzcv %f) "cond"="12" "asm"="gt" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ogt double %a, %b
  ret i1 %c
}

define i1 @cc.f.oge(%fnzcv %f) "cond"="10" "asm"="ge" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp oge double %a, %b
  ret i1 %c
}

define i1 @cc.f.olt(%fnzcv %f) "cond"="4" "asm"="mi" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp olt double %a, %b
  ret i1 %c
}

define i1 @cc.f.ole(%fnzcv %f) "cond"="9" "asm"="ls" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ole double %a, %b
  ret i1 %c
}

define i1 @cc.f.ugt(%fnzcv %f) "cond"="8" "asm"="hi" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ugt double %a, %b
  ret i1 %c
}

define i1 @cc.f.uge(%fnzcv %f) "cond"="5" "asm"="pl" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp uge double %a, %b
  ret i1 %c
}

define i1 @cc.f.ult(%fnzcv %f) "cond"="11" "asm"="lt" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ult double %a, %b
  ret i1 %c
}

define i1 @cc.f.ule(%fnzcv %f) "cond"="13" "asm"="le" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ule double %a, %b
  ret i1 %c
}

define i1 @cc.f.ord(%fnzcv %f) "cond"="7" "asm"="vc" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp ord double %a, %b
  ret i1 %c
}

define i1 @cc.f.uno(%fnzcv %f) "cond"="6" "asm"="vs" "reads"="nzcv" {
  %a = extractvalue %fnzcv %f, 0
  %b = extractvalue %fnzcv %f, 1
  %c = fcmp uno double %a, %b
  ret i1 %c
}

define %fnzcv @FCMPDrr(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 00 1000 n:5 00000" "asm"="fcmp {n}, {m}" "sets"="nzcv" {
  %f0 = insertvalue %fnzcv poison, double %n, 0
  %f = insertvalue %fnzcv %f0, double %m, 1
  ret %fnzcv %f
}

define %fnzcv @FCMPDr0(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 00000 00 1000 n:5 01000" "asm"="fcmp {n}, #0.0" "sets"="nzcv" {
  %f0 = insertvalue %fnzcv poison, double %n, 0
  %f = insertvalue %fnzcv %f0, double 0.0, 1
  ret %fnzcv %f
}

define double @FADDD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0010 10 n:5 d:5" "asm"="fadd {d}, {n}, {m}" {
  %r = fadd double %n, %m
  ret double %r
}

define double @FSUBD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0011 10 n:5 d:5" "asm"="fsub {d}, {n}, {m}" {
  %r = fsub double %n, %m
  ret double %r
}

define double @FMULD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0000 10 n:5 d:5" "asm"="fmul {d}, {n}, {m}" {
  %r = fmul double %n, %m
  ret double %r
}

define double @FDIVD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 0001 10 n:5 d:5" "asm"="fdiv {d}, {n}, {m}" {
  %r = fdiv double %n, %m
  ret double %r
}

define double @FNEGD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000010 10000 n:5 d:5" "asm"="fneg {d}, {n}" {
  %r = fneg double %n
  ret double %r
}

declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare double @llvm.fmuladd.f64(double, double, double)

define double @FABSD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000001 10000 n:5 d:5" "asm"="fabs {d}, {n}" {
  %r = call double @llvm.fabs.f64(double %n)
  ret double %r
}

define double @FSQRTD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000011 10000 n:5 d:5" "asm"="fsqrt {d}, {n}" {
  %r = call double @llvm.sqrt.f64(double %n)
  ret double %r
}

define double @FMADDD(double "reg"="d" %n, double "reg"="d" %m, double "reg"="d" %a) "enc"="0 0 0 11111 01 0 m:5 0 a:5 n:5 d:5" "asm"="fmadd {d}, {n}, {m}, {a}" {
  %r = call double @llvm.fmuladd.f64(double %n, double %m, double %a)
  ret double %r
}

define double @FCSELD(i1 "cond" %c, double "reg"="d" %n, double "reg"="d" %m) "enc"="0 0 0 11110 01 1 m:5 c:4 11 n:5 d:5" "asm"="fcsel {d}, {n}, {m}, {c}" {
  %r = select i1 %c, double %n, double %m
  ret double %r
}

define double @FMOVDr(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 000000 10000 n:5 d:5" "asm"="fmov {d}, {n}" "copy"="d" {
  ret double %n
}

define double @SCVTFDX(i64 "reg"="x" %n) "enc"="1 0 0 11110 01 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i64 %n to double
  ret double %r
}

define double @UCVTFDX(i64 "reg"="x" %n) "enc"="1 0 0 11110 01 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i64 %n to double
  ret double %r
}

define i64 @FCVTZSXD(double "reg"="d" %n) "enc"="1 0 0 11110 01 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi double %n to i64
  ret i64 %r
}

define i64 @FCVTZUXD(double "reg"="d" %n) "enc"="1 0 0 11110 01 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui double %n to i64
  ret i64 %r
}

define double @SCVTFDW(i32 "reg"="w" %n) "enc"="0 0 0 11110 01 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i32 %n to double
  ret double %r
}

define double @UCVTFDW(i32 "reg"="w" %n) "enc"="0 0 0 11110 01 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i32 %n to double
  ret double %r
}

define i32 @FCVTZSWD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi double %n to i32
  ret i32 %r
}

define i32 @FCVTZUWD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui double %n to i32
  ret i32 %r
}

define double @LDRDui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.d" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load double, ptr %p
  ret double %v
}

define void @STRDui(double "reg"="d" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.d" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  ret void
}

define double @LDURDi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load double, ptr %p
  ret double %v
}

define void @STURDi(double "reg"="d" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  ret void
}

define double @LDRDroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load double, ptr %p
  ret double %v
}

define void @STRDroX(double "reg"="d" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store double %t, ptr %p
  ret void
}

define { double, ptr } @LDRDpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load double, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { double, ptr } poison, double %v, 0
  %b = insertvalue { double, ptr } %a, ptr %next, 1
  ret { double, ptr } %b
}

define ptr @STRDpost(double "reg"="d" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store double %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define double @select.d(i1 "reg"="w" %c, double "reg"="d" %a, double "reg"="d" %b) "recipe"="select.d.expand" {
  %r = select i1 %c, double %a, double %b
  ret double %r
}

define double @select.d.expand(i1 %c, double %a, double %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call double @FCSELD(i1 %ne, double %a, double %b)
  ret double %r
}

define %fnzcv @FCMPSrr(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 00 1000 n:5 00000" "asm"="fcmp {n}, {m}" "sets"="nzcv" {
  %a = fpext float %n to double
  %b = fpext float %m to double
  %f0 = insertvalue %fnzcv poison, double %a, 0
  %f = insertvalue %fnzcv %f0, double %b, 1
  ret %fnzcv %f
}

define %fnzcv @FCMPSr0(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 00000 00 1000 n:5 01000" "asm"="fcmp {n}, #0.0" "sets"="nzcv" {
  %a = fpext float %n to double
  %f0 = insertvalue %fnzcv poison, double %a, 0
  %f = insertvalue %fnzcv %f0, double 0.0, 1
  ret %fnzcv %f
}

define float @FADDS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0010 10 n:5 d:5" "asm"="fadd {d}, {n}, {m}" {
  %r = fadd float %n, %m
  ret float %r
}

define float @FSUBS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0011 10 n:5 d:5" "asm"="fsub {d}, {n}, {m}" {
  %r = fsub float %n, %m
  ret float %r
}

define float @FMULS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0000 10 n:5 d:5" "asm"="fmul {d}, {n}, {m}" {
  %r = fmul float %n, %m
  ret float %r
}

define float @FDIVS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 0001 10 n:5 d:5" "asm"="fdiv {d}, {n}, {m}" {
  %r = fdiv float %n, %m
  ret float %r
}

define float @FNEGS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000010 10000 n:5 d:5" "asm"="fneg {d}, {n}" {
  %r = fneg float %n
  ret float %r
}

declare float @llvm.fabs.f32(float)
declare float @llvm.sqrt.f32(float)
declare float @llvm.fmuladd.f32(float, float, float)

define float @FABSS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000001 10000 n:5 d:5" "asm"="fabs {d}, {n}" {
  %r = call float @llvm.fabs.f32(float %n)
  ret float %r
}

define float @FSQRTS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000011 10000 n:5 d:5" "asm"="fsqrt {d}, {n}" {
  %r = call float @llvm.sqrt.f32(float %n)
  ret float %r
}

define float @FMADDS(float "reg"="s" %n, float "reg"="s" %m, float "reg"="s" %a) "enc"="0 0 0 11111 00 0 m:5 0 a:5 n:5 d:5" "asm"="fmadd {d}, {n}, {m}, {a}" {
  %r = call float @llvm.fmuladd.f32(float %n, float %m, float %a)
  ret float %r
}

define float @FCSELS(i1 "cond" %c, float "reg"="s" %n, float "reg"="s" %m) "enc"="0 0 0 11110 00 1 m:5 c:4 11 n:5 d:5" "asm"="fcsel {d}, {n}, {m}, {c}" {
  %r = select i1 %c, float %n, float %m
  ret float %r
}

define float @FMOVSr(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 000000 10000 n:5 d:5" "asm"="fmov {d}, {n}" "copy"="s" {
  ret float %n
}

define float @SCVTFSX(i64 "reg"="x" %n) "enc"="1 0 0 11110 00 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i64 %n to float
  ret float %r
}

define float @UCVTFSX(i64 "reg"="x" %n) "enc"="1 0 0 11110 00 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i64 %n to float
  ret float %r
}

define i64 @FCVTZSXS(float "reg"="s" %n) "enc"="1 0 0 11110 00 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi float %n to i64
  ret i64 %r
}

define i64 @FCVTZUXS(float "reg"="s" %n) "enc"="1 0 0 11110 00 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui float %n to i64
  ret i64 %r
}

define float @SCVTFSW(i32 "reg"="w" %n) "enc"="0 0 0 11110 00 1 00 010 000000 n:5 d:5" "asm"="scvtf {d}, {n}" {
  %r = sitofp i32 %n to float
  ret float %r
}

define float @UCVTFSW(i32 "reg"="w" %n) "enc"="0 0 0 11110 00 1 00 011 000000 n:5 d:5" "asm"="ucvtf {d}, {n}" {
  %r = uitofp i32 %n to float
  ret float %r
}

define i32 @FCVTZSWS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 11 000 000000 n:5 d:5" "asm"="fcvtzs {d}, {n}" {
  %r = fptosi float %n to i32
  ret i32 %r
}

define i32 @FCVTZUWS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 11 001 000000 n:5 d:5" "asm"="fcvtzu {d}, {n}" {
  %r = fptoui float %n to i32
  ret i32 %r
}

define float @LDRSui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 01 01 imm12:12=off/4 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.s" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load float, ptr %p
  ret float %v
}

define void @STRSui(float "reg"="s" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 01 00 imm12:12=off/4 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.s" {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  ret void
}

define float @LDURSi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load float, ptr %p
  ret float %v
}

define void @STURSi(float "reg"="s" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 1 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  ret void
}

define float @LDRSroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 1 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load float, ptr %p
  ret float %v
}

define void @STRSroX(float "reg"="s" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 1 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  store float %t, ptr %p
  ret void
}

define { float, ptr } @LDRSpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 1 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load float, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { float, ptr } poison, float %v, 0
  %b = insertvalue { float, ptr } %a, ptr %next, 1
  ret { float, ptr } %b
}

define ptr @STRSpost(float "reg"="s" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 1 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store float %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define float @select.s(i1 "reg"="w" %c, float "reg"="s" %a, float "reg"="s" %b) "recipe"="select.s.expand" {
  %r = select i1 %c, float %a, float %b
  ret float %r
}

define float @select.s.expand(i1 %c, float %a, float %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call float @FCSELS(i1 %ne, float %a, float %b)
  ret float %r
}

; Between the two widths.
define double @FCVTDS(float "reg"="s" %n) "enc"="0 0 0 11110 00 1 0001 01 10000 n:5 d:5" "asm"="fcvt {d}, {n}" {
  %r = fpext float %n to double
  ret double %r
}

define float @FCVTSD(double "reg"="d" %n) "enc"="0 0 0 11110 01 1 0001 00 10000 n:5 d:5" "asm"="fcvt {d}, {n}" {
  %r = fptrunc double %n to float
  ret float %r
}

; Between the register files, bit for bit.
define double @FMOVDX(i64 "reg"="x" %n) "enc"="1 00 11110 01 1 00 111 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="move.d.x" {
  %r = bitcast i64 %n to double
  ret double %r
}

define i64 @FMOVXD(double "reg"="d" %n) "enc"="1 00 11110 01 1 00 110 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="move.x.d" {
  %r = bitcast double %n to i64
  ret i64 %r
}

define float @FMOVSW(i32 "reg"="w" %n) "enc"="0 00 11110 00 1 00 111 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="move.s.w" {
  %r = bitcast i32 %n to float
  ret float %r
}

define i32 @FMOVWS(float "reg"="s" %n) "enc"="0 00 11110 00 1 00 110 000000 n:5 d:5" "asm"="fmov {d}, {n}" "role"="move.w.s" {
  %r = bitcast float %n to i32
  ret i32 %r
}


; Floating-point immediates: fmov's 8 bits hold (16 + f) / 16 times a power
; of two from 2^-3 to 2^4, signed (0.5, 1.0, 2.5, -10.0, ...).
define double @FMOVDi(double "imm" %c) "enc"="0 0 0 11110 01 1 imm8:8=fp8d(c) 100 00000 d:5" "asm"="fmov {d}, #{c:f64}" {
  ret double %c
}

define float @FMOVSi(float "imm" %c) "enc"="0 0 0 11110 00 1 imm8:8=fp8s(c) 100 00000 d:5" "asm"="fmov {d}, #{c:f32}" {
  ret float %c
}
