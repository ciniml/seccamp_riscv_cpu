package video

import chisel3._
import chisel3.util._

class DviOut extends Module {
    val videoIoType = new VideoIO(8*3)
    val io = IO( new Bundle{
        val video = Input(videoIoType)
        val dviClock = Output(UInt(10.W))
        val dviData0 = Output(UInt(10.W))
        val dviData1 = Output(UInt(10.W))
        val dviData2 = Output(UInt(10.W))
    })

    val dviData = RegInit(VecInit((0 to 2).map(_ => 0.U(10.W))))
    io.dviData0 := dviData(0)
    io.dviData1 := dviData(1)
    io.dviData2 := dviData(2)
    io.dviClock := "b00000_11111".U

    // delay 2 cycles
    val videoRegsDepth = 3
    val videoRegs = RegInit(VecInit((0 to videoRegsDepth-1).map(_ => new VideoIO(9*3).default())))
    videoRegs(videoRegsDepth-1).dataEnable := io.video.dataEnable
    videoRegs(videoRegsDepth-1).hSync := io.video.hSync
    videoRegs(videoRegsDepth-1).vSync := io.video.vSync
    videoRegs(videoRegsDepth-1).pixelData := Cat((0 to 2).map(ch => transitionMinimized(io.video.pixelData((ch+1)*8 - 1, ch*8))).reverse)
    for(i <- 0 to videoRegsDepth-2) {
        videoRegs(i) := videoRegs(i + 1)
    }

    def transitionMinimized(in: UInt): UInt = {
        assert(in.getWidth == 8)    // transitionMinimized can only be applied  to 8bit data.
        val popCount = PopCount(in)
        val xnorProcess = popCount > 4.U || (popCount === 4.U && !in(0))
        val bits = Wire(Vec(in.getWidth, Bool()))
        bits(0) := in(0)
        for(i <- 1 to in.getWidth - 1) {
            bits(i) := (bits(i - 1) ^ in(i)) ^ xnorProcess
        }
        Cat(!xnorProcess, bits.asUInt)  // XNOR process: MSB is 0, XOR process: MSB is 1
    }
    def dcBalancing(in: UInt, counter: SInt): Tuple2[UInt, SInt] = {
        // from DVI spec p.29 Figure 3-5
        assert(in.getWidth == 9)    // DC balancing process can only be applied to 9bit data.
        val n1 = PopCount(in(7, 0))
        val n0n1 = 8.S - (n1 << 1).zext  // n0 - n1 = 8 - 2n1
        val out = WireDefault(Cat(0.U(1.W), in))
        val newCounter = WireDefault(0.S(counter.getWidth.W))

        when(counter === 0.S || n0n1 === 0.S) {
            out := Cat(
                !in(8),
                in(8),
                Mux(in(8), in(7, 0), ~in(7, 0)),
            )
            when( in(8) ) {
                newCounter := counter - n0n1
            } .otherwise {
                newCounter := counter + n0n1
            }
        } .elsewhen( (counter > 0.S && n0n1 < 0.S) || (counter < 0.S && n0n1 > 0.S) ) {
            out := Cat(
                true.B,
                in(8),
                ~in(7, 0),
            )
            when( in(8) ) {
                newCounter := counter + n0n1 + 2.S
            } .otherwise {
                newCounter := counter + n0n1
            }
        } .otherwise {
            out := Cat(
                false.B,
                in(8),
                in(7, 0),
            )
            when( in(8) ) {
                newCounter := counter - n0n1
            } .otherwise {
                newCounter := counter - n0n1 - 2.S
            }
        }
        (out, newCounter)
    }
    
    def transitionMaximized(in: UInt): UInt = {
        assert(in.getWidth == 2)
        MuxLookup(in, 0.U(10.W), Seq(
            "b00".U -> "b1101010100".U,
            "b01".U -> "b0010101011".U,
            "b10".U -> "b0101010100".U,
            "b11".U -> "b1010101011".U,
        ))
    }

    val video = videoRegs(0)
    val counter = RegInit(VecInit((0 to 2).map(_ => 0.S(8.W))))
    when(!video.dataEnable) {
        dviData(0) := transitionMaximized(Cat(video.vSync, video.hSync))
        dviData(1) := transitionMaximized("b00".U(2.W))
        dviData(2) := transitionMaximized("b00".U(2.W))
        for(ch <- 0 to 2) {
            counter(ch) := 0.S
        }
    } .otherwise {
        // Video data period
        for(ch <- 0 to 2) {
            val (dcBalanced, newCounter) = dcBalancing(video.pixelData((ch+1)*9-1, ch*9), counter(ch))
            dviData(ch) := dcBalanced
            counter(ch) := newCounter
        }
    }
}