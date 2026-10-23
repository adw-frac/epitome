; Lanes of masks taken as narrow integers (glam tests two lanes at once):
; bitcast <4 x i1> to <2 x i2>, its lanes.
target triple = "arm64-apple-macosx14.0.0"
define void @f(ptr %o, ptr %p, ptr %q) {
  %a = load <4 x i32>, ptr %p
  %b = load <4 x i32>, ptr %q
  %m = icmp slt <4 x i32> %a, %b
  %c = bitcast <4 x i1> %m to <2 x i2>
  %x = extractelement <2 x i2> %c, i64 0
  %y = extractelement <2 x i2> %c, i64 1
  %xx = zext i2 %x to i8
  %yy = zext i2 %y to i8
  store i8 %xx, ptr %o
  %o1 = getelementptr i8, ptr %o, i64 1
  store i8 %yy, ptr %o1
  ret void
}
