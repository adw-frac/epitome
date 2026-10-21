#loc = loc("./verilog/counter/counter.hw.mlir":2:75)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clk : !seq.clock, input rst : i1, input en : i1, output count : i8>, parameters = [], result_locs = [#loc], sym_name = "counter"}> ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1):
    %0 = "hw.constant"() <{value = true}> : () -> i1
    %1 = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %2 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %3 = "comb.add"(%9, %1) : (i8, i8) -> i8
    %4 = "comb.xor"(%arg1, %0) : (i1, i1) -> i1
    %5 = "comb.and"(%arg2, %4) : (i1, i1) -> i1
    %6 = "comb.mux"(%5, %3, %2) : (i1, i8, i8) -> i8
    %7 = "comb.or"(%arg1, %arg2) : (i1, i1) -> i1
    %8 = "comb.mux"(%7, %6, %9) <{twoState}> : (i1, i8, i8) -> i8
    %9 = "seq.firreg"(%8, %arg0) <{name = "count"}> : (i8, !seq.clock) -> i8
    "hw.output"(%9) : (i8) -> ()
  }) : () -> ()
}) : () -> ()

