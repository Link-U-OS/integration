#!/usr/bin/env bash
# bt_connect.sh  <MAC>  示例：./bt_auto_connect.sh  AA:BB:CC:DD:EE:FF

set -euo pipefail

#===================== 全局配置 =====================
readonly LOG_TAG="bt_cmd_api"
readonly PAIRED_FILE="/opt/zy/bluetooth/bt_paired_devices"

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m'   # No Color

# 统一日志函数：log 级别 内容
# 用法示例：log info "xxxx"
log() {
    local level="$1"
    shift
    local msg="$*"
    local ts=$(date '+%F %T')

    # 终端颜色
    case "$level" in
        err)  color=$RED    ;;
        warn) color=$YELLOW ;;
        *)    color=$GREEN  ;;
    esac

    # 1. 终端打印
    printf "%b%s [%s] %s%b\n" "$color" "$ts" "${level^^}" "$msg" "$NC"
    # 2. syslog
    logger -t "$LOG_TAG" -p user."${level}" "$msg"
}
#===================================================

###############################################################################
# 1. 参数检查
###############################################################################
MAC="${1:-}"
[[ -z "$MAC" ]] && { log err "usage: $0 <BT MAC address>"; exit 1; }
[[ ! "$MAC" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] && \
  { log err "MAC address format is incorrect"; exit 1; }

log info "target MAC：$MAC"

###############################################################################
# 2. 工具检查 + 触发扫描
###############################################################################
command -v bluetoothctl >/dev/null 2>&1 || \
  { log err "cannot find bluetoothctl cmd."; exit 1; }

# log info "start scan (max 10 s) ..."
# bluetoothctl --timeout=10 scan on >/dev/null & SCAN_PID=$!

###############################################################################
# 3. 断掉已连接设备
###############################################################################
CONNECTED_MAC=$(bluetoothctl info 2>/dev/null | awk '/^Device /{print $2; exit}' || true)

if [[ "${MAC^^}" == "${CONNECTED_MAC^^}" ]]; then
    log info "already connected to $MAC"
    # kill "$SCAN_PID" >/dev/null 2>&1 || true
    # bluetoothctl scan off >/dev/null 2>&1 || true
    exit
fi

if [[ -n "$CONNECTED_MAC" ]]; then
    log info "disconnect existing connection: $CONNECTED_MAC"
    bluetoothctl disconnect "$CONNECTED_MAC" >/dev/null 2>&1 || true
fi

###############################################################################
# 4. 查找设备 + 连接
###############################################################################
# TIMEOUT=15
# device_found=false
# log info "try to find device: $MAC"
# for ((i=1; i<=30; i++)); do
#     if bluetoothctl devices | grep -qi "$MAC"; then
#         device_found=true
#         bluetoothctl scan off >/dev/null 2>&1 || true
#         kill "$SCAN_PID" >/dev/null 2>&1 || true
#         log info "Device $MAC found."
#         break
#     fi
#     sleep 0.5
# done
# 
# if ! "$device_found"; then
#     log err "Device $MAC not found in ($TIMEOUT)s, exit."
#     bluetoothctl scan off >/dev/null 2>&1 || true
#     kill "$SCAN_PID" >/dev/null 2>&1 || true
#     exit 1
# fi

# if ! awk -F'|' -v mac="${MAC,,}" 'tolower($1)==mac {found=1; exit} END{exit !found}' "$PAIRED_FILE"; then
#     log info "try to pair ..."
#     bluetoothctl pair "$MAC" >/dev/null 2>&1 || true
# fi

log info "try to pair ..."
bluetoothctl pair "$MAC" >/dev/null 2>&1 || true
log info "try to trust ..."
bluetoothctl trust "$MAC" >/dev/null 2>&1 || true
log info "try to connect ..."
bluetoothctl connect "$MAC" >/dev/null 2>&1 || true
###############################################################################
# 5. 轮询检查连接结果（10 秒）
###############################################################################
# START=$(date +%s)
# CONNECTED=false
# while :; do
#   [[ $(( $(date +%s) - START )) -ge 10 ]] && break
# if bluetoothctl info "$MAC" | grep -qi "Connected: yes"; then
#   CONNECTED=true
#     log info "successfully connected to $MAC"
#     break
# fi
#   sleep 0.5
# done

###############################################################################
# 6. 持久化保存结果
###############################################################################
if bluetoothctl info "$MAC" | grep -qi "Connected: yes"; then
  sudo mkdir -p "$(dirname "$PAIRED_FILE")"

  NAME=$(bluetoothctl info "$MAC" 2>/dev/null | awk -F': ' '/Name:/ {print $2}' | tr -d '\r')
  TYPE=$(bluetoothctl info "$MAC" 2>/dev/null | awk -F': ' '/Icon:/  {print $2}' | tr -d '\r')

  sudo sed -i "\|^${MAC}|d" "$PAIRED_FILE" 2>/dev/null || true
  echo "${MAC}|${NAME:-}|${TYPE:-}" | sudo tee -a "$PAIRED_FILE" >/dev/null

  log info "successfully connected to $MAC"
  log info "persistent save: ${MAC}|${NAME:-}|${TYPE:-}"
  exit 0
else
  log err "failed to connect to $MAC within 10 seconds."
  exit 2
fi
