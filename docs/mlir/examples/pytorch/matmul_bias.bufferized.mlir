#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d1)>
module {
  func.func @matmul_bias(%arg0: memref<2x3xf32>, %arg1: memref<3x4xf32>, %arg2: memref<4xf32>) -> memref<2x4xf32> attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    linalg.fill ins(%cst : f32) outs(%alloc : memref<2x4xf32>)
    linalg.matmul ins(%arg0, %arg1 : memref<2x3xf32>, memref<3x4xf32>) outs(%alloc : memref<2x4xf32>)
    linalg.generic {indexing_maps = [#map, #map1, #map], iterator_types = ["parallel", "parallel"]} ins(%alloc, %arg2 : memref<2x4xf32>, memref<4xf32>) outs(%alloc : memref<2x4xf32>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %0 = arith.addf %in, %in_0 : f32
      linalg.yield %0 : f32
    }
    return %alloc : memref<2x4xf32>
  }
}
