#loc = loc("./chisel/counter/Counter.after-arc-opt.mlir":8:82)
"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.define"() <{function_type = (i8) -> i8, sym_name = "Counter_arc"}> ({
  ^bb0(%arg3: i8):
    %1 = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %2 = "comb.add"(%arg3, %1) <{twoState}> : (i8, i8) -> i8
    "arc.output"(%2) : (i8) -> ()
  }) : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8>, parameters = [], result_locs = [#loc], sym_name = "Counter"}> ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1):
    %0 = "arc.state"(%arg0, %arg2, %arg1, %0) <{arc = @Counter_arc, latency = 1 : i32, operandSegmentSizes = array<i32: 1, 1, 1, 1, 0>}> : (!seq.clock, i1, i1, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

