#!/bin/bash

# 安装 agibot 服务
# @chengweiyuan 维护

cd $(dirname $0)
source ./agibot_service/function.sh

# 1. 关闭 em 服务
uninstall_service em.service

# 2. 卸载 agibot_ota 服务
uninstall_service agibot_ota.service

# 3. 强制安装 agibot_check_and_install.service
echo "安装 agibot_check_and_install.service"
rm -rf $install_service_path/agibot_check_and_install.service
cp agibot_service/agibot_check_and_install.service $install_service_path/agibot_check_and_install.service
systemctl disable agibot_check_and_install.service
systemctl enable agibot_check_and_install.service
sync

# 4. 强制安装 agibot_check_and_install.sh
echo "安装 agibot_check_and_install.sh"
rm -rf $install_bin_path/agibot_check_and_install.sh
cp agibot_service/agibot_check_and_install.sh $install_bin_path/
chmod +x $install_bin_path/agibot_check_and_install.sh
sync

# 5. 安装 agibot 相关服务
# 替换 /etc/systemd/system/agibot 目录
if [ -d "/etc/systemd/system/agibot_n" ]; then
    echo "删除agibot_n目录"
    rm -rf /etc/systemd/system/agibot_n
fi
echo "拷贝agibot_n目录"
cp -r "./agibot_service" /etc/systemd/system/agibot_n

if [ -d "/etc/systemd/system/agibot" ]; then
    echo "卸载agibot目录中的服务"
    bash /etc/systemd/system/agibot/uninstall.sh
    if [ -d "/etc/systemd/system/agibot_d" ]; then
        sudo rm -rf /etc/systemd/system/agibot_d
    fi
    mv /etc/systemd/system/agibot /etc/systemd/system/agibot_d
    rm -rf /etc/systemd/system/agibot_d
fi
echo "安装agibot目录"
mv /etc/systemd/system/agibot_n /etc/systemd/system/agibot

# 6. 同步文件
sync

exit 0
