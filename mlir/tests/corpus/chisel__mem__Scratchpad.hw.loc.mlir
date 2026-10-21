#loc5 = loc("./chisel/mem/Scratchpad.hw.mlir":5:28)
#loc6 = loc("./chisel/mem/Scratchpad.hw.mlir":5:52)
#loc7 = loc("./chisel/mem/Scratchpad.hw.mlir":5:68)
#loc8 = loc("./chisel/mem/Scratchpad.hw.mlir":5:107)
#loc9 = loc("./chisel/mem/Scratchpad.hw.mlir":5:124)
#loc10 = loc("./chisel/mem/Scratchpad.hw.mlir":5:143)
#loc15 = loc("./chisel/mem/Scratchpad.hw.mlir":5:88)
#loc36 = loc("./chisel/mem/Scratchpad.hw.mlir":42:30)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> () loc(#loc1)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> () loc(#loc2)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> () loc(#loc3)
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_raddr : i4, output io_rdata : i32, input io_wen : i1, input io_waddr : i4, input io_wdata : i32>, parameters = [], result_locs = [#loc15], sym_name = "Scratchpad"}> ({
  ^bb0(%arg1: !seq.clock loc("./chisel/mem/Scratchpad.hw.mlir":5:28), %arg2: i1 loc("./chisel/mem/Scratchpad.hw.mlir":5:52), %arg3: i4 loc("./chisel/mem/Scratchpad.hw.mlir":5:68), %arg4: i1 loc("./chisel/mem/Scratchpad.hw.mlir":5:107), %arg5: i4 loc("./chisel/mem/Scratchpad.hw.mlir":5:124), %arg6: i32 loc("./chisel/mem/Scratchpad.hw.mlir":5:143)):
    %0 = "seq.firmem"() <{name = "mem", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<16 x 32> loc(#loc11)
    "seq.firmem.write_port"(%0, %arg5, %arg1, %arg4, %arg6) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<16 x 32>, i4, !seq.clock, i1, i32) -> () loc(#loc12)
    %1 = "seq.firmem.read_port"(%0, %arg3, %arg1) {sv.namehint = "io_rdata"} : (!seq.firmem<16 x 32>, i4, !seq.clock) -> i32 loc(#loc13)
    "hw.output"(%1) : (i32) -> () loc(#loc14)
  }) : () -> () loc(#loc4)
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification", verilogName = "layers_Scratchpad_Verification"}> : () -> () loc(#loc16)
  "emit.file"() <{file_name = "verification/layers-Scratchpad-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification, symbols = []}> : () -> () loc(#loc19)
    }) : () -> () loc(#loc18)
  }) : () -> () loc(#loc17)
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification_Assert", verilogName = "layers_Scratchpad_Verification_Assert"}> : () -> () loc(#loc20)
  "emit.file"() <{file_name = "verification/assert/layers-Scratchpad-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification_Assert, symbols = []}> : () -> () loc(#loc23)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Scratchpad-Verification.sv"}> : () -> () loc(#loc24)
    }) : () -> () loc(#loc22)
  }) : () -> () loc(#loc21)
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification_Assume", verilogName = "layers_Scratchpad_Verification_Assume"}> : () -> () loc(#loc25)
  "emit.file"() <{file_name = "verification/assume/layers-Scratchpad-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification_Assume, symbols = []}> : () -> () loc(#loc28)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Scratchpad-Verification.sv"}> : () -> () loc(#loc29)
    }) : () -> () loc(#loc27)
  }) : () -> () loc(#loc26)
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification_Cover", verilogName = "layers_Scratchpad_Verification_Cover"}> : () -> () loc(#loc30)
  "emit.file"() <{file_name = "verification/cover/layers-Scratchpad-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification_Cover, symbols = []}> : () -> () loc(#loc33)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Scratchpad-Verification.sv"}> : () -> () loc(#loc34)
    }) : () -> () loc(#loc32)
  }) : () -> () loc(#loc31)
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Scratchpad_Class"}> ({
  ^bb0(%arg0: !om.basepath loc("./chisel/mem/Scratchpad.hw.mlir":42:30)):
    "om.class.fields"() : () -> () loc(#loc37)
  }) : () -> () loc(#loc35)
}) : () -> () loc(#loc)
#loc = loc("./chisel/mem/Scratchpad.hw.mlir":1:1)
#loc1 = loc("./chisel/mem/Scratchpad.hw.mlir":2:3)
#loc2 = loc("./chisel/mem/Scratchpad.hw.mlir":3:3)
#loc3 = loc("./chisel/mem/Scratchpad.hw.mlir":4:3)
#loc4 = loc("./chisel/mem/Scratchpad.hw.mlir":5:3)
#loc11 = loc("./chisel/mem/Scratchpad.hw.mlir":6:12)
#loc12 = loc("./chisel/mem/Scratchpad.hw.mlir":7:5)
#loc13 = loc("./chisel/mem/Scratchpad.hw.mlir":8:10)
#loc14 = loc("./chisel/mem/Scratchpad.hw.mlir":9:5)
#loc16 = loc("./chisel/mem/Scratchpad.hw.mlir":11:3)
#loc17 = loc("./chisel/mem/Scratchpad.hw.mlir":12:3)
#loc18 = loc("./chisel/mem/Scratchpad.hw.mlir":13:5)
#loc19 = loc("./chisel/mem/Scratchpad.hw.mlir":15:7)
#loc20 = loc("./chisel/mem/Scratchpad.hw.mlir":18:3)
#loc21 = loc("./chisel/mem/Scratchpad.hw.mlir":19:3)
#loc22 = loc("./chisel/mem/Scratchpad.hw.mlir":20:5)
#loc23 = loc("./chisel/mem/Scratchpad.hw.mlir":22:7)
#loc24 = loc("./chisel/mem/Scratchpad.hw.mlir":23:7)
#loc25 = loc("./chisel/mem/Scratchpad.hw.mlir":26:3)
#loc26 = loc("./chisel/mem/Scratchpad.hw.mlir":27:3)
#loc27 = loc("./chisel/mem/Scratchpad.hw.mlir":28:5)
#loc28 = loc("./chisel/mem/Scratchpad.hw.mlir":30:7)
#loc29 = loc("./chisel/mem/Scratchpad.hw.mlir":31:7)
#loc30 = loc("./chisel/mem/Scratchpad.hw.mlir":34:3)
#loc31 = loc("./chisel/mem/Scratchpad.hw.mlir":35:3)
#loc32 = loc("./chisel/mem/Scratchpad.hw.mlir":36:5)
#loc33 = loc("./chisel/mem/Scratchpad.hw.mlir":38:7)
#loc34 = loc("./chisel/mem/Scratchpad.hw.mlir":39:7)
#loc35 = loc("./chisel/mem/Scratchpad.hw.mlir":42:3)
#loc37 = loc("./chisel/mem/Scratchpad.hw.mlir":43:5)

