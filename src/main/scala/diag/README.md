# デバッグ用便利モジュール

## 埋め込みロジック・プローブ

GOWIN EDAに付属のGOWIN Analyzer Oscilloscope (GAO) がTang Nano 9K + Linuxの環境でまともに使えないので、代わりとなる埋め込みロジック・プローブモジュールを用意した。

GAOはJTAG経由でデータのやり取りをするが、ここで使用する埋め込みロジックプローブは、UARTでデータを垂れ流すだけである。

![構成](probe.drawio.svg)

### フレーム・フォーマット

8bitのUARTで信号を送るため、信号データを7bit単位で表現し、フレーム化のマーカーとして フレーム開始 (SOF) = 0x80, フレーム終了 (EOF) = 0x81 を用いる。

信号データはLSb firstで7bit単位で送信される。信号データのバイトは最上位ビット(7bit目)は常に0とする。7bitに満たない場合は上位ビットは0で埋められる。
例えば、測定したビット列が `9'b1_1111_1111` だった場合、 `8'b0111_1111 8'b0000_0011` が信号データとなる。

さらにSOF, EOFを付加して、フレームのバイト列は16進数で `80 7f 03 81` となる。

### 使い方

以下は、32bitの信号 `signal_32bit` と、1ビットの信号 `signal_1bit` 観測する例である。 トリガ条件は `signal_1bit === true.B` の場合となる。

```scala
  val signal_32bit = WireDefault(UInt(32.W)) // 観測対象の信号その1
  val signal_1bit = WireDefault(Bool())      // 観測対象の信号その2
  // 信号バッファ深さ512エントリ、トリガ位置 512 - 16 = 496、信号幅33bitのプローブを構築
  val probe = Module(new diag.Probe(new diag.ProbeConfig(bufferDepth = 512, triggerPosition = 512 - 16), 33))
  probe.io.in := Cat(signal_1bit, singal_32bit) // 観測対象の信号ビット列。33bit
  probe.io.trigger := signal_1bit               // トリガ入力
  // フレームアダプタを構築
  val probeFrameAdapter = Module(new diag.ProbeFrameAdapter(probe.width))
  probeFrameAdapter.io.in <> probe.io.out   // プローブの出力をフレームアダプタの入力に接続
  // UART送信モジュールを構築 (clockFreqHzにはクロック周波数が入っている)
  // 8bit, 115200bps
  val probeUartTx = Module(new UartTx(numberOfBits = 8, baudDivider = clockFreqHz / 115200))
  probeUartTx.io.in <> probeFrameAdapter.io.out // フレームアダプタの出力をUART TXの入力に接続
  // UART信号出力をモジュールの probeOut ポートから出力
  io.probeOut := probeUartTx.io.tx
```

### 受信プログラム

ホストPC用の受信プログラムは [`tool/probedec`](../../../../tool/probedec/) ディレクトリに格納されている。Rustで記述しているので、Rustのビルド環境が必要となる。
