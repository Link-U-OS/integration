#!/bin/bash

# 修改 logind.conf 文件
# @yangteng 需求

set -e

cd $(dirname $0)

target_file=/etc/systemd/logind.conf
source_file=./logind/logind.conf

echo "检查 logind.conf 文件是否存在"
if [ ! -f $source_file ]; then
    echo "logind.conf 文件不存在"
    exit 0
fi

# 对比两个文件，如果不同则拷贝
if ! diff -q $source_file $target_file; then
    echo "logind.conf 文件不同，拷贝到 /etc/systemd/logind.conf"
    rm -rf $target_file
    cp $source_file $target_file
fi

echo "拷贝完成"

sync

exit 0
