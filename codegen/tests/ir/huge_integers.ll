; Integers wider than 128 bits, as SROA makes of structs moved whole:
; loaded (volatile too) and stored, through a phi in a loop, shifted by
; constants each way, combined, extended, truncated, compared, selected.
target triple = "arm64-apple-macosx14.0.0"
define void @f(ptr %o, ptr %a, ptr %b, i32 %n) {
entry:
  %x = load i1152, ptr %a, align 8
  %y = load volatile i1152, ptr %b, align 8
  br label %loop
loop:
  %acc = phi i1152 [ %x, %entry ], [ %next, %loop ]
  %k = phi i32 [ 0, %entry ], [ %k1, %loop ]
  %s = lshr i1152 %acc, 72
  %t = shl i1152 %y, 3
  %u = xor i1152 %s, %t
  %next = or i1152 %u, 1
  %k1 = add i32 %k, 1
  %done = icmp eq i32 %k1, %n
  br i1 %done, label %out, label %loop
out:
  store i1152 %next, ptr %o, align 8
  %ar = ashr i1152 %y, 130
  %o1 = getelementptr i8, ptr %o, i64 144
  store i1152 %ar, ptr %o1, align 8
  %lo = trunc i1152 %next to i64
  %o2 = getelementptr i8, ptr %o, i64 288
  store i64 %lo, ptr %o2
  %mid = trunc i1152 %ar to i128
  %o3 = getelementptr i8, ptr %o, i64 296
  store i128 %mid, ptr %o3
  %part = trunc i1152 %next to i1088
  %o4 = getelementptr i8, ptr %o, i64 312
  store i1088 %part, ptr %o4, align 8
  %eq = icmp eq i1152 %x, %y
  %ne = icmp ne i1152 %next, %x
  %sel = select i1 %ne, i1152 %ar, i1152 %x
  %o5 = getelementptr i8, ptr %o, i64 448
  store i1152 %sel, ptr %o5, align 8
  %z = zext i64 %lo to i1152
  %sx = sext i128 %mid to i1152
  %w = and i1152 %z, %sx
  %o6 = getelementptr i8, ptr %o, i64 592
  store i1152 %w, ptr %o6, align 8
  %e8 = zext i1 %eq to i8
  %n8 = zext i1 %ne to i8
  %o7 = getelementptr i8, ptr %o, i64 736
  store i8 %e8, ptr %o7
  %o8 = getelementptr i8, ptr %o, i64 737
  store i8 %n8, ptr %o8
  ret void
}
