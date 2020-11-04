# PXEboot, NFSroot

# 基本情報

* サーバはルータ、NFSサーバ、tftpサーバ、dhcpサーバを構成する

用途 | ハードウェア
----|----------
サーバ | Raspberry Pi 4B(4GB)
サーバ用 MicroSD | 32GBくらい
クライアント情報確認用 MicroSD | 8GBくらい
サーバ用 SSD | USB3.0 - SATAケース経由でSATA HDDを接続
クライアント | Raspberry Pi 3B+
USB3.0 Ethernet ドングル | ax88179チップ
USB-UARTケーブル | 任意

## OS

* [Raspberry Pi OS(armhf)](https://www.raspberrypi.org/downloads/raspberry-pi-os/)
* [Debian Buster arm64](https://github.com/mamemomonga/rpi-debian-buster)

# サーバのセットアップ

[Debian Buster arm64](https://github.com/mamemomonga/rpi-debian-buster)のMicroSDを作成します

ホスト名の変更

	admin@localhost:$ sudo vim /etc/hostname
	piserver

	admin@localhost:$ sudo vim /etc/hosts
	127.0.0.1 localhost piserver

	admin@localhost:$ sudo reboot

再起動と各種インストール

	admin@piserver:$ sudo su -
	root@piserver:# apt install -y nfs-kernel-server dnsmasq

/etc/sysctl.d/disable-ipv6.conf

	net.ipv6.conf.all.disable_ipv6 = 1
	net.ipv6.conf.default.disable_ipv6 = 1

/etc/sysctl.d/nfs.conf

	net.core.wmem_max = 50331648
	net.core.rmem_max = 50331648
	net.ipv4.tcp_mem = "50331648 50331648 50331648"
	net.ipv4.udp_mem= "50331648 50331648 50331648"
	net.core.netdev_max_backlog = 5000

適用

	root@piserver:# sysctl -w

## ネットワークの設定

eth0: 内臓Ethernet / eth1: USB3.0 Ethernet

/etc/network/interfaces

	allow-hotplug eth0
	iface eth0 inet dhcp

	allow-hotplug eth1
	iface eth1 inet static
	  address 192.168.80.1
	  netmask 255.255.255.0

ファイアーウォール設定スクリプト

* [/root/firewall.sh](./files/firewall.sh)
* [/etc/systemd/system/firewall.service](./files/firewall.service)

systemdの適用

	root@piserver:# systemctl enable firewall
	root@piserver:# systemctl start firewall

動作の確認

	root@piserver:# systemctl status firewall

	root@piserver:# iptables -L
	Chain INPUT (policy ACCEPT)
	target     prot opt source               destination
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere             state RELATED,ESTABLISHED

	Chain FORWARD (policy ACCEPT)
	target     prot opt source               destination
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere

	Chain OUTPUT (policy ACCEPT)
	target     prot opt source               destination
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere
	ACCEPT     all  --  anywhere             anywhere

再起動後も適用されていることを確認する

## USBで接続したSSDの初期化とマウント

TOSHIBA の SSDを /dsk として作成する

    root@piserver:# lsblk -o VENDOR,MODEL,NAME,SIZE,TYPE,MOUNTPOINT,UUID
    VENDOR   MODEL                 NAME          SIZE TYPE MOUNTPOINT UUID
    TOSHIBA  TOSHIBA_THNSNH256GCST sda         238.5G disk
                                   └─sda1      238.5G part /dsk       12345678-1234-1234-1234-12345678abcd
1つのパーティションを作成し、フォーマットする

	root@piserver:# fdisk /dev/sda
	root@piserver:# mkfs.ext4 /dev/sda1

UUIDを確認する

	root@piserver:# lsblk -f /dev/sda1
	NAME FSTYPE LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
	sda1 ext4         12345678-1234-1234-1234-12345678abcd    220G     1% /dsk

/dsk を作成

	root@piserver:# mkdir /dsk

fstabを編集

	root@piserver:# vim /etc/fstab
	追記
	UUID=12345678-1234-1234-1234-12345678abcd /dsk ext4 defaults 0 0

手作業でマウントしてマウントを確認してリブート

	root@piserver:# mount -a
	root@piserver:# mount
	root@piserver:# reboot