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

  // 要素型を8bit幅x4つの配列にし、メモリの長さを1/4に変更
  val mem = SyncReadMem(16384/4, Vec(4, UInt(8.W))) 
  loadMemoryFromFile(mem, "src/hex/hazard_ex.hex")
  io.imem.inst := Cat(
    mem.read(io.imem.addr >> 2).reverse,  // アドレスをワード単位に変換。長さ4のVecが返ってくるのでreverseで逆順にしてCatで結合
  )
  io.dmem.rdata := Cat(
    mem.read(io.dmem.addr >> 2).reverse,
  )
  when(io.dmem.wen){
    // wdataを8bit単位に切り分けて逆順に並べなおしたものを書き込む
    mem.write(io.dmem.addr >> 2, VecInit((0 to 3).map(i => io.dmem.wdata(8*(i+1)-1, 8*i)).reverse))
  }
}
