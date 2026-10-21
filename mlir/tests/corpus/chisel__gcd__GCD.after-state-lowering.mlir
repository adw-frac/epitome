"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, sym_name = "GCD"}> ({
  ^bb0(%arg0: !arc.storage):
    %0 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %1 = "hw.constant"() <{value = -1 : i64}> : () -> i64
    %2 = "arc.as_context"(%arg0) : (!arc.storage) -> !arc.context
    "arc.set_next_wakeup"(%2, %1) : (!arc.context, i64) -> ()
    %3 = "arc.root_input"(%arg0) <{name = "clock"}> : (!arc.storage) -> !arc.state<!seq.clock>
    %4 = "arc.root_input"(%arg0) <{name = "reset"}> : (!arc.storage) -> !arc.state<i1>
    %5 = "arc.root_input"(%arg0) <{name = "io_value1"}> : (!arc.storage) -> !arc.state<i16>
    %6 = "arc.root_input"(%arg0) <{name = "io_value2"}> : (!arc.storage) -> !arc.state<i16>
    %7 = "arc.root_input"(%arg0) <{name = "io_loadingValues"}> : (!arc.storage) -> !arc.state<i1>
    %8 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i16>
    %9 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i16>
    %10 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i1>
    %11 = "arc.root_output"(%arg0) <{name = "io_outputGCD"}> : (!arc.storage) -> !arc.state<i16>
    %12 = "arc.root_output"(%arg0) <{name = "io_outputValid"}> : (!arc.storage) -> !arc.state<i1>
    %13 = "arc.state_read"(%3) : (!arc.state<!seq.clock>) -> !seq.clock
    %14 = "seq.from_clock"(%13) : (!seq.clock) -> i1
    %15 = "arc.state_read"(%10) : (!arc.state<i1>) -> i1
    "arc.state_write"(%10, %14) : (!arc.state<i1>, i1) -> ()
    %16 = "comb.xor"(%15, %14) : (i1, i1) -> i1
    %17 = "comb.and"(%16, %14) : (i1, i1) -> i1
    "scf.if"(%17) ({
      %21 = "arc.state_read"(%8) : (!arc.state<i16>) -> i16
      %22 = "arc.state_read"(%9) : (!arc.state<i16>) -> i16
      %23 = "comb.icmp"(%21, %22) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1
      %24 = "arc.state_read"(%7) : (!arc.state<i1>) -> i1
      %25 = "arc.state_read"(%5) : (!arc.state<i16>) -> i16
      %26 = "comb.sub"(%21, %22) <{twoState}> : (i16, i16) -> i16
      %27 = "comb.mux"(%23, %26, %21) <{twoState}> : (i1, i16, i16) -> i16
      %28 = "comb.mux"(%24, %25, %27) <{twoState}> : (i1, i16, i16) -> i16
      "arc.state_write"(%8, %28) : (!arc.state<i16>, i16) -> ()
      %29 = "arc.state_read"(%9) : (!arc.state<i16>) -> i16
      %30 = "arc.state_read"(%7) : (!arc.state<i1>) -> i1
      %31 = "arc.state_read"(%6) : (!arc.state<i16>) -> i16
      %32 = "comb.sub"(%29, %21) <{twoState}> : (i16, i16) -> i16
      %33 = "comb.mux"(%23, %29, %32) <{twoState}> : (i1, i16, i16) -> i16
      %34 = "comb.mux"(%30, %31, %33) <{twoState}> : (i1, i16, i16) -> i16
      "arc.state_write"(%9, %34) : (!arc.state<i16>, i16) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %18 = "arc.state_read"(%8) : (!arc.state<i16>) -> i16
    "arc.state_write"(%11, %18) : (!arc.state<i16>, i16) -> ()
    %19 = "arc.state_read"(%9) : (!arc.state<i16>) -> i16
    %20 = "comb.icmp"(%19, %0) <{predicate = 0 : i64, twoState}> : (i16, i16) -> i1
    "arc.state_write"(%12, %20) : (!arc.state<i1>, i1) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

