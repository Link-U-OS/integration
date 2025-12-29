#!/bin/bash

LOCK_FILE="/tmp/usb_cam_reset.lock"
touch "$LOCK_FILE"

reset_usb_power() {
    BUS_GPIO=$1
    echo "正在重启 Realsense D415 相机 usb 电源: gpio=usb3_p${BUS_GPIO}_en"

    GPIO_PATH="/sys/class/tz_gpio/usb3_p${BUS_GPIO}_en/value"

    if [ ! -e "$GPIO_PATH" ]; then
        echo "[Error]: GPIO 控制路径不存在: $GPIO_PATH"
        return 1
    fi

    echo 0 > "$GPIO_PATH"
    if [ $? -eq 0 ]; then
        echo "[Success]: Disabled USB3_P${BUS_GPIO}_EN"
    else
        echo "[Failed]: Failed to disable USB3_P${BUS_GPIO}_EN"
    fi

    sleep 2

    echo 1 > "$GPIO_PATH"
    if [ $? -eq 0 ]; then
        echo "[Success]: Enabled USB3_P${BUS_GPIO}_EN"
    else
        echo "[Failed]: Failed to enable USB3_P${BUS_GPIO}_EN"
    fi

    sleep 2
    echo "完成重启 Realsense D415 相机 usb 电源 (gpio=usb3_p${BUS_GPIO}_en)"
}

reset_by_bus_number() {
    local BUS=$1
    case "$BUS" in
        001)
            reset_usb_power 3
            ;;
        003|005)
            reset_usb_power 6
            ;;
        *)
            echo "[Warning]: 未知 Bus${BUS}，尝试全部重启"
            reset_usb_power 3
            reset_usb_power 6
            ;;
    esac
}

check_usb_speed() {
    DEVICE_INFO=$(lsusb | grep "415")

    if [ -z "$DEVICE_INFO" ]; then
        echo "错误：未找到包含 Realsense D415 的 USB 设备"
        reset_usb_power 3
        reset_usb_power 6
        return 1
    fi

    BUS_STR=$(echo "$DEVICE_INFO" | awk '{print $2}')
    BUS_NUM=$(echo "$BUS_STR" | sed 's/^0*//')  # 数值
    DEV_NUM=$(echo "$DEVICE_INFO" | awk '{print $4}' | sed 's/://;s/^0*//')

    SPEED_INFO=$(lsusb -t | grep "Bus 0*${BUS_NUM}")
    SPEED=$(echo "$SPEED_INFO" | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+[MG]$/) print $i}')

    echo "Realsense D415 相机挂载在 Bus${BUS_STR}，速率为: ${SPEED}"

    if [ "$SPEED" == "10000M" ] || [ "$SPEED" == "5000M" ]; then
        echo "✅ 相机连接速率正常 (${SPEED})"
        return 0
    elif [ "$SPEED" == "480M" ]; then
        echo "❌ 检测到 USB2.0 (480M)，执行电源重启"
        reset_by_bus_number "$BUS_STR"
        return 1
    else
        echo "❌ 未知速率 (${SPEED})，执行电源重启"
        reset_by_bus_number "$BUS_STR"
        return 1
    fi
}

# 尝试多次检测
for i in {1..3}; do
    check_usb_speed
    RES=$?
    if [ $RES -eq 0 ]; then
        echo "✅ Realsense D415 相机 USB 接口速率检查通过"
        break
    else
        echo "⚠️ 第 $i 次检测失败，等待重试..."
        sleep 1
    fi
done

rm -f "$LOCK_FILE"

exit $RES
