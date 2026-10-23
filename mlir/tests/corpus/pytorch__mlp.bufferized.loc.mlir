#loc6 = loc("./pytorch/mlp.bufferized.mlir":8:18)
#loc9 = loc("./pytorch/mlp.bufferized.mlir":11:10)
#loc11 = loc("./pytorch/mlp.bufferized.mlir":13:10)
#loc12 = loc("./pytorch/mlp.bufferized.mlir":14:14)
#loc17 = loc(unknown)
#loc20 = loc("./pytorch/mlp.bufferized.mlir":21:10)
#loc21 = loc("./pytorch/mlp.bufferized.mlir":21:20)
#loc24 = loc("./pytorch/mlp.bufferized.mlir":25:10)
#loc25 = loc("./pytorch/mlp.bufferized.mlir":25:20)
#loc26 = loc("./pytorch/mlp.bufferized.mlir":25:32)
#loc30 = loc("./pytorch/mlp.bufferized.mlir":30:10)
#loc31 = loc("./pytorch/mlp.bufferized.mlir":30:20)
#loc35 = loc("./pytorch/mlp.bufferized.mlir":35:16)
#loc42 = loc("./pytorch/mlp.bufferized.mlir":42:10)
#loc43 = loc("./pytorch/mlp.bufferized.mlir":42:20)
#loc46 = loc("./pytorch/mlp.bufferized.mlir":46:10)
#loc47 = loc("./pytorch/mlp.bufferized.mlir":46:20)
#loc48 = loc("./pytorch/mlp.bufferized.mlir":46:32)
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1)>
#map4 = affine_map<(d0, d1) -> (d0, d1)>
"builtin.module"() ({
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>, sym_name = "__constant_8x4xf32", sym_visibility = "private", type = memref<8x4xf32>}> : () -> () loc(#loc1)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>, sym_name = "__constant_8xf32", sym_visibility = "private", type = memref<8xf32>}> : () -> () loc(#loc2)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>, sym_name = "__constant_2x8xf32", sym_visibility = "private", type = memref<2x8xf32>}> : () -> () loc(#loc3)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>, sym_name = "__constant_2xf32", sym_visibility = "private", type = memref<2xf32>}> : () -> () loc(#loc4)
  "func.func"() <{function_type = (memref<1x4xf32>) -> memref<1x2xf32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: memref<1x4xf32> loc("./pytorch/mlp.bufferized.mlir":8:18)):
    %0 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc7)
    %1 = "memref.get_global"() <{name = @__constant_2xf32}> : () -> memref<2xf32> loc(#loc8)
    %2 = "memref.get_global"() <{name = @__constant_2x8xf32}> : () -> memref<2x8xf32> loc(#loc9)
    %3 = "memref.get_global"() <{name = @__constant_8xf32}> : () -> memref<8xf32> loc(#loc10)
    %4 = "memref.get_global"() <{name = @__constant_8x4xf32}> : () -> memref<8x4xf32> loc(#loc11)
    %5 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<4x8xf32> loc(#loc12)
    "linalg.transpose"(%4, %5) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg25: f32 loc("./pytorch/mlp.bufferized.mlir":13:10), %arg26: f32 loc("./pytorch/mlp.bufferized.mlir":14:14)):
      "linalg.yield"(%arg25) : (f32) -> () loc(#loc13)
    }) : (memref<8x4xf32>, memref<4x8xf32>) -> () loc(#loc13)
    %6 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x8xf32> loc(#loc14)
    %7 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x8xf32> loc(#loc15)
    "linalg.fill"(%0, %7) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg23: f32 loc(unknown), %arg24: f32 loc(unknown)):
      "linalg.yield"(%arg23) : (f32) -> () loc(#loc17)
    }) : (f32, memref<1x8xf32>) -> () loc(#loc16)
    "linalg.matmul"(%arg0, %5, %7) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg20: f32 loc(unknown), %arg21: f32 loc(unknown), %arg22: f32 loc(unknown)):
      %17 = "arith.mulf"(%arg20, %arg21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      %18 = "arith.addf"(%arg22, %17) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      "linalg.yield"(%18) : (f32) -> () loc(#loc17)
    }) : (memref<1x4xf32>, memref<4x8xf32>, memref<1x8xf32>) -> () loc(#loc18)
    "linalg.generic"(%3, %6) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg18: f32 loc("./pytorch/mlp.bufferized.mlir":21:10), %arg19: f32 loc("./pytorch/mlp.bufferized.mlir":21:20)):
      "linalg.yield"(%arg18) : (f32) -> () loc(#loc22)
    }) : (memref<8xf32>, memref<1x8xf32>) -> () loc(#loc19)
    "linalg.generic"(%7, %6, %6) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg15: f32 loc("./pytorch/mlp.bufferized.mlir":25:10), %arg16: f32 loc("./pytorch/mlp.bufferized.mlir":25:20), %arg17: f32 loc("./pytorch/mlp.bufferized.mlir":25:32)):
      %16 = "arith.addf"(%arg15, %arg16) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc27)
      "linalg.yield"(%16) : (f32) -> () loc(#loc28)
    }) : (memref<1x8xf32>, memref<1x8xf32>, memref<1x8xf32>) -> () loc(#loc23)
    "linalg.generic"(%6, %6) <{indexing_maps = [#map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg13: f32 loc("./pytorch/mlp.bufferized.mlir":30:10), %arg14: f32 loc("./pytorch/mlp.bufferized.mlir":30:20)):
      %14 = "arith.cmpf"(%arg13, %0) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1 loc(#loc32)
      %15 = "arith.select"(%14, %arg13, %0) : (i1, f32, f32) -> f32 loc(#loc33)
      "linalg.yield"(%15) : (f32) -> () loc(#loc34)
    }) : (memref<1x8xf32>, memref<1x8xf32>) -> () loc(#loc29)
    %8 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<8x2xf32> loc(#loc35)
    "linalg.transpose"(%2, %8) <{permutation = array<i64: 1, 0>}> ({
    ^bb0(%arg11: f32 loc("./pytorch/mlp.bufferized.mlir":11:10), %arg12: f32 loc("./pytorch/mlp.bufferized.mlir":35:16)):
      "linalg.yield"(%arg11) : (f32) -> () loc(#loc36)
    }) : (memref<2x8xf32>, memref<8x2xf32>) -> () loc(#loc36)
    %9 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2xf32> loc(#loc37)
    %10 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2xf32> loc(#loc38)
    "linalg.fill"(%0, %10) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg9: f32 loc(unknown), %arg10: f32 loc(unknown)):
      "linalg.yield"(%arg9) : (f32) -> () loc(#loc17)
    }) : (f32, memref<1x2xf32>) -> () loc(#loc39)
    "linalg.matmul"(%6, %8, %10) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg6: f32 loc(unknown), %arg7: f32 loc(unknown), %arg8: f32 loc(unknown)):
      %12 = "arith.mulf"(%arg6, %arg7) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      %13 = "arith.addf"(%arg8, %12) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc17)
      "linalg.yield"(%13) : (f32) -> () loc(#loc17)
    }) : (memref<1x8xf32>, memref<8x2xf32>, memref<1x2xf32>) -> () loc(#loc40)
    "linalg.generic"(%1, %9) <{indexing_maps = [#map3, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg4: f32 loc("./pytorch/mlp.bufferized.mlir":42:10), %arg5: f32 loc("./pytorch/mlp.bufferized.mlir":42:20)):
      "linalg.yield"(%arg4) : (f32) -> () loc(#loc44)
    }) : (memref<2xf32>, memref<1x2xf32>) -> () loc(#loc41)
    "linalg.generic"(%10, %9, %9) <{indexing_maps = [#map4, #map4, #map4], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg1: f32 loc("./pytorch/mlp.bufferized.mlir":46:10), %arg2: f32 loc("./pytorch/mlp.bufferized.mlir":46:20), %arg3: f32 loc("./pytorch/mlp.bufferized.mlir":46:32)):
      %11 = "arith.addf"(%arg1, %arg2) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc49)
      "linalg.yield"(%11) : (f32) -> () loc(#loc50)
    }) : (memref<1x2xf32>, memref<1x2xf32>, memref<1x2xf32>) -> () loc(#loc45)
    "func.return"(%9) : (memref<1x2xf32>) -> () loc(#loc51)
  }) {llvm.emit_c_interface} : () -> () loc(#loc5)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/mlp.bufferized.mlir":3:1)
#loc1 = loc("./pytorch/mlp.bufferized.mlir":4:3)
#loc2 = loc("./pytorch/mlp.bufferized.mlir":5:3)
#loc3 = loc("./pytorch/mlp.bufferized.mlir":6:3)
#loc4 = loc("./pytorch/mlp.bufferized.mlir":7:3)
#loc5 = loc("./pytorch/mlp.bufferized.mlir":8:3)
#loc7 = loc("./pytorch/mlp.bufferized.mlir":9:12)
#loc8 = loc("./pytorch/mlp.bufferized.mlir":10:10)
#loc10 = loc("./pytorch/mlp.bufferized.mlir":12:10)
#loc13 = loc("./pytorch/mlp.bufferized.mlir":15:5)
#loc14 = loc("./pytorch/mlp.bufferized.mlir":16:16)
#loc15 = loc("./pytorch/mlp.bufferized.mlir":17:16)
#loc16 = loc("./pytorch/mlp.bufferized.mlir":18:5)
#loc18 = loc("./pytorch/mlp.bufferized.mlir":19:5)
#loc19 = loc("./pytorch/mlp.bufferized.mlir":20:5)
#loc22 = loc("./pytorch/mlp.bufferized.mlir":22:7)
#loc23 = loc("./pytorch/mlp.bufferized.mlir":24:5)
#loc27 = loc("./pytorch/mlp.bufferized.mlir":26:12)
#loc28 = loc("./pytorch/mlp.bufferized.mlir":27:7)
#loc29 = loc("./pytorch/mlp.bufferized.mlir":29:5)
#loc32 = loc("./pytorch/mlp.bufferized.mlir":31:12)
#loc33 = loc("./pytorch/mlp.bufferized.mlir":32:12)
#loc34 = loc("./pytorch/mlp.bufferized.mlir":33:7)
#loc36 = loc("./pytorch/mlp.bufferized.mlir":36:5)
#loc37 = loc("./pytorch/mlp.bufferized.mlir":37:16)
#loc38 = loc("./pytorch/mlp.bufferized.mlir":38:16)
#loc39 = loc("./pytorch/mlp.bufferized.mlir":39:5)
#loc40 = loc("./pytorch/mlp.bufferized.mlir":40:5)
#loc41 = loc("./pytorch/mlp.bufferized.mlir":41:5)
#loc44 = loc("./pytorch/mlp.bufferized.mlir":43:7)
#loc45 = loc("./pytorch/mlp.bufferized.mlir":45:5)
#loc49 = loc("./pytorch/mlp.bufferized.mlir":47:12)
#loc50 = loc("./pytorch/mlp.bufferized.mlir":48:7)
#loc51 = loc("./pytorch/mlp.bufferized.mlir":50:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE"
    }
  }
#-}

