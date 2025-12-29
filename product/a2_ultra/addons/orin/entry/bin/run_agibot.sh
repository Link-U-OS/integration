#!/bin/bash

cd $(dirname $0)

# fix udp data frame loss
sudo sysctl -w net.core.rmem_max=20971520  # 20 MiB, default is 208 KiB
sudo sysctl -w net.core.wmem_max=20971529  # 20 MiB, default is 208 KiB

# 加载环境变量
source ./cfg/env.sh

# 设置系统 tcp/udp 端口映射范围
sudo sysctl -w net.ipv4.ip_local_port_range="32768 49999"

# 防止 ROS 无法本地组播报错（本版本启动配置了发现服务器，为了兼容性先保留本项）
ip link set lo multicast on

sudo ip link set can0 down
sudo ip link set can1 down

# 将 VIC 和 NVENC 硬件加速器性能模式设置为最高
echo performance > /sys/class/devfreq/15340000.vic/governor
echo performance > /sys/class/devfreq/154c0000.nvenc/governor
echo performance > /sys/class/devfreq/15540000.nvjpg/governor

# 防止 LCM 无网络时报错
# route add -net 224.0.0.0 netmask 240.0.0.0 dev eth0

# 确保/agibot目录下的owner
find /agibot -name "data" -prune -o -exec chown -h agi:agi {} +

# 确保重要目录权限正常
function EnableDirectory() {
    dir="$1"

    if [ ! -d "${dir}" ]; then
      mkdir -p "${dir}"
    fi
    chmod 777 -R "${dir}"
}

EnableDirectory "${AGIBOT_HOME}/agibot/data/var"
EnableDirectory "${AGIBOT_HOME}/agibot/log"
EnableDirectory "${AGIBOT_HOME}/agibot/data/log/_core"
EnableDirectory "${AGIBOT_HOME}/agibot/data/bag"
EnableDirectory "${AGIBOT_HOME}/agibot/data/minidump"

# 配置网络
source ./set_net_card.sh
# 根据网卡存在情况进行网络设置
if [ -n "$AGIBOT_WIFI_INTERFACE" ]; then
    echo "Using wifi network interface: $AGIBOT_WIFI_INTERFACE"
    setup_network_interface "$AGIBOT_WIFI_INTERFACE"
else
    echo "No valid network interface found. Skipping network configuration."
    # exit 1
fi

# 清除无用的共享内存文件
rm /dev/shm/*

# adu 硬件相关配置
bash ./adu_setup.sh

echo "waitting network available."

timedatectl set-ntp false

# 开启atop录制
bash ./atop_record.sh &

# 设置 core 文件大小
ulimit -c unlimited

# 删除 /agibot/log/_core 目录下，2天前的文件
find "/agibot/log/_core" -type f -mtime +2 -exec rm {} \;

# 删除/agibot/log目录下，无效的ros日志文件
find /agibot/log/ -name ros -exec rm -rf {} +

# if [ -f ./cpuset.py ]; then
#     python3 ./cpuset.py &
# fi

# 后台脚本，设置进程绑核以及优先级
if [ -f ./set_process_affinity.py ]; then
    python3 ./set_process_affinity.py &
fi

# # 阻塞等待同步完成,完成后会写flag文件
# python3 ./master_sync_time.py 192.168.100.100 agi 1

# 启动ntp2rtc服务
# 放在 下面的服务中执行
# python3 ./ntp2rtc_service.py &

# 设置smartctl非root运行
sudo chmod 644 /dev/nvme0n1
sudo setcap cap_sys_admin+ep /usr/sbin/smartctl

# 执行 EM
#exec ${AGIBOT_HOME}/agibot/software/v0/bin/em-server -c ${AGIBOT_HOME}/agibot/software/v0/entry/bin/cfg/run_agibot.yaml

# 启动em_server服务, 包含上面三个步骤
# 1. master_sync_time.py
# 2. ntp2rtc_service.py
# 3. agibot/software/v0/bin/em-server
python3 ./master_em_server.py
