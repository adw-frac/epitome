#loc = loc("./chisel/counter/Counter.hw.mlir":5:82)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8>, parameters = [], result_locs = [#loc], sym_name = "Counter"}> ({
  ^bb0(%arg1: !seq.clock, %arg2: i1, %arg3: i1):
    %0 = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %1 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %2 = "seq.firreg"(%4, %arg1, %arg2, %1) <{name = "reg"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "reg"} : (i8, !seq.clock, i1, i8) -> i8
    %3 = "comb.add"(%2, %0) <{twoState}> {sv.namehint = "_reg_T"} : (i8, i8) -> i8
    %4 = "comb.mux"(%arg3, %3, %2) <{twoState}> : (i1, i8, i8) -> i8
    "hw.output"(%2) : (i8) -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification", verilogName = "layers_Counter_Verification"}> : () -> ()
  "emit.file"() <{file_name = "verification/layers-Counter-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification, symbols = []}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Assert", verilogName = "layers_Counter_Verification_Assert"}> : () -> ()
  "emit.file"() <{file_name = "verification/assert/layers-Counter-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Assert, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Assume", verilogName = "layers_Counter_Verification_Assume"}> : () -> ()
  "emit.file"() <{file_name = "verification/assume/layers-Counter-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Assume, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Cover", verilogName = "layers_Counter_Verification_Cover"}> : () -> ()
  "emit.file"() <{file_name = "verification/cover/layers-Counter-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Cover, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Counter_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

