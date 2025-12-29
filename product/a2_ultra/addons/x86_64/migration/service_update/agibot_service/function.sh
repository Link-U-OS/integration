#!/bin/bash

export v0_dir="/agibot/data/ota/firmware/v0"
export vn_dir="/agibot/data/ota/firmware/vn"

export install_service_path="/etc/systemd/system"
export install_bin_path="/usr/local/bin"

# export 当前的服务列表
export service_list="agibot_disk_monitor.service agibot_em.service agibot_ui.service agibot_samba.service"

# 卸载服务
function uninstall_service() {
    service_name=$1
    # 判断服务是否存在
    if [ ! -f "$install_service_path/$service_name" ]; then
        echo "Service $service_name is not installed. Skipping..."
        return 0
    fi

    # 判断服务是否启用
    SERVICE_ENABLED=$(systemctl is-enabled $service_name)
    if [ "$SERVICE_ENABLED" != "enabled" ]; then
        echo "Service $service_name is not enabled. Skipping..."
        return 0
    fi

    echo "Disabling $service_name..."
    sudo systemctl disable $service_name
    echo "Removing $service_name..."
    sudo rm -rf $install_service_path/$service_name
    echo "Uninstallation process completed. The service will be restarted with the new version upon system reboot."
}

# 安装服务
function install_service() {
    service_dir=$2
    service_name=$1
    echo "Copying $service_name to $install_service_path..."
    cp $service_dir/$service_name $install_service_path/$service_name
    echo "Enabling $service_name..."
    sudo systemctl enable $service_name
    echo "Installation process completed. The service will be started with the new version."
}


# 启动服务
function start_service() {
    service_name=$1
    SERVICE_ACTIVE=$(systemctl is-active $service_name)
    if [ "$SERVICE_ACTIVE" == "active" ]; then
        echo "Service $service_name is already running. Skipping..."
        return 0
    fi

    echo "Starting $service_name..."
    sudo systemctl start $service_name &
    echo "Service $service_name has been started successfully."
}

# 停止服务
function stop_service() {
    service_name=$1
    SERVICE_ACTIVE=$(systemctl is-active $service_name)
    if [ "$SERVICE_ACTIVE" != "active" ]; then
        echo "Service $service_name is not running. Skipping..."
        return 0
    fi

    echo "Stopping $service_name..."
    sudo systemctl stop $service_name
    echo "Service $service_name has been stopped successfully."
}

# 获取第一个非系统用户
function get_first_non_system_user() {
    # 获取 UID >= 1000 的用户列表，提取 UID 和 GID，按 UID 排序，取第一个
    local first_user
    first_user=$(getent passwd | awk -F: '($3 >= 1000) {print $3, $4}' | sort -n | head -n 1)

    # 如果没有找到符合条件的用户
    if [ -z "$first_user" ]; then
        echo "No suitable user found."
        return 1
    fi

    # 解析出 UID 和 GID
    local uid=$(echo "$first_user" | cut -d ' ' -f 1)
    local gid=$(echo "$first_user" | cut -d ' ' -f 2)

    # 输出 UID 和 GID
    echo "$uid $gid"
    return 0
}

# 将某个目录转换为普通用户，包括隐藏目录和文件
function chown_to_user() {
    dir=$1
    uid=$2
    gid=$3
    # 先判断 dir 是否已经是普通用户 id, 如果是，则跳过
    current_uid=$(stat -c "%u" $dir)
    if [ "$current_uid" != "$uid" ]; then
        echo "chown -R $uid:$gid $dir"
        chown -R $uid:$gid $dir
    fi
}
