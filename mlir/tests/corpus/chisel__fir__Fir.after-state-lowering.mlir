"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16>, sym_name = "Fir"}> ({
  ^bb0(%arg0: !arc.storage):
    %0 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %1 = "hw.constant"() <{value = false}> : () -> i1
    %2 = "hw.constant"() <{value = 3 : i10}> : () -> i10
    %3 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %4 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %5 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %6 = "hw.constant"() <{value = -1 : i64}> : () -> i64
    %7 = "arc.as_context"(%arg0) : (!arc.storage) -> !arc.context
    "arc.set_next_wakeup"(%7, %6) : (!arc.context, i64) -> ()
    %8 = "arc.root_input"(%arg0) <{name = "clock"}> : (!arc.storage) -> !arc.state<!seq.clock>
    %9 = "arc.root_input"(%arg0) <{name = "reset"}> : (!arc.storage) -> !arc.state<i1>
    %10 = "arc.root_input"(%arg0) <{name = "io_in"}> : (!arc.storage) -> !arc.state<i8>
    %11 = "arc.root_input"(%arg0) <{name = "io_valid"}> : (!arc.storage) -> !arc.state<i1>
    %12 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i1>
    %13 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i8>
    %14 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i8>
    %15 = "arc.alloc_state"(%arg0) : (!arc.storage) -> !arc.state<i8>
    %16 = "arc.root_output"(%arg0) <{name = "io_out"}> : (!arc.storage) -> !arc.state<i16>
    %17 = "arc.state_read"(%8) : (!arc.state<!seq.clock>) -> !seq.clock
    %18 = "seq.from_clock"(%17) : (!seq.clock) -> i1
    %19 = "arc.state_read"(%12) : (!arc.state<i1>) -> i1
    "arc.state_write"(%12, %18) : (!arc.state<i1>, i1) -> ()
    %20 = "comb.xor"(%19, %18) : (i1, i1) -> i1
    %21 = "comb.and"(%20, %18) : (i1, i1) -> i1
    "scf.if"(%21) ({
      %40 = "arc.state_read"(%9) : (!arc.state<i1>) -> i1
      "scf.if"(%40) ({
        "arc.state_write"(%13, %5) : (!arc.state<i8>, i8) -> ()
        "arc.state_write"(%14, %5) : (!arc.state<i8>, i8) -> ()
        "arc.state_write"(%15, %5) : (!arc.state<i8>, i8) -> ()
        "scf.yield"() : () -> ()
      }, {
        %41 = "arc.state_read"(%11) : (!arc.state<i1>) -> i1
        "scf.if"(%41) ({
          %42 = "arc.state_read"(%13) : (!arc.state<i8>) -> i8
          %43 = "arc.state_read"(%10) : (!arc.state<i8>) -> i8
          "arc.state_write"(%13, %43) : (!arc.state<i8>, i8) -> ()
          %44 = "arc.state_read"(%14) : (!arc.state<i8>) -> i8
          "arc.state_write"(%14, %42) : (!arc.state<i8>, i8) -> ()
          "arc.state_write"(%15, %44) : (!arc.state<i8>, i8) -> ()
          "scf.yield"() : () -> ()
        }, {
        }) : (i1) -> ()
        "scf.yield"() : () -> ()
      }) : (i1) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %22 = "arc.state_read"(%15) : (!arc.state<i8>) -> i8
    %23 = "arc.state_read"(%14) : (!arc.state<i8>) -> i8
    %24 = "arc.state_read"(%13) : (!arc.state<i8>) -> i8
    %25 = "arc.state_read"(%10) : (!arc.state<i8>) -> i8
    %26 = "comb.concat"(%4, %22) : (i5, i8) -> i13
    %27 = "comb.concat"(%3, %23) : (i2, i8) -> i10
    %28 = "comb.mul"(%27, %2) <{twoState}> : (i10, i10) -> i10
    %29 = "comb.concat"(%3, %28) : (i2, i10) -> i12
    %30 = "comb.concat"(%3, %24) : (i2, i8) -> i10
    %31 = "comb.mul"(%30, %2) <{twoState}> : (i10, i10) -> i10
    %32 = "comb.concat"(%1, %31) : (i1, i10) -> i11
    %33 = "comb.concat"(%0, %25) : (i3, i8) -> i11
    %34 = "comb.add"(%33, %32) <{twoState}> : (i11, i11) -> i11
    %35 = "comb.concat"(%1, %34) : (i1, i11) -> i12
    %36 = "comb.add"(%35, %29) <{twoState}> : (i12, i12) -> i12
    %37 = "comb.concat"(%1, %36) : (i1, i12) -> i13
    %38 = "comb.add"(%37, %26) <{twoState}> : (i13, i13) -> i13
    %39 = "comb.concat"(%0, %38) : (i3, i13) -> i16
    "arc.state_write"(%16, %39) : (!arc.state<i16>, i16) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

