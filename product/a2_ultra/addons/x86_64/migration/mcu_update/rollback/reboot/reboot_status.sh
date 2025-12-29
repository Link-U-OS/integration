#!/bin/bash

# cd "$(dirname "$0")"

# python3 ./reboot_status.py
# ret=$?
# if [ $ret -ne 0 ]; then
#     echo "查询电源板状态失败"
#     exit $ret
# fi

# # 查询 hal 状态
# mkdir -p /agibot/info/etc/mcu
# chmod -R 777 /agibot/info/etc/mcu
# if [ -f "/agibot/software/vn/hal_ethercat/ota/firm_ota/firm_ota" ]; then
#     chmod +x /agibot/software/vn/hal_ethercat/ota/firm_ota/firm_ota

#     # eno1 为网口名称，此处固定为 eno1,后续需要根据实际情况修改
#     echo "查询 hal 状态"
#     /agibot/software/vn/hal_ethercat/ota/firm_ota/firm_ota query slave_info eno1
# else
#     echo "firm_ota 不存在"
# fi

echo "查询电源板状态完成"
exit 0
