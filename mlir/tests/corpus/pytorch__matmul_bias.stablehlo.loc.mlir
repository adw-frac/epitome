#loc2 = loc("./pytorch/matmul_bias.stablehlo.mlir":2:26)
#loc3 = loc("./pytorch/matmul_bias.stablehlo.mlir":2:50)
#loc4 = loc("./pytorch/matmul_bias.stablehlo.mlir":2:74)
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2x3xf32>, tensor<3x4xf32>, tensor<4xf32>) -> tensor<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: tensor<2x3xf32> loc("./pytorch/matmul_bias.stablehlo.mlir":2:26), %arg1: tensor<3x4xf32> loc("./pytorch/matmul_bias.stablehlo.mlir":2:50), %arg2: tensor<4xf32> loc("./pytorch/matmul_bias.stablehlo.mlir":2:74)):
    %0 = "stablehlo.dot_general"(%arg0, %arg1) <{dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>}> : (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32> loc(#loc5)
    %1 = "stablehlo.broadcast_in_dim"(%arg2) <{broadcast_dimensions = array<i64: 1>}> : (tensor<4xf32>) -> tensor<2x4xf32> loc(#loc6)
    %2 = "stablehlo.add"(%0, %1) : (tensor<2x4xf32>, tensor<2x4xf32>) -> tensor<2x4xf32> loc(#loc7)
    "func.return"(%2) : (tensor<2x4xf32>) -> () loc(#loc8)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/matmul_bias.stablehlo.mlir":1:1)
#loc1 = loc("./pytorch/matmul_bias.stablehlo.mlir":2:3)
#loc5 = loc("./pytorch/matmul_bias.stablehlo.mlir":3:10)
#loc6 = loc("./pytorch/matmul_bias.stablehlo.mlir":4:10)
#loc7 = loc("./pytorch/matmul_bias.stablehlo.mlir":5:10)
#loc8 = loc("./pytorch/matmul_bias.stablehlo.mlir":6:5)

