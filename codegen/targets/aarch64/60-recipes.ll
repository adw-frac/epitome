; The AArch64 description: recipes, for IR with no single instruction. The
; conventions are in 00-base.ll.

; ===========================================================================
; Recipes: IR with no single instruction.

define i32 @srem.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="srem.w.expand" {
  %r = srem i32 %a, %b
  ret i32 %r
}

define i32 @srem.w.expand(i32 %a, i32 %b) {
  %q = call i32 @SDIVW(i32 %a, i32 %b)
  %r = call i32 @MSUBW(i32 %q, i32 %b, i32 %a)
  ret i32 %r
}

define i64 @srem.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="srem.x.expand" {
  %r = srem i64 %a, %b
  ret i64 %r
}

define i64 @srem.x.expand(i64 %a, i64 %b) {
  %q = call i64 @SDIVX(i64 %a, i64 %b)
  %r = call i64 @MSUBX(i64 %q, i64 %b, i64 %a)
  ret i64 %r
}

define i32 @urem.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="urem.w.expand" {
  %r = urem i32 %a, %b
  ret i32 %r
}

define i32 @urem.w.expand(i32 %a, i32 %b) {
  %q = call i32 @UDIVW(i32 %a, i32 %b)
  %r = call i32 @MSUBW(i32 %q, i32 %b, i32 %a)
  ret i32 %r
}

define i64 @urem.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="urem.x.expand" {
  %r = urem i64 %a, %b
  ret i64 %r
}

define i64 @urem.x.expand(i64 %a, i64 %b) {
  %q = call i64 @UDIVX(i64 %a, i64 %b)
  %r = call i64 @MSUBX(i64 %q, i64 %b, i64 %a)
  ret i64 %r
}

; A select on a boolean in a register: test bit 0, then csel.
define i32 @select.w(i1 "reg"="w" %c, i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="select.w.expand" {
  %r = select i1 %c, i32 %a, i32 %b
  ret i32 %r
}

define i32 @select.w.expand(i1 %c, i32 %a, i32 %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call i32 @CSELW(i1 %ne, i32 %a, i32 %b)
  ret i32 %r
}

define i64 @select.x(i1 "reg"="w" %c, i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="select.x.expand" {
  %r = select i1 %c, i64 %a, i64 %b
  ret i64 %r
}

define i64 @select.x.expand(i1 %c, i64 %a, i64 %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call i64 @CSELX(i1 %ne, i64 %a, i64 %b)
  ret i64 %r
}

define ptr @select.p(i1 "reg"="w" %c, ptr "reg"="x" %a, ptr "reg"="x" %b) "recipe"="select.p.expand" {
  %r = select i1 %c, ptr %a, ptr %b
  ret ptr %r
}

define ptr @select.p.expand(i1 %c, ptr %a, ptr %b) {
  %c32 = zext i1 %c to i32
  %f = call %nzcv @TSTWri(i32 %c32, i32 1)
  %ne = call i1 @cc.ne(%nzcv %f)
  %r = call ptr @CSELP(i1 %ne, ptr %a, ptr %b)
  ret ptr %r
}

; Minimum and maximum: compare, then select.

declare i32 @llvm.smax.i32(i32, i32)

define i32 @smax.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="smax.w.expand" {
  %r = call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smax.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.gt(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.smax.i64(i64, i64)

define i64 @smax.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="smax.x.expand" {
  %r = call i64 @llvm.smax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smax.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.gt(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

declare i32 @llvm.smin.i32(i32, i32)

define i32 @smin.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="smin.w.expand" {
  %r = call i32 @llvm.smin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @smin.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.lt(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.smin.i64(i64, i64)

define i64 @smin.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="smin.x.expand" {
  %r = call i64 @llvm.smin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @smin.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.lt(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

declare i32 @llvm.umax.i32(i32, i32)

define i32 @umax.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="umax.w.expand" {
  %r = call i32 @llvm.umax.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umax.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.hi(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.umax.i64(i64, i64)

define i64 @umax.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="umax.x.expand" {
  %r = call i64 @llvm.umax.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umax.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.hi(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

declare i32 @llvm.umin.i32(i32, i32)

define i32 @umin.w(i32 "reg"="w" %a, i32 "reg"="w" %b) "recipe"="umin.w.expand" {
  %r = call i32 @llvm.umin.i32(i32 %a, i32 %b)
  ret i32 %r
}

define i32 @umin.w.expand(i32 %a, i32 %b) {
  %f = call %nzcv @CMPWrr(i32 %a, i32 %b)
  %c = call i1 @cc.lo(%nzcv %f)
  %r = call i32 @CSELW(i1 %c, i32 %a, i32 %b)
  ret i32 %r
}

declare i64 @llvm.umin.i64(i64, i64)

define i64 @umin.x(i64 "reg"="x" %a, i64 "reg"="x" %b) "recipe"="umin.x.expand" {
  %r = call i64 @llvm.umin.i64(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @umin.x.expand(i64 %a, i64 %b) {
  %f = call %nzcv @CMPXrr(i64 %a, i64 %b)
  %c = call i1 @cc.lo(%nzcv %f)
  %r = call i64 @CSELX(i1 %c, i64 %a, i64 %b)
  ret i64 %r
}

