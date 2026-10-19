; The RISC-V RV64 description: the F and D extensions, floating point. Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

define double @FADDD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0000001 m:5 n:5 111 d:5 1010011" "asm"="fadd.d {d}, {n}, {m}" "feature"="d" {
  %r = fadd double %n, %m
  ret double %r
}

define double @FSUBD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0000101 m:5 n:5 111 d:5 1010011" "asm"="fsub.d {d}, {n}, {m}" "feature"="d" {
  %r = fsub double %n, %m
  ret double %r
}

define double @FMULD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0001001 m:5 n:5 111 d:5 1010011" "asm"="fmul.d {d}, {n}, {m}" "feature"="d" {
  %r = fmul double %n, %m
  ret double %r
}

define double @FDIVD(double "reg"="d" %n, double "reg"="d" %m) "enc"="0001101 m:5 n:5 111 d:5 1010011" "asm"="fdiv.d {d}, {n}, {m}" "feature"="d" {
  %r = fdiv double %n, %m
  ret double %r
}

declare double @llvm.sqrt.f64(double)
declare double @llvm.fabs.f64(double)
declare double @llvm.fmuladd.f64(double, double, double)
declare double @llvm.fma.f64(double, double, double)

define double @FSQRTD(double "reg"="d" %n) "enc"="0101101 00000 n:5 111 d:5 1010011" "asm"="fsqrt.d {d}, {n}" "feature"="d" {
  %r = call double @llvm.sqrt.f64(double %n)
  ret double %r
}

define double @FNEGD(double "reg"="d" %n) "enc"="0010001 rb:5=n n:5 001 d:5 1010011" "asm"="fneg.d {d}, {n}" "feature"="d" {
  %r = fneg double %n
  ret double %r
}

define double @FABSD(double "reg"="d" %n) "enc"="0010001 rb:5=n n:5 010 d:5 1010011" "asm"="fabs.d {d}, {n}" "feature"="d" {
  %r = call double @llvm.fabs.f64(double %n)
  ret double %r
}

define double @FMVD(double "reg"="d" %n) "enc"="0010001 rb:5=n n:5 000 d:5 1010011" "asm"="fmv.d {d}, {n}" "feature"="d" "copy"="d" {
  ret double %n
}

define double @FMADDD(double "reg"="d" %n, double "reg"="d" %m, double "reg"="d" %a) "enc"="a:5 01 m:5 n:5 111 d:5 1000011" "asm"="fmadd.d {d}, {n}, {m}, {a}" "feature"="d" {
  %r = call double @llvm.fmuladd.f64(double %n, double %m, double %a)
  ret double %r
}

define double @FMADDDf(double "reg"="d" %n, double "reg"="d" %m, double "reg"="d" %a) "enc"="a:5 01 m:5 n:5 111 d:5 1000011" "asm"="fmadd.d {d}, {n}, {m}, {a}" "feature"="d" "nodecode" {
  %r = call double @llvm.fma.f64(double %n, double %m, double %a)
  ret double %r
}

define i1 @FEQD(double "reg"="d" %n, double "reg"="d" %m) "enc"="1010001 m:5 n:5 010 d:5 1010011" "asm"="feq.d {d}, {n}, {m}" "feature"="d" "zext"="1" {
  %r = fcmp oeq double %n, %m
  ret i1 %r
}

define i1 @FLTD(double "reg"="d" %n, double "reg"="d" %m) "enc"="1010001 m:5 n:5 001 d:5 1010011" "asm"="flt.d {d}, {n}, {m}" "feature"="d" "zext"="1" {
  %r = fcmp olt double %n, %m
  ret i1 %r
}

define i1 @FLED(double "reg"="d" %n, double "reg"="d" %m) "enc"="1010001 m:5 n:5 000 d:5 1010011" "asm"="fle.d {d}, {n}, {m}" "feature"="d" "zext"="1" {
  %r = fcmp ole double %n, %m
  ret i1 %r
}

