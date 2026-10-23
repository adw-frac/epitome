#map = affine_map<(d0, d1) -> (d0 + d1)>
"builtin.module"() ({
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>, sym_name = "__constant_2xf32", sym_visibility = "private", type = memref<2xf32>}> : () -> ()
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>, sym_name = "__constant_2x1x3x3xf32", sym_visibility = "private", type = memref<2x1x3x3xf32>}> : () -> ()
  "func.func"() <{function_type = (memref<1x1x5x5xf32>) -> memref<1x2x5x5xf32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: memref<1x1x5x5xf32>):
    %0 = "arith.constant"() <{value = 3 : index}> : () -> index
    %1 = "arith.constant"() <{value = 5 : index}> : () -> index
    %2 = "arith.constant"() <{value = 2 : index}> : () -> index
    %3 = "arith.constant"() <{value = 7 : index}> : () -> index
    %4 = "arith.constant"() <{value = 1 : index}> : () -> index
    %5 = "arith.constant"() <{value = 0 : index}> : () -> index
    %6 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %7 = "memref.get_global"() <{name = @__constant_2x1x3x3xf32}> : () -> memref<2x1x3x3xf32>
    %8 = "memref.get_global"() <{name = @__constant_2xf32}> : () -> memref<2xf32>
    %9 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x1x7x7xf32>
    "scf.for"(%5, %4, %4) ({
    ^bb0(%arg12: index):
      "scf.for"(%5, %4, %4) ({
      ^bb0(%arg13: index):
        "scf.for"(%5, %3, %4) ({
        ^bb0(%arg14: index):
          "scf.for"(%5, %3, %4) ({
          ^bb0(%arg15: index):
            "memref.store"(%6, %9, %arg12, %arg13, %arg14, %arg15) : (f32, memref<1x1x7x7xf32>, index, index, index, index) -> ()
            "scf.yield"() : () -> ()
          }) : (index, index, index) -> ()
          "scf.yield"() : () -> ()
        }) : (index, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %10 = "memref.subview"(%9) <{operandSegmentSizes = array<i32: 1, 0, 0, 0>, static_offsets = array<i64: 0, 0, 1, 1>, static_sizes = array<i64: 1, 1, 5, 5>, static_strides = array<i64: 1, 1, 1, 1>}> : (memref<1x1x7x7xf32>) -> memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>
    "memref.copy"(%arg0, %10) : (memref<1x1x5x5xf32>, memref<1x1x5x5xf32, strided<[49, 49, 7, 1], offset: 8>>) -> ()
    %11 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2x5x5xf32>
    "scf.for"(%5, %4, %4) ({
    ^bb0(%arg8: index):
      "scf.for"(%5, %2, %4) ({
      ^bb0(%arg9: index):
        "scf.for"(%5, %1, %4) ({
        ^bb0(%arg10: index):
          "scf.for"(%5, %1, %4) ({
          ^bb0(%arg11: index):
            %19 = "memref.load"(%8, %arg9) : (memref<2xf32>, index) -> f32
            "memref.store"(%19, %11, %arg8, %arg9, %arg10, %arg11) : (f32, memref<1x2x5x5xf32>, index, index, index, index) -> ()
            "scf.yield"() : () -> ()
          }) : (index, index, index) -> ()
          "scf.yield"() : () -> ()
        }) : (index, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%5, %4, %4) ({
    ^bb0(%arg1: index):
      "scf.for"(%5, %2, %4) ({
      ^bb0(%arg2: index):
        "scf.for"(%5, %1, %4) ({
        ^bb0(%arg3: index):
          "scf.for"(%5, %1, %4) ({
          ^bb0(%arg4: index):
            "scf.for"(%5, %4, %4) ({
            ^bb0(%arg5: index):
              "scf.for"(%5, %0, %4) ({
              ^bb0(%arg6: index):
                "scf.for"(%5, %0, %4) ({
                ^bb0(%arg7: index):
                  %12 = "affine.apply"(%arg3, %arg6) <{map = #map}> : (index, index) -> index
                  %13 = "affine.apply"(%arg4, %arg7) <{map = #map}> : (index, index) -> index
                  %14 = "memref.load"(%9, %arg1, %arg5, %12, %13) : (memref<1x1x7x7xf32>, index, index, index, index) -> f32
                  %15 = "memref.load"(%7, %arg2, %arg5, %arg6, %arg7) : (memref<2x1x3x3xf32>, index, index, index, index) -> f32
                  %16 = "memref.load"(%11, %arg1, %arg2, %arg3, %arg4) : (memref<1x2x5x5xf32>, index, index, index, index) -> f32
                  %17 = "arith.mulf"(%14, %15) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
                  %18 = "arith.addf"(%16, %17) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
                  "memref.store"(%18, %11, %arg1, %arg2, %arg3, %arg4) : (f32, memref<1x2x5x5xf32>, index, index, index, index) -> ()
                  "scf.yield"() : () -> ()
                }) : (index, index, index) -> ()
                "scf.yield"() : () -> ()
              }) : (index, index, index) -> ()
              "scf.yield"() : () -> ()
            }) : (index, index, index) -> ()
            "scf.yield"() : () -> ()
          }) : (index, index, index) -> ()
          "scf.yield"() : () -> ()
        }) : (index, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "func.return"(%11) : (memref<1x2x5x5xf32>) -> ()
  }) {llvm.emit_c_interface} : () -> ()
}) : () -> ()

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE",
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE"
    }
  }
#-}
