"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[3],f32>) -> (!torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>), sym_name = "counter"}> ({
  ^bb0(%arg0: !torch.vtensor<[3],f32>):
    %0 = "torch.vtensor.literal"() <{value = dense<0.000000e+00> : tensor<1xf32>}> : () -> !torch.vtensor<[1],f32>
    %1 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %2 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %3 = "torch.aten.add.Scalar"(%0, %1, %2) : (!torch.vtensor<[1],f32>, !torch.int, !torch.int) -> !torch.vtensor<[1],f32>
    %4 = "torch.aten.mul.Tensor"(%arg0, %3) : (!torch.vtensor<[3],f32>, !torch.vtensor<[1],f32>) -> !torch.vtensor<[3],f32>
    "func.return"(%3, %4) : (!torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>) -> ()
  }) : () -> ()
}) : () -> ()

