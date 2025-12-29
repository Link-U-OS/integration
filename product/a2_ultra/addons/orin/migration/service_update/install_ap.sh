#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
echo $script_dir

sudo sh $script_dir/ap/install.sh

echo "install ap end"

exit 0
