#loc = loc("./chisel/counter/Counter.fir.mlir":17:31)
#loc1 = loc("./chisel/counter/Counter.fir.mlir":17:57)
#loc2 = loc("./chisel/counter/Counter.fir.mlir":17:85)
#loc3 = loc("./chisel/counter/Counter.fir.mlir":17:114)
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
    "firrtl.module"() <{annotations = [], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, false, true>, portLocations = [#loc, #loc1, #loc2, #loc3], portNames = ["clock", "reset", "io_en", "io_count"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<1>, !firrtl.uint<8>], sym_name = "Counter"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.uint<1>, %arg3: !firrtl.uint<8>):
      %0 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.uint<1>
      %1 = "firrtl.constant"() <{value = 0 : ui8}> : () -> !firrtl.uint<8>
      %2 = "firrtl.wire"() <{annotations = [], name = "io_count", nameKind = #firrtl<name_kind droppable_name>}> : () -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg3, %2) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %3 = "firrtl.regreset"(%arg0, %arg1, %1) <{annotations = [], name = "reg", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 0 : ui64} : (!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>) -> !firrtl.uint<8>
      %4 = "firrtl.add"(%3, %0) {name = "_reg_T"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9>
      %5 = "firrtl.bits"(%4) <{hi = 7 : i32, lo = 0 : i32}> {name = "_reg_T_1"} : (!firrtl.uint<9>) -> !firrtl.uint<8>
      %6 = "firrtl.mux"(%arg2, %5, %3) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%3, %6) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      "firrtl.matchingconnect"(%2, %3) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

