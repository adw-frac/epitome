; The high and low halves of 128-bit products, by way of 256 bits (as
; Rust's u128 widening multiplications are; fastrand's ranges), by
; values and constants, with their signs and high halves compared.
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
  ; By a constant, and the product's sign and high half compared (pxfm's).
  %q = mul nuw i256 %xw, 216630482969909649486417808747042701312
  %qh = lshr i256 %q, 128
  %qhi = trunc nuw i256 %qh to i128
  %o3 = getelementptr i8, ptr %o, i64 32
  store i128 %qhi, ptr %o3, align 8
  %pos = icmp sgt i256 %q, -1
  %zero = icmp eq i256 %qh, 0
  %all = icmp eq i256 %p, 0
  %f1 = zext i1 %pos to i8
  %f2 = zext i1 %zero to i8
  %f3 = zext i1 %all to i8
  %g2 = shl i8 %f2, 1
  %g3 = shl i8 %f3, 2
  %fl = or i8 %f1, %g2
  %fl2 = or i8 %fl, %g3
  %o4 = getelementptr i8, ptr %o, i64 48
  store i8 %fl2, ptr %o4, align 1
  ret void
}
