; Lanes of a mask of bytes compared, each guarding a store (as the loop
; vectoriser makes predicated stores): `@` bytes made 0xff.
target triple = "arm64-apple-macosx14.0.0"
define void @f(ptr %p) {
entry:
  %v = load <8 x i8>, ptr %p, align 1
  %m = icmp eq <8 x i8> %v, splat (i8 64)
  br label %l0
l0:
  %c0 = extractelement <8 x i1> %m, i64 0
  br i1 %c0, label %s0, label %l1
s0:
  %q0 = getelementptr i8, ptr %p, i64 0
  store i8 -1, ptr %q0, align 1
  br label %l1
l1:
  %c1 = extractelement <8 x i1> %m, i64 1
  br i1 %c1, label %s1, label %l2
s1:
  %q1 = getelementptr i8, ptr %p, i64 1
  store i8 -1, ptr %q1, align 1
  br label %l2
l2:
  %c2 = extractelement <8 x i1> %m, i64 2
  br i1 %c2, label %s2, label %l3
s2:
  %q2 = getelementptr i8, ptr %p, i64 2
  store i8 -1, ptr %q2, align 1
  br label %l3
l3:
  %c3 = extractelement <8 x i1> %m, i64 3
  br i1 %c3, label %s3, label %l4
s3:
  %q3 = getelementptr i8, ptr %p, i64 3
  store i8 -1, ptr %q3, align 1
  br label %l4
l4:
  %c4 = extractelement <8 x i1> %m, i64 4
  br i1 %c4, label %s4, label %l5
s4:
  %q4 = getelementptr i8, ptr %p, i64 4
  store i8 -1, ptr %q4, align 1
  br label %l5
l5:
  %c5 = extractelement <8 x i1> %m, i64 5
  br i1 %c5, label %s5, label %l6
s5:
  %q5 = getelementptr i8, ptr %p, i64 5
  store i8 -1, ptr %q5, align 1
  br label %l6
l6:
  %c6 = extractelement <8 x i1> %m, i64 6
  br i1 %c6, label %s6, label %l7
s6:
  %q6 = getelementptr i8, ptr %p, i64 6
  store i8 -1, ptr %q6, align 1
  br label %l7
l7:
  %c7 = extractelement <8 x i1> %m, i64 7
  br i1 %c7, label %s7, label %done
s7:
  %q7 = getelementptr i8, ptr %p, i64 7
  store i8 -1, ptr %q7, align 1
  br label %done
done:
  ret void
}
