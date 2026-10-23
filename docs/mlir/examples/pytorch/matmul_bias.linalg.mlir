#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d1)>
module {
  func.func @matmul_bias(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>, %arg2: tensor<4xf32>) -> tensor<2x4xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = tensor.empty() : tensor<2x4xf32>
    %1 = linalg.fill ins(%cst : f32) outs(%0 : tensor<2x4xf32>) -> tensor<2x4xf32>
    %2 = linalg.matmul ins(%arg0, %arg1 : tensor<2x3xf32>, tensor<3x4xf32>) outs(%1 : tensor<2x4xf32>) -> tensor<2x4xf32>
    %3 = linalg.generic {indexing_maps = [#map, #map1, #map], iterator_types = ["parallel", "parallel"]} ins(%2, %arg2 : tensor<2x4xf32>, tensor<4xf32>) outs(%0 : tensor<2x4xf32>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %4 = arith.addf %in, %in_0 : f32
      linalg.yield %4 : f32
    } -> tensor<2x4xf32>
    return %3 : tensor<2x4xf32>
  }
}
