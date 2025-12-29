#!/usr/bin/env bash
# vol_relative.sh  <+/-百分比>
# 例：./vol_relative.sh  +10
#     ./vol_relative.sh  -5

set -euo pipefail

usage() {
    echo "usage: $0 <+/-percentage>"
    echo "demo:  $0 +10   # turn up 10%"
    echo "       $0 -5    # turn down 5%"
    exit 1
}

[[ $# -eq 1 ]] || usage
rel="$1"
[[ $rel =~ ^[+-][0-9]+$ ]] || usage

# 1. 找到“真正有声音输出的 sink”
sink_id=$(pactl list sink-inputs 2>/dev/null | awk '/Sink:/{print $2; exit}')
# 如果没有播放流，则退回到 DEFAULT_SINK
if [[ -z $sink_id ]]; then
    sink_id=$(pactl get-default-sink)
fi

# 2. 相对调整音量
pactl set-sink-volume "$sink_id" "${rel}%"

# 3. 可选：回显新的音量值（左声道）
new_vol=$(pactl get-sink-volume "$sink_id" \
          | awk -F'/' '/front-left:/ {print $2}' \
          | tr -d '[:space:]')
echo "volume of sink $sink_id is turned to $new_vol"
