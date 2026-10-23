"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32>) -> !torch.vtensor<[2,4],f32>, sym_name = "qmatmul"}> ({
  ^bb0(%arg0: !torch.vtensor<[2,3],f32>, %arg1: !torch.vtensor<[3,4],f32>):
    %0 = "torch.constant.none"() : () -> !torch.none
    %1 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %2 = "torch.constant.float"() <{value = 1.000000e-01 : f64}> : () -> !torch.float
    %3 = "torch.constant.float"() <{value = 5.000000e-02 : f64}> : () -> !torch.float
    %4 = "torch.constant.int"() <{value = 3 : i64}> : () -> !torch.int
    %5 = "torch.constant.int"() <{value = -128 : i64}> : () -> !torch.int
    %6 = "torch.constant.int"() <{value = 127 : i64}> : () -> !torch.int
    %7 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %8 = "torch.quantized_decomposed.quantize_per_tensor"(%arg0, %3, %4, %5, %6, %7) : (!torch.vtensor<[2,3],f32>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int) -> !torch.vtensor<[2,3],si8>
    %9 = "torch.quantized_decomposed.quantize_per_tensor"(%arg1, %2, %1, %5, %6, %7) : (!torch.vtensor<[3,4],f32>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int) -> !torch.vtensor<[3,4],si8>
    %10 = "torch.quantized_decomposed.dequantize_per_tensor"(%8, %3, %4, %5, %6, %7, %0) : (!torch.vtensor<[2,3],si8>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int, !torch.none) -> !torch.vtensor<[2,3],f32>
    %11 = "torch.quantized_decomposed.dequantize_per_tensor"(%9, %2, %1, %5, %6, %7, %0) : (!torch.vtensor<[3,4],si8>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int, !torch.none) -> !torch.vtensor<[3,4],f32>
    %12 = "torch.aten.mm"(%10, %11) : (!torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32>) -> !torch.vtensor<[2,4],f32>
    "func.return"(%12) : (!torch.vtensor<[2,4],f32>) -> ()
  }) : () -> ()
}) : () -> ()

