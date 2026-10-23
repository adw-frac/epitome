module {
  firrtl.circuit "Fir" {
    firrtl.layer @Verification bind attributes {output_file = #hw.output_file<"verification/">} {
      firrtl.layer @Assert bind attributes {output_file = #hw.output_file<"verification/assert/">} {
        firrtl.layer @Temporal inline {
        }
      }
      firrtl.layer @Assume bind attributes {output_file = #hw.output_file<"verification/assume/">} {
        firrtl.layer @Temporal inline {
        }
      }
      firrtl.layer @Cover bind attributes {output_file = #hw.output_file<"verification/cover/">} {
        firrtl.layer @Temporal inline {
        }
      }
    }
    firrtl.module @Fir(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, out %io: !firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>) attributes {annotations = [{class = "firrtl.transforms.DedupGroupAnnotation", group = "Fir"}], convention = #firrtl<convention scalarized>} {
      %0 = firrtl.subfield %io[out] : !firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>
      %1 = firrtl.subfield %io[in] : !firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>
      %2 = firrtl.subfield %io[valid] : !firrtl.bundle<in flip: uint<8>, valid flip: uint<1>, out: uint<16>>
      %c0_ui8 = firrtl.constant 0 : !firrtl.const.uint<8>
      %taps_1 = firrtl.regreset interesting_name %clock, %reset, %c0_ui8 : !firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>, !firrtl.uint<8>
      %taps_2 = firrtl.regreset interesting_name %clock, %reset, %c0_ui8 : !firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>, !firrtl.uint<8>
      %taps_3 = firrtl.regreset interesting_name %clock, %reset, %c0_ui8 : !firrtl.clock, !firrtl.uint<1>, !firrtl.const.uint<8>, !firrtl.uint<8>
      firrtl.when %2 : !firrtl.uint<1> {
        firrtl.matchingconnect %taps_1, %1 : !firrtl.uint<8>
        firrtl.matchingconnect %taps_2, %taps_1 : !firrtl.uint<8>
        firrtl.matchingconnect %taps_3, %taps_2 : !firrtl.uint<8>
      }
      %c1_ui1 = firrtl.constant 1 : !firrtl.const.uint<1>
      %3 = firrtl.mul %1, %c1_ui1 : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9>
      %products_0 = firrtl.node interesting_name %3 : !firrtl.uint<9>
      %c3_ui2 = firrtl.constant 3 : !firrtl.const.uint<2>
      %4 = firrtl.mul %taps_1, %c3_ui2 : (!firrtl.uint<8>, !firrtl.const.uint<2>) -> !firrtl.uint<10>
      %products_1 = firrtl.node interesting_name %4 : !firrtl.uint<10>
      %5 = firrtl.mul %taps_2, %c3_ui2 : (!firrtl.uint<8>, !firrtl.const.uint<2>) -> !firrtl.uint<10>
      %products_2 = firrtl.node interesting_name %5 : !firrtl.uint<10>
      %6 = firrtl.mul %taps_3, %c1_ui1 : (!firrtl.uint<8>, !firrtl.const.uint<1>) -> !firrtl.uint<9>
      %products_3 = firrtl.node interesting_name %6 : !firrtl.uint<9>
      %7 = firrtl.add %products_0, %products_1 : (!firrtl.uint<9>, !firrtl.uint<10>) -> !firrtl.uint<11>
      %_io_out_T = firrtl.node interesting_name %7 : !firrtl.uint<11>
      %8 = firrtl.add %_io_out_T, %products_2 : (!firrtl.uint<11>, !firrtl.uint<10>) -> !firrtl.uint<12>
      %_io_out_T_1 = firrtl.node interesting_name %8 : !firrtl.uint<12>
      %9 = firrtl.add %_io_out_T_1, %products_3 : (!firrtl.uint<12>, !firrtl.uint<9>) -> !firrtl.uint<13>
      %_io_out_T_2 = firrtl.node interesting_name %9 : !firrtl.uint<13>
      %10 = firrtl.pad %_io_out_T_2, 16 : (!firrtl.uint<13>) -> !firrtl.uint<16>
      firrtl.matchingconnect %0, %10 : !firrtl.uint<16>
    }
  }
}
