#!/usr/bin/env bash
set -euo pipefail

# --- 第 1 步：找真正有声音输出的 sink 号
# 从所有 sink-input 中收集它们所属的 sink 编号，取第 1 个（如有多个，只取其一）
sink_id=$(pactl list sink-inputs | awk '/Sink:/{print $2; exit}')

# 如果没有播放流，则退回到 DEFAULT_SINK
if [[ -z $sink_id ]]; then
    sink_id=$(pactl get-default-sink)
fi

# --- 第 2 步：获取该 sink 的音量百分比
volume=$(pactl get-sink-volume "$sink_id" \
         | awk -F'/' '/front-left:/ {print $2}' \
         | tr -d '[:space:]')

echo "active sink: $sink_id"
echo "volume: $volume"
