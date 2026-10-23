#loc = loc("./chisel/mem/Scratchpad.hw.mlir":5:88)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_raddr : i4, output io_rdata : i32, input io_wen : i1, input io_waddr : i4, input io_wdata : i32>, parameters = [], result_locs = [#loc], sym_name = "Scratchpad"}> ({
  ^bb0(%arg1: !seq.clock, %arg2: i1, %arg3: i4, %arg4: i1, %arg5: i4, %arg6: i32):
    %0 = "seq.firmem"() <{name = "mem", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<16 x 32>
    "seq.firmem.write_port"(%0, %arg5, %arg1, %arg4, %arg6) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<16 x 32>, i4, !seq.clock, i1, i32) -> ()
    %1 = "seq.firmem.read_port"(%0, %arg3, %arg1) {sv.namehint = "io_rdata"} : (!seq.firmem<16 x 32>, i4, !seq.clock) -> i32
    "hw.output"(%1) : (i32) -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification", verilogName = "layers_Scratchpad_Verification"}> : () -> ()
  "emit.file"() <{file_name = "verification/layers-Scratchpad-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification, symbols = []}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification_Assert", verilogName = "layers_Scratchpad_Verification_Assert"}> : () -> ()
  "emit.file"() <{file_name = "verification/assert/layers-Scratchpad-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification_Assert, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Scratchpad-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification_Assume", verilogName = "layers_Scratchpad_Verification_Assume"}> : () -> ()
  "emit.file"() <{file_name = "verification/assume/layers-Scratchpad-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification_Assume, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Scratchpad-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Scratchpad_Verification_Cover", verilogName = "layers_Scratchpad_Verification_Cover"}> : () -> ()
  "emit.file"() <{file_name = "verification/cover/layers-Scratchpad-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Scratchpad_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Scratchpad_Verification_Cover, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Scratchpad-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Scratchpad_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

