; NEON's pairwise sum of 64-bit vectors of two lanes (vpadd_u32, as
; simd-adler32 uses): the sum of a's lanes, then of b's.
target triple = "arm64-apple-macosx14.0.0"
declare <2 x i32> @llvm.aarch64.neon.addp.v2i32(<2 x i32>, <2 x i32>)
define void @p(ptr %out, ptr %a, ptr %b) {
  %x = load <2 x i32>, ptr %a
  %y = load <2 x i32>, ptr %b
  %r = call <2 x i32> @llvm.aarch64.neon.addp.v2i32(<2 x i32> %x, <2 x i32> %y)
  store <2 x i32> %r, ptr %out
  ret void
}
