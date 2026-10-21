#loc = loc("./chisel/gcd/GCD.hw.mlir":5:131)
#loc1 = loc("./chisel/gcd/GCD.hw.mlir":5:155)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, parameters = [], result_locs = [#loc, #loc1], sym_name = "GCD"}> ({
  ^bb0(%arg1: !seq.clock, %arg2: i1, %arg3: i16, %arg4: i16, %arg5: i1):
    %0 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %1 = "seq.firreg"(%8, %arg1) <{name = "x"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "x"} : (i16, !seq.clock) -> i16
    %2 = "seq.firreg"(%9, %arg1) <{name = "y"}> {firrtl.random_init_start = 16 : ui64} : (i16, !seq.clock) -> i16
    %3 = "comb.icmp"(%1, %2) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1
    %4 = "comb.sub"(%1, %2) <{twoState}> {sv.namehint = "_x_T"} : (i16, i16) -> i16
    %5 = "comb.mux"(%3, %4, %1) <{twoState}> : (i1, i16, i16) -> i16
    %6 = "comb.sub"(%2, %1) <{twoState}> {sv.namehint = "_y_T"} : (i16, i16) -> i16
    %7 = "comb.mux"(%3, %2, %6) <{twoState}> : (i1, i16, i16) -> i16
    %8 = "comb.mux"(%arg5, %arg3, %5) <{twoState}> : (i1, i16, i16) -> i16
    %9 = "comb.mux"(%arg5, %arg4, %7) <{twoState}> : (i1, i16, i16) -> i16
    %10 = "comb.icmp"(%2, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "io_outputValid"} : (i16, i16) -> i1
    "hw.output"(%1, %10) : (i16, i1) -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification", verilogName = "layers_GCD_Verification"}> : () -> ()
  "emit.file"() <{file_name = "verification/layers-GCD-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification, symbols = []}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Assert", verilogName = "layers_GCD_Verification_Assert"}> : () -> ()
  "emit.file"() <{file_name = "verification/assert/layers-GCD-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Assert, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Assume", verilogName = "layers_GCD_Verification_Assume"}> : () -> ()
  "emit.file"() <{file_name = "verification/assume/layers-GCD-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Assume, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Cover", verilogName = "layers_GCD_Verification_Cover"}> : () -> ()
  "emit.file"() <{file_name = "verification/cover/layers-GCD-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Cover, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "GCD_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

