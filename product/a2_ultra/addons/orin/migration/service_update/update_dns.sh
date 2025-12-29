#!/bin/bash
###
 # @Descripttion: update udev rules
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "update dns cfg start ..."

sudo cp -rp ./cfg/dns/nv-fallback-dns.conf /etc/systemd/resolved.conf.d/nv-fallback-dns.conf
sudo chmod 644 /etc/systemd/resolved.conf.d/nv-fallback-dns.conf
sudo chown root:root /etc/systemd/resolved.conf.d/nv-fallback-dns.conf

echo "update dns cfg end, need restart orin."
