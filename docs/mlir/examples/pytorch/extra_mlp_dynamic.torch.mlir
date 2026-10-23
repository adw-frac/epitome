module {
  func.func @mlp_dyn(%arg0: !torch.vtensor<[?,4],f32>) -> !torch.vtensor<[?,2],f32> {
    %int2 = torch.constant.int 2
    %0 = torch.vtensor.literal(dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>) : !torch.vtensor<[2],f32>
    %1 = torch.vtensor.literal(dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>) : !torch.vtensor<[2,8],f32>
    %int8 = torch.constant.int 8
    %2 = torch.vtensor.literal(dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>) : !torch.vtensor<[8],f32>
    %int1 = torch.constant.int 1
    %3 = torch.vtensor.literal(dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>) : !torch.vtensor<[8,4],f32>
    %int0 = torch.constant.int 0
    %4 = torch.symbolic_int "s77" {min_val = 0, max_val = 9223372036854775807} : !torch.int
    torch.bind_symbolic_shape %arg0, [%4], affine_map<()[s0] -> (s0, 4)> : !torch.vtensor<[?,4],f32>
    %5 = torch.aten.size.int %arg0, %int0 : !torch.vtensor<[?,4],f32>, !torch.int -> !torch.int
    %6 = torch.prim.ListConstruct %int1, %int0 : (!torch.int, !torch.int) -> !torch.list<int>
    %7 = torch.aten.permute %3, %6 : !torch.vtensor<[8,4],f32>, !torch.list<int> -> !torch.vtensor<[4,8],f32>
    %8 = torch.aten.mm %arg0, %7 : !torch.vtensor<[?,4],f32>, !torch.vtensor<[4,8],f32> -> !torch.vtensor<[?,8],f32>
    torch.bind_symbolic_shape %8, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
    %9 = torch.aten.mul.Scalar %8, %int1 : !torch.vtensor<[?,8],f32>, !torch.int -> !torch.vtensor<[?,8],f32>
    torch.bind_symbolic_shape %9, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
    %10 = torch.prim.ListConstruct %5, %int8 : (!torch.int, !torch.int) -> !torch.list<int>
    %11 = torch.aten.broadcast_to %2, %10 : !torch.vtensor<[8],f32>, !torch.list<int> -> !torch.vtensor<[?,8],f32>
    torch.bind_symbolic_shape %11, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
    %12 = torch.aten.mul.Scalar %11, %int1 : !torch.vtensor<[?,8],f32>, !torch.int -> !torch.vtensor<[?,8],f32>
    torch.bind_symbolic_shape %12, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
    %13 = torch.aten.add.Tensor %9, %12, %int1 : !torch.vtensor<[?,8],f32>, !torch.vtensor<[?,8],f32>, !torch.int -> !torch.vtensor<[?,8],f32>
    torch.bind_symbolic_shape %13, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
    %14 = torch.aten.relu %13 : !torch.vtensor<[?,8],f32> -> !torch.vtensor<[?,8],f32>
    torch.bind_symbolic_shape %14, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
    %15 = torch.prim.ListConstruct %int1, %int0 : (!torch.int, !torch.int) -> !torch.list<int>
    %16 = torch.aten.permute %1, %15 : !torch.vtensor<[2,8],f32>, !torch.list<int> -> !torch.vtensor<[8,2],f32>
    %17 = torch.aten.mm %14, %16 : !torch.vtensor<[?,8],f32>, !torch.vtensor<[8,2],f32> -> !torch.vtensor<[?,2],f32>
    torch.bind_symbolic_shape %17, [%4], affine_map<()[s0] -> (s0, 2)> : !torch.vtensor<[?,2],f32>
    %18 = torch.aten.mul.Scalar %17, %int1 : !torch.vtensor<[?,2],f32>, !torch.int -> !torch.vtensor<[?,2],f32>
    torch.bind_symbolic_shape %18, [%4], affine_map<()[s0] -> (s0, 2)> : !torch.vtensor<[?,2],f32>
    %19 = torch.prim.ListConstruct %5, %int2 : (!torch.int, !torch.int) -> !torch.list<int>
    %20 = torch.aten.broadcast_to %0, %19 : !torch.vtensor<[2],f32>, !torch.list<int> -> !torch.vtensor<[?,2],f32>
    torch.bind_symbolic_shape %20, [%4], affine_map<()[s0] -> (s0, 2)> : !torch.vtensor<[?,2],f32>
    %21 = torch.aten.mul.Scalar %20, %int1 : !torch.vtensor<[?,2],f32>, !torch.int -> !torch.vtensor<[?,2],f32>
    torch.bind_symbolic_shape %21, [%4], affine_map<()[s0] -> (s0, 2)> : !torch.vtensor<[?,2],f32>
    %22 = torch.aten.add.Tensor %18, %21, %int1 : !torch.vtensor<[?,2],f32>, !torch.vtensor<[?,2],f32>, !torch.int -> !torch.vtensor<[?,2],f32>
    torch.bind_symbolic_shape %22, [%4], affine_map<()[s0] -> (s0, 2)> : !torch.vtensor<[?,2],f32>
    return %22 : !torch.vtensor<[?,2],f32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E"
    }
  }
#-}
