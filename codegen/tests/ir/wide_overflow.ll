; 128-bit multiplications that check for overflow, their { i128, i1 }
; results carried round a loop by a phi (num-integer's roots).
target triple = "arm64-apple-macosx14.0.0"

define i32 @powers(ptr %o, i64 %base) {
start:
  %b = zext i64 %base to i128
  %first = call { i128, i1 } @llvm.umul.with.overflow.i128(i128 %b, i128 1)
  br label %loop

loop:
  %acc = phi { i128, i1 } [ %first, %start ], [ %next, %loop ]
  %n = phi i32 [ 0, %start ], [ %n1, %loop ]
  %v = extractvalue { i128, i1 } %acc, 0
  %next = call { i128, i1 } @llvm.umul.with.overflow.i128(i128 %v, i128 %b)
  %over = extractvalue { i128, i1 } %next, 1
  %n1 = add i32 %n, 1
  br i1 %over, label %done, label %loop

done:
  store i128 %v, ptr %o, align 16
  ret i32 %n1
}

declare { i128, i1 } @llvm.umul.with.overflow.i128(i128, i128)
