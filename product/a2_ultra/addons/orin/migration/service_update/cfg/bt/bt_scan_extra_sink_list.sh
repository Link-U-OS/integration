#!/usr/bin/env bash
# bt_scan_list.sh  --  过滤已配对设备后输出扫描结果

# 1. 读取已配对设备 MAC
declare -A paired_macs
pair_file="/opt/zy/bluetooth/bt_paired_devices"
if [[ -r "$pair_file" ]]; then
    while IFS='|' read -r mac _ _; do
        [[ -n $mac ]] && paired_macs["$mac"]=1
    done <"$pair_file"
fi

# 2. 扫描
timeout 1s bluetoothctl -- scan on >/dev/null 2>&1
bluetoothctl scan off >/dev/null 2>&1 || true

# 3. 输出未在已配对列表中的设备
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

    # # 配对 / 连接状态
    # connected=$(echo "$info" | awk -F': ' '/Connected/{print $2}')

    # printf '%s\t%s\t%s\tconnected=%s\n' "$mac" "$name" "$type" "$connected"

    # 仅保留耳机/音响
    case "$type" in
        audio-card|audio-headset|headset|audio-headphones|headphones|audio-speaker|speaker)
            connected=$(echo "$info" | awk -F': ' '/Connected/{print $2}')
            printf '%s\t%s\t%s\tconnected=%s\n' "$mac" "$name" "$type" "$connected"
            ;;
    esac

done
