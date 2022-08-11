package video

import chisel3._
import chisel3.util._

class SimpleTestPatternGenerator(videoParams: VideoParams, rectSize: Int = 32) extends Module {
    val io = IO(new Bundle {
        val video = new VideoIO(videoParams.pixelBits)
    })

    val totalCountsHMinus1 = videoParams.totalCountsH.U - 1.U
    val totalCountsVMinus1 = videoParams.totalCountsV.U - 1.U 
    val activeHLower = (videoParams.pulseWidthH + videoParams.backPorchH).U
    val activeHUpper = (videoParams.pulseWidthH + videoParams.backPorchH + videoParams.pixelsH).U
    val activeVLower = (videoParams.pulseWidthV + videoParams.backPorchV).U
    val activeVUpper = (videoParams.pulseWidthV + videoParams.backPorchV + videoParams.pixelsV).U

    val counterH = RegInit(0.U(videoParams.countHBits.W))
    val counterV = RegInit(0.U(videoParams.countVBits.W))
    val data = RegInit(0.U(videoParams.pixelBits.W))
    val dataEnable = Wire(Bool())
    val dataEnableReg = RegInit(false.B)
    val hSync = RegInit(true.B)
    val vSync = RegInit(true.B)
    val frameUpdate = WireDefault(false.B)

    when(counterH < totalCountsHMinus1) {
        counterH := counterH + 1.U
    } .otherwise {
        counterH := 0.U
        when( counterV < totalCountsVMinus1 ) {
            counterV := counterV + 1.U
        } .otherwise {
            counterV := 0.U
            frameUpdate := true.B
        }
    }
    data := 0xffff00.U
    dataEnableReg := dataEnable

    val rectL = RegInit(0.U(log2Ceil(videoParams.pixelsH).W))
    val rectT = RegInit(0.U(log2Ceil(videoParams.pixelsV).W))
    val rectR = RegInit(rectSize.U(log2Ceil(videoParams.pixelsH).W))
    val rectB = RegInit(rectSize.U(log2Ceil(videoParams.pixelsV).W))
    val directionX = RegInit(false.B)
    val directionY = RegInit(false.B)
    when(frameUpdate) {
        // Update rectangle pos
        when(!directionX) {
            when( rectR < videoParams.pixelsH.U ) {
                rectL := rectL + 1.U
                rectR := rectR + 1.U
            } .otherwise {
                directionX := true.B
            }
        } .otherwise {
            when( rectL > 0.U ) {
                rectL := rectL - 1.U
                rectR := rectR - 1.U
            } .otherwise {
                directionX := false.B
            }
        }
        when(!directionY) {
            when( rectB < videoParams.pixelsV.U ) {
                rectT := rectT + 1.U
                rectB := rectB + 1.U
            } .otherwise {
                directionY := true.B
            }
        } .otherwise {
            when( rectT > 0.U ) {
                rectT := rectT - 1.U
                rectB := rectB - 1.U
            } .otherwise {
                directionY := false.B
            }
        }
    }

    def toPixelValue(value: UInt): UInt = {
        if( videoParams.pixelBits == 24 ) {         // 24bpp BGR888
            value
        } else if( videoParams.pixelBits == 16 ) {  // 1bpp BGR565
            Cat(value(23, 16+3), value(15, 8+2), value(7, 0+3))
        } else {                        // 8bpp BGR233
            Cat(value(23, 16+6), value(15, 8+5), value(7, 0+5))
        }
    }

    dataEnable := activeHLower <= counterH && counterH < activeHUpper &&
                  activeVLower <= counterV && counterV < activeVUpper
    
    val activeCounterH = Mux(dataEnable, counterH - activeHLower, 0.U)
    val activeCounterV = Mux(dataEnable, counterV - activeVLower, 0.U)

    when( rectL <= activeCounterH && activeCounterH < rectR && rectT <= activeCounterV && activeCounterV < rectB ) {
        data := 0.U
    } .elsewhen( activeCounterH < (videoParams.pixelsH * 1 / 7).U ) {
        data := toPixelValue("xffffff".U)
    } .elsewhen( activeCounterH < (videoParams.pixelsH * 2 / 7).U ) {
        data := toPixelValue("xff0000".U)
    } .elsewhen( activeCounterH < (videoParams.pixelsH * 3 / 7).U ) {
        data := toPixelValue("xffff00".U)
    } .elsewhen( activeCounterH < (videoParams.pixelsH * 4 / 7).U ) {
        data := toPixelValue("x00ff00".U)
    } .elsewhen( activeCounterH < (videoParams.pixelsH * 5 / 7).U ) {
        data := toPixelValue("x00ffff".U)
    } .elsewhen( activeCounterH < (videoParams.pixelsH * 6 / 7).U ) {
        data := toPixelValue("x0000ff".U)
    } .otherwise {
        data := toPixelValue("xff00ff".U)
    }
    
    hSync := !(counterH < videoParams.pulseWidthH.U)
    vSync := !(counterV < videoParams.pulseWidthV.U)
   
    io.video.hSync := hSync
    io.video.vSync := vSync
    io.video.dataEnable := dataEnableReg
    io.video.pixelData := Mux(dataEnable, data, 0.U)
}