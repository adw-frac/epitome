module {
  func.func @matmul_bias(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>, %arg2: tensor<4xf32>) -> tensor<2x4xf32> {
    %0 = stablehlo.dot_general %arg0, %arg1, contracting_dims = [1] x [0] : (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>
    %1 = stablehlo.broadcast_in_dim %arg2, dims = [1] : (tensor<4xf32>) -> tensor<2x4xf32>
    %2 = stablehlo.add %0, %1 : tensor<2x4xf32>
    return %2 : tensor<2x4xf32>
  }
}
