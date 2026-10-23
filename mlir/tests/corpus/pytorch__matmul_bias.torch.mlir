"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32>, !torch.vtensor<[4],f32>) -> !torch.vtensor<[2,4],f32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: !torch.vtensor<[2,3],f32>, %arg1: !torch.vtensor<[3,4],f32>, %arg2: !torch.vtensor<[4],f32>):
    %0 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %1 = "torch.aten.mm"(%arg0, %arg1) : (!torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32>) -> !torch.vtensor<[2,4],f32>
    %2 = "torch.aten.add.Tensor"(%1, %arg2, %0) : (!torch.vtensor<[2,4],f32>, !torch.vtensor<[4],f32>, !torch.int) -> !torch.vtensor<[2,4],f32>
    "func.return"(%2) : (!torch.vtensor<[2,4],f32>) -> ()
  }) : () -> ()
}) : () -> ()

