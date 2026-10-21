#loc2 = loc("./pytorch/mlp.torch.mlir":2:18)
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[1,4],f32>) -> !torch.vtensor<[1,2],f32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: !torch.vtensor<[1,4],f32> loc("./pytorch/mlp.torch.mlir":2:18)):
    %0 = "torch.constant.int"() <{value = 2 : i64}> : () -> !torch.int loc(#loc3)
    %1 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32> loc(#loc4)
    %2 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> !torch.vtensor<[2,8],f32> loc(#loc5)
    %3 = "torch.constant.int"() <{value = 8 : i64}> : () -> !torch.int loc(#loc6)
    %4 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> !torch.vtensor<[8],f32> loc(#loc7)
    %5 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> !torch.vtensor<[8,4],f32> loc(#loc8)
    %6 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc9)
    %7 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int loc(#loc10)
    %8 = "torch.prim.ListConstruct"(%6, %7) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc11)
    %9 = "torch.aten.permute"(%5, %8) : (!torch.vtensor<[8,4],f32>, !torch.list<int>) -> !torch.vtensor<[4,8],f32> loc(#loc12)
    %10 = "torch.aten.mm"(%arg0, %9) : (!torch.vtensor<[1,4],f32>, !torch.vtensor<[4,8],f32>) -> !torch.vtensor<[1,8],f32> loc(#loc13)
    %11 = "torch.aten.mul.Scalar"(%10, %6) : (!torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32> loc(#loc14)
    %12 = "torch.prim.ListConstruct"(%6, %3) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc15)
    %13 = "torch.aten.broadcast_to"(%4, %12) : (!torch.vtensor<[8],f32>, !torch.list<int>) -> !torch.vtensor<[1,8],f32> loc(#loc16)
    %14 = "torch.aten.mul.Scalar"(%13, %6) : (!torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32> loc(#loc17)
    %15 = "torch.aten.add.Tensor"(%11, %14, %6) : (!torch.vtensor<[1,8],f32>, !torch.vtensor<[1,8],f32>, !torch.int) -> !torch.vtensor<[1,8],f32> loc(#loc18)
    %16 = "torch.aten.relu"(%15) : (!torch.vtensor<[1,8],f32>) -> !torch.vtensor<[1,8],f32> loc(#loc19)
    %17 = "torch.prim.ListConstruct"(%6, %7) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc20)
    %18 = "torch.aten.permute"(%2, %17) : (!torch.vtensor<[2,8],f32>, !torch.list<int>) -> !torch.vtensor<[8,2],f32> loc(#loc21)
    %19 = "torch.aten.mm"(%16, %18) : (!torch.vtensor<[1,8],f32>, !torch.vtensor<[8,2],f32>) -> !torch.vtensor<[1,2],f32> loc(#loc22)
    %20 = "torch.aten.mul.Scalar"(%19, %6) : (!torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32> loc(#loc23)
    %21 = "torch.prim.ListConstruct"(%6, %0) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc24)
    %22 = "torch.aten.broadcast_to"(%1, %21) : (!torch.vtensor<[2],f32>, !torch.list<int>) -> !torch.vtensor<[1,2],f32> loc(#loc25)
    %23 = "torch.aten.mul.Scalar"(%22, %6) : (!torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32> loc(#loc26)
    %24 = "torch.aten.add.Tensor"(%20, %23, %6) : (!torch.vtensor<[1,2],f32>, !torch.vtensor<[1,2],f32>, !torch.int) -> !torch.vtensor<[1,2],f32> loc(#loc27)
    "func.return"(%24) : (!torch.vtensor<[1,2],f32>) -> () loc(#loc28)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/mlp.torch.mlir":1:1)
#loc1 = loc("./pytorch/mlp.torch.mlir":2:3)
#loc3 = loc("./pytorch/mlp.torch.mlir":3:13)
#loc4 = loc("./pytorch/mlp.torch.mlir":4:10)
#loc5 = loc("./pytorch/mlp.torch.mlir":5:10)
#loc6 = loc("./pytorch/mlp.torch.mlir":6:13)
#loc7 = loc("./pytorch/mlp.torch.mlir":7:10)
#loc8 = loc("./pytorch/mlp.torch.mlir":8:10)
#loc9 = loc("./pytorch/mlp.torch.mlir":9:13)
#loc10 = loc("./pytorch/mlp.torch.mlir":10:13)
#loc11 = loc("./pytorch/mlp.torch.mlir":11:10)
#loc12 = loc("./pytorch/mlp.torch.mlir":12:10)
#loc13 = loc("./pytorch/mlp.torch.mlir":13:10)
#loc14 = loc("./pytorch/mlp.torch.mlir":14:10)
#loc15 = loc("./pytorch/mlp.torch.mlir":15:10)
#loc16 = loc("./pytorch/mlp.torch.mlir":16:10)
#loc17 = loc("./pytorch/mlp.torch.mlir":17:11)
#loc18 = loc("./pytorch/mlp.torch.mlir":18:11)
#loc19 = loc("./pytorch/mlp.torch.mlir":19:11)
#loc20 = loc("./pytorch/mlp.torch.mlir":20:11)
#loc21 = loc("./pytorch/mlp.torch.mlir":21:11)
#loc22 = loc("./pytorch/mlp.torch.mlir":22:11)
#loc23 = loc("./pytorch/mlp.torch.mlir":23:11)
#loc24 = loc("./pytorch/mlp.torch.mlir":24:11)
#loc25 = loc("./pytorch/mlp.torch.mlir":25:11)
#loc26 = loc("./pytorch/mlp.torch.mlir":26:11)
#loc27 = loc("./pytorch/mlp.torch.mlir":27:11)
#loc28 = loc("./pytorch/mlp.torch.mlir":28:5)

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

