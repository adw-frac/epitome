module {
  func.func @matmul_bias(%arg0: !torch.vtensor<[2,3],f32>, %arg1: !torch.vtensor<[3,4],f32>, %arg2: !torch.vtensor<[4],f32>) -> !torch.vtensor<[2,4],f32> {
    %0 = torch.aten.mm %arg0, %arg1 : !torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32> -> !torch.vtensor<[2,4],f32>
    %int1 = torch.constant.int 1
    %1 = torch.aten.add.Tensor %0, %arg2, %int1 : !torch.vtensor<[2,4],f32>, !torch.vtensor<[4],f32>, !torch.int -> !torch.vtensor<[2,4],f32>
    return %1 : !torch.vtensor<[2,4],f32>
  }
}
