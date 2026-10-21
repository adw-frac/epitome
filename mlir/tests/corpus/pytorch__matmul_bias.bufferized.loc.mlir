#loc2 = loc("./pytorch/matmul_bias.bufferized.mlir":4:26)
#loc3 = loc("./pytorch/matmul_bias.bufferized.mlir":4:50)
#loc4 = loc("./pytorch/matmul_bias.bufferized.mlir":4:74)
#loc8 = loc(unknown)
#loc11 = loc("./pytorch/matmul_bias.bufferized.mlir":10:10)
#loc12 = loc("./pytorch/matmul_bias.bufferized.mlir":10:20)
#loc13 = loc("./pytorch/matmul_bias.bufferized.mlir":10:32)
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
#map4 = affine_map<(d0, d1) -> (d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (memref<2x3xf32>, memref<3x4xf32>, memref<4xf32>) -> memref<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: memref<2x3xf32> loc("./pytorch/matmul_bias.bufferized.mlir":4:26), %arg1: memref<3x4xf32> loc("./pytorch/matmul_bias.bufferized.mlir":4:50), %arg2: memref<4xf32> loc("./pytorch/matmul_bias.bufferized.mlir":4:74)):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc5)
    %1 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<2x4xf32> loc(#loc6)
    "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32 loc(unknown), %arg10: f32 loc(unknown)):
      "linalg.yield"(%arg9) : (f32) -> () loc(#loc8)
    }) : (f32, memref<2x4xf32>) -> () loc(#loc7)
    "linalg.matmul"(%arg0, %arg1, %1) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32 loc(unknown), %arg7: f32 loc(unknown), %arg8: f32 loc(unknown)):
      %3 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc8)
      %4 = "arith.addf"(%arg8, %3) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc8)
      "linalg.yield"(%4) : (f32) -> () loc(#loc8)
    }) : (memref<2x3xf32>, memref<3x4xf32>, memref<2x4xf32>) -> () loc(#loc9)
    "linalg.generic"(%1, %arg2, %1) <{indexing_maps = [#map3, #map4, #map3], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg3: f32 loc("./pytorch/matmul_bias.bufferized.mlir":10:10), %arg4: f32 loc("./pytorch/matmul_bias.bufferized.mlir":10:20), %arg5: f32 loc("./pytorch/matmul_bias.bufferized.mlir":10:32)):
      %2 = "arith.addf"(%arg3, %arg4) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc14)
      "linalg.yield"(%2) : (f32) -> () loc(#loc15)
    }) : (memref<2x4xf32>, memref<4xf32>, memref<2x4xf32>) -> () loc(#loc10)
    "func.return"(%1) : (memref<2x4xf32>) -> () loc(#loc16)
  }) {llvm.emit_c_interface} : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/matmul_bias.bufferized.mlir":3:1)
#loc1 = loc("./pytorch/matmul_bias.bufferized.mlir":4:3)
#loc5 = loc("./pytorch/matmul_bias.bufferized.mlir":5:12)
#loc6 = loc("./pytorch/matmul_bias.bufferized.mlir":6:14)
#loc7 = loc("./pytorch/matmul_bias.bufferized.mlir":7:5)
#loc9 = loc("./pytorch/matmul_bias.bufferized.mlir":8:5)
#loc10 = loc("./pytorch/matmul_bias.bufferized.mlir":9:5)
#loc14 = loc("./pytorch/matmul_bias.bufferized.mlir":11:12)
#loc15 = loc("./pytorch/matmul_bias.bufferized.mlir":12:7)
#loc16 = loc("./pytorch/matmul_bias.bufferized.mlir":14:5)

