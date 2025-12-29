#!/bin/sh

# 添加ap_orin虚拟网口用于softap
UAP_IFNAME=ap_orin
# sudo iw dev |grep -q ${UAP_IFNAME} || sudo iw dev wifi_orin interface add ${UAP_IFNAME} type __ap
# echo "add softap interface ${UAP_IFNAME} successful."

# 配置文件路径
passwd_file="/opt/ap/passwd"
ssid_file="/opt/ap/ssid"
card_file="/opt/ap/card"
gateway_file="/opt/ap/gateway"
sn_file="/agibot/data/info/sn"

# 默认值
default_passwd="02270227"
default_ssid="Robot-SS-Y-M-XXXXX"
default_card="usb-wlan"
default_gateway="192.168.88.88"

hostapd_config="/opt/ap/hostapd.conf"
udhcpd_config="/opt/ap/udhcpd-ap.conf"


# 读取热点密码，文件不存在时创建并设置默认密码
if [ -f "$passwd_file" ]; then
    ap_passwd=$(cat "$passwd_file" | tr -d '[:space:]')
else
    echo "$default_passwd" | sudo tee "$passwd_file" > /dev/null
    ap_passwd="$default_passwd"
fi

# 读取网卡配置，文件不存在时创建并使用默认值
if [ -f "$card_file" ]; then
    usb_card=$(cat "$card_file" | tr -d '[:space:]')
else
    echo "$default_card" | sudo tee "$card_file" > /dev/null
    usb_card="$default_card"
fi

echo "最终的 usb_card 网卡为: $usb_card"

