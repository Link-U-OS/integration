#!/bin/bash

# 卸载 emqx
# @yangteng 需求

cd $(dirname $0)

# 关闭emqx
echo "关闭emqx"
# 检查是否有 enable，如果没有则不关闭
SERVICE_STATUS=$(systemctl is-enabled emqx)
if [ "$SERVICE_STATUS" == "enabled" ]; then
    sudo systemctl disable emqx
fi

echo "删除emqx"
exit 0
