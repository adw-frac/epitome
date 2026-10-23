#loc10 = loc("./chisel/counter/Counter.fir.mlir":17:31)
#loc11 = loc("./chisel/counter/Counter.fir.mlir":17:57)
#loc12 = loc("./chisel/counter/Counter.fir.mlir":17:85)
#loc13 = loc("./chisel/counter/Counter.fir.mlir":17:114)
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
    "firrtl.module"() <{annotations = [], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, false, true>, portLocations = [#loc10, #loc11, #loc12, #loc13], portNames = ["clock", "reset", "io_en", "io_count"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<1>, !firrtl.uint<8>], sym_name = "Counter"}> ({
    ^bb0(%arg0: !firrtl.clock loc("./chisel/counter/Counter.fir.mlir":17:31), %arg1: !firrtl.uint<1> loc("./chisel/counter/Counter.fir.mlir":17:57), %arg2: !firrtl.uint<1> loc("./chisel/counter/Counter.fir.mlir":17:85), %arg3: !firrtl.uint<8> loc("./chisel/counter/Counter.fir.mlir":17:114)):
      %0 = "firrtl.constant"() <{value = 1 : ui1}> : () -> !firrtl.uint<1> loc(#loc14)
      %1 = "firrtl.constant"() <{value = 0 : ui8}> : () -> !firrtl.uint<8> loc(#loc15)
      %2 = "firrtl.wire"() <{annotations = [], name = "io_count", nameKind = #firrtl<name_kind droppable_name>}> : () -> !firrtl.uint<8> loc(#loc16)
      "firrtl.matchingconnect"(%arg3, %2) : (!firrtl.uint<8>, !firrtl.uint<8>) -> () loc(#loc17)
      %3 = "firrtl.regreset"(%arg0, %arg1, %1) <{annotations = [], name = "reg", nameKind = #firrtl<name_kind droppable_name>}> {firrtl.random_init_start = 0 : ui64} : (!firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>) -> !firrtl.uint<8> loc(#loc18)
      %4 = "firrtl.add"(%3, %0) {name = "_reg_T"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9> loc(#loc19)
      %5 = "firrtl.bits"(%4) <{hi = 7 : i32, lo = 0 : i32}> {name = "_reg_T_1"} : (!firrtl.uint<9>) -> !firrtl.uint<8> loc(#loc20)
      %6 = "firrtl.mux"(%arg2, %5, %3) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8> loc(#loc21)
      "firrtl.matchingconnect"(%3, %6) : (!firrtl.uint<8>, !firrtl.uint<8>) -> () loc(#loc22)
      "firrtl.matchingconnect"(%2, %3) : (!firrtl.uint<8>, !firrtl.uint<8>) -> () loc(#loc23)
    }) : () -> () loc(#loc9)
  }) : () -> () loc(#loc1)
}) : () -> () loc(#loc)
#loc = loc("./chisel/counter/Counter.fir.mlir":1:1)
#loc1 = loc("./chisel/counter/Counter.fir.mlir":2:3)
#loc2 = loc("./chisel/counter/Counter.fir.mlir":3:5)
#loc3 = loc("./chisel/counter/Counter.fir.mlir":4:7)
#loc4 = loc("./chisel/counter/Counter.fir.mlir":5:9)
#loc5 = loc("./chisel/counter/Counter.fir.mlir":8:7)
#loc6 = loc("./chisel/counter/Counter.fir.mlir":9:9)
#loc7 = loc("./chisel/counter/Counter.fir.mlir":12:7)
#loc8 = loc("./chisel/counter/Counter.fir.mlir":13:9)
#loc9 = loc("./chisel/counter/Counter.fir.mlir":17:5)
#loc14 = loc("./chisel/counter/Counter.fir.mlir":18:17)
#loc15 = loc("./chisel/counter/Counter.fir.mlir":19:17)
#loc16 = loc("./chisel/counter/Counter.fir.mlir":20:21)
#loc17 = loc("./chisel/counter/Counter.fir.mlir":21:7)
#loc18 = loc("./chisel/counter/Counter.fir.mlir":22:14)
#loc19 = loc("./chisel/counter/Counter.fir.mlir":23:17)
#loc20 = loc("./chisel/counter/Counter.fir.mlir":24:19)
#loc21 = loc("./chisel/counter/Counter.fir.mlir":25:12)
#loc22 = loc("./chisel/counter/Counter.fir.mlir":26:7)
#loc23 = loc("./chisel/counter/Counter.fir.mlir":27:7)

