# macOS Sierra で OS の入ったSDカードを準備

* [16GBくらいのMicroSDカード](http://akizukidenshi.com/catalog/g/gS-13002/)を用意します。
* [downloads](https://www.raspberrypi.org/downloads/)から書き込みたいイメージを選び、ダウンロードしておく。
* [pv](https://linux.die.net/man/1/pv) を使うと、書込進捗を監視できます。

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

fat32のbootパーティションがマウントされます。
必要に応じてconfig.txt, cmdline.txtを修正します。

disk3s1をアンマウントする

	$ diskutil unmountDisk disk3


