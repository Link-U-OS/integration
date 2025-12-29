import datetime
import os
import re
import subprocess
import time
from pathlib import Path

def get_current_script_path():
    return os.path.dirname(os.path.abspath(__file__))


def get_ota_elink_tools_path():
    return os.path.join(
        get_current_script_path(), "../../bin/multiplex_link_a2_ota"
    )

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
    elink_path = get_ota_elink_tools_path()
    elink_path = Path(elink_path).resolve()
    code, _ = execute_bash_command(f"chmod +x {elink_path}")
    if code != 0:
        print("无法设置权限，无法执行脚本")
        return [-1, None]

    code, info = execute_bash_command(f"{elink_path} reboot_ipc 1011")
    print(f"{elink_path} reboot_ipc 1011")
    if code != 0:
        return -1
    return 0


if __name__ == "__main__":
    import sys
    retry_count = 3
    cnt =1
    is_ok = False
    while cnt <= retry_count:
        if reboot_ipc() != 0:
            print(f"工控机重启失败{cnt}次,正在重试,请稍等......")
            cnt+=1
            time.sleep(5)
            continue
        else:
            is_ok = True
            break
    if is_ok != True:
        print("工控机重启失败")
        sys.exit(-1)
    sys.exit(0)