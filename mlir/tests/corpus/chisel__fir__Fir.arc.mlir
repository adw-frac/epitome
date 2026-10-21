"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16>, storageBytes = 34 : ui32, sym_name = "Fir"}> ({
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
    %8 = "arc.root_input"(%arg0) <{name = "clock"}> {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %9 = "arc.root_input"(%arg0) <{name = "reset"}> {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %10 = "arc.root_input"(%arg0) <{name = "io_in"}> {offset = 26 : i32} : (!arc.storage) -> !arc.state<i8>
    %11 = "arc.root_input"(%arg0) <{name = "io_valid"}> {offset = 27 : i32} : (!arc.storage) -> !arc.state<i1>
    %12 = "arc.alloc_state"(%arg0) {offset = 28 : i32} : (!arc.storage) -> !arc.state<i1>
    %13 = "arc.alloc_state"(%arg0) {offset = 29 : i32} : (!arc.storage) -> !arc.state<i8>
    %14 = "arc.alloc_state"(%arg0) {offset = 30 : i32} : (!arc.storage) -> !arc.state<i8>
    %15 = "arc.alloc_state"(%arg0) {offset = 31 : i32} : (!arc.storage) -> !arc.state<i8>
    %16 = "arc.root_output"(%arg0) <{name = "io_out"}> {offset = 32 : i32} : (!arc.storage) -> !arc.state<i16>
    %17 = "arc.storage.get"(%arg0) <{offset = 24 : i32}> : (!arc.storage) -> !arc.state<!seq.clock>
    %18 = "arc.state_read"(%17) : (!arc.state<!seq.clock>) -> !seq.clock
    %19 = "seq.from_clock"(%18) : (!seq.clock) -> i1
    %20 = "arc.storage.get"(%arg0) <{offset = 28 : i32}> : (!arc.storage) -> !arc.state<i1>
    %21 = "arc.state_read"(%20) : (!arc.state<i1>) -> i1
    "arc.state_write"(%20, %19) : (!arc.state<i1>, i1) -> ()
    %22 = "comb.xor"(%21, %19) : (i1, i1) -> i1
    %23 = "comb.and"(%22, %19) : (i1, i1) -> i1
    "scf.if"(%23) ({
      %47 = "arc.storage.get"(%arg0) <{offset = 25 : i32}> : (!arc.storage) -> !arc.state<i1>
      %48 = "arc.state_read"(%47) : (!arc.state<i1>) -> i1
      "scf.if"(%48) ({
        %58 = "arc.storage.get"(%arg0) <{offset = 29 : i32}> : (!arc.storage) -> !arc.state<i8>
        "arc.state_write"(%58, %5) : (!arc.state<i8>, i8) -> ()
        %59 = "arc.storage.get"(%arg0) <{offset = 30 : i32}> : (!arc.storage) -> !arc.state<i8>
        "arc.state_write"(%59, %5) : (!arc.state<i8>, i8) -> ()
        %60 = "arc.storage.get"(%arg0) <{offset = 31 : i32}> : (!arc.storage) -> !arc.state<i8>
        "arc.state_write"(%60, %5) : (!arc.state<i8>, i8) -> ()
        "scf.yield"() : () -> ()
      }, {
        %49 = "arc.storage.get"(%arg0) <{offset = 27 : i32}> : (!arc.storage) -> !arc.state<i1>
        %50 = "arc.state_read"(%49) : (!arc.state<i1>) -> i1
        "scf.if"(%50) ({
          %51 = "arc.storage.get"(%arg0) <{offset = 29 : i32}> : (!arc.storage) -> !arc.state<i8>
          %52 = "arc.state_read"(%51) : (!arc.state<i8>) -> i8
          %53 = "arc.storage.get"(%arg0) <{offset = 26 : i32}> : (!arc.storage) -> !arc.state<i8>
          %54 = "arc.state_read"(%53) : (!arc.state<i8>) -> i8
          "arc.state_write"(%51, %54) : (!arc.state<i8>, i8) -> ()
          %55 = "arc.storage.get"(%arg0) <{offset = 30 : i32}> : (!arc.storage) -> !arc.state<i8>
          %56 = "arc.state_read"(%55) : (!arc.state<i8>) -> i8
          "arc.state_write"(%55, %52) : (!arc.state<i8>, i8) -> ()
          %57 = "arc.storage.get"(%arg0) <{offset = 31 : i32}> : (!arc.storage) -> !arc.state<i8>
          "arc.state_write"(%57, %56) : (!arc.state<i8>, i8) -> ()
          "scf.yield"() : () -> ()
        }, {
        }) : (i1) -> ()
        "scf.yield"() : () -> ()
      }) : (i1) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %24 = "arc.storage.get"(%arg0) <{offset = 31 : i32}> : (!arc.storage) -> !arc.state<i8>
    %25 = "arc.state_read"(%24) : (!arc.state<i8>) -> i8
    %26 = "arc.storage.get"(%arg0) <{offset = 30 : i32}> : (!arc.storage) -> !arc.state<i8>
    %27 = "arc.state_read"(%26) : (!arc.state<i8>) -> i8
    %28 = "arc.storage.get"(%arg0) <{offset = 29 : i32}> : (!arc.storage) -> !arc.state<i8>
    %29 = "arc.state_read"(%28) : (!arc.state<i8>) -> i8
    %30 = "arc.storage.get"(%arg0) <{offset = 26 : i32}> : (!arc.storage) -> !arc.state<i8>
    %31 = "arc.state_read"(%30) : (!arc.state<i8>) -> i8
    %32 = "comb.concat"(%4, %25) : (i5, i8) -> i13
    %33 = "comb.concat"(%3, %27) : (i2, i8) -> i10
    %34 = "comb.mul"(%33, %2) <{twoState}> : (i10, i10) -> i10
    %35 = "comb.concat"(%3, %34) : (i2, i10) -> i12
    %36 = "comb.concat"(%3, %29) : (i2, i8) -> i10
    %37 = "comb.mul"(%36, %2) <{twoState}> : (i10, i10) -> i10
    %38 = "comb.concat"(%1, %37) : (i1, i10) -> i11
    %39 = "comb.concat"(%0, %31) : (i3, i8) -> i11
    %40 = "comb.add"(%39, %38) <{twoState}> : (i11, i11) -> i11
    %41 = "comb.concat"(%1, %40) : (i1, i11) -> i12
    %42 = "comb.add"(%41, %35) <{twoState}> : (i12, i12) -> i12
    %43 = "comb.concat"(%1, %42) : (i1, i12) -> i13
    %44 = "comb.add"(%43, %32) <{twoState}> : (i13, i13) -> i13
    %45 = "comb.concat"(%0, %44) : (i3, i13) -> i16
    %46 = "arc.storage.get"(%arg0) <{offset = 32 : i32}> : (!arc.storage) -> !arc.state<i16>
    "arc.state_write"(%46, %45) : (!arc.state<i16>, i16) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

