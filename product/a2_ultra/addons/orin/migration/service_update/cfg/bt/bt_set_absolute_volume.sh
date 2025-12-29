#!/usr/bin/env bash
# set-volume.sh  —— 按百分比修改当前真正发声 / 默认 sink 的音量
# 用法:  ./set-volume.sh 72         # 把音量调到 72%

set -euo pipefail

# ---------- 参数检查 ----------
if [[ $# -ne 1 || ! "$1" =~ ^[0-9]+$ ]]; then
    echo "用法: $0 <0-100 的整数>" >&2
    exit 1
fi

volume="$1"
if (( volume < 0 || volume > 100 )); then
    echo "错误：音量必须在 0~100 之间" >&2
    exit 1
fi

# ---------- 功能函数 ----------
# 获取当前真正在“跑”音频流的 sink id，如果没有任何播放则返回空
get_playing_sink() {
    pactl list sink-inputs short | awk '/RUNNING/ {print $2}' | head -n1
}

# 获取系统默认 sink 的 id
get_default_sink() {
    pactl get-default-sink
}

# 根据 id 设置音量
set_sink_volume() {
    local sink_id="$1"
    local pct="$2"
    pactl set-sink-volume "$sink_id" "${pct}%"
}

# ---------- 主逻辑 ----------
playing_sink=$(get_playing_sink)
if [[ -n "$playing_sink" ]]; then
    target_sink="$playing_sink"
    echo "正在播放音频的 sink: $target_sink"
else
    target_sink=$(get_default_sink)
    echo "当前无播放流，将设置默认 sink: $target_sink"
fi

set_sink_volume "$target_sink" "$volume"
echo "已将 $target_sink 音量设为 $volume%"
