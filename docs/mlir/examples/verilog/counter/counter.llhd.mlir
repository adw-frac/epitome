module {
  hw.module @counter(in %clk : i1, in %rst : i1, in %en : i1, out count : i8) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %1 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %c1_i8 = hw.constant 1 : i8
    %c0_i8 = hw.constant 0 : i8
    %false = hw.constant false
    %clk_0 = llhd.sig name "clk" %false : <i1>
    %2 = llhd.prb %clk_0 : i1
    %rst_1 = llhd.sig name "rst" %false : <i1>
    %en_2 = llhd.sig name "en" %false : <i1>
    %count = llhd.sig : <i8>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %4 = llhd.prb %clk_0 : i1
      llhd.wait (%2 : i1), ^bb2
    ^bb2:  // pred: ^bb1
      %5 = llhd.prb %clk_0 : i1
      %6 = comb.xor bin %4, %true : i1
      %7 = comb.and bin %6, %5 : i1
      cf.cond_br %7, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %8 = llhd.prb %rst_1 : i1
      cf.cond_br %8, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %count, %c0_i8 after %1 : i8
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %9 = llhd.prb %en_2 : i1
      cf.cond_br %9, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %10 = llhd.prb %count : i8
      %11 = comb.add %10, %c1_i8 : i8
      llhd.drv %count, %11 after %1 : i8
      cf.br ^bb1
    }
    llhd.drv %clk_0, %clk after %0 : i1
    llhd.drv %rst_1, %rst after %0 : i1
    llhd.drv %en_2, %en after %0 : i1
    %3 = llhd.prb %count : i8
    hw.output %3 : i8
  }
}
