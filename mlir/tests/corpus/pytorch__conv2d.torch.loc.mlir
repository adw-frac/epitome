#loc2 = loc("./pytorch/conv2d.torch.mlir":2:21)
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[1,1,5,5],f32>) -> !torch.vtensor<[1,2,5,5],f32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: !torch.vtensor<[1,1,5,5],f32> loc("./pytorch/conv2d.torch.mlir":2:21)):
    %0 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int loc(#loc3)
    %1 = "torch.constant.bool"() <{value = false}> : () -> !torch.bool loc(#loc4)
    %2 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>}> : () -> !torch.vtensor<[2,1,3,3],f32> loc(#loc5)
    %3 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32> loc(#loc6)
    %4 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc7)
    %5 = "torch.prim.ListConstruct"(%4, %4) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc8)
    %6 = "torch.prim.ListConstruct"(%4, %4) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc9)
    %7 = "torch.prim.ListConstruct"(%4, %4) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc10)
    %8 = "torch.prim.ListConstruct"(%0, %0) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc11)
    %9 = "torch.aten.convolution"(%arg0, %2, %3, %5, %6, %7, %1, %8, %4) : (!torch.vtensor<[1,1,5,5],f32>, !torch.vtensor<[2,1,3,3],f32>, !torch.vtensor<[2],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.bool, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,2,5,5],f32> loc(#loc12)
    "func.return"(%9) : (!torch.vtensor<[1,2,5,5],f32>) -> () loc(#loc13)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/conv2d.torch.mlir":1:1)
#loc1 = loc("./pytorch/conv2d.torch.mlir":2:3)
#loc3 = loc("./pytorch/conv2d.torch.mlir":3:13)
#loc4 = loc("./pytorch/conv2d.torch.mlir":4:14)
#loc5 = loc("./pytorch/conv2d.torch.mlir":5:10)
#loc6 = loc("./pytorch/conv2d.torch.mlir":6:10)
#loc7 = loc("./pytorch/conv2d.torch.mlir":7:13)
#loc8 = loc("./pytorch/conv2d.torch.mlir":8:10)
#loc9 = loc("./pytorch/conv2d.torch.mlir":9:10)
#loc10 = loc("./pytorch/conv2d.torch.mlir":10:10)
#loc11 = loc("./pytorch/conv2d.torch.mlir":11:10)
#loc12 = loc("./pytorch/conv2d.torch.mlir":12:10)
#loc13 = loc("./pytorch/conv2d.torch.mlir":13:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}

