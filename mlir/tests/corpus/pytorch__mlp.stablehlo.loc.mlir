#loc2 = loc("./pytorch/mlp.stablehlo.mlir":2:18)
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<1x4xf32>) -> tensor<1x2xf32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: tensor<1x4xf32> loc("./pytorch/mlp.stablehlo.mlir":2:18)):
    %0 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32> loc(#loc3)
    %1 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> tensor<2x8xf32> loc(#loc4)
    %2 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> tensor<8xf32> loc(#loc5)
    %3 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> tensor<8x4xf32> loc(#loc6)
    %4 = "stablehlo.constant"() <{value = dense<0.000000e+00> : tensor<1x8xf32>}> : () -> tensor<1x8xf32> loc(#loc7)
    %5 = "arith.constant"() <{value = dense<1> : tensor<1xi64>}> : () -> tensor<1xi64> loc(#loc8)
    %6 = "stablehlo.transpose"(%3) <{permutation = array<i64: 1, 0>}> : (tensor<8x4xf32>) -> tensor<4x8xf32> loc(#loc9)
    %7 = "stablehlo.dot_general"(%arg0, %6) <{dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>}> : (tensor<1x4xf32>, tensor<4x8xf32>) -> tensor<1x8xf32> loc(#loc10)
    %8 = "stablehlo.convert"(%5) : (tensor<1xi64>) -> tensor<1xf32> loc(#loc11)
    %9 = "stablehlo.reshape"(%8) : (tensor<1xf32>) -> tensor<f32> loc(#loc12)
    %10 = "stablehlo.broadcast_in_dim"(%9) <{broadcast_dimensions = array<i64>}> : (tensor<f32>) -> tensor<1x8xf32> loc(#loc13)
    %11 = "stablehlo.multiply"(%7, %10) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc14)
    %12 = "stablehlo.broadcast_in_dim"(%2) <{broadcast_dimensions = array<i64: 1>}> : (tensor<8xf32>) -> tensor<1x8xf32> loc(#loc15)
    %13 = "stablehlo.multiply"(%12, %10) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc16)
    %14 = "stablehlo.add"(%11, %13) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc17)
    %15 = "stablehlo.maximum"(%14, %4) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc18)
    %16 = "stablehlo.transpose"(%1) <{permutation = array<i64: 1, 0>}> : (tensor<2x8xf32>) -> tensor<8x2xf32> loc(#loc19)
    %17 = "stablehlo.dot_general"(%15, %16) <{dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>}> : (tensor<1x8xf32>, tensor<8x2xf32>) -> tensor<1x2xf32> loc(#loc20)
    %18 = "stablehlo.broadcast_in_dim"(%9) <{broadcast_dimensions = array<i64>}> : (tensor<f32>) -> tensor<1x2xf32> loc(#loc21)
    %19 = "stablehlo.multiply"(%17, %18) : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc22)
    %20 = "stablehlo.broadcast_in_dim"(%0) <{broadcast_dimensions = array<i64: 1>}> : (tensor<2xf32>) -> tensor<1x2xf32> loc(#loc23)
    %21 = "stablehlo.multiply"(%20, %18) : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc24)
    %22 = "stablehlo.add"(%19, %21) : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc25)
    "func.return"(%22) : (tensor<1x2xf32>) -> () loc(#loc26)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/mlp.stablehlo.mlir":1:1)
#loc1 = loc("./pytorch/mlp.stablehlo.mlir":2:3)
#loc3 = loc("./pytorch/mlp.stablehlo.mlir":3:12)
#loc4 = loc("./pytorch/mlp.stablehlo.mlir":4:14)
#loc5 = loc("./pytorch/mlp.stablehlo.mlir":5:14)
#loc6 = loc("./pytorch/mlp.stablehlo.mlir":6:14)
#loc7 = loc("./pytorch/mlp.stablehlo.mlir":7:14)
#loc8 = loc("./pytorch/mlp.stablehlo.mlir":8:14)
#loc9 = loc("./pytorch/mlp.stablehlo.mlir":9:10)
#loc10 = loc("./pytorch/mlp.stablehlo.mlir":10:10)
#loc11 = loc("./pytorch/mlp.stablehlo.mlir":11:10)
#loc12 = loc("./pytorch/mlp.stablehlo.mlir":12:10)
#loc13 = loc("./pytorch/mlp.stablehlo.mlir":13:10)
#loc14 = loc("./pytorch/mlp.stablehlo.mlir":14:10)
#loc15 = loc("./pytorch/mlp.stablehlo.mlir":15:10)
#loc16 = loc("./pytorch/mlp.stablehlo.mlir":16:10)
#loc17 = loc("./pytorch/mlp.stablehlo.mlir":17:10)
#loc18 = loc("./pytorch/mlp.stablehlo.mlir":18:10)
#loc19 = loc("./pytorch/mlp.stablehlo.mlir":19:11)
#loc20 = loc("./pytorch/mlp.stablehlo.mlir":20:11)
#loc21 = loc("./pytorch/mlp.stablehlo.mlir":21:11)
#loc22 = loc("./pytorch/mlp.stablehlo.mlir":22:11)
#loc23 = loc("./pytorch/mlp.stablehlo.mlir":23:11)
#loc24 = loc("./pytorch/mlp.stablehlo.mlir":24:11)
#loc25 = loc("./pytorch/mlp.stablehlo.mlir":25:11)
#loc26 = loc("./pytorch/mlp.stablehlo.mlir":26:5)

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

