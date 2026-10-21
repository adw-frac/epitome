#loc = loc("./chisel/gcd/GCD.parse.mlir":17:27)
#loc1 = loc("./chisel/gcd/GCD.parse.mlir":17:53)
#loc2 = loc("./chisel/gcd/GCD.parse.mlir":17:82)
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
    "firrtl.module"() <{annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "GCD"}], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, true>, portLocations = [#loc, #loc1, #loc2], portNames = ["clock", "reset", "io"], portSymbols = [], portTypes = [!firrtl.clock, !firrtl.uint<1>, !firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>], sym_name = "GCD"}> ({
    ^bb0(%arg0: !firrtl.clock, %arg1: !firrtl.uint<1>, %arg2: !firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>):
      %0 = "firrtl.subfield"(%arg2) <{fieldIndex = 4 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<1>
      %1 = "firrtl.subfield"(%arg2) <{fieldIndex = 3 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<16>
      %2 = "firrtl.subfield"(%arg2) <{fieldIndex = 1 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<16>
      %3 = "firrtl.subfield"(%arg2) <{fieldIndex = 0 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<16>
      %4 = "firrtl.subfield"(%arg2) <{fieldIndex = 2 : i32}> : (!firrtl.bundle<value1 flip: uint<16>, value2 flip: uint<16>, loadingValues flip: uint<1>, outputGCD: uint<16>, outputValid: uint<1>>) -> !firrtl.uint<1>
      %5 = "firrtl.reg"(%arg0) <{annotations = [], name = "x", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock) -> !firrtl.uint
      %6 = "firrtl.reg"(%arg0) <{annotations = [], name = "y", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.clock) -> !firrtl.uint
      %7 = "firrtl.gt"(%5, %6) : (!firrtl.uint, !firrtl.uint) -> !firrtl.uint<1>
      %8 = "firrtl.node"(%7) <{annotations = [], name = "_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.when"(%8) ({
        %16 = "firrtl.sub"(%5, %6) : (!firrtl.uint, !firrtl.uint) -> !firrtl.uint
        %17 = "firrtl.node"(%16) <{annotations = [], name = "_x_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint
        %18 = "firrtl.tail"(%17) <{amount = 1 : i32}> : (!firrtl.uint) -> !firrtl.uint
        %19 = "firrtl.node"(%18) <{annotations = [], name = "_x_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint
        "firrtl.connect"(%5, %19) : (!firrtl.uint, !firrtl.uint) -> ()
      }, {
        %12 = "firrtl.sub"(%6, %5) : (!firrtl.uint, !firrtl.uint) -> !firrtl.uint
        %13 = "firrtl.node"(%12) <{annotations = [], name = "_y_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint
        %14 = "firrtl.tail"(%13) <{amount = 1 : i32}> : (!firrtl.uint) -> !firrtl.uint
        %15 = "firrtl.node"(%14) <{annotations = [], name = "_y_T_1", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint) -> !firrtl.uint
        "firrtl.connect"(%6, %15) : (!firrtl.uint, !firrtl.uint) -> ()
      }) : (!firrtl.uint<1>) -> ()
      "firrtl.when"(%4) ({
        "firrtl.connect"(%5, %3) : (!firrtl.uint, !firrtl.uint<16>) -> ()
        "firrtl.connect"(%6, %2) : (!firrtl.uint, !firrtl.uint<16>) -> ()
      }, {
      }) : (!firrtl.uint<1>) -> ()
      "firrtl.connect"(%1, %5) : (!firrtl.uint<16>, !firrtl.uint) -> ()
      %9 = "firrtl.constant"() <{value = 0 : ui1}> : () -> !firrtl.const.uint<1>
      %10 = "firrtl.eq"(%6, %9) : (!firrtl.uint, !firrtl.const.uint<1>) -> !firrtl.uint<1>
      %11 = "firrtl.node"(%10) <{annotations = [], name = "_io_outputValid_T", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%0, %11) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

