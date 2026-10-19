; @zero: memcpyopt: 6 stores made 1 memsets
; @zero: combine: (dead) x5

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

%s = type { i32, i32, i64, i16, i16, i32 }

define void @zero(ptr %p) {
  call void @llvm.memset.p0.i64(ptr align 8 %p, i8 0, i64 24, i1 false)
  ret void
}

declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
