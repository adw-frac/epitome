module {
  moore.module @counter(in %clk : !moore.l1, in %rst : !moore.l1, in %en : !moore.l1, out count : !moore.l8) {
    %0 = moore.constant 1 : l8
    %1 = moore.constant 0 : l8
    %clk_0 = moore.net name "clk" wire : <l1>
    %rst_1 = moore.net name "rst" wire : <l1>
    %en_2 = moore.net name "en" wire : <l1>
    %count = moore.variable : <l8>
    moore.procedure always_ff {
      moore.wait_event {
        %11 = moore.read %clk_0 : <l1>
        moore.detect_event posedge %11 : l1
      }
      %3 = moore.read %rst_1 : <l1>
      %4 = moore.logic_to_int %3 : l1
      %5 = moore.to_builtin_int %4 : i1
      cf.cond_br %5, ^bb1, ^bb2
    ^bb1:  // pred: ^bb0
      moore.nonblocking_assign %count, %1 : l8
      cf.br ^bb4
    ^bb2:  // pred: ^bb0
      %6 = moore.read %en_2 : <l1>
      %7 = moore.logic_to_int %6 : l1
      %8 = moore.to_builtin_int %7 : i1
      cf.cond_br %8, ^bb3, ^bb4
    ^bb3:  // pred: ^bb2
      %9 = moore.read %count : <l8>
      %10 = moore.add %9, %0 : l8
      moore.nonblocking_assign %count, %10 : l8
      cf.br ^bb4
    ^bb4:  // 3 preds: ^bb1, ^bb2, ^bb3
      moore.return
    }
    moore.assign %clk_0, %clk : l1
    moore.assign %rst_1, %rst : l1
    moore.assign %en_2, %en : l1
    %2 = moore.read %count : <l8>
    moore.output %2 : !moore.l8
  }
}
