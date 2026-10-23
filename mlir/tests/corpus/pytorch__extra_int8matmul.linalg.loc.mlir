#loc2 = loc("./pytorch/extra_int8matmul.linalg.mlir":2:25)
#loc3 = loc("./pytorch/extra_int8matmul.linalg.mlir":2:49)
#loc7 = loc(unknown)
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<32x8xi8>, tensor<8x8xi8>) -> tensor<32x8xi32>, sym_name = "int8matmul"}> ({
  ^bb0(%arg0: tensor<32x8xi8> loc("./pytorch/extra_int8matmul.linalg.mlir":2:25), %arg1: tensor<8x8xi8> loc("./pytorch/extra_int8matmul.linalg.mlir":2:49)):
    %0 = "arith.constant"() <{value = 0 : i32}> : () -> i32 loc(#loc4)
    %1 = "tensor.empty"() : () -> tensor<32x8xi32> loc(#loc5)
    %2 = "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg5: i32 loc(unknown), %arg6: i32 loc(unknown)):
      "linalg.yield"(%arg5) : (i32) -> () loc(#loc7)
    }) : (i32, tensor<32x8xi32>) -> tensor<32x8xi32> loc(#loc6)
    %3 = "linalg.matmul"(%arg0, %arg1, %2) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg2: i8 loc(unknown), %arg3: i8 loc(unknown), %arg4: i32 loc(unknown)):
      %4 = "arith.extsi"(%arg2) : (i8) -> i32 loc(#loc7)
      %5 = "arith.extsi"(%arg3) : (i8) -> i32 loc(#loc7)
      %6 = "arith.muli"(%4, %5) <{overflowFlags = #arith.overflow<none>}> : (i32, i32) -> i32 loc(#loc7)
      %7 = "arith.addi"(%arg4, %6) <{overflowFlags = #arith.overflow<none>}> : (i32, i32) -> i32 loc(#loc7)
      "linalg.yield"(%7) : (i32) -> () loc(#loc7)
    }) : (tensor<32x8xi8>, tensor<8x8xi8>, tensor<32x8xi32>) -> tensor<32x8xi32> loc(#loc8)
    "func.return"(%3) : (tensor<32x8xi32>) -> () loc(#loc9)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/extra_int8matmul.linalg.mlir":1:1)
#loc1 = loc("./pytorch/extra_int8matmul.linalg.mlir":2:3)
#loc4 = loc("./pytorch/extra_int8matmul.linalg.mlir":3:15)
#loc5 = loc("./pytorch/extra_int8matmul.linalg.mlir":4:10)
#loc6 = loc("./pytorch/extra_int8matmul.linalg.mlir":5:10)
#loc8 = loc("./pytorch/extra_int8matmul.linalg.mlir":6:10)
#loc9 = loc("./pytorch/extra_int8matmul.linalg.mlir":7:5)

