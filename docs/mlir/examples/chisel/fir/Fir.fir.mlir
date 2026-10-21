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
    firrtl.module @Fir(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, in %io_in: !firrtl.uint<8>, in %io_valid: !firrtl.uint<1>, out %io_out: !firrtl.uint<16>) attributes {convention = #firrtl<convention scalarized>} {
      %c3_ui2 = firrtl.constant 3 : !firrtl.uint<2>
      %c1_ui1 = firrtl.constant 1 : !firrtl.uint<1>
      %c0_ui8 = firrtl.constant 0 : !firrtl.uint<8>
      %io_out_0 = firrtl.wire {name = "io_out"} : !firrtl.uint<16>
      firrtl.matchingconnect %io_out, %io_out_0 : !firrtl.uint<16>
      %taps_1 = firrtl.regreset %clock, %reset, %c0_ui8 {firrtl.random_init_start = 0 : ui64} : !firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>
      %taps_2 = firrtl.regreset %clock, %reset, %c0_ui8 {firrtl.random_init_start = 8 : ui64} : !firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>
      %taps_3 = firrtl.regreset %clock, %reset, %c0_ui8 {firrtl.random_init_start = 16 : ui64} : !firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>
      %0 = firrtl.mux(%io_valid, %io_in, %taps_1) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      firrtl.matchingconnect %taps_1, %0 : !firrtl.uint<8>
      %1 = firrtl.mux(%io_valid, %taps_1, %taps_2) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      firrtl.matchingconnect %taps_2, %1 : !firrtl.uint<8>
      %2 = firrtl.mux(%io_valid, %taps_2, %taps_3) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      firrtl.matchingconnect %taps_3, %2 : !firrtl.uint<8>
      %products_0 = firrtl.mul %io_in, %c1_ui1 {name = "products_0"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9>
      %products_1 = firrtl.mul %taps_1, %c3_ui2 {name = "products_1"} : (!firrtl.uint<8>, !firrtl.uint<2>) -> !firrtl.uint<10>
      %products_2 = firrtl.mul %taps_2, %c3_ui2 {name = "products_2"} : (!firrtl.uint<8>, !firrtl.uint<2>) -> !firrtl.uint<10>
      %products_3 = firrtl.mul %taps_3, %c1_ui1 {name = "products_3"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9>
      %_io_out_T = firrtl.add %products_0, %products_1 {name = "_io_out_T"} : (!firrtl.uint<9>, !firrtl.uint<10>) -> !firrtl.uint<11>
      %_io_out_T_1 = firrtl.add %_io_out_T, %products_2 {name = "_io_out_T_1"} : (!firrtl.uint<11>, !firrtl.uint<10>) -> !firrtl.uint<12>
      %_io_out_T_2 = firrtl.add %_io_out_T_1, %products_3 {name = "_io_out_T_2"} : (!firrtl.uint<12>, !firrtl.uint<9>) -> !firrtl.uint<13>
      %3 = firrtl.pad %_io_out_T_2, 16 : (!firrtl.uint<13>) -> !firrtl.uint<16>
      firrtl.matchingconnect %io_out_0, %3 : !firrtl.uint<16>
    }
  }
}
