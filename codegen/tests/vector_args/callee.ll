; Functions taking and returning vectors no register holds, by value.
target triple = "arm64-apple-macosx14.0.0"
define <4 x i64> @w(<4 x i64> %x, <4 x i64> %y) {
  %r = sub <4 x i64> %x, %y
  ret <4 x i64> %r
}
define <3 x float> @t(<3 x float> %x, float %k) {
  %s = insertelement <3 x float> poison, float %k, i64 0
  %sp = shufflevector <3 x float> %s, <3 x float> poison, <3 x i32> zeroinitializer
  %r = fmul <3 x float> %x, %sp
  ret <3 x float> %r
}
define <2 x i8> @b(<2 x i8> %x, <2 x i8> %y) {
  %r = sub <2 x i8> %x, %y
  ret <2 x i8> %r
}
define <8 x float> @f8(<8 x float> %x, <8 x float> %y) {
  %r = fsub <8 x float> %x, %y
  ret <8 x float> %r
}
define <3 x i32> @i3(<3 x i32> %x) {
  %r = mul <3 x i32> %x, <i32 3, i32 5, i32 7>
  ret <3 x i32> %r
}
define <4 x i8> @q(<4 x i8> %x) {
  %r = mul <4 x i8> %x, <i8 3, i8 5, i8 7, i8 11>
  ret <4 x i8> %r
}
define i64 @late(<4 x i64> %a, <4 x i64> %b, <4 x i64> %c, <4 x i64> %d, <4 x i64> %e) {
  %x = extractelement <4 x i64> %e, i64 3
  %y = extractelement <4 x i64> %d, i64 1
  %z = extractelement <4 x i64> %a, i64 0
  %s = add i64 %x, %y
  %t = mul i64 %s, 3
  %u = add i64 %t, %z
  ret i64 %u
}
