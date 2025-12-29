#!/usr/bin/env python3
import requests
import subprocess
import csv
import re
import os
from collections import defaultdict
from datetime import datetime

URLS = [
    "http://127.0.0.1:50080/json/get_all_apps_info",
]

# 获取脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 获取当前系统时间作为文件后缀
RUN_TIME = datetime.now().strftime("%Y%m%d_%H%M%S")

def run_cmd(cmd):
    try:
        result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=5)
        return result.stdout.strip()
    except Exception:
        return ""

def get_main_pid(pid):
    output = run_cmd(f"pstree -p {pid}")
    if not output:
        return pid
    first_line = output.splitlines()[0]
    pids = re.findall(r"\((\d+)\)", first_line)
    if len(pids) >= 2:
        return pids[-2]
    else:
        return pid

def get_thread_tids(pid):
    tids = set()
    main_pid = get_main_pid(pid)
    tids.add(main_pid)

    pstree_output = run_cmd(f"pstree -p {pid} 2>/dev/null")
    thread_tids = re.findall(r"\{[^}]+\}\((\d+)\)", pstree_output)

    for tid in thread_tids:
        tids.add(tid)

    return sorted(tids, key=int)

def get_thread_name(tid):
    try:
        with open(f"/proc/{tid}/status", "r") as f:
            for line in f:
                if line.startswith("Name:"):
                    return line.split()[1]
    except Exception:
        return "N/A"
    return "N/A"

def get_cpu_affinity(tid):
    output = run_cmd(f"taskset -cp {tid}")
    if not output:
        return "N/A"
    return output.split(":", 1)[-1].strip()

def get_main_thread_nice(main_pid):
    output = run_cmd(f"ps -o ni= -p {main_pid}")
    if output:
        return output.strip()
    return "N/A"

def main():
    data = None
    for url in URLS:
        print(f"尝试访问 {url} ...")
        try:
            resp = requests.get(url, timeout=5)
            resp.raise_for_status()
            data = resp.json()
            print(f"成功从 {url} 获取数据。")
            break
        except Exception as e:
            print(f"访问 {url} 失败: {e}")

    if data is None:
        print("所有URL均无法获取数据，退出。")
        return

    # 使用时间戳命名文件
    detailed_csv = os.path.join(SCRIPT_DIR, f"threads_affinity_{RUN_TIME}.csv")
    summary_csv = os.path.join(SCRIPT_DIR, f"process_affinity_{RUN_TIME}.csv")

    process_info_map = defaultdict(lambda: {"cpu": set(), "nice": set()})

    # 写详细表
    with open(detailed_csv, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile, delimiter="\t")
        writer.writerow(["process_name", "thread_name", "cpu_affinity", "nice"])

        for proc_name, info in data.get("data", {}).items():
            pid = info.get("pid", -1)
            if pid == -1:
                continue
            print(f"正在处理进程: {proc_name} (PID={pid})")

            main_pid = get_main_pid(pid)
            nice_value = get_main_thread_nice(main_pid)

            tids = get_thread_tids(pid)
            for tid in tids:
                thread_name = get_thread_name(tid)
                cpu_affinity = get_cpu_affinity(tid)
                writer.writerow([proc_name, thread_name, cpu_affinity, nice_value])

                if cpu_affinity != "N/A":
                    process_info_map[proc_name]["cpu"].add(cpu_affinity)
                if nice_value != "N/A":
                    process_info_map[proc_name]["nice"].add(nice_value)

    # 写汇总表
    with open(summary_csv, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile, delimiter="\t")
        writer.writerow(["process_name", "cpu_affinity_summary", "nice_summary"])
        for proc_name, info in process_info_map.items():
            cpu_combined = ",".join(sorted(info["cpu"]))
            nice_combined = ",".join(sorted(info["nice"]))
            writer.writerow([proc_name, cpu_combined, nice_combined])

    print(f"完成，详细线程表保存在 {detailed_csv}")
    print(f"汇总表保存在 {summary_csv}")

if __name__ == "__main__":
    main()
