import os
import sys
# 禁止生成 __pycache__ 字节码文件
sys.dont_write_bytecode = True

import re
import time
import signal
import logging
import threading
import subprocess
from datetime import datetime

from master_em_rpc_client import  RpcStatus
from master_em_rpc_client import  call_xmlrpc_with_enum

# 配置常量
LOG_DIR = "/agibot/log/process_manager"
LOG_FILE_NAME = "em_daemon.log"
PING_LOG_FILE_NAME = "em_ping.log"
PACKAGE_YAML_FILE = "/agibot/software/v0/metadata.yaml"

# 判断对端启动的时间阈值3min
remote_boot_sec_max = 180

# TODO, 适配多个slave em节点的情况, 如 A3
rpc_host = "127.0.0.1"
rpc_port = 8080
running = True

logging_main = None
logging_ping = None
max_log_file_num = 50

# 存储 process_manager 进程对象
em_server_process = None

# 全局变量及线程安全控制
em_server_rpc_call_success = False           # 用于判断start_em_server 是否调用成功
var_lock = threading.Lock()                  # 保证全局变量 em_server_rpc_call_success 的线程安全

process_start_time = time.time()             # 记录进程启动时间
em_server_rcp_call_success_timeout = 300     # process_manager rpc 调用的超时时间: 300s


def ensure_log_directory():
    """确保日志目录存在"""
    try:
        if not os.path.exists(LOG_DIR):
            os.makedirs(LOG_DIR)
            print(f"创建日志目录: {LOG_DIR}")
    except Exception as e:
        print(f"创建日志目录失败: {e}")
        sys.exit(1)

def create_log_file(file_name):
    file_path = f"{LOG_DIR}/{file_name}"
    if os.path.exists(file_path):
        # 获取源文件的创建时间
        creation_time = os.path.getctime(file_path)
        timestamp = datetime.fromtimestamp(creation_time).strftime("%Y%m%d_%H_%M_%S")
        new_filename = f"{file_path}_{timestamp}"

        # 重命名现有文件
        os.rename(file_path, new_filename)
        cleanup_old_files(file_name)

    """配置日志系统"""
    logger = logging.getLogger(file_name)
    logger.setLevel(logging.INFO)

    # 避免重复添加 handler
    if logger.hasHandlers():
        logger.handlers.clear()

    handler = logging.FileHandler(file_path, encoding='utf-8')
    fmt = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    handler.setFormatter(fmt)
    logger.addHandler(handler)

    # 阻止日志向上传播到 root，确保互不干扰
    logger.propagate = False
    return logger


# 正则匹配时间戳
timestamp_pattern = re.compile(r'_(\d{8}_\d{2}_\d{2}_\d{2})(?:\.|$)')

def cleanup_old_files(file_name):
    files = [f for f in os.listdir(LOG_DIR) if f.startswith(f"{file_name}_")]

    # 按时间戳排序（旧 → 新）
    files.sort(key=lambda x: datetime.strptime(
        timestamp_pattern.search(x).group(1), "%Y%m%d_%H_%M_%S"))

    for i in range(max(0, len(files) - max_log_file_num)):
        oldest_file = files[i]
        os.remove(f"{LOG_DIR}/{oldest_file}")


