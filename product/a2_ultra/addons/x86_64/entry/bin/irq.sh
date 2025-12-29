#!/bin/bash

sudo systemctl stop irqbalance
sudo systemctl disable irqbalance

bind_irq_to_cpu() {
	local interface=$1
	local cpu=$2

	irqs=$(grep "$interface" /proc/interrupts | awk '{print $1}' | tr -d ':')

	if [ -z "$irqs" ]; then
		echo "无法找到与 $interface 相关的 IRQ 号"
		return 1
	fi

	for irq in $irqs; do
		echo "正在处理 IRQ 号: $irq"
		echo $cpu | sudo tee /proc/irq/$irq/smp_affinity_list
		if [ $? -ne 0 ]; then
			echo "无法将 IRQ $irq 绑定到 CPU $cpu"
		else
			echo "IRQ $irq 已成功绑定到 CPU $cpu"
		fi
	done

	return 0
}

set_irq_prio() {
    local dev_or_irq="$1"
    local prio="$2"
    [[ -z $prio ]] && { echo "Usage: set_irq_prio <iface|irq> <prio 1-99>"; return 1; }
    # 1. 如果给的是接口名，先转成 IRQ 号列表
    local irq_list
    if [[ $dev_or_irq =~ ^[0-9]+$ ]]; then
        irq_list=("$dev_or_irq")
    else
        irq_list=($(awk -F: "/${dev_or_irq}/ {print \$1}" /proc/interrupts | tr -d ' '))
        [[ ${#irq_list[@]} -eq 0 ]] && { echo "Interface $dev_or_irq not found"; return 1; }
    fi
    # 2. 逐个线程调优先级
    for irq in "${irq_list[@]}"; do
        local tid
        tid=$(ps -eo pid,comm | awk -v irq="$irq" '$2 ~ "irq/"irq"-" {print $1}')
        [[ -z $tid ]] && continue
        sudo chrt -f -p "$prio" "$tid" && echo "irq/$irq  -> FIFO $prio"
    done
}

bind_irq_to_cpu "eth_ecat" 11
bind_irq_to_cpu "eth_ecat2" 12
bind_irq_to_cpu "eth_multi_fun" 12
bind_irq_to_cpu "eth_to_orin" 12
bind_irq_to_cpu "eth4" 12
bind_irq_to_cpu "eth5" 12
bind_irq_to_cpu "iwlwifi" 15

set_irq_prio eth_ecat 95
set_irq_prio eth_ecat2 95

# 检查是否有任何绑定失败
if [ $? -ne 0 ]; then
	echo "脚本执行过程中发生错误"
	exit 1
fi

echo "所有 IRQ 已成功绑定到指定的 CPU"
exit 0
