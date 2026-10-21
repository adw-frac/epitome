#loc = loc("./chisel/fir/Fir.fir.mlir":17:27)
#loc1 = loc("./chisel/fir/Fir.fir.mlir":17:53)
#loc2 = loc("./chisel/fir/Fir.fir.mlir":17:81)
#loc3 = loc("./chisel/fir/Fir.fir.mlir":17:109)
#loc4 = loc("./chisel/fir/Fir.fir.mlir":17:141)
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
    "firrtl.module"() <{annotations = [], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, false, false, true>, portLocations = [#loc, #loc1, #loc2, #loc3, #loc4], portNames = ["clock", "reset", "io_in", "io_valid", "io_out"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<1>, !firrtl.uint<16>], sym_name = "Fir"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.uint<8>, %arg3: !firrtl.uint<1>, %arg4: !firrtl.uint<16>):
      %0 = "firrtl.constant"() <{value = 3 : ui2}> : () -> !firrtl.uint<2>
      %1 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.uint<1>
      %2 = "firrtl.constant"() <{value = 0 : ui8}> : () -> !firrtl.uint<8>
      %3 = "firrtl.wire"() <{annotations = [], name = "io_out", nameKind = #firrtl<name_kind droppable_name>}> : () -> !firrtl.uint<16>
      "firrtl.matchingconnect"(%arg4, %3) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
      %4 = "firrtl.regreset"(%arg0, %arg1, %2) <{annotations = [], name = "taps_1", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 0 : ui64} : (!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>) -> !firrtl.uint<8>
      %5 = "firrtl.regreset"(%arg0, %arg1, %2) <{annotations = [], name = "taps_2", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 8 : ui64} : (!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>) -> !firrtl.uint<8>
      %6 = "firrtl.regreset"(%arg0, %arg1, %2) <{annotations = [], name = "taps_3", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 16 : ui64} : (!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>) -> !firrtl.uint<8>
      %7 = "firrtl.mux"(%arg3, %arg2, %4) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%4, %7) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %8 = "firrtl.mux"(%arg3, %4, %5) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%5, %8) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %9 = "firrtl.mux"(%arg3, %5, %6) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%6, %9) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %10 = "firrtl.mul"(%arg2, %1) {name = "products_0"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9>
      %11 = "firrtl.mul"(%4, %0) {name = "products_1"} : (!firrtl.uint<8>, !firrtl.uint<2>) -> !firrtl.uint<10>
      %12 = "firrtl.mul"(%5, %0) {name = "products_2"} : (!firrtl.uint<8>, !firrtl.uint<2>) -> !firrtl.uint<10>
      %13 = "firrtl.mul"(%6, %1) {name = "products_3"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9>
      %14 = "firrtl.add"(%10, %11) {name = "_io_out_T"} : (!firrtl.uint<9>, !firrtl.uint<10>) -> !firrtl.uint<11>
      %15 = "firrtl.add"(%14, %12) {name = "_io_out_T_1"} : (!firrtl.uint<11>, !firrtl.uint<10>) -> !firrtl.uint<12>
      %16 = "firrtl.add"(%15, %13) {name = "_io_out_T_2"} : (!firrtl.uint<12>, !firrtl.uint<9>) -> !firrtl.uint<13>
      %17 = "firrtl.pad"(%16) <{amount = 16 : i32}> : (!firrtl.uint<13>) -> !firrtl.uint<16>
      "firrtl.matchingconnect"(%3, %17) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

