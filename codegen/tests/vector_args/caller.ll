; Calls of callee.ll's functions, with vectors loaded from memory.
target triple = "arm64-apple-macosx14.0.0"
declare <4 x i64> @w(<4 x i64>, <4 x i64>)
declare <3 x float> @t(<3 x float>, float)
declare <2 x i8> @b(<2 x i8>, <2 x i8>)
declare <8 x float> @f8(<8 x float>, <8 x float>)
declare <3 x i32> @i3(<3 x i32>)
declare <4 x i8> @q(<4 x i8>)
declare i64 @late(<4 x i64>, <4 x i64>, <4 x i64>, <4 x i64>, <4 x i64>)
define void @cw(ptr %o, ptr %a, ptr %b) {
  %x = load <4 x i64>, ptr %a
  %y = load <4 x i64>, ptr %b
  %r = call <4 x i64> @w(<4 x i64> %x, <4 x i64> %y)
  store <4 x i64> %r, ptr %o
  ret void
}
define void @ct(ptr %o, ptr %a, float %k) {
  %x = load <3 x float>, ptr %a
  %r = call <3 x float> @t(<3 x float> %x, float %k)
  store <3 x float> %r, ptr %o
  ret void
}
define void @cb(ptr %o, ptr %a, ptr %b) {
  %x = load <2 x i8>, ptr %a
  %y = load <2 x i8>, ptr %b
  %r = call <2 x i8> @b(<2 x i8> %x, <2 x i8> %y)
  store <2 x i8> %r, ptr %o
  ret void
}
define void @cf8(ptr %o, ptr %a, ptr %b) {
  %x = load <8 x float>, ptr %a
  %y = load <8 x float>, ptr %b
  %r = call <8 x float> @f8(<8 x float> %x, <8 x float> %y)
  store <8 x float> %r, ptr %o
  ret void
}
define void @ci3(ptr %o, ptr %a) {
  %x = load <3 x i32>, ptr %a
  %r = call <3 x i32> @i3(<3 x i32> %x)
  store <3 x i32> %r, ptr %o
  ret void
}
define void @cq(ptr %o, ptr %a) {
  %x = load <4 x i8>, ptr %a
  %r = call <4 x i8> @q(<4 x i8> %x)
  store <4 x i8> %r, ptr %o
  ret void
}
define i64 @clate(ptr %a) {
  %x = load <4 x i64>, ptr %a
  %y = add <4 x i64> %x, %x
  %r = call i64 @late(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x, <4 x i64> %y, <4 x i64> %y)
  ret i64 %r
}
