; Shuffles of 64-bit vectors into 128-bit ones (rav1e's and image's
; broadcasts), and lanes of constant vectors taken by constants.
target triple = "arm64-apple-macosx14.0.0"

@tab = private constant <4 x i32> <i32 10, i32 20, i32 30, i32 40>

define void @widen(ptr %o, ptr %a, ptr %b, i16 %h) {
  %x = load <2 x i32>, ptr %a
  %y = load <2 x float>, ptr %b
  %s1 = shufflevector <2 x i32> %x, <2 x i32> poison, <4 x i32> <i32 1, i32 1, i32 0, i32 1>
  store <4 x i32> %s1, ptr %o
  %s2 = shufflevector <2 x float> %y, <2 x float> poison, <4 x i32> <i32 0, i32 0, i32 1, i32 1>
  %o2 = getelementptr i8, ptr %o, i64 16
  store <4 x float> %s2, ptr %o2
  %i = insertelement <4 x i16> poison, i16 %h, i64 0
  %s3 = shufflevector <4 x i16> %i, <4 x i16> poison, <8 x i32> zeroinitializer
  %o3 = getelementptr i8, ptr %o, i64 32
  store <8 x i16> %s3, ptr %o3
  %c = extractelement <4 x i32> <i32 7, i32 8, i32 9, i32 10>, i64 2
  %d = extractelement <4 x float> <float 1.5, float 2.5, float 3.5, float 4.5>, i64 3
  %di = fptosi float %d to i32
  %e = add i32 %c, %di
  %o4 = getelementptr i8, ptr %o, i64 48
  store i32 %e, ptr %o4
  ret void
}
