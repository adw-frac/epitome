#loc5 = loc("./chisel/counter/Counter.hw.mlir":5:25)
#loc6 = loc("./chisel/counter/Counter.hw.mlir":5:49)
#loc7 = loc("./chisel/counter/Counter.hw.mlir":5:65)
#loc14 = loc("./chisel/counter/Counter.hw.mlir":5:82)
#loc35 = loc("./chisel/counter/Counter.hw.mlir":44:27)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> () loc(#loc1)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> () loc(#loc2)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> () loc(#loc3)
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8>, parameters = [], result_locs = [#loc14], sym_name = "Counter"}> ({
  ^bb0(%arg1: !seq.clock loc("./chisel/counter/Counter.hw.mlir":5:25), %arg2: i1 loc("./chisel/counter/Counter.hw.mlir":5:49), %arg3: i1 loc("./chisel/counter/Counter.hw.mlir":5:65)):
    %0 = "hw.constant"() <{value = 1 : i8}> : () -> i8 loc(#loc8)
    %1 = "hw.constant"() <{value = 0 : i8}> : () -> i8 loc(#loc9)
    %2 = "seq.firreg"(%4, %arg1, %arg2, %1) <{name = "reg"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "reg"} : (i8, !seq.clock, i1, i8) -> i8 loc(#loc10)
    %3 = "comb.add"(%2, %0) <{twoState}> {sv.namehint = "_reg_T"} : (i8, i8) -> i8 loc(#loc11)
    %4 = "comb.mux"(%arg3, %3, %2) <{twoState}> : (i1, i8, i8) -> i8 loc(#loc12)
    "hw.output"(%2) : (i8) -> () loc(#loc13)
  }) : () -> () loc(#loc4)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification", verilogName = "layers_Counter_Verification"}> : () -> () loc(#loc15)
  "emit.file"() <{file_name = "verification/layers-Counter-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification, symbols = []}> : () -> () loc(#loc18)
    }) : () -> () loc(#loc17)
  }) : () -> () loc(#loc16)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Assert", verilogName = "layers_Counter_Verification_Assert"}> : () -> () loc(#loc19)
  "emit.file"() <{file_name = "verification/assert/layers-Counter-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Assert, symbols = []}> : () -> () loc(#loc22)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> () loc(#loc23)
    }) : () -> () loc(#loc21)
  }) : () -> () loc(#loc20)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Assume", verilogName = "layers_Counter_Verification_Assume"}> : () -> () loc(#loc24)
  "emit.file"() <{file_name = "verification/assume/layers-Counter-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Assume, symbols = []}> : () -> () loc(#loc27)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> () loc(#loc28)
    }) : () -> () loc(#loc26)
  }) : () -> () loc(#loc25)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Cover", verilogName = "layers_Counter_Verification_Cover"}> : () -> () loc(#loc29)
  "emit.file"() <{file_name = "verification/cover/layers-Counter-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Cover, symbols = []}> : () -> () loc(#loc32)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> () loc(#loc33)
    }) : () -> () loc(#loc31)
  }) : () -> () loc(#loc30)
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Counter_Class"}> ({
  ^bb0(%arg0: !om.basepath loc("./chisel/counter/Counter.hw.mlir":44:27)):
    "om.class.fields"() : () -> () loc(#loc36)
  }) : () -> () loc(#loc34)
}) : () -> () loc(#loc)
#loc = loc("./chisel/counter/Counter.hw.mlir":1:1)
#loc1 = loc("./chisel/counter/Counter.hw.mlir":2:3)
#loc2 = loc("./chisel/counter/Counter.hw.mlir":3:3)
#loc3 = loc("./chisel/counter/Counter.hw.mlir":4:3)
#loc4 = loc("./chisel/counter/Counter.hw.mlir":5:3)
#loc8 = loc("./chisel/counter/Counter.hw.mlir":6:14)
#loc9 = loc("./chisel/counter/Counter.hw.mlir":7:14)
#loc10 = loc("./chisel/counter/Counter.hw.mlir":8:12)
#loc11 = loc("./chisel/counter/Counter.hw.mlir":9:10)
#loc12 = loc("./chisel/counter/Counter.hw.mlir":10:10)
#loc13 = loc("./chisel/counter/Counter.hw.mlir":11:5)
#loc15 = loc("./chisel/counter/Counter.hw.mlir":13:3)
#loc16 = loc("./chisel/counter/Counter.hw.mlir":14:3)
#loc17 = loc("./chisel/counter/Counter.hw.mlir":15:5)
#loc18 = loc("./chisel/counter/Counter.hw.mlir":17:7)
#loc19 = loc("./chisel/counter/Counter.hw.mlir":20:3)
#loc20 = loc("./chisel/counter/Counter.hw.mlir":21:3)
#loc21 = loc("./chisel/counter/Counter.hw.mlir":22:5)
#loc22 = loc("./chisel/counter/Counter.hw.mlir":24:7)
#loc23 = loc("./chisel/counter/Counter.hw.mlir":25:7)
#loc24 = loc("./chisel/counter/Counter.hw.mlir":28:3)
#loc25 = loc("./chisel/counter/Counter.hw.mlir":29:3)
#loc26 = loc("./chisel/counter/Counter.hw.mlir":30:5)
#loc27 = loc("./chisel/counter/Counter.hw.mlir":32:7)
#loc28 = loc("./chisel/counter/Counter.hw.mlir":33:7)
#loc29 = loc("./chisel/counter/Counter.hw.mlir":36:3)
#loc30 = loc("./chisel/counter/Counter.hw.mlir":37:3)
#loc31 = loc("./chisel/counter/Counter.hw.mlir":38:5)
#loc32 = loc("./chisel/counter/Counter.hw.mlir":40:7)
#loc33 = loc("./chisel/counter/Counter.hw.mlir":41:7)
#loc34 = loc("./chisel/counter/Counter.hw.mlir":44:3)
#loc36 = loc("./chisel/counter/Counter.hw.mlir":45:5)

