#!/bin/sh
cd $(dirname $0)
sudo cp ./orin_use_x86_wifi.service /etc/systemd/system/orin_use_x86_wifi.service
sudo mkdir -p /opt/orin_use_x86_wifi
sudo cp ./orin_cfg.sh /opt/orin_use_x86_wifi/
sudo chmod a+x /opt/orin_use_x86_wifi/orin_cfg.sh
sudo systemctl daemon-reload
sudo systemctl enable orin_use_x86_wifi.service
sudo systemctl start orin_use_x86_wifi.service
