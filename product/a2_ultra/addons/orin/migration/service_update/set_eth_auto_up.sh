#!/bin/bash
###
 # @Descripttion: set the network card of lidar auto up
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "set the network card of lidar auto up start ..."
sudo cp -rp ./cfg/ethernet/lidar_auto_up.conf /etc/NetworkManager/conf.d/lidar_auto_up.conf
sudo chmod 644 /etc/NetworkManager/conf.d/lidar_auto_up.conf
sudo chown root:root /etc/NetworkManager/conf.d/lidar_auto_up.conf
echo "set the network card of lidar auto up end ...."
