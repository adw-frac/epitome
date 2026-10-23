#loc = loc("./chisel/fir/Fir.parse.mlir":17:27)
#loc1 = loc("./chisel/fir/Fir.parse.mlir":17:53)
#loc2 = loc("./chisel/fir/Fir.parse.mlir":17:82)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "Fir"}> ({
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
    "firrtl.module"() <{annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "Fir"}], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, true>, portLocations = [#loc, #loc1, #loc2], portNames = ["clock", "reset", "io"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>], sym_name = "Fir"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>):
      %0 = "firrtl.subfield"(%arg2) <{fieldIndex = 2 : i32}> : (!firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>) -> !firrtl.uint<16>
      %1 = "firrtl.subfield"(%arg2) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>) -> !firrtl.uint<8>
      %2 = "firrtl.subfield"(%arg2) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>) -> !firrtl.uint<1>
      %3 = "firrtl.constant"() <{value = 0 : ui8}> : () -> !firrtl.const.uint<8>
      %4 = "firrtl.regreset"(%arg0, %arg1, %3) <{annotations = [], name = "taps_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>) -> !firrtl.uint<8>
      %5 = "firrtl.regreset"(%arg0, %arg1, %3) <{annotations = [], name = "taps_2", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>) -> !firrtl.uint<8>
      %6 = "firrtl.regreset"(%arg0, %arg1, %3) <{annotations = [], name = "taps_3", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>) -> !firrtl.uint<8>
      "firrtl.when"(%2) ({
        "firrtl.matchingconnect"(%4, %1) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
        "firrtl.matchingconnect"(%5, %4) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
        "firrtl.matchingconnect"(%6, %5) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      }, {
      }) : (!firrtl.uint<1>) -> ()
      %7 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.const.uint<1>
      %8 = "firrtl.mul"(%1, %7) : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9>
      %9 = "firrtl.node"(%8) <{annotations = [], name = "products_0", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<9>) -> !firrtl.uint<9>
      %10 = "firrtl.constant"() <{value = 3 : ui2}> : () -> !firrtl.const.uint<2>
      %11 = "firrtl.mul"(%4, %10) : (!firrtl.uint<8>, !firrtl.const.uint<2>) -> !firrtl.uint<10>
      %12 = "firrtl.node"(%11) <{annotations = [], name = "products_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<10>) -> !firrtl.uint<10>
      %13 = "firrtl.mul"(%5, %10) : (!firrtl.uint<8>, !firrtl.const.uint<2>) -> !firrtl.uint<10>
      %14 = "firrtl.node"(%13) <{annotations = [], name = "products_2", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<10>) -> !firrtl.uint<10>
      %15 = "firrtl.mul"(%6, %7) : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9>
      %16 = "firrtl.node"(%15) <{annotations = [], name = "products_3", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<9>) -> !firrtl.uint<9>
      %17 = "firrtl.add"(%9, %12) : (!firrtl.uint<9>, !firrtl.uint<10>) -> !firrtl.uint<11>
      %18 = "firrtl.node"(%17) <{annotations = [], name = "_io_out_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<11>) -> !firrtl.uint<11>
      %19 = "firrtl.add"(%18, %14) : (!firrtl.uint<11>, !firrtl.uint<10>) -> !firrtl.uint<12>
      %20 = "firrtl.node"(%19) <{annotations = [], name = "_io_out_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<12>) -> !firrtl.uint<12>
      %21 = "firrtl.add"(%20, %16) : (!firrtl.uint<12>, !firrtl.uint<9>) -> !firrtl.uint<13>
      %22 = "firrtl.node"(%21) <{annotations = [], name = "_io_out_T_2", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<13>) -> !firrtl.uint<13>
      %23 = "firrtl.pad"(%22) <{amount = 16 : i32}> : (!firrtl.uint<13>) -> !firrtl.uint<16>
      "firrtl.matchingconnect"(%0, %23) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

