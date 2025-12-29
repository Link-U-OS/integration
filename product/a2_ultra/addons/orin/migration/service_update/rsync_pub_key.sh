#!/bin/bash
set -euo pipefail

REMOTE_HOST="192.168.100.100"
REMOTE_USER="agi"
SSH_PASS="1"

# 动态选择 SSH KEY 路径
if [ -d "/agibot/data/home/agi/.ssh" ]; then
    SSH_DIR="/agibot/data/home/agi/.ssh"
else
    SSH_DIR="/home/agi/.ssh"
fi
SSH_KEY="$SSH_DIR/agibot_rsa"

check_machine_type() {
    if [ -f "/etc/bsp_version" ]; then
        echo "😊 当前机型无需同步密钥， 跳过同步"
        exit 0
    fi
}

install_sshpass() {
    if ! command -v sshpass &>/dev/null; then
        echo "⚠️ sshpass 未安装，尝试安装..."
        local script_dir
        script_dir=$(dirname "$0")
        if [ -d "$script_dir/sshpass" ] && ls "$script_dir/sshpass/"*.deb &>/dev/null; then
            sudo dpkg -i --force-confnew "$script_dir"/sshpass/*.deb || true
        fi
    fi

    if ! command -v sshpass &>/dev/null; then
        echo "❌ sshpass 安装失败，请检查安装包或环境"
        exit 1
    fi
}

ensure_ssh_key() {
    if [ ! -f "$SSH_KEY" ]; then
        echo "🔑 SSH Key 不存在，正在生成..."
        sudo mkdir -p "$SSH_DIR"
        sudo ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N "" -q
        sudo chmod 600 "$SSH_KEY"
        sudo chown "$REMOTE_USER:$REMOTE_USER" "$SSH_KEY"
    fi
    if [ ! -f "${SSH_KEY}.pub" ]; then
        ssh-keygen -y -f "$SSH_KEY" > "${SSH_KEY}.pub"
    fi
}

copy_ssh_key() {
    echo "🚀 正在同步 SSH Key 到 $REMOTE_USER@$REMOTE_HOST"
    sshpass -p "$SSH_PASS" ssh-copy-id -i "${SSH_KEY}.pub" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" || {
        echo "❌ SSH Key 同步失败，请检查密码或网络"
        exit 1
    }
}

main() {
    echo "🫡 开始检查 SSH 免密登录"
    check_machine_type
    install_sshpass
    ensure_ssh_key
    copy_ssh_key
    exit 0
}

main "$@"
