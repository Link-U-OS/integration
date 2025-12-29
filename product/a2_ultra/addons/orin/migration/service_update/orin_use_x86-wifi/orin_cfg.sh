#!/bin/bash

# the cfg for orin

echo "cfg for orin. enable orin use x86 wifi start ..."

sudo sysctl -w net.ipv4.ip_forward=1
# sudo iptables -t nat -A POSTROUTING -s 192.168.2.74 -o eth2 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 192.168.2.5 -o eth_to_x86 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 192.168.2.5 -o eth2 -j MASQUERADE

count=0
max_retry=40
while ! ping -c1 -W1 192.168.100.100 >/dev/null 2>&1; do
    count=$((count+1))
    if [ "$count" -ge "$max_retry" ]; then
        echo "Error: 192.168.100.100 is unreachable, default route not added."
        exit 1
    fi
    sleep 6
done

echo " 192.168.100.100 is reachable, now need to check x86 wifi whether connected."

tries=0
max=15

while (( tries++ < max )); do
    if sshpass -p "1" \
       ssh -o StrictHostKeyChecking=no -n agi@192.168.100.100 \
       'ip -4 addr show wifi_x86 | grep -q "inet "'; then

        echo "192.168.100.100 is reachable and x86 wifi is connected, so add default route for orin"
        sudo ip route add default via 192.168.100.100 dev eth_to_x86
        break
    fi
    echo "wait for x86 wifi to connect..."
    sleep 6
done

(( tries > max )) && echo "Error: 192.168.100.100 is reachable, but x86 wifi is not connected, so default route need not add."

echo "cfg for orin, enable orin use x86 wifi end ..."