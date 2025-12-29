#!/bin/bash
###
 # @Descripttion: update udev rules
###
cd "$(dirname "$0")"
echo "run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"
echo "update bt audio cfg start ..."

sudo cp -rp ./cfg/bt_audio/nv-bluetooth-service.conf /lib/systemd/system/bluetooth.service.d/nv-bluetooth-service.conf
sudo chmod 644 /lib/systemd/system/bluetooth.service.d/nv-bluetooth-service.conf
sudo chown root:root /lib/systemd/system/bluetooth.service.d/nv-bluetooth-service.conf

# echo "install pulseaudio-module-bluetooth start ..."
# sudo dpkg -i ./cfg/bt_audio/pulseaudio-module-bluetooth_1%3a15.99.1+dfsg1-1ubuntu2.2_arm64.deb
# echo "install pulseaudio-module-bluetooth end ..."

echo "disable and mask pulseaudio..."
sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user stop    pulseaudio.service  || true
sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user disable pulseaudio.service  || true
sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user stop    pulseaudio.socket   || true
sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user disable pulseaudio.socket   || true
sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user mask    pulseaudio.service  || true
sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user mask    pulseaudio.socket   || true
sudo chmod -x /usr/bin/pulseaudio 2>/dev/null || true
echo "disable and mask pulseaudio done"

#if dpkg-query -W -f='${Status}\n' pulseaudio 2>/dev/null | grep -q "install ok installed"; then
#    echo "pulseaudio have already installed, start remove now ..."
#    sudo apt remove -y pulseaudio
#else
#    echo "no pulseaudio found, no need remove."
#fi

echo "update bt audio cfg end, need restart orin."
