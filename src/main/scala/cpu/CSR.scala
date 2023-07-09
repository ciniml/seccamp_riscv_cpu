package cpu

import chisel3._
import chisel3.util._

class MStatusRegister extends Bundle {
  val wpri0 = UInt(1.W)
  val sie = Bool()
  val wpri1 = UInt(1.W)
  val mie = Bool()
  val wpri2 = UInt(1.W)
  val spie = Bool()
  val ube = Bool()
  val mpie = Bool()
  val spp = Bool()
  val vs = UInt(2.W)
  val mpp = UInt(2.W)
  val fs = UInt(2.W)
  val xs = UInt(2.W)
  val mprv = Bool()
  val sum = Bool()
  val mxr = Bool()
  val tvm = Bool()
  val tw = Bool()
  val tsr = Bool()
  val wpri3 = UInt(9.W)
  val uxl = UInt(2.W)
  val sxl = UInt(2.W)
  val sbe = Bool()
  val mbe = Bool()
  val wpri4 = UInt(25.W)
  val sd = Bool()
  val wpri5 = UInt(4.W)

  def toMStatusL(): UInt = {
    Cat(sd, wpri3(7,0), tsr, tw, tvm, mxr, sum, mprv, xs, fs, mpp, vs, spp, mpie, ube, spie, wpri2, mie, wpri1, sie, wpri0)
  }
  def toMStatusH(): UInt = {
    Cat(wpri4, wpri3(8), mbe, sbe, wpri5)
  }
  def toMStatus(): UInt = {
    Cat(sd, wpri4, mbe, sbe, sxl, uxl, wpri3, tsr, tw, tvm, mxr, sum, mprv, xs, fs, mpp, vs, spp, mpie, ube, spie, wpri2, mie, wpri1, sie, wpri0)
  }
}

object MStatusRegister {
  def apply(valueL: UInt, valueH: UInt): MStatusRegister = {
    val mstatus = default()
    mstatus.wpri0 := valueL(0)
    mstatus.sie := valueL(1)
    mstatus.wpri1 := valueL(2)
    mstatus.mie := valueL(3)
    mstatus.wpri2 := valueL(4)
    mstatus.spie := valueL(5)
    mstatus.ube := valueL(6)
    mstatus.mpie := valueL(7)
    mstatus.spp := valueL(8)
    mstatus.vs := valueL(10,9)
    mstatus.mpp := valueL(12,11)
    mstatus.fs := valueL(14,13)
    mstatus.xs := valueL(16,15)
    mstatus.mprv := valueL(17)
    mstatus.sum := valueL(18)
    mstatus.mxr := valueL(19)
    mstatus.tvm := valueL(20)
    mstatus.tw := valueL(21)
    mstatus.tsr := valueL(22)
    mstatus.wpri3 := Cat(valueH(6), valueL(30,23))
    mstatus.sd := valueL(31)
    mstatus.wpri5 := valueH(3,0)
    mstatus.sbe := valueH(4)
    mstatus.mbe := valueH(5)
    mstatus.wpri4 := valueH(31,6)
    mstatus
  }
  
  def default(): MStatusRegister = {
    val mstatus = Wire(new MStatusRegister())
    mstatus.wpri0 := 0.U
    mstatus.sie := false.B
    mstatus.wpri1 := 0.U
    mstatus.mie := false.B
    mstatus.wpri2 := 0.U
    mstatus.spie := false.B
    mstatus.ube := false.B
    mstatus.mpie := false.B
    mstatus.spp := false.B
    mstatus.vs := 0.U
    mstatus.mpp := 0.U
    mstatus.fs := 0.U
    mstatus.xs := 0.U
    mstatus.mprv := false.B
    mstatus.sum := false.B
    mstatus.mxr := false.B
    mstatus.tvm := false.B
    mstatus.tw := false.B
    mstatus.tsr := false.B
    mstatus.wpri3 := 0.U
    mstatus.uxl := 0.U
    mstatus.sxl := 0.U
    mstatus.sbe := false.B
    mstatus.mbe := false.B
    mstatus.wpri4 := 0.U
    mstatus.sd := false.B
    mstatus.wpri5 := 0.U
    mstatus
  }
}
class MipRegister extends Bundle{
  val ssip = Bool()
  val msip = Bool()
  val stip = Bool()
  val mtip = Bool()
  val seip = Bool()
  val meip = Bool()

  def toMip(): UInt = {
    Cat(0.U(4.W), meip, 0.U(1.W), seip, 0.U(1.W), mtip, 0.U(1.W), stip, 0.U(1.W), msip, 0.U(1.W), ssip, 0.U(1.W))
  }
  def hasPending(): Bool = {
    ssip || msip || stip || mtip || seip || meip
  }
}

object MipRegister {
  def default(): MipRegister = {
    val mip = Wire(new MipRegister())
    mip.ssip := false.B
    mip.msip := false.B
    mip.stip := false.B
    mip.mtip := false.B
    mip.seip := false.B
    mip.meip := false.B
    mip
  }
  def apply(value: UInt): MipRegister = {
    val mip = Wire(new MipRegister())
    mip.ssip := value(1)
    mip.msip := value(3)
    mip.stip := value(5)
    mip.mtip := value(7)
    mip.seip := value(9)
    mip.meip := value(11)
    mip
  }
}

class MieRegister extends Bundle{
  val ssie = Bool()
  val msie = Bool()
  val stie = Bool()
  val mtie = Bool()
  val seie = Bool()
  val meie = Bool()

  def toMie(): UInt = {
    Cat(0.U(4.W), meie, 0.U(1.W), seie, 0.U(1.W), mtie, 0.U(1.W), stie, 0.U(1.W), msie, 0.U(1.W), ssie, 0.U(1.W))
  }
}


object MieRegister {
  def default(): MieRegister = {
    val mie = Wire(new MieRegister())
    mie.ssie := false.B
    mie.msie := false.B
    mie.stie := false.B
    mie.mtie := false.B
    mie.seie := false.B
    mie.meie := false.B
    mie
  }
  def apply(value: UInt): MieRegister = {
    val mip = Wire(new MieRegister())
    mip.ssie := value(1)
    mip.msie := value(3)
    mip.stie := value(5)
    mip.mtie := value(7)
    mip.seie := value(9)
    mip.meie := value(11)
    mip
  }
}