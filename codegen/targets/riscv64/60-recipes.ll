; The RISC-V RV64 description: recipes, for IR with no single instruction. Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

define i1 @icmp.eq.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="icmp.eq.x.expand" {
  %r = icmp eq i64 %a, %b
  ret i1 %r
}

define i1 @icmp.eq.x.expand(i64 %a, i64 %b) {
  %x = call i64 @XOR(i64 %a, i64 %b)
  %r = call i1 @SEQZ(i64 %x)
  ret i1 %r
}

define i1 @icmp.ne.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="icmp.ne.x.expand" {
  %r = icmp ne i64 %a, %b
  ret i1 %r
}

define i1 @icmp.ne.x.expand(i64 %a, i64 %b) {
  %x = call i64 @XOR(i64 %a, i64 %b)
  %r = call i1 @SNEZ(i64 %x)
  ret i1 %r
}

define i1 @icmp.sge.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="icmp.sge.x.expand" {
  %r = icmp sge i64 %a, %b
  ret i1 %r
}

define i1 @icmp.sge.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLT(i64 %a, i64 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.uge.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="icmp.uge.x.expand" {
  %r = icmp uge i64 %a, %b
  ret i1 %r
}

define i1 @icmp.uge.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLTU(i64 %a, i64 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.sle.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="icmp.sle.x.expand" {
  %r = icmp sle i64 %a, %b
  ret i1 %r
}

define i1 @icmp.sle.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLTs(i64 %a, i64 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.ule.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="icmp.ule.x.expand" {
  %r = icmp ule i64 %a, %b
  ret i1 %r
}

define i1 @icmp.ule.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLTUs(i64 %a, i64 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.eq.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="icmp.eq.w.expand" {
  %r = icmp eq i32 %a, %b
  ret i1 %r
}

define i1 @icmp.eq.w.expand(i32 %a, i32 %b) {
  %x = call i32 @XORw(i32 %a, i32 %b)
  %r = call i1 @SEQZw(i32 %x)
  ret i1 %r
}

define i1 @icmp.ne.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="icmp.ne.w.expand" {
  %r = icmp ne i32 %a, %b
  ret i1 %r
}

define i1 @icmp.ne.w.expand(i32 %a, i32 %b) {
  %x = call i32 @XORw(i32 %a, i32 %b)
  %r = call i1 @SNEZw(i32 %x)
  ret i1 %r
}

define i1 @icmp.sge.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="icmp.sge.w.expand" {
  %r = icmp sge i32 %a, %b
  ret i1 %r
}

define i1 @icmp.sge.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTw(i32 %a, i32 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.uge.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="icmp.uge.w.expand" {
  %r = icmp uge i32 %a, %b
  ret i1 %r
}

define i1 @icmp.uge.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTUw(i32 %a, i32 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.sle.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="icmp.sle.w.expand" {
  %r = icmp sle i32 %a, %b
  ret i1 %r
}

define i1 @icmp.sle.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTsw(i32 %a, i32 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @icmp.ule.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="icmp.ule.w.expand" {
  %r = icmp ule i32 %a, %b
  ret i1 %r
}

define i1 @icmp.ule.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTUsw(i32 %a, i32 %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i64 @select.x(i1 "reg"="w" %c, i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="select.x.expand" {
  %r = select i1 %c, i64 %a, i64 %b
  ret i64 %r
}

define i64 @select.x.expand(i1 %c, i64 %a, i64 %b) {
  %c1 = call i64 @ZEXT1x(i1 %c)
  %m = call i64 @NEG(i64 %c1)
  %ai = bitcast i64 %a to i64
  %bi = bitcast i64 %b to i64
  %x = call i64 @XOR(i64 %ai, i64 %bi)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %bi, i64 %y)
  %rt = bitcast i64 %r to i64
  ret i64 %rt
}

define i32 @select.w(i1 "reg"="w" %c, i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="select.w.expand" {
  %r = select i1 %c, i32 %a, i32 %b
  ret i32 %r
}

define i32 @select.w.expand(i1 %c, i32 %a, i32 %b) {
  %c1 = call i64 @ZEXT1x(i1 %c)
  %m = call i64 @NEG(i64 %c1)
  %ai = bitcast i32 %a to i64
  %bi = bitcast i32 %b to i64
  %x = call i64 @XOR(i64 %ai, i64 %bi)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %bi, i64 %y)
  %rt = bitcast i64 %r to i32
  ret i32 %rt
}

define ptr @select.p(i1 "reg"="w" %c, ptr "reg"="x" %a, ptr "reg"="x" %b) "recipe"="select.p.expand" {
  %r = select i1 %c, ptr %a, ptr %b
  ret ptr %r
}

define ptr @select.p.expand(i1 %c, ptr %a, ptr %b) {
  %c1 = call i64 @ZEXT1x(i1 %c)
  %m = call i64 @NEG(i64 %c1)
  %ai = bitcast ptr %a to i64
  %bi = bitcast ptr %b to i64
  %x = call i64 @XOR(i64 %ai, i64 %bi)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %bi, i64 %y)
  %rt = bitcast i64 %r to ptr
  ret ptr %rt
}

define double @select.d(i1 "reg"="w" %c, double "reg"="d" %a, double "reg"="d" %b) "recipe"="select.d.expand" {
  %r = select i1 %c, double %a, double %b
  ret double %r
}

define double @select.d.expand(i1 %c, double %a, double %b) {
  %ai = call i64 @FMVXD(double %a)
  %bi = call i64 @FMVXD(double %b)
  %c1 = call i64 @ZEXT1x(i1 %c)
  %m = call i64 @NEG(i64 %c1)
  %a64 = bitcast i64 %ai to i64
  %b64 = bitcast i64 %bi to i64
  %x = call i64 @XOR(i64 %a64, i64 %b64)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %b64, i64 %y)
  %rt = bitcast i64 %r to i64
  %f = call double @FMVDX(i64 %rt)
  ret double %f
}

define float @select.s(i1 "reg"="w" %c, float "reg"="s" %a, float "reg"="s" %b) "recipe"="select.s.expand" {
  %r = select i1 %c, float %a, float %b
  ret float %r
}

define float @select.s.expand(i1 %c, float %a, float %b) {
  %ai = call i32 @FMVXS(float %a)
  %bi = call i32 @FMVXS(float %b)
  %c1 = call i64 @ZEXT1x(i1 %c)
  %m = call i64 @NEG(i64 %c1)
  %a64 = bitcast i32 %ai to i64
  %b64 = bitcast i32 %bi to i64
  %x = call i64 @XOR(i64 %a64, i64 %b64)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %b64, i64 %y)
  %rt = bitcast i64 %r to i32
  %f = call float @FMVSX(i32 %rt)
  ret float %f
}


define i64 @smax.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="smax.x.expand" {
  %r = call i64 @llvm.smax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smax.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLT(i64 %a, i64 %b)
  %c1 = call i64 @ZEXT1x(i1 %l)
  %m = call i64 @NEG(i64 %c1)
  %x = call i64 @XOR(i64 %a, i64 %b)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %a, i64 %y)
  ret i64 %r
}


define i32 @smax.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="smax.w.expand" {
  %r = call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smax.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTw(i32 %a, i32 %b)
  %c1 = call i32 @ZEXT1w(i1 %l)
  %m = call i32 @NEGW(i32 %c1)
  %x = call i32 @XORw(i32 %a, i32 %b)
  %y = call i32 @ANDw(i32 %x, i32 %m)
  %r = call i32 @XORw(i32 %a, i32 %y)
  ret i32 %r
}


define i64 @smin.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="smin.x.expand" {
  %r = call i64 @llvm.smin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smin.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLTs(i64 %a, i64 %b)
  %c1 = call i64 @ZEXT1x(i1 %l)
  %m = call i64 @NEG(i64 %c1)
  %x = call i64 @XOR(i64 %a, i64 %b)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %a, i64 %y)
  ret i64 %r
}


define i32 @smin.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="smin.w.expand" {
  %r = call i32 @llvm.smin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smin.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTsw(i32 %a, i32 %b)
  %c1 = call i32 @ZEXT1w(i1 %l)
  %m = call i32 @NEGW(i32 %c1)
  %x = call i32 @XORw(i32 %a, i32 %b)
  %y = call i32 @ANDw(i32 %x, i32 %m)
  %r = call i32 @XORw(i32 %a, i32 %y)
  ret i32 %r
}


define i64 @umax.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="umax.x.expand" {
  %r = call i64 @llvm.umax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umax.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLTU(i64 %a, i64 %b)
  %c1 = call i64 @ZEXT1x(i1 %l)
  %m = call i64 @NEG(i64 %c1)
  %x = call i64 @XOR(i64 %a, i64 %b)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %a, i64 %y)
  ret i64 %r
}


define i32 @umax.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="umax.w.expand" {
  %r = call i32 @llvm.umax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umax.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTUw(i32 %a, i32 %b)
  %c1 = call i32 @ZEXT1w(i1 %l)
  %m = call i32 @NEGW(i32 %c1)
  %x = call i32 @XORw(i32 %a, i32 %b)
  %y = call i32 @ANDw(i32 %x, i32 %m)
  %r = call i32 @XORw(i32 %a, i32 %y)
  ret i32 %r
}


define i64 @umin.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="umin.x.expand" {
  %r = call i64 @llvm.umin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umin.x.expand(i64 %a, i64 %b) {
  %l = call i1 @SLTUs(i64 %a, i64 %b)
  %c1 = call i64 @ZEXT1x(i1 %l)
  %m = call i64 @NEG(i64 %c1)
  %x = call i64 @XOR(i64 %a, i64 %b)
  %y = call i64 @AND(i64 %x, i64 %m)
  %r = call i64 @XOR(i64 %a, i64 %y)
  ret i64 %r
}


define i32 @umin.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="umin.w.expand" {
  %r = call i32 @llvm.umin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umin.w.expand(i32 %a, i32 %b) {
  %l = call i1 @SLTUsw(i32 %a, i32 %b)
  %c1 = call i32 @ZEXT1w(i1 %l)
  %m = call i32 @NEGW(i32 %c1)
  %x = call i32 @XORw(i32 %a, i32 %b)
  %y = call i32 @ANDw(i32 %x, i32 %m)
  %r = call i32 @XORw(i32 %a, i32 %y)
  ret i32 %r
}

define i64 @sext.i1.i64(i1 "reg"="w" %n) "recipe"="sext.i1.i64.expand" {
  %r = sext i1 %n to i64
  ret i64 %r
}

define i64 @sext.i1.i64.expand(i1 %n) {
  %w = zext i1 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 63)
  %d = call i64 @SRAI(i64 %u, i64 63)
  %r = trunc i64 %d to i64
  ret i64 %r
}

define i32 @sext.i1.i32(i1 "reg"="w" %n) "recipe"="sext.i1.i32.expand" {
  %r = sext i1 %n to i32
  ret i32 %r
}

define i32 @sext.i1.i32.expand(i1 %n) {
  %w = zext i1 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 63)
  %d = call i64 @SRAI(i64 %u, i64 63)
  %r = trunc i64 %d to i32
  ret i32 %r
}

define i64 @sext.i8.i64(i8 "reg"="w" %n) "recipe"="sext.i8.i64.expand" {
  %r = sext i8 %n to i64
  ret i64 %r
}

define i64 @sext.i8.i64.expand(i8 %n) {
  %w = zext i8 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 56)
  %d = call i64 @SRAI(i64 %u, i64 56)
  %r = trunc i64 %d to i64
  ret i64 %r
}

define i32 @sext.i8.i32(i8 "reg"="w" %n) "recipe"="sext.i8.i32.expand" {
  %r = sext i8 %n to i32
  ret i32 %r
}

define i32 @sext.i8.i32.expand(i8 %n) {
  %w = zext i8 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 56)
  %d = call i64 @SRAI(i64 %u, i64 56)
  %r = trunc i64 %d to i32
  ret i32 %r
}

