//> using scala 2.13.18
//> using dep org.chipsalliance::chisel:7.16.0
//> using plugin org.chipsalliance:::chisel-plugin:7.16.0
//> using options -deprecation -feature -Xcheckinit -Ymacro-annotations -language:reflectiveCalls

import chisel3._
import circt.stage.ChiselStage

/** An 8-bit counter that counts up while `en` is high. */
class Counter extends Module {
  val io = IO(new Bundle {
    val en    = Input(Bool())
    val count = Output(UInt(8.W))
  })
  val reg = RegInit(0.U(8.W))
  when(io.en) { reg := reg + 1.U }
  io.count := reg
}

object Main extends App {
  print(ChiselStage.emitCHIRRTL(new Counter))
}
