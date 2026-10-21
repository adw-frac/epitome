module {
  firrtl.circuit "PrimOps" {
    firrtl.module @PrimOps(in %a: !firrtl.uint<8>, in %b: !firrtl.uint<4>, in %s: !firrtl.sint<8>, in %t: !firrtl.sint<4>, in %c: !firrtl.uint<1>, out %o_add: !firrtl.uint<9>, out %o_sub: !firrtl.uint<9>, out %o_mul: !firrtl.uint<12>, out %o_div: !firrtl.uint<8>, out %o_rem: !firrtl.uint<4>, out %o_sdiv: !firrtl.sint<9>, out %o_srem: !firrtl.sint<4>, out %o_lt: !firrtl.uint<1>, out %o_slt: !firrtl.uint<1>, out %o_pad: !firrtl.uint<12>, out %o_spad: !firrtl.sint<12>, out %o_asuint: !firrtl.uint<8>, out %o_shl: !firrtl.uint<11>, out %o_shr: !firrtl.uint<5>, out %o_sshr: !firrtl.sint<5>, out %o_dshl: !firrtl.uint<23>, out %o_dshr: !firrtl.uint<8>, out %o_sdshr: !firrtl.sint<8>, out %o_cvt: !firrtl.sint<9>, out %o_neg: !firrtl.sint<9>, out %o_not: !firrtl.uint<8>, out %o_and: !firrtl.uint<8>, out %o_andr: !firrtl.uint<1>, out %o_orr: !firrtl.uint<1>, out %o_xorr: !firrtl.uint<1>, out %o_cat: !firrtl.uint<13>, out %o_bits: !firrtl.uint<5>, out %o_head: !firrtl.uint<3>, out %o_tail: !firrtl.uint<5>, out %o_mux: !firrtl.uint<8>) attributes {convention = #firrtl<convention scalarized>} {
      %0 = firrtl.add %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<9>
      %n_add = firrtl.node interesting_name %0 : !firrtl.uint<9>
      firrtl.matchingconnect %o_add, %n_add : !firrtl.uint<9>
      %1 = firrtl.sub %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<9>
      %n_sub = firrtl.node interesting_name %1 : !firrtl.uint<9>
      firrtl.matchingconnect %o_sub, %n_sub : !firrtl.uint<9>
      %2 = firrtl.mul %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<12>
      %n_mul = firrtl.node interesting_name %2 : !firrtl.uint<12>
      firrtl.matchingconnect %o_mul, %n_mul : !firrtl.uint<12>
      %3 = firrtl.div %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %n_div = firrtl.node interesting_name %3 : !firrtl.uint<8>
      firrtl.matchingconnect %o_div, %n_div : !firrtl.uint<8>
      %4 = firrtl.rem %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<4>
      %n_rem = firrtl.node interesting_name %4 : !firrtl.uint<4>
      firrtl.matchingconnect %o_rem, %n_rem : !firrtl.uint<4>
      %5 = firrtl.div %s, %t : (!firrtl.sint<8>, !firrtl.sint<4>) -> !firrtl.sint<9>
      %n_sdiv = firrtl.node interesting_name %5 : !firrtl.sint<9>
      firrtl.matchingconnect %o_sdiv, %n_sdiv : !firrtl.sint<9>
      %6 = firrtl.rem %s, %t : (!firrtl.sint<8>, !firrtl.sint<4>) -> !firrtl.sint<4>
      %n_srem = firrtl.node interesting_name %6 : !firrtl.sint<4>
      firrtl.matchingconnect %o_srem, %n_srem : !firrtl.sint<4>
      %7 = firrtl.lt %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<1>
      %n_lt = firrtl.node interesting_name %7 : !firrtl.uint<1>
      firrtl.matchingconnect %o_lt, %n_lt : !firrtl.uint<1>
      %8 = firrtl.lt %s, %t : (!firrtl.sint<8>, !firrtl.sint<4>) -> !firrtl.uint<1>
      %n_slt = firrtl.node interesting_name %8 : !firrtl.uint<1>
      firrtl.matchingconnect %o_slt, %n_slt : !firrtl.uint<1>
      %9 = firrtl.pad %b, 12 : (!firrtl.uint<4>) -> !firrtl.uint<12>
      %n_pad = firrtl.node interesting_name %9 : !firrtl.uint<12>
      firrtl.matchingconnect %o_pad, %n_pad : !firrtl.uint<12>
      %10 = firrtl.pad %t, 12 : (!firrtl.sint<4>) -> !firrtl.sint<12>
      %n_spad = firrtl.node interesting_name %10 : !firrtl.sint<12>
      firrtl.matchingconnect %o_spad, %n_spad : !firrtl.sint<12>
      %11 = firrtl.asUInt %s : (!firrtl.sint<8>) -> !firrtl.uint<8>
      %n_asuint = firrtl.node interesting_name %11 : !firrtl.uint<8>
      firrtl.matchingconnect %o_asuint, %n_asuint : !firrtl.uint<8>
      %12 = firrtl.shl %a, 3 : (!firrtl.uint<8>) -> !firrtl.uint<11>
      %n_shl = firrtl.node interesting_name %12 : !firrtl.uint<11>
      firrtl.matchingconnect %o_shl, %n_shl : !firrtl.uint<11>
      %13 = firrtl.shr %a, 3 : (!firrtl.uint<8>) -> !firrtl.uint<5>
      %n_shr = firrtl.node interesting_name %13 : !firrtl.uint<5>
      firrtl.matchingconnect %o_shr, %n_shr : !firrtl.uint<5>
      %14 = firrtl.shr %s, 3 : (!firrtl.sint<8>) -> !firrtl.sint<5>
      %n_sshr = firrtl.node interesting_name %14 : !firrtl.sint<5>
      firrtl.matchingconnect %o_sshr, %n_sshr : !firrtl.sint<5>
      %15 = firrtl.dshl %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<23>
      %n_dshl = firrtl.node interesting_name %15 : !firrtl.uint<23>
      firrtl.matchingconnect %o_dshl, %n_dshl : !firrtl.uint<23>
      %16 = firrtl.dshr %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %n_dshr = firrtl.node interesting_name %16 : !firrtl.uint<8>
      firrtl.matchingconnect %o_dshr, %n_dshr : !firrtl.uint<8>
      %17 = firrtl.dshr %s, %b : (!firrtl.sint<8>, !firrtl.uint<4>) -> !firrtl.sint<8>
      %n_sdshr = firrtl.node interesting_name %17 : !firrtl.sint<8>
      firrtl.matchingconnect %o_sdshr, %n_sdshr : !firrtl.sint<8>
      %18 = firrtl.cvt %a : (!firrtl.uint<8>) -> !firrtl.sint<9>
      %n_cvt = firrtl.node interesting_name %18 : !firrtl.sint<9>
      firrtl.matchingconnect %o_cvt, %n_cvt : !firrtl.sint<9>
      %19 = firrtl.neg %a : (!firrtl.uint<8>) -> !firrtl.sint<9>
      %n_neg = firrtl.node interesting_name %19 : !firrtl.sint<9>
      firrtl.matchingconnect %o_neg, %n_neg : !firrtl.sint<9>
      %20 = firrtl.not %a : (!firrtl.uint<8>) -> !firrtl.uint<8>
      %n_not = firrtl.node interesting_name %20 : !firrtl.uint<8>
      firrtl.matchingconnect %o_not, %n_not : !firrtl.uint<8>
      %21 = firrtl.and %a, %b : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %n_and = firrtl.node interesting_name %21 : !firrtl.uint<8>
      firrtl.matchingconnect %o_and, %n_and : !firrtl.uint<8>
      %22 = firrtl.andr %a : (!firrtl.uint<8>) -> !firrtl.uint<1>
      %n_andr = firrtl.node interesting_name %22 : !firrtl.uint<1>
      firrtl.matchingconnect %o_andr, %n_andr : !firrtl.uint<1>
      %23 = firrtl.orr %a : (!firrtl.uint<8>) -> !firrtl.uint<1>
      %n_orr = firrtl.node interesting_name %23 : !firrtl.uint<1>
      firrtl.matchingconnect %o_orr, %n_orr : !firrtl.uint<1>
      %24 = firrtl.xorr %a : (!firrtl.uint<8>) -> !firrtl.uint<1>
      %n_xorr = firrtl.node interesting_name %24 : !firrtl.uint<1>
      firrtl.matchingconnect %o_xorr, %n_xorr : !firrtl.uint<1>
      %25 = firrtl.cat %a, %b, %c : (!firrtl.uint<8>, !firrtl.uint<4>, !firrtl.uint<1>) -> !firrtl.uint<13>
      %n_cat = firrtl.node interesting_name %25 : !firrtl.uint<13>
      firrtl.matchingconnect %o_cat, %n_cat : !firrtl.uint<13>
      %26 = firrtl.bits %a 6 to 2 : (!firrtl.uint<8>) -> !firrtl.uint<5>
      %n_bits = firrtl.node interesting_name %26 : !firrtl.uint<5>
      firrtl.matchingconnect %o_bits, %n_bits : !firrtl.uint<5>
      %27 = firrtl.head %a, 3 : (!firrtl.uint<8>) -> !firrtl.uint<3>
      %n_head = firrtl.node interesting_name %27 : !firrtl.uint<3>
      firrtl.matchingconnect %o_head, %n_head : !firrtl.uint<3>
      %28 = firrtl.tail %a, 3 : (!firrtl.uint<8>) -> !firrtl.uint<5>
      %n_tail = firrtl.node interesting_name %28 : !firrtl.uint<5>
      firrtl.matchingconnect %o_tail, %n_tail : !firrtl.uint<5>
      %29 = firrtl.mux(%c, %a, %b) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %n_mux = firrtl.node interesting_name %29 : !firrtl.uint<8>
      firrtl.matchingconnect %o_mux, %n_mux : !firrtl.uint<8>
    }
  }
}
