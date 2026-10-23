#map = affine_map<(d0, d1) -> (d0, d1)>
module {
  func.func @qmatmul(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>) -> tensor<2x4xf32> {
    %c3_i64 = arith.constant 3 : i64
    %cst = arith.constant 0.000000e+00 : f32
    %cst_0 = arith.constant -1.280000e+02 : f32
    %cst_1 = arith.constant 1.270000e+02 : f32
    %cst_2 = arith.constant 5.000000e-02 : f64
    %cst_3 = arith.constant 3.000000e+00 : f32
    %cst_4 = arith.constant 1.000000e-01 : f64
    %0 = tensor.empty() : tensor<2x3xi8>
    %1 = linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel", "parallel"]} ins(%arg0 : tensor<2x3xf32>) outs(%0 : tensor<2x3xi8>) {
    ^bb0(%in: f32, %out: i8):
      %11 = arith.truncf %cst_2 : f64 to f32
      %12 = arith.divf %in, %11 : f32
      %13 = math.roundeven %12 : f32
      %14 = arith.addf %13, %cst_3 : f32
      %15 = arith.maximumf %14, %cst_0 : f32
      %16 = arith.minimumf %15, %cst_1 : f32
      %17 = arith.fptosi %16 : f32 to i8
      linalg.yield %17 : i8
    } -> tensor<2x3xi8>
    %2 = tensor.empty() : tensor<3x4xi8>
    %3 = linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel", "parallel"]} ins(%arg1 : tensor<3x4xf32>) outs(%2 : tensor<3x4xi8>) {
    ^bb0(%in: f32, %out: i8):
      %11 = arith.truncf %cst_4 : f64 to f32
      %12 = arith.divf %in, %11 : f32
      %13 = math.roundeven %12 : f32
      %14 = arith.addf %13, %cst : f32
      %15 = arith.maximumf %14, %cst_0 : f32
      %16 = arith.minimumf %15, %cst_1 : f32
      %17 = arith.fptosi %16 : f32 to i8
      linalg.yield %17 : i8
    } -> tensor<3x4xi8>
    %4 = tensor.empty() : tensor<2x3xf32>
    %5 = linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel", "parallel"]} ins(%1 : tensor<2x3xi8>) outs(%4 : tensor<2x3xf32>) {
    ^bb0(%in: i8, %out: f32):
      %11 = arith.extsi %in : i8 to i64
      %12 = arith.subi %11, %c3_i64 : i64
      %13 = arith.truncf %cst_2 : f64 to f32
      %14 = arith.sitofp %12 : i64 to f32
      %15 = arith.mulf %14, %13 : f32
      linalg.yield %15 : f32
    } -> tensor<2x3xf32>
    %6 = tensor.empty() : tensor<3x4xf32>
    %7 = linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel", "parallel"]} ins(%3 : tensor<3x4xi8>) outs(%6 : tensor<3x4xf32>) {
    ^bb0(%in: i8, %out: f32):
      %11 = arith.truncf %cst_4 : f64 to f32
      %12 = arith.sitofp %in : i8 to f32
      %13 = arith.mulf %12, %11 : f32
      linalg.yield %13 : f32
    } -> tensor<3x4xf32>
    %8 = tensor.empty() : tensor<2x4xf32>
    %9 = linalg.fill ins(%cst : f32) outs(%8 : tensor<2x4xf32>) -> tensor<2x4xf32>
    %10 = linalg.matmul ins(%5, %7 : tensor<2x3xf32>, tensor<3x4xf32>) outs(%9 : tensor<2x4xf32>) -> tensor<2x4xf32>
    return %10 : tensor<2x4xf32>
  }
}
