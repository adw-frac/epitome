#loc6 = loc("./pytorch/mlp.loops.mlir":6:18)
#loc19 = loc("./pytorch/mlp.loops.mlir":18:13)
#loc21 = loc("./pytorch/mlp.loops.mlir":19:15)
#loc27 = loc("./pytorch/mlp.loops.mlir":26:13)
#loc29 = loc("./pytorch/mlp.loops.mlir":27:15)
#loc32 = loc("./pytorch/mlp.loops.mlir":31:13)
#loc34 = loc("./pytorch/mlp.loops.mlir":32:15)
#loc36 = loc("./pytorch/mlp.loops.mlir":33:17)
#loc44 = loc("./pytorch/mlp.loops.mlir":43:13)
#loc46 = loc("./pytorch/mlp.loops.mlir":44:15)
#loc50 = loc("./pytorch/mlp.loops.mlir":49:13)
#loc52 = loc("./pytorch/mlp.loops.mlir":50:15)
#loc58 = loc("./pytorch/mlp.loops.mlir":57:13)
#loc60 = loc("./pytorch/mlp.loops.mlir":58:15)
#loc67 = loc("./pytorch/mlp.loops.mlir":66:13)
#loc69 = loc("./pytorch/mlp.loops.mlir":67:15)
#loc75 = loc("./pytorch/mlp.loops.mlir":74:13)
#loc77 = loc("./pytorch/mlp.loops.mlir":75:15)
#loc80 = loc("./pytorch/mlp.loops.mlir":79:13)
#loc82 = loc("./pytorch/mlp.loops.mlir":80:15)
#loc84 = loc("./pytorch/mlp.loops.mlir":81:17)
#loc92 = loc("./pytorch/mlp.loops.mlir":91:13)
#loc94 = loc("./pytorch/mlp.loops.mlir":92:15)
#loc98 = loc("./pytorch/mlp.loops.mlir":97:13)
#loc100 = loc("./pytorch/mlp.loops.mlir":98:15)
"builtin.module"() ({
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>, sym_name = "__constant_8x4xf32", sym_visibility = "private", type = memref<8x4xf32>}> : () -> () loc(#loc1)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>, sym_name = "__constant_8xf32", sym_visibility = "private", type = memref<8xf32>}> : () -> () loc(#loc2)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>, sym_name = "__constant_2x8xf32", sym_visibility = "private", type = memref<2x8xf32>}> : () -> () loc(#loc3)
  "memref.global"() <{alignment = 64 : i64, constant, initial_value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>, sym_name = "__constant_2xf32", sym_visibility = "private", type = memref<2xf32>}> : () -> () loc(#loc4)
  "func.func"() <{function_type = (memref<1x4xf32>) -> memref<1x2xf32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: memref<1x4xf32> loc("./pytorch/mlp.loops.mlir":6:18)):
    %0 = "arith.constant"() <{value = 2 : index}> : () -> index loc(#loc7)
    %1 = "arith.constant"() <{value = 8 : index}> : () -> index loc(#loc8)
    %2 = "arith.constant"() <{value = 1 : index}> : () -> index loc(#loc9)
    %3 = "arith.constant"() <{value = 4 : index}> : () -> index loc(#loc10)
    %4 = "arith.constant"() <{value = 0 : index}> : () -> index loc(#loc11)
    %5 = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32 loc(#loc12)
    %6 = "memref.get_global"() <{name = @__constant_2xf32}> : () -> memref<2xf32> loc(#loc13)
    %7 = "memref.get_global"() <{name = @__constant_2x8xf32}> : () -> memref<2x8xf32> loc(#loc14)
    %8 = "memref.get_global"() <{name = @__constant_8xf32}> : () -> memref<8xf32> loc(#loc15)
    %9 = "memref.get_global"() <{name = @__constant_8x4xf32}> : () -> memref<8x4xf32> loc(#loc16)
    %10 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<4x8xf32> loc(#loc17)
    "scf.for"(%4, %3, %2) ({
    ^bb0(%arg23: index loc("./pytorch/mlp.loops.mlir":18:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg24: index loc("./pytorch/mlp.loops.mlir":19:15)):
        %38 = "memref.load"(%9, %arg24, %arg23) : (memref<8x4xf32>, index, index) -> f32 loc(#loc22)
        "memref.store"(%38, %10, %arg23, %arg24) : (f32, memref<4x8xf32>, index, index) -> () loc(#loc23)
        "scf.yield"() : () -> () loc(#loc20)
      }) : (index, index, index) -> () loc(#loc20)
      "scf.yield"() : () -> () loc(#loc18)
    }) : (index, index, index) -> () loc(#loc18)
    %11 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x8xf32> loc(#loc24)
    %12 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x8xf32> loc(#loc25)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg21: index loc("./pytorch/mlp.loops.mlir":26:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg22: index loc("./pytorch/mlp.loops.mlir":27:15)):
        "memref.store"(%5, %12, %arg21, %arg22) : (f32, memref<1x8xf32>, index, index) -> () loc(#loc30)
        "scf.yield"() : () -> () loc(#loc28)
      }) : (index, index, index) -> () loc(#loc28)
      "scf.yield"() : () -> () loc(#loc26)
    }) : (index, index, index) -> () loc(#loc26)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg18: index loc("./pytorch/mlp.loops.mlir":31:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg19: index loc("./pytorch/mlp.loops.mlir":32:15)):
        "scf.for"(%4, %3, %2) ({
        ^bb0(%arg20: index loc("./pytorch/mlp.loops.mlir":33:17)):
          %33 = "memref.load"(%arg0, %arg18, %arg20) : (memref<1x4xf32>, index, index) -> f32 loc(#loc37)
          %34 = "memref.load"(%10, %arg20, %arg19) : (memref<4x8xf32>, index, index) -> f32 loc(#loc38)
          %35 = "memref.load"(%12, %arg18, %arg19) : (memref<1x8xf32>, index, index) -> f32 loc(#loc39)
          %36 = "arith.mulf"(%33, %34) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc40)
          %37 = "arith.addf"(%35, %36) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc41)
          "memref.store"(%37, %12, %arg18, %arg19) : (f32, memref<1x8xf32>, index, index) -> () loc(#loc42)
          "scf.yield"() : () -> () loc(#loc35)
        }) : (index, index, index) -> () loc(#loc35)
        "scf.yield"() : () -> () loc(#loc33)
      }) : (index, index, index) -> () loc(#loc33)
      "scf.yield"() : () -> () loc(#loc31)
    }) : (index, index, index) -> () loc(#loc31)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg16: index loc("./pytorch/mlp.loops.mlir":43:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg17: index loc("./pytorch/mlp.loops.mlir":44:15)):
        %32 = "memref.load"(%8, %arg17) : (memref<8xf32>, index) -> f32 loc(#loc47)
        "memref.store"(%32, %11, %arg16, %arg17) : (f32, memref<1x8xf32>, index, index) -> () loc(#loc48)
        "scf.yield"() : () -> () loc(#loc45)
      }) : (index, index, index) -> () loc(#loc45)
      "scf.yield"() : () -> () loc(#loc43)
    }) : (index, index, index) -> () loc(#loc43)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg14: index loc("./pytorch/mlp.loops.mlir":49:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg15: index loc("./pytorch/mlp.loops.mlir":50:15)):
        %29 = "memref.load"(%12, %arg14, %arg15) : (memref<1x8xf32>, index, index) -> f32 loc(#loc53)
        %30 = "memref.load"(%11, %arg14, %arg15) : (memref<1x8xf32>, index, index) -> f32 loc(#loc54)
        %31 = "arith.addf"(%29, %30) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc55)
        "memref.store"(%31, %11, %arg14, %arg15) : (f32, memref<1x8xf32>, index, index) -> () loc(#loc56)
        "scf.yield"() : () -> () loc(#loc51)
      }) : (index, index, index) -> () loc(#loc51)
      "scf.yield"() : () -> () loc(#loc49)
    }) : (index, index, index) -> () loc(#loc49)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg12: index loc("./pytorch/mlp.loops.mlir":57:13)):
      "scf.for"(%4, %1, %2) ({
      ^bb0(%arg13: index loc("./pytorch/mlp.loops.mlir":58:15)):
        %26 = "memref.load"(%11, %arg12, %arg13) : (memref<1x8xf32>, index, index) -> f32 loc(#loc61)
        %27 = "arith.cmpf"(%26, %5) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1 loc(#loc62)
        %28 = "arith.select"(%27, %26, %5) : (i1, f32, f32) -> f32 loc(#loc63)
        "memref.store"(%28, %11, %arg12, %arg13) : (f32, memref<1x8xf32>, index, index) -> () loc(#loc64)
        "scf.yield"() : () -> () loc(#loc59)
      }) : (index, index, index) -> () loc(#loc59)
      "scf.yield"() : () -> () loc(#loc57)
    }) : (index, index, index) -> () loc(#loc57)
    %13 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<8x2xf32> loc(#loc65)
    "scf.for"(%4, %1, %2) ({
    ^bb0(%arg10: index loc("./pytorch/mlp.loops.mlir":66:13)):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg11: index loc("./pytorch/mlp.loops.mlir":67:15)):
        %25 = "memref.load"(%7, %arg11, %arg10) : (memref<2x8xf32>, index, index) -> f32 loc(#loc70)
        "memref.store"(%25, %13, %arg10, %arg11) : (f32, memref<8x2xf32>, index, index) -> () loc(#loc71)
        "scf.yield"() : () -> () loc(#loc68)
      }) : (index, index, index) -> () loc(#loc68)
      "scf.yield"() : () -> () loc(#loc66)
    }) : (index, index, index) -> () loc(#loc66)
    %14 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2xf32> loc(#loc72)
    %15 = "memref.alloc"() <{alignment = 64 : i64, operandSegmentSizes = array<i32: 0, 0>}> : () -> memref<1x2xf32> loc(#loc73)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg8: index loc("./pytorch/mlp.loops.mlir":74:13)):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg9: index loc("./pytorch/mlp.loops.mlir":75:15)):
        "memref.store"(%5, %15, %arg8, %arg9) : (f32, memref<1x2xf32>, index, index) -> () loc(#loc78)
        "scf.yield"() : () -> () loc(#loc76)
      }) : (index, index, index) -> () loc(#loc76)
      "scf.yield"() : () -> () loc(#loc74)
    }) : (index, index, index) -> () loc(#loc74)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg5: index loc("./pytorch/mlp.loops.mlir":79:13)):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg6: index loc("./pytorch/mlp.loops.mlir":80:15)):
        "scf.for"(%4, %1, %2) ({
        ^bb0(%arg7: index loc("./pytorch/mlp.loops.mlir":81:17)):
          %20 = "memref.load"(%11, %arg5, %arg7) : (memref<1x8xf32>, index, index) -> f32 loc(#loc85)
          %21 = "memref.load"(%13, %arg7, %arg6) : (memref<8x2xf32>, index, index) -> f32 loc(#loc86)
          %22 = "memref.load"(%15, %arg5, %arg6) : (memref<1x2xf32>, index, index) -> f32 loc(#loc87)
          %23 = "arith.mulf"(%20, %21) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc88)
          %24 = "arith.addf"(%22, %23) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc89)
          "memref.store"(%24, %15, %arg5, %arg6) : (f32, memref<1x2xf32>, index, index) -> () loc(#loc90)
          "scf.yield"() : () -> () loc(#loc83)
        }) : (index, index, index) -> () loc(#loc83)
        "scf.yield"() : () -> () loc(#loc81)
      }) : (index, index, index) -> () loc(#loc81)
      "scf.yield"() : () -> () loc(#loc79)
    }) : (index, index, index) -> () loc(#loc79)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg3: index loc("./pytorch/mlp.loops.mlir":91:13)):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg4: index loc("./pytorch/mlp.loops.mlir":92:15)):
        %19 = "memref.load"(%6, %arg4) : (memref<2xf32>, index) -> f32 loc(#loc95)
        "memref.store"(%19, %14, %arg3, %arg4) : (f32, memref<1x2xf32>, index, index) -> () loc(#loc96)
        "scf.yield"() : () -> () loc(#loc93)
      }) : (index, index, index) -> () loc(#loc93)
      "scf.yield"() : () -> () loc(#loc91)
    }) : (index, index, index) -> () loc(#loc91)
    "scf.for"(%4, %2, %2) ({
    ^bb0(%arg1: index loc("./pytorch/mlp.loops.mlir":97:13)):
      "scf.for"(%4, %0, %2) ({
      ^bb0(%arg2: index loc("./pytorch/mlp.loops.mlir":98:15)):
        %16 = "memref.load"(%15, %arg1, %arg2) : (memref<1x2xf32>, index, index) -> f32 loc(#loc101)
        %17 = "memref.load"(%14, %arg1, %arg2) : (memref<1x2xf32>, index, index) -> f32 loc(#loc102)
        %18 = "arith.addf"(%16, %17) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32 loc(#loc103)
        "memref.store"(%18, %14, %arg1, %arg2) : (f32, memref<1x2xf32>, index, index) -> () loc(#loc104)
        "scf.yield"() : () -> () loc(#loc99)
      }) : (index, index, index) -> () loc(#loc99)
      "scf.yield"() : () -> () loc(#loc97)
    }) : (index, index, index) -> () loc(#loc97)
    "func.return"(%14) : (memref<1x2xf32>) -> () loc(#loc105)
  }) {llvm.emit_c_interface} : () -> () loc(#loc5)
}) : () -> () loc(#loc)
#loc = loc("./pytorch/mlp.loops.mlir":1:1)
#loc1 = loc("./pytorch/mlp.loops.mlir":2:3)
#loc2 = loc("./pytorch/mlp.loops.mlir":3:3)
#loc3 = loc("./pytorch/mlp.loops.mlir":4:3)
#loc4 = loc("./pytorch/mlp.loops.mlir":5:3)
#loc5 = loc("./pytorch/mlp.loops.mlir":6:3)
#loc7 = loc("./pytorch/mlp.loops.mlir":7:11)
#loc8 = loc("./pytorch/mlp.loops.mlir":8:11)
#loc9 = loc("./pytorch/mlp.loops.mlir":9:11)
#loc10 = loc("./pytorch/mlp.loops.mlir":10:11)
#loc11 = loc("./pytorch/mlp.loops.mlir":11:11)
#loc12 = loc("./pytorch/mlp.loops.mlir":12:12)
#loc13 = loc("./pytorch/mlp.loops.mlir":13:10)
#loc14 = loc("./pytorch/mlp.loops.mlir":14:10)
#loc15 = loc("./pytorch/mlp.loops.mlir":15:10)
#loc16 = loc("./pytorch/mlp.loops.mlir":16:10)
#loc17 = loc("./pytorch/mlp.loops.mlir":17:14)
#loc18 = loc("./pytorch/mlp.loops.mlir":18:5)
#loc20 = loc("./pytorch/mlp.loops.mlir":19:7)
#loc22 = loc("./pytorch/mlp.loops.mlir":20:14)
#loc23 = loc("./pytorch/mlp.loops.mlir":21:9)
#loc24 = loc("./pytorch/mlp.loops.mlir":24:16)
#loc25 = loc("./pytorch/mlp.loops.mlir":25:16)
#loc26 = loc("./pytorch/mlp.loops.mlir":26:5)
#loc28 = loc("./pytorch/mlp.loops.mlir":27:7)
#loc30 = loc("./pytorch/mlp.loops.mlir":28:9)
#loc31 = loc("./pytorch/mlp.loops.mlir":31:5)
#loc33 = loc("./pytorch/mlp.loops.mlir":32:7)
#loc35 = loc("./pytorch/mlp.loops.mlir":33:9)
#loc37 = loc("./pytorch/mlp.loops.mlir":34:16)
#loc38 = loc("./pytorch/mlp.loops.mlir":35:16)
#loc39 = loc("./pytorch/mlp.loops.mlir":36:16)
#loc40 = loc("./pytorch/mlp.loops.mlir":37:16)
#loc41 = loc("./pytorch/mlp.loops.mlir":38:16)
#loc42 = loc("./pytorch/mlp.loops.mlir":39:11)
#loc43 = loc("./pytorch/mlp.loops.mlir":43:5)
#loc45 = loc("./pytorch/mlp.loops.mlir":44:7)
#loc47 = loc("./pytorch/mlp.loops.mlir":45:14)
#loc48 = loc("./pytorch/mlp.loops.mlir":46:9)
#loc49 = loc("./pytorch/mlp.loops.mlir":49:5)
#loc51 = loc("./pytorch/mlp.loops.mlir":50:7)
#loc53 = loc("./pytorch/mlp.loops.mlir":51:14)
#loc54 = loc("./pytorch/mlp.loops.mlir":52:14)
#loc55 = loc("./pytorch/mlp.loops.mlir":53:14)
#loc56 = loc("./pytorch/mlp.loops.mlir":54:9)
#loc57 = loc("./pytorch/mlp.loops.mlir":57:5)
#loc59 = loc("./pytorch/mlp.loops.mlir":58:7)
#loc61 = loc("./pytorch/mlp.loops.mlir":59:14)
#loc62 = loc("./pytorch/mlp.loops.mlir":60:14)
#loc63 = loc("./pytorch/mlp.loops.mlir":61:14)
#loc64 = loc("./pytorch/mlp.loops.mlir":62:9)
#loc65 = loc("./pytorch/mlp.loops.mlir":65:16)
#loc66 = loc("./pytorch/mlp.loops.mlir":66:5)
#loc68 = loc("./pytorch/mlp.loops.mlir":67:7)
#loc70 = loc("./pytorch/mlp.loops.mlir":68:14)
#loc71 = loc("./pytorch/mlp.loops.mlir":69:9)
#loc72 = loc("./pytorch/mlp.loops.mlir":72:16)
#loc73 = loc("./pytorch/mlp.loops.mlir":73:16)
#loc74 = loc("./pytorch/mlp.loops.mlir":74:5)
#loc76 = loc("./pytorch/mlp.loops.mlir":75:7)
#loc78 = loc("./pytorch/mlp.loops.mlir":76:9)
#loc79 = loc("./pytorch/mlp.loops.mlir":79:5)
#loc81 = loc("./pytorch/mlp.loops.mlir":80:7)
#loc83 = loc("./pytorch/mlp.loops.mlir":81:9)
#loc85 = loc("./pytorch/mlp.loops.mlir":82:16)
#loc86 = loc("./pytorch/mlp.loops.mlir":83:16)
#loc87 = loc("./pytorch/mlp.loops.mlir":84:16)
#loc88 = loc("./pytorch/mlp.loops.mlir":85:16)
#loc89 = loc("./pytorch/mlp.loops.mlir":86:16)
#loc90 = loc("./pytorch/mlp.loops.mlir":87:11)
#loc91 = loc("./pytorch/mlp.loops.mlir":91:5)
#loc93 = loc("./pytorch/mlp.loops.mlir":92:7)
#loc95 = loc("./pytorch/mlp.loops.mlir":93:14)
#loc96 = loc("./pytorch/mlp.loops.mlir":94:9)
#loc97 = loc("./pytorch/mlp.loops.mlir":97:5)
#loc99 = loc("./pytorch/mlp.loops.mlir":98:7)
#loc101 = loc("./pytorch/mlp.loops.mlir":99:14)
#loc102 = loc("./pytorch/mlp.loops.mlir":100:14)
#loc103 = loc("./pytorch/mlp.loops.mlir":101:14)
#loc104 = loc("./pytorch/mlp.loops.mlir":102:9)
#loc105 = loc("./pytorch/mlp.loops.mlir":105:5)

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

