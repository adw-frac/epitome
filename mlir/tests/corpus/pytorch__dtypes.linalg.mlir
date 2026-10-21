#map = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> ()>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2xi1>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>) -> (tensor<i64>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>), sym_name = "dtypes"}> ({
  ^bb0(%arg0: tensor<2xi1>, %arg1: tensor<2xi64>, %arg2: tensor<2xi8>, %arg3: tensor<2xf16>, %arg4: tensor<2xbf16>, %arg5: tensor<f64>):
    %0 = "arith.constant"() <{value = 1 : i64}> : () -> i64
    %1 = "arith.constant"() <{value = 0 : i64}> : () -> i64
    %2 = "arith.constant"() <{value = 2.000000e+00 : f16}> : () -> f16
    %3 = "tensor.empty"() : () -> tensor<i64>
    %4 = "linalg.fill"(%1, %3) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg12: i64, %arg13: i64):
      "linalg.yield"(%arg12) : (i64) -> ()
    }) : (i64, tensor<i64>) -> tensor<i64>
    %5 = "linalg.generic"(%arg0, %4) <{indexing_maps = [#map, #map1], iterator_types = [#linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg10: i1, %arg11: i64):
      %12 = "arith.extui"(%arg10) : (i1) -> i64
      %13 = "arith.addi"(%12, %arg11) <{overflowFlags = #arith.overflow<none>}> : (i64, i64) -> i64
      "linalg.yield"(%13) : (i64) -> ()
    }) : (tensor<2xi1>, tensor<i64>) -> tensor<i64>
    %6 = "tensor.empty"() : () -> tensor<2xi64>
    %7 = "linalg.generic"(%arg1, %6) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg8: i64, %arg9: i64):
      %11 = "arith.addi"(%arg8, %0) <{overflowFlags = #arith.overflow<none>}> : (i64, i64) -> i64
      "linalg.yield"(%11) : (i64) -> ()
    }) : (tensor<2xi64>, tensor<2xi64>) -> tensor<2xi64>
    %8 = "tensor.empty"() : () -> tensor<2xf16>
    %9 = "linalg.generic"(%arg3, %8) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg6: f16, %arg7: f16):
      %10 = "arith.mulf"(%arg6, %2) <{fastmath = #arith.fastmath<none>}> : (f16, f16) -> f16
      "linalg.yield"(%10) : (f16) -> ()
    }) : (tensor<2xf16>, tensor<2xf16>) -> tensor<2xf16>
    "func.return"(%5, %7, %arg2, %9, %arg4, %arg5) : (tensor<i64>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>) -> ()
  }) : () -> ()
}) : () -> ()

