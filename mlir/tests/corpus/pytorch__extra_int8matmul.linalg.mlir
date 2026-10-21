#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<32x8xi8>, tensor<8x8xi8>) -> tensor<32x8xi32>, sym_name = "int8matmul"}> ({
  ^bb0(%arg0: tensor<32x8xi8>, %arg1: tensor<8x8xi8>):
    %0 = "arith.constant"() <{value = 0 : i32}> : () -> i32
    %1 = "tensor.empty"() : () -> tensor<32x8xi32>
    %2 = "linalg.fill"(%0, %1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%arg5: i32, %arg6: i32):
      "linalg.yield"(%arg5) : (i32) -> ()
    }) : (i32, tensor<32x8xi32>) -> tensor<32x8xi32>
    %3 = "linalg.matmul"(%arg0, %arg1, %2) <{indexing_maps = [#map, #map1, #map2], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%arg2: i8, %arg3: i8, %arg4: i32):
      %4 = "arith.extsi"(%arg2) : (i8) -> i32
      %5 = "arith.extsi"(%arg3) : (i8) -> i32
      %6 = "arith.muli"(%4, %5) <{overflowFlags = #arith.overflow<none>}> : (i32, i32) -> i32
      %7 = "arith.addi"(%arg4, %6) <{overflowFlags = #arith.overflow<none>}> : (i32, i32) -> i32
      "linalg.yield"(%7) : (i32) -> ()
    }) : (tensor<32x8xi8>, tensor<8x8xi8>, tensor<32x8xi32>) -> tensor<32x8xi32>
    "func.return"(%3) : (tensor<32x8xi32>) -> ()
  }) : () -> ()
}) : () -> ()

