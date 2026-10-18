; @fields: sroa: 1 allocas split into 2 pieces
; @fields: mem2reg: 2 allocas promoted (2 loads, 2 stores removed)
; @returned: sroa: 1 allocas split into 1 pieces
; @returned: mem2reg: 1 allocas promoted (2 loads, 1 stores removed)
; @mixed: sroa: 1 allocas split into 3 pieces
; @mixed: mem2reg: 3 allocas promoted (2 loads, 3 stores removed)
; @punning: sroa: 1 allocas split into 1 pieces
; @punning: mem2reg: 1 allocas promoted (1 loads, 1 stores removed)
; @update: sroa: 1 allocas split into 1 pieces
; @update: mem2reg: 1 allocas promoted (2 loads, 2 stores removed)
; @copies: sroa: 3 allocas split into 5 pieces
; @copies: mem2reg: 5 allocas promoted (5 loads, 5 stores removed)

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

%point = type { i32, i32 }
%mixed = type { i8, double, [2 x i16] }

@init = private constant %point { i32 3, i32 4 }

declare void @use(ptr)

define i32 @fields(i32 %a, i32 %b) {
  %r = add i32 %a, %b
  ret i32 %r
}

define i32 @returned(i64 %packed) {
  %sroa1 = trunc i64 %packed to i32
  %sroa3 = lshr i64 %packed, 32
  %sroa4 = trunc i64 %sroa3 to i32
  %r = sub i32 %sroa1, %sroa4
  ret i32 %r
}

define double @mixed(i8 %c, double %d, i16 %h) {
  %hf = sitofp i16 %h to double
  %r = fadd double %d, %hf
  ret double %r
}

define i32 @punning(float %f) {
  %sroa = bitcast float %f to i32
  ret i32 %sroa
}

define i64 @update(i64 %packed, i32 %y) {
  %sroa2 = zext i32 %y to i64
  %sroa3 = shl i64 %sroa2, 32
  %sroa4 = and i64 %packed, 4294967295
  %sroa5 = or i64 %sroa4, %sroa3
  ret i64 %sroa5
}

define i32 @kept(i64 %i) {
  %a = alloca %point
  %b = alloca [4 x i32]
  store i32 1, ptr %a
  call void @use(ptr %a)
  %e = getelementptr inbounds [4 x i32], ptr %b, i64 0, i64 %i
  store i32 2, ptr %e
  %x = load i32, ptr %a
  %y = load i32, ptr %b
  %r = add i32 %x, %y
  ret i32 %r
}

define i32 @copies() {
  %sroa3 = load i32, ptr @init, align 1
  %sroa4 = getelementptr i8, ptr @init, i64 4
  %sroa5 = load i32, ptr %sroa4, align 1
  %w32 = trunc i64 0 to i32
  %s = add i32 %sroa3, %sroa5
  %r = add i32 %s, %w32
  ret i32 %r
}
