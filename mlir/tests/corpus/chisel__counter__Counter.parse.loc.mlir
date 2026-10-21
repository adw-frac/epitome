#loc10 = loc("./chisel/counter/Counter.parse.mlir":17:31)
#loc11 = loc("./chisel/counter/Counter.parse.mlir":17:57)
#loc12 = loc("./chisel/counter/Counter.parse.mlir":17:86)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "Counter"}> ({
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
    "firrtl.module"() <{annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "Counter"}], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, true>, portLocations = [#loc10, #loc11, #loc12], portNames = ["clock", "reset", "io"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.bundle<en flip: uint<1>, count: uint<8>>], sym_name = "Counter"}> ({
    ^bb0(%arg0: !firrtl.clock loc("./chisel/counter/Counter.parse.mlir":17:31), %arg1: !firrtl.uint<1> loc("./chisel/counter/Counter.parse.mlir":17:57), %arg2: !firrtl.bundle<en flip: uint<1>, count: uint<8>> loc("./chisel/counter/Counter.parse.mlir":17:86)):
      %0 = "firrtl.subfield"(%arg2) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<en flip: uint<1>, count: uint<8>>) -> !firrtl.uint<8> loc(#loc13)
      %1 = "firrtl.subfield"(%arg2) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<en flip: uint<1>, count: uint<8>>) -> !firrtl.uint<1> loc(#loc14)
      %2 = "firrtl.constant"() <{value = 0 : ui8}> : () -> !firrtl.const.uint<8> loc(#loc15)
      %3 = "firrtl.regreset"(%arg0, %arg1, %2) <{annotations = [], name = "reg", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>) -> !firrtl.uint<8> loc(#loc16)
      %4 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.const.uint<1> loc(#loc17)
      "firrtl.when"(%1) ({
        %5 = "firrtl.add"(%3, %4) : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9> loc(#loc19)
        %6 = "firrtl.node"(%5) <{annotations = [], name = "_reg_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<9>) -> !firrtl.uint<9> loc(#loc20)
        %7 = "firrtl.tail"(%6) <{amount = 1 : i32}> : (!firrtl.uint<9>) -> !firrtl.uint<8> loc(#loc21)
        %8 = "firrtl.node"(%7) <{annotations = [], name = "_reg_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8> loc(#loc22)
        "firrtl.matchingconnect"(%3, %8) : (!firrtl.uint<8>, !firrtl.uint<8>) -> () loc(#loc23)
      }, {
      }) : (!firrtl.uint<1>) -> () loc(#loc18)
      "firrtl.matchingconnect"(%0, %3) : (!firrtl.uint<8>, !firrtl.uint<8>) -> () loc(#loc24)
    }) : () -> () loc(#loc9)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./chisel/counter/Counter.parse.mlir":1:1)
#loc1 = loc("./chisel/counter/Counter.parse.mlir":2:3)
#loc2 = loc("./chisel/counter/Counter.parse.mlir":3:5)
#loc3 = loc("./chisel/counter/Counter.parse.mlir":4:7)
#loc4 = loc("./chisel/counter/Counter.parse.mlir":5:9)
#loc5 = loc("./chisel/counter/Counter.parse.mlir":8:7)
#loc6 = loc("./chisel/counter/Counter.parse.mlir":9:9)
#loc7 = loc("./chisel/counter/Counter.parse.mlir":12:7)
#loc8 = loc("./chisel/counter/Counter.parse.mlir":13:9)
#loc9 = loc("./chisel/counter/Counter.parse.mlir":17:5)
#loc13 = loc("./chisel/counter/Counter.parse.mlir":18:12)
#loc14 = loc("./chisel/counter/Counter.parse.mlir":19:12)
#loc15 = loc("./chisel/counter/Counter.parse.mlir":20:17)
#loc16 = loc("./chisel/counter/Counter.parse.mlir":21:14)
#loc17 = loc("./chisel/counter/Counter.parse.mlir":22:17)
#loc18 = loc("./chisel/counter/Counter.parse.mlir":23:7)
#loc19 = loc("./chisel/counter/Counter.parse.mlir":24:14)
#loc20 = loc("./chisel/counter/Counter.parse.mlir":25:19)
#loc21 = loc("./chisel/counter/Counter.parse.mlir":26:14)
#loc22 = loc("./chisel/counter/Counter.parse.mlir":27:21)
#loc23 = loc("./chisel/counter/Counter.parse.mlir":28:9)
#loc24 = loc("./chisel/counter/Counter.parse.mlir":30:7)

