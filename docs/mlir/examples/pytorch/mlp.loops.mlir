module {
  memref.global "private" constant @__constant_8x4xf32 : memref<8x4xf32> = dense_resource<torch_tensor_8_4_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_8xf32 : memref<8xf32> = dense_resource<torch_tensor_8_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_2x8xf32 : memref<2x8xf32> = dense_resource<torch_tensor_2_8_torch.float32> {alignment = 64 : i64}
  memref.global "private" constant @__constant_2xf32 : memref<2xf32> = dense_resource<torch_tensor_2_torch.float32> {alignment = 64 : i64}
  func.func @mlp(%arg0: memref<1x4xf32>) -> memref<1x2xf32> attributes {llvm.emit_c_interface} {
    %c2 = arith.constant 2 : index
    %c8 = arith.constant 8 : index
    %c1 = arith.constant 1 : index
    %c4 = arith.constant 4 : index
    %c0 = arith.constant 0 : index
    %cst = arith.constant 0.000000e+00 : f32
    %0 = memref.get_global @__constant_2xf32 : memref<2xf32>
    %1 = memref.get_global @__constant_2x8xf32 : memref<2x8xf32>
    %2 = memref.get_global @__constant_8xf32 : memref<8xf32>
    %3 = memref.get_global @__constant_8x4xf32 : memref<8x4xf32>
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<4x8xf32>
    scf.for %arg1 = %c0 to %c4 step %c1 {
      scf.for %arg2 = %c0 to %c8 step %c1 {
        %4 = memref.load %3[%arg2, %arg1] : memref<8x4xf32>
        memref.store %4, %alloc[%arg1, %arg2] : memref<4x8xf32>
      }
    }
    %alloc_0 = memref.alloc() {alignment = 64 : i64} : memref<1x8xf32>
    %alloc_1 = memref.alloc() {alignment = 64 : i64} : memref<1x8xf32>
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c8 step %c1 {
        memref.store %cst, %alloc_1[%arg1, %arg2] : memref<1x8xf32>
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c8 step %c1 {
        scf.for %arg3 = %c0 to %c4 step %c1 {
          %4 = memref.load %arg0[%arg1, %arg3] : memref<1x4xf32>
          %5 = memref.load %alloc[%arg3, %arg2] : memref<4x8xf32>
          %6 = memref.load %alloc_1[%arg1, %arg2] : memref<1x8xf32>
          %7 = arith.mulf %4, %5 : f32
          %8 = arith.addf %6, %7 : f32
          memref.store %8, %alloc_1[%arg1, %arg2] : memref<1x8xf32>
        }
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c8 step %c1 {
        %4 = memref.load %2[%arg2] : memref<8xf32>
        memref.store %4, %alloc_0[%arg1, %arg2] : memref<1x8xf32>
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c8 step %c1 {
        %4 = memref.load %alloc_1[%arg1, %arg2] : memref<1x8xf32>
        %5 = memref.load %alloc_0[%arg1, %arg2] : memref<1x8xf32>
        %6 = arith.addf %4, %5 : f32
        memref.store %6, %alloc_0[%arg1, %arg2] : memref<1x8xf32>
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c8 step %c1 {
        %4 = memref.load %alloc_0[%arg1, %arg2] : memref<1x8xf32>
        %5 = arith.cmpf ugt, %4, %cst : f32
        %6 = arith.select %5, %4, %cst : f32
        memref.store %6, %alloc_0[%arg1, %arg2] : memref<1x8xf32>
      }
    }
    %alloc_2 = memref.alloc() {alignment = 64 : i64} : memref<8x2xf32>
    scf.for %arg1 = %c0 to %c8 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        %4 = memref.load %1[%arg2, %arg1] : memref<2x8xf32>
        memref.store %4, %alloc_2[%arg1, %arg2] : memref<8x2xf32>
      }
    }
    %alloc_3 = memref.alloc() {alignment = 64 : i64} : memref<1x2xf32>
    %alloc_4 = memref.alloc() {alignment = 64 : i64} : memref<1x2xf32>
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        memref.store %cst, %alloc_4[%arg1, %arg2] : memref<1x2xf32>
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        scf.for %arg3 = %c0 to %c8 step %c1 {
          %4 = memref.load %alloc_0[%arg1, %arg3] : memref<1x8xf32>
          %5 = memref.load %alloc_2[%arg3, %arg2] : memref<8x2xf32>
          %6 = memref.load %alloc_4[%arg1, %arg2] : memref<1x2xf32>
          %7 = arith.mulf %4, %5 : f32
          %8 = arith.addf %6, %7 : f32
          memref.store %8, %alloc_4[%arg1, %arg2] : memref<1x2xf32>
        }
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        %4 = memref.load %0[%arg2] : memref<2xf32>
        memref.store %4, %alloc_3[%arg1, %arg2] : memref<1x2xf32>
      }
    }
    scf.for %arg1 = %c0 to %c1 step %c1 {
      scf.for %arg2 = %c0 to %c2 step %c1 {
        %4 = memref.load %alloc_4[%arg1, %arg2] : memref<1x2xf32>
        %5 = memref.load %alloc_3[%arg1, %arg2] : memref<1x2xf32>
        %6 = arith.addf %4, %5 : f32
        memref.store %6, %alloc_3[%arg1, %arg2] : memref<1x2xf32>
      }
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
