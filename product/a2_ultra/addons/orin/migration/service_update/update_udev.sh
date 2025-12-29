#!/bin/bash
###
 # @Descripttion: update udev rules
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "update udev rules start ..."

sudo cp -rp ./cfg/udev/70-persistent-usb-net.rules /etc/udev/rules.d/
sudo chmod 644 /etc/udev/rules.d/70-persistent-usb-net.rules
sudo chown root:root /etc/udev/rules.d/70-persistent-usb-net.rules

echo "update udev rules done, need restart orin."