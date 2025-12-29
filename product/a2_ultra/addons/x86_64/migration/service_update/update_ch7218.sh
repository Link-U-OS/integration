#!/bin/bash

CMD='sudo ./ch7218_fwu -f ./CH7218A-IMG.G62FA.07.08.19.IMG.img'
max_retry=3
retry=0

check_version()
{
    VERSION=$(sudo ./ch7218_fwu -v | grep "FW Version" | sed -n 's/.*: \(.*\)/\1/p' | tr -d ' \n\r')
    if [ -z $VERSION ]; then
        echo "Failed to get CH7218 chp FW version"
        exit 0
    elif [ "$VERSION" = "07:08:18" ]; then
        echo "Current FW version 07:08:18, Start to Upgrade..."
    else
        echo "No OTA action for FW version $VERSION"
        exit 0
    fi
}

update_fw()
{
    while (( retry < max_retry )); do
        if eval "$CMD"; then
            echo "[OK] Firmware update succeeded."
            exit 0
        else
            ((retry++))
            echo "[WARN] Attempt $retry failed, retrying in 2s..."
            sleep 2
        fi
    done
}

cd $(dirname $0)/ch7218

check_version
update_fw

echo "[ERROR] Firmware update failed after $max_retry attempts."
exit 1