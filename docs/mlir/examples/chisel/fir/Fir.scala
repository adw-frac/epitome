//> using scala 2.13.18
//> using dep org.chipsalliance::chisel:7.16.0
//> using plugin org.chipsalliance:::chisel-plugin:7.16.0
//> using options -deprecation -feature -Xcheckinit -Ymacro-annotations -language:reflectiveCalls

import chisel3._
import circt.stage.ChiselStage

/** A 4-tap FIR filter with fixed coefficients: a tiny "accelerator".
  * y[n] = 1*x[n] + 3*x[n-1] + 3*x[n-2] + 1*x[n-3]
  */
class Fir(coeffs: Seq[Int] = Seq(1, 3, 3, 1)) extends Module {
  val io = IO(new Bundle {
    val in    = Input(UInt(8.W))
    val valid = Input(Bool())
    val out   = Output(UInt(16.W))
  })
  // Delay line: taps(0) is the newest sample.
  val taps = Seq(io.in) ++ Seq.fill(coeffs.length - 1)(RegInit(0.U(8.W)))
  when(io.valid) {
    for (i <- 1 until taps.length) taps(i) := taps(i - 1)
  }
  val products = taps.zip(coeffs).map { case (t, c) => t * c.U }
  io.out := products.reduce(_ +& _)
}

object Main extends App {
  print(ChiselStage.emitCHIRRTL(new Fir))
}
