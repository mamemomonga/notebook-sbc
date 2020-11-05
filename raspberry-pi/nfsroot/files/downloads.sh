set -eu

FILES_URL="https://raw.githubusercontent.com/mamemomonga/notebook-sbc/master/raspberry-pi/nfsroot/files"

download() {
        local name=$1
        local fexec="${2:-}"
        mkdir -p files
        echo "Download: $name"
        curl -Lso files/$name $FILES_URL"/"$name
        if [ "$fexec" == "1" ]; then
                chmod 755 files/$name
        fi
}

download dnsmasq-resolv.conf
download dnsmasq.conf
download expand-image.sh 1
download firewall.service
download firewall.sh 1
download modify-bootable-sdcard.sh 1

