# ピンヘッダレイアウト

![pinheader.png](pinheader.png)

## J8ピンヘッダ

* Raspberry Pi Zero
* Raspberry Pi 3
* Raspberry Pi 2 A+, B+
* Raspberry Pi A+, B+

## Raspbeery Pi A, B

新しいモデルのRaspberry Piと比べて、初期モデルは以下の違いがある。

Revision 2.0
* 26ピンまで

Revision 1.0
* 26ピンまで
* GPIO02 が GPIO00
* GPIO03 が GPIO01
* GPIO27 が GPIO21

# RUN

RUNと書かれたピンをGNDに落とすと、リセットされる。停止中は起動する。

# シリアルコンソール

* USB-UART変換モジュールの RXDに Raspberry Piの TXD を USB-UART変換モジュールの TXDに Raspberry Piの RXD を接続
* モジュールは 3.3Vである必要がある。
* GNDの接続を忘れずに

# 参考文献

* [Raspberry Pi hardware](https://www.raspberrypi.org/documentation/hardware/raspberrypi/)