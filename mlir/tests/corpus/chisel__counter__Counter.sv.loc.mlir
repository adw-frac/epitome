#loc44 = loc("./chisel/counter/Counter.sv.mlir":65:25)
#loc45 = loc("./chisel/counter/Counter.sv.mlir":65:41)
#loc46 = loc("./chisel/counter/Counter.sv.mlir":65:57)
#loc76 = loc("./chisel/counter/Counter.sv.mlir":65:74)
#loc97 = loc("./chisel/counter/Counter.sv.mlir":138:27)
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
  "hw.module"() <{module_type = !hw.modty<input clock : i1, input reset : i1, input io_en : i1, output io_count : i8>, parameters = [], result_locs = [#loc76], sym_name = "Counter"}> ({
  ^bb0(%arg1: i1 loc("./chisel/counter/Counter.sv.mlir":65:25), %arg2: i1 loc("./chisel/counter/Counter.sv.mlir":65:41), %arg3: i1 loc("./chisel/counter/Counter.sv.mlir":65:57)):
    %0 = "hw.constant"() <{value = 0 : i0}> : () -> i0 loc(#loc47)
    %1 = "hw.constant"() <{value = 1 : i8}> : () -> i8 loc(#loc48)
    %2 = "hw.constant"() <{value = 0 : i8}> : () -> i8 loc(#loc49)
    %3 = "sv.reg"() <{name = "reg"}> {sv.namehint = "reg"} : () -> !hw.inout<i8> loc(#loc50)
    %4 = "sv.read_inout"(%3) : (!hw.inout<i8>) -> i8 loc(#loc51)
    %5 = "comb.add"(%4, %1) <{twoState}> {sv.namehint = "_reg_T"} : (i8, i8) -> i8 loc(#loc52)
    "sv.always"(%arg1) <{events = [0 : i32]}> ({
      "sv.if"(%arg2) ({
        "sv.passign"(%3, %2) : (!hw.inout<i8>, i8) -> () loc(#loc55)
      }, {
        "sv.if"(%arg3) ({
          "sv.passign"(%3, %5) : (!hw.inout<i8>, i8) -> () loc(#loc57)
        }, {
        }) : (i1) -> () loc(#loc56)
      }) : (i1) -> () loc(#loc54)
    }) : (i1) -> () loc(#loc53)
    "sv.ifdef"() <{cond = #sv<macro.ident @ENABLE_INITIAL_REG_>}> ({
      "sv.ordered"() ({
        "sv.ifdef"() <{cond = #sv<macro.ident @FIRRTL_BEFORE_INITIAL>}> ({
          "sv.verbatim"() <{format_string = "`FIRRTL_BEFORE_INITIAL", symbols = []}> : () -> () loc(#loc61)
        }, {
        }) : () -> () loc(#loc60)
        "sv.initial"() ({
          "sv.ifdef.procedural"() <{cond = #sv<macro.ident @INIT_RANDOM_PROLOG_>}> ({
            "sv.verbatim"() <{format_string = "`INIT_RANDOM_PROLOG_", symbols = []}> : () -> () loc(#loc64)
          }, {
          }) : () -> () loc(#loc63)
          "sv.ifdef.procedural"() <{cond = #sv<macro.ident @RANDOMIZE_REG_INIT>}> ({
            %6 = "sv.logic"() <{name = "_RANDOM"}> : () -> !hw.inout<uarray<1xi32>> loc(#loc66)
            %7 = "sv.macro.ref.expr.se"() <{macroName = @RANDOM}> : () -> i32 loc(#loc67)
            %8 = "sv.array_index_inout"(%6, %0) : (!hw.inout<uarray<1xi32>>, i0) -> !hw.inout<i32> loc(#loc68)
            "sv.bpassign"(%8, %7) : (!hw.inout<i32>, i32) -> () loc(#loc69)
            %9 = "sv.read_inout"(%8) : (!hw.inout<i32>) -> i32 loc(#loc70)
            %10 = "comb.extract"(%9) <{lowBit = 0 : i32}> : (i32) -> i8 loc(#loc71)
            "sv.bpassign"(%3, %10) : (!hw.inout<i8>, i8) -> () loc(#loc72)
          }, {
          }) : () -> () loc(#loc65)
        }) : () -> () loc(#loc62)
        "sv.ifdef"() <{cond = #sv<macro.ident @FIRRTL_AFTER_INITIAL>}> ({
          "sv.verbatim"() <{format_string = "`FIRRTL_AFTER_INITIAL", symbols = []}> : () -> () loc(#loc74)
        }, {
        }) : () -> () loc(#loc73)
      }) : () -> () loc(#loc59)
    }, {
    }) : () -> () loc(#loc58)
    "hw.output"(%4) : (i8) -> () loc(#loc75)
  }) {emit.fragments = [@RANDOM_INIT_REG_FRAGMENT, @RANDOM_INIT_FRAGMENT]} : () -> () loc(#loc43)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification", verilogName = "layers_Counter_Verification"}> : () -> () loc(#loc77)
  "emit.file"() <{file_name = "verification/layers-Counter-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification, symbols = []}> : () -> () loc(#loc80)
    }) : () -> () loc(#loc79)
  }) : () -> () loc(#loc78)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Assert", verilogName = "layers_Counter_Verification_Assert"}> : () -> () loc(#loc81)
  "emit.file"() <{file_name = "verification/assert/layers-Counter-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Assert, symbols = []}> : () -> () loc(#loc84)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> () loc(#loc85)
    }) : () -> () loc(#loc83)
  }) : () -> () loc(#loc82)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Assume", verilogName = "layers_Counter_Verification_Assume"}> : () -> () loc(#loc86)
  "emit.file"() <{file_name = "verification/assume/layers-Counter-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Assume, symbols = []}> : () -> () loc(#loc89)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> () loc(#loc90)
    }) : () -> () loc(#loc88)
  }) : () -> () loc(#loc87)
  "sv.macro.decl"() <{sym_name = "layers_Counter_Verification_Cover", verilogName = "layers_Counter_Verification_Cover"}> : () -> () loc(#loc91)
  "emit.file"() <{file_name = "verification/cover/layers-Counter-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Counter_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Counter_Verification_Cover, symbols = []}> : () -> () loc(#loc94)
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Counter-Verification.sv"}> : () -> () loc(#loc95)
    }) : () -> () loc(#loc93)
  }) : () -> () loc(#loc92)
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Counter_Class"}> ({
  ^bb0(%arg0: !om.basepath loc("./chisel/counter/Counter.sv.mlir":138:27)):
    "om.class.fields"() : () -> () loc(#loc98)
  }) : () -> () loc(#loc96)
}) : () -> () loc(#loc)
#loc = loc("./chisel/counter/Counter.sv.mlir":1:1)
#loc1 = loc("./chisel/counter/Counter.sv.mlir":2:3)
#loc2 = loc("./chisel/counter/Counter.sv.mlir":3:3)
#loc3 = loc("./chisel/counter/Counter.sv.mlir":4:3)
#loc4 = loc("./chisel/counter/Counter.sv.mlir":5:5)
#loc5 = loc("./chisel/counter/Counter.sv.mlir":6:5)
#loc6 = loc("./chisel/counter/Counter.sv.mlir":7:5)
#loc7 = loc("./chisel/counter/Counter.sv.mlir":9:7)
#loc8 = loc("./chisel/counter/Counter.sv.mlir":11:5)
#loc9 = loc("./chisel/counter/Counter.sv.mlir":12:5)
#loc10 = loc("./chisel/counter/Counter.sv.mlir":14:7)
#loc11 = loc("./chisel/counter/Counter.sv.mlir":16:5)
#loc12 = loc("./chisel/counter/Counter.sv.mlir":17:5)
#loc13 = loc("./chisel/counter/Counter.sv.mlir":19:7)
#loc14 = loc("./chisel/counter/Counter.sv.mlir":21:5)
#loc15 = loc("./chisel/counter/Counter.sv.mlir":22:5)
#loc16 = loc("./chisel/counter/Counter.sv.mlir":24:7)
#loc17 = loc("./chisel/counter/Counter.sv.mlir":25:9)
#loc18 = loc("./chisel/counter/Counter.sv.mlir":26:11)
#loc19 = loc("./chisel/counter/Counter.sv.mlir":28:11)
#loc20 = loc("./chisel/counter/Counter.sv.mlir":31:9)
#loc21 = loc("./chisel/counter/Counter.sv.mlir":35:3)
#loc22 = loc("./chisel/counter/Counter.sv.mlir":36:5)
#loc23 = loc("./chisel/counter/Counter.sv.mlir":37:5)
#loc24 = loc("./chisel/counter/Counter.sv.mlir":39:7)
#loc25 = loc("./chisel/counter/Counter.sv.mlir":40:9)
#loc26 = loc("./chisel/counter/Counter.sv.mlir":43:5)
#loc27 = loc("./chisel/counter/Counter.sv.mlir":45:7)
#loc28 = loc("./chisel/counter/Counter.sv.mlir":47:9)
#loc29 = loc("./chisel/counter/Counter.sv.mlir":50:5)
#loc30 = loc("./chisel/counter/Counter.sv.mlir":52:3)
#loc31 = loc("./chisel/counter/Counter.sv.mlir":53:3)
#loc32 = loc("./chisel/counter/Counter.sv.mlir":54:3)
#loc33 = loc("./chisel/counter/Counter.sv.mlir":55:3)
#loc34 = loc("./chisel/counter/Counter.sv.mlir":56:3)
#loc35 = loc("./chisel/counter/Counter.sv.mlir":57:3)
#loc36 = loc("./chisel/counter/Counter.sv.mlir":58:3)
#loc37 = loc("./chisel/counter/Counter.sv.mlir":59:3)
#loc38 = loc("./chisel/counter/Counter.sv.mlir":60:3)
#loc39 = loc("./chisel/counter/Counter.sv.mlir":61:3)
#loc40 = loc("./chisel/counter/Counter.sv.mlir":62:3)
#loc41 = loc("./chisel/counter/Counter.sv.mlir":63:3)
#loc42 = loc("./chisel/counter/Counter.sv.mlir":64:3)
#loc43 = loc("./chisel/counter/Counter.sv.mlir":65:3)
#loc47 = loc("./chisel/counter/Counter.sv.mlir":66:14)
#loc48 = loc("./chisel/counter/Counter.sv.mlir":67:14)
#loc49 = loc("./chisel/counter/Counter.sv.mlir":68:14)
#loc50 = loc("./chisel/counter/Counter.sv.mlir":69:12)
#loc51 = loc("./chisel/counter/Counter.sv.mlir":70:10)
#loc52 = loc("./chisel/counter/Counter.sv.mlir":71:10)
#loc53 = loc("./chisel/counter/Counter.sv.mlir":72:5)
#loc54 = loc("./chisel/counter/Counter.sv.mlir":73:7)
#loc55 = loc("./chisel/counter/Counter.sv.mlir":74:9)
#loc56 = loc("./chisel/counter/Counter.sv.mlir":76:9)
#loc57 = loc("./chisel/counter/Counter.sv.mlir":77:11)
#loc58 = loc("./chisel/counter/Counter.sv.mlir":81:5)
#loc59 = loc("./chisel/counter/Counter.sv.mlir":82:7)
#loc60 = loc("./chisel/counter/Counter.sv.mlir":83:9)
#loc61 = loc("./chisel/counter/Counter.sv.mlir":84:11)
#loc62 = loc("./chisel/counter/Counter.sv.mlir":86:9)
#loc63 = loc("./chisel/counter/Counter.sv.mlir":87:11)
#loc64 = loc("./chisel/counter/Counter.sv.mlir":88:13)
#loc65 = loc("./chisel/counter/Counter.sv.mlir":90:11)
#loc66 = loc("./chisel/counter/Counter.sv.mlir":91:24)
#loc67 = loc("./chisel/counter/Counter.sv.mlir":92:23)
#loc68 = loc("./chisel/counter/Counter.sv.mlir":93:18)
#loc69 = loc("./chisel/counter/Counter.sv.mlir":94:13)
#loc70 = loc("./chisel/counter/Counter.sv.mlir":95:18)
#loc71 = loc("./chisel/counter/Counter.sv.mlir":96:18)
#loc72 = loc("./chisel/counter/Counter.sv.mlir":97:13)
#loc73 = loc("./chisel/counter/Counter.sv.mlir":100:9)
#loc74 = loc("./chisel/counter/Counter.sv.mlir":101:11)
#loc75 = loc("./chisel/counter/Counter.sv.mlir":105:5)
#loc77 = loc("./chisel/counter/Counter.sv.mlir":107:3)
#loc78 = loc("./chisel/counter/Counter.sv.mlir":108:3)
#loc79 = loc("./chisel/counter/Counter.sv.mlir":109:5)
#loc80 = loc("./chisel/counter/Counter.sv.mlir":111:7)
#loc81 = loc("./chisel/counter/Counter.sv.mlir":114:3)
#loc82 = loc("./chisel/counter/Counter.sv.mlir":115:3)
#loc83 = loc("./chisel/counter/Counter.sv.mlir":116:5)
#loc84 = loc("./chisel/counter/Counter.sv.mlir":118:7)
#loc85 = loc("./chisel/counter/Counter.sv.mlir":119:7)
#loc86 = loc("./chisel/counter/Counter.sv.mlir":122:3)
#loc87 = loc("./chisel/counter/Counter.sv.mlir":123:3)
#loc88 = loc("./chisel/counter/Counter.sv.mlir":124:5)
#loc89 = loc("./chisel/counter/Counter.sv.mlir":126:7)
#loc90 = loc("./chisel/counter/Counter.sv.mlir":127:7)
#loc91 = loc("./chisel/counter/Counter.sv.mlir":130:3)
#loc92 = loc("./chisel/counter/Counter.sv.mlir":131:3)
#loc93 = loc("./chisel/counter/Counter.sv.mlir":132:5)
#loc94 = loc("./chisel/counter/Counter.sv.mlir":134:7)
#loc95 = loc("./chisel/counter/Counter.sv.mlir":135:7)
#loc96 = loc("./chisel/counter/Counter.sv.mlir":138:3)
#loc98 = loc("./chisel/counter/Counter.sv.mlir":139:5)

