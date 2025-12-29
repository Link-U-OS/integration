#!/bin/bash

cd $(dirname $0)

# 0. x86 关闭 ntp 服务，被动授时。
timedatectl set-ntp false

# 函数：确保进程被终止
ensure_killed() {
    local service_name=$1
    while pgrep -f "$service_name" > /dev/null; do
        echo "尝试终止 $service_name 进程..."
        pkill -9 -f "$service_name"
        sleep 1
    done
    echo "$service_name 进程已终止。"
}
net_card_name="eth_to_orin"
# 使用ethtool获取PTP对应的号码
ptp_info=$(ethtool -T $net_card_name)

# 从输出中提取PTP硬件时钟号码
ptp_clock=$(echo "$ptp_info" | grep "PTP Hardware Clock" | awk '{print $NF}')

if [ -z "$ptp_clock" ]; then
    echo "未找到PTP硬件时钟号码"
else
    echo "PTP硬件时钟号码: $ptp_clock"
fi
ptp_name="ptp$ptp_clock"
echo "ptp_name: $ptp_name"

# 4. 检查 ptp4l 是否已经在运行
if pgrep -f "ptp4l" > /dev/null; then
    echo "发现已有 ptp4l 服务在运行，终止进程..."
    ensure_killed "ptp4l"
fi
echo "启动 ptp4l 服务..."
ptp4l -i $net_card_name -f ./cfg/slave_time_sync.conf  > /dev/null 2>&1 &

# 5. 检查 phc2sys 是否已经在运行
if pgrep -f "phc2sys" > /dev/null; then
    echo "发现已有 phc2sys 服务在运行，终止进程..."
    ensure_killed "phc2sys"
fi
echo "将和 orin 互联的网口时间同步到系统中 ..."
phc2sys -s /dev/$ptp_name -c CLOCK_REALTIME -w  -O 0 -S 10  > /dev/null 2>&1 &