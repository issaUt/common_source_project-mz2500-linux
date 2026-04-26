# MZ-2500 向けデバッガ拡張

この WSL 向け作業ブランチでは、MZ-2500 のメモリ構造を調査しやすくするために、
デバッガへいくつかの専用機能を追加しています。

## 前提

まずデバッガで `Memory Bus(MZ2500)` を target に切り替えてください。

    !device
    !device <Memory Bus(MZ2500) の ID>

この target を選ぶと、Z80 から直接見えていない物理 RAM / VRAM / ROM 領域も
デバッグ用アドレス空間として参照できます。

## 追加コマンド

### R

`Memory Bus(MZ2500)` を target にした場合、現在の MZ-2500 メモリ状態を表示します。

表示内容は主に

* `bank`
* `mode`
* `vram_sel`
* `vram_page`
* `dic_bank`
* `kanji_bank`
* 8KB x 8 ページの現在割り当て
* 各ページの種別 / wait / 実体

です。

### RH

`Memory Bus(MZ2500)` を target にした場合、統合デバッグ空間の説明を表示します。

どのアドレス帯が Main RAM / VRAM / TVRAM / PCG / ROM に対応するかを確認する用途です。

### MMAP

現在の MZ-2500 メモリマップを表示します。

* 8KB x 8 ページの現在割り当て
* 各ページの種別
* wait 値
* 実際にどの物理領域へ向いているか

を確認する用途です。

### MSTAT

MZ-2500 のメモリ制御状態を表示します。

現状では `MMAP` と同じ内容を表示しますが、用途としては

* `bank`
* `mode`
* `vram_sel`
* `vram_page`
* `dic_bank`
* `kanji_bank`

などの制御状態確認用です。

### MRAM <start> [end]

MZ-2500 の Main RAM 256KB を物理 RAM として直接ダンプします。

Z80 から現在見えているかどうかに関係なく、生の RAM 内容を確認できます。

例:

    MRAM 0000 007f

### MVRAM <start> [end]

MZ-2500 の VRAM 128KB を物理 VRAM として直接ダンプします。

表示崩れや描画状態の確認用です。

例:

    MVRAM 0000 007f

### LB [<range>]

バイナリ専用ロードです。

指定アドレスへ `.bin` を読み込みます。
`HEX` / `SYM` を誤って混ぜないよう、用途を分離した安全用コマンドです。

例:

    N sample.bin
    LB 40000

### LH [<offset>]

Intel HEX 専用ロードです。

HEX 内のアドレス情報に従ってロードします。
MZ-2500 用に追加した拡張デバッグアドレス空間にも対応します。

例:

    N sample.hex
    LH

### LS

シンボル専用ロードです。

`.sym` ファイルだけを対象にします。

### WB <start> <end>

バイナリ専用書き出しです。

指定範囲を `.bin` として保存します。
アドレス情報は不要で、生データだけ欲しいときに使います。

例:

    N vram.bin
    WB 40000 5ffff

### WH <start> <end>

Intel HEX 専用書き出しです。

指定範囲をアドレス付き HEX として保存します。
`0xffff` を超える領域でも、拡張リニアアドレス付きで出力します。

例:

    N vram.hex
    WH 40000 5ffff

### L

従来互換の自動判定ロードです。

拡張子を見て `bin` / `hex` / `sym` を判別します。
新規運用では `LB` / `LH` / `LS` を推奨します。

### W

従来互換の自動判定書き出しです。

拡張子を見て `bin` / `hex` を判別します。
新規運用では `WB` / `WH` を推奨します。

## Memory Bus(MZ2500) 用の統合デバッグ空間

`Memory Bus(MZ2500)` を target にした場合、`D` / `R` / `RH` などの既存コマンドは
次の統合アドレス空間を対象にします。

* `00000-3FFFF` : Main RAM 256KB
* `40000-5FFFF` : VRAM 128KB
* `60000-61FFF` : Text VRAM
* `62000-63FFF` : PCG
* `64000-6BFFF` : IPL ROM
* `6C000-ABFFF` : Dictionary ROM
* `AC000-EBFFF` : Kanji ROM
* `EC000-F3FFF` : Phone ROM

例:

    D 40000 4007f

で VRAM 先頭を直接確認できます。

## デバッガ表示フォント

デバッガウィンドウの既定フォントは `Noto Mono` を優先するように変更しています。
環境に `Noto Mono` が無い場合は、固定幅のシステムフォントへフォールバックします。

また、見やすさのために

* fixed pitch 強制
* kerning 無効
* 行折り返し無効

としています。
