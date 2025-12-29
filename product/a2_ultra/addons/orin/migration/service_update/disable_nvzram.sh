#!/bin/bash
###
 # @Descripttion: disable nvzramconfig service
###
echo "disable nvzramconfig service"
if [ -f "/etc/systemd/system/multi-user.target.wants/nvzramconfig.service" ]; then
    sudo systemctl disable nvzramconfig.service
fi

echo "disable nvzramconfig service done, need restart"

