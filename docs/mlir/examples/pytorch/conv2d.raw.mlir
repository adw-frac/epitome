module {
  func.func @conv2d(%arg0: !torch.vtensor<[1,1,5,5],f32>) -> !torch.vtensor<[1,2,5,5],f32> {
    %0 = torch.vtensor.literal(dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>) : !torch.vtensor<[2,1,3,3],f32>
    %1 = torch.vtensor.literal(dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>) : !torch.vtensor<[2],f32>
    %int1 = torch.constant.int 1
    %int1_0 = torch.constant.int 1
    %2 = torch.prim.ListConstruct %int1, %int1_0 : (!torch.int, !torch.int) -> !torch.list<int>
    %int1_1 = torch.constant.int 1
    %int1_2 = torch.constant.int 1
    %3 = torch.prim.ListConstruct %int1_1, %int1_2 : (!torch.int, !torch.int) -> !torch.list<int>
    %int1_3 = torch.constant.int 1
    %int1_4 = torch.constant.int 1
    %4 = torch.prim.ListConstruct %int1_3, %int1_4 : (!torch.int, !torch.int) -> !torch.list<int>
    %false = torch.constant.bool false
    %int0 = torch.constant.int 0
    %int0_5 = torch.constant.int 0
    %5 = torch.prim.ListConstruct %int0, %int0_5 : (!torch.int, !torch.int) -> !torch.list<int>
    %int1_6 = torch.constant.int 1
    %6 = torch.aten.convolution %arg0, %0, %1, %2, %3, %4, %false, %5, %int1_6 : !torch.vtensor<[1,1,5,5],f32>, !torch.vtensor<[2,1,3,3],f32>, !torch.vtensor<[2],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.bool, !torch.list<int>, !torch.int -> !torch.vtensor<[1,2,5,5],f32>
    return %6 : !torch.vtensor<[1,2,5,5],f32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}
