#!/bin/bash
IFACE=${1:-eth_to_x86}

# 1. 禁用 EEE（Energy Efficient Ethernet）
ethtool --set-eee ${IFACE} eee off 2>/dev/null || echo "EEE not supported"

# 2. 禁用 Wake-on-LAN
ethtool -s ${IFACE} wol d 2>/dev/null || true

# 3. 固定速率和双工，禁止自协商降速
ethtool -s ${IFACE} speed 1000 duplex full autoneg on

# 4. 关闭驱动私有节能位（igb 专用）
ethtool --set-priv-flags ${IFACE} "Energy Efficient Ethernet" off 2>/dev/null || true
ethtool --set-priv-flags ${IFACE} "Auto Power Down" off 2>/dev/null || true

# 5. 对 NetworkManager 关闭“省电”
nmcli dev set ${IFACE} managed yes
nmcli dev set ${IFACE} autoconnect yes
nmcli con mod "netplan-${IFACE}" 802-3-ethernet.wake-on-lan 0 2>/dev/null || true

