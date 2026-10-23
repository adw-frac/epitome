module {
  firrtl.circuit "GCD" {
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
    firrtl.module @GCD(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, in %io_value1: !firrtl.uint<16>, in %io_value2: !firrtl.uint<16>, in %io_loadingValues: !firrtl.uint<1>, out %io_outputGCD: !firrtl.uint<16>, out %io_outputValid: !firrtl.uint<1>) attributes {convention = #firrtl<convention scalarized>} {
      %io_outputGCD_0 = firrtl.wire {name = "io_outputGCD"} : !firrtl.uint<16>
      %io_outputValid_1 = firrtl.wire {name = "io_outputValid"} : !firrtl.uint<1>
      firrtl.matchingconnect %io_outputGCD, %io_outputGCD_0 : !firrtl.uint<16>
      firrtl.matchingconnect %io_outputValid, %io_outputValid_1 : !firrtl.uint<1>
      %x = firrtl.reg %clock {firrtl.random_init_start = 0 : ui64} : !firrtl.clock, !firrtl.uint<16>
      %y = firrtl.reg %clock {firrtl.random_init_start = 16 : ui64} : !firrtl.clock, !firrtl.uint<16>
      %0 = firrtl.gt %x, %y : (!firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<1>
      %_x_T = firrtl.sub %x, %y {name = "_x_T"} : (!firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<17>
      %_x_T_1 = firrtl.bits %_x_T 15 to 0 {name = "_x_T_1"} : (!firrtl.uint<17>) -> !firrtl.uint<16>
      %1 = firrtl.mux(%0, %_x_T_1, %x) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      %_y_T = firrtl.sub %y, %x {name = "_y_T"} : (!firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<17>
      %_y_T_1 = firrtl.bits %_y_T 15 to 0 {name = "_y_T_1"} : (!firrtl.uint<17>) -> !firrtl.uint<16>
      %2 = firrtl.mux(%0, %y, %_y_T_1) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      %3 = firrtl.mux(%io_loadingValues, %io_value1, %1) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      firrtl.matchingconnect %x, %3 : !firrtl.uint<16>
      %4 = firrtl.mux(%io_loadingValues, %io_value2, %2) : (!firrtl.uint<1>, !firrtl.uint<16>, !firrtl.uint<16>) -> !firrtl.uint<16>
      firrtl.matchingconnect %y, %4 : !firrtl.uint<16>
      firrtl.matchingconnect %io_outputGCD_0, %x : !firrtl.uint<16>
      %5 = firrtl.orr %y : (!firrtl.uint<16>) -> !firrtl.uint<1>
      %_io_outputValid_T = firrtl.not %5 {name = "_io_outputValid_T"} : (!firrtl.uint<1>) -> !firrtl.uint<1>
      firrtl.matchingconnect %io_outputValid_1, %_io_outputValid_T : !firrtl.uint<1>
    }
  }
}
