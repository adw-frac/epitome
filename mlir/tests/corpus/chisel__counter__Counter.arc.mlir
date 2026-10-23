"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8>, storageBytes = 30 : ui32, sym_name = "Counter"}> ({
  ^bb0(%arg0: !arc.storage):
    %0 = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %1 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %2 = "hw.constant"() <{value = -1 : i64}> : () -> i64
    %3 = "arc.as_context"(%arg0) : (!arc.storage) -> !arc.context
    "arc.set_next_wakeup"(%3, %2) : (!arc.context, i64) -> ()
    %4 = "arc.root_input"(%arg0) <{name = "clock"}> {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %5 = "arc.root_input"(%arg0) <{name = "reset"}> {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %6 = "arc.root_input"(%arg0) <{name = "io_en"}> {offset = 26 : i32} : (!arc.storage) -> !arc.state<i1>
    %7 = "arc.alloc_state"(%arg0) {offset = 27 : i32} : (!arc.storage) -> !arc.state<i1>
    %8 = "arc.alloc_state"(%arg0) {offset = 28 : i32} : (!arc.storage) -> !arc.state<i8>
    %9 = "arc.root_output"(%arg0) <{name = "io_count"}> {offset = 29 : i32} : (!arc.storage) -> !arc.state<i8>
    %10 = "arc.storage.get"(%arg0) <{offset = 24 : i32}> : (!arc.storage) -> !arc.state<!seq.clock>
    %11 = "arc.state_read"(%10) : (!arc.state<!seq.clock>) -> !seq.clock
    %12 = "seq.from_clock"(%11) : (!seq.clock) -> i1
    %13 = "arc.storage.get"(%arg0) <{offset = 27 : i32}> : (!arc.storage) -> !arc.state<i1>
    %14 = "arc.state_read"(%13) : (!arc.state<i1>) -> i1
    "arc.state_write"(%13, %12) : (!arc.state<i1>, i1) -> ()
    %15 = "comb.xor"(%14, %12) : (i1, i1) -> i1
    %16 = "comb.and"(%15, %12) : (i1, i1) -> i1
    "scf.if"(%16) ({
      %20 = "arc.storage.get"(%arg0) <{offset = 25 : i32}> : (!arc.storage) -> !arc.state<i1>
      %21 = "arc.state_read"(%20) : (!arc.state<i1>) -> i1
      "scf.if"(%21) ({
        %27 = "arc.storage.get"(%arg0) <{offset = 28 : i32}> : (!arc.storage) -> !arc.state<i8>
        "arc.state_write"(%27, %1) : (!arc.state<i8>, i8) -> ()
        "scf.yield"() : () -> ()
      }, {
        %22 = "arc.storage.get"(%arg0) <{offset = 26 : i32}> : (!arc.storage) -> !arc.state<i1>
        %23 = "arc.state_read"(%22) : (!arc.state<i1>) -> i1
        "scf.if"(%23) ({
          %24 = "arc.storage.get"(%arg0) <{offset = 28 : i32}> : (!arc.storage) -> !arc.state<i8>
          %25 = "arc.state_read"(%24) : (!arc.state<i8>) -> i8
          %26 = "comb.add"(%25, %0) <{twoState}> : (i8, i8) -> i8
          "arc.state_write"(%24, %26) : (!arc.state<i8>, i8) -> ()
          "scf.yield"() : () -> ()
        }, {
        }) : (i1) -> ()
        "scf.yield"() : () -> ()
      }) : (i1) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %17 = "arc.storage.get"(%arg0) <{offset = 28 : i32}> : (!arc.storage) -> !arc.state<i8>
    %18 = "arc.state_read"(%17) : (!arc.state<i8>) -> i8
    %19 = "arc.storage.get"(%arg0) <{offset = 29 : i32}> : (!arc.storage) -> !arc.state<i8>
    "arc.state_write"(%19, %18) : (!arc.state<i8>, i8) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

