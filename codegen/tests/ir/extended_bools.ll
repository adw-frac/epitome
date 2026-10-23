; Booleans extended and compared with 0 or with what they were extended
; from (prepare.rs, extended_bool_compares): a compare's, inverted; a
; float compare's; and a loaded boolean's, which is xor'ed instead.
define i32 @f(i16 %a, double %x, ptr %p) {
entry:
  %c = icmp ne i16 %a, 26211
  %z = zext i1 %c to i32
  %n = icmp eq i32 %z, 0
  br i1 %n, label %yes, label %no

yes:
  %d = fcmp olt double %x, 1.5
  %s = sext i1 %d to i64
  %m = icmp ne i64 %s, -1
  %lb = load i8, ptr %p, !range !0
  %b = trunc i8 %lb to i1
  %zb = zext i1 %b to i8
  %e = icmp eq i8 %zb, 1
  %r1 = zext i1 %m to i32
  %r2 = zext i1 %e to i32
  %r3 = shl i32 %r2, 1
  %r = or i32 %r1, %r3
  ret i32 %r

no:
  ret i32 7
}

!0 = !{i8 0, i8 2}
