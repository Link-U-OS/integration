#!/bin/bash
# disable-bt-services.sh
CONF="/etc/bluetooth/main.conf"
TMP=$(mktemp)

# 需要禁用的插件列表
PLUGINS="ftp,opp,obex,pan"

[[ -f "$CONF" ]] || touch "$CONF"

# 获取现有行并清理空格和大小写
existing=$(grep -i '^[[:space:]]*DisablePlugins[[:space:]]*=' "$CONF" \
           | sed -E 's/.*=[[:space:]]*//;s/[[:space:]]*,[[:space:]]*/,/g;s/^,//;s/,$//' \
           | tr '[:upper:]' '[:lower:]')

# 将现有与待禁用合并去重
IFS=',' read -ra CUR <<<"${existing:-}"
mapfile -t LIST <<<"$(IFS=$'\n'; echo -e "${CUR[*]}\n${PLUGINS//,/$'\n'}" | sort -fu | grep -v '^$')"
NEW=$(IFS=','; echo "${LIST[*]}")

if [[ "${existing}" != "${NEW}" ]]; then
    awk -v new="DisablePlugins = ${NEW}" '
        BEGIN{IGNORECASE=1}
        /^[[:space:]]*DisablePlugins[[:space:]]*=/ {print new; found=1; next}
        {print}
        END{if(!found) print new}
    ' "$CONF" > "$TMP"
    cat "$TMP" > "$CONF"
    rm -f "$TMP"
    systemctl restart bluetooth.service
    echo "updated: DisablePlugins = ${NEW}"
else
    echo "no change required"
fi
