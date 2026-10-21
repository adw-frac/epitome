#loc2 = loc("./pytorch/matmul_bias.loops.mlir":2:26)
#loc3 = loc("./pytorch/matmul_bias.loops.mlir":2:50)
#loc4 = loc("./pytorch/matmul_bias.loops.mlir":2:74)
#loc13 = loc("./pytorch/matmul_bias.loops.mlir":10:13)
#loc15 = loc("./pytorch/matmul_bias.loops.mlir":11:15)
#loc18 = loc("./pytorch/matmul_bias.loops.mlir":15:13)
#loc20 = loc("./pytorch/matmul_bias.loops.mlir":16:15)
#loc22 = loc("./pytorch/matmul_bias.loops.mlir":17:17)
#loc30 = loc("./pytorch/matmul_bias.loops.mlir":27:13)
#loc32 = loc("./pytorch/matmul_bias.loops.mlir":28:15)
"builtin.module"() ({
  "func.func"() <{function_type = (memref<2x3xf32>, memref<3x4xf32>, memref<4xf32>) -> memref<2x4xf32>, sym_name = "matmul_bias"}> ({
  ^bb0(%arg0: memref<2x3xf32> loc("./pytorch/matmul_bias.loops.mlir":2:26), %arg1: memref<3x4xf32> loc("./pytorch/matmul_bias.loops.mlir":2:50), %arg2: memref<4xf32> loc("./pytorch/matmul_bias.loops.mlir":2:74)):
    %0 = "arith.constant"() <{value = 3 : index}> : () -> index loc(#loc5)
    %1 = "arith.constant"() <{value = 4 : index}> : () -> index loc(#loc6)
    %2 = "arith.constant"() <{value = 1 : index}> : () -> index loc(#loc7)
    %3 = "arith.constant"() <{value = 2 : index}> : () -> index loc(#loc8)
    %4 = "arith.constant"() <{value = 0 : index}> : () -> index loc(#loc9)
    %5 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc10)
    %6 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<2x4xf32> loc(#loc11)
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg8: index loc("./pytorch/matmul_bias.loops.mlir":10:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg9: index loc("./pytorch/matmul_bias.loops.mlir":11:15)):
        "memref.store"(%5, %6, %arg8, %arg9) : (f32, memref<2x4xf32>, index, index) -> () loc(#loc16)
        "scf.yield"() : () -> () loc(#loc14)
      }) : (index, index, index) -> () loc(#loc14)
      "scf.yield"() : () -> () loc(#loc12)
    }) : (index, index, index) -> () loc(#loc12)
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg5: index loc("./pytorch/matmul_bias.loops.mlir":15:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg6: index loc("./pytorch/matmul_bias.loops.mlir":16:15)):
        "scf.for"(%4, %0, %2) ({
        ^bb0(%arg7: index loc("./pytorch/matmul_bias.loops.mlir":17:17)):
          %10 = "memref.load"(%arg0, %arg5, %arg7) : (memref<2x3xf32>, index, index) -> f32 loc(#loc23)
          %11 = "memref.load"(%arg1, %arg7, %arg6) : (memref<3x4xf32>, index, index) -> f32 loc(#loc24)
          %12 = "memref.load"(%6, %arg5, %arg6) : (memref<2x4xf32>, index, index) -> f32 loc(#loc25)
          %13 = "arith.mulf"(%10, %11) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc26)
          %14 = "arith.addf"(%12, %13) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc27)
          "memref.store"(%14, %6, %arg5, %arg6) : (f32, memref<2x4xf32>, index, index) -> () loc(#loc28)
          "scf.yield"() : () -> () loc(#loc21)
        }) : (index, index, index) -> () loc(#loc21)
        "scf.yield"() : () -> () loc(#loc19)
      }) : (index, index, index) -> () loc(#loc19)
      "scf.yield"() : () -> () loc(#loc17)
    }) : (index, index, index) -> () loc(#loc17)
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg3: index loc("./pytorch/matmul_bias.loops.mlir":27:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg4: index loc("./pytorch/matmul_bias.loops.mlir":28:15)):
        %7 = "memref.load"(%6, %arg3, %arg4) : (memref<2x4xf32>, index, index) -> f32 loc(#loc33)
        %8 = "memref.load"(%arg2, %arg4) : (memref<4xf32>, index) -> f32 loc(#loc34)
        %9 = "arith.addf"(%7, %8) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc35)
        "memref.store"(%9, %6, %arg3, %arg4) : (f32, memref<2x4xf32>, index, index) -> () loc(#loc36)
        "scf.yield"() : () -> () loc(#loc31)
      }) : (index, index, index) -> () loc(#loc31)
      "scf.yield"() : () -> () loc(#loc29)
    }) : (index, index, index) -> () loc(#loc29)
    "func.return"(%6) : (memref<2x4xf32>) -> () loc(#loc37)
  }) {llvm.emit_c_interface} : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/matmul_bias.loops.mlir":1:1)
#loc1 = loc("./pytorch/matmul_bias.loops.mlir":2:3)
#loc5 = loc("./pytorch/matmul_bias.loops.mlir":3:11)
#loc6 = loc("./pytorch/matmul_bias.loops.mlir":4:11)
#loc7 = loc("./pytorch/matmul_bias.loops.mlir":5:11)
#loc8 = loc("./pytorch/matmul_bias.loops.mlir":6:11)
#loc9 = loc("./pytorch/matmul_bias.loops.mlir":7:11)
#loc10 = loc("./pytorch/matmul_bias.loops.mlir":8:12)
#loc11 = loc("./pytorch/matmul_bias.loops.mlir":9:14)
#loc12 = loc("./pytorch/matmul_bias.loops.mlir":10:5)
#loc14 = loc("./pytorch/matmul_bias.loops.mlir":11:7)
#loc16 = loc("./pytorch/matmul_bias.loops.mlir":12:9)
#loc17 = loc("./pytorch/matmul_bias.loops.mlir":15:5)
#loc19 = loc("./pytorch/matmul_bias.loops.mlir":16:7)
#loc21 = loc("./pytorch/matmul_bias.loops.mlir":17:9)
#loc23 = loc("./pytorch/matmul_bias.loops.mlir":18:16)
#loc24 = loc("./pytorch/matmul_bias.loops.mlir":19:16)
#loc25 = loc("./pytorch/matmul_bias.loops.mlir":20:16)
#loc26 = loc("./pytorch/matmul_bias.loops.mlir":21:16)
#loc27 = loc("./pytorch/matmul_bias.loops.mlir":22:16)
#loc28 = loc("./pytorch/matmul_bias.loops.mlir":23:11)
#loc29 = loc("./pytorch/matmul_bias.loops.mlir":27:5)
#loc31 = loc("./pytorch/matmul_bias.loops.mlir":28:7)
#loc33 = loc("./pytorch/matmul_bias.loops.mlir":29:14)
#loc34 = loc("./pytorch/matmul_bias.loops.mlir":30:14)
#loc35 = loc("./pytorch/matmul_bias.loops.mlir":31:14)
#loc36 = loc("./pytorch/matmul_bias.loops.mlir":32:9)
#loc37 = loc("./pytorch/matmul_bias.loops.mlir":35:5)