define i1 @FGTD(double "reg"="d" %n, double "reg"="d" %m) "enc"="1010001 rb:5=n ra:5=m 001 d:5 1010011" "asm"="flt.d {d}, {m}, {n}" "feature"="d" "zext"="1" "nodecode" {
  %r = fcmp ogt double %n, %m
  ret i1 %r
}

define i1 @FGED(double "reg"="d" %n, double "reg"="d" %m) "enc"="1010001 rb:5=n ra:5=m 000 d:5 1010011" "asm"="fle.d {d}, {m}, {n}" "feature"="d" "zext"="1" "nodecode" {
  %r = fcmp oge double %n, %m
  ret i1 %r
}

define i64 @FCVTLD(double "reg"="d" %n) "enc"="1100001 00010 n:5 001 d:5 1010011" "asm"="fcvt.l.d {d}, {n}, rtz" "feature"="d" {
  %r = fptosi double %n to i64
  ret i64 %r
}

define i64 @FCVTLUD(double "reg"="d" %n) "enc"="1100001 00011 n:5 001 d:5 1010011" "asm"="fcvt.lu.d {d}, {n}, rtz" "feature"="d" {
  %r = fptoui double %n to i64
  ret i64 %r
}

define double @FCVTDL(i64 "reg"="x" %n) "enc"="1101001 00010 n:5 111 d:5 1010011" "asm"="fcvt.d.l {d}, {n}" "feature"="d" {
  %r = sitofp i64 %n to double
  ret double %r
}

define double @FCVTDLU(i64 "reg"="x" %n) "enc"="1101001 00011 n:5 111 d:5 1010011" "asm"="fcvt.d.lu {d}, {n}" "feature"="d" {
  %r = uitofp i64 %n to double
  ret double %r
}

define i32 @FCVTWD(double "reg"="d" %n) "enc"="1100001 00000 n:5 001 d:5 1010011" "asm"="fcvt.w.d {d}, {n}, rtz" "feature"="d" {
  %r = fptosi double %n to i32
  ret i32 %r
}

define i32 @FCVTWUD(double "reg"="d" %n) "enc"="1100001 00001 n:5 001 d:5 1010011" "asm"="fcvt.wu.d {d}, {n}, rtz" "feature"="d" {
  %r = fptoui double %n to i32
  ret i32 %r
}

define double @FCVTDW(i32 "reg"="w" %n) "enc"="1101001 00000 n:5 111 d:5 1010011" "asm"="fcvt.d.w {d}, {n}" "feature"="d" {
  %r = sitofp i32 %n to double
  ret double %r
}

define double @FCVTDWU(i32 "reg"="w" %n) "enc"="1101001 00001 n:5 111 d:5 1010011" "asm"="fcvt.d.wu {d}, {n}" "feature"="d" {
  %r = uitofp i32 %n to double
  ret double %r
}

define i64 @FMVXD(double "reg"="d" %n) "enc"="1110001 00000 n:5 000 d:5 1010011" "asm"="fmv.x.d {d}, {n}" "feature"="d" "role"="move.x.d" {
  %r = bitcast double %n to i64
  ret i64 %r
}

define double @FMVDX(i64 "reg"="x" %n) "enc"="1111001 00000 n:5 000 d:5 1010011" "asm"="fmv.d.x {d}, {n}" "feature"="d" "role"="move.d.x" {
  %r = bitcast i64 %n to double
  ret double %r
}

define double @FLD(ptr "reg"="x" %n, i64 "imm" %off) "enc"="off:s12 n:5 011 d:5 0000111" "asm"="fld {d}, {off}({n})" "feature"="d" "role"="load.d" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load double, ptr %p
  ret double %v
}

define void @FSD(double "reg"="d" %t, ptr "reg"="x" %n, i64 "imm" %off) "enc"="hi:s7=off>>5 t:5 n:5 011 lo:5=off&31 0100111" "asm"="fsd {t}, {off}({n})" "feature"="d" "role"="store.d" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  ret void
}

define float @FADDS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0000000 m:5 n:5 111 d:5 1010011" "asm"="fadd.s {d}, {n}, {m}" "feature"="f" {
  %r = fadd float %n, %m
  ret float %r
}