define i64 @sext.i16.i64(i16 "reg"="w" %n) "recipe"="sext.i16.i64.expand" {
  %r = sext i16 %n to i64
  ret i64 %r
}

define i64 @sext.i16.i64.expand(i16 %n) {
  %w = zext i16 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 48)
  %d = call i64 @SRAI(i64 %u, i64 48)
  %r = trunc i64 %d to i64
  ret i64 %r
}

define i64 @zext.i16.i64(i16 "reg"="w" %n) "recipe"="zext.i16.i64.expand" {
  %r = zext i16 %n to i64
  ret i64 %r
}

define i64 @zext.i16.i64.expand(i16 %n) {
  %w = zext i16 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 48)
  %d = call i64 @SRLI(i64 %u, i64 48)
  %r = trunc i64 %d to i64
  ret i64 %r
}

define i32 @sext.i16.i32(i16 "reg"="w" %n) "recipe"="sext.i16.i32.expand" {
  %r = sext i16 %n to i32
  ret i32 %r
}

define i32 @sext.i16.i32.expand(i16 %n) {
  %w = zext i16 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 48)
  %d = call i64 @SRAI(i64 %u, i64 48)
  %r = trunc i64 %d to i32
  ret i32 %r
}

define i32 @zext.i16.i32(i16 "reg"="w" %n) "recipe"="zext.i16.i32.expand" {
  %r = zext i16 %n to i32
  ret i32 %r
}

