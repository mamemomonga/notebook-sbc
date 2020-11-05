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

ツールのダウンロード、/root/files にダウンロードされる。

    root@piserver:# cd
    root@piserver:# curl -Ls https://raw.githubusercontent.com/mamemomonga/notebook-sbc/master/raspberry-pi/nfsroot/files/downloads.sh | bash


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

## ホスト情報の確認

クライアントとなるPi3B+ で Raspberry Pi OSやDebian BusterをMicroSDで起動し、ホスト情報を確認する。

    $ curl -Ls https://raw.githubusercontent.com/mamemomonga/notebook-sbc/master/raspberry-pi/nfsroot/files/piinfo.pl | perl
    Model:  Raspberry Pi 3 Model B Plus Rev 1.3(a020d3)
    SoC:    BCM2835
    Serial: abcdef01
    IPv4:   192.168.80.11/24
    HWAddr: b8:27:eb:ab:cd:12
    program_usb_boot_mode=1 ENABLE

この情報はこの先参照します。

**program_usb_boot_mode=1 ENABLE** の場合はPXEBootが可能です。 **program_usb_boot_mode=1 DISABLE** の場合は、/boot/config.txt に program_usb_boot_mode=1 に追記して再起動して再実行してください。

確認と設定が完了したら、シャットダウンして電源を切りMicroSDカードを抜きます。

## OSのイメージのダウンロードと展開

ホスト名は **p1** とします

	root@piserver:# mkdir -p /dsk/rpi/nfs
	root@piserver:# mkdir -p /dsk/rpi/tftp

/dsk/rpi/nfs/p1 に rootイメージを展開

	root@piserver:# cd /dsk/rpi
	root@piserver:# wget https://github.com/mamemomonga/rpi-debian-buster/releases/download/v1.0.1/rpi-buster-v1.0.1.img.xz
	root@piserver:# xz -d rpi-buster-v1.0.1.img.xz 
    root@piserver:# /root/files/expand-image.sh rpi-buster-v1.0.1.img nfs/p1

## PXEBootの設定

/dsk/rpi/tftp/bootcode.bin を設置

    root@piserver:# cp nfs/p1/boot/bootcode.bin tftp/

/dsk/rpi/tftp/c31da6bf を作成

	root@piserver:# cp -av nfs/p1/boot tftp/c31da6bf

カーネルパラメータの設定

    root@piserver:# TARGET_HOST=p1 TARGET_SERIAL=abcdef01 bash -xe << 'EOS'
    echo 'console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=192.168.80.1:/dsk/rpi/nfs/'$TARGET_HOST',rsize=1048576,wsize=1048576,tcp,vers=3 rw ip=dhcp elevator=deadline net.ifnames=0 biosdevname=0' > /dsk/rpi/tftp/$TARGET_SERIAL/cmdline.txt
    EOS

## NFSrootの設定

ホストの設定

    root@piserver:# TARGET_HOST=p1 bash -xe << 'EOS'
    echo 'proc /proc proc defaults 0 0' > /dsk/rpi/nfs/$TARGET_HOST/etc/fstab
    echo '' > /dsk/rpi/nfs/$TARGET_HOST/etc/network/interfaces
    echo '127.0.0.1 localhost '$TARGET_HOST > /dsk/rpi/nfs/$TARGET_HOST/etc/hosts
    echo $TARGET_HOST > /dsk/rpi/nfs/$TARGET_HOST/etc/hostname
    EOS

SSHキーの設定

/home/admin/.ssh の id_25519.pub を登録する。相手の/home/adminのUIDは1000であるとする。

	root@piserver:# TARGET_HOST=p1 bash -xe << 'EOS'
    mkdir -m 0700 /dsk/rpi/nfs/$TARGET_HOST/home/admin/.ssh
    cat /home/admin/.ssh/id_ed25519.pub > /dsk/rpi/nfs/$TARGET_HOST/home/admin/.ssh/authorized_keys
    chmod 0600 /dsk/rpi/nfs/$TARGET_HOST/home/admin/.ssh/authorized_keys
    chown -R 1000:1000 /dsk/rpi/nfs/$TARGET_HOST/home/admin/.ssh
    EOS

NFSの設定

	root@piserver:# echo '/dsk/rpi/nfs/p1 192.168.80.*(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports

	root@piserver:# exportfs -a
	root@piserver:# exportfs
    /dsk/rpi/nfs/p1
                    192.168.80.*

dnsmasqの設定

	root@piserver:# TARGET_MAC=b8:27:eb:ab:cd:12 TARGET_HOST=p1 TARGET_ADDR=192.168.80.11 bash -xe << 'EOS'
    echo "dhcp-host=$TARGET_MAC,$TARGET_ADDR" >> /etc/dnsmasq.conf
    echo "address=/$TARGET_HOST/$TARGET_ADDR" >> /etc/dnsmasq.conf
    echo "" >> /etc/dnsmasq.conf
    EOS

    root@piserver:# cat /etc/dnsmasq.conf
    root@piserver:# systemctl restart dnsmasq

これで基本設定は完了、あとはPi3B+ の電源を入れるとブートする。起動シーケンスがはじまるまで1分ほどかかる。シリアルコンソールなどをつけておいたほうがよい。

