#!/bin/bash
###
 # @Descripttion: add bt tools
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "add bt tools start ..."

FILE="/opt/zy/bluetooth/bt_paired_devices"

sudo mkdir -p /opt/zy/bluetooth/

if [ ! -f "$FILE" ]; then
    touch "$FILE"
fi

sudo cp -rp ./cfg/bt/* /opt/zy/bluetooth/
sudo chmod -R +x /opt/zy/bluetooth/
sudo chown -R root:root /opt/zy/bluetooth
echo "add bt tools end ..."
