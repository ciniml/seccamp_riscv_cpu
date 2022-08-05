package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.util.experimental.loadMemoryFromFileInline

class ImemPortIo extends Bundle {
  val addr = Input(UInt(WORD_LEN.W))
  val inst = Output(UInt(WORD_LEN.W))
  val valid = Output(Bool())
}

class DmemPortIo extends Bundle {
  val addr  = Input(UInt(WORD_LEN.W))
  val rdata = Output(UInt(WORD_LEN.W))
  val rvalid = Output(Bool())
  val wen   = Input(Bool())
  val wdata = Input(UInt(WORD_LEN.W))
}

class Memory(memoryPath: Option[Int => String], baseAddress: UInt = "x80000000".U) extends Module {
  val io = IO(new Bundle {
    val imem = new ImemPortIo()
    val dmem = new DmemPortIo()
  })

  val mems = (0 to 3).map(_ => SyncReadMem(16384/4, UInt(8.W)))
  if( memoryPath.isDefined ) {
    val memoryPath_ = memoryPath.get
    for(i <- 0 to 3) {
      loadMemoryFromFileInline(mems(i), memoryPath_(i))
    }
  }
  val imemWordAddrBits = io.imem.addr.getWidth - 2
  val imemWordAddr = (io.imem.addr - baseAddress) >> 2
  val imemWordAddrFetched = Reg(UInt(imemWordAddrBits.W)) // フェッチ済みのアドレス
  val isFirstCycle = RegInit(true.B)  // リセット直後かどうか？
  isFirstCycle := false.B
  // リセット直後でなく、対象アドレスがフェッチ済みならデータ有効
  io.imem.valid := !isFirstCycle && imemWordAddrFetched === imemWordAddr
  imemWordAddrFetched := imemWordAddr
  io.imem.inst := Cat(
    (0 to 3).map(i => mems(i).read(imemWordAddr)).reverse
  )

  io.dmem.rvalid := false.B
  val dmemWordAddr = (io.dmem.addr - baseAddress) >> 2
  io.dmem.rdata := Cat(
    (0 to 3).map(i => mems(i).read(dmemWordAddr)).reverse
  )
  when(io.dmem.wen){
    for(i <- 0 to 3) {
      mems(i).write((io.dmem.addr - baseAddress) >> 2, io.dmem.wdata(8*(i+1)-1, 8*i))
    }
  }
}
