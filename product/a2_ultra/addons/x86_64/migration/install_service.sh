#!/bin/bash

cd $(dirname $0)

echo "执行目录: $(dirname $0)"

declare -i last_return_code=0
# 获取 service_update 目录下的所有 .py 和 .sh 文件，并执行
while read -r file; do
    echo "执行文件: $file"
    # 如果文件是 .py 文件，则执行 python3 命令
    if [ "${file##*.}" == "py" ]; then
        python3 "$file"
        return_code=$?
    else
        bash "$file"
        return_code=$?
    fi

    if [ $return_code -ne 0 ]; then
        echo "执行文件: $file 失败, 返回码: $return_code"
        last_return_code=$return_code
        break
    fi
done < <(find ./service_update -maxdepth 1 -name "*.py" -o -name "*.sh")

if [ $last_return_code -ne 0 ]; then
    echo "执行失败"
else
    echo "执行完成"
fi

exit $last_return_code