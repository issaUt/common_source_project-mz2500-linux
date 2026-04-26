# common_source_project-mz2500-linux

Common Source Code Project の Qt/Linux 系を土台にした、SHARP MZ-2500 向け Linux / WSL 実用化ブランチです。

## 概要

このリポジトリは、MZ-2500 を Linux / WSL 上で実用しやすくすることを目的とした派生版です。

ベースになっているのは次の 2 つです。

- 武田俊也さんによる Common Source Code Project
- Artanejp さん / K.Ohta さんによる Qt/Linux 移植版

その上で、主に次の改善を加えています。

- WSL で使いやすい起動スクリプト
- 実行時ディレクトリの整理
- ステート起動、メディア自動マウント補助
- MZ-2500 向けデバッガ拡張
- Linux / WSLg 上での描画・音声の実用改善

## 現在の主眼

このリポジトリでは、特に次のような MZ-2500 開発用途を重視しています。

- クロス開発環境からの起動
- ディスクイメージを使った確認
- ステートを使った高速な開発サイクル
- MZ-2500 のメモリ / デバッガ調査

## ビルド

現在確認できている MZ-2500 向けビルド手順は次の通りです。

```bash
git clone <this-repository-url>
cd common_source_project-mz2500-linux
cmake -S source -B build-mz2500
cmake --build build-mz2500 --target emumz2500 -j1
```

補足:

- CMake の configure 時には他機種の定義も広く走ります
- 実際のビルド対象は `--target emumz2500` を指定してください
- Linux / WSL 版では、現時点で MOVIE 関連は既定で無効化しています

## 実行時ディレクトリ

MZ-2500 用の実行時データは、既定で次のディレクトリを使用します。

```text
runtime/mz2500
```

このディレクトリには、主に次のようなファイルを置きます。

- `IPL.ROM`
- `KANJI.ROM`
- `DICT.ROM`
- `PHONE.ROM`（任意）
- `mz2500.sta0` から `mz2500.sta9`

ROM 探索順は次の通りです。

1. カレントディレクトリ
2. `--appdir` で指定したディレクトリ
3. 既定では `runtime/mz2500`

## 起動

起動には `run_mz2500.sh` を使います。

```bash
cd common_source_project-mz2500-linux
./run_mz2500.sh
```

FD を指定して起動する例:

```bash
./run_mz2500.sh --fd0 ../../diskimages/SWORD_2500V2.d88 --fd1 ./SOSPROG.D88
```

ステートから起動して FD1 を差し替える例:

```bash
./run_mz2500.sh --state-slot 0 --fd1 ./SOSPROG.D88
```

任意のステートファイルを指定する例:

```bash
./run_mz2500.sh --state ./runtime/mz2500/mz2500.sta0 --fd1 ./SOSPROG.D88
```

## 主な環境変数

`run_mz2500.sh` は次の環境変数を受け付けます。

- `MZ2500_APPDIR`
- `MZ2500_FD0`
- `MZ2500_FD1`
- `MZ2500_FD2`
- `MZ2500_FD3`
- `MZ2500_STATE`
- `MZ2500_STATE_SLOT`
- `MZ2500_WINDOW_POS`

例:

```bash
MZ2500_APPDIR=./runtime/mz2500 \
MZ2500_STATE_SLOT=0 \
MZ2500_FD1=./SOSPROG.D88 \
./run_mz2500.sh
```

## 既知の注意点

- Linux / WSL 版では MOVIE 関連機能を現在無効化しています
- WSLg + Qt Multimedia 環境では、音声まわりの警告が出ることがあります
- ウィンドウ位置指定は、WSLg 側の制約で安定しないことがあります
- Linux / WSLg では、MZ-2500 の ALGO キーは既定で `F11` に割り当てています（全角・半角キーは key release が不安定な環境があるため）

## デバッガ

MZ-2500 向けに追加・拡張したデバッガ機能については、`DebuggerForMZ2500.md` を参照してください。

- `Memory Bus(MZ2500)` を対象にしたメモリ確認
- 既存コマンド `R`, `RH` の MZ-2500 向け拡張
- 追加コマンド `MMAP`, `MSTAT`, `MRAM`, `MVRAM`
- 追加コマンド `LB`, `LH`, `LS`, `WB`, `WH`

## 謝辞

- 武田俊也さんによる Common Source Code Project
- Artanejp さん / K.Ohta さんによる Qt/Linux 移植版

このリポジトリは、上記プロジェクトへの敬意と謝意の上に成り立っています。

## 参照元

- オリジナル Common Source Code Project:
  <https://takeda-toshiya.my.coocan.jp/>
- Qt/Linux 移植版:
  <https://github.com/Artanejp/common_source_project-fm7>

## ライセンス

このリポジトリは、派生元である Common Source Code Project および Qt/Linux 移植版のライセンスに従います。

本リポジトリで追加した変更部分も、派生元と同じく GNU General Public License v2 互換の条件で扱います。

詳細は `LICENSE`、各ソースファイル、および派生元プロジェクトのライセンス表記を参照してください。

## ROM イメージについて

このリポジトリには、実機由来の ROM イメージは含めません。

利用時には、次の点に注意してください。

- 実機 ROM は各自で正当に入手・準備してください
- このリポジトリには ROM データは含まれません
- 起動に必要な ROM 名や配置先は本 README および関連文書を参照してください

