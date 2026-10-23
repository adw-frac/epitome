"builtin.module"() ({
  "moore.module"() <{module_type = !hw.modty<input clk : !moore.l1, input rst : !moore.l1, input en : !moore.l1, output count : !moore.l8>, sym_name = "counter"}> ({
  ^bb0(%arg0: !moore.l1, %arg1: !moore.l1, %arg2: !moore.l1):
    %0 = "moore.constant"() <{value = #moore.fvint<1 : 8>}> : () -> !moore.l8
    %1 = "moore.constant"() <{value = #moore.fvint<0 : 8>}> : () -> !moore.l8
    %2 = "moore.net"() <{kind = 9 : i32, name = "clk"}> : () -> !moore.ref<l1>
    %3 = "moore.net"() <{kind = 9 : i32, name = "rst"}> : () -> !moore.ref<l1>
    %4 = "moore.net"() <{kind = 9 : i32, name = "en"}> : () -> !moore.ref<l1>
    %5 = "moore.variable"() <{name = "count"}> : () -> !moore.ref<l8>
    "moore.procedure"() <{kind = 5 : i32}> ({
      "moore.wait_event"() ({
        %15 = "moore.read"(%2) : (!moore.ref<l1>) -> !moore.l1
        "moore.detect_event"(%15) <{edge = 1 : i32}> : (!moore.l1) -> ()
      }) : () -> ()
      %7 = "moore.read"(%3) : (!moore.ref<l1>) -> !moore.l1
      %8 = "moore.logic_to_int"(%7) : (!moore.l1) -> !moore.i1
      %9 = "moore.to_builtin_int"(%8) : (!moore.i1) -> i1
      "cf.cond_br"(%9)[^bb1, ^bb2] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
    ^bb1:  // pred: ^bb0
      "moore.nonblocking_assign"(%5, %1) : (!moore.ref<l8>, !moore.l8) -> ()
      "cf.br"()[^bb4] : () -> ()
    ^bb2:  // pred: ^bb0
      %10 = "moore.read"(%4) : (!moore.ref<l1>) -> !moore.l1
      %11 = "moore.logic_to_int"(%10) : (!moore.l1) -> !moore.i1
      %12 = "moore.to_builtin_int"(%11) : (!moore.i1) -> i1
      "cf.cond_br"(%12)[^bb3, ^bb4] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
    ^bb3:  // pred: ^bb2
      %13 = "moore.read"(%5) : (!moore.ref<l8>) -> !moore.l8
      %14 = "moore.add"(%13, %0) : (!moore.l8, !moore.l8) -> !moore.l8
      "moore.nonblocking_assign"(%5, %14) : (!moore.ref<l8>, !moore.l8) -> ()
      "cf.br"()[^bb4] : () -> ()
    ^bb4:  // 3 preds: ^bb1, ^bb2, ^bb3
      "moore.return"() : () -> ()
    }) : () -> ()
    "moore.assign"(%2, %arg0) : (!moore.ref<l1>, !moore.l1) -> ()
    "moore.assign"(%3, %arg1) : (!moore.ref<l1>, !moore.l1) -> ()
    "moore.assign"(%4, %arg2) : (!moore.ref<l1>, !moore.l1) -> ()
    %6 = "moore.read"(%5) : (!moore.ref<l8>) -> !moore.l8
    "moore.output"(%6) : (!moore.l8) -> ()
  }) : () -> ()
}) : () -> ()

