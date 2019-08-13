# Raspberry Pi用イメージのコピーと縮小と加工

# イメージファイルのままマウントする方法

* ループバック機能をつかえば、イメージファイルのままマウントすることができる
* losetup の -P オプションでパーティションの解析も行ってくれる
* こちらは Ubuntu18.04でおこなったが、Raspbianもほぼ同様である(Raspbianだとbootパーティッションのマウント先が/bootになっている)
* ホストマシンは Ubuntu18.04 amd64

## イメージのマウント

イメージファイル名を設定する

	$ IMAGE_NAME=ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img

パーティションリストを確認する

	$ fdisk -l $IMAGE_NAME

	Disk ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img: 2.3 GiB, 2422361088 bytes, 4731174 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0x85baa6c1
	
	Device                                               Boot  Start     End Sectors  Size Id Type
	ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img1 *      2048  526335  524288  256M  c W95 FAT32 (LBA)
	ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img2      526336 4731139 4204804    2G 83 Linux

最初のパーティッションがブート用、2番目がルート

ループバックデバイスを設定する

	$ LOOPBACKDEV=$( sudo losetup -P -f --show $IMAGE_NAME )
	$ echo $LOOPBACKDEV
	/dev/loop20

パーティション状況の確認

	$ ls $LOOPBACKDEV*
	/dev/loop20  /dev/loop20p1  /dev/loop20p2

ルートのマウント

	$ mkdir image
	$ sudo mount $LOOPBACKDEV'p2' image

fstabの確認

	$ cat image/etc/fstab
	LABEL=writable  /        ext4   defaults        0 0
	LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

ブートパーティションは /boot/firmwareにマウントされていることがわかる

ブートパーティションのマウント

	$ sudo mount $LOOPBACKDEV'p1' image/boot/firmware
	$ ls image/boot/firmware

これでマウントの完了

## イメージのアンマウント

内側にマウントしたものから解除していく

	$ sudo umount image/boot/firmware
	$ sudo umount image

ループバックの解除

	$ sudo losetup -d $LOOPBACKDEV

掃除

	$ unset LOOPBACKDEV
	$ unset IMAGE_NAME
	$ rmdir image

# 接続したUSB-MicroSDアダプタのデバイス名の探し方

USB-MicroSDアダプタを接続後、以下のコマンドを実行する

	$ lsblk -o NAME,SIZE,VENDOR,MODEL
	NAME     SIZE VENDOR   MODEL
	sdd     28.9G BUFFALO  BSCR17TU3     -2
	├─sdd1   256M
	└─sdd2  28.6G

接続しているUSB-MicroSDアダプタのメーカがBUFFALO、モデルがBSCR17TU3、MicroSDのサイズが 14.7Gなので、だいたい16GBであるから、デバイス名は **/dev/sdd** である。

# MicroSDのイメージ化、イメージファイルのサイズ縮小

* Ubunutuの場合、cloud-initによってルートパーティッションの拡大が行われるため、ファイルイメージを縮小しておくことができる。これによってコピー元のMicroSDよりも小さなサイズのMicroSDにコピーすることができる。(もちろん全体のファイルサイズが超えてしまったらだめ)

* Raspbian の場合、初回起動後自己削除される /etc/init.d/resize2fs_once がファイルシステムの拡大を行っている。

### USB-MicroSDの接続

mkfs.vfat のためにdosfstoolsを入れる

	$ sudo apt install dosfstools

MicroSDの接続し、デバイス名を確認する。私の環境では /dev/sdd であった。

現在のパーティション構成を確認しておく

	$ sudo fdisk -l /dev/sdd
	Disk /dev/sdd: 28.9 GiB, 30979129344 bytes, 60506112 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0x85baa6c1
	
	Device     Boot  Start      End  Sectors  Size Id Type
	/dev/sdd1  *      2048   526335   524288  256M  c W95 FAT32 (LBA)
	/dev/sdd2       526336 60506078 59979743 28.6G 83 Linux

セクタサイズ 512 byte、ブート領域は 2048 から 524288 で 256M で、ファイルタイプIDは c である

