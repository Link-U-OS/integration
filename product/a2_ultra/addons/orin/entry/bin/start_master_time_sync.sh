#!/bin/bash

cd $(dirname $0)

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

# 1. 检查 ptp4l 是否已经在运行
if pgrep -f "ptp4l" > /dev/null; then
    echo "发现已有 ptp4l 服务在运行，终止进程..."
    ensure_killed "ptp4l"
fi
echo "启动 ptp4l 服务..."

lidar_device_name="eth_lidar"  # lidar: 192.168.1.50
device_name2="eth_to_x86"

# 使用ethtool获取PTP对应的号码
lidar_ptp_info=$(ethtool -T $lidar_device_name)

# 从输出中提取PTP硬件时钟号码
lidar_ptp_clock=$(echo "$lidar_ptp_info" | grep "PTP Hardware Clock" | awk '{print $NF}')

if [ -z "$lidar_ptp_clock" ]; then
    echo "未找到PTP硬件时钟号码"
else
    echo "PTP硬件时钟号码: $lidar_ptp_clock"
fi

ptp_info2=$(ethtool -T $device_name2)

# 从输出中提取PTP硬件时钟号码
ptp_clock2=$(echo "$ptp_info2" | grep "PTP Hardware Clock" | awk '{print $NF}')

if [ -z "$ptp_clock2" ]; then
    echo "未找到PTP硬件时钟号码"
else
    echo "PTP硬件时钟号码: $ptp_clock2"
fi


# 打印hwclock 时间
hwclock_rtc=$(hwclock --rtc=/dev/rtc_agibot -r)
echo "hwclock_rtc: $hwclock_rtc"

# rtc时间设置到系统时间
hwclock --rtc=/dev/rtc_agibot -s
system_time=$(date)
echo "rtc时间设置到系统时间完成, 系统时间: $system_time"

# 同步系统时间到ptp，tz机器上eth_lidar和eth_to_x86共用同一张网卡
phc_ctl /dev/ptp"$lidar_ptp_clock" set
time=$(phc_ctl /dev/ptp"$ptp_clock2" get)
echo "同步系统时间到ptp完成,ptp时间: $time"

ptp4l -i $device_name2 -f ./cfg/master_time_sync.conf > /dev/null 2>&1 &
ptp4l -i $lidar_device_name -f ./cfg/lidar_time_sync.conf > /dev/null 2>&1 &

# 2. 检查 phc2sys 是否已经在运行
if pgrep -f "phc2sys" > /dev/null; then
    echo "发现已有 phc2sys 服务在运行，终止进程..."
    ensure_killed "phc2sys"
fi

echo "同步系统时间到网卡上"
# tz机器上eth_lidar和eth_to_x86共用同一张网卡
phc2sys -s CLOCK_REALTIME -c /dev/ptp"$lidar_ptp_clock" -w -O 0 -S 10 > /dev/null 2>&1 &
