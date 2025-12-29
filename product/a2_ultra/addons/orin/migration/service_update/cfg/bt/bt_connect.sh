#!/usr/bin/env bash
# bt_connect.sh  <MAC>  示例：./bt_auto_connect.sh  AA:BB:CC:DD:EE:FF

set -euo pipefail

###############################################################################
# 1. 参数检查
###############################################################################
MAC="${1:-}"
[[ -z "$MAC" ]] && { echo "usage: $0 <BT MAC address>"; exit 1; }
[[ ! "$MAC" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] && \
  { echo "error：MAC address format is incorrect"; exit 1; }

echo "[INFO] target MAC：$MAC"

###############################################################################
# 2. 工具检查
###############################################################################
command -v bluetoothctl >/dev/null 2>&1 || \
  { echo "error：can not find bluetoothctl cmd."; exit 1; }

###############################################################################
# NEW：3. 如果有已连接的设备，先全部断开
###############################################################################
# echo "[INFO] checking existing connections ..."
# CONNECTED_MAC=""
# 获取所有已知设备
# for dev in $(bluetoothctl devices | awk '{print $2}'); do
#    if bluetoothctl info "$dev" 2>/dev/null | grep -qi "Connected: yes"; then
#        CONNECTED_MAC=$dev
#        break
#    fi
#done

#if [[ -n "$CONNECTED_MAC" ]]; then
#    echo "[INFO] disconnect existing connection: $CONNECTED_MAC"
#    bluetoothctl disconnect "$CONNECTED_MAC" >/dev/null 2>&1 || true
#fi
###############################################################################
# 4. 预先关闭可能残留的扫描
###############################################################################
bluetoothctl --timeout=2 scan off >/dev/null 2>&1 || true

###############################################################################
# 5. 启动扫描，后台进程在 30 秒后强制结束
###############################################################################
echo "[INFO] start scan, maximum lasts 30s ..."
bluetoothctl --timeout=30 scan on >/dev/null & SCAN_PID=$!

###############################################################################
# 6. 尝试配对并连接
###############################################################################
echo "[INFO] try to pair ..."
bluetoothctl pair   "$MAC" >/dev/null 2>&1 || true
echo "[INFO] try to connect ..."
bluetoothctl trust  "$MAC" >/dev/null 2>&1 || true
bluetoothctl connect "$MAC" >/dev/null 2>&1 || true

###############################################################################
# 7. 轮询检查连接结果（30 秒总时限）
###############################################################################
START=$(date +%s)
CONNECTED=false
while :; do
  [[ $(( $(date +%s) - START )) -ge 30 ]] && break
  if bluetoothctl info "$MAC" | grep -qi "Connected: yes"; then
    CONNECTED=true
    break
  fi
  sleep 1
done

###############################################################################
# 8. 清理扫描 & 输出结果
###############################################################################
kill "$SCAN_PID" >/dev/null 2>&1 || true
bluetoothctl scan off >/dev/null 2>&1 || true

if $CONNECTED; then
  echo "[OK] successfully connect to $MAC"
  exit 0
else
  echo "[FAIL] failed to connect to $MAC within 30 seconds."
  exit 2
fi
