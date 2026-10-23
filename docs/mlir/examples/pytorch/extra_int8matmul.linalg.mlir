module {
  func.func @int8matmul(%arg0: tensor<32x8xi8>, %arg1: tensor<8x8xi8>) -> tensor<32x8xi32> {
    %c0_i32 = arith.constant 0 : i32
    %0 = tensor.empty() : tensor<32x8xi32>
    %1 = linalg.fill ins(%c0_i32 : i32) outs(%0 : tensor<32x8xi32>) -> tensor<32x8xi32>
    %2 = linalg.matmul ins(%arg0, %arg1 : tensor<32x8xi8>, tensor<8x8xi8>) outs(%1 : tensor<32x8xi32>) -> tensor<32x8xi32>
    return %2 : tensor<32x8xi32>
  }
}
