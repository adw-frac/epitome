#map = affine_map<(d0, d1) -> (d1)>
#map1 = affine_map<(d0, d1) -> (d0, d1)>
module {
  func.func @mlp_dyn(%arg0: tensor<?x4xf32>) -> tensor<?x2xf32> {
    %true = arith.constant true
    %c0_i64 = arith.constant 0 : i64
    %c0 = arith.constant 0 : index
    %cst = arith.constant 0.000000e+00 : f32
    %cst_0 = arith.constant dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>
    %cst_1 = arith.constant dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>
    %cst_2 = arith.constant dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>
    %cst_3 = arith.constant dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>
    %dim = tensor.dim %arg0, %c0 : tensor<?x4xf32>
    %0 = arith.index_cast %dim : index to i64
    %1 = tensor.empty() : tensor<4x8xf32>
    %transposed = linalg.transpose ins(%cst_3 : tensor<8x4xf32>) outs(%1 : tensor<4x8xf32>) permutation = [1, 0] 
    %2 = tensor.empty(%dim) : tensor<?x8xf32>
    %3 = linalg.fill ins(%cst : f32) outs(%2 : tensor<?x8xf32>) -> tensor<?x8xf32>
    %4 = linalg.matmul ins(%arg0, %transposed : tensor<?x4xf32>, tensor<4x8xf32>) outs(%3 : tensor<?x8xf32>) -> tensor<?x8xf32>
    %5 = arith.cmpi sge, %0, %c0_i64 : i64
    cf.assert %5, "negative values not allowed in new dimensions"
    %6 = tensor.empty(%dim) : tensor<?x8xf32>
    %7 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%cst_2 : tensor<8xf32>) outs(%6 : tensor<?x8xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    } -> tensor<?x8xf32>
    cf.assert %true, "mismatched size for broadcast"
    %8 = linalg.generic {indexing_maps = [#map1, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%4, %7 : tensor<?x8xf32>, tensor<?x8xf32>) outs(%2 : tensor<?x8xf32>) {
    ^bb0(%in: f32, %in_5: f32, %out: f32):
      %17 = arith.addf %in, %in_5 : f32
      linalg.yield %17 : f32
    } -> tensor<?x8xf32>
    %9 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%8 : tensor<?x8xf32>) outs(%2 : tensor<?x8xf32>) {
    ^bb0(%in: f32, %out: f32):
      %17 = arith.cmpf ugt, %in, %cst : f32
      %18 = arith.select %17, %in, %cst : f32
      linalg.yield %18 : f32
    } -> tensor<?x8xf32>
    %10 = tensor.empty() : tensor<8x2xf32>
    %transposed_4 = linalg.transpose ins(%cst_1 : tensor<2x8xf32>) outs(%10 : tensor<8x2xf32>) permutation = [1, 0] 
    %11 = tensor.empty(%dim) : tensor<?x2xf32>
    %12 = linalg.fill ins(%cst : f32) outs(%11 : tensor<?x2xf32>) -> tensor<?x2xf32>
    %13 = linalg.matmul ins(%9, %transposed_4 : tensor<?x8xf32>, tensor<8x2xf32>) outs(%12 : tensor<?x2xf32>) -> tensor<?x2xf32>
    cf.assert %5, "negative values not allowed in new dimensions"
    %14 = tensor.empty(%dim) : tensor<?x2xf32>
    %15 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%cst_0 : tensor<2xf32>) outs(%14 : tensor<?x2xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    } -> tensor<?x2xf32>
    cf.assert %true, "mismatched size for broadcast"
    %16 = linalg.generic {indexing_maps = [#map1, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%13, %15 : tensor<?x2xf32>, tensor<?x2xf32>) outs(%11 : tensor<?x2xf32>) {
    ^bb0(%in: f32, %in_5: f32, %out: f32):
      %17 = arith.addf %in, %in_5 : f32
      linalg.yield %17 : f32
    } -> tensor<?x2xf32>
    return %16 : tensor<?x2xf32>
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
