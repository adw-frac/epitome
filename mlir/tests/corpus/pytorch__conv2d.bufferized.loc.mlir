#loc4 = loc("./pytorch/conv2d.bufferized.mlir":4:21)
#loc7 = loc("./pytorch/conv2d.bufferized.mlir":7:10)
#loc10 = loc("./pytorch/conv2d.bufferized.mlir":10:8)
#loc14 = loc("./pytorch/conv2d.bufferized.mlir":15:16)
#loc17 = loc(unknown)
#map = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d4, d2 + d5, d3 + d6)>
#map1 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d1, d4, d5, d6)>
#map2 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>
"builtin.module"() ({
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>, sym_name = "__constant_2xf32", sym_visibility = "private", type = memref<2xf32>}> : () -> () loc(#loc1)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>, sym_name = "__constant_2x1x3x3xf32", sym_visibility = "private", type = memref<2x1x3x3xf32>}> : () -> () loc(#loc2)
  "func.func"() <{function_type = (memref<1x1x5x5xf32>) -> memref<1x2x5x5xf32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: memref<1x1x5x5xf32> loc("./pytorch/conv2d.bufferized.mlir":4:21)):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc5)
    %1 = "memref.get_global"() <{name = @__constant_2x1x3x3xf32}> : () -> memref<2x1x3x3xf32> loc(#loc6)
    %2 = "memref.get_global"() <{name = @__constant_2xf32}> : () -> memref<2xf32> loc(#loc7)
    %3 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x1x7x7xf32> loc(#loc8)
    "linalg.map"(%3) ({
    ^bb0(%arg6: f32 loc("./pytorch/conv2d.bufferized.mlir":10:8)):
      "linalg.yield"(%0) : (f32) -> () loc(#loc11)
    }) : (memref<1x1x7x7xf32>) -> () loc(#loc9)
    %4 = "memref.subview"(%3) <{operandSegmentSizes = array<i32: 1, 0, 0, 0>, static_offsets = array<i64: 0, 0, 1, 1>, static_sizes = array<i64: 1, 1, 5, 5>, static_strides = array<i64: 1, 1, 1, 1>}> : (memref<1x1x7x7xf32>) -> memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>> loc(#loc12)
    "memref.copy"(%arg0, %4) : (memref<1x1x5x5xf32>, memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>) -> () loc(#loc13)
    %5 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2x5x5xf32> loc(#loc14)
    "linalg.broadcast"(%2, %5) <{dimensions = array<i64: 0, 2, 3>}> ({
    ^bb0(%arg4: f32 loc("./pytorch/conv2d.bufferized.mlir":7:10), %arg5: f32 loc("./pytorch/conv2d.bufferized.mlir":15:16)):
      "linalg.yield"(%arg4) : (f32) -> () loc(#loc15)
    }) : (memref<2xf32>, memref<1x2x5x5xf32>) -> () loc(#loc15)
    "linalg.conv_2d_nchw_fchw"(%3, %1, %5) <{dilations = dense<1> : vector<2xi64>, operandSegmentSizes = array<i32: 2, 1>, strides = dense<1> : vector<2xi64>}> ({
    ^bb0(%arg1: f32 loc(unknown), %arg2: f32 loc(unknown), %arg3: f32 loc(unknown)):
      %6 = "arith.mulf"(%arg1, %arg2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      %7 = "arith.addf"(%arg3, %6) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      "linalg.yield"(%7) : (f32) -> () loc(#loc17)
    }) {linalg.memoized_indexing_maps = [#map, #map1, #map2]} : (memref<1x1x7x7xf32>, memref<2x1x3x3xf32>, memref<1x2x5x5xf32>) -> () loc(#loc16)
    "func.return"(%5) : (memref<1x2x5x5xf32>) -> () loc(#loc18)
  }) {llvm.emit_c_interface} : () -> () loc(#loc3)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/conv2d.bufferized.mlir":1:1)
#loc1 = loc("./pytorch/conv2d.bufferized.mlir":2:3)
#loc2 = loc("./pytorch/conv2d.bufferized.mlir":3:3)
#loc3 = loc("./pytorch/conv2d.bufferized.mlir":4:3)
#loc5 = loc("./pytorch/conv2d.bufferized.mlir":5:12)
#loc6 = loc("./pytorch/conv2d.bufferized.mlir":6:10)
#loc8 = loc("./pytorch/conv2d.bufferized.mlir":8:14)
#loc9 = loc("./pytorch/conv2d.bufferized.mlir":9:5)
#loc11 = loc("./pytorch/conv2d.bufferized.mlir":11:9)
#loc12 = loc("./pytorch/conv2d.bufferized.mlir":13:16)
#loc13 = loc("./pytorch/conv2d.bufferized.mlir":14:5)
#loc15 = loc("./pytorch/conv2d.bufferized.mlir":16:5)
#loc16 = loc("./pytorch/conv2d.bufferized.mlir":17:5)
#loc18 = loc("./pytorch/conv2d.bufferized.mlir":18:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE",
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE"
    }
  }
#-}

