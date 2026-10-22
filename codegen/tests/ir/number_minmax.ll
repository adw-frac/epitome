; llvm.minimumnum and llvm.maximumnum (Rust's f32::min and max): a number
; over any NaN, quiet or signalling; -0 below +0; of floats, doubles,
; halves and vectors.
target triple = "arm64-apple-macosx14.0.0"
declare float @llvm.minimumnum.f32(float, float)
declare float @llvm.maximumnum.f32(float, float)
declare double @llvm.minimumnum.f64(double, double)
declare half @llvm.maximumnum.f16(half, half)
declare <4 x float> @llvm.maximumnum.v4f32(<4 x float>, <4 x float>)
define i32 @min32(i32 %a, i32 %b) {
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = call float @llvm.minimumnum.f32(float %x, float %y)
  %i = bitcast float %r to i32
  ret i32 %i
}
define i32 @max32(i32 %a, i32 %b) {
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = call float @llvm.maximumnum.f32(float %x, float %y)
  %i = bitcast float %r to i32
  ret i32 %i
}
define i64 @min64(i64 %a, i64 %b) {
  %x = bitcast i64 %a to double
  %y = bitcast i64 %b to double
  %r = call double @llvm.minimumnum.f64(double %x, double %y)
  %i = bitcast double %r to i64
  ret i64 %i
}
define i16 @max16(i16 %a, i16 %b) {
  %x = bitcast i16 %a to half
  %y = bitcast i16 %b to half
  %r = call half @llvm.maximumnum.f16(half %x, half %y)
  %i = bitcast half %r to i16
  ret i16 %i
}
define void @max4(ptr %out, ptr %a, ptr %b) {
  %x = load <4 x float>, ptr %a
  %y = load <4 x float>, ptr %b
  %r = call <4 x float> @llvm.maximumnum.v4f32(<4 x float> %x, <4 x float> %y)
  store <4 x float> %r, ptr %out
  ret void
}
