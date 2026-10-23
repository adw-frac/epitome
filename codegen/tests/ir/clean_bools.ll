; Booleans that are exactly 0 or 1 in their registers, made by compares and
; carried through phis, selects and bitwise operations, extended without a
; mask (isel.rs, clean_bools); and ones that are not (a truncation, an
; argument), extended with one.
define i64 @f(i64 %a, i64 %b, i8 %t, i1 zeroext %z) {
entry:
  %c = icmp ult i64 %a, %b
  %d = icmp eq i64 %a, 7
  br i1 %d, label %one, label %two

one:
  %x = xor i1 %c, true
  br label %join

two:
  %tb = trunc i8 %t to i1
  %y = select i1 %c, i1 %tb, i1 %z
  br label %join

join:
  %p = phi i1 [ %x, %one ], [ %y, %two ]
  %q = phi i1 [ true, %one ], [ %c, %two ]
  %pq = and i1 %p, %q
  %e1 = zext i1 %pq to i64
  %e2 = zext i1 %q to i64
  %s = shl i64 %e2, 1
  %r = or i64 %e1, %s
  ret i64 %r
}
