package memory

import chisel3._
import chisel3.util.log2Ceil

class FixedLatencyMemoryPort(val dataWidth: Int, val numberOfBits: Int) extends Bundle {
    if( (numberOfBits % dataWidth) != 0 ) {
        throw new Exception("numberOfBits must be a multiple of dataWidth")
    }
    val dataIn = Output(UInt(dataWidth.W))
    val dataOut = Input(UInt(dataWidth.W))
    val address = Output(UInt(log2Ceil(numberOfBits / dataWidth).W))
    val chipEnable = Output(Bool())
    val writeEnable = Output(Bool())
    val clock = Output(Clock())
    val reset = Output(Reset())
}

object FixedLatencyMemoryPort {
    def apply(dataWidth: Int, numberOfBits: Int) = {
        new FixedLatencyMemoryPort(dataWidth, numberOfBits)
    }
}