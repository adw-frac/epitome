; Byte swaps of integers between 64 and 128 bits (byteorder's u128 at odd
; widths): loaded as bytes, swapped, stored.
target triple = "arm64-apple-macosx14.0.0"

define void @swaps(ptr %o, ptr %a) {
  %x = load i80, ptr %a, align 1
  %y = call i80 @llvm.bswap.i80(i80 %x)
  store i80 %y, ptr %o, align 1
  %pa = getelementptr i8, ptr %a, i64 16
  %u = load i96, ptr %pa, align 1
  %v = call i96 @llvm.bswap.i96(i96 %u)
  %po = getelementptr i8, ptr %o, i64 16
  store i96 %v, ptr %po, align 1
  %pa2 = getelementptr i8, ptr %a, i64 32
  %w = load i128, ptr %pa2, align 1
  %z = call i128 @llvm.bswap.i128(i128 %w)
  %po2 = getelementptr i8, ptr %o, i64 32
  store i128 %z, ptr %po2, align 1
  ret void
}

declare i80 @llvm.bswap.i80(i80)
declare i96 @llvm.bswap.i96(i96)
declare i128 @llvm.bswap.i128(i128)