# 检查 sn_file 是否存在
if [ -f "$sn_file" ]; then
    sn=$(cat "$sn_file" | tr -d '[:space:]')
    echo "sn: $sn"
    
    # 确保 sn 的长度足够
    if [ ${#sn} -ge 14 ]; then
        # 使用 cut 提取 sn 的各个部分
        SS=$(echo "$sn" | cut -c1-2)
        Y=$(echo "$sn" | cut -c8)
        M=$(echo "$sn" | cut -c9)
        X=$(echo "$sn" | cut -c10-14)
        ssid_name="Robot-$SS-$Y-$M-$X"
        
        # 写入 ssid_file
        echo "$ssid_name" | sudo tee "$ssid_file" > /dev/null
    else
        echo "错误: sn 长度不足，无法生成 SSID"
        exit 1
    fi
else
    echo "错误: sn_file 不存在"
    exit 1
fi

# 读取热点名，文件不存在时创建并使用默认值
ssid_name=$(cat "$ssid_file" | tr -d '[:space:]')

echo "SSID 设置为: $ssid_name"

#设置NetWorkanager不托管 usb-wlan
CONF_FILE="/etc/NetworkManager/NetworkManager.conf"
CONNECTIONS_DIR="/etc/NetworkManager/system-connections"
INTERFACE=$usb_card
KEYFILE_SECTION="[keyfile]"
UNMANAGED_LINE="unmanaged-devices"

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以root权限运行此脚本 (例如：sudo $0)"
    exit 1
fi

# 如果配置文件不存在，创建空文件
if [ ! -f "$CONF_FILE" ]; then
    echo "配置文件 $CONF_FILE 不存在，正在创建..."
    touch "$CONF_FILE"
fi

# 检查 [keyfile] 段是否存在，如果不存在则添加
if ! grep -q "^\[keyfile\]" "$CONF_FILE"; then
    echo "在 $CONF_FILE 中未找到 [keyfile] 段，正在添加..."
    echo "" >> "$CONF_FILE"
    echo "[keyfile]" >> "$CONF_FILE"
fi

# 从文件中读取 [keyfile] 段内容，尝试找到 unmanaged-devices 行
UNMANAGED_EXISTS=$(awk -v RS='' -v IGNORECASE=1 '
    /\[keyfile\]/ {
        # 在keyfile段内查找unmanaged-devices
        if ($0 ~ /unmanaged-devices/) print "yes"
    }' "$CONF_FILE")

# 如果 unmanaged-devices 行不存在，直接添加
if [ -z "$UNMANAGED_EXISTS" ]; then
    echo "unmanaged-devices行不存在，正在添加..."
    # 追加到 keyfile 段底部
    sed -i "/\[keyfile\]/a unmanaged-devices=interface-name:$INTERFACE" "$CONF_FILE"
else
    # 如果 unmanaged-devices 行已存在，但需要添加新接口
    # 首先提取现有的 unmanaged-devices 行内容
    CURRENT_LINE=$(awk -F= '/^\s*unmanaged-devices\s*=/ {print $2}' "$CONF_FILE" | head -n 1 | tr -d '[:space:]')

    # 检查接口是否已存在
    if echo "$CURRENT_LINE" | grep -q "interface-name:$INTERFACE"; then
        echo "接口 $INTERFACE 已存在于 unmanaged-devices 中，无需更新。"
    else
        # 添加新的接口，使用分号隔开
        NEW_LINE="$CURRENT_LINE;interface-name:$INTERFACE"

        # 使用 sed 替换旧行
        sed -i "s|unmanaged-devices=.*|unmanaged-devices=$NEW_LINE|" "$CONF_FILE"
        echo "已将 $INTERFACE 添加到 unmanaged-devices 中。"
    fi
fi

# 检查并删除 system-connections 中的对应文件
# if [ -d "$CONNECTIONS_DIR" ]; then
#     CONNECTION_FILES=$(grep -rl "interface-name=$INTERFACE" "$CONNECTIONS_DIR")
#     if [ -n "$CONNECTION_FILES" ]; then
#         echo "找到以下包含 interface-name=$INTERFACE 的配置文件："
#         echo "$CONNECTION_FILES"

#         # 删除所有匹配的文件
#         for FILE in $CONNECTION_FILES; do
#             echo "删除文件 $FILE"
#             rm -f "$FILE"
#         done

#         # 重启 NetworkManager 服务以清除缓存
#         # echo "重启 NetworkManager 以应用更改..."
#         # systemctl restart NetworkManager
#     else
#         echo "未在 $CONNECTIONS_DIR 中找到配置 interface-name=$INTERFACE 的文件。"
#     fi
# else
#     echo "$CONNECTIONS_DIR 目录不存在，跳过删除检查。"
# fi

# 读取网关地址，文件不存在时创建并写入默认值192.168.10.1
if [ -f "$gateway_file" ]; then
    ap_gateway=$(cat "$gateway_file" | tr -d '[:space:]')
else
    echo "$default_gateway" | sudo tee "$gateway_file" > /dev/null
    ap_gateway="$default_gateway"
fi

# 根据网关地址计算 start_addr 和 end_addr
network_prefix=$(echo "$ap_gateway" | awk -F'.' '{print $1"."$2"."$3}')
ap_start_addr="${network_prefix}.89"
ap_end_addr="${network_prefix}.240"

# sudo usbreset 0bda:c811
# sleep 5

# 写入 hostapd 配置文件
sudo tee "$hostapd_config" > /dev/null <<EOF
ctrl_interface=/var/run/hostapd
interface=$usb_card
country_code=CN
driver=nl80211
ssid=$ssid_name
hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=1
#ht_capab=[HT40+][SHORT-GI-40]

# 启用 WPA2-PSK 加密
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP

# 设置 Wi-Fi 密码
wpa_passphrase=$ap_passwd
EOF

echo "Hostapd 配置文件已更新，SSID 设置为: $ssid_name"

echo "设置 $usb_card"
sudo ifconfig $usb_card 0.0.0.0
sudo ip link set $usb_card up
sudo ip addr add $ap_gateway/24 dev $usb_card

echo "设置 udhcpd"

sudo tee "$udhcpd_config" > /dev/null <<EOF
# The start and end of the IP lease block
start           $ap_start_addr
end             $ap_end_addr

# The interface that udhcpd will use
interface       $usb_card

opt     dns     114.114.114.114
option  subnet  255.255.255.0
opt     router  $ap_gateway
option  domain  local
option  lease   864000            # 10 days in seconds
EOF

sudo udhcpd -S $udhcpd_config &

echo "开启热点，配置文件: $hostapd_config"
sudo hostapd $hostapd_config
