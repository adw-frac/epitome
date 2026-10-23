module {
  func.func @conv2d(%arg0: tensor<1x1x5x5xf32>) -> tensor<1x2x5x5xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %cst_0 = arith.constant dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>
    %cst_1 = arith.constant dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>
    %padded = tensor.pad %arg0 low[0, 0, 1, 1] high[0, 0, 1, 1] {
    ^bb0(%arg1: index, %arg2: index, %arg3: index, %arg4: index):
      tensor.yield %cst : f32
    } : tensor<1x1x5x5xf32> to tensor<1x1x7x7xf32>
    %0 = tensor.empty() : tensor<1x2x5x5xf32>
    %broadcasted = linalg.broadcast ins(%cst_1 : tensor<2xf32>) outs(%0 : tensor<1x2x5x5xf32>) dimensions = [0, 2, 3] 
    %1 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%padded, %cst_0 : tensor<1x1x7x7xf32>, tensor<2x1x3x3xf32>) outs(%broadcasted : tensor<1x2x5x5xf32>) -> tensor<1x2x5x5xf32>
    return %1 : tensor<1x2x5x5xf32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}
