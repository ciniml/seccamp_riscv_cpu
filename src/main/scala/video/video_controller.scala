package video

import chisel3._
import chisel3.util._

import cpu.DmemPortIo

class VideoController(videoParams: VideoParams, vramPixelBits: Int, magnificationRateH: Int, magnificationRateV: Int, pixelTranslation: UInt => UInt) extends Module {
    val io = IO(new Bundle {
        val reg = new DmemPortIo()
        val mem = new DmemPortIo()
        val videoClock = Input(Clock()) // ビデオクロック。映像出力系の回路が動くクロック
        val videoReset = Input(Bool())  // ビデオクロックに同期したリセット
        val video = new VideoIO(videoParams.pixelBits)
    })

    val vramPixelsH = videoParams.pixelsH/magnificationRateH
    val vramPixelsV = videoParams.pixelsV/magnificationRateV
    val vramAddressMax = vramPixelsH * vramPixelsV

    val vram = Mem(vramAddressMax, UInt(vramPixelBits.W))
    val memWordAddr = io.mem.addr >> 2

    // VRAMへはワードアクセスのみ許可 (バイトオフセットは無視)
    val rdata = RegNext(vram(memWordAddr), 0.U)
    val rvalid = RegInit(false.B)
    io.mem.rvalid := rvalid
    io.mem.rdata := rdata
    rvalid := false.B
    when(io.mem.ren) {
        rvalid := true.B
    }
    when(io.mem.wen) {
        vram(memWordAddr) := io.mem.wdata
    }

    // レジスタ・インターフェース
    io.reg.rvalid := true.B
    // ビデオクロックで動いている信号のCDC用レジスタ (2段FF)
    val hSyncReg = RegInit(0.U(2.W))
    val vSyncReg = RegInit(0.U(2.W))
    val dataEnableReg = RegInit(0.U(2.W))
    // CDC用レジスタのビット幅分のFFで、CPUクロックに同期する
    hSyncReg := Cat(io.video.hSync, hSyncReg(hSyncReg.getWidth-1, 1))
    vSyncReg := Cat(io.video.vSync, vSyncReg(vSyncReg.getWidth-1, 1))
    dataEnableReg := Cat(io.video.dataEnable, dataEnableReg(dataEnableReg.getWidth-1, 1))
    io.reg.rdata := MuxCase("xdeadbeef".U, Seq(
        // VSYNC, HSYNC, DEをCPUから読み取れるようにしておく
        (io.reg.addr(2, 2) === 0.U) -> Cat(0.U(29.W), vSyncReg(0), hSyncReg(0), dataEnableReg(0)),
    ))

    // ビデオクロックで動く部分
    withClockAndReset(io.videoClock, io.videoReset) {
        // アクティブ区間のH/Vそれぞれのカウンタ値の下限と上限
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
        val endOfFrame = WireDefault(false.B)
        val endOfLine = WireDefault(false.B)

        val lineAddress = RegInit(0.U(log2Ceil(vramAddressMax).W))
        val pixelAddress = RegInit(0.U(log2Ceil(vramAddressMax).W))
        val magnificationCounterH = RegInit(0.U(log2Ceil(magnificationRateH).W))
        val magnificationCounterV = RegInit(0.U(log2Ceil(magnificationRateV).W))

        // 水平・垂直カウンタの更新
        when(counterH < videoParams.totalCountsH.U ) {
            counterH := counterH + 1.U
        } .otherwise {
            counterH := 0.U // ラインの端まで到達
            endOfLine := true.B
            when( counterV < videoParams.totalCountsV.U ) {
                counterV := counterV + 1.U
            } .otherwise {
                counterV := 0.U // フレームの右下に到達
                endOfFrame := true.B
            }
        }
        data := 0.U
        dataEnableReg := dataEnable

        // フレームバッファ読み出し
        when(dataEnable) {
            when(magnificationCounterH === (magnificationRateH - 1).U) {
                // 水平方向の拡大カウンタが最大値なら、ピクセルアドレスを進める
                pixelAddress := pixelAddress + 1.U
                magnificationCounterH := 0.U
            } .otherwise {
                magnificationCounterH := magnificationCounterH + 1.U
            }
            // VRAMのピクセルフォーマットから、24bpp BGRのピクセルフォーマットに変換する
            data := pixelTranslation(RegNext(vram(pixelAddress), 0.U))
        }
        when(activeVLower <= counterV && counterV < activeVUpper && endOfLine) {
            when(magnificationCounterV === (magnificationRateV - 1).U) {
                // 垂直方向の拡大カウンタが最大値なら、ライン開始アドレスを進める
                lineAddress := lineAddress + vramPixelsH.U
                pixelAddress := lineAddress + vramPixelsH.U
                magnificationCounterV := 0.U
            } .otherwise {
                magnificationCounterV := magnificationCounterV + 1.U
                pixelAddress := lineAddress
            }
        }
        when(endOfFrame) {
            /// フレーム終端なのでアドレスを0に戻す
            pixelAddress := 0.U
            lineAddress := 0.U
        }

        // 有効画素区間なら`dataEnable`をアサート
        dataEnable := activeHLower <= counterH && counterH < activeHUpper &&
                    activeVLower <= counterV && counterV < activeVUpper

        // HSYNC/VSYNCを生成
        hSync := counterH < videoParams.pulseWidthH.U
        vSync := counterV < videoParams.pulseWidthV.U
    
        io.video.hSync := hSync
        io.video.vSync := vSync
        io.video.dataEnable := dataEnableReg
        io.video.pixelData := Mux(dataEnable, data, 0.U)
    }
}