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

* USB-UART変換モジュールを使用する。FT-232RL, CP2102など。[秋月電子](http://akizukidenshi.com/catalog/c/cusb232/)で購入できる。
* モジュールは 3.3Vである必要がある。5Vトレラント機能はないので5Vで接続しないこと。
* USB-UART変換モジュールの RXDに Raspberry Piの TXD を USB-UART変換モジュールの TXDに Raspberry Piの RXD を接続。
* GNDの接続を忘れずに。
* 標準のボーレートは 115200 baud。
* Pi3以降のRaspbianでは /boot/config.txt に **dtoverlay=pi3-miniuart-bt** の追加が必要。

GNU screenで接続する例

    [macOS] screen /dev/cu.USBtoUART 115200
    [Linux] sudo screen /dev/ttyUSB0 115200

# 参考文献

* [Raspberry Pi hardware](https://www.raspberrypi.org/documentation/hardware/raspberrypi/)
