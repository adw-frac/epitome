target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

declare void @opaque()
declare i32 @reads(ptr) memory(read)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

; Straight line: which store reaches each load?
define i32 @straight(ptr %p, ptr %q) {
entry:
  %a = alloca [4 x i32]
  %b = alloca i32
  %a0 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 0
  %a1 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 1
  store i32 1, ptr %a0
  store i32 2, ptr %a1
  store i32 3, ptr %b
  store i32 4, ptr %p
  %x = load i32, ptr %a0        ; a0: past b, a1 and p, to the first store
  %y = load i32, ptr %q         ; q may be p: the store to p
  %r = call i32 @reads(ptr %q)  ; reads only: a use
  call void @opaque()           ; may write anything that escapes
  %z = load i32, ptr %p         ; the opaque call
  %w = load i32, ptr %a1        ; a does not escape: past the call
  %s1 = add i32 %x, %y
  %s2 = add i32 %z, %w
  %s3 = add i32 %s1, %s2
  ret i32 %s3
}

; A diamond: both arms write p, so the join has a phi.
define i32 @diamond(i1 %c, ptr %p, ptr noalias %n) {
entry:
  store i32 0, ptr %n
  br i1 %c, label %then, label %else
then:
  store i32 1, ptr %p
  br label %join
else:
  store i32 2, ptr %p
  br label %join
join:
  %v = load i32, ptr %p         ; the phi: different stores each way
  %u = load i32, ptr %n         ; noalias n: past the phi to the first store
  %t = add i32 %v, %u
  ret i32 %t
}

; A loop that writes only its own array: a load of g goes round it.
@g = global i32 7
define i32 @loop(i64 %n) {
entry:
  %buf = alloca [16 x i32]
  store i32 5, ptr @g
  br label %head
head:
  %i = phi i64 [ 0, %entry ], [ %i1, %head ]
  %e = getelementptr inbounds [16 x i32], ptr %buf, i64 0, i64 %i
  store i32 9, ptr %e
  %i1 = add i64 %i, 1
  %c = icmp ult i64 %i1, %n
  br i1 %c, label %head, label %exit
exit:
  %v = load i32, ptr @g         ; past the loop's phi: the store of 5
  ret i32 %v
}

; memcpy writes its destination's bytes only; a volatile load is a write.
define i32 @copies(ptr noalias %dst, ptr noalias %src, ptr noalias %other) {
entry:
  store i32 1, ptr %other
  call void @llvm.memcpy.p0.p0.i64(ptr %dst, ptr %src, i64 16, i1 false)
  %d4 = getelementptr inbounds i8, ptr %dst, i64 4
  %d32 = getelementptr inbounds i8, ptr %dst, i64 32
  %x = load i32, ptr %d4        ; inside the copy: the memcpy
  %y = load i32, ptr %d32       ; past its 16 bytes
  %o = load i32, ptr %other     ; the first store
  %v = load volatile i32, ptr %src
  %s = add i32 %x, %y
  %t = add i32 %s, %o
  %u = add i32 %t, %v
  ret i32 %u
}

; The same pointer value is another address in each iteration: the load
; of e must not be "clobbered by" last iteration's store to e. But p is
; the same address every time round, so p's load sees the loop's store.
define i32 @carried(ptr %a, ptr %p, i64 %n) {
entry:
  br label %head
head:
  %i = phi i64 [ 0, %entry ], [ %i1, %head ]
  %e = getelementptr inbounds i32, ptr %a, i64 %i
  %x = load i32, ptr %e         ; the phi: e is defined in the loop
  %y = load i32, ptr %p         ; p is fixed: the phi too, as the loop writes e
  store i32 %x, ptr %e
  %i1 = add i64 %i, 1
  %c = icmp ult i64 %i1, %n
  br i1 %c, label %head, label %exit
exit:
  %z = load i32, ptr %p         ; the store in the loop
  ret i32 %z
}
