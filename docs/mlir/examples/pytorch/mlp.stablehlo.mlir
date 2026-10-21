module {
  func.func @mlp(%arg0: tensor<1x4xf32>) -> tensor<1x2xf32> {
    %cst = stablehlo.constant dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>
    %cst_0 = stablehlo.constant dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>
    %cst_1 = stablehlo.constant dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>
    %cst_2 = stablehlo.constant dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>
    %cst_3 = stablehlo.constant dense<0.000000e+00> : tensor<1x8xf32>
    %cst_4 = arith.constant dense<1> : tensor<1xi64>
    %0 = stablehlo.transpose %cst_2, dims = [1, 0] : (tensor<8x4xf32>) -> tensor<4x8xf32>
    %1 = stablehlo.dot_general %arg0, %0, contracting_dims = [1] x [0] : (tensor<1x4xf32>, tensor<4x8xf32>) -> tensor<1x8xf32>
    %2 = stablehlo.convert %cst_4 : (tensor<1xi64>) -> tensor<1xf32>
    %3 = stablehlo.reshape %2 : (tensor<1xf32>) -> tensor<f32>
    %4 = stablehlo.broadcast_in_dim %3, dims = [] : (tensor<f32>) -> tensor<1x8xf32>
    %5 = stablehlo.multiply %1, %4 : tensor<1x8xf32>
    %6 = stablehlo.broadcast_in_dim %cst_1, dims = [1] : (tensor<8xf32>) -> tensor<1x8xf32>
    %7 = stablehlo.multiply %6, %4 : tensor<1x8xf32>
    %8 = stablehlo.add %5, %7 : tensor<1x8xf32>
    %9 = stablehlo.maximum %8, %cst_3 : tensor<1x8xf32>
    %10 = stablehlo.transpose %cst_0, dims = [1, 0] : (tensor<2x8xf32>) -> tensor<8x2xf32>
    %11 = stablehlo.dot_general %9, %10, contracting_dims = [1] x [0] : (tensor<1x8xf32>, tensor<8x2xf32>) -> tensor<1x2xf32>
    %12 = stablehlo.broadcast_in_dim %3, dims = [] : (tensor<f32>) -> tensor<1x2xf32>
    %13 = stablehlo.multiply %11, %12 : tensor<1x2xf32>
    %14 = stablehlo.broadcast_in_dim %cst, dims = [1] : (tensor<2xf32>) -> tensor<1x2xf32>
    %15 = stablehlo.multiply %14, %12 : tensor<1x2xf32>
    %16 = stablehlo.add %13, %15 : tensor<1x2xf32>
    return %16 : tensor<1x2xf32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E"
    }
  }
#-}
