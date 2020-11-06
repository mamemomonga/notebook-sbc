# Raspberry Pi4メモ

# ファームウェアのアップデート

Raspberry Pi OSで `rpi-eeprom-update` を実行するとファームウェアをアップグレードできる。
ファームウェアアップグレードで raspi-config などで USB-Bootの設定が可能になる。

https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md

# 外付けUSB 3.1 HDDの問題

USB3.0接続の場合、uas_eh_abort_handler などのエラーがでて正しく動作しないことがある。
UASが中途半端に実装されているデバイスの場合パフォーマンスが極端に悪くなる様子。
また、電力が影響している可能性もある。

https://www.raspberrypi.org/forums/viewtopic.php?t=245931

lsusbで問題のUSBストレージを探して、VID,PIDをメモする。
そして、/boot/cmdline.txtに追記する

	usb-storage.quirks=VVVV:PPPP:u (VVVV:PPPPはそれぞれVID,PIDに置換)

これでUSB3.0接続でもうまく動作する。

