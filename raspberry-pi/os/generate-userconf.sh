#!/bin/bash
set -eu

NEW_USERNAME="newuser"
NEW_PASSWORD="newpass"

docker run --rm -e "NEW_USERNAME=$NEW_USERNAME" -e "NEW_PASSWORD=$NEW_PASSWORD" -i debian bash << 'EOS'
apt-get update
apt-get install -y openssl
echo "USERNAME: $NEW_USERNAME"
ENC_PASSWORD="$(echo "$NEW_PASSWORD" | openssl passwd -6 -stdin)"
echo ""
echo ""
echo "-- /boot/userconf.txt"
echo "$NEW_USERNAME:$ENC_PASSWORD"
EOS