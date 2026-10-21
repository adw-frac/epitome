module {
  func.func @matmul_bias(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>, %arg2: tensor<4xf32>) -> tensor<2x4xf32> {
    %0 = "tosa.const"() <{values = dense<0.000000e+00> : tensor<1xf32>}> : () -> tensor<1xf32>
    %1 = tosa.const_shape  {values = dense<[1, 2, 3]> : tensor<3xindex>} : () -> !tosa.shape<3>
    %2 = tosa.const_shape  {values = dense<[1, 3, 4]> : tensor<3xindex>} : () -> !tosa.shape<3>
    %3 = tosa.const_shape  {values = dense<[2, 4]> : tensor<2xindex>} : () -> !tosa.shape<2>
    %4 = tosa.const_shape  {values = dense<[1, 4]> : tensor<2xindex>} : () -> !tosa.shape<2>
    %5 = tosa.reshape %arg0, %1 : (tensor<2x3xf32>, !tosa.shape<3>) -> tensor<1x2x3xf32>
    %6 = tosa.reshape %arg1, %2 : (tensor<3x4xf32>, !tosa.shape<3>) -> tensor<1x3x4xf32>
    %7 = tosa.matmul %5, %6, %0, %0 : (tensor<1x2x3xf32>, tensor<1x3x4xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x2x4xf32>
    %8 = tosa.reshape %7, %3 : (tensor<1x2x4xf32>, !tosa.shape<2>) -> tensor<2x4xf32>
    %9 = tosa.reshape %arg2, %4 : (tensor<4xf32>, !tosa.shape<2>) -> tensor<1x4xf32>
    %10 = tosa.add %8, %9 : (tensor<2x4xf32>, tensor<1x4xf32>) -> tensor<2x4xf32>
    return %10 : tensor<2x4xf32>
  }
}
