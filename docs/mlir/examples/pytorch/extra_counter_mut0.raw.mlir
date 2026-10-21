module {
  func.func @counter(%arg0: !torch.vtensor<[3],f32>) -> (!torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>) {
    %0 = torch.vtensor.literal(dense<0.000000e+00> : tensor<1xf32>) : !torch.vtensor<[1],f32>
    %int1 = torch.constant.int 1
    %int1_0 = torch.constant.int 1
    %1 = torch.aten.add.Scalar %0, %int1, %int1_0 : !torch.vtensor<[1],f32>, !torch.int, !torch.int -> !torch.vtensor<[1],f32>
    %2 = torch.aten.mul.Tensor %arg0, %1 : !torch.vtensor<[3],f32>, !torch.vtensor<[1],f32> -> !torch.vtensor<[3],f32>
    return %1, %2 : !torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>
  }
}