### ソースMicroSDカードのマウント

	$ mkdir -p sdcard
	$ sudo mount /dev/sdd2 sdcard
	$ sudo mount /dev/sdd1 sdcard/boot/firmware

ファイルサイズの計算をする(多少エラーがでるが・・気にしない)

	$ sudo du -sh sdcard
	2.2G    sdcard

### ディスクイメージの作成

新規イメージ名の設定

	$ IMAGE_NAME=ubuntu.img

ちょっとおおきめの空のイメージを作成する

	$ fallocate -l 2.5G $IMAGE_NAME

パーティションの作成

	$ sudo fdisk $IMAGE_NAME

以下のような順番で押していくと

	n -> p -> 1 -> 2048 -> +256M -> t -> c
	n -> p -> 2 -> [ENTER] -> [ENTER]
	a -> 1 -> p

次のような構成ができる

	Disk ubunutu1.img: 2.5 GiB, 2671771648 bytes, 5218304 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0xd177f38c
	
	Device        Boot  Start     End Sectors  Size Id Type
	ubunutu.img1  *      2048  526335  524288  256M  c W95 FAT32 (LBA)
	ubunutu.img2       526336 5218303 4691968  2.2G 83 Linux

問題がなければ、wを押して書き込んで終了

	w

ループバックデバイスの設定

	$ LOOPBACKDEV=$( sudo losetup -P -f --show $IMAGE_NAME )
	$ ls $LOOPBACKDEV*
	/dev/loop0  /dev/loop0p1  /dev/loop0p2

新規イメージフォーマット

	$ sudo mkfs.vfat $LOOPBACKDEV'p1'
	$ sudo mkfs.ext4 -j $LOOPBACKDEV'p2'

ブートデバイスは /boot/firmware なので、そのディレクトリを作成しマウントする

	$ mkdir -p image
	$ sudo mount $LOOPBACKDEV'p2' image
	$ sudo mkdir -p image/boot/firmware
	$ sudo mount $LOOPBACKDEV'p1' image/boot/firmware

ソースMicroSDからイメージへコピー

	$ sudo sh -c 'tar cC sdcard . | tar xvpC image'

ソースMicroSDのアンマウント

	$ sudo umount sdcard/boot/firmware
	$ sudo umount sdcard
	$ rmdir sdcard

初回起動に不要なファイルの削除

	$ sudo rm -v image/etc/ssh/ssh_host_*
	$ sudo rm -rf image/tmp/*
	$ sudo rm -rf image/var/tmp/*
	$ sudo rm -rf image/var/lib/cloud/{data,handlers,instance,instances,scripts,sem}
	$ sudo find image/var/log/ -type f | xargs sudo rm -vf
	$ sudo rm -rf image/var/lib/apt/lists

他に不要なファイルがあるかもしれない

### パーティションの調整

/etc/fstabを確認する

	$ cat image/etc/fstab
	LABEL=writable  /        ext4   defaults,noatime        0 0
	LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

ブートパーティッションには **system-boot** ルートパーティションには **writable** というラベルがついているのがわかる

## 新規イメージのアンマウント

	$ sudo umount image/boot/firmware
	$ sudo umount image
	$ rmdir image

### ボリュームラベルの設定

	$ sudo fatlabel $LOOPBACKDEV'p1' system-boot
	$ sudo e2label $LOOPBACKDEV'p2' writable

	$ sudo fatlabel $LOOPBACKDEV'p1'
	system-boot
	$ sudo e2label $LOOPBACKDEV'p2'
	writable

### ループバックの解除

	$ sudo losetup -d $LOOPBACKDEV

### 変数の削除

	$ unset IMAGE_NAME
	$ unset LOOPBACKDEV

### SDカードの作成

新しいMicroSDカードにイメージを書き込む

まずは対象の確認

	$ lsblk -o NAME,SIZE,VENDOR,MODEL
	sdd     14.7G BUFFALO  BSCR17TU3     -2
	├─sdd1  43.9M
	└─sdd2  14.6G

/dev/sdd とわかる。***/dev/sdd は自分の環境に必ずあわせること、間違えるとシステムを破壊します***

書き込む

	$ sudo dd if=ubunutu.img of=/dev/sdd bs=8M


