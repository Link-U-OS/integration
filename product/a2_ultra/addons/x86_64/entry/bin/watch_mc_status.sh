#!/usr/bin/env bash
# watch_motion.sh
# 等待 motion_control 启动，内存 >5G 时 gcore 并退出

PROG="motion_control"
MAX_MB=$((2*1024))          # 5 GB 换成 MB 单位
SAMPLE_SEC=2                # top 采样间隔
PERF_TOOL="/agibot/software/v0/entry/bin/perf_x86"

# 等待进程出现
while :; do
    PID=$(pidof "$PROG" | awk '{print $1}')   # 只取第一个 pid
    [[ -n $PID ]] && break
    echo "[$PROG] 未启动，等待 3 秒 ..."
    sleep 3
done
echo "检测到 $PROG 已启动，PID=$PID"

# 开始监控内存
while kill -0 "$PID" 2>/dev/null; do
    # top 取一次 RES 字段（单位 KB），awk 过滤当前 PID
    MEM_KB=$(top -b -n1 -p "$PID" | awk -v p="$PID" '$1==p {print $6}')
    # 如果 top 没抓到，sleep 后继续
    [[ -z $MEM_KB ]] && { sleep "$SAMPLE_SEC"; continue; }

    MEM_MB=$((MEM_KB / 1024))
    echo "$(date '+%F %T')  PID=$PID  RES=${MEM_MB}MB"

    if (( MEM_MB >= MAX_MB )); then
        DUMP_FILE_GCORE="/agibot/log/mc/$(date +%Y%m%d_%H%M%S)_${PROG}_${PID}.core"
        DUMP_FILE_PERF="/agibot/log/mc/$(date +%Y%m%d_%H%M%S)_${PROG}_${PID}.perf"

        "$PERF_TOOL" record -F 99 -p "$PID" -g -o "$DUMP_FILE_PERF" -- sleep 10

        echo "内存超限 (${MEM_MB}MB >= ${MAX_MB}MB)，开始 gcore ..."
        gcore -o "$DUMP_FILE_GCORE" "$PID"
        echo "core 已生成：${DUMP_FILE}，脚本退出"
        exit 0
    fi

    sleep "$SAMPLE_SEC"
done

echo "进程 $PID 已退出，脚本结束"