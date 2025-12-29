#!/bin/bash
###
 # @Descripttion: update 5G modem dial-up process
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "update dial-up process start ..."
sudo systemctl stop tztek-jetson-service-net-mobile-connect-v2.service
sudo cp -rp ./cfg_5g/mobileConnect /usr/local/sbin/
sudo cp -rp ./cfg_5g/get_mobile_status /usr/local/sbin/
sudo cp -rp ./cfg_5g/meig-cm /opt/tztek/tztek-jetson-service-net-mobile-connect/meig-cm/meig-cm
echo "update dial-up process done, need restart orin."

echo "update 5G modem cfg file: default.script start ..."
sudo cp -rp ./cfg_5g/default.script /etc/udhcpc/default.script
echo "update 5G modem cfg file: default.script end successfully"
