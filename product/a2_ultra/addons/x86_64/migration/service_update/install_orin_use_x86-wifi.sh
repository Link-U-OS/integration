#!/usr/bin/env bash

echo "install orin use x86 wifi service start ..."
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
echo $script_dir

sudo sh $script_dir/orin_use_x86-wifi/install.sh

echo "install orin use x86 wifi service  end"

exit 0
