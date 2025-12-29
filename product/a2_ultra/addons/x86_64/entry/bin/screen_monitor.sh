#!/bin/bash

while true
do
	dpms_status=$(cat /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-HDMI-A-2/dpms)
	if [ $dpms_status == "Off" ]; then
		systemctl stop agibot_ui
		systemctl start agibot_ui
	fi
	sleep 10
done
