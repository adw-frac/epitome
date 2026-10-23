#loc2 = loc("./pytorch/mlp.linalg.mlir":4:18)
#loc5 = loc("./pytorch/mlp.linalg.mlir":7:14)
#loc7 = loc("./pytorch/mlp.linalg.mlir":9:14)
#loc8 = loc("./pytorch/mlp.linalg.mlir":10:10)
#loc12 = loc(unknown)
#loc15 = loc("./pytorch/mlp.linalg.mlir":16:10)
#loc16 = loc("./pytorch/mlp.linalg.mlir":16:20)
#loc19 = loc("./pytorch/mlp.linalg.mlir":20:10)
#loc20 = loc("./pytorch/mlp.linalg.mlir":20:20)
#loc21 = loc("./pytorch/mlp.linalg.mlir":20:32)
#loc25 = loc("./pytorch/mlp.linalg.mlir":25:10)
#loc26 = loc("./pytorch/mlp.linalg.mlir":25:20)
#loc30 = loc("./pytorch/mlp.linalg.mlir":30:10)
#loc36 = loc("./pytorch/mlp.linalg.mlir":36:10)
#loc37 = loc("./pytorch/mlp.linalg.mlir":36:20)
#loc40 = loc("./pytorch/mlp.linalg.mlir":40:10)
#loc41 = loc("./pytorch/mlp.linalg.mlir":40:20)
#loc42 = loc("./pytorch/mlp.linalg.mlir":40:32)
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1)>
#map4 = affine_map<(d0, d1) -> (d0, d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<1x4xf32>) -> tensor<1x2xf32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: tensor<1x4xf32> loc("./pytorch/mlp.linalg.mlir":4:18)):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc3)
    %1 = "arith.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32> loc(#loc4)
    %2 = "arith.constant"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> tensor<2x8xf32> loc(#loc5)
    %3 = "arith.constant"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> tensor<8xf32> loc(#loc6)
    %4 = "arith.constant"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> tensor<8x4xf32> loc(#loc7)
    %5 = "tensor.empty"() : () -> tensor<4x8xf32> loc(#loc8)
    %6 = "linalg.transpose"(%4, %5) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg25: f32 loc("./pytorch/mlp.linalg.mlir":9:14), %arg26: f32 loc("./pytorch/mlp.linalg.mlir":10:10)):
      "linalg.yield"(%arg25) : (f32) -> () loc(#loc9)
    }) : (tensor<8x4xf32>, tensor<4x8xf32>) -> tensor<4x8xf32> loc(#loc9)
    %7 = "tensor.empty"() : () -> tensor<1x8xf32> loc(#loc10)
    %8 = "linalg.fill"(%0, %7) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg23: f32 loc(unknown), %arg24: f32 loc(unknown)):
      "linalg.yield"(%arg23) : (f32) -> () loc(#loc12)
    }) : (f32, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc11)
    %9 = "linalg.matmul"(%arg0, %6, %8) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg20: f32 loc(unknown), %arg21: f32 loc(unknown), %arg22: f32 loc(unknown)):
      %26 = "arith.mulf"(%arg20, %arg21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc12)
      %27 = "arith.addf"(%arg22, %26) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc12)
      "linalg.yield"(%27) : (f32) -> () loc(#loc12)
    }) : (tensor<1x4xf32>, tensor<4x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc13)
    %10 = "linalg.generic"(%3, %7) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg18: f32 loc("./pytorch/mlp.linalg.mlir":16:10), %arg19: f32 loc("./pytorch/mlp.linalg.mlir":16:20)):
      "linalg.yield"(%arg18) : (f32) -> () loc(#loc17)
    }) : (tensor<8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc14)
    %11 = "linalg.generic"(%9, %10, %7) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg15: f32 loc("./pytorch/mlp.linalg.mlir":20:10), %arg16: f32 loc("./pytorch/mlp.linalg.mlir":20:20), %arg17: f32 loc("./pytorch/mlp.linalg.mlir":20:32)):
      %25 = "arith.addf"(%arg15, %arg16) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc22)
      "linalg.yield"(%25) : (f32) -> () loc(#loc23)
    }) : (tensor<1x8xf32>, tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc18)
    %12 = "linalg.generic"(%11, %7) <{indexing_maps = [#map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg13: f32 loc("./pytorch/mlp.linalg.mlir":25:10), %arg14: f32 loc("./pytorch/mlp.linalg.mlir":25:20)):
      %23 = "arith.cmpf"(%arg13, %0) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1 loc(#loc27)
      %24 = "arith.select"(%23, %arg13, %0) : (i1, f32, f32) -> f32 loc(#loc28)
      "linalg.yield"(%24) : (f32) -> () loc(#loc29)
    }) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32> loc(#loc24)
    %13 = "tensor.empty"() : () -> tensor<8x2xf32> loc(#loc30)
    %14 = "linalg.transpose"(%2, %13) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg11: f32 loc("./pytorch/mlp.linalg.mlir":7:14), %arg12: f32 loc("./pytorch/mlp.linalg.mlir":30:10)):
      "linalg.yield"(%arg11) : (f32) -> () loc(#loc31)
    }) : (tensor<2x8xf32>, tensor<8x2xf32>) -> tensor<8x2xf32> loc(#loc31)
    %15 = "tensor.empty"() : () -> tensor<1x2xf32> loc(#loc32)
    %16 = "linalg.fill"(%0, %15) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32 loc(unknown), %arg10: f32 loc(unknown)):
      "linalg.yield"(%arg9) : (f32) -> () loc(#loc12)
    }) : (f32, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc33)
    %17 = "linalg.matmul"(%12, %14, %16) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32 loc(unknown), %arg7: f32 loc(unknown), %arg8: f32 loc(unknown)):
      %21 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc12)
      %22 = "arith.addf"(%arg8, %21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc12)
      "linalg.yield"(%22) : (f32) -> () loc(#loc12)
    }) : (tensor<1x8xf32>, tensor<8x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc34)
    %18 = "linalg.generic"(%1, %15) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg4: f32 loc("./pytorch/mlp.linalg.mlir":36:10), %arg5: f32 loc("./pytorch/mlp.linalg.mlir":36:20)):
      "linalg.yield"(%arg4) : (f32) -> () loc(#loc38)
    }) : (tensor<2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc35)
    %19 = "linalg.generic"(%17, %18, %15) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg1: f32 loc("./pytorch/mlp.linalg.mlir":40:10), %arg2: f32 loc("./pytorch/mlp.linalg.mlir":40:20), %arg3: f32 loc("./pytorch/mlp.linalg.mlir":40:32)):
      %20 = "arith.addf"(%arg1, %arg2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc43)
      "linalg.yield"(%20) : (f32) -> () loc(#loc44)
    }) : (tensor<1x2xf32>, tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32> loc(#loc39)
    "func.return"(%19) : (tensor<1x2xf32>) -> () loc(#loc45)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/mlp.linalg.mlir":3:1)
#loc1 = loc("./pytorch/mlp.linalg.mlir":4:3)
#loc3 = loc("./pytorch/mlp.linalg.mlir":5:12)
#loc4 = loc("./pytorch/mlp.linalg.mlir":6:14)
#loc6 = loc("./pytorch/mlp.linalg.mlir":8:14)
#loc9 = loc("./pytorch/mlp.linalg.mlir":11:19)
#loc10 = loc("./pytorch/mlp.linalg.mlir":12:10)
#loc11 = loc("./pytorch/mlp.linalg.mlir":13:10)
#loc13 = loc("./pytorch/mlp.linalg.mlir":14:10)
#loc14 = loc("./pytorch/mlp.linalg.mlir":15:10)
#loc17 = loc("./pytorch/mlp.linalg.mlir":17:7)
#loc18 = loc("./pytorch/mlp.linalg.mlir":19:10)
#loc22 = loc("./pytorch/mlp.linalg.mlir":21:13)
#loc23 = loc("./pytorch/mlp.linalg.mlir":22:7)
#loc24 = loc("./pytorch/mlp.linalg.mlir":24:10)
#loc27 = loc("./pytorch/mlp.linalg.mlir":26:13)
#loc28 = loc("./pytorch/mlp.linalg.mlir":27:13)
#loc29 = loc("./pytorch/mlp.linalg.mlir":28:7)
#loc31 = loc("./pytorch/mlp.linalg.mlir":31:21)
#loc32 = loc("./pytorch/mlp.linalg.mlir":32:10)
#loc33 = loc("./pytorch/mlp.linalg.mlir":33:10)
#loc34 = loc("./pytorch/mlp.linalg.mlir":34:11)
#loc35 = loc("./pytorch/mlp.linalg.mlir":35:11)
#loc38 = loc("./pytorch/mlp.linalg.mlir":37:7)
#loc39 = loc("./pytorch/mlp.linalg.mlir":39:11)
#loc43 = loc("./pytorch/mlp.linalg.mlir":41:13)
#loc44 = loc("./pytorch/mlp.linalg.mlir":42:7)
#loc45 = loc("./pytorch/mlp.linalg.mlir":44:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E"
    }
  }
#-}

