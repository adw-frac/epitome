#loc2 = loc("./pytorch/conv2d.linalg.mlir":2:21)
#loc5 = loc("./pytorch/conv2d.linalg.mlir":5:14)
#loc7 = loc("./pytorch/conv2d.linalg.mlir":7:10)
#loc8 = loc("./pytorch/conv2d.linalg.mlir":7:24)
#loc9 = loc("./pytorch/conv2d.linalg.mlir":7:38)
#loc10 = loc("./pytorch/conv2d.linalg.mlir":7:52)
#loc12 = loc("./pytorch/conv2d.linalg.mlir":10:10)
#loc15 = loc(unknown)
#map = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d4, d2 + d5, d3 + d6)>
#map1 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d1, d4, d5, d6)>
#map2 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<1x1x5x5xf32>) -> tensor<1x2x5x5xf32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: tensor<1x1x5x5xf32> loc("./pytorch/conv2d.linalg.mlir":2:21)):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc3)
    %1 = "arith.constant"() <{value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>}> : () -> tensor<2x1x3x3xf32> loc(#loc4)
    %2 = "arith.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32> loc(#loc5)
    %3 = "tensor.pad"(%arg0) <{operandSegmentSizes = array<i32: 1, 0, 0>, static_high = array<i64: 0, 0, 1, 1>, static_low = array<i64: 0, 0, 1, 1>}> ({
    ^bb0(%arg6: index loc("./pytorch/conv2d.linalg.mlir":7:10), %arg7: index loc("./pytorch/conv2d.linalg.mlir":7:24), %arg8: index loc("./pytorch/conv2d.linalg.mlir":7:38), %arg9: index loc("./pytorch/conv2d.linalg.mlir":7:52)):
      "tensor.yield"(%0) : (f32) -> () loc(#loc11)
    }) : (tensor<1x1x5x5xf32>) -> tensor<1x1x7x7xf32> loc(#loc6)
    %4 = "tensor.empty"() : () -> tensor<1x2x5x5xf32> loc(#loc12)
    %5 = "linalg.broadcast"(%2, %4) <{dimensions = array<i64: 0, 2, 3>}> ({
    ^bb0(%arg4: f32 loc("./pytorch/conv2d.linalg.mlir":5:14), %arg5: f32 loc("./pytorch/conv2d.linalg.mlir":10:10)):
      "linalg.yield"(%arg4) : (f32) -> () loc(#loc13)
    }) : (tensor<2xf32>, tensor<1x2x5x5xf32>) -> tensor<1x2x5x5xf32> loc(#loc13)
    %6 = "linalg.conv_2d_nchw_fchw"(%3, %1, %5) <{dilations = dense<1> : vector<2xi64>, operandSegmentSizes = array<i32: 2, 1>, strides = dense<1> : vector<2xi64>}> ({
    ^bb0(%arg1: f32 loc(unknown), %arg2: f32 loc(unknown), %arg3: f32 loc(unknown)):
      %7 = "arith.mulf"(%arg1, %arg2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc15)
      %8 = "arith.addf"(%arg3, %7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc15)
      "linalg.yield"(%8) : (f32) -> () loc(#loc15)
    }) {linalg.memoized_indexing_maps = [#map, #map1, #map2]} : (tensor<1x1x7x7xf32>, tensor<2x1x3x3xf32>, tensor<1x2x5x5xf32>) -> tensor<1x2x5x5xf32> loc(#loc14)
    "func.return"(%6) : (tensor<1x2x5x5xf32>) -> () loc(#loc16)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/conv2d.linalg.mlir":1:1)
#loc1 = loc("./pytorch/conv2d.linalg.mlir":2:3)
#loc3 = loc("./pytorch/conv2d.linalg.mlir":3:12)
#loc4 = loc("./pytorch/conv2d.linalg.mlir":4:14)
#loc6 = loc("./pytorch/conv2d.linalg.mlir":6:15)
#loc11 = loc("./pytorch/conv2d.linalg.mlir":8:7)
#loc13 = loc("./pytorch/conv2d.linalg.mlir":11:20)
#loc14 = loc("./pytorch/conv2d.linalg.mlir":12:10)
#loc16 = loc("./pytorch/conv2d.linalg.mlir":13:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}

