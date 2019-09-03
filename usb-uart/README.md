# シリアルの接続

シングルボードコンピュータにはHDMIなどのビデオ出力がないものがあり、また、GUIやビデオが不要でテキスト・コンソールさえあれば事足りる場合があります。その場合、シリアルコンソール経由でアクセスします。パソコンに接続する場合はUSB-UARTアダプタを利用します。

# UARTでの接続

[UARTはUniversal Asynchronous Receiver/Transmitterの略](https://ja.wikipedia.org/wiki/UART)で、シリアル通信の一種で、その中でも基本的なものです。シングルボードコンピュータで言うシリアル接続は一般的にこれを指します。これを外だしできるように信号レベルなどを変換したものがRS-232Cになります。

UARTには最低3本の線を利用します。TX(送信), RX(受信), GND(グランド)です。変換基盤のTXとターゲットのRX、変換基板のRXとターゲットのTX、変換基板のGNDとターゲットのGND、と言う形で接続します。

また、信号には主に3.3Vと5Vが存在します。Raspberry Piなど多くのSBCは3.3Vで、Arduino UNOなどは5Vです。1.8Vのものもあります。これはハードウェアによって違い、場合によっては破損しますので、きちんと互いのデバイスを確認しておく必要があります。

# USB-UART変換IC及びモジュールとドライバ

USB-UARTアダプタのドライバは、それに使われているチップによって決まります。

## FTDI FT232系

* もっともメジャーで安定感のあるものはFTDI FT232系です。
* 3.3V / 5V と選択できるものが多いです。
* 中華通販でニセモノの**チップ**にあたったことがあります、**IC自体が偽物でした**。安すぎるモジュールに要注意。

モジュール・ケーブル例

* [FTDI USBシリアル変換アダプター Rev.2](https://www.switch-science.com/catalog/2782/)
* [FT232RL USBシリアル変換モジュール](http://akizukidenshi.com/catalog/g/gK-01977/)
* [FT234X 超小型USBシリアル変換モジュール](http://akizukidenshi.com/catalog/g/gM-08461/)
* [FTDI USBシリアル変換ケーブル(3.3V)](http://akizukidenshi.com/catalog/g/gK-12974/)
* [USB-TTLシリアルコンバータ 3.3V 3.5mmプラグ](https://strawberry-linux.com/catalog/items?code=50050)

ドライバ

* [FTDI FT232系(VCP Drivers)](https://www.ftdichip.com/Drivers/VCP.htm)
* Linuxの場合は多くの場合OSに付属しています

OSでの認識

* macOSの場合 **/dev/cu.usbserial-XXXXX** として認識されます
* Linuxの場合 **/dev/ttyUSBX** として認識されます
* Windowsだと **COMXX** です(未確認)

## Silicon Labs CP2102

* 安価で安定感があります。
* 3.3Vのみ。
* 中華通販で配線ミスのあるモジュールにあたったことがあります。(チップはおそらく正規品)

モジュール・ケーブル例

* [USBシリアル変換モジュール CP2102使用 JYE119](http://akizukidenshi.com/catalog/g/gK-12974/)

ドライバ

* [CP210x USB - UART ブリッジ VCP ドライバ](https://jp.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)
* Linuxの場合は多くの場合OSに付属しています

### OSでの認識

* macOSの場合 **/dev/cu.SLAB_USBtoUART** として認識されます
* Linuxの場合 **/dev/ttyUSBX** として認識されます
* Windowsだと **COMXX** です(未確認)

## Profilic PL2303系

* さらに安価です。
* 初心者向きではありません。
* いろいろと不具合が起きやすい印象がありますが、上手くいけばそれなりに使えます。
* Raspberry Pi向けの専用ケーブルが安価で売っています。

モジュール・ケーブル例

* [Raspberry Pi ラズベリーパイ用の USB－TTLシリアルコンソールのUSB変換COMケーブルモジュールのケーブル](https://www.amazon.co.jp/dp/B00K7YYFNM/)

ドライバ

* [Profilic PL2303](http://www.prolific.com.tw/JP/ShowProduct.aspx?p_id=223&pcid=126)
* Linuxの場合は多くの場合OSに付属しています

## その他

ほかにも[MCP2221A(便利なGPIO付きIC)](https://www.microchip.com/wwwproducts/en/MCP2221A)や[CH340(中華Arduinoクローンに多い、激安)](http://www.wch.cn/download/CH341SER_EXE.html)などがあります。

# 利用方法

## 配線

* 必ずロジックレベル(電圧)を確認します
* TXとRX, RXとTX, GNDとGNDを接続します
* ボーレートを確認します。Raspberry Piの場合は 115200 です
* パリティなし、データビット 8、ストップビット 1（N/8/1）でたいてい繋がります

## ターミナル

LinuxおよびmacOS

### screenをつかって接続

	$ screen /dev/cu.usbserial-ABCDEFG 115200

	CTRL+A k y で終了

### cu をつかって接続

	$ sudo cu -l /dev/cu.usbserial-ABCDEFG -s 115200

Windows

[TeraTerm](http://hp.vector.co.jp/authors/VA002416/) や [ttssh2](https://ja.osdn.net/projects/ttssh2/)を使用します。

# Raspberry Pi Raspbianでのシリアル接続

WiFi機能のあるRaspberry Piでシリアルコンソールを使うためには、/boot/config.txt に **dtoverlay=pi3-miniuart-bt** を追記する必要があります。
