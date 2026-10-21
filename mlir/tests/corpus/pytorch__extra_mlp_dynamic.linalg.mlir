#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1)>
#map4 = affine_map<(d0, d1) -> (d0, d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<?x4xf32>) -> tensor<?x2xf32>, sym_name = "mlp_dyn"}> ({
  ^bb0(%arg0: tensor<?x4xf32>):
    %0 = "arith.constant"() <{value = true}> : () -> i1
    %1 = "arith.constant"() <{value = 0 : i64}> : () -> i64
    %2 = "arith.constant"() <{value = 0 : index}> : () -> index
    %3 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %4 = "arith.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32>
    %5 = "arith.constant"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> tensor<2x8xf32>
    %6 = "arith.constant"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> tensor<8xf32>
    %7 = "arith.constant"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> tensor<8x4xf32>
    %8 = "tensor.dim"(%arg0, %2) : (tensor<?x4xf32>, index) -> index
    %9 = "arith.index_cast"(%8) : (index) -> i64
    %10 = "tensor.empty"() : () -> tensor<4x8xf32>
    %11 = "linalg.transpose"(%7, %10) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg25: f32, %arg26: f32):
      "linalg.yield"(%arg25) : (f32) -> ()
    }) : (tensor<8x4xf32>, tensor<4x8xf32>) -> tensor<4x8xf32>
    %12 = "tensor.empty"(%8) : (index) -> tensor<?x8xf32>
    %13 = "linalg.fill"(%3, %12) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg23: f32, %arg24: f32):
      "linalg.yield"(%arg23) : (f32) -> ()
    }) : (f32, tensor<?x8xf32>) -> tensor<?x8xf32>
    %14 = "linalg.matmul"(%arg0, %11, %13) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg20: f32, %arg21: f32, %arg22: f32):
      %34 = "arith.mulf"(%arg20, %arg21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %35 = "arith.addf"(%arg22, %34) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%35) : (f32) -> ()
    }) : (tensor<?x4xf32>, tensor<4x8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32>
    %15 = "arith.cmpi"(%9, %1) <{predicate = 5 : i64}> : (i64, i64) -> i1
    "cf.assert"(%15) <{msg = "negative values not allowed in new dimensions"}> : (i1) -> ()
    %16 = "tensor.empty"(%8) : (index) -> tensor<?x8xf32>
    %17 = "linalg.generic"(%6, %16) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg18: f32, %arg19: f32):
      "linalg.yield"(%arg18) : (f32) -> ()
    }) : (tensor<8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32>
    "cf.assert"(%0) <{msg = "mismatched size for broadcast"}> : (i1) -> ()
    %18 = "linalg.generic"(%14, %17, %12) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg15: f32, %arg16: f32, %arg17: f32):
      %33 = "arith.addf"(%arg15, %arg16) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%33) : (f32) -> ()
    }) : (tensor<?x8xf32>, tensor<?x8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32>
    %19 = "linalg.generic"(%18, %12) <{indexing_maps = [#map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg13: f32, %arg14: f32):
      %31 = "arith.cmpf"(%arg13, %3) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1
      %32 = "arith.select"(%31, %arg13, %3) : (i1, f32, f32) -> f32
      "linalg.yield"(%32) : (f32) -> ()
    }) : (tensor<?x8xf32>, tensor<?x8xf32>) -> tensor<?x8xf32>
    %20 = "tensor.empty"() : () -> tensor<8x2xf32>
    %21 = "linalg.transpose"(%5, %20) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg11: f32, %arg12: f32):
      "linalg.yield"(%arg11) : (f32) -> ()
    }) : (tensor<2x8xf32>, tensor<8x2xf32>) -> tensor<8x2xf32>
    %22 = "tensor.empty"(%8) : (index) -> tensor<?x2xf32>
    %23 = "linalg.fill"(%3, %22) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32, %arg10: f32):
      "linalg.yield"(%arg9) : (f32) -> ()
    }) : (f32, tensor<?x2xf32>) -> tensor<?x2xf32>
    %24 = "linalg.matmul"(%19, %21, %23) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32, %arg7: f32, %arg8: f32):
      %29 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      %30 = "arith.addf"(%arg8, %29) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%30) : (f32) -> ()
    }) : (tensor<?x8xf32>, tensor<8x2xf32>, tensor<?x2xf32>) -> tensor<?x2xf32>
    "cf.assert"(%15) <{msg = "negative values not allowed in new dimensions"}> : (i1) -> ()
    %25 = "tensor.empty"(%8) : (index) -> tensor<?x2xf32>
    %26 = "linalg.generic"(%4, %25) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg4: f32, %arg5: f32):
      "linalg.yield"(%arg4) : (f32) -> ()
    }) : (tensor<2xf32>, tensor<?x2xf32>) -> tensor<?x2xf32>
    "cf.assert"(%0) <{msg = "mismatched size for broadcast"}> : (i1) -> ()
    %27 = "linalg.generic"(%24, %26, %22) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg1: f32, %arg2: f32, %arg3: f32):
      %28 = "arith.addf"(%arg1, %arg2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
      "linalg.yield"(%28) : (f32) -> ()
    }) : (tensor<?x2xf32>, tensor<?x2xf32>, tensor<?x2xf32>) -> tensor<?x2xf32>
    "func.return"(%27) : (tensor<?x2xf32>) -> ()
  }) : () -> ()
}) : () -> ()

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

