---
marp: true
theme: default
size: 16:9
paginate: true
headingDivider: 2
header: セキュリティキャンプ2022 Y4 RISC-V CPU自作ゼミ
footer: (C) 2022 Kenta Ida
---

# セキュリティキャンプ2022 Y4 <br/> RISC-V CPU自作ゼミ

<!--
_class: lead
_paginate: false
_header: ""
-->

## 目次

* 講義で直接取り扱う領域

* 論理回路
  * 組み合わせ論理回路
  * 順序回路
* FPGAで実現可能な論理回路
* 論理合成
* 配置配線
* 書籍のCPUを合成してみる
* 問題
* メモリの構造
* メモリのアクセス方法
* 対策
  * 命令メモリ
  * データメモリ
* CPUと外の世界の接続
  * 専用命令
  * アクセラレータ・インターフェース
  * MMIO
  * 共有メモリ
* CPUからLチカ
  * LEDを光らせるには
  * Tang Nano 9Kの回路
  * 余談:電流制限抵抗とVf-If特性
  * GPIO
  * 専用命令
  * アクセラレータ・インターフェース
  * MMIO
* PCとの通信
  * シリアル通信プロトコル
  * UART
  * UARTの送受信回路


## 講義で取り扱う領域

* RISC-V CPUコアの設計方法については書籍に記載
  * 基本的なRISC-Vコアの実装
  * Chiselの環境構築
  * 簡単なシミュレーションの実行方法
* 書籍では以下の内容は取り扱っていない
  * CPU外部との入出力
  * FPGAへの実装
* 書籍で取り扱っていない部分を補足しつつ、FPGA実装を行い、外部との入出力を行うことが目標

## 書籍で実装するRISC-Vコア

* 第III部までの内容 (パイプライン化)
* RISC-V RV32I のサブセット
  * 一部命令が実装されていない
  * e.g. LB, LH, SB, SHなどのワード単位以外のロード・ストア命令
* 5段パイプライン

## FPGAで合成チャレンジ！

* 意外とそのまま行けたりするんじゃないの？という話もあるので、まずは合成できるベースまで持っていく

## FPGAとは

