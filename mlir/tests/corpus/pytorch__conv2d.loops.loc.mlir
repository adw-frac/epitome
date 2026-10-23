#loc4 = loc("-":5:21)
#loc16 = loc("-":16:13)
#loc18 = loc("-":17:15)
#loc20 = loc("-":18:17)
#loc22 = loc("-":19:19)
#loc28 = loc("-":28:13)
#loc30 = loc("-":29:15)
#loc32 = loc("-":30:17)
#loc34 = loc("-":31:19)
#loc38 = loc("-":38:13)
#loc40 = loc("-":39:15)
#loc42 = loc("-":40:17)
#loc44 = loc("-":41:19)
#loc46 = loc("-":42:21)
#loc48 = loc("-":43:23)
#loc50 = loc("-":44:25)
#map = affine_map<(d0, d1) -> (d0 + d1)>
"builtin.module"() ({
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>, sym_name = "__constant_2xf32", sym_visibility = "private", type = memref<2xf32>}> : () -> () loc(#loc1)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>, sym_name = "__constant_2x1x3x3xf32", sym_visibility = "private", type = memref<2x1x3x3xf32>}> : () -> () loc(#loc2)
  "func.func"() <{function_type = (memref<1x1x5x5xf32>) -> memref<1x2x5x5xf32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: memref<1x1x5x5xf32> loc("-":5:21)):
    %0 = "arith.constant"() <{value = 3 : index}> : () -> index loc(#loc5)
    %1 = "arith.constant"() <{value = 5 : index}> : () -> index loc(#loc6)
    %2 = "arith.constant"() <{value = 2 : index}> : () -> index loc(#loc7)
    %3 = "arith.constant"() <{value = 7 : index}> : () -> index loc(#loc8)
    %4 = "arith.constant"() <{value = 1 : index}> : () -> index loc(#loc9)
    %5 = "arith.constant"() <{value = 0 : index}> : () -> index loc(#loc10)
    %6 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc11)
    %7 = "memref.get_global"() <{name = @__constant_2x1x3x3xf32}> : () -> memref<2x1x3x3xf32> loc(#loc12)
    %8 = "memref.get_global"() <{name = @__constant_2xf32}> : () -> memref<2xf32> loc(#loc13)
    %9 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x1x7x7xf32> loc(#loc14)
    "scf.for"(%5, %4, %4) ({
    ^bb0(%arg12: index loc("-":16:13)):
      "scf.for"(%5, %4, %4) ({
      ^bb0(%arg13: index loc("-":17:15)):
        "scf.for"(%5, %3, %4) ({
        ^bb0(%arg14: index loc("-":18:17)):
          "scf.for"(%5, %3, %4) ({
          ^bb0(%arg15: index loc("-":19:19)):
            "memref.store"(%6, %9, %arg12, %arg13, %arg14, %arg15) : (f32, memref<1x1x7x7xf32>, index, index, index, index) -> () loc(#loc23)
            "scf.yield"() : () -> () loc(#loc21)
          }) : (index, index, index) -> () loc(#loc21)
          "scf.yield"() : () -> () loc(#loc19)
        }) : (index, index, index) -> () loc(#loc19)
        "scf.yield"() : () -> () loc(#loc17)
      }) : (index, index, index) -> () loc(#loc17)
      "scf.yield"() : () -> () loc(#loc15)
    }) : (index, index, index) -> () loc(#loc15)
    %10 = "memref.subview"(%9) <{operandSegmentSizes = array<i32: 1, 0, 0, 0>, static_offsets = array<i64: 0, 0, 1, 1>, static_sizes = array<i64: 1, 1, 5, 5>, static_strides = array<i64: 1, 1, 1, 1>}> : (memref<1x1x7x7xf32>) -> memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>> loc(#loc24)
    "memref.copy"(%arg0, %10) : (memref<1x1x5x5xf32>, memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>) -> () loc(#loc25)
    %11 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2x5x5xf32> loc(#loc26)
    "scf.for"(%5, %4, %4) ({
    ^bb0(%arg8: index loc("-":28:13)):
      "scf.for"(%5, %2, %4) ({
      ^bb0(%arg9: index loc("-":29:15)):
        "scf.for"(%5, %1, %4) ({
        ^bb0(%arg10: index loc("-":30:17)):
          "scf.for"(%5, %1, %4) ({
          ^bb0(%arg11: index loc("-":31:19)):
            %19 = "memref.load"(%8, %arg9) : (memref<2xf32>, index) -> f32 loc(#loc35)
            "memref.store"(%19, %11, %arg8, %arg9, %arg10, %arg11) : (f32, memref<1x2x5x5xf32>, index, index, index, index) -> () loc(#loc36)
            "scf.yield"() : () -> () loc(#loc33)
          }) : (index, index, index) -> () loc(#loc33)
          "scf.yield"() : () -> () loc(#loc31)
        }) : (index, index, index) -> () loc(#loc31)
        "scf.yield"() : () -> () loc(#loc29)
      }) : (index, index, index) -> () loc(#loc29)
      "scf.yield"() : () -> () loc(#loc27)
    }) : (index, index, index) -> () loc(#loc27)
    "scf.for"(%5, %4, %4) ({
    ^bb0(%arg1: index loc("-":38:13)):
      "scf.for"(%5, %2, %4) ({
      ^bb0(%arg2: index loc("-":39:15)):
        "scf.for"(%5, %1, %4) ({
        ^bb0(%arg3: index loc("-":40:17)):
          "scf.for"(%5, %1, %4) ({
          ^bb0(%arg4: index loc("-":41:19)):
            "scf.for"(%5, %4, %4) ({
            ^bb0(%arg5: index loc("-":42:21)):
              "scf.for"(%5, %0, %4) ({
              ^bb0(%arg6: index loc("-":43:23)):
                "scf.for"(%5, %0, %4) ({
                ^bb0(%arg7: index loc("-":44:25)):
                  %12 = "affine.apply"(%arg3, %arg6) <{map = #map}> : (index, index) -> index loc(#loc51)
                  %13 = "affine.apply"(%arg4, %arg7) <{map = #map}> : (index, index) -> index loc(#loc52)
                  %14 = "memref.load"(%9, %arg1, %arg5, %12, %13) : (memref<1x1x7x7xf32>, index, index, index, index) -> f32 loc(#loc53)
                  %15 = "memref.load"(%7, %arg2, %arg5, %arg6, %arg7) : (memref<2x1x3x3xf32>, index, index, index, index) -> f32 loc(#loc54)
                  %16 = "memref.load"(%11, %arg1, %arg2, %arg3, %arg4) : (memref<1x2x5x5xf32>, index, index, index, index) -> f32 loc(#loc55)
                  %17 = "arith.mulf"(%14, %15) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc56)
                  %18 = "arith.addf"(%16, %17) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc57)
                  "memref.store"(%18, %11, %arg1, %arg2, %arg3, %arg4) : (f32, memref<1x2x5x5xf32>, index, index, index, index) -> () loc(#loc58)
                  "scf.yield"() : () -> () loc(#loc49)
                }) : (index, index, index) -> () loc(#loc49)
                "scf.yield"() : () -> () loc(#loc47)
              }) : (index, index, index) -> () loc(#loc47)
              "scf.yield"() : () -> () loc(#loc45)
            }) : (index, index, index) -> () loc(#loc45)
            "scf.yield"() : () -> () loc(#loc43)
          }) : (index, index, index) -> () loc(#loc43)
          "scf.yield"() : () -> () loc(#loc41)
        }) : (index, index, index) -> () loc(#loc41)
        "scf.yield"() : () -> () loc(#loc39)
      }) : (index, index, index) -> () loc(#loc39)
      "scf.yield"() : () -> () loc(#loc37)
    }) : (index, index, index) -> () loc(#loc37)
    "func.return"(%11) : (memref<1x2x5x5xf32>) -> () loc(#loc59)
  }) {llvm.emit_c_interface} : () -> () loc(#loc3)
}) : () -> () loc(#loc)
#loc = loc("-":2:1)
#loc1 = loc("-":3:3)
#loc2 = loc("-":4:3)
#loc3 = loc("-":5:3)
#loc5 = loc("-":6:11)
#loc6 = loc("-":7:11)
#loc7 = loc("-":8:11)
#loc8 = loc("-":9:11)
#loc9 = loc("-":10:11)
#loc10 = loc("-":11:11)
#loc11 = loc("-":12:12)
#loc12 = loc("-":13:10)
#loc13 = loc("-":14:10)
#loc14 = loc("-":15:14)
#loc15 = loc("-":16:5)
#loc17 = loc("-":17:7)
#loc19 = loc("-":18:9)
#loc21 = loc("-":19:11)
#loc23 = loc("-":20:13)
#loc24 = loc("-":25:16)
#loc25 = loc("-":26:5)
#loc26 = loc("-":27:16)
#loc27 = loc("-":28:5)
#loc29 = loc("-":29:7)
#loc31 = loc("-":30:9)
#loc33 = loc("-":31:11)
#loc35 = loc("-":32:18)
#loc36 = loc("-":33:13)
#loc37 = loc("-":38:5)
#loc39 = loc("-":39:7)
#loc41 = loc("-":40:9)
#loc43 = loc("-":41:11)
#loc45 = loc("-":42:13)
#loc47 = loc("-":43:15)
#loc49 = loc("-":44:17)
#loc51 = loc("-":45:24)
#loc52 = loc("-":46:24)
#loc53 = loc("-":47:24)
#loc54 = loc("-":48:24)
#loc55 = loc("-":49:24)
#loc56 = loc("-":50:24)
#loc57 = loc("-":51:24)
#loc58 = loc("-":52:19)
#loc59 = loc("-":60:5)

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE",
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE"
    }
  }
#-}
