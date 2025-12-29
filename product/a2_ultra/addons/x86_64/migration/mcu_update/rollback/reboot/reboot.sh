#!/bin/bash

cd "$(dirname "$0")"

echo "开始升级电源板"
# 正常情况下，不会退出，30m 内直接重启了
timeout -s SIGKILL 30m python3 ./reboot.py
ret=$?

echo "返回值: $ret"

# timeout 命令返回值:
# 124 - 超时且 TERM 信号终止进程
# 137 - 超时且 KILL 信号终止进程
# 0 - 正常退出
# 其他 - 程序自身返回值
if [ $ret -eq 124 ] || [ $ret -eq 137 ]; then
    echo "升级电源板超时"
    exit 1
fi

if [ $ret -ne 0 ]; then
    echo "升级电源板失败"
    exit $ret
fi

echo "升级电源板完成"
echo $ret