* Field Programmable Gate Arrayの略
* ここでは、製造後に論理回路の構成を変更可能なICくらいの認識で良い
* 詳しいことが知りたい場合は [FPGAの原理と構成](https://shop.ohmsha.co.jp/shopdetail/000000004588/) を参照のこと

## FPGAの論理回路を構成する流れ

* 論理合成
* 配置配線
* ビットストリーム書き込み

## ChiselからVerilog HDLの生成

* FPGAの論理合成系へ入力できるようにするためChiselからVerilog HDLへの変換が必要
* Chiselではこの処理のことを **エラボレーション (Elaboration)** と呼ぶ

## Chiselのエラボレーション(1/3)

* `runMain` で実行できるように `App` の派生クラスを定義する
* `ChiselStage` の `emitVerilog` に、Verilogに変換したいChiselのモジュールを渡して呼び出す
* 第2引数に変換時のパラメータを含む `Array` を指定する

```scala
package fpga

import chisel3._
import chisel3.stage.ChiselStage
import cpu.Top

object Elaborate_ComProcCpuBoard extends App {
  (new ChiselStage).emitVerilog(new Top, Array(
    "-o", "riscv.v",
    "--target-dir", "rtl/comproc_cpu_board",
  ))
}
```

## Chiselのエラボレーション(2/3)

* sbtから定義したAppを呼び出す

```shell
$ sbt
sbt:riscv_chisel_book> runMain fpga.Elaborate_ComProcCpuBoard
[info] compiling 6 Scala sources to /home/kenta/repos/seccamp_2022_y4_riscv/fpga_impl/target/scala-2.12/classes ...
[info] running fpga.Elaborate_ComProcCpuBoard 
Elaborating design...
Done elaborating.
```

## Chiselのエラボレーション(3/3)

* `--target-dir` パラメータで指定したディレクトリ (`rtl/comproc_cpu_board`) に変換後のVerilogのモジュールが出力される
* 出力ファイル名は `-o` パラメータで指定したファイル名 (`riscv.v`)

```
rtl
└── comproc_cpu_board
    ├── firrtl_black_box_resource_files.f
    ├── riscv.v
    ├── Top.anno.json
    ├── Top.fir
    └── Top.Memory.mem.v
```

## Chiselから変換したHDLの論理合成

* とりあえずGOWINの合成系で合成してみる
* 合成時にエラー

```
eda/cpu_riscv_chisel_book$ make
(省略)
Running inference ...
ERROR (RP0001) : The number(131072) of DFF in the design exceeds the resource limit(6480) of current device(GW1NR-LV9QN88PC6/I5)
ERROR (IF0003) : Cannot infer "mem" due to multiple write clocks("/home/kenta/repos/seccamp_2022_y4_riscv/fpga_impl/rtl/comproc_cpu_board/riscv.v":1029)
GowinSynthesis finish
```

* DFFの個数が **131072** 個になっていてFPGAに載らない
  * 対象デバイスには **6480** 個しかDFFがない
* コアで使っているDFFは多く見積もっても 32bit幅のものが100個分程度 = DFF 3200個くらい
  * レジスタファイル (32bit * 40) やパイプラインレジスタ
* ではどこでDFFを使っているのか？

## FPGA向けHDLでのメモリの表現

* FPGA向けの合成系では、メモリ (SRAM) を表現する方法が大きく分けて2つある

1. FPGAのメモリ・プリミティブを直接インスタンス化する
2. 合成系のRAM推論規則に従ったHDLを記述する

* ChiselでFPGA向けのデザインを記述する場合は、一般的には **2** の方法を用いる
  * 規則は合成系によって微妙に異なるが大枠は一緒

## そもそもRAMとは

* 指定したアドレスに対してワード単位での読み書きが可能な記憶素子
* 記憶素子の構造などによりいくつかの種類がある
  * e.g. Static RAM (SRAM), Dynamic RAM (DRAM)

## RAMに専用素子が必要な理由

* 一番単純な構造
* アドレスから入出力を選択するマルチプレクサが巨大な回路になる
  * 回路規模の増大
  * 遅延の増加による動作周波数低下
* アドレスから行・列をそれぞれ選択するように分割
* 回路をFPGAの論理素子で構成すると多量の素子を消費する
* SRAMを1つの大きいブロック(ハードマクロ)として実装して利用する

## SRAMの使い方 (読み出し)

1. `CE (Chip Enable)` 信号をアサートする
2. ホストがアドレス線にアドレスを出力する
3. データ出力線にアドレスに対応するセルのデータが出力される
4. `CE` 信号をデアサートする

## SRAMの使い方 (書き込み)

1. `CE (Chip Enable)` 信号をアサートする
2. ホストがアドレス線にアドレスを出力する
3. ホストがデータ入力線にデータを出力する
4. `WE (Write Enable)` 信号をアサートする
5. `WE` 信号をデアサートする
6. `CE` 信号をデアサートする

## GOWIN合成系におけるRAM推論規則 (1/2)

* 前述のSRAMの使い方に対応する処理を記述すると、対応するレジスタをSRAMのワードアクセスに推論する
* GOWINの合成系 (GowinSynthesis) のユーザーガイド (SUG550) に記載

## GOWIN合成系におけるRAM推論規則 (2/2)

* 8bit x 1024 (1[kiB]) のRAM記述の例

<style scoped>
pre {
  font-size: 20px;
}
</style>

```verilog
logic [9:0] address;      // アドレス
logic [7:0] mem[0:1023];  // メモリ本体
logic ce;                 // Chip Enable
logic we;                 // Write Enable
logic [7:0] data_in;      // データ入力
logic [7:0] data_out;     // データ出力
always_ff @(posedge clock) begin
  if(reset) begin
    data_out <= 0;
  end
  else begin
    if( ce ) begin
      data_out <= mem[addr];
      if( we ) begin
        mem[addr] <= data_in;
      end
    end
  end
end
```

## 推論規則による推論に失敗した場合

* 前述のHDLの記述の通り、そのままメモリのセルがすべてDFFに展開される
  * 1[kiB]のメモリなら、 8192個のDFFとアドレス選択回路になる
* さきほどのエラボレーション結果で意図せぬ個数のDFFがでたのはこのため
  * 16[kiB] = 131072個のDFF
    * `The number(131072) of DFF in the design exceeds the resource limit(6480) of current device(GW1NR-LV9QN88PC6/I5)`
  * エラーメッセージの内容と一致

```scala
// Memory.scala 26行目
val mem = Mem(16384, UInt(8.W))
```

→ なぜ推論されなかったのか？

## Chiselの `Mem` 型

* "A combinational/asynchronous-read, sequential/synchronous-write memory."
  * https://www.chisel-lang.org/api/latest/chisel3/Mem.html
* 非同期読み出し・同期書き込みメモリ
  * c.f. FPGAのSRAMは同期読み出し・同期書き込み
* 等価回路は下記の通り
  * `data_out` がレジスタになっておらず、推論規則と異なる回路

<style scoped>
pre {
  font-size: 14px;
}
</style>

```verilog
logic [9:0] address;      // アドレス
logic [7:0] mem[0:1023];  // メモリ本体
logic ce;                 // Chip Enable
logic we;                 // Write Enable
logic [7:0] data_in;      // データ入力
logic [7:0] data_out;     // データ出力
assign data_out = mem[address]; // 同一サイクル出力
always_ff @(posedge clock) begin
  if(!reset) begin
    if( ce & we ) begin
      mem[addr] <= data_in;
    end
  end
end
```


## Chiselの `SyncReadMem` 型

* "A sequential/synchronous-read, sequential/synchronous-write memory."
  * https://www.chisel-lang.org/api/latest/chisel3/SyncReadMem.html
* 同期読み出し・同期書き込みメモリ
* こっちを使えばいけそう？

# `SyncReadMem` に変更してみる

* 変更

```scala
val mem = SyncReadMem(16384, UInt(8.W))
```

* 結果

```
ERROR (RP0001) : The number(131072) of DFF in the design exceeds the resource limit(6480) of current device(GW1NR-LV9QN88PC6/I5)
ERROR (IF0003) : Cannot infer "mem" due to multiple write clocks("/home/kenta/repos/seccamp_2022_y4_riscv/fpga_impl/rtl/comproc_cpu_board/riscv.v":1039)
```

* エラーメッセージに変化なし
* そもそも2行目に `Cannot infer "mem" due to multiple write clocks` とある
* どういうことか？

## Schematic Viewerで確認

![bg right fit](figure/ram_inference_viewer.drawio.svg)

* Gowin EDAのプロジェクトを作成して、エラボレーション結果のVerilog HDLを追加
* `Tool -> Schematic Viewer` から **Schematic Viewer** で回路を表示
* RAMに対して書き込み4ポート、読み出し8ポート存在する

## FPGAの内蔵SRAMのポート数

* FPGA内蔵のSRAMは、大体のデバイスで最大2つまでのポートを使用可能
  * 所謂Dual Port Memory
* FPGAに実装するには一つのSRAMあたりポート数を2つまでに減らす必要がある

## ポート数が増えている原因

* 32bit読み書きのために8bit幅で4回ずつ読み書きしている
  * 命令読み出し、データ読み書き

<style scoped>
pre {
  font-size: 18px;
}
</style>

```scala
val mem = SyncReadMem(16384, UInt(8.W))
loadMemoryFromFile(mem, "src/hex/hazard_ex.hex")
io.imem.inst := Cat(
  mem(io.imem.addr + 3.U(WORD_LEN.W)), // Read 0
  mem(io.imem.addr + 2.U(WORD_LEN.W)), // Read 1
  mem(io.imem.addr + 1.U(WORD_LEN.W)), // Read 2
  mem(io.imem.addr)                    // Read 3 
)
io.dmem.rdata := Cat(
  mem(io.dmem.addr + 3.U(WORD_LEN.W)), // Read 4
  mem(io.dmem.addr + 2.U(WORD_LEN.W)), // Read 5
  mem(io.dmem.addr + 1.U(WORD_LEN.W)), // Read 6
  mem(io.dmem.addr)                    // Read 7
)

when(io.dmem.wen){
  mem(io.dmem.addr)                   := io.dmem.wdata( 7,  0) // Write 0
  mem(io.dmem.addr + 1.U(WORD_LEN.W)) := io.dmem.wdata(15,  8) // Write 1
  mem(io.dmem.addr + 2.U(WORD_LEN.W)) := io.dmem.wdata(23, 16) // Write 2
  mem(io.dmem.addr + 3.U(WORD_LEN.W)) := io.dmem.wdata(31, 24) // Write 3
}
```

## ポート数を増やす(1/3)

![bg right fit](figure/ram_inference_multi_bank.drawio.svg)


* ポート数が足りないのであれば、SRAMの割り当て方を変えればよい
  * e.g. 複数SRAMを並べる
* 今回の場合は1度に32bitアクセスしたいので、8bitごとに4つにわけて並べる

## ポート数を増やす(2/3)

* Chiselでは、 `Vec` 型を使った配列型をメモリの要素型とすれば対応可能

```scala
// 要素型を8bit幅x4つの配列にし、メモリの長さを1/4に変更
val mem = SyncReadMem(16384/4, Vec(4, UInt(8.W))) 
loadMemoryFromFile(mem, "src/hex/hazard_ex.hex")
io.imem.inst := Cat(
  mem.read(io.imem.addr >> 2).reverse,  // アドレスをワード単位に変換。長さ4のVecが返ってくるのでreverseで逆順にしてCatで結合
)
io.dmem.rdata := Cat(
  mem.read(io.dmem.addr >> 2).reverse,
)
when(io.dmem.wen){
  // wdataを8bit単位に切り分けて逆順に並べなおしたものを書き込む
  mem.write(io.dmem.addr >> 2, VecInit((0 to 3).map(i => io.dmem.wdata(8*(i+1)-1, 8*i)).reverse))
}
```

## ポート数を増やす(3/3)

![bg right:40% fit](figure/ram_inference_multi_bank_viewer.drawio.svg)

* Schematic Viewerで効果を確認
  * RAMが4つになり、それぞれ読み書き2ポートまでに抑えられている
* 合成して効果を確認
  * 論理合成・配置配線が成功する

## シミュレーション確認(1/4)

* `riscv-tests` のテストを実行
* 全テスト失敗する
* 原因は、 `loadMemoryFromFile` が `Vec[UInt]` 型を要素とする `Mem` に対応していないこと
  * `loadMemoryFromFile` だとエラーにならず分かりずらいが `loadMemoryFromFileInline` だと以下のエラーが出る

```
[info]   Cause: java.lang.RuntimeException: [module Memory] Cannot initialize memory mem of non ground type UInt<8>[4]
```

## シミュレーション確認(2/4)

* 対策として、 `SyncReadMem` の型を `Vec[UInt]` にするのではなく、 `SyncReadMem` を複数用意する
* `loadMemoryFromFile` の入力データもバイト単位で分割しておく
  * 分割後のファイル名を取得するためのlambdaを渡しておく

<style scoped>
pre {
  font-size: 14px;
}
</style>

```scala
val mems = (0 to 3).map(_ => Mem(16384/4, UInt(8.W)))
if( memoryPath.isDefined ) {
  val memoryPath_ = memoryPath.get
  for(i <- 0 to 3) {
    loadMemoryFromFileInline(mems(i), memoryPath_(i))
  }
}
val imemWordAddr = (io.imem.addr - baseAddress) >> 2
val dmemWordAddr = (io.dmem.addr - baseAddress) >> 2
io.imem.inst := Cat(
  (0 to 3).map(i => mems(i).read(imemWordAddr)).reverse
)
io.dmem.rdata := Cat(
  (0 to 3).map(i => mems(i).read(dmemWordAddr)).reverse
)
when(io.dmem.wen){
  for(i <- 0 to 3) {
    mems(i).write((io.dmem.addr - baseAddress) >> 2, io.dmem.wdata(8*(i+1)-1, 8*i))
  }
}
```

## シミュレーション確認(3/4)

* `Mem` を使った場合
  * 未実装の命令 `LB` `LBU` `LH` `LHU` のテスト以外は成功

```
[info] RiscvTest:
[info] RiscV
[info] - must runs rv32ui-p-add
(省略)
[info] - must runs rv32ui-p-lb *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
[info] - must runs rv32ui-p-lbu *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
[info] - must runs rv32ui-p-lh *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
[info] - must runs rv32ui-p-lhu *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
(省略)
[info] Run completed in 38 seconds, 449 milliseconds.
[info] Total number of tests run: 38
[info] Suites: completed 1, aborted 0
[info] Tests: succeeded 32, failed 6, canceled 0, ignored 0, pending 0
[info] *** 6 TESTS FAILED ***
```

## シミュレーション確認(4/4)

* `SyncReadMem` を使った場合
  * ほとんどのテストが失敗
  * なにがおきているのか？

```
[info] RiscvTest:
[info] RiscV
[info] - must runs rv32ui-p-add *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
[info] - must runs rv32ui-p-addi *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
[info] - must runs rv32ui-p-and *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
[info] - must runs rv32ui-p-andi *** FAILED ***
[info]   io_success=false (0, 0x0) did not equal expected=true (1, 0x1) (lines in riscv-test.scala: 61) (riscv-test.scala:66)
(省略)
[info] Run completed in 29 seconds, 136 milliseconds.
[info] Total number of tests run: 38
[info] Suites: completed 1, aborted 0
[info] Tests: succeeded 5, failed 33, canceled 0, ignored 0, pending 0
[info] *** 33 TESTS FAILED ***
```

## シミュレーション波形の確認(1/3)

* 書籍では `printf` を使ったデバッグ方法のみ紹介
* 一般的なFPGA開発では各信号の時系列変化も確認する
* シミュレーション時に各信号の時系列変化を出力して確認する
* ChiselTestではシミュレーション時に `-DwriteVcd=1` を指定すると時系列変化が出力される

```sbt
sbt:riscv_chisel_book> testOnly cpu.RiscvTest -- -DwriteVcd=1
```

## シミュレーション波形の確認(2/3)

* 出力された波形ファイル (*.vcd) を **gtkwave** で確認する

![fit](figure/chiseltest_gtkwave.drawio.svg)

## シミュレーション波形の確認(3/3)

* `SyncReadMem` だとデータ出力が1サイクル遅延
  * 分岐時に1つ古い命令を実行してしまう → **対策が必要**

![fit](figure/chiseltest_mem.drawio.svg)

## 対策の方法 - パイプラインのストール(1/5)

* CPUのパイプライン化のときに行ったのと同様に、<br/>読み出したいアドレスのデータが準備できていないときにストールさせる
* **データが準備できていないとき** の条件
  * リセット直後 → 1サイクル遅延するのでまだデータを読めていない
  * 分岐直後 → 分岐先アドレスのデータを読めていない

## 対策の方法 - パイプラインのストール(2/5)

* メモリ・インターフェース ( `IMemPortIo` ) の変更
* データが準備できているかどうかを表す **Valid信号** `valid` を追加する

```scala
class ImemPortIo extends Bundle {
  val addr = Input(UInt(WORD_LEN.W))
  val inst = Output(UInt(WORD_LEN.W))
  val valid = Output(Bool())            // 追加
}
```

## 対策の方法 - パイプラインのストール(3/5)

* メモリ側の変更

```scala
val imemWordAddrBits = io.imem.addr.getWidth - 2
val imemWordAddr = (io.imem.addr - baseAddress) >> 2
val imemWordAddrFetched = Reg(UInt(imemWordAddrBits.W)) // フェッチ済みのアドレス
val isFirstCycle = RegInit(true.B)  // リセット直後かどうか？
isFirstCycle := false.B
// リセット直後でなく、対象アドレスがフェッチ済みならデータ有効
io.imem.valid := !isFirstCycle && imemWordAddrFetched === imemWordAddr
imemWordAddrFetched := imemWordAddr
io.imem.inst := Cat(
  (0 to 3).map(i => mems(i).read(imemWordAddr)).reverse
)
```

## 対策の方法 - パイプラインのストール(4/5)

* コア側の変更
  * 命令が向こうなら `BUBBLE` に置き換えておく
  * ストールの条件に `!io.imem.valid` を追加

```scala
val if_inst = Mux(io.imem.valid, io.imem.inst, BUBBLE)  // 命令が無効ならBUBBLEにする
// ...
val if_pc_next = MuxCase(if_pc_plus4, Seq(
  // 優先順位重要！ジャンプ成立とストールが同時発生した場合、ジャンプ処理を優先
  exe_br_flg         -> exe_br_target,
  exe_jmp_flg         -> exe_alu_out,
  (if_inst === ECALL) -> csr_regfile(0x305),  // go to trap_vector
  (stall_flg || !io.imem.valid) -> if_reg_pc, // stall
))
if_reg_pc := if_pc_next
```

## 対策の方法 - パイプラインのストール(5/5)

* シミュレーション結果
  * メモリアクセス系のテスト以外はパスする
  * 但し、CPUの動作速度が半分に低下

![fit](figure/imem_fetch_stall.drawio.svg)


## 演習1 - 命令実行速度の低下抑制

* 命令メモリの読み出し対策を入れて動作速度(IPC)が半分に低下
  * さすがに性能的に許容できない
* 分岐時以外に動作速度が低下しない(ほぼ1サイクルに1回、命令フェッチを行える)ようにCPUのロジックを変更
  * 非同期メモリに戻す方法以外のみ許可
* メモリアクセス系以外のテストが通ることを確認すること
  * LB, LBU, LH, LW, SB, SBU, SH, SW のテストは除外

## データバスアクセス時のストール実装 (1/5)

* 命令メモリと同様にデータバスアクセスのストールも実装する
* データバスのアクセスは読み出しデータ有効信号 `rvalid` だけでなく、読み出しを実行するかどうかの信号 `ren` を追加する
  * データバスからのメモリアクセスは毎サイクル行うわけではない

```scala
class DmemPortIo extends Bundle {
  val addr  = Input(UInt(WORD_LEN.W))
  val rdata = Output(UInt(WORD_LEN.W))
  val ren = Input(Bool())               // 追加
  val rvalid = Output(Bool())           // 追加
  val wen   = Input(Bool())
  val wdata = Input(UInt(WORD_LEN.W))
}
```

## データバスアクセス時のストール実装 (2/5)

* メモリ側の変更
  * `rdata` の内容は 1サイクル後に `addr` の番地の内容になる
  * `ren` がアサートされた次のサイクルで `rvalid` をアサート
```scala
val dmemWordAddr = (io.dmem.addr - baseAddress) >> 2
val rvalid = RegInit(false.B)
val rdata = Cat(
  (0 to 3).map(i => mems(i).read(dmemWordAddr)).reverse
) // `rdata` の内容は次のサイクルでdmemWordAddr番地の内容になる
io.dmem.rvalid := rvalid
io.dmem.rdata := rdata
rvalid := false.B
val dmemAddrReg = Reg(UInt(io.dmem.addr.getWidth.W))  // デバッグ用
when( io.dmem.ren && !io.dmem.wen && !rvalid ) {
  rvalid := true.B  // 次のサイクルでrvalidをアサート
  dmemAddrReg := io.dmem.addr
}
when( rvalid ) {
  printf(p"Data read address=0x${Hexadecimal(dmemAddrReg)} data=0x${Hexadecimal(rdata)}\n")
}
```

## データバスアクセス時のストール実装 (3/5)

* コア側の変更 (IF, ID ステージ)

```scala
val mem_stall_flg = Wire(Bool())  // データバス要因のストール
// (省略)
stall_flg := (id_rs1_data_hazard || id_rs2_data_hazard || mem_stall_flg)  // データバス要因のストールも全体のストール要因に追加
// (省略)
// MEMステージがストールしていない場合のみEXEのパイプラインレジスタを更新する。
when( !mem_stall_flg ) {
  exe_reg_pc            := id_reg_pc
  // (省略)
  exe_reg_mem_wen       := id_mem_wen
}
```

## データバスアクセス時のストール実装 (4/5)

* コア側の変更 (EXステージ)

```scala
// MEMステージがストールしていない場合のみMEMのパイプラインレジスタを更新する。
when( !mem_stall_flg ) {
  mem_reg_pc         := exe_reg_pc
  // (省略)
  mem_reg_mem_wen    := exe_reg_mem_wen
}
```

## データバスアクセス時のストール実装 (5/5)

* コア側の変更 (MEMステージ)
```scala
//**********************************
// Memory Access Stage
io.dmem.addr  := mem_reg_alu_out
io.dmem.ren   := mem_reg_wb_sel === WB_MEM  // ロード命令ならrenをアサート
io.dmem.wen   := mem_reg_mem_wen
io.dmem.wdata := mem_reg_rs2_data
// WBでデータバスの内容が必要だが、データバスのデータが有効でないならストール
mem_stall_flg := io.dmem.ren && !io.dmem.rvalid
```
* コア側の変更 (WBステージ)
```scala
//**********************************
// MEM/WB regsiter
wb_reg_wb_addr := mem_reg_wb_addr
wb_reg_rf_wen  := Mux(!mem_stall_flg, mem_reg_rf_wen, REN_X)  // ストールしてなければライトバックする
wb_reg_wb_data := mem_wb_data 
```
