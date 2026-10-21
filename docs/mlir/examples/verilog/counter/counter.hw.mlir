module {
  hw.module @counter(in %clk : !seq.clock, in %rst : i1, in %en : i1, out count : i8) {
    %true = hw.constant true
    %c1_i8 = hw.constant 1 : i8
    %c0_i8 = hw.constant 0 : i8
    %0 = comb.add %count, %c1_i8 : i8
    %1 = comb.xor %rst, %true : i1
    %2 = comb.and %en, %1 : i1
    %3 = comb.mux %2, %0, %c0_i8 : i8
    %4 = comb.or %rst, %en : i1
    %5 = comb.mux bin %4, %3, %count : i8
    %count = seq.firreg %5 clock %clk : i8
    hw.output %count : i8
  }
}
