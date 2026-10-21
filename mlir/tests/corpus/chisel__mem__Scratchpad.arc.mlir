"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (), sym_name = "exit", sym_visibility = "private"}> ({
  }) : () -> ()
  "arc.model"() <{io = !hw.modty<input clock : !seq.clock, input reset : i1, input io_raddr : i4, output io_rdata : i32, input io_wen : i1, input io_waddr : i4, input io_wdata : i32>, storageBytes = 120 : ui32, sym_name = "Scratchpad"}> ({
  ^bb0(%arg0: !arc.storage):
    %0 = "hw.constant"() <{value = 0 : i32}> : () -> i32
    %1 = "hw.constant"() <{value = true}> : () -> i1
    %2 = "hw.constant"() <{value = -1 : i64}> : () -> i64
    %3 = "arc.as_context"(%arg0) : (!arc.storage) -> !arc.context
    "arc.set_next_wakeup"(%3, %2) : (!arc.context, i64) -> ()
    %4 = "arc.root_input"(%arg0) <{name = "clock"}> {offset = 24 : i32} : (!arc.storage) -> !arc.state<!seq.clock>
    %5 = "arc.root_input"(%arg0) <{name = "reset"}> {offset = 25 : i32} : (!arc.storage) -> !arc.state<i1>
    %6 = "arc.root_input"(%arg0) <{name = "io_raddr"}> {offset = 26 : i32} : (!arc.storage) -> !arc.state<i4>
    %7 = "arc.root_input"(%arg0) <{name = "io_wen"}> {offset = 27 : i32} : (!arc.storage) -> !arc.state<i1>
    %8 = "arc.root_input"(%arg0) <{name = "io_waddr"}> {offset = 28 : i32} : (!arc.storage) -> !arc.state<i4>
    %9 = "arc.root_input"(%arg0) <{name = "io_wdata"}> {offset = 32 : i32} : (!arc.storage) -> !arc.state<i32>
    %10 = "arc.alloc_memory"(%arg0) {offset = 48 : i32, stride = 4 : i32} : (!arc.storage) -> !arc.memory<16 x i32, i4>
    %11 = "arc.alloc_state"(%arg0) {offset = 112 : i32} : (!arc.storage) -> !arc.state<i4>
    %12 = "arc.alloc_state"(%arg0) {offset = 113 : i32} : (!arc.storage) -> !arc.state<i1>
    %13 = "arc.alloc_state"(%arg0) {offset = 114 : i32} : (!arc.storage) -> !arc.state<i1>
    %14 = "arc.root_output"(%arg0) <{name = "io_rdata"}> {offset = 116 : i32} : (!arc.storage) -> !arc.state<i32>
    %15 = "arc.storage.get"(%arg0) <{offset = 24 : i32}> : (!arc.storage) -> !arc.state<!seq.clock>
    %16 = "arc.state_read"(%15) : (!arc.state<!seq.clock>) -> !seq.clock
    %17 = "seq.from_clock"(%16) : (!seq.clock) -> i1
    %18 = "arc.storage.get"(%arg0) <{offset = 113 : i32}> : (!arc.storage) -> !arc.state<i1>
    %19 = "arc.state_read"(%18) : (!arc.state<i1>) -> i1
    "arc.state_write"(%18, %17) : (!arc.state<i1>, i1) -> ()
    %20 = "comb.xor"(%19, %17) : (i1, i1) -> i1
    %21 = "comb.and"(%20, %17) : (i1, i1) -> i1
    "scf.if"(%21) ({
      %30 = "arc.storage.get"(%arg0) <{offset = 27 : i32}> : (!arc.storage) -> !arc.state<i1>
      %31 = "arc.state_read"(%30) : (!arc.state<i1>) -> i1
      "scf.if"(%31) ({
        %36 = "arc.storage.get"(%arg0) <{offset = 28 : i32}> : (!arc.storage) -> !arc.state<i4>
        %37 = "arc.state_read"(%36) : (!arc.state<i4>) -> i4
        %38 = "arc.storage.get"(%arg0) <{offset = 32 : i32}> : (!arc.storage) -> !arc.state<i32>
        %39 = "arc.state_read"(%38) : (!arc.state<i32>) -> i32
        %40 = "arc.storage.get"(%arg0) <{offset = 48 : i32}> : (!arc.storage) -> !arc.memory<16 x i32, i4>
        "arc.memory_write"(%40, %37, %39) : (!arc.memory<16 x i32, i4>, i4, i32) -> ()
        "scf.yield"() : () -> ()
      }, {
      }) : (i1) -> ()
      %32 = "arc.storage.get"(%arg0) <{offset = 26 : i32}> : (!arc.storage) -> !arc.state<i4>
      %33 = "arc.state_read"(%32) : (!arc.state<i4>) -> i4
      %34 = "arc.storage.get"(%arg0) <{offset = 112 : i32}> : (!arc.storage) -> !arc.state<i4>
      "arc.state_write"(%34, %33) : (!arc.state<i4>, i4) -> ()
      %35 = "arc.storage.get"(%arg0) <{offset = 114 : i32}> : (!arc.storage) -> !arc.state<i1>
      "arc.state_write"(%35, %1) : (!arc.state<i1>, i1) -> ()
      "scf.yield"() : () -> ()
    }, {
    }) : (i1) -> ()
    %22 = "arc.storage.get"(%arg0) <{offset = 114 : i32}> : (!arc.storage) -> !arc.state<i1>
    %23 = "arc.state_read"(%22) : (!arc.state<i1>) -> i1
    %24 = "arc.storage.get"(%arg0) <{offset = 112 : i32}> : (!arc.storage) -> !arc.state<i4>
    %25 = "arc.state_read"(%24) : (!arc.state<i4>) -> i4
    %26 = "arc.storage.get"(%arg0) <{offset = 48 : i32}> : (!arc.storage) -> !arc.memory<16 x i32, i4>
    %27 = "arc.memory_read"(%26, %25) : (!arc.memory<16 x i32, i4>, i4) -> i32
    %28 = "comb.mux"(%23, %27, %0) : (i1, i32, i32) -> i32
    %29 = "arc.storage.get"(%arg0) <{offset = 116 : i32}> : (!arc.storage) -> !arc.state<i32>
    "arc.state_write"(%29, %28) : (!arc.state<i32>, i32) -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>} : () -> ()

