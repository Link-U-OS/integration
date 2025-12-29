#!/bin/bash

# 修改内核启动参数
# @yangteng 需求

cd $(dirname $0)

config_path1="/etc/grub.d/40_custom"
config_path2="/agibot_bk/etc/grub.d/40_custom"

# 备份路径
backup_path1="${config_path1}.bak"
backup_path2="${config_path2}.bak"

# 初始化标志，记录是否需要调用 update-grub
update_needed=false

# 计算哈希值的函数（使用 md5sum）
calculate_hash() {
    local file=$1
    md5sum "$file" | awk '{print $1}'
}

# 原子化的 update-grub 操作
atomic_update_grub() {
    echo "正在检查并处理 /etc/default/grub 软链接..."

    # 获取当前grub配置中的default值
    local current_default=""
    if [[ -f "/boot/grub/grub.cfg" ]]; then
        current_default=$(cat /boot/grub/grub.cfg | grep "default=\"Ubuntu_" | cut -d '_' -f 2 | cut -c 1)
    fi

    # 获取当前/etc/default/grub软链接指向
    local current_link=""
    if [[ -L "/etc/default/grub" ]]; then
        current_link=$(readlink /etc/default/grub)
    fi

    echo "当前default值: $current_default"
    echo "当前软链接指向: $current_link"

    # 根据规则处理软链接
    local need_relink=false

    if [[ "$current_default" == "a" && "$current_link" == "/etc/default/grub_b" ]]; then
        echo "检测到default为'a'但软链接指向grub_b，正在重新设置软链接..."
        sudo ln -sf /etc/default/grub_a /etc/default/grub
        need_relink=true
    elif [[ "$current_default" == "b" && "$current_link" == "/etc/default/grub_a" ]]; then
        echo "检测到default为'b'但软链接指向grub_a，正在重新设置软链接..."
        sudo ln -sf /etc/default/grub_b /etc/default/grub
        need_relink=true
    else
        echo "软链接指向正确，无需修改"
    fi

    if [[ "$need_relink" == true ]]; then
        echo "软链接已重新设置，新的指向: $(readlink /etc/default/grub)"
    fi

    # 执行 update-grub
    echo "正在执行 update-grub..."
    update-grub

    echo "update-grub 执行完成"
}

# 备份并修改文件的函数
process_file() {
    local original_file=$1
    local backup_file=$2
    local file_changed=false

    # 备份文件
    cp "$original_file" "$backup_file"

    # 修改备份文件
    sed -i 's/isolcpus=.*/isolcpus=2-13 nohz_full=2-13 rcu_nocbs=2-13 pcie_aspm=off $vt_handoff quiet net.ifnames=0 biosdevname=0/' "$backup_file"

    # 计算哈希值
    original_hash=$(calculate_hash "$original_file")
    backup_hash=$(calculate_hash "$backup_file")

    # 比较哈希值
    if [[ "$original_hash" == "$backup_hash" ]]; then
        # 删除未生效的备份文件
        rm -f "$backup_file"
    else
        mv "$backup_file" "$original_file"
        file_changed=true
    fi

    echo $file_changed
}

# 处理两个文件并记录是否有修改
file1_changed=$(process_file "$config_path1" "$backup_path1")
file2_changed=$(process_file "$config_path2" "$backup_path2")

# 如果至少有一个文件被修改，设置更新标志
if [[ "$file1_changed" == "true" || "$file2_changed" == "true" ]]; then
    update_needed=true
fi

# 如果需要更新 GRUB 配置文件，调用 update-grub
if [[ "$update_needed" == true ]]; then
    echo "检测到文件内容有更改，正在调用 update-grub..."
    atomic_update_grub
else
    echo "文件内容均未更改，无需调用 update-grub。"
fi

echo "文件 ${config_path1} 内容:"
cat ${config_path1}

echo "文件 ${config_path2} 内容:"
cat ${config_path2}

echo "执行完成"

exit 0
