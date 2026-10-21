module {
  memref.global "private" constant @__constant_2xf32 : memref<2xf32> = dense_resource<torch_tensor_2_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_2x1x3x3xf32 : memref<2x1x3x3xf32> = dense_resource<torch_tensor_2_1_3_3_torch.float32> {alignment = 64 : i64}
  func.func @conv2d(%arg0: memref<1x1x5x5xf32>) -> memref<1x2x5x5xf32> attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = memref.get_global @__constant_2x1x3x3xf32 : memref<2x1x3x3xf32>
    %1 = memref.get_global @__constant_2xf32 : memref<2xf32>
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<1x1x7x7xf32>
    linalg.map outs(%alloc : memref<1x1x7x7xf32>)
      (%init: f32) {
        linalg.yield %cst : f32
      }
    %subview = memref.subview %alloc[0, 0, 1, 1] [1, 1, 5, 5] [1, 1, 1, 1] : memref<1x1x7x7xf32> to memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>
    memref.copy %arg0, %subview : memref<1x1x5x5xf32> to memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>
    %alloc_0 = memref.alloc() {alignment = 64 : i64} : memref<1x2x5x5xf32>
    linalg.broadcast ins(%1 : memref<2xf32>) outs(%alloc_0 : memref<1x2x5x5xf32>) dimensions = [0, 2, 3] 
    linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%alloc, %0 : memref<1x1x7x7xf32>, memref<2x1x3x3xf32>) outs(%alloc_0 : memref<1x2x5x5xf32>)
    return %alloc_0 : memref<1x2x5x5xf32>
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE",
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE"
    }
  }
#-}
