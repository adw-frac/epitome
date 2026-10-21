#loc2 = loc("./pytorch/conv2d.raw.mlir":2:21)
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[1,1,5,5],f32>) -> !torch.vtensor<[1,2,5,5],f32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: !torch.vtensor<[1,1,5,5],f32> loc("./pytorch/conv2d.raw.mlir":2:21)):
    %0 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>}> : () -> !torch.vtensor<[2,1,3,3],f32> loc(#loc3)
    %1 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32> loc(#loc4)
    %2 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc5)
    %3 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc6)
    %4 = "torch.prim.ListConstruct"(%2, %3) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc7)
    %5 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc8)
    %6 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc9)
    %7 = "torch.prim.ListConstruct"(%5, %6) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc10)
    %8 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc11)
    %9 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc12)
    %10 = "torch.prim.ListConstruct"(%8, %9) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc13)
    %11 = "torch.constant.bool"() <{value = false}> : () -> !torch.bool loc(#loc14)
    %12 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int loc(#loc15)
    %13 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int loc(#loc16)
    %14 = "torch.prim.ListConstruct"(%12, %13) : (!torch.int, !torch.int) -> !torch.list<int> loc(#loc17)
    %15 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc18)
    %16 = "torch.aten.convolution"(%arg0, %0, %1, %4, %7, %10, %11, %14, %15) : (!torch.vtensor<[1,1,5,5],f32>, !torch.vtensor<[2,1,3,3],f32>, !torch.vtensor<[2],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.bool, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,2,5,5],f32> loc(#loc19)
    "func.return"(%16) : (!torch.vtensor<[1,2,5,5],f32>) -> () loc(#loc20)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/conv2d.raw.mlir":1:1)
#loc1 = loc("./pytorch/conv2d.raw.mlir":2:3)
#loc3 = loc("./pytorch/conv2d.raw.mlir":3:10)
#loc4 = loc("./pytorch/conv2d.raw.mlir":4:10)
#loc5 = loc("./pytorch/conv2d.raw.mlir":5:13)
#loc6 = loc("./pytorch/conv2d.raw.mlir":6:15)
#loc7 = loc("./pytorch/conv2d.raw.mlir":7:10)
#loc8 = loc("./pytorch/conv2d.raw.mlir":8:15)
#loc9 = loc("./pytorch/conv2d.raw.mlir":9:15)
#loc10 = loc("./pytorch/conv2d.raw.mlir":10:10)
#loc11 = loc("./pytorch/conv2d.raw.mlir":11:15)
#loc12 = loc("./pytorch/conv2d.raw.mlir":12:15)
#loc13 = loc("./pytorch/conv2d.raw.mlir":13:10)
#loc14 = loc("./pytorch/conv2d.raw.mlir":14:14)
#loc15 = loc("./pytorch/conv2d.raw.mlir":15:13)
#loc16 = loc("./pytorch/conv2d.raw.mlir":16:15)
#loc17 = loc("./pytorch/conv2d.raw.mlir":17:10)
#loc18 = loc("./pytorch/conv2d.raw.mlir":18:15)
#loc19 = loc("./pytorch/conv2d.raw.mlir":19:10)
#loc20 = loc("./pytorch/conv2d.raw.mlir":20:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}

