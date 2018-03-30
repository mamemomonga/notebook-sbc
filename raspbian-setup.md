# Raspbian基本セットアップ

* Raspberry Pi W
* 2017-11-29-raspbian-stretch-lite
* SD書込にはmacOSを使用する
* HDMI+マウス+キーボードを使わずシリアル接続を使用

* [16GBくらいのMicroSDカード](http://akizukidenshi.com/catalog/g/gS-13002/)を用意します。
* [downloads](https://www.raspberrypi.org/downloads/)から書き込みたいイメージを選び、ダウンロードしておく。
* [pv](https://linux.die.net/man/1/pv) を使うと、書込進捗を監視できます。

# イメージの書込

homebrewをつかってpvのインストール

	$ brew install pv

ディスクユーティリティーを起動

	$ open -a 'Disk Utility'

「ディスクユーティリティー」で書き込みたいSDカードのフォーマット済みパーティッションの「装置」の項目を確認します。**disk3s1** となっていれば、disk3のパーティション1。以下、disk3のSDカードに書き込みます。**必ず自分の環境のディスク番号を確認すること。**

展開します

	$ unzip 2017-11-29-raspbian-stretch-lite.zip

書き込む先をもう一度確認します

	$ diskutil list
	/dev/disk3 (external, physical):
	   #:                       TYPE NAME                    SIZE       IDENTIFIER
	   0:     FDisk_partition_scheme                        *15.7 GB    disk3
	   1:                 DOS_FAT_32 SD                      15.7 GB    disk3s1

disk3でよさそうだ

disk3s1をアンマウントします

	$ diskutil unmount disk3s1

書き込む

[/dev/rdisk* をこちらをつかったほうが高速で書き込める](https://superuser.com/questions/631592/why-is-dev-rdisk-about-20-times-faster-than-dev-disk-in-mac-os-x)。

	$ sudo sh -c 'pv 2017-11-29-raspbian-stretch-lite.img | dd of=/dev/rdisk3 bs=32m'

## シリアルコンソールの設定を行う

書込が完了するとFAT32のbootパーティッションがmacOSにマウントされます。

WiFi,BT内蔵のRaspberry Piで使うRaspbianは、
デフォルトでシリアルコンソールが無効になっているらしいので、
まずは bootパーティションにある config.txt を編集します。

	$ echo 'dtoverlay=pi3-miniuart-bt' >> /Volumes/boot/config.txt

disk3s1をアンマウントする

	$ diskutil unmountDisk disk3

# シリアルインターフェイスの準備

シリアル通信には、USB-UARTブリッジチップののったアダプタを使用する。

USB-UARTブリッジICには

* [FTDI FT-232系](http://www.ftdichip.com/Products/ICs/FT232R.htm)
* [Silicon Labs CP210系](https://jp.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)
* [Profilic PL2303系](http://www.prolific.com.tw/US/ShowProduct.aspx?pcid=41&showlevel=0017-0037-0041)

などがあるので、ICに合わせたドライバをインストールしておきます。

* 回路電圧は **3.3V** を使用してください。
* 買うならFT232系, CP210xを使用したものがおすすめ。FT232はニセモノチップも出回っているので注意。

以下のように接続します

![usb-serial-console.png](usb-serial-console.png)

## シリアル接続

Raspberry Piの電源を入れる前に接続しておく
115200/1-N-8 で接続

### screenをつかって接続

	$ screen /dev/cu.usbserial-ABCDEFG 115200

	CTRL+A k y で終了

### cu をつかって接続

	$ sudo cu -l /dev/cu.usbserial-ABCDEFG -s 115200

# 電源投入してシリアルコンソールからログイン

準備ができたらmicroSDカードをRaspberry Piに刺して、電源を入れます。
起動メッセージが流れます。

## ログインする

	Username: pi
	Password: raspberry

でログイン。piユーザはsudo でrootになれます。

## パスワードの変更

	$ passwd

## SSHの有効化

	$ sudo update-rc.d ssh enable
	$ sudo invoke-rc.d ssh start

## ネットワークの設定

## WiFiの設定

Raspberry Pi3, Raspberry Pi Zero Wでは、WiFiが使用可能です。

* ssid,id_str(interfaces.dの項目と紐付く), psk, priorityを設定する。
* network=の項目は、複数設定可能

wpa_supplicant.conf

	$ sudo sh -c 'cat > /etc/wpa_supplicant/wpa_supplicant.conf' << 'EOS'
	ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
	update_config=1
	country=JP
	
	network={
	    ssid="my-ssid1"
	    id_str="my-ssid1"
	    psk="MY_SECRET_PSK1"
	    priority=10
	}
	network={
	    ssid="my-ssid2"
	    id_str="my-ssid2"
	    psk="MY_SECRET_PSK2"
	    priority=20
	}
	EOS

interfaces.d/wlan0

	$ sudo sh -c 'cat > /etc/network/interfaces.d/wlan0' << 'EOS'
	auto wlan0
	iface wlan0 inet manual
		wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
	iface my-ssid1 inet dhcp	
	iface my-ssid2 inet dhcp	
	EOS

### ホスト名の設定

	$ sudo sh -c 'echo "raspiw" > /etc/hostname'
	$ sudo sed -i 's/raspberrypi/raspiw/' /etc/hosts

## 再起動

	$ sudo reboot

## SSHでの接続

起動メッセージに

	My IP address is 192.168.xxx.xxx

という感じで表示されているので、そちらにSSHで接続する。

	$ ssh pi@192.168.xxx.xxx

# アップデートと再起動

	$ sudo sh -c 'apt-get update && apt-get -y upgrade && reboot'

再接続を行う

この時点で avahi-daemon が入っているので、ローカルネットワークからだと raspiw.local で名前解決できる。

	$ ssh pi@raspiw.local

# 各種設定

メニューで各種設定を行いたい場合は raspi-config を実行する

	$ sudo raspi-config

JSTにする

	$ sudo bash -xeu << 'END_OF_SNIPPET'
	rm /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
	echo 'Asia/Tokyo' > /etc/timezone
	date
	END_OF_SNIPPET

git, vim, ntpd, postfixのセットアップ

	$ sudo bash -xeu << 'END_OF_SNIPPET'
	export DEBIAN_FRONTEND=noninteractive
	apt-get install -y git-core vim ntp postfix

	cat > /etc/vim/vimrc.local << 'EOS'
	syntax on
	set wildmenu
	set history=100
	set number
	set scrolloff=5
	set autowrite
	set tabstop=4
	set shiftwidth=4
	set softtabstop=0
	set termencoding=utf-8
	set encoding=utf-8
	set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp,ucs2le,ucs-2
	set fenc=utf-8
	set enc=utf-8
	EOS
	sudo sh -c "echo '3' | update-alternatives --config editor"

	cat > /etc/ntp.conf << 'EOS'
	driftfile /var/lib/ntp/drift
	statistics loopstats peerstats clockstats
	filegen loopstats file loopstats type day enable
	filegen peerstats file peerstats type day enable
	filegen clockstats file clockstats type day enable
	
	restrict -4 default kod notrap nomodify nopeer noquery
	restrict -6 default kod nomodify notrap nopeer noquery
	restrict 127.0.0.1 
	restrict ::1

	server ntp1.jst.mfeed.ad.jp iburst
	server ntp2.jst.mfeed.ad.jp iburst
	server ntp3.jst.mfeed.ad.jp iburst
	EOS

	service ntp restart
	sleep 10
	ntpq -p

	sed -i.bak -e 's/^\(inet_protocols = all\)/#\1/' /etc/postfix/main.cf
	echo 'inet_protocols = ipv4' >> /etc/postfix/main.cf
	service postfix restart

	END_OF_SNIPPET

# 参考サイト

* [RaspberryPi3でシリアル通信を行う](https://qiita.com/yamamotomanabu/items/33b6cf0d450051d33d41)
* [THE RASPBERRY PI UARTS](https://www.raspberrypi.org/documentation/configuration/uart.md)

