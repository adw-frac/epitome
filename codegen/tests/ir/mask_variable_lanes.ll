; Lanes of masks chosen by a value (as the loop vectoriser's "first
; active lane" makes): taken out, and put in.
target triple = "arm64-apple-macosx14.0.0"
define i8 @get(ptr %p, ptr %q, i64 %k) {
  %a = load <4 x i32>, ptr %p
  %b = load <4 x i32>, ptr %q
  %m = icmp slt <4 x i32> %a, %b
  %l = extractelement <4 x i1> %m, i64 %k
  %r = zext i1 %l to i8
  ret i8 %r
}
define void @set(ptr %o, ptr %p, ptr %q, i64 %k, i1 %v) {
  %a = load <4 x i32>, ptr %p
  %b = load <4 x i32>, ptr %q
  %m = icmp slt <4 x i32> %a, %b
  %n = insertelement <4 x i1> %m, i1 %v, i64 %k
  %s = select <4 x i1> %n, <4 x i32> %a, <4 x i32> %b
  store <4 x i32> %s, ptr %o
  ret void
}
