# Ubuntu ARM Raspberry Pi を サーバ向けに調整する

[ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img.xz](https://wiki.ubuntu.com/ARM/RaspberryPi) をベースとする

# 初期設定

* IPアドレスはDHCPで取得されるので、シリアルコンソールなどでログインして確認するか、 DHCPのログを参照する。シリアルコンソールのボーレートは 115200

* キーボードをつなげてHDMIからは確認したことがないので不明
- User: ubuntu / Psassword: ubuntu でログイン

- 任意の root パスワードを設定する

## SSH キーを設定する

 	$ cd
 	$ cat > .ssh/authorized_keys << 'EOS'
 	ssh-ed25519 AAA....
 	EOS

## 富山大学ミラーを追加する

	$ perl > /tmp/cloud.cfg << 'EOS'
	use strict;
	open(my $fhi,'<','/etc/cloud/cloud.cfg') || die $!;
	foreach(<\$fhi>) {
	  print;
	  if(m#\Qsecurity: http://ports.ubuntu.com/ubuntu-ports\E#) {
	    print " search:\n";
	    print " primary:\n";
	    print " - http://ubuntutym.u-toyama.ac.jp/ubuntu-ports/\n";
	  }
	 }
	EOS

	$ sudo sh -c 'cat /tmp/cloud.cfg > /etc/cloud/cloud.cfg'
	$ rm /tmp/cloud.cfg
	$ sudo rm /var/lib/cloud/instances/nocloud/sem/config*apt*\*
	$ sudo cloud-init modules --mode config
	$ grep 'tym' /etc/apt/sources.list

## 日本時間に設定, git, curl, wget の導入, vim の設定

	$ sudo bash -xeu << 'END_OF_SNIPPET'
	export DEBIAN_FRONTEND=noninteractive
	apt-get update

	apt-get -y install tzdata git-core curl wget vim
	rm /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
	echo 'Asia/Tokyo' > /etc/timezone
	date

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
	sudo sh -c "update-alternatives --set editor /usr/bin/vim.basic"

	apt-get -y upgrade

	END_OF_SNIPPET

## noatimeの設定

/ に noatimeオプションを追加する

	$ sudo vim /etc/fstab
	LABEL=writable  /    ext4   defaults,noatime    0 0
	LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

リブートする

	$ reboot

## 起動サービスの選定

以下の調整を行うと、WiFiを始め、様々な機能が使えなくなります。

	$ systemctl list-unit-files -t service | grep enabled | sort

	accounts-daemon.service                enabled
	apparmor.service                       enabled
	atd.service                            enabled
	autovt@.service                        enabled
	blk-availability.service               enabled
	cloud-init.service                     enabled
	console-setup.service                  enabled
	cron.service                           enabled
	dbus-fi.w1.wpa_supplicant1.service     enabled
	dbus-org.freedesktop.resolve1.service  enabled
	ebtables.service                       enabled
	getty@.service                         enabled
	irqbalance.service                     enabled
	iscsi.service                          enabled
	keyboard-setup.service                 enabled
	lvm2-monitor.service                   enabled
	lxcfs.service                          enabled
	lxd-containers.service                 enabled
	networkd-dispatcher.service            enabled
	ondemand.service                       enabled
	open-iscsi.service                     enabled
	pollinate.service                      enabled
	rsync.service                          enabled
	rsyslog.service                        enabled
	setvtrgb.service                       enabled
	snapd.autoimport.service               enabled
	snapd.core-fixup.service               enabled
	snapd.seeded.service                   enabled
	snapd.service                          enabled
	snapd.system-shutdown.service          enabled
	ssh.service                            enabled
	sshd.service                           enabled
	syslog.service                         enabled
	systemd-networkd-wait-online.service   enabled
	systemd-networkd.service               enabled
	systemd-resolved.service               enabled
	systemd-timesyncd.service              enabled
	ufw.service                            enabled
	unattended-upgrades.service            enabled
	ureadahead.service                     enabled
	wpa_supplicant.service                 enabled

無効にするものを列挙して停止

	$ bash << 'EOS'
	  set -eu
	  TARGETS=$( cat << 'EOT'
	accounts-daemon.service
	apparmor.service
	atd.service
	blk-availability.service
	console-setup.service
	dbus-fi.w1.wpa_supplicant1.service
	ebtables.service
	iscsi.service
	keyboard-setup.service 
	lvm2-monitor.service
	open-iscsi.service
	rsync.service
	snapd.autoimport.service
	snapd.core-fixup.service
	snapd.seeded.service
	snapd.service
	snapd.system-shutdown.service
	ufw.service
	wpa_supplicant.service
	lxcfs.service
	lxd-containers.service
	EOT
	)
	for i in $TARGETS; do
	  sudo systemctl stop $i
	  sudo systemctl disable $i
	done
	EOS

/boot/firmware/config.txt の調整

調整前

	enable_uart=1
	kernel=kernel8.bin
	device_tree_address=0x03000000
	dtparam=i2c_arm=on
	dtparam=spi=on
	arm_64bit=1

調整後

	# ARM 64bit
	arm_64bit=1
	
	# device tree
	device_tree_address=0x03000000
	
	# Kernel
	kernel=kernel8.bin
	
	# i2c, spi
	dtparam=i2c_arm=off
	dtparam=spi=off
	
	# UART
	enable_uart=1
	
	# GPUメモリ
	gpu_mem=16
	
	# CPUオーバークロック
	# arm_freq=1300
	# over_voltage=5
	# gpu_freq=500
	
	# SDRAMオーバークロック
	# sdram_freq=500
	# sdram_schmoo=0x02000020
	# over_voltage_sdram_p=6
	# over_voltage_sdram_i=4
	# over_voltage_sdram_c=4

再起動

	$ reboot


### 準備中: 不要なカーネルドライバ

	sudo rmmod brcmfmac
	sudo rmmod brcmutil
	sudo rmmod cfg80211
	sudo rmmod iscsi_tcp
	sudo rmmod libiscsi_tcp
	sudo rmmod libiscsi
	sudo rmmod btrfs
	sudo rmmod raid10
	sudo rmmod raid456
	sudo rmmod async_raid6_recov
	sudo rmmod async_memcpy
	sudo rmmod async_pq
	sudo rmmod async_xor
	sudo rmmod async_tx
	sudo rmmod xor
	sudo rmmod raid6_pq
	sudo rmmod raid1
	sudo rmmod raid0
	sudo rmmod multipath
	sudo rmmod zstd_decompress
	sudo rmmod zstd_compress
	sudo rmmod xxhash

### (参考情報)

メモリの使用量(再起動直後)

	$ free --mega

設定前

	              total        used        free      shared  buff/cache   available
	Mem:            933          98         607           4         228         816
	Swap:             0           0           0


設定後

	              total        used        free      shared  buff/cache   available
	Mem:            933          92         677           4         163         821
	Swap:             0           0           0

ほんのちょっと・・


