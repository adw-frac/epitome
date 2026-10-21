#loc = loc("./chisel/gcd/GCD.sv.mlir":65:123)
#loc1 = loc("./chisel/gcd/GCD.sv.mlir":65:147)
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
  "hw.module"() <{module_type = !hw.modty<input clock : i1, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, parameters = [], result_locs = [#loc, #loc1], sym_name = "GCD"}> ({
  ^bb0(%arg1: i1, %arg2: i1, %arg3: i16, %arg4: i16, %arg5: i1):
    %0 = "hw.constant"() <{value = 0 : i0}> : () -> i0
    %1 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %2 = "sv.reg"() <{name = "x"}> {sv.namehint = "x"} : () -> !hw.inout<i16>
    %3 = "sv.read_inout"(%2) : (!hw.inout<i16>) -> i16
    %4 = "sv.reg"() <{name = "y"}> : () -> !hw.inout<i16>
    %5 = "sv.read_inout"(%4) : (!hw.inout<i16>) -> i16
    %6 = "comb.icmp"(%3, %5) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1
    %7 = "comb.sub"(%3, %5) <{twoState}> {sv.namehint = "_x_T"} : (i16, i16) -> i16
    %8 = "comb.sub"(%5, %3) <{twoState}> {sv.namehint = "_y_T"} : (i16, i16) -> i16
    %9 = "comb.icmp"(%5, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "io_outputValid"} : (i16, i16) -> i1
    "sv.always"(%arg1) <{events = [0 : i32]}> ({
      "sv.if"(%arg5) ({
        "sv.passign"(%2, %arg3) : (!hw.inout<i16>, i16) -> ()
        "sv.passign"(%4, %arg4) : (!hw.inout<i16>, i16) -> ()
      }, {
        "sv.if"(%6) ({
          "sv.passign"(%2, %7) : (!hw.inout<i16>, i16) -> ()
        }, {
          "sv.passign"(%4, %8) : (!hw.inout<i16>, i16) -> ()
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
            %10 = "sv.logic"() <{name = "_RANDOM"}> : () -> !hw.inout<uarray<1xi32>>
            %11 = "sv.macro.ref.expr.se"() <{macroName = @RANDOM}> : () -> i32
            %12 = "sv.array_index_inout"(%10, %0) : (!hw.inout<uarray<1xi32>>, i0) -> !hw.inout<i32>
            "sv.bpassign"(%12, %11) : (!hw.inout<i32>, i32) -> ()
            %13 = "sv.read_inout"(%12) : (!hw.inout<i32>) -> i32
            %14 = "comb.extract"(%13) <{lowBit = 0 : i32}> : (i32) -> i16
            "sv.bpassign"(%2, %14) : (!hw.inout<i16>, i16) -> ()
            %15 = "comb.extract"(%13) <{lowBit = 16 : i32}> : (i32) -> i16
            "sv.bpassign"(%4, %15) : (!hw.inout<i16>, i16) -> ()
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
    "hw.output"(%3, %9) : (i16, i1) -> ()
  }) {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} : () -> ()
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

