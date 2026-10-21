#map = affine_map<(d0, d1) -> (d0 + d1)>
module {
  memref.global "private" constant @__constant_2xf32 : memref<2xf32> = dense_resource<torch_tensor_2_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_2x1x3x3xf32 : memref<2x1x3x3xf32> = dense_resource<torch_tensor_2_1_3_3_torch.float32> {alignment = 64 : i64}
  func.func @conv2d(%arg0: memref<1x1x5x5xf32>) -> memref<1x2x5x5xf32> attributes {llvm.emit_c_interface} {
    %c3 = arith.constant 3 : index
    %c5 = arith.constant 5 : index
    %c2 = arith.constant 2 : index
    %c7 = arith.constant 7 : index
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %cst = arith.constant 0.000000e+00 : f32
    %0 = memref.get_global @__constant_2x1x3x3xf32 : memref<2x1x3x3xf32>
    %1 = memref.get_global @__constant_2xf32 : memref<2xf32>
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<1x1x7x7xf32>
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c1 step %c1 {
        scf.for %arg3 = %c0 to %c7 step %c1 {
          scf.for %arg4 = %c0 to %c7 step %c1 {
            memref.store %cst, %alloc[%arg1, %arg2, %arg3, %arg4] : memref<1x1x7x7xf32>
          }
        }
      }
    }
    %subview = memref.subview %alloc[0, 0, 1, 1] [1, 1, 5, 5] [1, 1, 1, 1] : memref<1x1x7x7xf32> to memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>
    memref.copy %arg0, %subview : memref<1x1x5x5xf32> to memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>
    %alloc_0 = memref.alloc() {alignment = 64 : i64} : memref<1x2x5x5xf32>
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        scf.for %arg3 = %c0 to %c5 step %c1 {
          scf.for %arg4 = %c0 to %c5 step %c1 {
            %2 = memref.load %1[%arg2] : memref<2xf32>
            memref.store %2, %alloc_0[%arg1, %arg2, %arg3, %arg4] : memref<1x2x5x5xf32>
          }
        }
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        scf.for %arg3 = %c0 to %c5 step %c1 {
          scf.for %arg4 = %c0 to %c5 step %c1 {
            scf.for %arg5 = %c0 to %c1 step %c1 {
              scf.for %arg6 = %c0 to %c3 step %c1 {
                scf.for %arg7 = %c0 to %c3 step %c1 {
                  %2 = affine.apply #map(%arg3, %arg6)
                  %3 = affine.apply #map(%arg4, %arg7)
                  %4 = memref.load %alloc[%arg1, %arg5, %2, %3] : memref<1x1x7x7xf32>
                  %5 = memref.load %0[%arg2, %arg5, %arg6, %arg7] : memref<2x1x3x3xf32>
                  %6 = memref.load %alloc_0[%arg1, %arg2, %arg3, %arg4] : memref<1x2x5x5xf32>
                  %7 = arith.mulf %4, %5 : f32
                  %8 = arith.addf %6, %7 : f32
                  memref.store %8, %alloc_0[%arg1, %arg2, %arg3, %arg4] : memref<1x2x5x5xf32>
                }
              }
            }
          }
        }
      }
    }
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
