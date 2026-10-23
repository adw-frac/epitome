#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1, d2) -> (d0, d2)>
#map2 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map3 = affine_map<(d0, d1, d2) -> (d0, d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>, sym_name = "qmatmul"}> ({
  ^bb0(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>):
    %0 = "arith.constant"() <{value = 3 : i64}> : () -> i64
    %1 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %2 = "arith.constant"() <{value = -1.280000e+02 : f32}> : () -> f32
    %3 = "arith.constant"() <{value = 1.270000e+02 : f32}> : () -> f32
    %4 = "arith.constant"() <{value = 5.000000e-02 : f64}> : () -> f64
    %5 = "arith.constant"() <{value = 3.000000e+00 : f32}> : () -> f32
    %6 = "arith.constant"() <{value = 1.000000e-01 : f64}> : () -> f64
    %7 = "tensor.empty"() : () -> tensor<2x3xi8>
    %8 = "linalg.generic"(%arg0, %7) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg13: f32, %arg14: i8):
      %35 = "arith.truncf"(%4) : (f64) -> f32
      %36 = "arith.divf"(%arg13, %35) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %37 = "math.roundeven"(%36) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
      %38 = "arith.addf"(%37, %5) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %39 = "arith.maximumf"(%38, %2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %40 = "arith.minimumf"(%39, %3) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %41 = "arith.fptosi"(%40) : (f32) -> i8
      "linalg.yield"(%41) : (i8) -> ()
    }) : (tensor<2x3xf32>, tensor<2x3xi8>) -> tensor<2x3xi8>
    %9 = "tensor.empty"() : () -> tensor<3x4xi8>
    %10 = "linalg.generic"(%arg1, %9) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg11: f32, %arg12: i8):
      %28 = "arith.truncf"(%6) : (f64) -> f32
      %29 = "arith.divf"(%arg11, %28) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %30 = "math.roundeven"(%29) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
      %31 = "arith.addf"(%30, %1) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %32 = "arith.maximumf"(%31, %2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %33 = "arith.minimumf"(%32, %3) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %34 = "arith.fptosi"(%33) : (f32) -> i8
      "linalg.yield"(%34) : (i8) -> ()
    }) : (tensor<3x4xf32>, tensor<3x4xi8>) -> tensor<3x4xi8>
    %11 = "tensor.empty"() : () -> tensor<2x3xf32>
    %12 = "linalg.generic"(%8, %11) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: i8, %arg10: f32):
      %23 = "arith.extsi"(%arg9) : (i8) -> i64
      %24 = "arith.subi"(%23, %0) <{overflowFlags = #arith.overflow<none>}> : (i64, i64) -> i64
      %25 = "arith.truncf"(%4) : (f64) -> f32
      %26 = "arith.sitofp"(%24) : (i64) -> f32
      %27 = "arith.mulf"(%26, %25) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%27) : (f32) -> ()
    }) : (tensor<2x3xi8>, tensor<2x3xf32>) -> tensor<2x3xf32>
    %13 = "tensor.empty"() : () -> tensor<3x4xf32>
    %14 = "linalg.generic"(%10, %13) <{indexing_maps = [#map, #map], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg7: i8, %arg8: f32):
      %20 = "arith.truncf"(%6) : (f64) -> f32
      %21 = "arith.sitofp"(%arg7) : (i8) -> f32
      %22 = "arith.mulf"(%21, %20) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%22) : (f32) -> ()
    }) : (tensor<3x4xi8>, tensor<3x4xf32>) -> tensor<3x4xf32>
    %15 = "tensor.empty"() : () -> tensor<2x4xf32>
    %16 = "linalg.fill"(%1, %15) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg5: f32, %arg6: f32):
      "linalg.yield"(%arg5) : (f32) -> ()
    }) : (f32, tensor<2x4xf32>) -> tensor<2x4xf32>
    %17 = "linalg.matmul"(%12, %14, %16) <{indexing_maps = [#map1, #map2, #map3], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg2: f32, %arg3: f32, %arg4: f32):
      %18 = "arith.mulf"(%arg2, %arg3) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %19 = "arith.addf"(%arg4, %18) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%19) : (f32) -> ()
    }) : (tensor<2x3xf32>, tensor<3x4xf32>, tensor<2x4xf32>) -> tensor<2x4xf32>
    "func.return"(%17) : (tensor<2x4xf32>) -> ()
  }) : () -> ()
}) : () -> ()

