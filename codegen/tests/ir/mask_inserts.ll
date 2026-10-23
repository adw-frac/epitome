; Masks put together lane by lane (insertelement of booleans), then
; extended: as wide as the lanes they were built in.
target triple = "arm64-apple-macosx14.0.0"
define void @f(ptr %o, ptr %a) {
  %m0 = insertelement <8 x i1> zeroinitializer, i1 true, i64 0
  %b = load i8, ptr %a
  %c = trunc i8 %b to i1
  %m1 = insertelement <8 x i1> %m0, i1 %c, i64 2
  %m2 = insertelement <8 x i1> %m1, i1 true, i64 5
  %z = zext <8 x i1> %m2 to <8 x i8>
  store <8 x i8> %z, ptr %o
  ret void
}
