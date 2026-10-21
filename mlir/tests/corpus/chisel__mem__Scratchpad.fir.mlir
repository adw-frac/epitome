#loc = loc("./chisel/mem/Scratchpad.fir.mlir":17:34)
#loc1 = loc("./chisel/mem/Scratchpad.fir.mlir":17:60)
#loc2 = loc("./chisel/mem/Scratchpad.fir.mlir":17:88)
#loc3 = loc("./chisel/mem/Scratchpad.fir.mlir":17:120)
#loc4 = loc("./chisel/mem/Scratchpad.fir.mlir":17:152)
#loc5 = loc("./chisel/mem/Scratchpad.fir.mlir":17:181)
#loc6 = loc("./chisel/mem/Scratchpad.fir.mlir":17:212)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "Scratchpad"}> ({
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
    "firrtl.module"() <{annotations = [], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, false, true, false, false, false>, portLocations = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6], portNames = ["clock", "reset", "io_raddr", "io_rdata", "io_wen", "io_waddr", "io_wdata"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<4>, !firrtl.uint<32>, !firrtl.uint<1>, !firrtl.uint<4>, !firrtl.uint<32>], sym_name = "Scratchpad"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.uint<4>, %arg3: !firrtl.uint<32>, %arg4: !firrtl.uint<1>, %arg5: !firrtl.uint<4>, %arg6: !firrtl.uint<32>):
      %0 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.uint<1>
      %1 = "firrtl.wire"() <{annotations = [], name = "io_rdata", nameKind = #firrtl<name_kind droppable_name>}> : () -> !firrtl.uint<32>
      "firrtl.matchingconnect"(%arg3, %1) : (!firrtl.uint<32>, !firrtl.uint<32>) -> ()
      %2:2 = "firrtl.mem"() <{annotations = [], depth = 16 : i64, name = "mem", nameKind = #firrtl<name_kind droppable_name>, portAnnotations = [[], []], portNames = ["MPORT", "io_rdata_MPORT"], readLatency = 1 : i32, ruw = #firrtl<ruwbehavior Undefined>, writeLatency = 1 : i32}> : () -> (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>, !firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>)
      %3 = "firrtl.subfield"(%2#0) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>) -> !firrtl.uint<4>
      %4 = "firrtl.subfield"(%2#0) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>) -> !firrtl.uint<1>
      %5 = "firrtl.subfield"(%2#0) <{fieldIndex = 2 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>) -> !firrtl.clock
      %6 = "firrtl.subfield"(%2#0) <{fieldIndex = 3 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>) -> !firrtl.uint<32>
      %7 = "firrtl.subfield"(%2#0) <{fieldIndex = 4 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data: uint<32>, mask: uint<1>>) -> !firrtl.uint<1>
      %8 = "firrtl.subfield"(%2#1) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>) -> !firrtl.uint<4>
      %9 = "firrtl.subfield"(%2#1) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>) -> !firrtl.uint<1>
      %10 = "firrtl.subfield"(%2#1) <{fieldIndex = 2 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>) -> !firrtl.clock
      %11 = "firrtl.subfield"(%2#1) <{fieldIndex = 3 : i32}> : (!firrtl.bundle<addr: uint<4>, en: uint<1>, clk: clock, data flip: uint<32>>) -> !firrtl.uint<32>
      "firrtl.matchingconnect"(%9, %0) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      "firrtl.matchingconnect"(%8, %arg2) : (!firrtl.uint<4>, !firrtl.uint<4>) -> ()
      "firrtl.matchingconnect"(%10, %arg0) : (!firrtl.clock, !firrtl.clock) -> ()
      "firrtl.matchingconnect"(%1, %11) : (!firrtl.uint<32>, !firrtl.uint<32>) -> ()
      "firrtl.matchingconnect"(%3, %arg5) : (!firrtl.uint<4>, !firrtl.uint<4>) -> ()
      "firrtl.matchingconnect"(%4, %arg4) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      "firrtl.matchingconnect"(%5, %arg0) : (!firrtl.clock, !firrtl.clock) -> ()
      "firrtl.matchingconnect"(%7, %0) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      "firrtl.matchingconnect"(%6, %arg6) : (!firrtl.uint<32>, !firrtl.uint<32>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

