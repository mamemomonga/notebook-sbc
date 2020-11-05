#!/bin/bash
set -eu

FILES_URL="https://raw.githubusercontent.com/mamemomonga/notebook-sbc/master/raspberry-pi/nfsroot/files"

download() {
	local name=$1
	local fexec=${2:-}
	mkdir -p files
	curl -Lo files/$name $FILES_URL"/"$name
	if [ "$fexec" == "1" ]; then
		chmod files/$name
	fi
}

download dnsmasq-resolv.conf
download dnsmasq.conf
download expand-image.sh 1
download firewall.service
download firewall.sh 1
download piinfo.pl
