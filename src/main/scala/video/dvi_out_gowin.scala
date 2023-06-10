package video

import chisel3._
import chisel3.util._
import gowin.OSER10

/**
  * DVI Out module for GOWIN
  *
  */
class DviOutGowin extends Module {
    val io = IO(new Bundle{
        val video = Input(new VideoIO(24))
        val serializerClock = Input(Clock())
        val dviClock = Output(Bool())
        val dviData0 = Output(Bool())
        val dviData1 = Output(Bool())
        val dviData2 = Output(Bool())
    })

    val dviOut = Module(new DviOut)
    dviOut.io.video <> io.video
    val parallelIn = Wire(Vec(4, UInt(10.W)))
    val serialOut = Wire(Vec(4, Bool()))

    parallelIn(0) := dviOut.io.dviClock
    parallelIn(1) := dviOut.io.dviData0
    parallelIn(2) := dviOut.io.dviData1
    parallelIn(3) := dviOut.io.dviData2

    for(ch <- 0 to 3) {
        val serializer = Module(new OSER10)
        serializer.io.RESET := this.reset
        serializer.io.PCLK := this.clock
        serializer.io.FCLK := io.serializerClock
        serializer.io.D0 := parallelIn(0)(0)
        serializer.io.D1 := parallelIn(0)(1)
        serializer.io.D2 := parallelIn(0)(2)
        serializer.io.D3 := parallelIn(0)(3)
        serializer.io.D4 := parallelIn(0)(4)
        serializer.io.D5 := parallelIn(0)(5)
        serializer.io.D6 := parallelIn(0)(6)
        serializer.io.D7 := parallelIn(0)(7)
        serializer.io.D8 := parallelIn(0)(8)
        serializer.io.D9 := parallelIn(0)(9)
        serialOut(ch) := serializer.io.Q
    }

    io.dviClock := serialOut(0)
    io.dviData0 := serialOut(1)
    io.dviData1 := serialOut(2)
    io.dviData2 := serialOut(3)
}