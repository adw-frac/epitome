#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
#map4 = affine_map<(d0, d1) -> (d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2x3xf32>, tensor<3x4xf32>, tensor<4xf32>) -> tensor<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>, %arg2: tensor<4xf32>):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %1 = "tensor.empty"() : () -> tensor<2x4xf32>
    %2 = "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32, %arg10: f32):
      "linalg.yield"(%arg9) : (f32) -> ()
    }) : (f32, tensor<2x4xf32>) -> tensor<2x4xf32>
    %3 = "linalg.matmul"(%arg0, %arg1, %2) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32, %arg7: f32, %arg8: f32):
      %6 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %7 = "arith.addf"(%arg8, %6) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%7) : (f32) -> ()
    }) : (tensor<2x3xf32>, tensor<3x4xf32>, tensor<2x4xf32>) -> tensor<2x4xf32>
    %4 = "linalg.generic"(%3, %arg2, %1) <{indexing_maps = [#map3, #map4, #map3], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg3: f32, %arg4: f32, %arg5: f32):
      %5 = "arith.addf"(%arg3, %arg4) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%5) : (f32) -> ()
    }) : (tensor<2x4xf32>, tensor<4xf32>, tensor<2x4xf32>) -> tensor<2x4xf32>
    "func.return"(%4) : (tensor<2x4xf32>) -> ()
  }) : () -> ()
}) : () -> ()

