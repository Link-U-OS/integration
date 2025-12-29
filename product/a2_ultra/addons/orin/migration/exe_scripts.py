import os
import subprocess
import sys
from datetime import datetime


def log_message(message):
    """
    打印日志到终端，带有时间戳。

    :param message: 要打印的日志信息
    """
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted_message = f"[{timestamp}] {message}"
    print(formatted_message)


def get_dir_list_with_agibot_home(dir_list):
    """
    根据环境变量 AGIBOT_HOME 动态构造 dir_list。
    如果 AGIBOT_HOME 存在且非空，则在每个目录前添加 AGIBOT_HOME 的值。
    如果 AGIBOT_HOME 为空，则返回原始的 dir_list。

    :param dir_list: 原始目录列表
    :return: 动态生成的目录列表
    """
    agibot_home = os.getenv("AGIBOT_HOME", "").strip()
    if agibot_home:
        log_message(f"AGIBOT_HOME is set to: {agibot_home}")
        return [os.path.join(agibot_home, directory) for directory in dir_list]
    else:
        log_message("AGIBOT_HOME is not set or empty.")
        return dir_list


def execute_files(dir_list, suffix=""):
    """
    按顺序查找和执行指定目录列表中的 .sh 和 .py 文件。
    如果任何脚本返回值不为0，则直接退出并返回 exit(1)。

    :param dir_list: 目录列表
    :param suffix: 在目录后附加的后缀（如 "check" 或 "end"）
    """
    for directory in dir_list:
        # 构造实际目录路径
        target_dir = os.path.join(directory, suffix) if suffix else directory

        # 检查目录是否存在
        if not os.path.isdir(target_dir):
            log_message(f"Directory not found: {target_dir}")
            continue

        log_message(f"Processing directory: {target_dir}")

        # 查找 .sh 和 .py 文件
        for file_name in os.listdir(target_dir):
            file_path = os.path.join(target_dir, file_name)
            if os.path.isfile(file_path):
                if file_name.endswith(".sh"):
                    log_message(f"Executing bash script: {file_path}")
                    result = subprocess.run(["bash", file_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                elif file_name.endswith(".py"):
                    log_message(f"Executing Python script: {file_path}")
                    result = subprocess.run(["python3", file_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                else:
                    continue

                # 记录脚本执行结果
                if result.returncode == 0:
                    log_message(f"Success: {file_path}")
                    log_message(result.stdout.decode("utf-8").strip())
                else:
                    log_message(f"Error: {file_path}, Return Code: {result.returncode}")
                    log_message(result.stderr.decode("utf-8").strip())
                    sys.exit(1)


def main():
    # 原始目录列表
    original_dir_list = [
    "/agibot/data/ota/firmware/vn/migration/" + sub_dir
    for sub_dir in [
        "data_module_migration",
        "third_party_library_update",
        ]
    ]

    # 根据 AGIBOT_HOME 动态构造目录列表
    dir_list = get_dir_list_with_agibot_home(original_dir_list)

    # 第一轮执行原始目录
    log_message("==== Executing original directories ====")
    execute_files(dir_list)

    # 第二轮执行 dir + check
    log_message("==== Executing directories with 'check' suffix ====")
    execute_files(dir_list, suffix="check")

    # 第三轮执行 dir + end
    log_message("==== Executing directories with 'end' suffix ====")
    execute_files(dir_list, suffix="end")

    log_message("All tasks completed successfully.")


if __name__ == "__main__":
    main()
