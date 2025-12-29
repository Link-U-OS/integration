#!/bin/bash

# 检查网卡是否存在的函数
check_network_interface() {
    local nic_name="$1"

    if [ -z "$nic_name" ]; then
        echo "Usage: check_network_interface <network_interface>"
        return 2
    fi

    if ip link show "$nic_name" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置网络共享的函数
setup_network_interface() {
    local nic_name="$1"

    echo "Setting up network interface: $nic_name"
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo iptables -t nat -A POSTROUTING -s 192.168.2.74 -o "$nic_name" -j MASQUERADE
}

# 人形默认使用 wifi-wlan
echo "Setting default network interface to wifi-wlan"
export AGIBOT_WIFI_INTERFACE="wifi-wlan"

