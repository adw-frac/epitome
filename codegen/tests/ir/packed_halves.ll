; Two 32-bit halves packed into an i64, carried round a loop by a phi,
; mixed with xor, and taken apart again: the halves throughout
; (bitmaps.rs, split_packed), and rotated as halves.
define void @f(ptr %out, ptr %in, i64 %n) {
entry:
  %a0 = load i32, ptr %in
  %p1 = getelementptr i8, ptr %in, i64 4
  %b0 = load i32, ptr %p1
  %za = zext i32 %a0 to i64
  %zb = zext i32 %b0 to i64
  %sb = shl nuw i64 %zb, 32
  %init = or disjoint i64 %sb, %za
  br label %loop

loop:
  %x = phi i64 [ %init, %entry ], [ %next, %loop ]
  %i = phi i64 [ 0, %entry ], [ %i1, %loop ]
  %lo = trunc i64 %x to i32
  %hs = lshr i64 %x, 32
  %hi = trunc i64 %hs to i32
  %rl = call i32 @llvm.fshl.i32(i32 %lo, i32 %lo, i32 7)
  %rh = call i32 @llvm.fshl.i32(i32 %hi, i32 %hi, i32 13)
  %sum = add i32 %rl, %rh
  %zl = zext i32 %sum to i64
  %zh = zext i32 %rl to i64
  %sh = shl nuw i64 %zh, 32
  %k = or disjoint i64 %sh, %zl
  %m = xor i64 %k, 81985529216486895
  %next = xor i64 %m, %x
  %i1 = add i64 %i, 1
  %c = icmp ult i64 %i1, %n
  br i1 %c, label %loop, label %done

done:
  %flo = trunc i64 %next to i32
  %fs = lshr i64 %next, 32
  %fhi = trunc i64 %fs to i32
  store i32 %flo, ptr %out
  %o1 = getelementptr i8, ptr %out, i64 4
  store i32 %fhi, ptr %o1
  ret void
}

declare i32 @llvm.fshl.i32(i32, i32, i32)
