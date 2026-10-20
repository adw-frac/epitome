; epitome-opt: --passes=memory,combine
; memcpyopt: six stores of zero to a struct's fields become one memset.
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
%s = type { i32, i32, i64, i16, i16, i32 }
define void @zero(ptr %p) {
  store i32 0, ptr %p, align 8
  %b = getelementptr inbounds %s, ptr %p, i32 0, i32 1
  store i32 0, ptr %b, align 4
  %c = getelementptr inbounds %s, ptr %p, i32 0, i32 2
  store i64 0, ptr %c, align 8
  %d = getelementptr inbounds %s, ptr %p, i32 0, i32 3
  store i16 0, ptr %d, align 8
  %e = getelementptr inbounds %s, ptr %p, i32 0, i32 4
  store i16 0, ptr %e, align 2
  %f = getelementptr inbounds %s, ptr %p, i32 0, i32 5
  store i32 0, ptr %f, align 4
  ret void
}
