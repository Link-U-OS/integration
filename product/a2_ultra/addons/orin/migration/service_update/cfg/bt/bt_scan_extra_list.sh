#!/usr/bin/env bash
# bt_scan_list.sh  --  过滤已配对设备后输出扫描结果

#===================== 全局配置 =====================
readonly LOG_TAG="bt_cmd_api"
PAIRED_FILE="/opt/zy/bluetooth/bt_paired_devices"

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
    printf  "%s\n" "$msg"
    # 2. syslog
    logger -t "$LOG_TAG" -p user."${level}" "$msg"
}

# 1. 扫描
log info "start bt scan ..."
bluetoothctl --timeout=2 scan on >/dev/null & SCAN_PID=$!

# 2. 读取已配对设备 MAC
declare -A paired_macs
PAIRED_FILE="/opt/zy/bluetooth/bt_paired_devices"
if [[ -r "$PAIRED_FILE" ]]; then
    while IFS='|' read -r mac _ _; do
        [[ -n $mac ]] && paired_macs["$mac"]=1
    done <"$PAIRED_FILE"
fi

# 3. 等待扫描结束 输出未在已配对列表中的设备
sleep 2

bluetoothctl devices | while read -r _ mac name; do
    # 已配对则跳过
    [[ ${paired_macs[$mac]} ]] && continue

    # 去掉分隔符后比较，过滤掉名字就是 MAC 的设备
    [[ ${mac//[:-]} == ${name//[:-]} ]] && continue
    [[ -z $name ]] && continue

    info=$(bluetoothctl info "$mac")

    # 设备类型
    type=$(echo "$info" | awk -F': ' '/Icon/{print $2}')
    # echo "the original type = $type".
    # case "$type" in
    #     audio-card|audio-headset|headset|headphones) type="Headset" ;;
    #     input-keyboard)                type="Keyboard" ;;
    #     input-mouse)                   type="Mouse" ;;
    #     input-tablet)                  type="Tablet" ;;
    #     phone)                         type="Phone" ;;
    #     computer)                      type="Computer" ;;
    #     *)                             type="${type:-Unknown}" ;;
    # esac

    # 仅保留耳机/音响
    case "$type" in
        audio-card|audio-headset|headset|audio-headphones|headphones|audio-speaker|speaker)
            connected=$(echo "$info" | awk -F': ' '/Connected/{print $2}')
            # printf '%s\t%s\t%s\tconnected=%s\n' "$mac" "$name" "$type" "$connected"
            log info "$mac" "$name" "$type" "connected=$connected"
            ;;
    esac

done

bluetoothctl scan off >/dev/null 2>&1 || true
kill "$SCAN_PID" >/dev/null 2>&1 || true
log info "scan done"
