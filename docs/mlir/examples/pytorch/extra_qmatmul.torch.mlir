module {
  func.func @qmatmul(%arg0: !torch.vtensor<[2,3],f32>, %arg1: !torch.vtensor<[3,4],f32>) -> !torch.vtensor<[2,4],f32> {
    %none = torch.constant.none
    %int0 = torch.constant.int 0
    %float1.000000e-01 = torch.constant.float 1.000000e-01
    %float5.000000e-02 = torch.constant.float 5.000000e-02
    %int3 = torch.constant.int 3
    %int-128 = torch.constant.int -128
    %int127 = torch.constant.int 127
    %int1 = torch.constant.int 1
    %0 = torch.quantized_decomposed.quantize_per_tensor %arg0, %float5.000000e-02, %int3, %int-128, %int127, %int1 : !torch.vtensor<[2,3],f32>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int -> !torch.vtensor<[2,3],si8>
    %1 = torch.quantized_decomposed.quantize_per_tensor %arg1, %float1.000000e-01, %int0, %int-128, %int127, %int1 : !torch.vtensor<[3,4],f32>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int -> !torch.vtensor<[3,4],si8>
    %2 = torch.quantized_decomposed.dequantize_per_tensor %0, %float5.000000e-02, %int3, %int-128, %int127, %int1, %none : !torch.vtensor<[2,3],si8>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int, !torch.none -> !torch.vtensor<[2,3],f32>
    %3 = torch.quantized_decomposed.dequantize_per_tensor %1, %float1.000000e-01, %int0, %int-128, %int127, %int1, %none : !torch.vtensor<[3,4],si8>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int, !torch.none -> !torch.vtensor<[3,4],f32>
    %4 = torch.aten.mm %2, %3 : !torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32> -> !torch.vtensor<[2,4],f32>
    return %4 : !torch.vtensor<[2,4],f32>
  }
}
