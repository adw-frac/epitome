#loc = loc("./chisel/counter/Counter.parse.mlir":17:31)
#loc1 = loc("./chisel/counter/Counter.parse.mlir":17:57)
#loc2 = loc("./chisel/counter/Counter.parse.mlir":17:86)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "Counter"}> ({
    "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Verification"}> ({
      "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Assert"}> ({
        "firrtl.layer"() <{convention = #firrtl<layerconvention inline>, sym_name = "Temporal"}> ({
        ^bb0:
        }) : () -> ()
      }) {output_file = #hw.output_file<"verification/assert/">} : () -> ()
      "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Assume"}> ({
        "firrtl.layer"() <{convention = #firrtl<layerconvention inline>, sym_name = "Temporal"}> ({
        ^bb0:
        }) : () -> ()
      }) {output_file = #hw.output_file<"verification/assume/">} : () -> ()
      "firrtl.layer"() <{convention = #firrtl<layerconvention bind>, sym_name = "Cover"}> ({
        "firrtl.layer"() <{convention = #firrtl<layerconvention inline>, sym_name = "Temporal"}> ({
        ^bb0:
        }) : () -> ()
      }) {output_file = #hw.output_file<"verification/cover/">} : () -> ()
    }) {output_file = #hw.output_file<"verification/">} : () -> ()
    "firrtl.module"() <{annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "Counter"}], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, true>, portLocations = [#loc, #loc1, #loc2], portNames = ["clock", "reset", "io"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.bundle<en flip: uint<1>, count: uint<8>>], sym_name = "Counter"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.bundle<en flip: uint<1>, count: uint<8>>):
      %0 = "firrtl.subfield"(%arg2) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<en flip: uint<1>, count: uint<8>>) -> !firrtl.uint<8>
      %1 = "firrtl.subfield"(%arg2) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<en flip: uint<1>, count: uint<8>>) -> !firrtl.uint<1>
      %2 = "firrtl.constant"() <{value = 0 : ui8}> : () -> !firrtl.const.uint<8>
      %3 = "firrtl.regreset"(%arg0, %arg1, %2) <{annotations = [], name = "reg", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>) -> !firrtl.uint<8>
      %4 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.const.uint<1>
      "firrtl.when"(%1) ({
        %5 = "firrtl.add"(%3, %4) : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9>
        %6 = "firrtl.node"(%5) <{annotations = [], name = "_reg_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<9>) -> !firrtl.uint<9>
        %7 = "firrtl.tail"(%6) <{amount = 1 : i32}> : (!firrtl.uint<9>) -> !firrtl.uint<8>
        %8 = "firrtl.node"(%7) <{annotations = [], name = "_reg_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
        "firrtl.matchingconnect"(%3, %8) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      }, {
      }) : (!firrtl.uint<1>) -> ()
      "firrtl.matchingconnect"(%0, %3) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

