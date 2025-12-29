#!/bin/bash

# the cfg for x86

echo "cfg for x86, enable orin use x86 wifi start ..."

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 192.168.100.110 -o wifi_x86 -j MASQUERADE

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 1883 -j DNAT --to-destination 192.168.100.110:1883
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 1883 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 64513 -j DNAT --to-destination 192.168.100.110:64513
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 64513 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 64514 -j DNAT --to-destination 192.168.100.110:64514
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 64514 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 64515 -j DNAT --to-destination 192.168.100.110:64515
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 64515 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 64516 -j DNAT --to-destination 192.168.100.110:64516
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 64516 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 51056 -j DNAT --to-destination 192.168.100.110:51056
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 51056 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 5000 -j DNAT --to-destination 192.168.100.110:5000
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 5000 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 3478 -j DNAT --to-destination 192.168.100.110:3478
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 3478 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 50090 -j DNAT --to-destination 192.168.100.110:50090
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 50090 -j SNAT --to-source 192.168.100.100

sudo iptables -t nat -A PREROUTING -i wifi_x86 -p tcp --dport 21274 -j DNAT --to-destination 192.168.100.110:21274
sudo iptables -t nat -A POSTROUTING -d 192.168.100.110 -p tcp --dport 21274 -j SNAT --to-source 192.168.100.100

echo "cfg for x86, enable orin use x86 wifi end ..."