def start_local_em_server():
    """启动 process_manager 并输出日志"""
    global em_server_process
    if em_server_process is None or em_server_process.poll() is not None:
        agibot_home = os.environ.get('AGIBOT_HOME')
        if not agibot_home:
            agibot_home = ""
        cmd = [
            "/agibot/software/v0/scripts/process_manager/start_process_manager.sh"
        ]
        try:
            # 启动 process_manager 并将标准输出和标准错误输出重定向到终端
            em_server_process = subprocess.Popen(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            logging_main.info("local start em_server success...")
            return "process_manager started successfully."
        except Exception as e:
            return f"Failed to start process_manager: {str(e)}"
    else:
        return "process_manager is already running."


def call_rpc_client(func_name: str):
    while running:
        status, result = call_xmlrpc_with_enum(rpc_host, rpc_port, func_name)
        if status != RpcStatus.SUCCESS:
            logging_main.error(f"调用 rpc{func_name}接口失败: {status}, result: {result}")
            time.sleep(2)
        else:
            return result


def check_time_sync():
    while running:
        remote_time = call_rpc_client("get_current_time")
        remote_time_format = datetime.fromtimestamp(remote_time).isoformat()
        local_time = time.time()
        local_time_format = datetime.fromtimestamp(local_time).isoformat()
        time_diff = abs(local_time - remote_time)
        if time_diff < 1:
            logging_main.info(f"checkout_time_sync success, remote: {remote_time_format}, local: {local_time_format}")
            return True
        else:
            logging_main.warning(f"checkout_time_sync failed, remote: {remote_time_format}, local: {local_time_format}")
            time.sleep(1)


def start_remote_em():
    global em_server_rpc_call_success
    success_tag = "successfully"
    running_tag = "running"
    while running:
        result = call_rpc_client("start_em_server")
        if success_tag in result.lower():
            # 该rpc已经调用成功
            with var_lock:
                em_server_rpc_call_success = True
            logging_main.info(f"start_remote_em success...")
            return True
        elif running_tag in result.lower():
            logging_main.info(f"start_remote_em, em_server is already_running...")
            return True
        else:
            logging_main.error(f"start_remote_em failed, {result}")
            time.sleep(2)


def get_local_em_status():
    """获取 process_manager 的运行状态"""
    process_name="process_manager"
    cmd = "ps -auxf |grep \"process_manager --cfg_file_path\" | grep -v grep"
    try:
        # 自动回收子进程
        output = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if process_name.lower() in output.stdout:
            return "running"
        else:
            logging_main.warning("get_local_em_status, not find process_manager process...")
            return "stopped"
    except Exception as e:
        logging_main.warning("get_local_em_status, catch execpt...%s", e)
        return "stopped"

def start_remote_init_process():
    logging_main.info(f"begin check_time_sync...")
    check_time_sync()
    logging_main.info(f"begin start remote em_server...")
    start_remote_em()

def start_local_init_prcess():
    logging_main.info(f"begin start ntp2rtc_service...")
    # 以子进程的方式运行 ntprtc_service.py 程序
    process = subprocess.Popen([sys.executable, "ntp2rtc_service.py"])
    logging_main.info(f"begin start local em_server...")
    start_local_em_server()

def start_local_intit_process_with_sync_time():
    # 本地启动之前, 也需要确认时间同步是否ok, 避免x86已经存在, orin重启时忽略时间同步的逻辑
    logging_main.info(f"begin check_time_sync in local_init_process...")
    check_time_sync()
    start_local_init_prcess()

# thread func
def start_handle_call_em_rpc_success_timeout():
    logging_main.info("start_handle_call_em_rpc_success_timeout...")
    global em_server_rpc_call_success

    while True:
        with var_lock:  # 加锁检查
            time_since_last_mod = time.time() - process_start_time

            # em_server_rcp_call_success_timeout, 则自行启动local em, 无需等待
            # 只调用一次
            if time_since_last_mod >= em_server_rcp_call_success_timeout and not em_server_rpc_call_success:
                logging_main.warning("em_server_rcp_call_success_timeout, ready to start local_em_server by myself...")
                start_local_init_prcess()
                em_server_rpc_call_success = True

        time.sleep(2)  # 每2秒检查一次


def ping_host(ip, logger, interval = 1):

    logging_main.info(f"local start ping cmd, to {ip}...")
    # cmd = f"ping -i {interval} {ip}"
    cmd = [
        "ping",
        "-i",
        f"{interval}",
        f"{ip}"
    ]

    try:
        # 自动回收子进程
        output = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True)           # 行缓冲

        # 创建一个线程来实时输出日志
        import threading
        def log_output():
            for line in output.stdout:
                logger.info(line.rstrip())
        log_thread = threading.Thread(target=log_output)
        log_thread.start()

        logging_main.info("local start ping success...")

    except Exception as e:
        logging_main.warning("local start ping cmd, catch execpt...%s", e)


# 读取文件的最后4行信息
def get_last_n_lines(file_path, n=4):
    try:
        # 使用seek从文件末尾开始读取
        with open(file_path, 'rb') as f:
            # 移动到文件末尾
            f.seek(0, os.SEEK_END)
            file_size = f.tell()

            # 缓冲区大小，可以根据需要调整
            buffer_size = 1024
            position = file_size

            lines = []
            line_count = 0

            while position > 0 and line_count < n:
                # 计算要读取的字节数
                read_size = min(buffer_size, position)
                position -= read_size
                f.seek(position)

                # 读取数据并分割成行
                chunk = f.read(read_size)
                lines_in_chunk = chunk.decode('utf-8').split('\n')

                # 如果是第一次读取，去掉可能的空行
                if position + read_size == file_size:
                    if lines_in_chunk[-1] == '':
                        lines_in_chunk = lines_in_chunk[:-1]

                # 将新读取的行与已有行合并
                lines = lines_in_chunk + lines

                # 统计行数
                line_count = len(lines)

            # 返回最后n行（或更少如果文件行数不足）
            return lines[-n:] if line_count >= n else lines

    except FileNotFoundError:
        return ["错误: 文件不存在"]
    except Exception as e:
        return [f"错误: 读取文件时发生异常 - {str(e)}"]


