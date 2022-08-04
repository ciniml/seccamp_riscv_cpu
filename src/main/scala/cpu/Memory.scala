package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.util.experimental.loadMemoryFromFile

class ImemPortIo extends Bundle {
  val addr = Input(UInt(WORD_LEN.W))
  val inst = Output(UInt(WORD_LEN.W))
}

class DmemPortIo extends Bundle {
  val addr  = Input(UInt(WORD_LEN.W))
  val rdata = Output(UInt(WORD_LEN.W))
  val wen   = Input(Bool())
  val wdata = Input(UInt(WORD_LEN.W))
}

class Memory extends Module {
  val io = IO(new Bundle {
    val imem = new ImemPortIo()
    val dmem = new DmemPortIo()
  })

  val mem = SyncReadMem(16384/4, Vec(4, UInt(8.W)))
  loadMemoryFromFile(mem, "src/hex/hazard_ex.hex")
  io.imem.inst := Cat(
    mem.read(io.imem.addr >> 2).reverse,
  )
  io.dmem.rdata := Cat(
    mem.read(io.dmem.addr >> 2).reverse,
  )
  when(io.dmem.wen){
    mem.write(io.dmem.addr >> 2, VecInit((0 to 3).map(i => io.dmem.wdata(8*(i+1)-1, 8*i)).reverse))
  }
}
