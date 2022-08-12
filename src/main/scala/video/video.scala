// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package video

import chisel3._
import chisel3.util._
import chisel3.experimental.BundleLiterals._

case class VideoParams
(
    pixelBits: Int,

    backPorchV: Int,
    pixelsV: Int,
    frontPorchV: Int,
    pulseWidthV: Int,

    backPorchH: Int,
    pixelsH: Int,
    frontPorchH: Int,

    pulseWidthH: Int,
) {
    val totalCountsH = backPorchH + pixelsH + frontPorchH + pulseWidthH
    val totalCountsV = backPorchV + pixelsV + frontPorchV + pulseWidthV
    val countHBits = log2Ceil(totalCountsH + 1)
    val countVBits = log2Ceil(totalCountsV + 1)
    val pixelBytes = (pixelBits + 7) / 8
    val framePixels = pixelsH * pixelsV
    val frameBytes = pixelBytes * framePixels
    val addressBits = log2Ceil(frameBytes*2)
    val bankOffset = frameBytes
}

class VideoConfig(val maxVideoParams: VideoParams) extends Bundle {
    val backPorchV = UInt(log2Ceil(maxVideoParams.backPorchV + 1).W)
    val pixelsV = UInt(log2Ceil(maxVideoParams.pixelsV + 1).W)
    val frontPorchV = UInt(log2Ceil(maxVideoParams.frontPorchV + 1).W)
    val pulseWidthV = UInt(log2Ceil(maxVideoParams.pulseWidthV + 1).W)
    val backPorchH = UInt(log2Ceil(maxVideoParams.backPorchH + 1).W)
    val pixelsH = UInt(log2Ceil(maxVideoParams.pixelsH + 1).W)
    val frontPorchH = UInt(log2Ceil(maxVideoParams.frontPorchH + 1).W)
    val pulseWidthH = UInt(log2Ceil(maxVideoParams.pulseWidthH + 1).W)

    def default(defaultVideoParams: VideoParams): VideoConfig = {
        WireInit(
            this.Lit(
                _.backPorchV -> defaultVideoParams.backPorchV.U,
                _.pixelsV -> defaultVideoParams.pixelsV.U,
                _.frontPorchV -> defaultVideoParams.frontPorchV.U,
                _.pulseWidthV -> defaultVideoParams.pulseWidthV.U,
                _.backPorchH -> defaultVideoParams.backPorchH.U,
                _.pixelsH -> defaultVideoParams.pixelsH.U,
                _.frontPorchH -> defaultVideoParams.frontPorchH.U,
                _.pulseWidthH -> defaultVideoParams.pulseWidthH.U,
            )
        )
    }
    def totalCountsH(): UInt = {
        this.pulseWidthH + this.backPorchH + this.pixelsH + this.frontPorchH
    }
    def totalCountsV(): UInt = {
        this.pulseWidthV + this.backPorchV + this.pixelsV + this.frontPorchV
    }
}
object VideoConfig {
    def apply(maxVideoParams: VideoParams): VideoConfig = {
        new VideoConfig(maxVideoParams)
    }
}

class VideoSignal(val pixelBits: Int) extends Bundle {
    val pixelData = Output(UInt(pixelBits.W))
    val startOfFrame = Output(Bool())
    val endOfLine = Output(Bool())
}

class VideoIO(val pixelBits: Int) extends Bundle {
    val pixelData = Output(UInt(pixelBits.W))
    val hSync = Output(Bool())
    val vSync = Output(Bool())
    val dataEnable = Output(Bool())

    def default(): VideoIO = {
        WireInit(
            this.Lit(
                _.dataEnable -> false.B,
                _.hSync -> true.B,
                _.vSync -> true.B,
                _.pixelData -> 0.U,
            )
        )
    }
}

class VideoMemoryIO(val pixelBits: Int, val addressWidth: Int) extends Bundle {
    val pixelData = Input(UInt(pixelBits.W))
    val address = Output(UInt(addressWidth.W))
}

class VideoSignalGenerator(defaultVideoParams: VideoParams, maxVideoParams: VideoParams) extends Module {
    val videoConfigType = new VideoConfig(maxVideoParams)
    val io = IO(new Bundle {
        val video = new VideoIO(maxVideoParams.pixelBits)
        val data = Flipped(Irrevocable(new VideoSignal(maxVideoParams.pixelBits)))
        val triggerFrame = Output(Bool())
        val dataInSync = Output(Bool())
        val config = Flipped(Valid(videoConfigType))
    })

