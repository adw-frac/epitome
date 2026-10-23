#loc5 = loc("./chisel/gcd/GCD.hw.mlir":5:21)
#loc6 = loc("./chisel/gcd/GCD.hw.mlir":5:45)
#loc7 = loc("./chisel/gcd/GCD.hw.mlir":5:61)
#loc8 = loc("./chisel/gcd/GCD.hw.mlir":5:82)
#loc9 = loc("./chisel/gcd/GCD.hw.mlir":5:103)
#loc22 = loc("./chisel/gcd/GCD.hw.mlir":5:131)
#loc23 = loc("./chisel/gcd/GCD.hw.mlir":5:155)
#loc44 = loc("./chisel/gcd/GCD.hw.mlir":50:23)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> () loc(#loc1)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> () loc(#loc2)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> () loc(#loc3)
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, parameters = [], result_locs = [#loc22, #loc23], sym_name = "GCD"}> ({
  ^bb0(%arg1: !seq.clock loc("./chisel/gcd/GCD.hw.mlir":5:21), %arg2: i1 loc("./chisel/gcd/GCD.hw.mlir":5:45), %arg3: i16 loc("./chisel/gcd/GCD.hw.mlir":5:61), %arg4: i16 loc("./chisel/gcd/GCD.hw.mlir":5:82), %arg5: i1 loc("./chisel/gcd/GCD.hw.mlir":5:103)):
    %0 = "hw.constant"() <{value = 0 : i16}> : () -> i16 loc(#loc10)
    %1 = "seq.firreg"(%8, %arg1) <{name = "x"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "x"} : (i16, !seq.clock) -> i16 loc(#loc11)
    %2 = "seq.firreg"(%9, %arg1) <{name = "y"}> {firrtl.random_init_start = 16 : ui64} : (i16, !seq.clock) -> i16 loc(#loc12)
    %3 = "comb.icmp"(%1, %2) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1 loc(#loc13)
    %4 = "comb.sub"(%1, %2) <{twoState}> {sv.namehint = "_x_T"} : (i16, i16) -> i16 loc(#loc14)
    %5 = "comb.mux"(%3, %4, %1) <{twoState}> : (i1, i16, i16) -> i16 loc(#loc15)
    %6 = "comb.sub"(%2, %1) <{twoState}> {sv.namehint = "_y_T"} : (i16, i16) -> i16 loc(#loc16)
    %7 = "comb.mux"(%3, %2, %6) <{twoState}> : (i1, i16, i16) -> i16 loc(#loc17)
    %8 = "comb.mux"(%arg5, %arg3, %5) <{twoState}> : (i1, i16, i16) -> i16 loc(#loc18)
    %9 = "comb.mux"(%arg5, %arg4, %7) <{twoState}> : (i1, i16, i16) -> i16 loc(#loc19)
    %10 = "comb.icmp"(%2, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "io_outputValid"} : (i16, i16) -> i1 loc(#loc20)
    "hw.output"(%1, %10) : (i16, i1) -> () loc(#loc21)
  }) : () -> () loc(#loc4)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification", verilogName = "layers_GCD_Verification"}> : () -> () loc(#loc24)
  "emit.file"() <{file_name = "verification/layers-GCD-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification, symbols = []}> : () -> () loc(#loc27)
    }) : () -> () loc(#loc26)
  }) : () -> () loc(#loc25)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Assert", verilogName = "layers_GCD_Verification_Assert"}> : () -> () loc(#loc28)
  "emit.file"() <{file_name = "verification/assert/layers-GCD-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Assert, symbols = []}> : () -> () loc(#loc31)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> () loc(#loc32)
    }) : () -> () loc(#loc30)
  }) : () -> () loc(#loc29)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Assume", verilogName = "layers_GCD_Verification_Assume"}> : () -> () loc(#loc33)
  "emit.file"() <{file_name = "verification/assume/layers-GCD-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Assume, symbols = []}> : () -> () loc(#loc36)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> () loc(#loc37)
    }) : () -> () loc(#loc35)
  }) : () -> () loc(#loc34)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Cover", verilogName = "layers_GCD_Verification_Cover"}> : () -> () loc(#loc38)
  "emit.file"() <{file_name = "verification/cover/layers-GCD-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Cover, symbols = []}> : () -> () loc(#loc41)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> () loc(#loc42)
    }) : () -> () loc(#loc40)
  }) : () -> () loc(#loc39)
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "GCD_Class"}> ({
  ^bb0(%arg0: !om.basepath loc("./chisel/gcd/GCD.hw.mlir":50:23)):
    "om.class.fields"() : () -> () loc(#loc45)
  }) : () -> () loc(#loc43)
}) : () -> () loc(#loc)
#loc = loc("./chisel/gcd/GCD.hw.mlir":1:1)
#loc1 = loc("./chisel/gcd/GCD.hw.mlir":2:3)
#loc2 = loc("./chisel/gcd/GCD.hw.mlir":3:3)
#loc3 = loc("./chisel/gcd/GCD.hw.mlir":4:3)
#loc4 = loc("./chisel/gcd/GCD.hw.mlir":5:3)
#loc10 = loc("./chisel/gcd/GCD.hw.mlir":6:15)
#loc11 = loc("./chisel/gcd/GCD.hw.mlir":7:10)
#loc12 = loc("./chisel/gcd/GCD.hw.mlir":8:10)
#loc13 = loc("./chisel/gcd/GCD.hw.mlir":9:10)
#loc14 = loc("./chisel/gcd/GCD.hw.mlir":10:10)
#loc15 = loc("./chisel/gcd/GCD.hw.mlir":11:10)
#loc16 = loc("./chisel/gcd/GCD.hw.mlir":12:10)
#loc17 = loc("./chisel/gcd/GCD.hw.mlir":13:10)
#loc18 = loc("./chisel/gcd/GCD.hw.mlir":14:10)
#loc19 = loc("./chisel/gcd/GCD.hw.mlir":15:10)
#loc20 = loc("./chisel/gcd/GCD.hw.mlir":16:10)
#loc21 = loc("./chisel/gcd/GCD.hw.mlir":17:5)
#loc24 = loc("./chisel/gcd/GCD.hw.mlir":19:3)
#loc25 = loc("./chisel/gcd/GCD.hw.mlir":20:3)
#loc26 = loc("./chisel/gcd/GCD.hw.mlir":21:5)
#loc27 = loc("./chisel/gcd/GCD.hw.mlir":23:7)
#loc28 = loc("./chisel/gcd/GCD.hw.mlir":26:3)
#loc29 = loc("./chisel/gcd/GCD.hw.mlir":27:3)
#loc30 = loc("./chisel/gcd/GCD.hw.mlir":28:5)
#loc31 = loc("./chisel/gcd/GCD.hw.mlir":30:7)
#loc32 = loc("./chisel/gcd/GCD.hw.mlir":31:7)
#loc33 = loc("./chisel/gcd/GCD.hw.mlir":34:3)
#loc34 = loc("./chisel/gcd/GCD.hw.mlir":35:3)
#loc35 = loc("./chisel/gcd/GCD.hw.mlir":36:5)
#loc36 = loc("./chisel/gcd/GCD.hw.mlir":38:7)
#loc37 = loc("./chisel/gcd/GCD.hw.mlir":39:7)
#loc38 = loc("./chisel/gcd/GCD.hw.mlir":42:3)
#loc39 = loc("./chisel/gcd/GCD.hw.mlir":43:3)
#loc40 = loc("./chisel/gcd/GCD.hw.mlir":44:5)
#loc41 = loc("./chisel/gcd/GCD.hw.mlir":46:7)
#loc42 = loc("./chisel/gcd/GCD.hw.mlir":47:7)
#loc43 = loc("./chisel/gcd/GCD.hw.mlir":50:3)
#loc45 = loc("./chisel/gcd/GCD.hw.mlir":51:5)

