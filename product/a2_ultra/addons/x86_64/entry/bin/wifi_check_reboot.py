#/usr/bin/env python3
import os
import json
import subprocess
import time
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

WIFI_CHECK_SCRIPT = os.path.join(SCRIPT_DIR, "check_wifi_x86.sh")
REBOOT_SCRIPT = os.path.join(SCRIPT_DIR, "reboot_ipc.sh")

REBOOT_JSON_PATH = "/agibot/log/em/last_reboot.json"
MAX_INTERVAL_SECONDS = (8) * 60  # 10 minutes

def run_script(script_path):
    """运行 shell 脚本并返回 exit code"""
    try:
        result = subprocess.run(["bash", script_path], check=False)
        return result.returncode
    except Exception as e:
        print(f"Error running {script_path}: {e}")
        return -1

def execute_bash_command(command):
    try:
        # 使用 subprocess.run 执行命令
        result = subprocess.run(
            command,  # 命令字符串
            shell=True,  # 使用 shell 执行
            check=True,  # 如果命令失败会抛出 CalledProcessError
            text=False,  # 以字符串形式处理输出
            stdout=subprocess.PIPE,  # 捕获 stdout
            stderr=subprocess.PIPE,  # 捕获 stderr
        )
        # 打印 stdout 和 stderr
        if result.stdout:
            print(result.stdout.strip())
        if result.stderr:
            print(result.stderr.strip())

        # 把 stdout 和 stderr 转换为字符串
        stdout_str = result.stdout.decode("utf-8", errors="ignore")
        stderr_str = result.stderr.decode("utf-8", errors="ignore")
        print(f"stdout_str: {stdout_str}")
        print(f"stderr_str: {stderr_str}")

        return [result.returncode, stdout_str]
    except subprocess.CalledProcessError as e:
        # 打印错误输出
        if e.stdout:
            print(e.stdout.strip())
        if e.stderr:
            print(e.stderr.strip())
        return [e.returncode, None]

def reboot_ipc():
    """执行重启工控机脚本"""
    time.sleep(10)
    print("Rebooting ipc...")
    code = run_script(REBOOT_SCRIPT)
    if code != 0:
       return -1
    return 0 

def get_time_cnt():
    with open(REBOOT_JSON_PATH, 'r') as f:
        data = json.load(f)
        if "last_reboot_time" not in data:
            print("Invalid reboot.json format(last_reboot_time). Exiting.")
            return [None,None]
        if "count" not in data:
            print("Invalid reboot.json format(count). Exiting.")
            return [None,None]
        
        last_time_str = data.get("last_reboot_time")
        last_cnt = data.get("count")
        cnt = last_cnt
        last_time = datetime.fromisoformat(last_time_str)
    return [cnt,last_time]

def update_reboot_json(timestamp,cnt):
    """更新 reboot.json 中的时间为当前时间,更新count"""
    os.makedirs(os.path.dirname(REBOOT_JSON_PATH), exist_ok=True)
    with open(REBOOT_JSON_PATH, 'w') as f:
        json.dump({"last_reboot_time": timestamp.isoformat(), "count": cnt}, f)

def main():
    time.sleep(10)
    if not os.path.exists(WIFI_CHECK_SCRIPT):
        print(f"WiFi check script not found: {WIFI_CHECK_SCRIPT}")
        exit(0)

    retry_cnt = 3
    cnt = 0
    current_time = datetime.now()
    if not os.path.exists(REBOOT_JSON_PATH):
        # 文件不存在，写入当前时间和cnt
        update_reboot_json(current_time,cnt)
        # 执行 wifi_check.sh
        if run_script(WIFI_CHECK_SCRIPT) != 0:
            #wifi检查失败，重启工控机
            cnt+=1
            update_reboot_json(current_time,cnt)
            if reboot_ipc() != 0:
                exit(1)
        else:
            #wifi检查成功
            print("WiFi check passed.")
            #更新时间和重置cnt
            update_reboot_json(current_time,0)
            exit(0)
    else:
        # 文件存在，读取上次时间
        cnt,last_time = get_time_cnt()
        if cnt == None:
            exit(-1)
        delta = current_time - last_time
        print(f"delta:{delta.seconds},MAX_INTERVAL_SECONDS:{MAX_INTERVAL_SECONDS}")

        if (delta.seconds <  MAX_INTERVAL_SECONDS) & (cnt >= retry_cnt):
            current_time = datetime.now()
            update_reboot_json(last_time,cnt)
            print(f"Reached the maximum number of retries:{retry_cnt}")
            exit(1)
        elif (delta.seconds >= MAX_INTERVAL_SECONDS) & (cnt >= retry_cnt):
            current_time = datetime.now()
            # 执行 wifi_check.sh
            if run_script(WIFI_CHECK_SCRIPT) != 0:
                print("check wifi failed")
                update_reboot_json(current_time,1)
                if reboot_ipc() !=0:
                    exit(1)
            else:
                print("WiFi check passed.")
                update_reboot_json(current_time,0)
                exit(0)
        elif (delta.seconds <  MAX_INTERVAL_SECONDS) & (cnt < retry_cnt):
            current_time = datetime.now()
            # 执行 wifi_check.sh
            if run_script(WIFI_CHECK_SCRIPT) != 0:
                print("check wifi failed")
                cnt+=1
                update_reboot_json(current_time,cnt)
                if reboot_ipc() !=0:
                    exit(1)
            else:
                print("WiFi check passed.")
                update_reboot_json(current_time,0)
                exit(0)
        elif (delta.seconds >= MAX_INTERVAL_SECONDS) & (cnt < retry_cnt):
            current_time = datetime.now()
            # 执行 wifi_check.sh
            if run_script(WIFI_CHECK_SCRIPT) != 0:
                print("check wifi failed")
                update_reboot_json(current_time,1)
                if reboot_ipc() !=0:
                    exit(1)
            else:
                print("WiFi check passed.")
                update_reboot_json(current_time,0)
                exit(0)


if __name__ == "__main__":
    main()