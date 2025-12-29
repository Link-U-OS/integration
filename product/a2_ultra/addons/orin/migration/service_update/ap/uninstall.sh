sudo systemctl stop agibot_ap.service
sudo systemctl disable agibot_ap.service
sudo rm -rf /etc/systemd/system/agibot_ap.service
sudo systemctl mask agibot_ap.service
