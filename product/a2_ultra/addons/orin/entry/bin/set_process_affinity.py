#!/usr/bin/env python3
import subprocess
import time

# 多进程配置表
PROCESS_CONFIG = {
    # 平台组
    "./hal_d415": {"nice": -5, "cpus": "11"},
    "./tzcamera": {"nice": -20, "cpus": "8"},
    "./mid360lidar": {"nice": -5, "cpus": "11"},
    "/agibot/software/v0/bin/iox-roudi": {"nice": -10, "cpus": "11"},
    "ptp4l": {"nice": -5, "cpus": "8,11"},
}

# 线程单独覆盖配置，高优先级
# 格式: PID/进程名 -> {线程名或TID: {"nice": ..., "cpus": ...}}
THREAD_OVERRIDE_CONFIG = {
    "./agent": {
        "face_thread": {"nice": -20, "cpus": "4"},  # 单线程覆盖
        "mouth_thread": {"nice": -20, "cpus": "4"},  # 单线程覆盖
        "iflytek_cap": {"nice": -20, "cpus": "4"},  # 单线程覆盖
    },
}

def get_exact_pids(executable):
    """获取命令行第一字段为 executable 的所有 PID"""
    pids = []
    try:
        result = subprocess.run(
            ["ps", "-eo", "pid,args"],
            capture_output=True, text=True, check=True
        )
        for line in result.stdout.splitlines()[1:]:
            parts = line.split()
            if len(parts) < 2:
                continue
            pid, *args = parts
            if args[0] == executable:
                pids.append(int(pid))
        return pids
    except Exception as e:
        print(f"Error: {e}")
        return []

def set_threads_properties(pid, default_nice, default_cpus, override_threads=None):
    """
    设置线程的 nice 和 CPU 亲和度
    override_threads: dict {线程名: {"nice":..., "cpus":...}}, 优先级高于默认
    """
    try:
        # 只列出指定 PID 的线程
        result = subprocess.run(
            ["ps", "-L", "-p", str(pid), "-o", "pid,lwp,comm"],
            capture_output=True, text=True, check=True
        )
        lines = result.stdout.strip().splitlines()
        if len(lines) <= 1:
            print(f"[WARN] No threads found for PID {pid}")
            return
        
        for line in lines[1:]:  # 跳过表头
            parts = line.split()
            if len(parts) < 3:
                continue
            proc_pid, tid, tname = parts
            # 优先使用线程覆盖配置
            if override_threads and tname in override_threads:
                nice_value = override_threads[tname]["nice"]
                cpu_mask = override_threads[tname]["cpus"]
            else:
                nice_value = default_nice
                cpu_mask = default_cpus

            # 设置线程优先级
            subprocess.run(["renice", "-n", str(nice_value), "-p", tid], capture_output=True)
            # 设置线程 CPU 亲和度
            subprocess.run(["taskset", "-pc", cpu_mask, tid], capture_output=True)

            print(f"[INFO] Set thread '{tname}' (TID {tid}) "
                  f"nice={nice_value} cpus={cpu_mask}")

    except Exception as e:
        print(f"Error setting properties for PID {pid}: {e}")

if __name__ == "__main__":
    while True:
        for proc_name, cfg in PROCESS_CONFIG.items():
            pids = get_exact_pids(proc_name)
            if not pids:
                print(f"[WARN] Process '{proc_name}' not found.")
                continue
            thread_override = THREAD_OVERRIDE_CONFIG.get(proc_name)
            for pid in pids:
                set_threads_properties(pid, cfg["nice"], cfg["cpus"], thread_override)
        time.sleep(30)
