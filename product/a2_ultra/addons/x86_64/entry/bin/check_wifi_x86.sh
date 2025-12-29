#!/bin/bash
# check_wifi_x86.sh

IFACE="wifi_x86"

for ((i=0; i<30; i++)); do
    if ifconfig "$IFACE" >/dev/null 2>&1; then
        echo "$IFACE is loaded"
        exit 0
    fi
    sleep 1
done

echo "$IFACE not found within 30 seconds."
exit 1