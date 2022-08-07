package uart

import chisel3._
import chisel3.util._

class UartTx(clockFrequency: Int, baudRate: Int) extends Module {
    val io = IO(new Bundle{
        val tx = Output(Bool())
    })

    val baudDivider = clockFrequency/baudRate               // クロック周波数/ボー・レート
    val rateCounter = RegInit(0.U(log2Ceil(baudDivider).W)) // ボー・レート周期生成用カウンタ
    val bitCounter = RegInit(0.U(log2Ceil(8 + 2).W))        // 残り送信ビット数カウンタ
    val bits = Reg(Vec(8 + 2, Bool()))                      // 送信ビット・バッファ

    io.tx := bitCounter === 0.U || bits(0)
    val ready = bitCounter === 0.U  // ビット・カウンタ == 0なので、次の送信を開始できるか？
    
    when(ready) {
        bits := Cat(1.U, 0x41.U(8.W), 0.U).asBools  // STOP(1), 'A', START(0)
        bitCounter := (8 + 2).U                     // 残送信ビット数 = 10bit (STOP + DATA + START)
        rateCounter := (baudDivider - 1).U          // レートカウンタを初期化
    }

    when( bitCounter > 0.U ) {
        when(rateCounter === 0.U) { // 次のボーレート周期の送信タイミング
            (0 to 8).foreach(i => bits(i) := bits(i + 1))   // ビットバッファを右シフトする
            bitCounter := bitCounter - 1.U
            rateCounter := (baudDivider - 1).U
        } .otherwise {
            rateCounter := rateCounter - 1.U
        }
    }
}