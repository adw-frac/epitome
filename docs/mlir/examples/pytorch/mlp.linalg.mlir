#map = affine_map<(d0, d1) -> (d1)>
#map1 = affine_map<(d0, d1) -> (d0, d1)>
module {
  func.func @mlp(%arg0: tensor<1x4xf32>) -> tensor<1x2xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %cst_0 = arith.constant dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>
    %cst_1 = arith.constant dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>
    %cst_2 = arith.constant dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>
    %cst_3 = arith.constant dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>
    %0 = tensor.empty() : tensor<4x8xf32>
    %transposed = linalg.transpose ins(%cst_3 : tensor<8x4xf32>) outs(%0 : tensor<4x8xf32>) permutation = [1, 0] 
    %1 = tensor.empty() : tensor<1x8xf32>
    %2 = linalg.fill ins(%cst : f32) outs(%1 : tensor<1x8xf32>) -> tensor<1x8xf32>
    %3 = linalg.matmul ins(%arg0, %transposed : tensor<1x4xf32>, tensor<4x8xf32>) outs(%2 : tensor<1x8xf32>) -> tensor<1x8xf32>
    %4 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%cst_2 : tensor<8xf32>) outs(%1 : tensor<1x8xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    } -> tensor<1x8xf32>
    %5 = linalg.generic {indexing_maps = [#map1, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%3, %4 : tensor<1x8xf32>, tensor<1x8xf32>) outs(%1 : tensor<1x8xf32>) {
    ^bb0(%in: f32, %in_5: f32, %out: f32):
      %13 = arith.addf %in, %in_5 : f32
      linalg.yield %13 : f32
    } -> tensor<1x8xf32>
    %6 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%5 : tensor<1x8xf32>) outs(%1 : tensor<1x8xf32>) {
    ^bb0(%in: f32, %out: f32):
      %13 = arith.cmpf ugt, %in, %cst : f32
      %14 = arith.select %13, %in, %cst : f32
      linalg.yield %14 : f32
    } -> tensor<1x8xf32>
    %7 = tensor.empty() : tensor<8x2xf32>
    %transposed_4 = linalg.transpose ins(%cst_1 : tensor<2x8xf32>) outs(%7 : tensor<8x2xf32>) permutation = [1, 0] 
    %8 = tensor.empty() : tensor<1x2xf32>
    %9 = linalg.fill ins(%cst : f32) outs(%8 : tensor<1x2xf32>) -> tensor<1x2xf32>
    %10 = linalg.matmul ins(%6, %transposed_4 : tensor<1x8xf32>, tensor<8x2xf32>) outs(%9 : tensor<1x2xf32>) -> tensor<1x2xf32>
    %11 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%cst_0 : tensor<2xf32>) outs(%8 : tensor<1x2xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    } -> tensor<1x2xf32>
    %12 = linalg.generic {indexing_maps = [#map1, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%10, %11 : tensor<1x2xf32>, tensor<1x2xf32>) outs(%8 : tensor<1x2xf32>) {
    ^bb0(%in: f32, %in_5: f32, %out: f32):
      %13 = arith.addf %in, %in_5 : f32
      linalg.yield %13 : f32
    } -> tensor<1x2xf32>
    return %12 : tensor<1x2xf32>
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
