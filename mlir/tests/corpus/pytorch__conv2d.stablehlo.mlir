"builtin.module"() ({
  "func.func"() <{function_type = (tensor<1x1x5x5xf32>) -> tensor<1x2x5x5xf32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: tensor<1x1x5x5xf32>):
    %0 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>}> : () -> tensor<2x1x3x3xf32>
    %1 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32>
    %2 = "stablehlo.convolution"(%arg0, %0) <{batch_group_count = 1 : i64, dimension_numbers = #stablehlo.conv<[b, f, 0, 1]x[o, i, 0, 1]->[b, f, 0, 1]>, feature_group_count = 1 : i64, padding = dense<1> : tensor<2x2xi64>, rhs_dilation = array<i64: 1, 1>, window_strides = array<i64: 1, 1>}> : (tensor<1x1x5x5xf32>, tensor<2x1x3x3xf32>) -> tensor<1x2x5x5xf32>
    %3 = "stablehlo.reshape"(%1) : (tensor<2xf32>) -> tensor<2x1x1xf32>
    %4 = "stablehlo.broadcast_in_dim"(%3) <{broadcast_dimensions = array<i64: 1, 2, 3>}> : (tensor<2x1x1xf32>) -> tensor<1x2x5x5xf32>
    %5 = "stablehlo.add"(%2, %4) : (tensor<1x2x5x5xf32>, tensor<1x2x5x5xf32>) -> tensor<1x2x5x5xf32>
    "func.return"(%5) : (tensor<1x2x5x5xf32>) -> ()
  }) : () -> ()
}) : () -> ()

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}

