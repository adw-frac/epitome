"builtin.module"() ({
  "func.func"() <{function_type = (memref<2x3xf32>, memref<3x4xf32>, memref<4xf32>) -> memref<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: memref<2x3xf32>, %arg1: memref<3x4xf32>, %arg2: memref<4xf32>):
    %0 = "arith.constant"() <{value = 3 : index}> : () -> index
    %1 = "arith.constant"() <{value = 4 : index}> : () -> index
    %2 = "arith.constant"() <{value = 1 : index}> : () -> index
    %3 = "arith.constant"() <{value = 2 : index}> : () -> index
    %4 = "arith.constant"() <{value = 0 : index}> : () -> index
    %5 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %6 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<2x4xf32>
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg8: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg9: index):
        "memref.store"(%5, %6, %arg8, %arg9) : (f32, memref<2x4xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg5: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg6: index):
        "scf.for"(%4, %0, %2) ({
        ^bb0(%arg7: index):
          %10 = "memref.load"(%arg0, %arg5, %arg7) : (memref<2x3xf32>, index, index) -> f32
          %11 = "memref.load"(%arg1, %arg7, %arg6) : (memref<3x4xf32>, index, index) -> f32
          %12 = "memref.load"(%6, %arg5, %arg6) : (memref<2x4xf32>, index, index) -> f32
          %13 = "arith.mulf"(%10, %11) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
          %14 = "arith.addf"(%12, %13) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
          "memref.store"(%14, %6, %arg5, %arg6) : (f32, memref<2x4xf32>, index, index) -> ()
          "scf.yield"() : () -> ()
        }) : (index, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg3: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg4: index):
        %7 = "memref.load"(%6, %arg3, %arg4) : (memref<2x4xf32>, index, index) -> f32
        %8 = "memref.load"(%arg2, %arg4) : (memref<4xf32>, index) -> f32
        %9 = "arith.addf"(%7, %8) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
        "memref.store"(%9, %6, %arg3, %arg4) : (f32, memref<2x4xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "func.return"(%6) : (memref<2x4xf32>) -> ()
  }) {llvm.emit_c_interface} : () -> ()
}) : () -> ()

