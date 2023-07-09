# probedec - embedded probe decoder

## 概要

FPGA内部信号観測用の組込みロジック・プローブからの送信データを受信・解析し、バイナリもしくはCSVで保存するためのプログラム

## 使い方

```
$ cargo run -- --help
Usage: probedec [OPTIONS] --port <PORT> --signal <SIGNALS>...

Options:
      --port <PORT>          
      --signal <SIGNALS>...  
      --bin <BIN>            
      --csv <CSV>            
      --with-index           
      --count <COUNT>        
  -h, --help                 Print help
```

### --port

ロジック・プローブからの送信データを受信するシリアル・ポートのデバイス・ファイルへのパスを指定する。

例: `/dev/ttyACM0` を指定する場合

```
--port /dev/ttyACM0
```

### --signal

ロジック・プローブの信号名と信号のビット幅を指定する。`信号名:ビット幅` のように、信号名とビット幅を `:` で区切って指定する。 複数指定可能である。また、必ず1つは指定しないといけない。
最下位ビット(LSb) から指定した順に割り当てられていくので、下位ビットの信号から指定していく必要がある。

例: 32bitの信号 `debug_pc` および、1bitの信号 `trigger` を下記のChisel上の記述で `Probe` モジュールの `in` ポートに指定した場合。
つまり、 `debug_pc` が0~31ビット、 `trigger` が32ビットの場合。

```scala
probe.io := Cat(trigger, debug_pc)
```

```
--signal debug_pc:32 --signal trigger:1
```

### --bin

受信した信号データの内容をバイナリ形式で保存する場合の基準となるパスを指定する。
指定したパスに対して、元々の拡張子を取得したデータのインデックス + 元の拡張子に置換する。
`--bin` もしくは `--csv` のいずれかを指定する必要がある。

例： `hoge/output.0.bin` のように、`hoge` ディレクトリ以下にファイル名 `output` 拡張子 `.bin` で保存する場合

```
--bin hoge/output.bin
```

### --csv

受信した信号データの内容をCSV形式で保存する場合の基準となるパスを指定する。
指定したパスに対して、元々の拡張子を取得したデータのインデックス + 元の拡張子に置換する。
`--bin` もしくは `--csv` のいずれかを指定する必要がある。

例： `hoge/output.0.csv` のように、`hoge` ディレクトリ以下にファイル名 `output` 拡張子 `.csv` で保存する場合

```
--csv hoge/output.csv
```

### --with-index

CSV形式で保存する場合、各行の最初の列として `index` 列を挿入する。
`index` 列にはフレーム内の信号の番号が0から順に入る。

### --count

トリガ何回分のデータを記録するかを指定する。指定しない場合はプログラムを強制終了するまでデータの取得を継続する。


## 例

`/dev/ttyACM0` からデータを取得し、 `output.0.csv` としてCSV形式で取得データを保存する。
信号は 32bitの `debug_pc` および 1bitの `switchIn(0)` の構成。
CSV出力時にはインデックス列を付加。
トリガ2回分のデータを取得したらプログラムを終了する。

```
cargo run -- --port /dev/ttyACM0 --csv output.csv --signal debug_pc:32 --signal switchIn\(0\):1 --with-index --count 2
```