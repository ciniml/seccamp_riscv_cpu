package cpu

import chisel3._
import chisel3.util._
import common.Consts._
import chisel3.util.experimental.loadMemoryFromFileInline

import chisel3.util.experimental.loadMemoryFromFile

import gowin.GowinDualPortMemory
import memory._
import java.math.BigInteger

class ImemPortIo extends Bundle {
  val addr = Input(UInt(WORD_LEN.W))
  val inst = Output(UInt(WORD_LEN.W))
  val valid = Output(Bool())
}

class DmemPortIo extends Bundle {
  val addr  = Input(UInt(WORD_LEN.W))
  val rdata = Output(UInt(WORD_LEN.W))
  val ren = Input(Bool())
  val rvalid = Output(Bool())
  val wen   = Input(Bool())
  val wstrb = Input(UInt(4.W))
  val wdata = Input(UInt(WORD_LEN.W))
}

class Memory(memoryPath: Option[Int => String], baseAddress: UInt = "x80000000".U, sizeInBytes: Int = 16384, forSimulation: Boolean = false, useTargetPrimitive: Boolean = true) extends Module {
  val io = IO(new Bundle {
    val imem = new ImemPortIo()
    val dmem = new DmemPortIo()
  })

  val imemPorts = (0 to 3).map(_ => Wire(Flipped(FixedLatencyMemoryPort(8, sizeInBytes * 8 / 4)))).toSeq
  val dmemPorts = (0 to 3).map(_ => Wire(Flipped(FixedLatencyMemoryPort(8, sizeInBytes * 8 / 4)))).toSeq
  val mems = (0 to 3).map(i => {
    if( useTargetPrimitive ) {
      val initData = memoryPath match {
        case Some(path) => {
          val initFilePath = path(i)
          // Read init file
          val initFile = scala.io.Source.fromFile(initFilePath)
          val initFileContent = initFile.getLines().map(line => {
            line
          }).grouped(32).map(group => {
            var hexString = group.reverse.mkString
            BigInt(hexString, 16)
          }).toSeq
          Some(initFileContent)
        }
        case None => None
      }
      val mem = Module(new GowinDualPortMemory(8, 8, sizeInBytes*8/4, initData))
      mem.io.portA <> imemPorts(i)
      mem.io.portB <> dmemPorts(i)
      mem
    } else {
      val initFile = memoryPath match {
        case Some(path) => Some(path(i))
        case None => None
      }
      // For simulation, we must use loadMemoryFileInline instead of loadMemoryFile, which is not supported by the simulator backend.
      val mem = Module(new DualPortMemory(8, sizeInBytes*8/4, initFile, true))
      mem.io.portA <> imemPorts(i)
      mem.io.portB <> dmemPorts(i)
      mem
    }
  })

  val imemWordAddrBits = io.imem.addr.getWidth - 2
  val imemWordAddr = (io.imem.addr - baseAddress) >> 2
  val imemWordAddrFetched = Reg(UInt(imemWordAddrBits.W)) // フェッチ済みのアドレス
  val isFirstCycle = RegInit(true.B)  // リセット直後かどうか？
  isFirstCycle := false.B
  // リセット直後でなく、対象アドレスがフェッチ済みならデータ有効
  io.imem.valid := !isFirstCycle && imemWordAddrFetched === imemWordAddr
  imemWordAddrFetched := imemWordAddr
  for(port <- imemPorts) {
    port.clock := clock
    port.reset := reset
    port.address := imemWordAddr
    port.dataIn := 0.U
    port.chipEnable := true.B
    port.writeEnable := false.B
  }
  io.imem.inst := Cat(
    imemPorts.map(port => port.dataOut).reverse
  )

  val dmemWordAddr = (io.dmem.addr - baseAddress) >> 2
  val rvalid = RegInit(false.B)
  io.dmem.rvalid := rvalid
  val rdata = Cat(dmemPorts.map(port => port.dataOut).reverse)
  rvalid := false.B
  val dmemAddrReg = Reg(UInt(io.dmem.addr.getWidth.W))
  when( io.dmem.ren && !io.dmem.wen && !rvalid ) {
    rvalid := true.B
    dmemAddrReg := io.dmem.addr
  }
  io.dmem.rdata := rdata
  for((port, index) <- dmemPorts.zipWithIndex) {
    port.clock := clock
    port.reset := reset
    port.chipEnable := io.dmem.ren || io.dmem.wen
    port.writeEnable := io.dmem.wen && io.dmem.wstrb(index)
    port.address := dmemWordAddr
    port.dataIn := io.dmem.wdata(8*(index+1)-1, 8*index)
  }
  when( rvalid ) {
    printf(p"Data read address=0x${Hexadecimal(dmemAddrReg)} data=0x${Hexadecimal(rdata)}\n")
  }
}
