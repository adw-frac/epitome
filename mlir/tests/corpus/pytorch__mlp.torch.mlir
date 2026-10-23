"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[1,4],f32>) -> !torch.vtensor<[1,2],f32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: !torch.vtensor<[1,4],f32>):
    %0 = "torch.constant.int"() <{value = 2 : i64}> : () -> !torch.int
    %1 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32>
    %2 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> !torch.vtensor<[2,8],f32>
    %3 = "torch.constant.int"() <{value = 8 : i64}> : () -> !torch.int
    %4 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> !torch.vtensor<[8],f32>
    %5 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> !torch.vtensor<[8,4],f32>
    %6 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %7 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %8 = "torch.prim.ListConstruct"(%6, %7) : (!torch.int, !torch.int) -> !torch.list<int>
    %9 = "torch.aten.permute"(%5, %8) : (!torch.vtensor<[8,4],f32>, !torch.list<int>) -> !torch.vtensor<[4,8],f32>
    %10 = "torch.aten.mm"(%arg0, %9) : (!torch.vtensor<[1,4],f32>, !torch.vtensor<[4,8],f32>) -> !torch.vtensor<[1,8],f32>
    %11 = "torch.aten.mul.Scalar"(%10, %6) : (!torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32>
    %12 = "torch.prim.ListConstruct"(%6, %3) : (!torch.int, !torch.int) -> !torch.list<int>
    %13 = "torch.aten.broadcast_to"(%4, %12) : (!torch.vtensor<[8],f32>, !torch.list<int>) -> !torch.vtensor<[1,8],f32>
    %14 = "torch.aten.mul.Scalar"(%13, %6) : (!torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32>
    %15 = "torch.aten.add.Tensor"(%11, %14, %6) : (!torch.vtensor<[1,8],f32>, !torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32>
    %16 = "torch.aten.relu"(%15) : (!torch.vtensor<[1,8],f32>) -> !torch.vtensor<[1,8],f32>
    %17 = "torch.prim.ListConstruct"(%6, %7) : (!torch.int, !torch.int) -> !torch.list<int>
    %18 = "torch.aten.permute"(%2, %17) : (!torch.vtensor<[2,8],f32>, !torch.list<int>) -> !torch.vtensor<[8,2],f32>
    %19 = "torch.aten.mm"(%16, %18) : (!torch.vtensor<[1,8],f32>, !torch.vtensor<[8,2],f32>) -> !torch.vtensor<[1,2],f32>
    %20 = "torch.aten.mul.Scalar"(%19, %6) : (!torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32>
    %21 = "torch.prim.ListConstruct"(%6, %0) : (!torch.int, !torch.int) -> !torch.list<int>
    %22 = "torch.aten.broadcast_to"(%1, %21) : (!torch.vtensor<[2],f32>, !torch.list<int>) -> !torch.vtensor<[1,2],f32>
    %23 = "torch.aten.mul.Scalar"(%22, %6) : (!torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32>
    %24 = "torch.aten.add.Tensor"(%20, %23, %6) : (!torch.vtensor<[1,2],f32>, !torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32>
    "func.return"(%24) : (!torch.vtensor<[1,2],f32>) -> ()
  }) : () -> ()
}) : () -> ()

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

