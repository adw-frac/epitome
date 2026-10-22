; Masks moved about by shuffles (with poison lanes), chosen between by a
; mask, and taken as bits; and <2 x float> halves joined. As glam and nom
; have them.
target triple = "arm64-apple-macosx14.0.0"

define i8 @halves(ptr %p) {
  %x = load <8 x double>, ptr %p
  %c = fcmp oeq <8 x double> %x, <double 2.0, double 4.0, double 6.0, double 8.0, double 10.0, double 12.0, double 14.0, double 16.0>
  %lo = shufflevector <8 x i1> %c, <8 x i1> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %hi = shufflevector <8 x i1> %c, <8 x i1> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %a = and <4 x i1> %lo, %hi
  %w = shufflevector <4 x i1> %a, <4 x i1> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 poison, i32 poison, i32 poison, i32 poison>
  %j = shufflevector <8 x i1> %w, <8 x i1> %c, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 12, i32 13, i32 14, i32 15>
  %b = bitcast <8 x i1> %j to i8
  ret i8 %b
}

define i1 @pair(ptr %p) {
  %x = load <2 x float>, ptr %p
  %c = fcmp olt <2 x float> %x, zeroinitializer
  %shift = shufflevector <2 x i1> %c, <2 x i1> poison, <2 x i32> <i32 1, i32 poison>
  %o = or <2 x i1> %c, %shift
  %r = extractelement <2 x i1> %o, i64 0
  ret i1 %r
}

define i16 @pick(ptr %a, ptr %b) {
  %x = load <16 x i8>, ptr %a
  %y = load <16 x i8>, ptr %b
  %c = icmp ult <16 x i8> %x, splat (i8 10)
  %d = icmp eq <16 x i8> %x, %y
  %e = icmp ugt <16 x i8> %y, splat (i8 200)
  %n = select <16 x i1> %c, <16 x i1> splat (i1 true), <16 x i1> %d
  %m = select <16 x i1> %e, <16 x i1> %n, <16 x i1> %c
  %r = bitcast <16 x i1> %m to i16
  ret i16 %r
}

define void @join(ptr %o, ptr %a, ptr %b) {
  %x = load <2 x float>, ptr %a
  %y = load <2 x float>, ptr %b
  %j = shufflevector <2 x float> %x, <2 x float> %y, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %k = fadd <4 x float> %j, <float 1.0, float 2.0, float 3.0, float 4.0>
  store <4 x float> %k, ptr %o
  ret void
}

