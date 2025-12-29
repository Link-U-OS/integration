#!/bin/bash

# 安装 

cd $(dirname $0)
echo "开始检查并安装fstrim-daily-boot服务"

disable_old_timer()
{
    sudo systemctl stop fstrim.timer
    sudo systemctl disable fstrim.timer
    sudo systemctl mask fstrim.timer

}

install_daily_timer()
{
    sudo cp fstrim/fstrim-daily-boot.* /etc/systemd/system
    sudo systemctl enable fstrim-daily-boot.timer
}

SERVICE_STATUS=$(systemctl is-enabled fstrim.timer)

if [ "$SERVICE_STATUS" != "masked" ]; then
    disable_old_timer
    install_daily_timer
fi

echo "完成fstrim-daily-boot服务安装检查"

exit 0
