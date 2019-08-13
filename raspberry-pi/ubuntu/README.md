# Raspberry Pi Ubuntu

Linux ARM64では一番利用しやすい Ubuntu 18.04.2 を使用している。
ここでは ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img.xz を使用する。
以下からダウンロードが可能。

[RaspberryPi](https://wiki.ubuntu.com/ARM/RaspberryPi)

	$ xz -d ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img.xz

で展開し、[balena Etcher](https://www.balena.io/etcher/) などでMicroSDにイメージを作成することができる。

デフォルトユーザ名は **ubuntu** パスワードは **ubuntu** である。初回ログイン時にパスワードの変更を求められる。

* [Raspberry Pi用イメージのコピーと縮小と加工](Images.md)
* [サーバ向けに調整する](ServerOptimize.md)
* [config.txt](ConfigTxt.md)
* [ミラーを富山大学に変更](AptMirror.md)

