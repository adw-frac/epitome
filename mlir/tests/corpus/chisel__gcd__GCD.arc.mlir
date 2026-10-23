"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_value1 : i16, input io_value2 : i16, input io_loadingValues : i1, output io_outputGCD : i16, output io_outputValid : i1>, storageBytes = 41 : ui32, sym_name = "GCD"}> ({
  ^bb0(%arg0: !arc.storage):
    %0 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %1 = "hw.constant"() <{value = -1 : i64}> : () -> i64
    %2 = "arc.as_context"(%arg0) : (!arc.storage) -> !arc.context
    "arc.set_next_wakeup"(%2, %1) : (!arc.context, i64) -> ()
    %3 = "arc.root_input"(%arg0) <{name = "clock"}> {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %4 = "arc.root_input"(%arg0) <{name = "reset"}> {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %5 = "arc.root_input"(%arg0) <{name = "io_value1"}> {offset = 26 : i32} : (!arc.storage) -> !arc.state<i16>
    %6 = "arc.root_input"(%arg0) <{name = "io_value2"}> {offset = 28 : i32} : (!arc.storage) -> !arc.state<i16>
    %7 = "arc.root_input"(%arg0) <{name = "io_loadingValues"}> {offset = 30 : i32} : (!arc.storage) -> !arc.state<i1>
    %8 = "arc.alloc_state"(%arg0) {offset = 32 : i32} : (!arc.storage) -> !arc.state<i16>
    %9 = "arc.alloc_state"(%arg0) {offset = 34 : i32} : (!arc.storage) -> !arc.state<i16>
    %10 = "arc.alloc_state"(%arg0) {offset = 36 : i32} : (!arc.storage) -> !arc.state<i1>
    %11 = "arc.root_output"(%arg0) <{name = "io_outputGCD"}> {offset = 38 : i32} : (!arc.storage) -> !arc.state<i16>
    %12 = "arc.root_output"(%arg0) <{name = "io_outputValid"}> {offset = 40 : i32} : (!arc.storage) -> !arc.state<i1>
    %13 = "arc.storage.get"(%arg0) <{offset = 24 : i32}> : (!arc.storage) -> !arc.state<!seq.clock>
    %14 = "arc.state_read"(%13) : (!arc.state<!seq.clock>) -> !seq.clock
    %15 = "seq.from_clock"(%14) : (!seq.clock) -> i1
    %16 = "arc.storage.get"(%arg0) <{offset = 36 : i32}> : (!arc.storage) -> !arc.state<i1>
    %17 = "arc.state_read"(%16) : (!arc.state<i1>) -> i1
    "arc.state_write"(%16, %15) : (!arc.state<i1>, i1) -> ()
    %18 = "comb.xor"(%17, %15) : (i1, i1) -> i1
    %19 = "comb.and"(%18, %15) : (i1, i1) -> i1
    "scf.if"(%19) ({
      %27 = "arc.storage.get"(%arg0) <{offset = 32 : i32}> : (!arc.storage) -> !arc.state<i16>
      %28 = "arc.state_read"(%27) : (!arc.state<i16>) -> i16
      %29 = "arc.storage.get"(%arg0) <{offset = 34 : i32}> : (!arc.storage) -> !arc.state<i16>
      %30 = "arc.state_read"(%29) : (!arc.state<i16>) -> i16
      %31 = "comb.icmp"(%28, %30) <{predicate = 8 : i64, twoState}> : (i16, i16) -> i1
      %32 = "arc.storage.get"(%arg0) <{offset = 30 : i32}> : (!arc.storage) -> !arc.state<i1>
      %33 = "arc.state_read"(%32) : (!arc.state<i1>) -> i1
      %34 = "arc.storage.get"(%arg0) <{offset = 26 : i32}> : (!arc.storage) -> !arc.state<i16>
      %35 = "arc.state_read"(%34) : (!arc.state<i16>) -> i16
      %36 = "comb.sub"(%28, %30) <{twoState}> : (i16, i16) -> i16
      %37 = "comb.mux"(%31, %36, %28) <{twoState}> : (i1, i16, i16) -> i16
      %38 = "comb.mux"(%33, %35, %37) <{twoState}> : (i1, i16, i16) -> i16
      "arc.state_write"(%27, %38) : (!arc.state<i16>, i16) -> ()
      %39 = "arc.state_read"(%29) : (!arc.state<i16>) -> i16
      %40 = "arc.state_read"(%32) : (!arc.state<i1>) -> i1
      %41 = "arc.storage.get"(%arg0) <{offset = 28 : i32}> : (!arc.storage) -> !arc.state<i16>
      %42 = "arc.state_read"(%41) : (!arc.state<i16>) -> i16
      %43 = "comb.sub"(%39, %28) <{twoState}> : (i16, i16) -> i16
      %44 = "comb.mux"(%31, %39, %43) <{twoState}> : (i1, i16, i16) -> i16
      %45 = "comb.mux"(%40, %42, %44) <{twoState}> : (i1, i16, i16) -> i16
      "arc.state_write"(%29, %45) : (!arc.state<i16>, i16) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %20 = "arc.storage.get"(%arg0) <{offset = 32 : i32}> : (!arc.storage) -> !arc.state<i16>
    %21 = "arc.state_read"(%20) : (!arc.state<i16>) -> i16
    %22 = "arc.storage.get"(%arg0) <{offset = 38 : i32}> : (!arc.storage) -> !arc.state<i16>
    "arc.state_write"(%22, %21) : (!arc.state<i16>, i16) -> ()
    %23 = "arc.storage.get"(%arg0) <{offset = 34 : i32}> : (!arc.storage) -> !arc.state<i16>
    %24 = "arc.state_read"(%23) : (!arc.state<i16>) -> i16
    %25 = "comb.icmp"(%24, %0) <{predicate = 0 : i64, twoState}> : (i16, i16) -> i1
    %26 = "arc.storage.get"(%arg0) <{offset = 40 : i32}> : (!arc.storage) -> !arc.state<i1>
    "arc.state_write"(%26, %25) : (!arc.state<i1>, i1) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

