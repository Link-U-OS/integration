#!/bin/sh
cd $(dirname $0)
sudo systemctl unmask agibot_ap.service
sudo cp ./agibot_ap.service /etc/systemd/system/
sudo mkdir -p /opt/ap
sudo mkdir -p /etc/hostapd
sudo cp ./ap.sh /opt/ap
sudo chmod a+x /opt/ap/ap.sh
sudo systemctl enable agibot_ap.service
sudo systemctl start agibot_ap.service
