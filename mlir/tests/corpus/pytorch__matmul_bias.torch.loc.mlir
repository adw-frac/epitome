#loc2 = loc("./pytorch/matmul_bias.torch.mlir":2:26)
#loc3 = loc("./pytorch/matmul_bias.torch.mlir":2:60)
#loc4 = loc("./pytorch/matmul_bias.torch.mlir":2:94)
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32>, !torch.vtensor<[4],f32>) -> !torch.vtensor<[2,4],f32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: !torch.vtensor<[2,3],f32> loc("./pytorch/matmul_bias.torch.mlir":2:26), %arg1: !torch.vtensor<[3,4],f32> loc("./pytorch/matmul_bias.torch.mlir":2:60), %arg2: !torch.vtensor<[4],f32> loc("./pytorch/matmul_bias.torch.mlir":2:94)):
    %0 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc5)
    %1 = "torch.aten.mm"(%arg0, %arg1) : (!torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32>) -> !torch.vtensor<[2,4],f32> loc(#loc6)
    %2 = "torch.aten.add.Tensor"(%1, %arg2, %0) : (!torch.vtensor<[2,4],f32>, !torch.vtensor<[4],f32>, !torch.int) -> !torch.vtensor<[2,4],f32> loc(#loc7)
    "func.return"(%2) : (!torch.vtensor<[2,4],f32>) -> () loc(#loc8)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/matmul_bias.torch.mlir":1:1)
#loc1 = loc("./pytorch/matmul_bias.torch.mlir":2:3)
#loc5 = loc("./pytorch/matmul_bias.torch.mlir":3:13)
#loc6 = loc("./pytorch/matmul_bias.torch.mlir":4:10)
#loc7 = loc("./pytorch/matmul_bias.torch.mlir":5:10)
#loc8 = loc("./pytorch/matmul_bias.torch.mlir":6:5)

