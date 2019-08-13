# Ubuntu 18.04 arm64のミラーを富山大学に変更する 

	$ sudo vim /etc/cloud/cloud.cfg

system_info -> package_mirrors -> arches: [arm64, armel, armhf] -> search -> primary に追加

	 - http://ubuntutym.u-toyama.ac.jp/ubuntu-ports/

設定の適用

	$ sudo rm /var/lib/cloud/instances/nocloud/sem/config_apt_*
	$ sudo cloud-init modules --mode config

設定の確認

	$ grep 'tym' /etc/apt/sources.list
	
アップデートとアップグレードと再起動

	$ sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt update && sudo apt upgrade -y && reboot'

