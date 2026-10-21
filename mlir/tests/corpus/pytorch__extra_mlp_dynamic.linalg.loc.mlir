#loc2 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":4:22)
#loc8 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":10:14)
#loc10 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":12:14)
#loc13 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":15:10)
#loc17 = loc(unknown)
#loc23 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":24:10)
#loc24 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":24:20)
#loc28 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":29:10)
#loc29 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":29:20)
#loc30 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":29:32)
#loc34 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":34:10)
#loc35 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":34:20)
#loc39 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":39:11)
#loc47 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":47:10)
#loc48 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":47:20)
#loc52 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":52:10)
#loc53 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":52:20)
#loc54 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":52:32)
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1)>
#map4 = affine_map<(d0, d1) -> (d0, d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<?x4xf32>) -> tensor<?x2xf32>, sym_name = "mlp_dyn"}> ({
  ^bb0(%arg0: tensor<?x4xf32> loc("./pytorch/extra_mlp_dynamic.linalg.mlir":4:22)):
    %0 = "arith.constant"() <{value = true}> : () -> i1 loc(#loc3)
    %1 = "arith.constant"() <{value = 0 : i64}> : () -> i64 loc(#loc4)
    %2 = "arith.constant"() <{value = 0 : index}> : () -> index loc(#loc5)
    %3 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc6)
    %4 = "arith.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32> loc(#loc7)
    %5 = "arith.constant"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> tensor<2x8xf32> loc(#loc8)
    %6 = "arith.constant"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> tensor<8xf32> loc(#loc9)
    %7 = "arith.constant"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> tensor<8x4xf32> loc(#loc10)
    %8 = "tensor.dim"(%arg0, %2) : (tensor<?x4xf32>, index) -> index loc(#loc11)
    %9 = "arith.index_cast"(%8) : (index) -> i64 loc(#loc12)
    %10 = "tensor.empty"() : () -> tensor<4x8xf32> loc(#loc13)
    %11 = "linalg.transpose"(%7, %10) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg25: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":12:14), %arg26: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":15:10)):
      "linalg.yield"(%arg25) : (f32) -> () loc(#loc14)
    }) : (tensor<8x4xf32>, tensor<4x8xf32>) -> tensor<4x8xf32> loc(#loc14)
    %12 = "tensor.empty"(%8) : (index) -> tensor<?x8xf32> loc(#loc15)
    %13 = "linalg.fill"(%3, %12) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg23: f32 loc(unknown), %arg24: f32 loc(unknown)):
      "linalg.yield"(%arg23) : (f32) -> () loc(#loc17)
    }) : (f32, tensor<?x8xf32>) -> tensor<?x8xf32> loc(#loc16)
    %14 = "linalg.matmul"(%arg0, %11, %13) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg20: f32 loc(unknown), %arg21: f32 loc(unknown), %arg22: f32 loc(unknown)):
      %34 = "arith.mulf"(%arg20, %arg21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      %35 = "arith.addf"(%arg22, %34) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      "linalg.yield"(%35) : (f32) -> () loc(#loc17)
    }) : (tensor<?x4xf32>, tensor<4x8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32> loc(#loc18)
    %15 = "arith.cmpi"(%9, %1) <{predicate = 5 : i64}> : (i64, i64) -> i1 loc(#loc19)
    "cf.assert"(%15) <{msg = "negative values not allowed in new dimensions"}> : (i1) -> () loc(#loc20)
    %16 = "tensor.empty"(%8) : (index) -> tensor<?x8xf32> loc(#loc21)
    %17 = "linalg.generic"(%6, %16) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg18: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":24:10), %arg19: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":24:20)):
      "linalg.yield"(%arg18) : (f32) -> () loc(#loc25)
    }) : (tensor<8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32> loc(#loc22)
    "cf.assert"(%0) <{msg = "mismatched size for broadcast"}> : (i1) -> () loc(#loc26)
    %18 = "linalg.generic"(%14, %17, %12) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg15: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":29:10), %arg16: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":29:20), %arg17: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":29:32)):
      %33 = "arith.addf"(%arg15, %arg16) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc31)
      "linalg.yield"(%33) : (f32) -> () loc(#loc32)
    }) : (tensor<?x8xf32>, tensor<?x8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32> loc(#loc27)
    %19 = "linalg.generic"(%18, %12) <{indexing_maps = [#map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg13: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":34:10), %arg14: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":34:20)):
      %31 = "arith.cmpf"(%arg13, %3) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1 loc(#loc36)
      %32 = "arith.select"(%31, %arg13, %3) : (i1, f32, f32) -> f32 loc(#loc37)
      "linalg.yield"(%32) : (f32) -> () loc(#loc38)
    }) : (tensor<?x8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32> loc(#loc33)
    %20 = "tensor.empty"() : () -> tensor<8x2xf32> loc(#loc39)
    %21 = "linalg.transpose"(%5, %20) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg11: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":10:14), %arg12: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":39:11)):
      "linalg.yield"(%arg11) : (f32) -> () loc(#loc40)
    }) : (tensor<2x8xf32>, tensor<8x2xf32>) -> tensor<8x2xf32> loc(#loc40)
    %22 = "tensor.empty"(%8) : (index) -> tensor<?x2xf32> loc(#loc41)
    %23 = "linalg.fill"(%3, %22) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32 loc(unknown), %arg10: f32 loc(unknown)):
      "linalg.yield"(%arg9) : (f32) -> () loc(#loc17)
    }) : (f32, tensor<?x2xf32>) -> tensor<?x2xf32> loc(#loc42)
    %24 = "linalg.matmul"(%19, %21, %23) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32 loc(unknown), %arg7: f32 loc(unknown), %arg8: f32 loc(unknown)):
      %29 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      %30 = "arith.addf"(%arg8, %29) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      "linalg.yield"(%30) : (f32) -> () loc(#loc17)
    }) : (tensor<?x8xf32>, tensor<8x2xf32>, tensor<?x2xf32>) -> tensor<?x2xf32> loc(#loc43)
    "cf.assert"(%15) <{msg = "negative values not allowed in new dimensions"}> : (i1) -> () loc(#loc44)
    %25 = "tensor.empty"(%8) : (index) -> tensor<?x2xf32> loc(#loc45)
    %26 = "linalg.generic"(%4, %25) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg4: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":47:10), %arg5: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":47:20)):
      "linalg.yield"(%arg4) : (f32) -> () loc(#loc49)
    }) : (tensor<2xf32>, tensor<?x2xf32>) -> tensor<?x2xf32> loc(#loc46)
    "cf.assert"(%0) <{msg = "mismatched size for broadcast"}> : (i1) -> () loc(#loc50)
    %27 = "linalg.generic"(%24, %26, %22) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg1: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":52:10), %arg2: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":52:20), %arg3: f32 loc("./pytorch/extra_mlp_dynamic.linalg.mlir":52:32)):
      %28 = "arith.addf"(%arg1, %arg2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc55)
      "linalg.yield"(%28) : (f32) -> () loc(#loc56)
    }) : (tensor<?x2xf32>, tensor<?x2xf32>, tensor<?x2xf32>) -> tensor<?x2xf32> loc(#loc51)
    "func.return"(%27) : (tensor<?x2xf32>) -> () loc(#loc57)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":3:1)
#loc1 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":4:3)
#loc3 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":5:13)
#loc4 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":6:15)
#loc5 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":7:11)
#loc6 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":8:12)
#loc7 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":9:14)
#loc9 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":11:14)
#loc11 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":13:12)
#loc12 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":14:10)
#loc14 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":16:19)
#loc15 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":17:10)
#loc16 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":18:10)
#loc18 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":19:10)
#loc19 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":20:10)
#loc20 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":21:5)
#loc21 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":22:10)
#loc22 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":23:10)
#loc25 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":25:7)
#loc26 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":27:5)
#loc27 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":28:10)
#loc31 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":30:13)
#loc32 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":31:7)
#loc33 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":33:10)
#loc36 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":35:13)
#loc37 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":36:13)
#loc38 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":37:7)
#loc40 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":40:21)
#loc41 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":41:11)
#loc42 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":42:11)
#loc43 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":43:11)
#loc44 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":44:5)
#loc45 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":45:11)
#loc46 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":46:11)
#loc49 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":48:7)
#loc50 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":50:5)
#loc51 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":51:11)
#loc55 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":53:13)
#loc56 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":54:7)
#loc57 = loc("./pytorch/extra_mlp_dynamic.linalg.mlir":56:5)

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