    val nextVideoConfig = RegInit(videoConfigType.default(defaultVideoParams))
    val videoConfig = RegInit(videoConfigType.default(defaultVideoParams))

    val totalCountsHMinus1 = RegInit(0.U(maxVideoParams.countHBits.W))
    val totalCountsVMinus1 = RegInit(0.U(maxVideoParams.countHBits.W))
    val activeHLower = RegInit(0.U(maxVideoParams.countHBits.W))
    val activeHUpper = RegInit(0.U(maxVideoParams.countHBits.W))
    val activeVLower = RegInit(0.U(maxVideoParams.countVBits.W))
    val activeVUpper = RegInit(0.U(maxVideoParams.countVBits.W))

    val counterH = RegInit(0.U(maxVideoParams.countHBits.W))
    val counterV = RegInit(0.U(maxVideoParams.countVBits.W))
    val data = RegInit(0.U(maxVideoParams.pixelBits.W))
    val dataEnable = Wire(Bool())
    val dataEnableReg = RegInit(false.B)
    val hSync = RegInit(true.B)
    val vSync = RegInit(true.B)
    val dataInSync = RegInit(false.B)
    val dataReady = Wire(Bool())

    // Update video config
    when(io.config.valid) {
        nextVideoConfig := io.config.bits
    }

    when( counterH === 0.U && counterV === 0.U ) { // Update config.
        videoConfig := nextVideoConfig
        totalCountsHMinus1 := nextVideoConfig.totalCountsH() - 1.U
        totalCountsVMinus1 := nextVideoConfig.totalCountsV() - 1.U
        printf(p"[VideoSignalGenerator] Update Video Config nextVideoConfig: ${nextVideoConfig}")
        activeHLower := (nextVideoConfig.pulseWidthH + 0.U(maxVideoParams.countHBits.W)) + nextVideoConfig.backPorchH
        activeVLower := (nextVideoConfig.pulseWidthV + 0.U(maxVideoParams.countVBits.W)) + nextVideoConfig.backPorchV
        activeHUpper := (nextVideoConfig.pulseWidthH + 0.U(maxVideoParams.countHBits.W)) + nextVideoConfig.backPorchH + nextVideoConfig.pixelsH
        activeVUpper := (nextVideoConfig.pulseWidthV + 0.U(maxVideoParams.countVBits.W)) + nextVideoConfig.backPorchV + nextVideoConfig.pixelsV
    }

    when( !dataInSync ) {
        counterH := 0.U
        counterV := 0.U
        
        when( io.data.valid ) {
            when ( io.data.bits.startOfFrame ) {
                dataInSync := true.B
            }
        }
    } .otherwise {

        when(counterH < totalCountsHMinus1) {
            counterH := counterH + 1.U
        } .otherwise {
            counterH := 0.U
            when( counterV < totalCountsVMinus1 ) {
                counterV := counterV + 1.U
            } .otherwise {
                counterV := 0.U
            }
        }
        when( counterH === activeHLower && counterV === activeVLower && (!io.data.valid || !io.data.bits.startOfFrame) ) {
            // If current data does not have SOF flag at the top-left point, the data stream is not in sync.
            printf(p"[VideoSignalGenerator] Lost sync. counterH=${counterH}, activeHLower=${activeHLower}, counterV=${counterV}, activeVLower=${activeVLower}")
            dataInSync := false.B
        }
        data := Mux(io.data.valid, io.data.bits.pixelData, 0.U)
        dataEnableReg := dataEnable
    }

    dataReady := (!dataInSync && io.data.valid && !io.data.bits.startOfFrame) || (dataInSync && dataEnable)
    hSync := !(counterH < videoConfig.pulseWidthH)
    vSync := !(counterV < videoConfig.pulseWidthV)
    dataEnable := activeHLower <= counterH && counterH < activeHUpper &&
                  activeVLower <= counterV && counterV < activeVUpper
    
    io.triggerFrame := !dataInSync || (!hSync && !vSync)
    io.dataInSync := dataInSync
    io.data.ready := dataReady
    io.video.hSync := hSync
    io.video.vSync := vSync
    io.video.dataEnable := dataEnableReg
    io.video.pixelData := Mux(dataEnable, data, 0.U)
}