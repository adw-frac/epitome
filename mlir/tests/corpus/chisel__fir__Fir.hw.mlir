#loc = loc("./chisel/fir/Fir.hw.mlir":5:97)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16>, parameters = [], result_locs = [#loc], sym_name = "Fir"}> ({
  ^bb0(%arg1: !seq.clock, %arg2: i1, %arg3: i8, %arg4: i1):
    %0 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %1 = "hw.constant"() <{value = 3 : i10}> : () -> i10
    %2 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %3 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %4 = "hw.constant"() <{value = false}> : () -> i1
    %5 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %6 = "seq.firreg"(%9, %arg1, %arg2, %5) <{name = "taps_1"}> {firrtl.random_init_start = 0 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %7 = "seq.firreg"(%10, %arg1, %arg2, %5) <{name = "taps_2"}> {firrtl.random_init_start = 8 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %8 = "seq.firreg"(%11, %arg1, %arg2, %5) <{name = "taps_3"}> {firrtl.random_init_start = 16 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %9 = "comb.mux"(%arg4, %arg3, %6) <{twoState}> : (i1, i8, i8) -> i8
    %10 = "comb.mux"(%arg4, %6, %7) <{twoState}> : (i1, i8, i8) -> i8
    %11 = "comb.mux"(%arg4, %7, %8) <{twoState}> : (i1, i8, i8) -> i8
    %12 = "comb.concat"(%3, %6) : (i2, i8) -> i10
    %13 = "comb.mul"(%12, %1) <{twoState}> {sv.namehint = "products_1"} : (i10, i10) -> i10
    %14 = "comb.concat"(%3, %7) : (i2, i8) -> i10
    %15 = "comb.mul"(%14, %1) <{twoState}> {sv.namehint = "products_2"} : (i10, i10) -> i10
    %16 = "comb.concat"(%2, %arg3) : (i3, i8) -> i11
    %17 = "comb.concat"(%4, %13) : (i1, i10) -> i11
    %18 = "comb.add"(%16, %17) <{twoState}> {sv.namehint = "_io_out_T"} : (i11, i11) -> i11
    %19 = "comb.concat"(%4, %18) : (i1, i11) -> i12
    %20 = "comb.concat"(%3, %15) : (i2, i10) -> i12
    %21 = "comb.add"(%19, %20) <{twoState}> {sv.namehint = "_io_out_T_1"} : (i12, i12) -> i12
    %22 = "comb.concat"(%4, %21) : (i1, i12) -> i13
    %23 = "comb.concat"(%0, %8) : (i5, i8) -> i13
    %24 = "comb.add"(%22, %23) <{twoState}> {sv.namehint = "_io_out_T_2"} : (i13, i13) -> i13
    %25 = "comb.concat"(%2, %24) {sv.namehint = "io_out"} : (i3, i13) -> i16
    "hw.output"(%25) : (i16) -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir_Verification", verilogName = "layers_Fir_Verification"}> : () -> ()
  "emit.file"() <{file_name = "verification/layers-Fir-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir_Verification, symbols = []}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir_Verification_Assert", verilogName = "layers_Fir_Verification_Assert"}> : () -> ()
  "emit.file"() <{file_name = "verification/assert/layers-Fir-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir_Verification_Assert, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Fir-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir_Verification_Assume", verilogName = "layers_Fir_Verification_Assume"}> : () -> ()
  "emit.file"() <{file_name = "verification/assume/layers-Fir-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir_Verification_Assume, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Fir-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir_Verification_Cover", verilogName = "layers_Fir_Verification_Cover"}> : () -> ()
  "emit.file"() <{file_name = "verification/cover/layers-Fir-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir_Verification_Cover, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Fir-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Fir_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

