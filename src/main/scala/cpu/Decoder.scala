package cpu

import chisel3._
import chisel3.util._
import common.Consts._

class DMemDecoder(targetAddressRanges: Seq[(BigInt, BigInt)]) extends Module {
  val io = IO(new Bundle {
    val initiator = new DmemPortIo()
    val targets = Vec(targetAddressRanges.size, Flipped(new DmemPortIo))
  })

  val rvalid = WireDefault(true.B)
  val rdata = WireDefault("xdeadbeef".U(32.W))
  val wready = WireDefault(false.B)

  io.initiator.rvalid := rvalid
  io.initiator.rdata := rdata

  for(((start, length), index) <- targetAddressRanges.zipWithIndex) {
    val target = io.targets(index)

    val addr = WireDefault(0.U(32.W))
    val ren = WireDefault(false.B)
    val wen = WireDefault(false.B)
    val wdata = WireDefault("xdeadbeef".U(32.W))
    val wstrb = WireDefault("b1111".U)
    
    target.addr := addr
    target.ren := ren
    target.wen := wen
    target.wdata := wdata
    target.wstrb := wstrb

    when(start.U <= io.initiator.addr && io.initiator.addr < (start + length).U ) {
      addr := io.initiator.addr - start.U
      ren := io.initiator.ren
      rvalid := target.rvalid
      rdata := target.rdata
      wen := io.initiator.wen
      wdata := io.initiator.wdata
      wstrb := io.initiator.wstrb
    }
  }
}