#!/bin/bash

# 卸载gdm
# @yangteng 需求

# 关闭gdm
echo "关闭gdm"
# 检查是否有 enable，如果没有则不关闭
SERVICE_STATUS=$(systemctl is-enabled gdm)
if [ "$SERVICE_STATUS" == "enabled" ] || [ "$SERVICE_STATUS" == "static" ]; then
    sudo systemctl disable gdm
fi

echo "删除gdm"
exit 0
