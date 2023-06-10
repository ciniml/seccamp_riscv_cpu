package gowin

import chisel3._
import chisel3.experimental._

/**
  * GOWIN IOBUF OSER10 - 10bit output serializer
  */
class OSER10 extends BlackBox(Map("GSREN" -> "false", // Disable global reset
                                  "LSREN" -> "true"   // Enable local reset
                     )) {
  val io = IO(new Bundle {
    val Q = Output(Bool())  // Serial out
    val D0 = Input(Bool())  // Parallel in 0
    val D1 = Input(Bool())  // Parallel in 1
    val D2 = Input(Bool())  // Parallel in 2
    val D3 = Input(Bool())  // Parallel in 3
    val D4 = Input(Bool())  // Parallel in 4
    val D5 = Input(Bool())  // Parallel in 5
    val D6 = Input(Bool())  // Parallel in 6
    val D7 = Input(Bool())  // Parallel in 7
    val D8 = Input(Bool())  // Parallel in 8
    val D9 = Input(Bool())  // Parallel in 9
    val FCLK = Input(Clock())   // Fast (serializer) clock
    val PCLK = Input(Clock())   // Parallel clock
    val RESET = Input(Bool())   // Reset
  })
}