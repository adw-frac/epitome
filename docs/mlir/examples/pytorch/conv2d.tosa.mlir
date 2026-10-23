module {
  func.func @conv2d(%arg0: tensor<1x1x5x5xf32>) -> tensor<1x2x5x5xf32> {
    %0 = "tosa.const"() <{values = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32>
    %1 = "tosa.const"() <{values = dense<0.000000e+00> : tensor<1xf32>}> : () -> tensor<1xf32>
    %2 = tosa.const_shape  {values = dense<[1, 5, 5, 1]> : tensor<4xindex>} : () -> !tosa.shape<4>
    %3 = "tosa.const"() <{values = dense<[[[[-0.136510104], [0.19779253], [-0.202846378]], [[0.302456707], [0.228433296], [-0.281094313]], [[-0.0829614401], [0.0150408745], [0.0486336946]]], [[[0.0790580958], [0.130809426], [0.0199667215]], [[-0.162642926], [0.15772967], [-0.319749653]], [[-0.197568893], [-0.083443284], [-0.162371129]]]]> : tensor<2x3x3x1xf32>}> : () -> tensor<2x3x3x1xf32>
    %4 = tosa.reshape %arg0, %2 : (tensor<1x1x5x5xf32>, !tosa.shape<4>) -> tensor<1x5x5x1xf32>
    %5 = tosa.conv2d %4, %3, %0, %1, %1 {acc_type = f32, dilation = array<i64: 1, 1>, pad = array<i64: 1, 1, 1, 1>, stride = array<i64: 1, 1>} : (tensor<1x5x5x1xf32>, tensor<2x3x3x1xf32>, tensor<2xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x5x5x2xf32>
    %6 = tosa.transpose %5 {perms = array<i32: 0, 3, 1, 2>} : (tensor<1x5x5x2xf32>) -> tensor<1x2x5x5xf32>
    return %6 : tensor<1x2x5x5xf32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}
