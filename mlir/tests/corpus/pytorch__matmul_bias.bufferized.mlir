#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
#map4 = affine_map<(d0, d1) -> (d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (memref<2x3xf32>, memref<3x4xf32>, memref<4xf32>) -> memref<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: memref<2x3xf32>, %arg1: memref<3x4xf32>, %arg2: memref<4xf32>):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %1 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<2x4xf32>
    "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32, %arg10: f32):
      "linalg.yield"(%arg9) : (f32) -> ()
    }) : (f32, memref<2x4xf32>) -> ()
    "linalg.matmul"(%arg0, %arg1, %1) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32, %arg7: f32, %arg8: f32):
      %3 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %4 = "arith.addf"(%arg8, %3) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%4) : (f32) -> ()
    }) : (memref<2x3xf32>, memref<3x4xf32>, memref<2x4xf32>) -> ()
    "linalg.generic"(%1, %arg2, %1) <{indexing_maps = [#map3, #map4, #map3], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg3: f32, %arg4: f32, %arg5: f32):
      %2 = "arith.addf"(%arg3, %arg4) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%2) : (f32) -> ()
    }) : (memref<2x4xf32>, memref<4xf32>, memref<2x4xf32>) -> ()
    "func.return"(%1) : (memref<2x4xf32>) -> ()
  }) {llvm.emit_c_interface} : () -> ()
}) : () -> ()

