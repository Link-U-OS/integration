#!/bin/bash

# 修改核心转储配置
# @yangteng 需求

cd $(dirname $0)

# 1. 关闭 apport.service
sudo systemctl stop apport.service
sudo systemctl disable apport.service

cp ./core_pattern/apport /etc/default/apport

# 检查 /etc/default/apport 内容
cat /etc/default/apport

# 2. 配置 sysctl.conf
cp ./core_pattern/sysctl.conf /etc/sysctl.conf

sysctl -p

# 检查 /etc/sysctl.conf 内容
cat /etc/sysctl.conf

# 3. 配置 limits.conf
cp ./core_pattern/limits.conf /etc/security/limits.conf

# 检查 /etc/security/limits.conf 内容
cat /etc/security/limits.conf

# 4. 在服务中放开 ulimit

# 5. 允许 sudo 传递 ulimit
chown root:root ./core_pattern/sudoers
chmod 440 ./core_pattern/sudoers
cp ./core_pattern/sudoers /etc/sudoers

# 检查 /etc/sudoers 内容
cat /etc/sudoers

exit 0
