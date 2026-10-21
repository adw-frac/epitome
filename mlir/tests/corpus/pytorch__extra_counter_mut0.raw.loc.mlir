#loc2 = loc("./pytorch/extra_counter_mut0.raw.mlir":2:22)
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[3],f32>) -> (!torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>), sym_name = "counter"}> ({
  ^bb0(%arg0: !torch.vtensor<[3],f32> loc("./pytorch/extra_counter_mut0.raw.mlir":2:22)):
    %0 = "torch.vtensor.literal"() <{value = dense<0.000000e+00> : tensor<1xf32>}> : () -> !torch.vtensor<[1],f32> loc(#loc3)
    %1 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc4)
    %2 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int loc(#loc5)
    %3 = "torch.aten.add.Scalar"(%0, %1, %2) : (!torch.vtensor<[1],f32>, !torch.int, !torch.int) -> !torch.vtensor<[1],f32> loc(#loc6)
    %4 = "torch.aten.mul.Tensor"(%arg0, %3) : (!torch.vtensor<[3],f32>, !torch.vtensor<[1],f32>) -> !torch.vtensor<[3],f32> loc(#loc7)
    "func.return"(%3, %4) : (!torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>) -> () loc(#loc8)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/extra_counter_mut0.raw.mlir":1:1)
#loc1 = loc("./pytorch/extra_counter_mut0.raw.mlir":2:3)
#loc3 = loc("./pytorch/extra_counter_mut0.raw.mlir":3:10)
#loc4 = loc("./pytorch/extra_counter_mut0.raw.mlir":4:13)
#loc5 = loc("./pytorch/extra_counter_mut0.raw.mlir":5:15)
#loc6 = loc("./pytorch/extra_counter_mut0.raw.mlir":6:10)
#loc7 = loc("./pytorch/extra_counter_mut0.raw.mlir":7:10)
#loc8 = loc("./pytorch/extra_counter_mut0.raw.mlir":8:5)

