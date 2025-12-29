#!/bin/bash

file="/etc/profile"

# 检查文件是否存在
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    continue
fi

# 使用 sed 注释符合条件的行
sed -Ei.bak '/^[[:space:]]*pactl set-sink-volume/ {
    /^[[:space:]]*#/! s/^([[:space:]]*)(pactl set-sink-volume.*)/\1#\2/
}' "$file"

echo "Processed: $file (backup saved as $file.bak)"