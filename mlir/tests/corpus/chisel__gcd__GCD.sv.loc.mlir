#loc44 = loc("./chisel/gcd/GCD.sv.mlir":65:21)
#loc45 = loc("./chisel/gcd/GCD.sv.mlir":65:37)
#loc46 = loc("./chisel/gcd/GCD.sv.mlir":65:53)
#loc47 = loc("./chisel/gcd/GCD.sv.mlir":65:74)
#loc48 = loc("./chisel/gcd/GCD.sv.mlir":65:95)
#loc86 = loc("./chisel/gcd/GCD.sv.mlir":65:123)
#loc87 = loc("./chisel/gcd/GCD.sv.mlir":65:147)
#loc108 = loc("./chisel/gcd/GCD.sv.mlir":147:23)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "SYNTHESIS"}> : () -> () loc(#loc1)
  "sv.macro.decl"() <{sym_name = "VERILATOR"}> : () -> () loc(#loc2)
  "emit.fragment"() <{sym_name = "RANDOM_INIT_FRAGMENT"}> ({
    "sv.verbatim"() <{format_string = "// Standard header to adapt well known macros for register randomization.", symbols = []}> : () -> () loc(#loc4)
    "sv.verbatim"() <{format_string = "\0A// RANDOM may be set to an expression that produces a 32-bit random unsigned value.", symbols = []}> : () -> () loc(#loc5)
    "sv.ifdef"() <{cond = #sv<macro.ident @RANDOM>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "$random", macroName = @RANDOM, symbols = []}> : () -> () loc(#loc7)
    }) : () -> () loc(#loc6)
    "sv.verbatim"() <{format_string = "\0A// Users can define INIT_RANDOM as general code that gets injected into the\0A// initializer block for modules with registers.", symbols = []}> : () -> () loc(#loc8)
    "sv.ifdef"() <{cond = #sv<macro.ident @INIT_RANDOM>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @INIT_RANDOM, symbols = []}> : () -> () loc(#loc10)
    }) : () -> () loc(#loc9)
    "sv.verbatim"() <{format_string = "\0A// If using random initialization, you can also define RANDOMIZE_DELAY to\0A// customize the delay used, otherwise 0.002 is used.", symbols = []}> : () -> () loc(#loc11)
    "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE_DELAY>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "0.002", macroName = @RANDOMIZE_DELAY, symbols = []}> : () -> () loc(#loc13)
    }) : () -> () loc(#loc12)
    "sv.verbatim"() <{format_string = "\0A// Define INIT_RANDOM_PROLOG_ for use in our modules below.", symbols = []}> : () -> () loc(#loc14)
    "sv.ifdef"() <{cond = #sv<macro.ident @INIT_RANDOM_PROLOG_>}> ({
    ^bb0:
    }, {
      "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE>}> ({
        "sv.ifdef"() <{cond = #sv<macro.ident @VERILATOR>}> ({
          "sv.macro.def"() <{format_string = "`INIT_RANDOM", macroName = @INIT_RANDOM_PROLOG_, symbols = []}> : () -> () loc(#loc18)
        }, {
          "sv.macro.def"() <{format_string = "`INIT_RANDOM #`RANDOMIZE_DELAY begin end", macroName = @INIT_RANDOM_PROLOG_, symbols = []}> : () -> () loc(#loc19)
        }) : () -> () loc(#loc17)
      }, {
        "sv.macro.def"() <{format_string = "", macroName = @INIT_RANDOM_PROLOG_, symbols = []}> : () -> () loc(#loc20)
      }) : () -> () loc(#loc16)
    }) : () -> () loc(#loc15)
  }) : () -> () loc(#loc3)
  "emit.fragment"() <{sym_name = "RANDOM_INIT_REG_FRAGMENT"}> ({
    "sv.verbatim"() <{format_string = "\0A// Include register initializers in init blocks unless synthesis is set", symbols = []}> : () -> () loc(#loc22)
    "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE>}> ({
    ^bb0:
    }, {
      "sv.ifdef"() <{cond = #sv<macro.ident @RANDOMIZE_REG_INIT>}> ({
        "sv.macro.def"() <{format_string = "", macroName = @RANDOMIZE, symbols = []}> : () -> () loc(#loc25)
      }, {
      }) : () -> () loc(#loc24)
    }) : () -> () loc(#loc23)
    "sv.ifdef"() <{cond = #sv<macro.ident @SYNTHESIS>}> ({
    ^bb0:
    }, {
      "sv.ifdef"() <{cond = #sv<macro.ident @ENABLE_INITIAL_REG_>}> ({
      ^bb0:
      }, {
        "sv.macro.def"() <{format_string = "", macroName = @ENABLE_INITIAL_REG_, symbols = []}> : () -> () loc(#loc28)
      }) : () -> () loc(#loc27)
    }) : () -> () loc(#loc26)
    "sv.verbatim"() <{format_string = "", symbols = []}> : () -> () loc(#loc29)
  }) : () -> () loc(#loc21)
  "sv.macro.decl"() <{sym_name = "ENABLE_INITIAL_REG_"}> : () -> () loc(#loc30)
  "sv.macro.decl"() <{sym_name = "ENABLE_INITIAL_MEM_"}> : () -> () loc(#loc31)
  "sv.macro.decl"() <{sym_name = "FIRRTL_BEFORE_INITIAL"}> : () -> () loc(#loc32)
  "sv.macro.decl"() <{sym_name = "FIRRTL_AFTER_INITIAL"}> : () -> () loc(#loc33)
  "sv.macro.decl"() <{sym_name = "RANDOMIZE_REG_INIT"}> : () -> () loc(#loc34)
  "sv.macro.decl"() <{sym_name = "RANDOMIZE"}> : () -> () loc(#loc35)
  "sv.macro.decl"() <{sym_name = "RANDOMIZE_DELAY"}> : () -> () loc(#loc36)
  "sv.macro.decl"() <{sym_name = "RANDOM"}> : () -> () loc(#loc37)
  "sv.macro.decl"() <{sym_name = "INIT_RANDOM"}> : () -> () loc(#loc38)
  "sv.macro.decl"() <{sym_name = "INIT_RANDOM_PROLOG_"}> : () -> () loc(#loc39)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> () loc(#loc40)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> () loc(#loc41)
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> () loc(#loc42)
  "hw.module"() <{module_type = !hw.modty<input clock : i1, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, parameters = [], result_locs = [#loc86, #loc87], sym_name = "GCD"}> ({
  ^bb0(%arg1: i1 loc("./chisel/gcd/GCD.sv.mlir":65:21), %arg2: i1 loc("./chisel/gcd/GCD.sv.mlir":65:37), %arg3: i16 loc("./chisel/gcd/GCD.sv.mlir":65:53), %arg4: i16 loc("./chisel/gcd/GCD.sv.mlir":65:74), %arg5: i1 loc("./chisel/gcd/GCD.sv.mlir":65:95)):
    %0 = "hw.constant"() <{value = 0 : i0}> : () -> i0 loc(#loc49)
    %1 = "hw.constant"() <{value = 0 : i16}> : () -> i16 loc(#loc50)
    %2 = "sv.reg"() <{name = "x"}> {sv.namehint = "x"} : () -> !hw.inout<i16> loc(#loc51)
    %3 = "sv.read_inout"(%2) : (!hw.inout<i16>) -> i16 loc(#loc52)
    %4 = "sv.reg"() <{name = "y"}> : () -> !hw.inout<i16> loc(#loc53)
    %5 = "sv.read_inout"(%4) : (!hw.inout<i16>) -> i16 loc(#loc54)
    %6 = "comb.icmp"(%3, %5) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1 loc(#loc55)
    %7 = "comb.sub"(%3, %5) <{twoState}> {sv.namehint = "_x_T"} : (i16, i16) -> i16 loc(#loc56)
    %8 = "comb.sub"(%5, %3) <{twoState}> {sv.namehint = "_y_T"} : (i16, i16) -> i16 loc(#loc57)
    %9 = "comb.icmp"(%5, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "io_outputValid"} : (i16, i16) -> i1 loc(#loc58)
    "sv.always"(%arg1) <{events = [0 : i32]}> ({
      "sv.if"(%arg5) ({
        "sv.passign"(%2, %arg3) : (!hw.inout<i16>, i16) -> () loc(#loc61)
        "sv.passign"(%4, %arg4) : (!hw.inout<i16>, i16) -> () loc(#loc62)
      }, {
        "sv.if"(%6) ({
          "sv.passign"(%2, %7) : (!hw.inout<i16>, i16) -> () loc(#loc64)
        }, {
          "sv.passign"(%4, %8) : (!hw.inout<i16>, i16) -> () loc(#loc65)
        }) : (i1) -> () loc(#loc63)
      }) : (i1) -> () loc(#loc60)
    }) : (i1) -> () loc(#loc59)
    "sv.ifdef"() <{cond = #sv<macro.ident @ENABLE_INITIAL_REG_>}> ({
      "sv.ordered"() ({
        "sv.ifdef"() <{cond = #sv<macro.ident @FIRRTL_BEFORE_INITIAL>}> ({
          "sv.verbatim"() <{format_string = "`FIRRTL_BEFORE_INITIAL", symbols = []}> : () -> () loc(#loc69)
        }, {
        }) : () -> () loc(#loc68)
        "sv.initial"() ({
          "sv.ifdef.procedural"() <{cond = #sv<macro.ident @INIT_RANDOM_PROLOG_>}> ({
            "sv.verbatim"() <{format_string = "`INIT_RANDOM_PROLOG_", symbols = []}> : () -> () loc(#loc72)
          }, {
          }) : () -> () loc(#loc71)
          "sv.ifdef.procedural"() <{cond = #sv<macro.ident @RANDOMIZE_REG_INIT>}> ({
            %10 = "sv.logic"() <{name = "_RANDOM"}> : () -> !hw.inout<uarray<1xi32>> loc(#loc74)
            %11 = "sv.macro.ref.expr.se"() <{macroName = @RANDOM}> : () -> i32 loc(#loc75)
            %12 = "sv.array_index_inout"(%10, %0) : (!hw.inout<uarray<1xi32>>, i0) -> !hw.inout<i32> loc(#loc76)
            "sv.bpassign"(%12, %11) : (!hw.inout<i32>, i32) -> () loc(#loc77)
            %13 = "sv.read_inout"(%12) : (!hw.inout<i32>) -> i32 loc(#loc78)
            %14 = "comb.extract"(%13) <{lowBit = 0 : i32}> : (i32) -> i16 loc(#loc79)
            "sv.bpassign"(%2, %14) : (!hw.inout<i16>, i16) -> () loc(#loc80)
            %15 = "comb.extract"(%13) <{lowBit = 16 : i32}> : (i32) -> i16 loc(#loc81)
            "sv.bpassign"(%4, %15) : (!hw.inout<i16>, i16) -> () loc(#loc82)
          }, {
          }) : () -> () loc(#loc73)
        }) : () -> () loc(#loc70)
        "sv.ifdef"() <{cond = #sv<macro.ident @FIRRTL_AFTER_INITIAL>}> ({
          "sv.verbatim"() <{format_string = "`FIRRTL_AFTER_INITIAL", symbols = []}> : () -> () loc(#loc84)
        }, {
        }) : () -> () loc(#loc83)
      }) : () -> () loc(#loc67)
    }, {
    }) : () -> () loc(#loc66)
    "hw.output"(%3, %9) : (i16, i1) -> () loc(#loc85)
  }) {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} : () -> () loc(#loc43)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification", verilogName = "layers_GCD_Verification"}> : () -> () loc(#loc88)
  "emit.file"() <{file_name = "verification/layers-GCD-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification, symbols = []}> : () -> () loc(#loc91)
    }) : () -> () loc(#loc90)
  }) : () -> () loc(#loc89)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Assert", verilogName = "layers_GCD_Verification_Assert"}> : () -> () loc(#loc92)
  "emit.file"() <{file_name = "verification/assert/layers-GCD-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Assert, symbols = []}> : () -> () loc(#loc95)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> () loc(#loc96)
    }) : () -> () loc(#loc94)
  }) : () -> () loc(#loc93)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Assume", verilogName = "layers_GCD_Verification_Assume"}> : () -> () loc(#loc97)
  "emit.file"() <{file_name = "verification/assume/layers-GCD-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Assume, symbols = []}> : () -> () loc(#loc100)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> () loc(#loc101)
    }) : () -> () loc(#loc99)
  }) : () -> () loc(#loc98)
  "sv.macro.decl"() <{sym_name = "layers_GCD_Verification_Cover", verilogName = "layers_GCD_Verification_Cover"}> : () -> () loc(#loc102)
  "emit.file"() <{file_name = "verification/cover/layers-GCD-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_GCD_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_GCD_Verification_Cover, symbols = []}> : () -> () loc(#loc105)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-GCD-Verification.sv"}> : () -> () loc(#loc106)
    }) : () -> () loc(#loc104)
  }) : () -> () loc(#loc103)
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "GCD_Class"}> ({
  ^bb0(%arg0: !om.basepath loc("./chisel/gcd/GCD.sv.mlir":147:23)):
    "om.class.fields"() : () -> () loc(#loc109)
  }) : () -> () loc(#loc107)
}) : () -> () loc(#loc)
#loc = loc("./chisel/gcd/GCD.sv.mlir":1:1)
#loc1 = loc("./chisel/gcd/GCD.sv.mlir":2:3)
#loc2 = loc("./chisel/gcd/GCD.sv.mlir":3:3)
#loc3 = loc("./chisel/gcd/GCD.sv.mlir":4:3)
#loc4 = loc("./chisel/gcd/GCD.sv.mlir":5:5)
#loc5 = loc("./chisel/gcd/GCD.sv.mlir":6:5)
#loc6 = loc("./chisel/gcd/GCD.sv.mlir":7:5)
#loc7 = loc("./chisel/gcd/GCD.sv.mlir":9:7)
#loc8 = loc("./chisel/gcd/GCD.sv.mlir":11:5)
#loc9 = loc("./chisel/gcd/GCD.sv.mlir":12:5)
#loc10 = loc("./chisel/gcd/GCD.sv.mlir":14:7)
#loc11 = loc("./chisel/gcd/GCD.sv.mlir":16:5)
#loc12 = loc("./chisel/gcd/GCD.sv.mlir":17:5)
#loc13 = loc("./chisel/gcd/GCD.sv.mlir":19:7)
#loc14 = loc("./chisel/gcd/GCD.sv.mlir":21:5)
#loc15 = loc("./chisel/gcd/GCD.sv.mlir":22:5)
#loc16 = loc("./chisel/gcd/GCD.sv.mlir":24:7)
#loc17 = loc("./chisel/gcd/GCD.sv.mlir":25:9)
#loc18 = loc("./chisel/gcd/GCD.sv.mlir":26:11)
#loc19 = loc("./chisel/gcd/GCD.sv.mlir":28:11)
#loc20 = loc("./chisel/gcd/GCD.sv.mlir":31:9)
#loc21 = loc("./chisel/gcd/GCD.sv.mlir":35:3)
#loc22 = loc("./chisel/gcd/GCD.sv.mlir":36:5)
#loc23 = loc("./chisel/gcd/GCD.sv.mlir":37:5)
#loc24 = loc("./chisel/gcd/GCD.sv.mlir":39:7)
#loc25 = loc("./chisel/gcd/GCD.sv.mlir":40:9)
#loc26 = loc("./chisel/gcd/GCD.sv.mlir":43:5)
#loc27 = loc("./chisel/gcd/GCD.sv.mlir":45:7)
#loc28 = loc("./chisel/gcd/GCD.sv.mlir":47:9)
#loc29 = loc("./chisel/gcd/GCD.sv.mlir":50:5)
#loc30 = loc("./chisel/gcd/GCD.sv.mlir":52:3)
#loc31 = loc("./chisel/gcd/GCD.sv.mlir":53:3)
#loc32 = loc("./chisel/gcd/GCD.sv.mlir":54:3)
#loc33 = loc("./chisel/gcd/GCD.sv.mlir":55:3)
#loc34 = loc("./chisel/gcd/GCD.sv.mlir":56:3)
#loc35 = loc("./chisel/gcd/GCD.sv.mlir":57:3)
#loc36 = loc("./chisel/gcd/GCD.sv.mlir":58:3)
#loc37 = loc("./chisel/gcd/GCD.sv.mlir":59:3)
#loc38 = loc("./chisel/gcd/GCD.sv.mlir":60:3)
#loc39 = loc("./chisel/gcd/GCD.sv.mlir":61:3)
#loc40 = loc("./chisel/gcd/GCD.sv.mlir":62:3)
#loc41 = loc("./chisel/gcd/GCD.sv.mlir":63:3)
#loc42 = loc("./chisel/gcd/GCD.sv.mlir":64:3)
#loc43 = loc("./chisel/gcd/GCD.sv.mlir":65:3)
#loc49 = loc("./chisel/gcd/GCD.sv.mlir":66:14)
#loc50 = loc("./chisel/gcd/GCD.sv.mlir":67:15)
#loc51 = loc("./chisel/gcd/GCD.sv.mlir":68:10)
#loc52 = loc("./chisel/gcd/GCD.sv.mlir":69:10)
#loc53 = loc("./chisel/gcd/GCD.sv.mlir":70:10)
#loc54 = loc("./chisel/gcd/GCD.sv.mlir":71:10)
#loc55 = loc("./chisel/gcd/GCD.sv.mlir":72:10)
#loc56 = loc("./chisel/gcd/GCD.sv.mlir":73:10)
#loc57 = loc("./chisel/gcd/GCD.sv.mlir":74:10)
#loc58 = loc("./chisel/gcd/GCD.sv.mlir":75:10)
#loc59 = loc("./chisel/gcd/GCD.sv.mlir":76:5)
#loc60 = loc("./chisel/gcd/GCD.sv.mlir":77:7)
#loc61 = loc("./chisel/gcd/GCD.sv.mlir":78:9)
#loc62 = loc("./chisel/gcd/GCD.sv.mlir":79:9)
#loc63 = loc("./chisel/gcd/GCD.sv.mlir":81:9)
#loc64 = loc("./chisel/gcd/GCD.sv.mlir":82:11)
#loc65 = loc("./chisel/gcd/GCD.sv.mlir":84:11)
#loc66 = loc("./chisel/gcd/GCD.sv.mlir":88:5)
#loc67 = loc("./chisel/gcd/GCD.sv.mlir":89:7)
#loc68 = loc("./chisel/gcd/GCD.sv.mlir":90:9)
#loc69 = loc("./chisel/gcd/GCD.sv.mlir":91:11)
#loc70 = loc("./chisel/gcd/GCD.sv.mlir":93:9)
#loc71 = loc("./chisel/gcd/GCD.sv.mlir":94:11)
#loc72 = loc("./chisel/gcd/GCD.sv.mlir":95:13)
#loc73 = loc("./chisel/gcd/GCD.sv.mlir":97:11)
#loc74 = loc("./chisel/gcd/GCD.sv.mlir":98:24)
#loc75 = loc("./chisel/gcd/GCD.sv.mlir":99:23)
#loc76 = loc("./chisel/gcd/GCD.sv.mlir":100:18)
#loc77 = loc("./chisel/gcd/GCD.sv.mlir":101:13)
#loc78 = loc("./chisel/gcd/GCD.sv.mlir":102:18)
#loc79 = loc("./chisel/gcd/GCD.sv.mlir":103:18)
#loc80 = loc("./chisel/gcd/GCD.sv.mlir":104:13)
#loc81 = loc("./chisel/gcd/GCD.sv.mlir":105:18)
#loc82 = loc("./chisel/gcd/GCD.sv.mlir":106:13)
#loc83 = loc("./chisel/gcd/GCD.sv.mlir":109:9)
#loc84 = loc("./chisel/gcd/GCD.sv.mlir":110:11)
#loc85 = loc("./chisel/gcd/GCD.sv.mlir":114:5)
#loc88 = loc("./chisel/gcd/GCD.sv.mlir":116:3)
#loc89 = loc("./chisel/gcd/GCD.sv.mlir":117:3)
#loc90 = loc("./chisel/gcd/GCD.sv.mlir":118:5)
#loc91 = loc("./chisel/gcd/GCD.sv.mlir":120:7)
#loc92 = loc("./chisel/gcd/GCD.sv.mlir":123:3)
#loc93 = loc("./chisel/gcd/GCD.sv.mlir":124:3)
#loc94 = loc("./chisel/gcd/GCD.sv.mlir":125:5)
#loc95 = loc("./chisel/gcd/GCD.sv.mlir":127:7)
#loc96 = loc("./chisel/gcd/GCD.sv.mlir":128:7)
#loc97 = loc("./chisel/gcd/GCD.sv.mlir":131:3)
#loc98 = loc("./chisel/gcd/GCD.sv.mlir":132:3)
#loc99 = loc("./chisel/gcd/GCD.sv.mlir":133:5)
#loc100 = loc("./chisel/gcd/GCD.sv.mlir":135:7)
#loc101 = loc("./chisel/gcd/GCD.sv.mlir":136:7)
#loc102 = loc("./chisel/gcd/GCD.sv.mlir":139:3)
#loc103 = loc("./chisel/gcd/GCD.sv.mlir":140:3)
#loc104 = loc("./chisel/gcd/GCD.sv.mlir":141:5)
#loc105 = loc("./chisel/gcd/GCD.sv.mlir":143:7)
#loc106 = loc("./chisel/gcd/GCD.sv.mlir":144:7)
#loc107 = loc("./chisel/gcd/GCD.sv.mlir":147:3)
#loc109 = loc("./chisel/gcd/GCD.sv.mlir":148:5)