define float @FSUBS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0000100 m:5 n:5 111 d:5 1010011" "asm"="fsub.s {d}, {n}, {m}" "feature"="f" {
  %r = fsub float %n, %m
  ret float %r
}

define float @FMULS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0001000 m:5 n:5 111 d:5 1010011" "asm"="fmul.s {d}, {n}, {m}" "feature"="f" {
  %r = fmul float %n, %m
  ret float %r
}

define float @FDIVS(float "reg"="s" %n, float "reg"="s" %m) "enc"="0001100 m:5 n:5 111 d:5 1010011" "asm"="fdiv.s {d}, {n}, {m}" "feature"="f" {
  %r = fdiv float %n, %m
  ret float %r
}

declare float @llvm.sqrt.f32(float)
declare float @llvm.fabs.f32(float)
declare float @llvm.fmuladd.f32(float, float, float)
declare float @llvm.fma.f32(float, float, float)

define float @FSQRTS(float "reg"="s" %n) "enc"="0101100 00000 n:5 111 d:5 1010011" "asm"="fsqrt.s {d}, {n}" "feature"="f" {
  %r = call float @llvm.sqrt.f32(float %n)
  ret float %r
}

define float @FNEGS(float "reg"="s" %n) "enc"="0010000 rb:5=n n:5 001 d:5 1010011" "asm"="fneg.s {d}, {n}" "feature"="f" {
  %r = fneg float %n
  ret float %r
}

define float @FABSS(float "reg"="s" %n) "enc"="0010000 rb:5=n n:5 010 d:5 1010011" "asm"="fabs.s {d}, {n}" "feature"="f" {
  %r = call float @llvm.fabs.f32(float %n)
  ret float %r
}

define float @FMVS(float "reg"="s" %n) "enc"="0010000 rb:5=n n:5 000 d:5 1010011" "asm"="fmv.s {d}, {n}" "feature"="f" "copy"="s" {
  ret float %n
}

define float @FMADDS(float "reg"="s" %n, float "reg"="s" %m, float "reg"="s" %a) "enc"="a:5 00 m:5 n:5 111 d:5 1000011" "asm"="fmadd.s {d}, {n}, {m}, {a}" "feature"="f" {
  %r = call float @llvm.fmuladd.f32(float %n, float %m, float %a)
  ret float %r
}

define float @FMADDSf(float "reg"="s" %n, float "reg"="s" %m, float "reg"="s" %a) "enc"="a:5 00 m:5 n:5 111 d:5 1000011" "asm"="fmadd.s {d}, {n}, {m}, {a}" "feature"="f" "nodecode" {
  %r = call float @llvm.fma.f32(float %n, float %m, float %a)
  ret float %r
}

define i1 @FEQS(float "reg"="s" %n, float "reg"="s" %m) "enc"="1010000 m:5 n:5 010 d:5 1010011" "asm"="feq.s {d}, {n}, {m}" "feature"="f" "zext"="1" {
  %r = fcmp oeq float %n, %m
  ret i1 %r
}

define i1 @FLTS(float "reg"="s" %n, float "reg"="s" %m) "enc"="1010000 m:5 n:5 001 d:5 1010011" "asm"="flt.s {d}, {n}, {m}" "feature"="f" "zext"="1" {
  %r = fcmp olt float %n, %m
  ret i1 %r
}

define i1 @FLES(float "reg"="s" %n, float "reg"="s" %m) "enc"="1010000 m:5 n:5 000 d:5 1010011" "asm"="fle.s {d}, {n}, {m}" "feature"="f" "zext"="1" {
  %r = fcmp ole float %n, %m
  ret i1 %r
}

define i1 @FGTS(float "reg"="s" %n, float "reg"="s" %m) "enc"="1010000 rb:5=n ra:5=m 001 d:5 1010011" "asm"="flt.s {d}, {m}, {n}" "feature"="f" "zext"="1" "nodecode" {
  %r = fcmp ogt float %n, %m
  ret i1 %r
}

