#!/usr/bin/env bash
# bt_remove_paired_devices.sh  AA:BB:CC:DD:EE:FF
set -euo pipefail

MAC="${1:-}"
[[ -z "$MAC" ]] && { echo "usage: $0 <BT MAC address>"; exit 1; }
[[ ! "$MAC" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] && \
  { echo "error: MAC address format is incorrect"; exit 1; }

PAIR_FILE="/opt/zy/bluetooth/bt_paired_devices"

echo "[INFO] removing $MAC from paired..."
sudo bluetoothctl -- remove "$MAC" 2>/dev/null || true   # 不判断结果
# 删除包含该 MAC 的整个记录行（格式：MAC|设备名|类型）
sudo sed -i "\|${MAC}|d" "$PAIR_FILE" 2>/dev/null || true
echo "[OK] $MAC has been removed from paired"
