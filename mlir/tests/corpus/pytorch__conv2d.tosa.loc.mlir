#loc2 = loc("./pytorch/conv2d.tosa.mlir":2:21)
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<1x1x5x5xf32>) -> tensor<1x2x5x5xf32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: tensor<1x1x5x5xf32> loc("./pytorch/conv2d.tosa.mlir":2:21)):
    %0 = "tosa.const"() <{values = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32> loc(#loc3)
    %1 = "tosa.const"() <{values = dense<0.000000e+00> : tensor<1xf32>}> : () -> tensor<1xf32> loc(#loc4)
    %2 = "tosa.const_shape"() <{values = dense<[1, 5, 5, 1]> : tensor<4xindex>}> : () -> !tosa.shape<4> loc(#loc5)
    %3 = "tosa.const"() <{values = dense<[[[[-0.136510104], [0.19779253], [-0.202846378]], [[0.302456707], [0.228433296], [-0.281094313]], [[-0.0829614401], [0.0150408745], [0.0486336946]]], [[[0.0790580958], [0.130809426], [0.0199667215]], [[-0.162642926], [0.15772967], [-0.319749653]], [[-0.197568893], [-0.083443284], [-0.162371129]]]]> : tensor<2x3x3x1xf32>}> : () -> tensor<2x3x3x1xf32> loc(#loc6)
    %4 = "tosa.reshape"(%arg0, %2) : (tensor<1x1x5x5xf32>, !tosa.shape<4>) -> tensor<1x5x5x1xf32> loc(#loc7)
    %5 = "tosa.conv2d"(%4, %3, %0, %1, %1) <{acc_type = f32, dilation = array<i64: 1, 1>, pad = array<i64: 1, 1, 1, 1>, stride = array<i64: 1, 1>}> : (tensor<1x5x5x1xf32>, tensor<2x3x3x1xf32>, tensor<2xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x5x5x2xf32> loc(#loc8)
    %6 = "tosa.transpose"(%5) <{perms = array<i32: 0, 3, 1, 2>}> : (tensor<1x5x5x2xf32>) -> tensor<1x2x5x5xf32> loc(#loc9)
    "func.return"(%6) : (tensor<1x2x5x5xf32>) -> () loc(#loc10)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/conv2d.tosa.mlir":1:1)
#loc1 = loc("./pytorch/conv2d.tosa.mlir":2:3)
#loc3 = loc("./pytorch/conv2d.tosa.mlir":3:10)
#loc4 = loc("./pytorch/conv2d.tosa.mlir":4:10)
#loc5 = loc("./pytorch/conv2d.tosa.mlir":5:10)
#loc6 = loc("./pytorch/conv2d.tosa.mlir":6:10)
#loc7 = loc("./pytorch/conv2d.tosa.mlir":7:10)
#loc8 = loc("./pytorch/conv2d.tosa.mlir":8:10)
#loc9 = loc("./pytorch/conv2d.tosa.mlir":9:10)
#loc10 = loc("./pytorch/conv2d.tosa.mlir":10:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}

