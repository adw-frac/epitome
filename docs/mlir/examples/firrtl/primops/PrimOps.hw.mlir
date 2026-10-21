module {
  hw.module @PrimOps(in %a : i8, in %b : i4, in %s : i8, in %t : i4, in %c : i1, out o_add : i9, out o_sub : i9, out o_mul : i12, out o_div : i8, out o_rem : i4, out o_sdiv : i9, out o_srem : i4, out o_lt : i1, out o_slt : i1, out o_pad : i12, out o_spad : i12, out o_asuint : i8, out o_shl : i11, out o_shr : i5, out o_sshr : i5, out o_dshl : i23, out o_dshr : i8, out o_sdshr : i8, out o_cvt : i9, out o_neg : i9, out o_not : i8, out o_and : i8, out o_andr : i1, out o_orr : i1, out o_xorr : i1, out o_cat : i13, out o_bits : i5, out o_head : i3, out o_tail : i5, out o_mux : i8) {
    %c-1_i8 = hw.constant -1 : i8
    %c0_i9 = hw.constant 0 : i9
    %c0_i19 = hw.constant 0 : i19
    %c0_i15 = hw.constant 0 : i15
    %c0_i3 = hw.constant 0 : i3
    %c0_i8 = hw.constant 0 : i8
    %c0_i4 = hw.constant 0 : i4
    %c0_i5 = hw.constant 0 : i5
    %false = hw.constant false
    %0 = comb.concat %false, %a : i1, i8
    %1 = comb.concat %c0_i5, %b : i5, i4
    %2 = comb.add bin %0, %1 {sv.namehint = "n_add"} : i9
    %3 = comb.sub bin %0, %1 {sv.namehint = "n_sub"} : i9
    %4 = comb.concat %c0_i4, %a : i4, i8
    %5 = comb.concat %c0_i8, %b : i8, i4
    %6 = comb.mul bin %4, %5 {sv.namehint = "n_mul"} : i12
    %7 = comb.concat %c0_i4, %b : i4, i4
    %8 = comb.divu bin %a, %7 {sv.namehint = "n_div"} : i8
    %9 = comb.modu bin %a, %7 {sv.namehint = "n_rem"} : i8
    %10 = comb.extract %9 from 0 {sv.namehint = "n_rem"} : (i8) -> i4
    %11 = comb.extract %s from 7 : (i8) -> i1
    %12 = comb.concat %11, %s : i1, i8
    %13 = comb.extract %t from 3 : (i4) -> i1
    %14 = comb.replicate %13 : (i1) -> i5
    %15 = comb.concat %14, %t : i5, i4
    %16 = comb.divs bin %12, %15 {sv.namehint = "n_sdiv"} : i9
    %17 = comb.replicate %13 : (i1) -> i4
    %18 = comb.concat %17, %t : i4, i4
    %19 = comb.mods bin %s, %18 {sv.namehint = "n_srem"} : i8
    %20 = comb.extract %19 from 0 {sv.namehint = "n_srem"} : (i8) -> i4
    %21 = comb.icmp bin ult %a, %7 {sv.namehint = "n_lt"} : i8
    %22 = comb.icmp bin slt %s, %18 {sv.namehint = "n_slt"} : i8
    %23 = comb.replicate %13 : (i1) -> i8
    %24 = comb.concat %23, %t : i8, i4
    %25 = comb.concat %a, %c0_i3 {sv.namehint = "n_shl"} : i8, i3
    %26 = comb.extract %a from 3 {sv.namehint = "n_shr"} : (i8) -> i5
    %27 = comb.extract %s from 3 : (i8) -> i5
    %28 = comb.concat %c0_i15, %a : i15, i8
    %29 = comb.concat %c0_i19, %b : i19, i4
    %30 = comb.shl bin %28, %29 {sv.namehint = "n_dshl"} : i23
    %31 = comb.shru bin %a, %7 {sv.namehint = "n_dshr"} : i8
    %32 = comb.shrs bin %s, %7 {sv.namehint = "n_sdshr"} : i8
    %33 = comb.sub bin %c0_i9, %0 {sv.namehint = "n_neg"} : i9
    %34 = comb.xor bin %a, %c-1_i8 {sv.namehint = "n_not"} : i8
    %35 = comb.extract %a from 0 : (i8) -> i4
    %36 = comb.and bin %35, %b : i4
    %37 = comb.concat %c0_i4, %36 : i4, i4
    %38 = comb.icmp bin eq %a, %c-1_i8 {sv.namehint = "n_andr"} : i8
    %39 = comb.icmp bin ne %a, %c0_i8 {sv.namehint = "n_orr"} : i8
    %40 = comb.parity bin %a {sv.namehint = "n_xorr"} : i8
    %41 = comb.concat %a, %b, %c {sv.namehint = "n_cat"} : i8, i4, i1
    %42 = comb.extract %a from 2 {sv.namehint = "n_bits"} : (i8) -> i5
    %43 = comb.extract %a from 5 {sv.namehint = "n_head"} : (i8) -> i3
    %44 = comb.extract %a from 0 {sv.namehint = "n_tail"} : (i8) -> i5
    %45 = comb.mux bin %c, %a, %7 {sv.namehint = "n_mux"} : i8
    hw.output %2, %3, %6, %8, %10, %16, %20, %21, %22, %5, %24, %s, %25, %26, %27, %30, %31, %32, %0, %33, %34, %37, %38, %39, %40, %41, %42, %43, %44, %45 : i9, i9, i12, i8, i4, i9, i4, i1, i1, i12, i12, i8, i11, i5, i5, i23, i8, i8, i9, i9, i8, i8, i1, i1, i1, i13, i5, i3, i5, i8
  }
  om.class @PrimOps_Class(%basepath: !om.basepath) {
    om.class.fields 
  }
}
