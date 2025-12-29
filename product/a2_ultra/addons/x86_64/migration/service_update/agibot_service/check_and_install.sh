#!/bin/bash

# cd to this script's directory
cd $(dirname $0)
source ./function.sh

# 1. 生成 v0 目录
if [ ! -d "$v0_dir" ]; then
    if [ -d "$vn_dir" ]; then
        mv $vn_dir $v0_dir
    else
        echo "Error: v0 和 vn 都不存在."
        sleep 30
        exit 100
    fi
fi

id_info=$(get_first_non_system_user)
uid=$(echo $id_info | awk '{print $1}')
gid=$(echo $id_info | awk '{print $2}')
# chown_to_user $v0_dir $uid $gid

# 2. 安装 agibot_check_and_install 服务
# 2.1 计算已 agibot_check_and_install.service 的哈希值
if [ ! -f "$install_service_path/agibot_check_and_install.service" ]; then
    hash_had_install_service="0"
else
    hash_had_install_service=$(md5sum $install_service_path/agibot_check_and_install.service | awk '{print $1}')
fi
# 2.2 计算待安装 agibot_check_and_install.service 的哈希值
hash_install_service=$(md5sum agibot_check_and_install.service | awk '{print $1}')
# 2.3 如果哈希值相同，则跳过安装
if [ "$hash_had_install_service" == "$hash_install_service" ]; then
    echo "agibot_check_and_install.service 已安装，跳过安装"
else
    # 安装 agibot_check_and_install 服务
    echo "安装 agibot_check_and_install 服务"
    rm -rf $install_service_path/agibot_check_and_install.service
    cp agibot_check_and_install.service $install_service_path/agibot_check_and_install.service
    systemctl disable agibot_check_and_install.service
    systemctl enable agibot_check_and_install.service
fi

# 2.4 计算已安装 agibot_check_and_install.sh 的哈希值
if [ ! -f "$install_bin_path/agibot_check_and_install.sh" ]; then
    hash_had_install_sh="0"
else
    hash_had_install_sh=$(md5sum $install_bin_path/agibot_check_and_install.sh | awk '{print $1}')
fi
# 2.5 计算待安装 agibot_check_and_install.sh 的哈希值
hash_install_sh=$(md5sum agibot_check_and_install.sh | awk '{print $1}')
# 2.6 如果哈希值相同，则跳过安装
if [ "$hash_had_install_sh" == "$hash_install_sh" ]; then
    echo "agibot_check_and_install.sh 已安装，跳过安装"
else
    echo "安装 agibot_check_and_install.sh"
    rm -rf $install_bin_path/agibot_check_and_install.sh
    cp agibot_check_and_install.sh $install_bin_path/
    chmod +x $install_bin_path/agibot_check_and_install.sh
fi

# 3.判断所有服务是否都已安装
is_all_enabled=true
for service in ${service_list}; do
    # 判断服务，有没有安装
    if [ ! -f "/etc/systemd/system/multi-user.target.wants/$service" ]; then
        echo "Service $service is not installed."
        is_all_enabled=false
        continue
    fi
    
    if [ $(systemctl is-enabled $service) != "enabled" ]; then
        echo "Service $service is not enabled. Enabling..."
        is_all_enabled=false
    fi
done

if [ "$is_all_enabled" == "true" ]; then
    echo "All services are enabled."
    exit 0
fi

# 4. 安装服务
for service in ${service_list}; do
    # 后缀是 .service
    if [[ $service == *.service ]]; then
        install_service $service ./service
    fi
done

# 5. 启动服务
echo "Reloading systemd daemon..."
systemctl daemon-reload

for service in ${service_list}; do
    start_service $service
done

exit 0
