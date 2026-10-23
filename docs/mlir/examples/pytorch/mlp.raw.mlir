module {
  func.func @mlp(%arg0: !torch.vtensor<[1,4],f32>) -> !torch.vtensor<[1,2],f32> {
    %0 = torch.vtensor.literal(dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>) : !torch.vtensor<[8,4],f32>
    %int1 = torch.constant.int 1
    %int0 = torch.constant.int 0
    %1 = torch.prim.ListConstruct %int1, %int0 : (!torch.int, !torch.int) -> !torch.list<int>
    %2 = torch.aten.permute %0, %1 : !torch.vtensor<[8,4],f32>, !torch.list<int> -> !torch.vtensor<[4,8],f32>
    %3 = torch.aten.mm %arg0, %2 : !torch.vtensor<[1,4],f32>, !torch.vtensor<[4,8],f32> -> !torch.vtensor<[1,8],f32>
    %int1_0 = torch.constant.int 1
    %4 = torch.aten.mul.Scalar %3, %int1_0 : !torch.vtensor<[1,8],f32>, !torch.int -> !torch.vtensor<[1,8],f32>
    %5 = torch.vtensor.literal(dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>) : !torch.vtensor<[8],f32>
    %int1_1 = torch.constant.int 1
    %int8 = torch.constant.int 8
    %6 = torch.prim.ListConstruct %int1_1, %int8 : (!torch.int, !torch.int) -> !torch.list<int>
    %false = torch.constant.bool false
    %7 = torch.aten.expand %5, %6, %false : !torch.vtensor<[8],f32>, !torch.list<int>, !torch.bool -> !torch.vtensor<[1,8],f32>
    %int1_2 = torch.constant.int 1
    %8 = torch.aten.mul.Scalar %7, %int1_2 : !torch.vtensor<[1,8],f32>, !torch.int -> !torch.vtensor<[1,8],f32>
    %int1_3 = torch.constant.int 1
    %9 = torch.aten.add.Tensor %4, %8, %int1_3 : !torch.vtensor<[1,8],f32>, !torch.vtensor<[1,8],f32>, !torch.int -> !torch.vtensor<[1,8],f32>
    %10 = torch.aten.relu %9 : !torch.vtensor<[1,8],f32> -> !torch.vtensor<[1,8],f32>
    %11 = torch.vtensor.literal(dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>) : !torch.vtensor<[2,8],f32>
    %int1_4 = torch.constant.int 1
    %int0_5 = torch.constant.int 0
    %12 = torch.prim.ListConstruct %int1_4, %int0_5 : (!torch.int, !torch.int) -> !torch.list<int>
    %13 = torch.aten.permute %11, %12 : !torch.vtensor<[2,8],f32>, !torch.list<int> -> !torch.vtensor<[8,2],f32>
    %14 = torch.aten.mm %10, %13 : !torch.vtensor<[1,8],f32>, !torch.vtensor<[8,2],f32> -> !torch.vtensor<[1,2],f32>
    %int1_6 = torch.constant.int 1
    %15 = torch.aten.mul.Scalar %14, %int1_6 : !torch.vtensor<[1,2],f32>, !torch.int -> !torch.vtensor<[1,2],f32>
    %16 = torch.vtensor.literal(dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>) : !torch.vtensor<[2],f32>
    %int1_7 = torch.constant.int 1
    %int2 = torch.constant.int 2
    %17 = torch.prim.ListConstruct %int1_7, %int2 : (!torch.int, !torch.int) -> !torch.list<int>
    %false_8 = torch.constant.bool false
    %18 = torch.aten.expand %16, %17, %false_8 : !torch.vtensor<[2],f32>, !torch.list<int>, !torch.bool -> !torch.vtensor<[1,2],f32>
    %int1_9 = torch.constant.int 1
    %19 = torch.aten.mul.Scalar %18, %int1_9 : !torch.vtensor<[1,2],f32>, !torch.int -> !torch.vtensor<[1,2],f32>
    %int1_10 = torch.constant.int 1
    %20 = torch.aten.add.Tensor %15, %19, %int1_10 : !torch.vtensor<[1,2],f32>, !torch.vtensor<[1,2],f32>, !torch.int -> !torch.vtensor<[1,2],f32>
    return %20 : !torch.vtensor<[1,2],f32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE"
    }
  }
#-}
