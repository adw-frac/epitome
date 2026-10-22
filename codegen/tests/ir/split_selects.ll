; Vectors split across registers or into lanes, chosen between by a
; splat of one boolean (image-webp's predictors), and used in a block
; placed before the loop that makes them (rand_distr's).
target triple = "arm64-apple-macosx14.0.0"

define void @pick(ptr %o, ptr %a, ptr %b, i1 %c) {
  %x = load <4 x i8>, ptr %a
  %y = load <4 x i8>, ptr %b
  %i = insertelement <4 x i1> poison, i1 %c, i64 0
  %m = shufflevector <4 x i1> %i, <4 x i1> poison, <4 x i32> zeroinitializer
  %r = select <4 x i1> %m, <4 x i8> %x, <4 x i8> %y
  store <4 x i8> %r, ptr %o
  ret void
}

define double @late(i32 %n) {
start:
  br label %loop

done:
  %e0 = extractelement <8 x double> %next, i64 0
  %e7 = extractelement <8 x double> %next, i64 7
  %s = fadd double %e0, %e7
  ret double %s

loop:
  %v = phi <8 x double> [ <double 1.0, double 2.0, double 3.0, double 4.0, double 5.0, double 6.0, double 7.0, double 8.0>, %start ], [ %next, %loop ]
  %k = phi i32 [ 0, %start ], [ %k1, %loop ]
  %w = fmul <8 x double> %v, splat (double 1.5)
  %c = fcmp olt <8 x double> %w, splat (double 20.0)
  %next = select <8 x i1> %c, <8 x double> %w, <8 x double> %v
  %k1 = add i32 %k, 1
  %more = icmp ult i32 %k1, %n
  br i1 %more, label %loop, label %done
}
