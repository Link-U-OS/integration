#!/bin/bash

# 捕获网络数据包目录路径
OUTPUT_DIR="/agibot/data/net/tcp_dump"
# 文件命名格式
FILENAME="capture-$(date +%Y%m%d%H%M%S).pcap"
OUTPUT_FILE="$OUTPUT_DIR/$FILENAME"

# 日志文件
LOG_FILE="/agibot/data/net/tcp_dump/tcpdump.log"

# 确保目标目录存在
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Directory $OUTPUT_DIR does not exist. Creating it..." | tee -a "$LOG_FILE"
    sudo mkdir -p "$OUTPUT_DIR"
fi

# 检查是否已有相同功能的 tcpdump 进程在运行
if pgrep -f "tcpdump -i eno1" > /dev/null; then
    echo "tcpdump is already running. Exiting." | tee -a "$LOG_FILE"
fi

# 删除 OUTPUT_DIR 目录下，两天前的文件
find "$OUTPUT_DIR" -type f -mtime +2 -exec rm {} \;

# 捕获网络数据包并写入文件
echo "Starting tcpdump to capture network packets..." | tee -a "$LOG_FILE"
sudo tcpdump -i "${NET_IF_ETHERCAT}" -C 10 -W 50 -w "$OUTPUT_FILE" -Z $USER &