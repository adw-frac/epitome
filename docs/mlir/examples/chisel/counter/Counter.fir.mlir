module {
  firrtl.circuit "Counter" {
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
    firrtl.module @Counter(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, in %io_en: !firrtl.uint<1>, out %io_count: !firrtl.uint<8>) attributes {convention = #firrtl<convention scalarized>} {
      %c1_ui1 = firrtl.constant 1 : !firrtl.uint<1>
      %c0_ui8 = firrtl.constant 0 : !firrtl.uint<8>
      %io_count_0 = firrtl.wire {name = "io_count"} : !firrtl.uint<8>
      firrtl.matchingconnect %io_count, %io_count_0 : !firrtl.uint<8>
      %reg = firrtl.regreset %clock, %reset, %c0_ui8 {firrtl.random_init_start = 0 : ui64} : !firrtl.clock, !firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>
      %_reg_T = firrtl.add %reg, %c1_ui1 {name = "_reg_T"} : (!firrtl.uint<8>, !firrtl.uint<1>) -> !firrtl.uint<9>
      %_reg_T_1 = firrtl.bits %_reg_T 7 to 0 {name = "_reg_T_1"} : (!firrtl.uint<9>) -> !firrtl.uint<8>
      %0 = firrtl.mux(%io_en, %_reg_T_1, %reg) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<8>) -> !firrtl.uint<8>
      firrtl.matchingconnect %reg, %0 : !firrtl.uint<8>
      firrtl.matchingconnect %io_count_0, %reg : !firrtl.uint<8>
    }
  }
}
