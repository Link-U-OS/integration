#!/bin/bash

# cd to this script's directory
cd $(dirname $0)

source ./function.sh

echo "$service_list" | tr ' ' '\n' | tac | while IFS= read -r service; do
    if [[ $service == *.service ]]; then
        echo "正在卸载服务: $service"
        uninstall_service "$service"
    else
        echo "跳过非服务条目: $service"
    fi
done

echo "Uninstallation process completed. The service will be restarted with the new version upon system reboot."

exit 0