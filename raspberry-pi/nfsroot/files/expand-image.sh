#!/bin/bash
set -eu

usage() {
	echo "USAGE: $0 [SRC] [DEST]"
	exit 1
}

if [ -z "${1:-}" ]; then usage; fi
if [ -z "${2:-}" ]; then usage; fi

if [ "$(id -u)" != 0 ]; then
	echo "please run as root"
	exit 1
fi

SRCFILE=${1:-}
DSTFILE=${2:-}
LOOPBACK=$( losetup -f -P --show $SRCFILE )

mount $LOOPBACK'p2' /mnt
mount $LOOPBACK'p1' /mnt/boot

mkdir -p $DSTFILE
echo "$SRCFILE -> $LOOPBACK -> $DSTFILE"
tar cC /mnt . | tar xC $DSTFILE

umount /mnt/boot
umount /mnt

losetup -d $LOOPBACK
