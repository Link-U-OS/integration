#!/bin/bash
###
 # @Descripttion: update netplan conf
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "update netplan conf start ..."
sudo cp -rp ./cfg_netplan/01-network-manager-vlan-eth1.yaml /etc/netplan/01-network-manager-vlan-eth1.yaml
sudo cp -rp ./cfg_netplan/99-vlan.conf /etc/NetworkManager/conf.d/99-vlan.conf
sudo chmod 644 /etc/NetworkManager/conf.d/99-vlan.conf
sudo chown root:root /etc/NetworkManager/conf.d/99-vlan.conf
echo "update netplan done, need restart orin."
