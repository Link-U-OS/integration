#!/bin/bash

# 定义目录路径
AGIBOT_DIR="/etc/systemd/system/agibot"
AGIBOT_N_DIR="/etc/systemd/system/agibot_n"
CHECK_AND_INSTALL_SCRIPT="$AGIBOT_DIR/check_and_install.sh"

# 检查 /etc/systemd/system/agibot 目录是否存在
if [ -d "$AGIBOT_DIR" ]; then
    echo "Directory $AGIBOT_DIR exists. Executing $CHECK_AND_INSTALL_SCRIPT..."
    # 使用 bash 执行 check_and_install.sh 脚本
    bash $CHECK_AND_INSTALL_SCRIPT
    RETURN_CODE=$?
    if [ $RETURN_CODE -eq 0 ]; then
        echo "$CHECK_AND_INSTALL_SCRIPT executed successfully."
        # /bin/systemctl daemon-reload
    fi
    exit $RETURN_CODE
else
    # 检查 /etc/systemd/system/agibot_n 目录是否存在
    if [ -d "$AGIBOT_N_DIR" ]; then
        echo "Directory $AGIBOT_N_DIR exists. Renaming to $AGIBOT_DIR and executing $CHECK_AND_INSTALL_SCRIPT..."
        # 将 /etc/systemd/system/agibot_n 重命名为 /etc/systemd/system/agibot
        mv "$AGIBOT_N_DIR" "$AGIBOT_DIR"
        if [ $? -ne 0 ]; then
            # 重命名失败
            echo "Error: Failed to rename $AGIBOT_N_DIR to $AGIBOT_DIR."
            exit 101
        fi
        # 使用 bash 执行 check_and_install.sh 脚本
        bash $CHECK_AND_INSTALL_SCRIPT
        RETURN_CODE=$?
        if [ $RETURN_CODE -eq 0 ]; then
            echo "$CHECK_AND_INSTALL_SCRIPT executed successfully."
            # /bin/systemctl daemon-reload
        fi
        exit $RETURN_CODE
    else
        # 两个目录都不存在
        echo "Error: Neither $AGIBOT_DIR nor $AGIBOT_N_DIR exists."
        exit 100
    fi
fi
