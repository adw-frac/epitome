module {
  func.func @mlp(%arg0: tensor<1x4xf32>) -> tensor<1x2xf32> {
    %0 = "tosa.const"() <{values = dense<0.000000e+00> : tensor<1xf32>}> : () -> tensor<1xf32>
    %1 = tosa.const_shape  {values = dense<[1, 1, 4]> : tensor<3xindex>} : () -> !tosa.shape<3>
    %2 = tosa.const_shape  {values = dense<[1, 8]> : tensor<2xindex>} : () -> !tosa.shape<2>
    %3 = tosa.const_shape  {values = dense<[1, 1, 8]> : tensor<3xindex>} : () -> !tosa.shape<3>
    %4 = tosa.const_shape  {values = dense<[1, 2]> : tensor<2xindex>} : () -> !tosa.shape<2>
    %5 = "tosa.const"() <{values = dense<[[[-3.743410e-03, -0.192577183, -0.0443720222, -0.477674246, 0.197667599, 0.181608558, -0.0805916786, -0.31476897], [0.268221796, 0.134078681, 0.132306278, -0.331141055, 0.300011396, 0.415193975, 0.0529070497, -0.126582623], [-0.411522567, -0.00990658998, -0.151106536, -0.20611155, -0.338970542, -0.102900088, 0.452738106, -0.194899976], [-0.367969513, 0.396444738, -0.0982826948, 0.0185217857, -0.217731416, 0.374155879, -0.46383518, 0.432000399]]]> : tensor<1x4x8xf32>}> : () -> tensor<1x4x8xf32>
    %6 = "tosa.const"() <{values = dense_resource<torch_tensor_8_torch.float32> : tensor<1x8xf32>}> : () -> tensor<1x8xf32>
    %7 = "tosa.const"() <{values = dense<[[[0.0185939241, -0.156799167], [-0.181260988, -0.0127570499], [0.0598158166, 0.226118848], [-0.330110937, 0.351479113], [-0.255465746, 0.140319034], [-0.182267368, 0.0477625355], [0.223070249, 0.237052709], [0.20729585, -0.208173066]]]> : tensor<1x8x2xf32>}> : () -> tensor<1x8x2xf32>
    %8 = "tosa.const"() <{values = dense_resource<torch_tensor_2_torch.float32> : tensor<1x2xf32>}> : () -> tensor<1x2xf32>
    %9 = tosa.reshape %arg0, %1 : (tensor<1x4xf32>, !tosa.shape<3>) -> tensor<1x1x4xf32>
    %10 = tosa.matmul %9, %5, %0, %0 : (tensor<1x1x4xf32>, tensor<1x4x8xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x1x8xf32>
    %11 = tosa.reshape %10, %2 : (tensor<1x1x8xf32>, !tosa.shape<2>) -> tensor<1x8xf32>
    %12 = tosa.add %11, %6 : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32>
    %13 = tosa.clamp %12 {max_val = 3.40282347E+38 : f32, min_val = 0.000000e+00 : f32} : (tensor<1x8xf32>) -> tensor<1x8xf32>
    %14 = tosa.reshape %13, %3 : (tensor<1x8xf32>, !tosa.shape<3>) -> tensor<1x1x8xf32>
    %15 = tosa.matmul %14, %7, %0, %0 : (tensor<1x1x8xf32>, tensor<1x8x2xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x1x2xf32>
    %16 = tosa.reshape %15, %4 : (tensor<1x1x2xf32>, !tosa.shape<2>) -> tensor<1x2xf32>
    %17 = tosa.add %16, %8 : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32>
    return %17 : tensor<1x2xf32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE"
    }
  }
#-}
