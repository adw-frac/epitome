module {
  func.func @matmul_bias(%arg0: memref<2x3xf32>, %arg1: memref<3x4xf32>, %arg2: memref<4xf32>) -> memref<2x4xf32> attributes {llvm.emit_c_interface} {
    %c3 = arith.constant 3 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    %cst = arith.constant 0.000000e+00 : f32
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    scf.for %arg3 = %c0 to %c2 step %c1 {
      scf.for %arg4 = %c0 to %c4 step %c1 {
        memref.store %cst, %alloc[%arg3, %arg4] : memref<2x4xf32>
      }
    }
    scf.for %arg3 = %c0 to %c2 step %c1 {
      scf.for %arg4 = %c0 to %c4 step %c1 {
        scf.for %arg5 = %c0 to %c3 step %c1 {
          %0 = memref.load %arg0[%arg3, %arg5] : memref<2x3xf32>
          %1 = memref.load %arg1[%arg5, %arg4] : memref<3x4xf32>
          %2 = memref.load %alloc[%arg3, %arg4] : memref<2x4xf32>
          %3 = arith.mulf %0, %1 : f32
          %4 = arith.addf %2, %3 : f32
          memref.store %4, %alloc[%arg3, %arg4] : memref<2x4xf32>
        }
      }
    }
    scf.for %arg3 = %c0 to %c2 step %c1 {
      scf.for %arg4 = %c0 to %c4 step %c1 {
        %0 = memref.load %alloc[%arg3, %arg4] : memref<2x4xf32>
        %1 = memref.load %arg2[%arg4] : memref<4xf32>
        %2 = arith.addf %0, %1 : f32
        memref.store %2, %alloc[%arg3, %arg4] : memref<2x4xf32>
      }
    }
    return %alloc : memref<2x4xf32>
  }
}
