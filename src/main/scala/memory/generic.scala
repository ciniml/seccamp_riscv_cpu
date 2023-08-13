package memory

import chisel3._
import chisel3.util._
import chisel3.util.experimental.{loadMemoryFromFile, loadMemoryFromFileInline}

/**
  * Generic dual port memory implementation
  *
  * @param dataWidth
  * @param numberOfBits
  * @param initFile
  */
class DualPortMemory(val dataWidth: Int, val numberOfBits: Int, val initFile: Option[String] = None, val inlineInit: Boolean = true) extends Module {
    val io = IO(new Bundle{
        val portA = Flipped(FixedLatencyMemoryPort(dataWidth, numberOfBits))
        val portB = Flipped(FixedLatencyMemoryPort(dataWidth, numberOfBits))
    })

    if( numberOfBits % dataWidth != 0 ) {
        throw new Exception("numberOfBits must be a multiple of dataWidth")
    }

    val mem = SyncReadMem(numberOfBits / dataWidth, UInt(dataWidth.W))
    // Memory dedup prevention.
    // See https://github.com/chipsalliance/chisel/issues/2899
    val dedupBlock = WireInit(mem.hashCode.U)
    initFile match {
        case Some(filename) => {
            if( inlineInit ) {
                loadMemoryFromFileInline(mem, filename)
            } else {
                loadMemoryFromFile(mem, filename)
            }
        }
        case None => {
            // do nothing
        }
    }
    val portADataOut = WireDefault(0.U(dataWidth.W))
    withClockAndReset(io.portA.clock, io.portA.reset) {
        when(io.portA.chipEnable) {
            when(io.portA.writeEnable) {
                mem.write(io.portA.address, io.portA.dataIn)
            }.otherwise {
                portADataOut := mem.read(io.portA.address)
            }
        }
    }
    io.portA.dataOut := portADataOut

    val portBDataOut = WireDefault(0.U(dataWidth.W))
    withClockAndReset(io.portB.clock, io.portB.reset) {
        when(io.portB.chipEnable) {
            when(io.portB.writeEnable) {
                mem.write(io.portB.address, io.portB.dataIn)
            }.otherwise {
                portBDataOut := mem.read(io.portB.address)
            }
        }
    }
    io.portB.dataOut := portBDataOut
}