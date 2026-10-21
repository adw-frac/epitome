"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[32,8],si8>, !torch.vtensor<[8,8],si8>) -> !torch.vtensor<[32,8],si32>, sym_name = "int8matmul"}> ({
  ^bb0(%arg0: !torch.vtensor<[32,8],si8>, %arg1: !torch.vtensor<[8,8],si8>):
    %0 = "torch.aten.mm"(%arg0, %arg1) : (!torch.vtensor<[32,8],si8>, !torch.vtensor<[8,8],si8>) -> !torch.vtensor<[32,8],si32>
    "func.return"(%0) : (!torch.vtensor<[32,8],si32>) -> ()
  }) : () -> ()
}) : () -> ()

