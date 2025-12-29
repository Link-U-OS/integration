#!/usr/bin/env bash
# bt_scan_list.sh

timeout 1s bluetoothctl -- scan on >/dev/null 2>&1
bluetoothctl scan off >/dev/null 2>&1 || true

bluetoothctl devices | while read -r _ mac name; do
    # 去掉分隔符后比较，过滤掉名字就是 MAC 的设备
    [[ ${mac//[:-]} == ${name//[:-]} ]] && continue
    [[ -z $name ]] && continue

    info=$(bluetoothctl info "$mac")

    # 设备类型
    type=$(echo "$info" | awk -F': ' '/Icon/{print $2}')
    case "$type" in
        audio-card|headset|headphones) type="Headset" ;;
        input-keyboard)                type="Keyboard" ;;
        input-mouse)                   type="Mouse" ;;
        input-tablet)                  type="Tablet" ;;
        phone)                         type="Phone" ;;
        computer)                      type="Computer" ;;
        *)                             type="${type:-Unknown}" ;;
    esac

    # 配对 / 连接状态
    paired=$(echo "$info" | awk -F': ' '/Paired/{print $2}')
    connected=$(echo "$info" | awk -F': ' '/Connected/{print $2}')

    printf '%s\t%s\t%s\tpaired=%s\tconnected=%s\n' "$mac" "$name" "$type" "$paired" "$connected"
done
