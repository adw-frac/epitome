#loc2 = loc("./pytorch/dtypes.linalg.mlir":4:21)
#loc3 = loc("./pytorch/dtypes.linalg.mlir":4:42)
#loc4 = loc("./pytorch/dtypes.linalg.mlir":4:64)
#loc5 = loc("./pytorch/dtypes.linalg.mlir":4:85)
#loc6 = loc("./pytorch/dtypes.linalg.mlir":4:107)
#loc7 = loc("./pytorch/dtypes.linalg.mlir":4:130)
#loc13 = loc(unknown)
#loc15 = loc("./pytorch/dtypes.linalg.mlir":11:10)
#loc16 = loc("./pytorch/dtypes.linalg.mlir":11:19)
#loc22 = loc("./pytorch/dtypes.linalg.mlir":18:10)
#loc23 = loc("./pytorch/dtypes.linalg.mlir":18:20)
#loc28 = loc("./pytorch/dtypes.linalg.mlir":24:10)
#loc29 = loc("./pytorch/dtypes.linalg.mlir":24:20)
#map = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> ()>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2xi1>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>) -> (tensor<i64>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>), sym_name = "dtypes"}> ({
  ^bb0(%arg0: tensor<2xi1> loc("./pytorch/dtypes.linalg.mlir":4:21), %arg1: tensor<2xi64> loc("./pytorch/dtypes.linalg.mlir":4:42), %arg2: tensor<2xi8> loc("./pytorch/dtypes.linalg.mlir":4:64), %arg3: tensor<2xf16> loc("./pytorch/dtypes.linalg.mlir":4:85), %arg4: tensor<2xbf16> loc("./pytorch/dtypes.linalg.mlir":4:107), %arg5: tensor<f64> loc("./pytorch/dtypes.linalg.mlir":4:130)):
    %0 = "arith.constant"() <{value = 1 : i64}> : () -> i64 loc(#loc8)
    %1 = "arith.constant"() <{value = 0 : i64}> : () -> i64 loc(#loc9)
    %2 = "arith.constant"() <{value = 2.000000e+00 : f16}> : () -> f16 loc(#loc10)
    %3 = "tensor.empty"() : () -> tensor<i64> loc(#loc11)
    %4 = "linalg.fill"(%1, %3) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg12: i64 loc(unknown), %arg13: i64 loc(unknown)):
      "linalg.yield"(%arg12) : (i64) -> () loc(#loc13)
    }) : (i64, tensor<i64>) -> tensor<i64> loc(#loc12)
    %5 = "linalg.generic"(%arg0, %4) <{indexing_maps = [#map, #map1], iterator_types = [#linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg10: i1 loc("./pytorch/dtypes.linalg.mlir":11:10), %arg11: i64 loc("./pytorch/dtypes.linalg.mlir":11:19)):
      %12 = "arith.extui"(%arg10) : (i1) -> i64 loc(#loc17)
      %13 = "arith.addi"(%12, %arg11) <{overflowFlags = #arith.overflow<none>}> : (i64, i64) -> i64 loc(#loc18)
      "linalg.yield"(%13) : (i64) -> () loc(#loc19)
    }) : (tensor<2xi1>, tensor<i64>) -> tensor<i64> loc(#loc14)
    %6 = "tensor.empty"() : () -> tensor<2xi64> loc(#loc20)
    %7 = "linalg.generic"(%arg1, %6) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg8: i64 loc("./pytorch/dtypes.linalg.mlir":18:10), %arg9: i64 loc("./pytorch/dtypes.linalg.mlir":18:20)):
      %11 = "arith.addi"(%arg8, %0) <{overflowFlags = #arith.overflow<none>}> : (i64, i64) -> i64 loc(#loc24)
      "linalg.yield"(%11) : (i64) -> () loc(#loc25)
    }) : (tensor<2xi64>, tensor<2xi64>) -> tensor<2xi64> loc(#loc21)
    %8 = "tensor.empty"() : () -> tensor<2xf16> loc(#loc26)
    %9 = "linalg.generic"(%arg3, %8) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg6: f16 loc("./pytorch/dtypes.linalg.mlir":24:10), %arg7: f16 loc("./pytorch/dtypes.linalg.mlir":24:20)):
      %10 = "arith.mulf"(%arg6, %2) <{fastmath = #arith.fastmath<none>}> : (f16, f16) -> f16 loc(#loc30)
      "linalg.yield"(%10) : (f16) -> () loc(#loc31)
    }) : (tensor<2xf16>, tensor<2xf16>) -> tensor<2xf16> loc(#loc27)
    "func.return"(%5, %7, %arg2, %9, %arg4, %arg5) : (tensor<i64>, tensor<2xi64>, tensor<2xi8>, tensor<2xf16>, tensor<2xbf16>, tensor<f64>) -> () loc(#loc32)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/dtypes.linalg.mlir":3:1)
#loc1 = loc("./pytorch/dtypes.linalg.mlir":4:3)
#loc8 = loc("./pytorch/dtypes.linalg.mlir":5:15)
#loc9 = loc("./pytorch/dtypes.linalg.mlir":6:15)
#loc10 = loc("./pytorch/dtypes.linalg.mlir":7:12)
#loc11 = loc("./pytorch/dtypes.linalg.mlir":8:10)
#loc12 = loc("./pytorch/dtypes.linalg.mlir":9:10)
#loc14 = loc("./pytorch/dtypes.linalg.mlir":10:10)
#loc17 = loc("./pytorch/dtypes.linalg.mlir":12:12)
#loc18 = loc("./pytorch/dtypes.linalg.mlir":13:12)
#loc19 = loc("./pytorch/dtypes.linalg.mlir":14:7)
#loc20 = loc("./pytorch/dtypes.linalg.mlir":16:10)
#loc21 = loc("./pytorch/dtypes.linalg.mlir":17:10)
#loc24 = loc("./pytorch/dtypes.linalg.mlir":19:12)
#loc25 = loc("./pytorch/dtypes.linalg.mlir":20:7)
#loc26 = loc("./pytorch/dtypes.linalg.mlir":22:10)
#loc27 = loc("./pytorch/dtypes.linalg.mlir":23:10)
#loc30 = loc("./pytorch/dtypes.linalg.mlir":25:12)
#loc31 = loc("./pytorch/dtypes.linalg.mlir":26:7)
#loc32 = loc("./pytorch/dtypes.linalg.mlir":28:5)

