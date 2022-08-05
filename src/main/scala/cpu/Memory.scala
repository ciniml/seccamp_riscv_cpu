package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.util.experimental.loadMemoryFromFileInline

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

class Memory(memoryPath: Option[Int => String], baseAddress: UInt = "x00000000".U) extends Module {
  val io = IO(new Bundle {
    val imem = new ImemPortIo()
    val dmem = new DmemPortIo()
  })

  val mems = (0 to 3).map(_ => Mem(16384/4, UInt(8.W)))
  if( memoryPath.isDefined ) {
    val memoryPath_ = memoryPath.get
    for(i <- 0 to 3) {
      loadMemoryFromFileInline(mems(i), memoryPath_(i))
    }
  }
  val imemWordAddr = (io.imem.addr - baseAddress) >> 2
  val dmemWordAddr = (io.dmem.addr - baseAddress) >> 2
  io.imem.inst := Cat(
    (0 to 3).map(i => mems(i).read(imemWordAddr)).reverse
  )
  io.dmem.rdata := Cat(
    (0 to 3).map(i => mems(i).read(dmemWordAddr)).reverse
  )
  when(io.dmem.wen){
    for(i <- 0 to 3) {
      mems(i).write((io.dmem.addr - baseAddress) >> 2, io.dmem.wdata(8*(i+1)-1, 8*i))
    }
  }
}
