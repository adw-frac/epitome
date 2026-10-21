#loc = loc("./chisel/gcd/GCD.fir.mlir":17:27)
#loc1 = loc("./chisel/gcd/GCD.fir.mlir":17:53)
#loc2 = loc("./chisel/gcd/GCD.fir.mlir":17:81)
#loc3 = loc("./chisel/gcd/GCD.fir.mlir":17:114)
#loc4 = loc("./chisel/gcd/GCD.fir.mlir":17:147)
#loc5 = loc("./chisel/gcd/GCD.fir.mlir":17:187)
#loc6 = loc("./chisel/gcd/GCD.fir.mlir":17:224)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "GCD"}> ({
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
    "firrtl.module"() <{annotations = [], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, false, false, false, true, true>, portLocations = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6], portNames = ["clock", "reset", "io_value1", "io_value2", "io_loadingValues", "io_outputGCD", "io_outputValid"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>, !firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<1>], sym_name = "GCD"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.uint<16>, %arg3: !firrtl.uint<16>, %arg4: !firrtl.uint<1>, %arg5: !firrtl.uint<16>, %arg6: !firrtl.uint<1>):
      %0 = "firrtl.wire"() <{annotations = [], name = "io_outputGCD", nameKind = #firrtl<name_kind droppable_name>}> : () -> !firrtl.uint<16>
      %1 = "firrtl.wire"() <{annotations = [], name = "io_outputValid", nameKind = #firrtl<name_kind droppable_name>}> : () -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%arg5, %0) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
      "firrtl.matchingconnect"(%arg6, %1) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      %2 = "firrtl.reg"(%arg0) <{annotations = [], name = "x", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 0 : ui64} : (!firrtl.clock) -> !firrtl.uint<16>
      %3 = "firrtl.reg"(%arg0) <{annotations = [], name = "y", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 16 : ui64} : (!firrtl.clock) -> !firrtl.uint<16>
      %4 = "firrtl.gt"(%2, %3) : (!firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<1>
      %5 = "firrtl.sub"(%2, %3) {name = "_x_T"} : (!firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<17>
      %6 = "firrtl.bits"(%5) <{hi = 15 : i32, lo = 0 : i32}> {name = "_x_T_1"} : (!firrtl.uint<17>) -> !firrtl.uint<16>
      %7 = "firrtl.mux"(%4, %6, %2) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      %8 = "firrtl.sub"(%3, %2) {name = "_y_T"} : (!firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<17>
      %9 = "firrtl.bits"(%8) <{hi = 15 : i32, lo = 0 : i32}> {name = "_y_T_1"} : (!firrtl.uint<17>) -> !firrtl.uint<16>
      %10 = "firrtl.mux"(%4, %3, %9) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      %11 = "firrtl.mux"(%arg4, %arg2, %7) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      "firrtl.matchingconnect"(%2, %11) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
      %12 = "firrtl.mux"(%arg4, %arg3, %10) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      "firrtl.matchingconnect"(%3, %12) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
      "firrtl.matchingconnect"(%0, %2) : (!firrtl.uint<16>, !firrtl.uint<16>) -> ()
      %13 = "firrtl.orr"(%3) : (!firrtl.uint<16>) -> !firrtl.uint<1>
      %14 = "firrtl.not"(%13) {name = "_io_outputValid_T"} : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%1, %14) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

