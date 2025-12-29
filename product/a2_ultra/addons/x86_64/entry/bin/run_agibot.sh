#!/usr/bin/bash

cd $(dirname $0)

python3 ./wifi_check_reboot.py

# fix udp data frame loss
sudo sysctl -w net.core.rmem_max=20971520  # 20 MiB, default is 208 KiB
sudo sysctl -w net.core.wmem_max=20971529  # 20 MiB, default is 208 KiB

echo 1  | sudo tee  /proc/sys/fs/suid_dumpable
sudo snap refresh --hold &

# 加载环境变量
source ./cfg/env.sh

#cpu固定频率
sudo ./frequency.sh

# irq绑定
sudo bash ./irq.sh

# 设置普通用户访问perf event的权限
echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid

# 设置系统 tcp/udp 端口映射范围
sudo sysctl -w net.ipv4.ip_local_port_range="32768 49999"

# 防止 ROS 无法本地组播报错（本版本启动配置了发现服务器，为了兼容性先保留本项）
ip link set lo multicast on

# 防止 LCM 无网络时报错
route add -net 224.0.0.0 netmask 240.0.0.0 dev enp2s0

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

# 清除无用的共享内存文件
rm /dev/shm/*

# adu 硬件相关配置
bash ./adu_setup.sh

# monitor screen dpms
bash ./screen_monitor.sh &

# disable powersave for eth_to_orin
bash ./disable_eth_power_save.sh

# 开启实时时间同步
bash ./start_slave_time_sync.sh

# 捕获网卡流量
bash ./capture_net.sh

# 设置程序net高权，用于ethercat通信
if ! getcap ${AGIBOT_HOME}/agibot/software/v0/bin/aimrt_main_hal | grep "cap_net_raw=eip" >/dev/null; then
  echo "assign advanced permissions to the program cap_cet_raw."
  sudo setcap cap_net_raw=eip ${AGIBOT_HOME}/agibot/software/v0/bin/aimrt_main_hal
fi

# 开启atop录制
bash ./atop_record.sh &

bash ./watch_mc_status.sh &

# 设置 core 文件大小
ulimit -c unlimited

# 删除 /agibot/log/_core 目录下，2天前的文件
find "/agibot/log/_core" -type f -mtime +2 -exec rm {} \;

# 删除/agibot/log目录下，无效的ros日志文件
find /agibot/log/ -name ros -exec rm -rf {} +

# 强制NVME softirq中断处理切换到发起I/O请求的core
echo 2 | sudo tee /sys/class/block/nvme0n1/queue/rq_affinity

# 设置smartctl非root运行
sudo chmod 644 /dev/nvme0n1
sudo setcap cap_sys_admin+ep /usr/sbin/smartctl

# # 执行 EM
# exec ${AGIBOT_HOME}/agibot/software/v0/bin/em-server -c ${AGIBOT_HOME}/agibot/software/v0/entry/bin/cfg/run_agibot.yaml

# 启动 XML-RPC 服务
python3 ./slave_em_server.py 192.168.100.100  56999
