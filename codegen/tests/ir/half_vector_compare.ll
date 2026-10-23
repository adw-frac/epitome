; Comparisons of vectors of halves (as of their single-precision values),
; their masks extended to bytes.
target triple = "arm64-apple-macosx14.0.0"
define void @f(ptr %o, ptr %a, ptr %b) {
  %x = load <8 x half>, ptr %a
  %y = load <8 x half>, ptr %b
  %c = fcmp olt <8 x half> %x, %y
  %z = zext <8 x i1> %c to <8 x i8>
  store <8 x i8> %z, ptr %o
  ret void
}
