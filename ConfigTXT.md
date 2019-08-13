# config.txt ファイル

config.txtファイルに設定を行うことで、Linux側からはできないRaspberry Pi自体の各種設定を行う。
Raspbian(arm7l)の場合 **/boot/config.txt**, Debian Buster(arm64),Ubuntu(arm64)の場合 **/boot/firmware/config.txt**

# 設定例

## Raspberry Pi3以降をヘッドレスで使う場合よく使う設定

    # Pi 3以降のRaspbianでUARTを有効にする
    dtoverlay=pi3-miniuart-bt

    # GPUメモリを16MBにする
    gpu_mem=16

## arm64カーネル向け設定

    # Switch the CPU from ARMv7 into ARMv8 (aarch64) mode
    arm_control=0x200

    # arm64でuartを有効にする
    enable_uart=1

## Raspberry Pi3オーバークロック

冷却をきちんとしないとサーマルスロッティングで逆に性能が落ちるので注意 

    # CPUのオーバークロック
    arm_freq=1300
    over_voltage=5
    gpu_freq=500

    # SDRAMのオーバークロック
    sdram_freq=500
    sdram_schmoo=0x02000020
    over_voltage_sdram_p=6
    over_voltage_sdram_i=4
    over_voltage_sdram_c=4

    # 強制ターボモード
    force_turbo=1

## ベリフェラル

    # SPIを有効にする
    dtparam=spi=on

    # I2Cを有効にする
    dtparam=i2c_arm=on

    # I2Sを有効にする
    dtparam=i2s=on

    # hifiberry-dac(BB PCM5102互換)を使用する
    dtoverlay=hifiberry-dac

    # パワーオフ状態でなければ、GPIO22をHIGHにする
    dtoverlay=gpio-poweroff,gpiopin=22,active_low="y"

    # (Raspberry Pi2)USB出力電源を0.6Aから1.2Aにする
    max_usb_current=1

## その他

    # 虹のスプラッシュ画面を無効にする
    disable_splash=1

# 参考文献

* [config.txt](https://www.raspberrypi.org/documentation/configuration/config-txt/)
* [Raspberrypi3のデバイスツリーについて](https://qiita.com/cello_piano_violin/items/90e417123e7e026b190e)
* [Device Trees, overlays, and parameters](https://www.raspberrypi.org/documentation/configuration/device-tree.md)

