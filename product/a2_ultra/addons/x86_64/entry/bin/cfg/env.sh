#!/usr/bin/bash

# -------------------------------------------------------------
# ROS 相关的环境
# -------------------------------------------------------------

# -------------------------------------------------------------
# 获取适当的UID和GID
# -------------------------------------------------------------

get_first_non_system_user() {
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

USER_INFO=$(get_first_non_system_user)
export USER_UID=$(echo "$USER_INFO" | cut -d ' ' -f 1)
export USER_GID=$(echo "$USER_INFO" | cut -d ' ' -f 2)

chown_to_user "/agibot/data/ota/firmware/v0" $USER_UID $USER_GID
chown_to_user "/agibot/data/param" $USER_UID $USER_GID

# -------------------------------------------------------------
# 机器人模型相关的环境变量
# -------------------------------------------------------------

export AGIBOT_ROBOT_MODEL=$(head -n 1 /agibot/data/info/model)

current_form=$(cat /agibot/data/info/form)
export AGIBOT_ROBOT_FORM=$current_form

export AGIBOT_ROBOT_BODY_URDF_DIR=$AGIBOT_HOME/agibot/data/info/etc/body/$current_form
export AGIBOT_ROBOT_BODY_URDF_FILE_PATH=$AGIBOT_HOME/agibot/data/info/etc/body/$current_form/urdf/model.urdf

# -------------------------------------------------------------
# 末端工具相关的环境变量
# -------------------------------------------------------------

export AGIBOT_TOOLS_HOME_PATH=/agibot/data/info/etc/tools
tool_id="null"
if [ -f "/agibot/data/info/tool_id" ]; then
    tool_id=$(cat /agibot/data/info/tool_id)
fi
export AGIBOT_TOOL_ID=${tool_id}

# -------------------------------------------------------------
# 网络相关的环境变量 (x86, master)
# -------------------------------------------------------------

export AGIBOT_LOCAL_HOST_IP="127.0.0.1"
export AGIBOT_LOCAL_HOST_NAME="agi"
export AGIBOT_NEIGHBOR_HOST_IP="192.168.100.110"
export AGIBOT_NEIGHBOR_HOST_NAME="agi"

export AGIBOT_MASTER_IP="${AGIBOT_LOCAL_HOST_IP}"
export AGIBOT_GATEWAY_IP="${AGIBOT_NEIGHBOR_HOST_IP}"

export MQTT_BROKER_IP="${AGIBOT_GATEWAY_IP}"

export MC_IP="${AGIBOT_LOCAL_HOST_IP}"
export PNC_IP="${AGIBOT_NEIGHBOR_HOST_IP}"

# -------------------------------------------------------------
# 执行所需的环境变量
# -------------------------------------------------------------

export PATH=$PATH:/usr/local/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# 额外不同ADU相关环境变量
source /agibot/software/v0/entry/bin/cfg/env_adu.sh