def read_package_info():
    """读取文件最后n行并记录到日志, 多读取几行, 有可能文件内容会扩展"""
    lines = get_last_n_lines(PACKAGE_YAML_FILE, 10)

    logging_main.info(f"*** file {PACKAGE_YAML_FILE} content, last 10 lines ***")
    for line in lines:
        logging_main.info(f"*** {line.strip()}")
    logging_main.info(f"*** file {PACKAGE_YAML_FILE}   end.   ***")

def start_master_rtc_time_sync():
    """运行rtc时间同步脚本, 并阻塞等待运行完成"""
    try:
        ret = subprocess.run(
            ["/bin/sh", "./start_master_time_sync.sh"],
            capture_output=True,
            text=True,
            check=True
        )
        logging_main.info(f"time_sync: stdout: \n{ret.stdout}")
        logging_main.info(f"time_sync: stderr: \n{ret.stderr}")
        logging_main.info("start master_time_sync.sh finish...")

    except Exception as e:
        return f"Failed to start master_time_sync: {str(e)}"


def signal_handler(signum, frame):
    """信号处理函数"""
    logging_main.info(f"收到信号 {signum}，准备退出服务...")
    global running
    running = False



def main():
    global rpc_host
    global rpc_port
    rpc_host = "192.168.100.100"
    rpc_port = 56999

    global logging_main
    global logging_ping
    ensure_log_directory()
    logging_main = create_log_file(LOG_FILE_NAME)
    logging_ping = create_log_file(PING_LOG_FILE_NAME)

    # 注册信号处理
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    # Warning! 这里不能忽略任何信号, 否则模块进程内部捕获子进程的逻辑就会出问题, 忽略信号会传递
    # signal.signal(signal.SIGCHLD, signal.SIG_IGN)

    # 读取版本信息
    read_package_info()
    
    # TZ网卡经常第20s被重新up
    time.sleep(30)

    logging_main.info(f"remote em_server, host:{rpc_host}, port:{rpc_port}...")


    # 启动监控线程
    global process_start_time
    process_start_time = time.time()
    monitor_thread = threading.Thread(target=start_handle_call_em_rpc_success_timeout, daemon=True)
    monitor_thread.start()

    ping_host(rpc_host, logging_ping)

    # 判断当前是否为orin重启
    remote_boot_sec = call_rpc_client("get_seconds_since_boot")
    if remote_boot_sec_max < remote_boot_sec:
        logging_main.warning(f"remote_boot_sec: {remote_boot_sec}, will never start sync rtc time...")
        # 使用remote 时间设置当前系统时间
        remote_time = call_rpc_client("get_current_time")
        remote_time_format = datetime.fromtimestamp(remote_time).isoformat()
        try:
            # 阻塞等待设置时间戳完成
            ret = subprocess.run(['sudo', 'date', '-s', f"@{remote_time:.6f}"], capture_output=True, check=True)
            logging_main.warning(f"set system time success {remote_time_format}...stdout:{ret.stdout}, stderr:{ret.stderr}")
        except Exception as e:
            logging_main.error(f"set system date failed... - {str(e)}")
    else:
        start_master_rtc_time_sync()

    # 支持orin, x86单独reboot
    while running:
        remote_em_status = call_rpc_client("get_em_status")
        local_em_status = get_local_em_status()
        if remote_em_status == "running" and local_em_status == "running":
            time.sleep(2)
        elif remote_em_status == "running" and running:
            start_local_intit_process_with_sync_time()
        elif local_em_status == "running" and running:
            start_remote_init_process()
        else:
            if running:
                start_remote_init_process()
                if not em_server_rpc_call_success:  # 第一次启动时, 如果本地em已经超时自启动了, 则无需重复启动
                    start_local_init_prcess()


if __name__ == "__main__":
    main()
