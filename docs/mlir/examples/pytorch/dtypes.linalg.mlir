#map = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> ()>
module {
  func.func @dtypes(%arg0: tensor<2xi1>, %arg1: tensor<2xi64>, %arg2: tensor<2xi8>, %arg3: tensor<2xf16>, %arg4: tensor<2xbf16>, %arg5: tensor<f64>) -> (tensor<i64>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>) {
    %c1_i64 = arith.constant 1 : i64
    %c0_i64 = arith.constant 0 : i64
    %cst = arith.constant 2.000000e+00 : f16
    %0 = tensor.empty() : tensor<i64>
    %1 = linalg.fill ins(%c0_i64 : i64) outs(%0 : tensor<i64>) -> tensor<i64>
    %2 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["reduction"]} ins(%arg0 : tensor<2xi1>) outs(%1 : tensor<i64>) {
    ^bb0(%in: i1, %out: i64):
      %7 = arith.extui %in : i1 to i64
      %8 = arith.addi %7, %out : i64
      linalg.yield %8 : i64
    } -> tensor<i64>
    %3 = tensor.empty() : tensor<2xi64>
    %4 = linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel"]} ins(%arg1 : tensor<2xi64>) outs(%3 : tensor<2xi64>) {
    ^bb0(%in: i64, %out: i64):
      %7 = arith.addi %in, %c1_i64 : i64
      linalg.yield %7 : i64
    } -> tensor<2xi64>
    %5 = tensor.empty() : tensor<2xf16>
    %6 = linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel"]} ins(%arg3 : tensor<2xf16>) outs(%5 : tensor<2xf16>) {
    ^bb0(%in: f16, %out: f16):
      %7 = arith.mulf %in, %cst : f16
      linalg.yield %7 : f16
    } -> tensor<2xf16>
    return %2, %4, %arg2, %6, %arg4, %arg5 : tensor<i64>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>
  }
}
