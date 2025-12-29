#!/usr/bin/bash

# 和 ADU相关的配置更新 比如refresh udev等
echo "$AGIBOT_ADU_TYPE ADU setup"

# make jetson clock runs
sudo jetson_clocks

sudo bash usb_cam_reset.sh &