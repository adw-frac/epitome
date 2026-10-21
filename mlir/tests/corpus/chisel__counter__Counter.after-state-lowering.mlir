"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_en : i1, output io_count : i8>, sym_name = "Counter"}> ({
  ^bb0(%arg0: !arc.storage):
    %0 = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %1 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %2 = "hw.constant"() <{value = -1 : i64}> : () -> i64
    %3 = "arc.as_context"(%arg0) : (!arc.storage) -> !arc.context
    "arc.set_next_wakeup"(%3, %2) : (!arc.context, i64) -> ()
    %4 = "arc.root_input"(%arg0) <{name = "clock"}> : (!arc.storage) -> !arc.state<!seq.clock>
    %5 = "arc.root_input"(%arg0) <{name = "reset"}> : (!arc.storage) -> !arc.state<i1>
    %6 = "arc.root_input"(%arg0) <{name = "io_en"}> : (!arc.storage) -> !arc.state<i1>
    %7 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i1>
    %8 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i8>
    %9 = "arc.root_output"(%arg0) <{name = "io_count"}> : (!arc.storage) -> !arc.state<i8>
    %10 = "arc.state_read"(%4) : (!arc.state<!seq.clock>) -> !seq.clock
    %11 = "seq.from_clock"(%10) : (!seq.clock) -> i1
    %12 = "arc.state_read"(%7) : (!arc.state<i1>) -> i1
    "arc.state_write"(%7, %11) : (!arc.state<i1>, i1) -> ()
    %13 = "comb.xor"(%12, %11) : (i1, i1) -> i1
    %14 = "comb.and"(%13, %11) : (i1, i1) -> i1
    "scf.if"(%14) ({
      %16 = "arc.state_read"(%5) : (!arc.state<i1>) -> i1
      "scf.if"(%16) ({
        "arc.state_write"(%8, %1) : (!arc.state<i8>, i8) -> ()
        "scf.yield"() : () -> ()
      }, {
        %17 = "arc.state_read"(%6) : (!arc.state<i1>) -> i1
        "scf.if"(%17) ({
          %18 = "arc.state_read"(%8) : (!arc.state<i8>) -> i8
          %19 = "comb.add"(%18, %0) <{twoState}> : (i8, i8) -> i8
          "arc.state_write"(%8, %19) : (!arc.state<i8>, i8) -> ()
          "scf.yield"() : () -> ()
        }, {
        }) : (i1) -> ()
        "scf.yield"() : () -> ()
      }) : (i1) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %15 = "arc.state_read"(%8) : (!arc.state<i8>) -> i8
    "arc.state_write"(%9, %15) : (!arc.state<i8>, i8) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

