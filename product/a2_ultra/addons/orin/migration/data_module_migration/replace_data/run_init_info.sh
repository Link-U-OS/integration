#!/bin/bash

# 定义文件路径
BASHRC_PATH="/agibot/data/home/agi/.bashrc"
BASH_PROFILE_PATH="/agibot/data/home/agi/.bash_profile"
LOGIN_INFO_PATH="/agibot/data/home/agi/.login_info"

# 计算文件的MD5值
function calculate_md5() {
    local file_path=$1
    if [ -f "$file_path" ]; then
        md5sum "$file_path" | awk '{ print $1 }'
    else
        echo ""
    fi
}

# 检查文件是否存在并验证MD5值
function check_and_copy_file() {
    local source_path=$1
    local dest_path=$2
    local owner_group=$4

    local current_md5=$(calculate_md5 "$dest_path") # 计算目标文件的MD5值
    local expected_md5=$(calculate_md5 "$source_path") # 计算源文件的MD5值
    echo $current_md5
    if [ -z "$current_md5" ] || [ "$current_md5" != "$expected_md5" ]; then
        echo "文件 $dest_path 不存在或MD5值不匹配，正在复制并设置权限..."
        sudo cp -f "$source_path" "$dest_path"
        sudo chown "$owner_group" "$dest_path"
        echo "文件 $dest_path 设置成功！"
    else
        echo "文件 $dest_path 存在且MD5值匹配，无需操作。"
    fi
}

# 执行检查和复制操作
check_and_copy_file "./bashrc" "$BASHRC_PATH" "agi:agi"
check_and_copy_file "./bash_profile" "$BASH_PROFILE_PATH" "agi:agi"
check_and_copy_file "./login_info" "$LOGIN_INFO_PATH" "root:root"