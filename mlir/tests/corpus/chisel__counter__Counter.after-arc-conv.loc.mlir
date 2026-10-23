#loc3 = loc("./chisel/counter/Counter.after-arc-conv.mlir":3:27)
#loc4 = loc("./chisel/counter/Counter.after-arc-conv.mlir":3:38)
#loc10 = loc("./chisel/counter/Counter.after-arc-conv.mlir":9:25)
#loc11 = loc("./chisel/counter/Counter.after-arc-conv.mlir":9:49)
#loc12 = loc("./chisel/counter/Counter.after-arc-conv.mlir":9:65)
#loc15 = loc("./chisel/counter/Counter.after-arc-conv.mlir":9:82)
"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> () loc(#loc1)
  "arc.define"() <{function_type = (i8, i1) -> i8, sym_name = "Counter_arc"}> ({
  ^bb0(%arg3: i8 loc("./chisel/counter/Counter.after-arc-conv.mlir":3:27), %arg4: i1 loc("./chisel/counter/Counter.after-arc-conv.mlir":3:38)):
    %1 = "hw.constant"() <{value = 1 : i8}> : () -> i8 loc(#loc5)
    %2 = "comb.add"(%arg3, %1) <{twoState}> : (i8, i8) -> i8 loc(#loc6)
    %3 = "comb.mux"(%arg4, %2, %arg3) <{twoState}> : (i1, i8, i8) -> i8 loc(#loc7)
    "arc.output"(%3) : (i8) -> () loc(#loc8)
  }) : () -> () loc(#loc2)
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8>, parameters = [], result_locs = [#loc15], sym_name = "Counter"}> ({
  ^bb0(%arg0: !seq.clock loc("./chisel/counter/Counter.after-arc-conv.mlir":9:25), %arg1: i1 loc("./chisel/counter/Counter.after-arc-conv.mlir":9:49), %arg2: i1 loc("./chisel/counter/Counter.after-arc-conv.mlir":9:65)):
    %0 = "arc.state"(%arg0, %arg1, %0, %arg2) <{arc = @Counter_arc, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 0, 1, 2, 0>}> : (!seq.clock, i1, i8, i1) -> i8 loc(#loc13)
    "hw.output"(%0) : (i8) -> () loc(#loc14)
  }) : () -> () loc(#loc9)
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> () loc(#loc)
#loc = loc("./chisel/counter/Counter.after-arc-conv.mlir":1:1)
#loc1 = loc("./chisel/counter/Counter.after-arc-conv.mlir":2:3)
#loc2 = loc("./chisel/counter/Counter.after-arc-conv.mlir":3:3)
#loc5 = loc("./chisel/counter/Counter.after-arc-conv.mlir":4:14)
#loc6 = loc("./chisel/counter/Counter.after-arc-conv.mlir":5:10)
#loc7 = loc("./chisel/counter/Counter.after-arc-conv.mlir":6:10)
#loc8 = loc("./chisel/counter/Counter.after-arc-conv.mlir":7:5)
#loc9 = loc("./chisel/counter/Counter.after-arc-conv.mlir":9:3)
#loc13 = loc("./chisel/counter/Counter.after-arc-conv.mlir":10:10)
#loc14 = loc("./chisel/counter/Counter.after-arc-conv.mlir":11:5)

