#!/bin/bash

systemctl disable ModemManager.service
rm -rf /lib/systemd/system/ModemManager.service
echo "Remove ModemManager success"

exit 0
