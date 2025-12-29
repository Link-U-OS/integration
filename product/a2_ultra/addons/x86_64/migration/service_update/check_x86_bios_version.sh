#!/bin/bash
# 定义一个函数来处理版本信息的输出和写入
write_bios_version() {
    local bios_version="$1"
    echo "当前主机BIOS版本为：$bios_version"
    echo "当前主机BIOS版本为：$bios_version" > /agibot/software/x86_version.txt
}

# 获取 scaling_driver 的返回值
scaling_driver=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver)
# 判断 scaling_driver 类型，并根据不同类型输出相应的 BIOS 版本
if [[ "$scaling_driver" == "acpi-cpufreq" ]]; then
    write_bios_version "8.870.2067-A12"
    exit 0
elif [[ "$scaling_driver" == "intel_pstate" ]]; then
    if [ ! -f "/sys/devices/system/cpu/cpu0/cpuidle/state*/name" ]; then
        echo "文件 /sys/devices/system/cpu/cpu0/cpuidle/state*/name 不存在" > /agibot/software/x86_version.txt
        echo "X86 BIOS 版本不正确，请联系 APQ 厂家确认"
        exit 0
    fi

    output=$(cat /sys/devices/system/cpu/cpu0/cpuidle/state*/name 2>&1)
    echo "$output"
    if [[ "$output" == *"cat:"* ]]; then
        write_bios_version "8.870.2067-A13"
        echo "X86 BIOS 版本不正确，请联系 APQ 厂家确认"
        exit 0
    else
        write_bios_version "8.870.2067-A10"
        echo "X86 BIOS 版本不正确，请联系 APQ 厂家确认"
        exit 0
    fi

else
    echo "无法识别的 scaling_driver: $scaling_driver"
    echo "无法识别的 scaling_driver: $scaling_driver" > /agibot/software/x86_version.txt
    echo "X86 BIOS 版本不正确，请联系 APQ 厂家确认"
    exit 0
fi

echo "进入到错误分支"
echo "进入到错误分支" > /agibot/software/x86_version.txt
echo "X86 BIOS 版本不正确，请联系 APQ 厂家确认"
exit 0