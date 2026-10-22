; A vector of 128-bit integers carried round a loop by a phi (as
; num-rational's Ratio<i128>::from_f32 carries its convergents).
target triple = "arm64-apple-macosx14.0.0"

define void @steps(ptr %o, i64 %k, i32 %n) {
start:
  %kw = zext i64 %k to i128
  br label %loop

loop:
  %v = phi <2 x i128> [ <i128 0, i128 1>, %start ], [ %next, %loop ]
  %i = phi i32 [ 0, %start ], [ %i1, %loop ]
  %a = extractelement <2 x i128> %v, i64 0
  %b = extractelement <2 x i128> %v, i64 1
  %bk = mul i128 %b, %kw
  %c = add i128 %a, %bk
  %w = insertelement <2 x i128> poison, i128 %b, i64 0
  %next = insertelement <2 x i128> %w, i128 %c, i64 1
  %i1 = add i32 %i, 1
  %more = icmp ult i32 %i1, %n
  br i1 %more, label %loop, label %done

done:
  store <2 x i128> %next, ptr %o, align 16
  ret void
}
