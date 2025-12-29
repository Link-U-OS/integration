#!/bin/bash

cd "$(dirname "$0")"
echo "TZ udev patch run in path: ${PWD}"
script_name=$(basename "$0")
echo "execute script: ${script_name}"

echo "TZ refresh udev rule."
sudo cp ./udev/* /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo service udev restart && sudo udevadm trigger
echo "refresh udev rule done."
