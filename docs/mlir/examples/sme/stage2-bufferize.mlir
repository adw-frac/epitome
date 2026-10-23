"builtin.module"() ({
  "func.func"() <{function_type = (memref<16x4xf32>, memref<4x20xf32>, memref<16x20xf32>) -> (), sym_name = "matmul"}> ({
  ^bb0(%arg0: memref<16x4xf32>, %arg1: memref<4x20xf32>, %arg2: memref<16x20xf32>):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %1 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<16x20xf32>
    "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg3: f32, %arg4: f32):
      "linalg.yield"(%arg3) : (f32) -> ()
    }) : (f32, memref<16x20xf32>) -> ()
    "linalg.generic"(%arg0, %arg1, %1) <{indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg5: f32, %arg6: f32, %arg7: f32):
      %2 = "arith.mulf"(%arg5, %arg6) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %3 = "arith.addf"(%arg7, %2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%3) : (f32) -> ()
    }) : (memref<16x4xf32>, memref<4x20xf32>, memref<16x20xf32>) -> ()
    "memref.copy"(%1, %arg2) : (memref<16x20xf32>, memref<16x20xf32>) -> ()
    "memref.dealloc"(%1) : (memref<16x20xf32>) -> ()
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()
