"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2x3xf32>, tensor<3x4xf32>, tensor<4xf32>) -> tensor<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>, %arg2: tensor<4xf32>):
    %0 = "stablehlo.dot_general"(%arg0, %arg1) <{dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>}> : (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>
    %1 = "stablehlo.broadcast_in_dim"(%arg2) <{broadcast_dimensions = array<i64: 1>}> : (tensor<4xf32>) -> tensor<2x4xf32>
    %2 = "stablehlo.add"(%0, %1) : (tensor<2x4xf32>, tensor<2x4xf32>) -> tensor<2x4xf32>
    "func.return"(%2) : (tensor<2x4xf32>) -> ()
  }) : () -> ()
}) : () -> ()

