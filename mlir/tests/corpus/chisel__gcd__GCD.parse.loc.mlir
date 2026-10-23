#loc10 = loc("./chisel/gcd/GCD.parse.mlir":17:27)
#loc11 = loc("./chisel/gcd/GCD.parse.mlir":17:53)
#loc12 = loc("./chisel/gcd/GCD.parse.mlir":17:82)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "GCD"}> ({
    "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Verification"}> ({
      "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Assert"}> ({
        "firrtl.layer"() <{convention = #firrtl<layerconvention inline>, sym_name = "Temporal"}> ({
        ^bb0:
        }) : () -> () loc(#loc4)
      }) {output_file = #hw.output_file<"verification/assert/">} : () -> () loc(#loc3)
      "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Assume"}> ({
        "firrtl.layer"() <{convention = #firrtl<layerconvention inline>, sym_name = "Temporal"}> ({
        ^bb0:
        }) : () -> () loc(#loc6)
      }) {output_file = #hw.output_file<"verification/assume/">} : () -> () loc(#loc5)
      "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Cover"}> ({
        "firrtl.layer"() <{convention = #firrtl<layerconvention inline>, sym_name = "Temporal"}> ({
        ^bb0:
        }) : () -> () loc(#loc8)
      }) {output_file = #hw.output_file<"verification/cover/">} : () -> () loc(#loc7)
    }) {output_file = #hw.output_file<"verification/">} : () -> () loc(#loc2)
    "firrtl.module"() <{annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "GCD"}], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, true>, portLocations = [#loc10, #loc11, #loc12], portNames = ["clock", "reset", "io"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>], sym_name = "GCD"}> ({
    ^bb0(%arg0: !firrtl.clock loc("./chisel/gcd/GCD.parse.mlir":17:27), %arg1: !firrtl.uint<1> loc("./chisel/gcd/GCD.parse.mlir":17:53), %arg2: !firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>> loc("./chisel/gcd/GCD.parse.mlir":17:82)):
      %0 = "firrtl.subfield"(%arg2) <{fieldIndex = 4 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<1> loc(#loc13)
      %1 = "firrtl.subfield"(%arg2) <{fieldIndex = 3 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<16> loc(#loc14)
      %2 = "firrtl.subfield"(%arg2) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<16> loc(#loc15)
      %3 = "firrtl.subfield"(%arg2) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<16> loc(#loc16)
      %4 = "firrtl.subfield"(%arg2) <{fieldIndex = 2 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<1> loc(#loc17)
      %5 = "firrtl.reg"(%arg0) <{annotations = [], name = "x", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock) -> !firrtl.uint loc(#loc18)
      %6 = "firrtl.reg"(%arg0) <{annotations = [], name = "y", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock) -> !firrtl.uint loc(#loc19)
      %7 = "firrtl.gt"(%5, %6) : (!firrtl.uint, !firrtl.uint) -> !firrtl.uint<1> loc(#loc20)
      %8 = "firrtl.node"(%7) <{annotations = [], name = "_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1> loc(#loc21)
      "firrtl.when"(%8) ({
        %16 = "firrtl.sub"(%5, %6) : (!firrtl.uint, !firrtl.uint) -> !firrtl.uint loc(#loc23)
        %17 = "firrtl.node"(%16) <{annotations = [], name = "_x_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint loc(#loc24)
        %18 = "firrtl.tail"(%17) <{amount = 1 : i32}> : (!firrtl.uint) -> !firrtl.uint loc(#loc25)
        %19 = "firrtl.node"(%18) <{annotations = [], name = "_x_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint loc(#loc26)
        "firrtl.connect"(%5, %19) : (!firrtl.uint, !firrtl.uint) -> () loc(#loc27)
      }, {
        %12 = "firrtl.sub"(%6, %5) : (!firrtl.uint, !firrtl.uint) -> !firrtl.uint loc(#loc28)
        %13 = "firrtl.node"(%12) <{annotations = [], name = "_y_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint loc(#loc29)
        %14 = "firrtl.tail"(%13) <{amount = 1 : i32}> : (!firrtl.uint) -> !firrtl.uint loc(#loc30)
        %15 = "firrtl.node"(%14) <{annotations = [], name = "_y_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint loc(#loc31)
        "firrtl.connect"(%6, %15) : (!firrtl.uint, !firrtl.uint) -> () loc(#loc32)
      }) : (!firrtl.uint<1>) -> () loc(#loc22)
      "firrtl.when"(%4) ({
        "firrtl.connect"(%5, %3) : (!firrtl.uint, !firrtl.uint<16>) -> () loc(#loc34)
        "firrtl.connect"(%6, %2) : (!firrtl.uint, !firrtl.uint<16>) -> () loc(#loc35)
      }, {
      }) : (!firrtl.uint<1>) -> () loc(#loc33)
      "firrtl.connect"(%1, %5) : (!firrtl.uint<16>, !firrtl.uint) -> () loc(#loc36)
      %9 = "firrtl.constant"() <{value = 0 : ui1}> : () -> !firrtl.const.uint<1> loc(#loc37)
      %10 = "firrtl.eq"(%6, %9) : (!firrtl.uint, !firrtl.const.uint<1>) -> !firrtl.uint<1> loc(#loc38)
      %11 = "firrtl.node"(%10) <{annotations = [], name = "_io_outputValid_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1> loc(#loc39)
      "firrtl.matchingconnect"(%0, %11) : (!firrtl.uint<1>, !firrtl.uint<1>) -> () loc(#loc40)
    }) : () -> () loc(#loc9)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./chisel/gcd/GCD.parse.mlir":1:1)
#loc1 = loc("./chisel/gcd/GCD.parse.mlir":2:3)
#loc2 = loc("./chisel/gcd/GCD.parse.mlir":3:5)
#loc3 = loc("./chisel/gcd/GCD.parse.mlir":4:7)
#loc4 = loc("./chisel/gcd/GCD.parse.mlir":5:9)
#loc5 = loc("./chisel/gcd/GCD.parse.mlir":8:7)
#loc6 = loc("./chisel/gcd/GCD.parse.mlir":9:9)
#loc7 = loc("./chisel/gcd/GCD.parse.mlir":12:7)
#loc8 = loc("./chisel/gcd/GCD.parse.mlir":13:9)
#loc9 = loc("./chisel/gcd/GCD.parse.mlir":17:5)
#loc13 = loc("./chisel/gcd/GCD.parse.mlir":18:12)
#loc14 = loc("./chisel/gcd/GCD.parse.mlir":19:12)
#loc15 = loc("./chisel/gcd/GCD.parse.mlir":20:12)
#loc16 = loc("./chisel/gcd/GCD.parse.mlir":21:12)
#loc17 = loc("./chisel/gcd/GCD.parse.mlir":22:12)
#loc18 = loc("./chisel/gcd/GCD.parse.mlir":23:12)
#loc19 = loc("./chisel/gcd/GCD.parse.mlir":24:12)
#loc20 = loc("./chisel/gcd/GCD.parse.mlir":25:12)
#loc21 = loc("./chisel/gcd/GCD.parse.mlir":26:13)
#loc22 = loc("./chisel/gcd/GCD.parse.mlir":27:7)
#loc23 = loc("./chisel/gcd/GCD.parse.mlir":28:14)
#loc24 = loc("./chisel/gcd/GCD.parse.mlir":29:17)
#loc25 = loc("./chisel/gcd/GCD.parse.mlir":30:14)
#loc26 = loc("./chisel/gcd/GCD.parse.mlir":31:19)
#loc27 = loc("./chisel/gcd/GCD.parse.mlir":32:9)
#loc28 = loc("./chisel/gcd/GCD.parse.mlir":34:14)
#loc29 = loc("./chisel/gcd/GCD.parse.mlir":35:17)
#loc30 = loc("./chisel/gcd/GCD.parse.mlir":36:14)
#loc31 = loc("./chisel/gcd/GCD.parse.mlir":37:19)
#loc32 = loc("./chisel/gcd/GCD.parse.mlir":38:9)
#loc33 = loc("./chisel/gcd/GCD.parse.mlir":40:7)
#loc34 = loc("./chisel/gcd/GCD.parse.mlir":41:9)
#loc35 = loc("./chisel/gcd/GCD.parse.mlir":42:9)
#loc36 = loc("./chisel/gcd/GCD.parse.mlir":44:7)
#loc37 = loc("./chisel/gcd/GCD.parse.mlir":45:17)
#loc38 = loc("./chisel/gcd/GCD.parse.mlir":46:12)
#loc39 = loc("./chisel/gcd/GCD.parse.mlir":47:28)
#loc40 = loc("./chisel/gcd/GCD.parse.mlir":48:7)

