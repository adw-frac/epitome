; Bits of a vector of integers taken as lanes of a mask (chrono's test of
; a bit of a <4 x i32>), at the edges of lanes and between.
target triple = "arm64-apple-macosx14.0.0"

define i32 @bits(ptr %p) {
  %v = load <4 x i32>, ptr %p
  %m = bitcast <4 x i32> %v to <128 x i1>
  %b0 = extractelement <128 x i1> %m, i64 0
  %b1 = extractelement <128 x i1> %m, i64 31
  %b2 = extractelement <128 x i1> %m, i64 32
  %b3 = extractelement <128 x i1> %m, i64 77
  %b4 = extractelement <128 x i1> %m, i64 127
  %w = load <8 x i16>, ptr %p
  %n = bitcast <8 x i16> %w to <128 x i1>
  %b5 = extractelement <128 x i1> %n, i64 17
  %z0 = zext i1 %b0 to i32
  %z1 = zext i1 %b1 to i32
  %z2 = zext i1 %b2 to i32
  %z3 = zext i1 %b3 to i32
  %z4 = zext i1 %b4 to i32
  %z5 = zext i1 %b5 to i32
  %s1 = shl i32 %z1, 1
  %s2 = shl i32 %z2, 2
  %s3 = shl i32 %z3, 3
  %s4 = shl i32 %z4, 4
  %s5 = shl i32 %z5, 5
  %o1 = or i32 %z0, %s1
  %o2 = or i32 %o1, %s2
  %o3 = or i32 %o2, %s3
  %o4 = or i32 %o3, %s4
  %o5 = or i32 %o4, %s5
  ret i32 %o5
}
