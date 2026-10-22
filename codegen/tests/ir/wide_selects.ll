; Selects by one boolean of vectors split across registers (glam's
; DVec4 and friends): <4 x double>, <8 x float>, and <3 x double>, whose
; parts are scalars.
target triple = "arm64-apple-macosx14.0.0"

define void @pick(ptr %o, ptr %a, ptr %b, i32 %k) {
  %x = load <4 x double>, ptr %a
  %y = load <4 x double>, ptr %b
  %c = icmp sgt i32 %k, 3
  %r = select i1 %c, <4 x double> %x, <4 x double> %y
  %z = fadd <4 x double> %r, <double 1.0, double 2.0, double 3.0, double 4.0>
  store <4 x double> %z, ptr %o
  %pa = getelementptr i8, ptr %a, i64 32
  %pb = getelementptr i8, ptr %b, i64 32
  %u = load <8 x float>, ptr %pa
  %v = load <8 x float>, ptr %pb
  %d = icmp eq i32 %k, 5
  %s = select i1 %d, <8 x float> %u, <8 x float> %v
  %po = getelementptr i8, ptr %o, i64 32
  store <8 x float> %s, ptr %po
  %pa2 = getelementptr i8, ptr %a, i64 64
  %pb2 = getelementptr i8, ptr %b, i64 64
  %e = load <3 x double>, ptr %pa2
  %f = load <3 x double>, ptr %pb2
  %g = icmp ult i32 %k, 2
  %h = select i1 %g, <3 x double> %e, <3 x double> %f
  %po2 = getelementptr i8, ptr %o, i64 64
  store <3 x double> %h, ptr %po2
  ret void
}
