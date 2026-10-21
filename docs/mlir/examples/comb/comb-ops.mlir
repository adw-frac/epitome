// One output per comb operation, to see what arcilator lowers each to.
hw.module @CombOps(in %a : i8, in %b : i8, in %c : i1, in %w : i12,
    out add : i8, out sub : i8, out mul : i8, out divu : i8, out divs : i8,
    out modu : i8, out mods : i8, out shl : i8, out shru : i8, out shrs : i8,
    out and3 : i8, out or2 : i8, out xor2 : i8, out not : i8,
    out ult : i1, out slt : i1, out eq : i1, out ne : i1, out uge : i1, out sgt : i1,
    out ceq : i1, out weq : i1,
    out parity : i1, out ext : i4, out cat : i20, out rep : i24, out mux : i8,
    out rev : i8) {
  %0 = comb.add %a, %b : i8
  %1 = comb.sub %a, %b : i8
  %2 = comb.mul %a, %b : i8
  %3 = comb.divu %a, %b : i8
  %4 = comb.divs %a, %b : i8
  %5 = comb.modu %a, %b : i8
  %6 = comb.mods %a, %b : i8
  %7 = comb.shl %a, %b : i8
  %8 = comb.shru %a, %b : i8
  %9 = comb.shrs %a, %b : i8
  %10 = comb.and %a, %b, %a : i8
  %11 = comb.or %a, %b : i8
  %12 = comb.xor %a, %b : i8
  %m1 = hw.constant -1 : i8
  %13 = comb.xor %a, %m1 : i8
  %14 = comb.icmp ult %a, %b : i8
  %15 = comb.icmp slt %a, %b : i8
  %16 = comb.icmp eq %a, %b : i8
  %17 = comb.icmp ne %a, %b : i8
  %18 = comb.icmp uge %a, %b : i8
  %19 = comb.icmp sgt %a, %b : i8
  %20 = comb.icmp ceq %a, %b : i8
  %21 = comb.icmp weq %a, %b : i8
  %22 = comb.parity %a : i8
  %23 = comb.extract %a from 2 : (i8) -> i4
  %24 = comb.concat %a, %w : i8, i12
  %25 = comb.replicate %a : (i8) -> i24
  %26 = comb.mux %c, %a, %b : i8
  %27 = comb.reverse %a : i8
  hw.output %0, %1, %2, %3, %4, %5, %6, %7, %8, %9, %10, %11, %12, %13, %14, %15, %16, %17, %18, %19, %20, %21, %22, %23, %24, %25, %26, %27 : i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i1, i1, i1, i1, i1, i1, i1, i1, i1, i4, i20, i24, i8, i8
}
