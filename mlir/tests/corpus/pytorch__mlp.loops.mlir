"builtin.module"() ({
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>, sym_name = "__constant_8x4xf32", sym_visibility = "private", type = memref<8x4xf32>}> : () -> ()
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>, sym_name = "__constant_8xf32", sym_visibility = "private", type = memref<8xf32>}> : () -> ()
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>, sym_name = "__constant_2x8xf32", sym_visibility = "private", type = memref<2x8xf32>}> : () -> ()
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>, sym_name = "__constant_2xf32", sym_visibility = "private", type = memref<2xf32>}> : () -> ()
  "func.func"() <{function_type = (memref<1x4xf32>) -> memref<1x2xf32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: memref<1x4xf32>):
    %0 = "arith.constant"() <{value = 2 : index}> : () -> index
    %1 = "arith.constant"() <{value = 8 : index}> : () -> index
    %2 = "arith.constant"() <{value = 1 : index}> : () -> index
    %3 = "arith.constant"() <{value = 4 : index}> : () -> index
    %4 = "arith.constant"() <{value = 0 : index}> : () -> index
    %5 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %6 = "memref.get_global"() <{name = @__constant_2xf32}> : () -> memref<2xf32>
    %7 = "memref.get_global"() <{name = @__constant_2x8xf32}> : () -> memref<2x8xf32>
    %8 = "memref.get_global"() <{name = @__constant_8xf32}> : () -> memref<8xf32>
    %9 = "memref.get_global"() <{name = @__constant_8x4xf32}> : () -> memref<8x4xf32>
    %10 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<4x8xf32>
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg23: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg24: index):
        %38 = "memref.load"(%9, %arg24, %arg23) : (memref<8x4xf32>, index, index) -> f32
        "memref.store"(%38, %10, %arg23, %arg24) : (f32, memref<4x8xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %11 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x8xf32>
    %12 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x8xf32>
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg21: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg22: index):
        "memref.store"(%5, %12, %arg21, %arg22) : (f32, memref<1x8xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg18: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg19: index):
        "scf.for"(%4, %3, %2) ({
        ^bb0(%arg20: index):
          %33 = "memref.load"(%arg0, %arg18, %arg20) : (memref<1x4xf32>, index, index) -> f32
          %34 = "memref.load"(%10, %arg20, %arg19) : (memref<4x8xf32>, index, index) -> f32
          %35 = "memref.load"(%12, %arg18, %arg19) : (memref<1x8xf32>, index, index) -> f32
          %36 = "arith.mulf"(%33, %34) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
          %37 = "arith.addf"(%35, %36) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
          "memref.store"(%37, %12, %arg18, %arg19) : (f32, memref<1x8xf32>, index, index) -> ()
          "scf.yield"() : () -> ()
        }) : (index, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg16: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg17: index):
        %32 = "memref.load"(%8, %arg17) : (memref<8xf32>, index) -> f32
        "memref.store"(%32, %11, %arg16, %arg17) : (f32, memref<1x8xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg14: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg15: index):
        %29 = "memref.load"(%12, %arg14, %arg15) : (memref<1x8xf32>, index, index) -> f32
        %30 = "memref.load"(%11, %arg14, %arg15) : (memref<1x8xf32>, index, index) -> f32
        %31 = "arith.addf"(%29, %30) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
        "memref.store"(%31, %11, %arg14, %arg15) : (f32, memref<1x8xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg12: index):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg13: index):
        %26 = "memref.load"(%11, %arg12, %arg13) : (memref<1x8xf32>, index, index) -> f32
        %27 = "arith.cmpf"(%26, %5) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1
        %28 = "arith.select"(%27, %26, %5) : (i1, f32, f32) -> f32
        "memref.store"(%28, %11, %arg12, %arg13) : (f32, memref<1x8xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %13 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<8x2xf32>
    "scf.for"(%4, %1, %2) ({
    ^bb0(%arg10: index):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg11: index):
        %25 = "memref.load"(%7, %arg11, %arg10) : (memref<2x8xf32>, index, index) -> f32
        "memref.store"(%25, %13, %arg10, %arg11) : (f32, memref<8x2xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    %14 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2xf32>
    %15 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2xf32>
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg8: index):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg9: index):
        "memref.store"(%5, %15, %arg8, %arg9) : (f32, memref<1x2xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg5: index):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg6: index):
        "scf.for"(%4, %1, %2) ({
        ^bb0(%arg7: index):
          %20 = "memref.load"(%11, %arg5, %arg7) : (memref<1x8xf32>, index, index) -> f32
          %21 = "memref.load"(%13, %arg7, %arg6) : (memref<8x2xf32>, index, index) -> f32
          %22 = "memref.load"(%15, %arg5, %arg6) : (memref<1x2xf32>, index, index) -> f32
          %23 = "arith.mulf"(%20, %21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
          %24 = "arith.addf"(%22, %23) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
          "memref.store"(%24, %15, %arg5, %arg6) : (f32, memref<1x2xf32>, index, index) -> ()
          "scf.yield"() : () -> ()
        }) : (index, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg3: index):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg4: index):
        %19 = "memref.load"(%6, %arg4) : (memref<2xf32>, index) -> f32
        "memref.store"(%19, %14, %arg3, %arg4) : (f32, memref<1x2xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg1: index):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg2: index):
        %16 = "memref.load"(%15, %arg1, %arg2) : (memref<1x2xf32>, index, index) -> f32
        %17 = "memref.load"(%14, %arg1, %arg2) : (memref<1x2xf32>, index, index) -> f32
        %18 = "arith.addf"(%16, %17) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
        "memref.store"(%18, %14, %arg1, %arg2) : (f32, memref<1x2xf32>, index, index) -> ()
        "scf.yield"() : () -> ()
      }) : (index, index, index) -> ()
      "scf.yield"() : () -> ()
    }) : (index, index, index) -> ()
    "func.return"(%14) : (memref<1x2xf32>) -> ()
  }) {llvm.emit_c_interface} : () -> ()
}) : () -> ()

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