define i32 @zext.i16.i32.expand(i16 %n) {
  %w = zext i16 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 48)
  %d = call i64 @SRLI(i64 %u, i64 48)
  %r = trunc i64 %d to i32
  ret i32 %r
}

define i64 @zext.i32.i64(i32 "reg"="x" %n) "recipe"="zext.i32.i64.expand" {
  %r = zext i32 %n to i64
  ret i64 %r
}

define i64 @zext.i32.i64.expand(i32 %n) {
  %w = zext i32 %n to i64
  %u = call i64 @SLLI(i64 %w, i64 32)
  %d = call i64 @SRLI(i64 %u, i64 32)
  %r = trunc i64 %d to i64
  ret i64 %r
}

declare i64 @llvm.abs.i64(i64, i1)

define i64 @abs.x(i64 "reg"="x" %n) "recipe"="abs.x.expand" {
  %r = call i64 @llvm.abs.i64(i64 %n, i1 false)
  ret i64 %r
}

define i64 @abs.x.expand(i64 %n) {
  %s = call i64 @SRAI(i64 %n, i64 63)
  %x = call i64 @XOR(i64 %n, i64 %s)
  %r = call i64 @SUB(i64 %x, i64 %s)
  ret i64 %r
}

declare i32 @llvm.abs.i32(i32, i1)

