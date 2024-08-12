# CPU LED制御デザイン
## 概要

Tang Nano 9Kに搭載されているLEDをCPUから制御するデザイン

## 合成

### Tang Nano 9K Pmod ベースボード向け

```
make
```

### ComProc CPU Board向け

```
export TARGET=comprocboard_9k
make
```

## 書き込み

### SRAM

```
make run 
```

### Flash

```
make deploy
```