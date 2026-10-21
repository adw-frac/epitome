#loc = loc("./chisel/fir/Fir.sv.mlir":65:89)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "SYNTHESIS"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "VERILATOR"}> : () -> ()
  "emit.fragment"() <{sym_name = "RANDOM_INIT_FRAGMENT"}> ({
    "sv.verbatim"() <{format_string = "// Standard header to adapt well known macros for register randomization.", symbols = []}> : () -> ()
    "sv.verbatim"() <{format_string = "\0A// RANDOM may be set to an expression that produces a 32-bit random unsigned value.", symbols = []}> : () -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @RANDOM>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "$random", macroName = @RANDOM, symbols = []}> : () -> ()
    }) : () -> ()
    "sv.verbatim"() <{format_string = "\0A// Users can define INIT_RANDOM as general code that gets injected into the\0A// initializer block for modules with registers.", symbols = []}> : () -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @INIT_RANDOM>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @INIT_RANDOM, symbols = []}> : () -> ()
    }) : () -> ()
    "sv.verbatim"() <{format_string = "\0A// If using random initialization, you can also define RANDOMIZE_DELAY to\0A// customize the delay used, otherwise 0.002 is used.", symbols = []}> : () -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE_DELAY>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "0.002", macroName = @RANDOMIZE_DELAY, symbols = []}> : () -> ()
    }) : () -> ()
    "sv.verbatim"() <{format_string = "\0A// Define INIT_RANDOM_PROLOG_ for use in our modules below.", symbols = []}> : () -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @INIT_RANDOM_PROLOG_>}> ({
    ^bb0:
    }, {
      "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE>}> ({
        "sv.ifdef"() <{cond = #sv<macro.ident @VERILATOR>}> ({
          "sv.macro.def"() <{format_string = "`INIT_RANDOM", macroName = @INIT_RANDOM_PROLOG_, symbols = []}> : () -> ()
        }, {
          "sv.macro.def"() <{format_string = "`INIT_RANDOM #`RANDOMIZE_DELAY begin end", macroName = @INIT_RANDOM_PROLOG_, symbols = []}> : () -> ()
        }) : () -> ()
      }, {
        "sv.macro.def"() <{format_string = "", macroName = @INIT_RANDOM_PROLOG_, symbols = []}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
  "emit.fragment"() <{sym_name = "RANDOM_INIT_REG_FRAGMENT"}> ({
    "sv.verbatim"() <{format_string = "\0A// Include register initializers in init blocks unless synthesis is set", symbols = []}> : () -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE>}> ({
    ^bb0:
    }, {
      "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE_REG_INIT>}> ({
        "sv.macro.def"() <{format_string = "", macroName = @RANDOMIZE, symbols = []}> : () -> ()
      }, {
      }) : () -> ()
    }) : () -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @SYNTHESIS>}> ({
    ^bb0:
    }, {
      "sv.ifdef"() <{cond = #sv<macro.ident @ENABLE_INITIAL_REG_>}> ({
      ^bb0:
      }, {
        "sv.macro.def"() <{format_string = "", macroName = @ENABLE_INITIAL_REG_, symbols = []}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "sv.verbatim"() <{format_string = "", symbols = []}> : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "ENABLE_INITIAL_REG_"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "ENABLE_INITIAL_MEM_"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "FIRRTL_BEFORE_INITIAL"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "FIRRTL_AFTER_INITIAL"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "RANDOMIZE_REG_INIT"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "RANDOMIZE"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "RANDOMIZE_DELAY"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "RANDOM"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "INIT_RANDOM"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "INIT_RANDOM_PROLOG_"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : i1, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16>, parameters = [], result_locs = [#loc], sym_name = "Fir"}> ({
  ^bb0(%arg1: i1, %arg2: i1, %arg3: i8, %arg4: i1):
    %0 = "hw.constant"() <{value = 0 : i0}> : () -> i0
    %1 = "hw.constant"() <{value = false}> : () -> i1
    %2 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %3 = "hw.constant"() <{value = 3 : i10}> : () -> i10
    %4 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %5 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %6 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %7 = "sv.reg"() <{name = "taps_1"}> : () -> !hw.inout<i8>
    %8 = "sv.read_inout"(%7) : (!hw.inout<i8>) -> i8
    %9 = "sv.reg"() <{name = "taps_2"}> : () -> !hw.inout<i8>
    %10 = "sv.read_inout"(%9) : (!hw.inout<i8>) -> i8
    %11 = "sv.reg"() <{name = "taps_3"}> : () -> !hw.inout<i8>
    %12 = "sv.read_inout"(%11) : (!hw.inout<i8>) -> i8
    %13 = "comb.concat"(%5, %8) : (i2, i8) -> i10
    %14 = "comb.mul"(%13, %3) <{twoState}> {sv.namehint = "products_1"} : (i10, i10) -> i10
    %15 = "comb.concat"(%5, %10) : (i2, i8) -> i10
    %16 = "comb.mul"(%15, %3) <{twoState}> {sv.namehint = "products_2"} : (i10, i10) -> i10
    %17 = "comb.concat"(%4, %arg3) : (i3, i8) -> i11
    %18 = "comb.concat"(%1, %14) : (i1, i10) -> i11
    %19 = "comb.add"(%17, %18) <{twoState}> {sv.namehint = "_io_out_T"} : (i11, i11) -> i11
    %20 = "comb.concat"(%1, %19) : (i1, i11) -> i12
    %21 = "comb.concat"(%5, %16) : (i2, i10) -> i12
    %22 = "comb.add"(%20, %21) <{twoState}> {sv.namehint = "_io_out_T_1"} : (i12, i12) -> i12
    %23 = "comb.concat"(%1, %22) : (i1, i12) -> i13
    %24 = "comb.concat"(%2, %12) : (i5, i8) -> i13
    %25 = "comb.add"(%23, %24) <{twoState}> {sv.namehint = "_io_out_T_2"} : (i13, i13) -> i13
    %26 = "comb.concat"(%4, %25) {sv.namehint = "io_out"} : (i3, i13) -> i16
    "sv.always"(%arg1) <{events = [0 : i32]}> ({
      "sv.if"(%arg2) ({
        "sv.passign"(%7, %6) : (!hw.inout<i8>, i8) -> ()
        "sv.passign"(%9, %6) : (!hw.inout<i8>, i8) -> ()
        "sv.passign"(%11, %6) : (!hw.inout<i8>, i8) -> ()
      }, {
        "sv.if"(%arg4) ({
          "sv.passign"(%7, %arg3) : (!hw.inout<i8>, i8) -> ()
          "sv.passign"(%9, %8) : (!hw.inout<i8>, i8) -> ()
          "sv.passign"(%11, %10) : (!hw.inout<i8>, i8) -> ()
        }, {
        }) : (i1) -> ()
      }) : (i1) -> ()
    }) : (i1) -> ()
    "sv.ifdef"() <{cond = #sv<macro.ident @ENABLE_INITIAL_REG_>}> ({
      "sv.ordered"() ({
        "sv.ifdef"() <{cond = #sv<macro.ident @FIRRTL_BEFORE_INITIAL>}> ({
          "sv.verbatim"() <{format_string = "`FIRRTL_BEFORE_INITIAL", symbols = []}> : () -> ()
        }, {
        }) : () -> ()
        "sv.initial"() ({
          "sv.ifdef.procedural"() <{cond = #sv<macro.ident @INIT_RANDOM_PROLOG_>}> ({
            "sv.verbatim"() <{format_string = "`INIT_RANDOM_PROLOG_", symbols = []}> : () -> ()
          }, {
          }) : () -> ()
          "sv.ifdef.procedural"() <{cond = #sv<macro.ident @RANDOMIZE_REG_INIT>}> ({
            %27 = "sv.logic"() <{name = "_RANDOM"}> : () -> !hw.inout<uarray<1xi32>>
            %28 = "sv.macro.ref.expr.se"() <{macroName = @RANDOM}> : () -> i32
            %29 = "sv.array_index_inout"(%27, %0) : (!hw.inout<uarray<1xi32>>, i0) -> !hw.inout<i32>
            "sv.bpassign"(%29, %28) : (!hw.inout<i32>, i32) -> ()
            %30 = "sv.read_inout"(%29) : (!hw.inout<i32>) -> i32
            %31 = "comb.extract"(%30) <{lowBit = 0 : i32}> : (i32) -> i8
            "sv.bpassign"(%7, %31) : (!hw.inout<i8>, i8) -> ()
            %32 = "comb.extract"(%30) <{lowBit = 8 : i32}> : (i32) -> i8
            "sv.bpassign"(%9, %32) : (!hw.inout<i8>, i8) -> ()
            %33 = "comb.extract"(%30) <{lowBit = 16 : i32}> : (i32) -> i8
            "sv.bpassign"(%11, %33) : (!hw.inout<i8>, i8) -> ()
          }, {
          }) : () -> ()
        }) : () -> ()
        "sv.ifdef"() <{cond = #sv<macro.ident @FIRRTL_AFTER_INITIAL>}> ({
          "sv.verbatim"() <{format_string = "`FIRRTL_AFTER_INITIAL", symbols = []}> : () -> ()
        }, {
        }) : () -> ()
      }) : () -> ()
    }, {
    }) : () -> ()
    "hw.output"(%26) : (i16) -> ()
  }) {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} : () -> ()
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