define i1 @FGES(float "reg"="s" %n, float "reg"="s" %m) "enc"="1010000 rb:5=n ra:5=m 000 d:5 1010011" "asm"="fle.s {d}, {m}, {n}" "feature"="f" "zext"="1" "nodecode" {
  %r = fcmp oge float %n, %m
  ret i1 %r
}

define i64 @FCVTLS(float "reg"="s" %n) "enc"="1100000 00010 n:5 001 d:5 1010011" "asm"="fcvt.l.s {d}, {n}, rtz" "feature"="f" {
  %r = fptosi float %n to i64
  ret i64 %r
}

define i64 @FCVTLUS(float "reg"="s" %n) "enc"="1100000 00011 n:5 001 d:5 1010011" "asm"="fcvt.lu.s {d}, {n}, rtz" "feature"="f" {
  %r = fptoui float %n to i64
  ret i64 %r
}

define float @FCVTSL(i64 "reg"="x" %n) "enc"="1101000 00010 n:5 111 d:5 1010011" "asm"="fcvt.s.l {d}, {n}" "feature"="f" {
  %r = sitofp i64 %n to float
  ret float %r
}

define float @FCVTSLU(i64 "reg"="x" %n) "enc"="1101000 00011 n:5 111 d:5 1010011" "asm"="fcvt.s.lu {d}, {n}" "feature"="f" {
  %r = uitofp i64 %n to float
  ret float %r
}

define i32 @FCVTWS(float "reg"="s" %n) "enc"="1100000 00000 n:5 001 d:5 1010011" "asm"="fcvt.w.s {d}, {n}, rtz" "feature"="f" {
  %r = fptosi float %n to i32
  ret i32 %r
}

define i32 @FCVTWUS(float "reg"="s" %n) "enc"="1100000 00001 n:5 001 d:5 1010011" "asm"="fcvt.wu.s {d}, {n}, rtz" "feature"="f" {
  %r = fptoui float %n to i32
  ret i32 %r
}

define float @FCVTSW(i32 "reg"="w" %n) "enc"="1101000 00000 n:5 111 d:5 1010011" "asm"="fcvt.s.w {d}, {n}" "feature"="f" {
  %r = sitofp i32 %n to float
  ret float %r
}

define float @FCVTSWU(i32 "reg"="w" %n) "enc"="1101000 00001 n:5 111 d:5 1010011" "asm"="fcvt.s.wu {d}, {n}" "feature"="f" {
  %r = uitofp i32 %n to float
  ret float %r
}

define i32 @FMVXS(float "reg"="s" %n) "enc"="1110000 00000 n:5 000 d:5 1010011" "asm"="fmv.x.w {d}, {n}" "feature"="f" "role"="move.w.s" {
  %r = bitcast float %n to i32
  ret i32 %r
}

define float @FMVSX(i32 "reg"="w" %n) "enc"="1111000 00000 n:5 000 d:5 1010011" "asm"="fmv.w.x {d}, {n}" "feature"="f" "role"="move.s.w" {
  %r = bitcast i32 %n to float
  ret float %r
}

define float @FLS(ptr "reg"="x" %n, i64 "imm" %off) "enc"="off:s12 n:5 010 d:5 0000111" "asm"="flw {d}, {off}({n})" "feature"="f" "role"="load.s" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load float, ptr %p
  ret float %v
}

define void @FSS(float "reg"="s" %t, ptr "reg"="x" %n, i64 "imm" %off) "enc"="hi:s7=off>>5 t:5 n:5 010 lo:5=off&31 0100111" "asm"="fsw {t}, {off}({n})" "feature"="f" "role"="store.s" {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  ret void
}

define double @FCVTDS(float "reg"="s" %n) "enc"="0100001 00000 n:5 111 d:5 1010011" "asm"="fcvt.d.s {d}, {n}" "feature"="d" {
  %r = fpext float %n to double
  ret double %r
}

define float @FCVTSD(double "reg"="d" %n) "enc"="0100000 00001 n:5 111 d:5 1010011" "asm"="fcvt.s.d {d}, {n}" "feature"="d" {
  %r = fptrunc double %n to float
  ret float %r
}
