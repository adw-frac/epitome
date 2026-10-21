#loc = loc("./verilog/counter/counter.llhd.mlir":2:67)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clk : i1, input rst : i1, input en : i1, output count : i8>, parameters = [], result_locs = [#loc], sym_name = "counter"}> ({
  ^bb0(%arg0: i1, %arg1: i1, %arg2: i1):
    %0 = "llhd.constant_time"() <{value = #llhd.time<0ns, 0d, 1e>}> : () -> !llhd.time
    %1 = "llhd.constant_time"() <{value = #llhd.time<0ns, 1d, 0e>}> : () -> !llhd.time
    %2 = "hw.constant"() <{value = true}> : () -> i1
    %3 = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %4 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %5 = "hw.constant"() <{value = false}> : () -> i1
    %6 = "llhd.sig"(%5) <{name = "clk"}> : (i1) -> !llhd.ref<i1>
    %7 = "llhd.prb"(%6) : (!llhd.ref<i1>) -> i1
    %8 = "llhd.sig"(%5) <{name = "rst"}> : (i1) -> !llhd.ref<i1>
    %9 = "llhd.sig"(%5) <{name = "en"}> : (i1) -> !llhd.ref<i1>
    %10 = "llhd.sig"() <{name = "count"}> : () -> !llhd.ref<i8>
    "llhd.process"() ({
      "cf.br"()[^bb1] : () -> ()
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %12 = "llhd.prb"(%6) : (!llhd.ref<i1>) -> i1
      "llhd.wait"(%7)[^bb2] <{operandSegmentSizes = array<i32: 0, 0, 1, 0>}> : (i1) -> ()
    ^bb2:  // pred: ^bb1
      %13 = "llhd.prb"(%6) : (!llhd.ref<i1>) -> i1
      %14 = "comb.xor"(%12, %2) <{twoState}> : (i1, i1) -> i1
      %15 = "comb.and"(%14, %13) <{twoState}> : (i1, i1) -> i1
      "cf.cond_br"(%15)[^bb3, ^bb1] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
    ^bb3:  // pred: ^bb2
      %16 = "llhd.prb"(%8) : (!llhd.ref<i1>) -> i1
      "cf.cond_br"(%16)[^bb4, ^bb5] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
    ^bb4:  // pred: ^bb3
      "llhd.drv"(%10, %4, %1) : (!llhd.ref<i8>, i8, !llhd.time) -> ()
      "cf.br"()[^bb1] : () -> ()
    ^bb5:  // pred: ^bb3
      %17 = "llhd.prb"(%9) : (!llhd.ref<i1>) -> i1
      "cf.cond_br"(%17)[^bb6, ^bb1] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
    ^bb6:  // pred: ^bb5
      %18 = "llhd.prb"(%10) : (!llhd.ref<i8>) -> i8
      %19 = "comb.add"(%18, %3) : (i8, i8) -> i8
      "llhd.drv"(%10, %19, %1) : (!llhd.ref<i8>, i8, !llhd.time) -> ()
      "cf.br"()[^bb1] : () -> ()
    }) : () -> ()
    "llhd.drv"(%6, %arg0, %0) : (!llhd.ref<i1>, i1, !llhd.time) -> ()
    "llhd.drv"(%8, %arg1, %0) : (!llhd.ref<i1>, i1, !llhd.time) -> ()
    "llhd.drv"(%9, %arg2, %0) : (!llhd.ref<i1>, i1, !llhd.time) -> ()
    %11 = "llhd.prb"(%10) : (!llhd.ref<i8>) -> i8
    "hw.output"(%11) : (i8) -> ()
  }) : () -> ()
}) : () -> ()

