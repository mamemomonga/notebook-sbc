#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMANDS="format mount umount"

if [ "$(id -u)" != "0" ]; then
	echo "please run as root"
	exit 1
fi


do_format() {
	echo "Target Drive: $TARGET_DRIVE"
	lsblk -o VENDOR,MODEL,NAME,SIZE,TYPE,MOUNTPOINT,UUID $TARGET_DRIVE
	read -p "Ready? (y/N): " yn; case "$yn" in [yY]*) ;; *) echo "abort"; exit 1;; esac
	dd if=/dev/zero of=$TARGET_DRIVE bs=512 count=1 conv=notrunc
	echo 'n
p
1

+256M
t
b
n
p
2

+2G
t
2
82
n
p
3


w' | fdisk -w always -W always $TARGET_DRIVE
	mkfs.vfat $TARGET_DRIVE'1'
	mkswap $TARGET_DRIVE'2'
	mkfs.ext4 $TARGET_DRIVE'3'
	cat << EOS
---------------------------
/etc/fstab example
---------------------------
EOS
	echo $TARGET_DRIVE'1 /boot vfat defaults               0 0'
	echo $TARGET_DRIVE'2 swap  swap defaults               0 0'
	echo $TARGET_DRIVE'3 /mmc  ext4 noatime,data=writeback 0 0'
	echo ''
}

do_mount() {
	mkdir -p /mnt/boot
	mkdir -p /mnt/mmc
	mount -v $TARGET_DRIVE'1' /mnt/boot
	mount -v $TARGET_DRIVE'3' /mnt/mmc
}

do_umount() {
	umount -v /mnt/boot
	umount -v /mnt/mmc
	rmdir /mnt/boot
	rmdir /mnt/mmc
}

usage() {
	echo "-----------------------------"
	echo "Usage:"
   	echo "  $0 [DRIVE] format"
   	echo "  $0 [DRIVE] mount"
   	echo "  $0 [DRIVE] umount"
	echo "-----------------------------"
	echo "Drive List:"
	lsblk -o VENDOR,MODEL,NAME,SIZE,TYPE,MOUNTPOINT,UUID
	exit 1
}

run() {

    for i in $COMMANDS; do
    if [ "$i" == "${1:-}" ]; then
        shift
        do_$i $@
        exit 0
    fi
    done
    echo "USAGE: $( basename $0 ) COMMAND"
    echo "COMMANDS:"
    for i in $COMMANDS; do
    echo "   $i"
    done
    exit 1
}

if [ -z "${1:-}" ]; then usage; fi
TARGET_DRIVE=$1
shift
run $@

