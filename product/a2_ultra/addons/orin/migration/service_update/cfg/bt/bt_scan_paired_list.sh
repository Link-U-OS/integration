#!/bin/bash
#
# bt_scan_paired_list.sh
# 作用：读取 /opt/zy/bluetooth/bt_paired_devices
#       每行格式：mac|设备名|设备类型
#       将每行追加“连接状态”后直接打印到标准输出，格式：
#       mac 设备名 设备类型 connected=yes/no
#

INPUT_FILE="/opt/zy/bluetooth/bt_paired_devices"

[[ -f "$INPUT_FILE" ]] || { echo "文件不存在: $INPUT_FILE" >&2; exit 1; }

while IFS='|' read -r mac device_name device_type _; do
    # 忽略空行
    [[ -z "$mac" ]] && continue

    mac="${mac// /}"                    # 去掉空格
    if bluetoothctl info "$mac" &>/dev/null && \
       bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        status="yes"
    else
        status="no"
    fi

    printf '%s %s %s connected=%s\n' "$mac" "$device_name" "$device_type" "$status"
done < "$INPUT_FILE"
