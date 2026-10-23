#loc2 = loc("./pytorch/extra_int8matmul.torch.mlir":2:25)
#loc3 = loc("./pytorch/extra_int8matmul.torch.mlir":2:60)
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[32,8],si8>, !torch.vtensor<[8,8],si8>) -> !torch.vtensor<[32,8],si32>, sym_name = "int8matmul"}> ({
  ^bb0(%arg0: !torch.vtensor<[32,8],si8> loc("./pytorch/extra_int8matmul.torch.mlir":2:25), %arg1: !torch.vtensor<[8,8],si8> loc("./pytorch/extra_int8matmul.torch.mlir":2:60)):
    %0 = "torch.aten.mm"(%arg0, %arg1) : (!torch.vtensor<[32,8],si8>, !torch.vtensor<[8,8],si8>) -> !torch.vtensor<[32,8],si32> loc(#loc4)
    "func.return"(%0) : (!torch.vtensor<[32,8],si32>) -> () loc(#loc5)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/extra_int8matmul.torch.mlir":1:1)
#loc1 = loc("./pytorch/extra_int8matmul.torch.mlir":2:3)
#loc4 = loc("./pytorch/extra_int8matmul.torch.mlir":3:10)
#loc5 = loc("./pytorch/extra_int8matmul.torch.mlir":4:5)

