#!/bin/bash
###
 # @Descripttion: update mobile managed devices
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "update mobile managed device start ..."
sudo cp -rp ./cfg_ethernet/10-mobile-managed-devices.conf /etc/NetworkManager/conf.d/
echo "update mobile managed devices done, need restart orin."
