; The high and low halves of 128-bit products, by way of 256 bits (as
; Rust's u128 widening multiplications are; fastrand's ranges).
target triple = "arm64-apple-macosx14.0.0"

define void @products(ptr %o, ptr %a, ptr %b) {
  %x = load i128, ptr %a, align 8
  %y = load i128, ptr %b, align 8
  %xw = zext i128 %x to i256
  %yw = zext i128 %y to i256
  %p = mul nuw i256 %xw, %yw
  %h = lshr i256 %p, 128
  %hi = trunc nuw i256 %h to i128
  %lo = trunc i256 %p to i128
  store i128 %hi, ptr %o, align 8
  %o2 = getelementptr i8, ptr %o, i64 16
  store i128 %lo, ptr %o2, align 8
  ret void
}
