#!/bin/bash
###
 # @Descripttion: optimize 5G modem
###

echo "disable ModemManager.service start..."
sudo systemctl stop  ModemManager.service
sudo systemctl disable  ModemManager.service
echo "disable ModemManager.service end."

echo "add agi to dialout group start..."
sudo usermod -aG dialout agi
echo "add agi to dialout group end."
