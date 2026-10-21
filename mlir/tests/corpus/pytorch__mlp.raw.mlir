"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[1,4],f32>) -> !torch.vtensor<[1,2],f32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: !torch.vtensor<[1,4],f32>):
    %0 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> !torch.vtensor<[8,4],f32>
    %1 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %2 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %3 = "torch.prim.ListConstruct"(%1, %2) : (!torch.int, !torch.int) -> !torch.list<int>
    %4 = "torch.aten.permute"(%0, %3) : (!torch.vtensor<[8,4],f32>, !torch.list<int>) -> !torch.vtensor<[4,8],f32>
    %5 = "torch.aten.mm"(%arg0, %4) : (!torch.vtensor<[1,4],f32>, !torch.vtensor<[4,8],f32>) -> !torch.vtensor<[1,8],f32>
    %6 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %7 = "torch.aten.mul.Scalar"(%5, %6) : (!torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32>
    %8 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> !torch.vtensor<[8],f32>
    %9 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %10 = "torch.constant.int"() <{value = 8 : i64}> : () -> !torch.int
    %11 = "torch.prim.ListConstruct"(%9, %10) : (!torch.int, !torch.int) -> !torch.list<int>
    %12 = "torch.constant.bool"() <{value = false}> : () -> !torch.bool
    %13 = "torch.aten.expand"(%8, %11, %12) : (!torch.vtensor<[8],f32>, !torch.list<int>, !torch.bool) -> !torch.vtensor<[1,8],f32>
    %14 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %15 = "torch.aten.mul.Scalar"(%13, %14) : (!torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32>
    %16 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %17 = "torch.aten.add.Tensor"(%7, %15, %16) : (!torch.vtensor<[1,8],f32>, !torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32>
    %18 = "torch.aten.relu"(%17) : (!torch.vtensor<[1,8],f32>) -> !torch.vtensor<[1,8],f32>
    %19 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> !torch.vtensor<[2,8],f32>
    %20 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %21 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %22 = "torch.prim.ListConstruct"(%20, %21) : (!torch.int, !torch.int) -> !torch.list<int>
    %23 = "torch.aten.permute"(%19, %22) : (!torch.vtensor<[2,8],f32>, !torch.list<int>) -> !torch.vtensor<[8,2],f32>
    %24 = "torch.aten.mm"(%18, %23) : (!torch.vtensor<[1,8],f32>, !torch.vtensor<[8,2],f32>) -> !torch.vtensor<[1,2],f32>
    %25 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %26 = "torch.aten.mul.Scalar"(%24, %25) : (!torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32>
    %27 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32>
    %28 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %29 = "torch.constant.int"() <{value = 2 : i64}> : () -> !torch.int
    %30 = "torch.prim.ListConstruct"(%28, %29) : (!torch.int, !torch.int) -> !torch.list<int>
    %31 = "torch.constant.bool"() <{value = false}> : () -> !torch.bool
    %32 = "torch.aten.expand"(%27, %30, %31) : (!torch.vtensor<[2],f32>, !torch.list<int>, !torch.bool) -> !torch.vtensor<[1,2],f32>
    %33 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %34 = "torch.aten.mul.Scalar"(%32, %33) : (!torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32>
    %35 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %36 = "torch.aten.add.Tensor"(%26, %34, %35) : (!torch.vtensor<[1,2],f32>, !torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32>
    "func.return"(%36) : (!torch.vtensor<[1,2],f32>) -> ()
  }) : () -> ()
}) : () -> ()

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

