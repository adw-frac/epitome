; Vectors of i24 lanes, as SROA makes of [u8; 3]s: built from bytes,
; shifted both ways, multiplied, divided, compared, extended and taken apart.
target triple = "arm64-apple-macosx14.0.0"
define void @f(ptr %out, ptr %a, ptr %b, ptr %c) {
  %x = load <8 x i8>, ptr %a
  %y = load <8 x i8>, ptr %b
  %z = load <8 x i8>, ptr %c
  %x1 = zext <8 x i8> %x to <8 x i24>
  %x2 = shl nuw <8 x i24> %x1, splat (i24 16)
  %y1 = zext <8 x i8> %y to <8 x i24>
  %y2 = shl nuw <8 x i24> %y1, splat (i24 8)
  %z1 = zext <8 x i8> %z to <8 x i24>
  %w = or <8 x i24> %x2, %y2
  %v = or <8 x i24> %w, %z1
  %s1 = lshr <8 x i24> %v, splat (i24 5)
  %s2 = ashr <8 x i24> %v, splat (i24 3)
  %m = mul <8 x i24> %v, splat (i24 1000)
  %d = udiv <8 x i24> %m, splat (i24 7)
  %q = sdiv <8 x i24> %m, splat (i24 9)
  %c1 = icmp slt <8 x i24> %m, zeroinitializer
  %c2 = icmp ugt <8 x i24> %v, splat (i24 8000000)
  %sel = select <8 x i1> %c1, <8 x i24> %s1, <8 x i24> %s2
  %e1 = sext <8 x i24> %q to <8 x i64>
  %e2 = zext <8 x i24> %d to <8 x i64>
  %sum = add <8 x i64> %e1, %e2
  %t = trunc <8 x i24> %sel to <8 x i16>
  %t64 = sext <8 x i16> %t to <8 x i64>
  %all = add <8 x i64> %sum, %t64
  %c3 = and <8 x i1> %c1, %c2
  %c3z = zext <8 x i1> %c3 to <8 x i64>
  %r = add <8 x i64> %all, %c3z
  store <8 x i64> %r, ptr %out
  %l3 = extractelement <8 x i24> %m, i64 3
  %l3e = sext i24 %l3 to i64
  %p = getelementptr i8, ptr %out, i64 64
  store i64 %l3e, ptr %p
  ret void
}
