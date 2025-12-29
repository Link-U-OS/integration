#!/bin/bash

# replace xinitrc to fix unexpected screen blank

set -e

cd $(dirname $0)

target_file=/etc/X11/xinit/xinitrc
source_file=./display/xinitrc

if [ ! -f $source_file ]; then
    echo "xinitrc not existed"
    exit 0
fi

if ! diff -q $source_file $target_file; then
    echo "replace xinitrc"
    rm -rf $target_file
    cp $source_file $target_file
fi

echo "replace xinitrc done"

sync

exit 0
