#map = affine_map<(d0, d1) -> (d1)>
#map1 = affine_map<(d0, d1) -> (d0, d1)>
module {
  memref.global "private" constant @__constant_8x4xf32 : memref<8x4xf32> = dense_resource<torch_tensor_8_4_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_8xf32 : memref<8xf32> = dense_resource<torch_tensor_8_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_2x8xf32 : memref<2x8xf32> = dense_resource<torch_tensor_2_8_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_2xf32 : memref<2xf32> = dense_resource<torch_tensor_2_torch.float32> {alignment = 64 : i64}
  func.func @mlp(%arg0: memref<1x4xf32>) -> memref<1x2xf32> attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = memref.get_global @__constant_2xf32 : memref<2xf32>
    %1 = memref.get_global @__constant_2x8xf32 : memref<2x8xf32>
    %2 = memref.get_global @__constant_8xf32 : memref<8xf32>
    %3 = memref.get_global @__constant_8x4xf32 : memref<8x4xf32>
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<4x8xf32>
    linalg.transpose ins(%3 : memref<8x4xf32>) outs(%alloc : memref<4x8xf32>) permutation = [1, 0] 
    %alloc_0 = memref.alloc() {alignment = 64 : i64} : memref<1x8xf32>
    %alloc_1 = memref.alloc() {alignment = 64 : i64} : memref<1x8xf32>
    linalg.fill ins(%cst : f32) outs(%alloc_1 : memref<1x8xf32>)
    linalg.matmul ins(%arg0, %alloc : memref<1x4xf32>, memref<4x8xf32>) outs(%alloc_1 : memref<1x8xf32>)
    linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%2 : memref<8xf32>) outs(%alloc_0 : memref<1x8xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    }
    linalg.generic {indexing_maps = [#map1, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%alloc_1, %alloc_0 : memref<1x8xf32>, memref<1x8xf32>) outs(%alloc_0 : memref<1x8xf32>) {
    ^bb0(%in: f32, %in_5: f32, %out: f32):
      %4 = arith.addf %in, %in_5 : f32
      linalg.yield %4 : f32
    }
    linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%alloc_0 : memref<1x8xf32>) outs(%alloc_0 : memref<1x8xf32>) {
    ^bb0(%in: f32, %out: f32):
      %4 = arith.cmpf ugt, %in, %cst : f32
      %5 = arith.select %4, %in, %cst : f32
      linalg.yield %5 : f32
    }
    %alloc_2 = memref.alloc() {alignment = 64 : i64} : memref<8x2xf32>
    linalg.transpose ins(%1 : memref<2x8xf32>) outs(%alloc_2 : memref<8x2xf32>) permutation = [1, 0] 
    %alloc_3 = memref.alloc() {alignment = 64 : i64} : memref<1x2xf32>
    %alloc_4 = memref.alloc() {alignment = 64 : i64} : memref<1x2xf32>
    linalg.fill ins(%cst : f32) outs(%alloc_4 : memref<1x2xf32>)
    linalg.matmul ins(%alloc_0, %alloc_2 : memref<1x8xf32>, memref<8x2xf32>) outs(%alloc_4 : memref<1x2xf32>)
    linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%0 : memref<2xf32>) outs(%alloc_3 : memref<1x2xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    }
    linalg.generic {indexing_maps = [#map1, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%alloc_4, %alloc_3 : memref<1x2xf32>, memref<1x2xf32>) outs(%alloc_3 : memref<1x2xf32>) {
    ^bb0(%in: f32, %in_5: f32, %out: f32):
      %4 = arith.addf %in, %in_5 : f32
      linalg.yield %4 : f32
    }
    return %alloc_3 : memref<1x2xf32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE"
    }
  }
#-}