define i32 @abs.w(i32 "reg"="w" %n) "recipe"="abs.w.expand" {
  %r = call i32 @llvm.abs.i32(i32 %n, i1 false)
  ret i32 %r
}

define i32 @abs.w.expand(i32 %n) {
  %s = call i32 @SRAIW(i32 %n, i32 31)
  %x = call i32 @XORw(i32 %n, i32 %s)
  %r = call i32 @SUBW(i32 %x, i32 %s)
  ret i32 %r
}

define i1 @fcmp.une.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.une.d.expand" {
  %r = fcmp une double %a, %b
  ret i1 %r
}

define i1 @fcmp.une.d.expand(double %a, double %b) {
  %l = call i1 @FEQD(double %a, double %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.uge.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.uge.d.expand" {
  %r = fcmp uge double %a, %b
  ret i1 %r
}

define i1 @fcmp.uge.d.expand(double %a, double %b) {
  %l = call i1 @FLTD(double %a, double %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ugt.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.ugt.d.expand" {
  %r = fcmp ugt double %a, %b
  ret i1 %r
}

define i1 @fcmp.ugt.d.expand(double %a, double %b) {
  %l = call i1 @FLED(double %a, double %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ule.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.ule.d.expand" {
  %r = fcmp ule double %a, %b
  ret i1 %r
}

define i1 @fcmp.ule.d.expand(double %a, double %b) {
  %l = call i1 @FLTD(double %b, double %a)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ult.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.ult.d.expand" {
  %r = fcmp ult double %a, %b
  ret i1 %r
}

define i1 @fcmp.ult.d.expand(double %a, double %b) {
  %l = call i1 @FLED(double %b, double %a)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ord.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.ord.d.expand" {
  %r = fcmp ord double %a, %b
  ret i1 %r
}

define i1 @fcmp.ord.d.expand(double %a, double %b) {
  %x = call i1 @FEQD(double %a, double %a)
  %y = call i1 @FEQD(double %b, double %b)
  %r = call i1 @ANDb(i1 %x, i1 %y)
  ret i1 %r
}

define i1 @fcmp.uno.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.uno.d.expand" {
  %r = fcmp uno double %a, %b
  ret i1 %r
}

define i1 @fcmp.uno.d.expand(double %a, double %b) {
  %x = call i1 @FEQD(double %a, double %a)
  %y = call i1 @FEQD(double %b, double %b)
  %z = call i1 @ANDb(i1 %x, i1 %y)
  %r = call i1 @XORIb(i1 %z, i1 1)
  ret i1 %r
}

define i1 @fcmp.one.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.one.d.expand" {
  %r = fcmp one double %a, %b
  ret i1 %r
}

define i1 @fcmp.one.d.expand(double %a, double %b) {
  %x = call i1 @FLTD(double %a, double %b)
  %y = call i1 @FLTD(double %b, double %a)
  %r = call i1 @ORb(i1 %x, i1 %y)
  ret i1 %r
}

define i1 @fcmp.ueq.d(double "reg"="d" %a, double "reg"="d" %b) "recipe"="fcmp.ueq.d.expand" {
  %r = fcmp ueq double %a, %b
  ret i1 %r
}

define i1 @fcmp.ueq.d.expand(double %a, double %b) {
  %x = call i1 @FLTD(double %a, double %b)
  %y = call i1 @FLTD(double %b, double %a)
  %z = call i1 @ORb(i1 %x, i1 %y)
  %r = call i1 @XORIb(i1 %z, i1 1)
  ret i1 %r
}

define i1 @fcmp.une.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.une.s.expand" {
  %r = fcmp une float %a, %b
  ret i1 %r
}

define i1 @fcmp.une.s.expand(float %a, float %b) {
  %l = call i1 @FEQS(float %a, float %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.uge.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.uge.s.expand" {
  %r = fcmp uge float %a, %b
  ret i1 %r
}

define i1 @fcmp.uge.s.expand(float %a, float %b) {
  %l = call i1 @FLTS(float %a, float %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ugt.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.ugt.s.expand" {
  %r = fcmp ugt float %a, %b
  ret i1 %r
}

define i1 @fcmp.ugt.s.expand(float %a, float %b) {
  %l = call i1 @FLES(float %a, float %b)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ule.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.ule.s.expand" {
  %r = fcmp ule float %a, %b
  ret i1 %r
}

define i1 @fcmp.ule.s.expand(float %a, float %b) {
  %l = call i1 @FLTS(float %b, float %a)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ult.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.ult.s.expand" {
  %r = fcmp ult float %a, %b
  ret i1 %r
}

define i1 @fcmp.ult.s.expand(float %a, float %b) {
  %l = call i1 @FLES(float %b, float %a)
  %r = call i1 @XORIb(i1 %l, i1 1)
  ret i1 %r
}

define i1 @fcmp.ord.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.ord.s.expand" {
  %r = fcmp ord float %a, %b
  ret i1 %r
}

define i1 @fcmp.ord.s.expand(float %a, float %b) {
  %x = call i1 @FEQS(float %a, float %a)
  %y = call i1 @FEQS(float %b, float %b)
  %r = call i1 @ANDb(i1 %x, i1 %y)
  ret i1 %r
}

define i1 @fcmp.uno.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.uno.s.expand" {
  %r = fcmp uno float %a, %b
  ret i1 %r
}

define i1 @fcmp.uno.s.expand(float %a, float %b) {
  %x = call i1 @FEQS(float %a, float %a)
  %y = call i1 @FEQS(float %b, float %b)
  %z = call i1 @ANDb(i1 %x, i1 %y)
  %r = call i1 @XORIb(i1 %z, i1 1)
  ret i1 %r
}

define i1 @fcmp.one.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.one.s.expand" {
  %r = fcmp one float %a, %b
  ret i1 %r
}

define i1 @fcmp.one.s.expand(float %a, float %b) {
  %x = call i1 @FLTS(float %a, float %b)
  %y = call i1 @FLTS(float %b, float %a)
  %r = call i1 @ORb(i1 %x, i1 %y)
  ret i1 %r
}

define i1 @fcmp.ueq.s(float "reg"="s" %a, float "reg"="s" %b) "recipe"="fcmp.ueq.s.expand" {
  %r = fcmp ueq float %a, %b
  ret i1 %r
}

define i1 @fcmp.ueq.s.expand(float %a, float %b) {
  %x = call i1 @FLTS(float %a, float %b)
  %y = call i1 @FLTS(float %b, float %a)
  %z = call i1 @ORb(i1 %x, i1 %y)
  %r = call i1 @XORIb(i1 %z, i1 1)
  ret i1 %r
}
