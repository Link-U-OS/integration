import xmlrpc.server
import time
import subprocess
import logging
import signal
import os
import re
import sys
import threading
import time

from datetime import datetime

# 配置常量
LOG_DIR = "/agibot/log/process_manager"
LOG_FILE_NAME = "em_daemon.log"
PING_LOG_FILE_NAME = "em_ping.log"
PACKAGE_YAML_FILE = "/agibot/software/v0/metadata.yaml"

rpc_host = "127.0.0.1"
rpc_port = 8080

logging_main = None
logging_ping = None
max_log_file_num = 50

# 存储 em-server 进程对象
em_server_process = None

# 全局变量及线程安全控制
em_server_rpc_called = False      # 用于判断start_em_server 是否被调用
var_lock = threading.Lock()       # 保证全局变量 em_server_rpc_called 的线程安全

process_start_time = time.time()  # 记录进程启动时间
em_server_start_timeout = 300     # em-server 没有被启动的超时时间: 300s

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



def get_current_time():
    """获取当前时间"""
    return time.time()

def get_seconds_since_boot():
    """获取启动到现在的秒数"""
    boot_sec = int(time.clock_gettime(time.CLOCK_MONOTONIC))
    return boot_sec

def start_em_server_internal():
    logging_main.info(f"ready start em_server...")
    global em_server_process
    if em_server_process is None or em_server_process.poll() is not None:
        agibot_home = os.environ.get('AGIBOT_HOME')
        if not agibot_home:
            agibot_home = ""
        cmd = [
            "/agibot/software/v0/scripts/process_manager/start_process_manager.sh"
        ]
        try:
            # 启动 em-server 并将标准输出和标准错误输出重定向到终端
            em_server_process = subprocess.Popen(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            logging_main.info("start em_server success...")
            return "em-server started successfully."
        except Exception as e:
            return f"Failed to start em-server: {str(e)}"
    else:
        return "em-server is already running."


def start_em_server():
    """启动 em-server 并输出日志"""
    global em_server_rpc_called
    # 该rpc已经被调用
    with var_lock:
        em_server_rpc_called = True

    return start_em_server_internal()

def stop_em_server():
    """停止 em-server"""
    global em_server_process
    if em_server_process and em_server_process.poll() is None:
        try:
            em_server_process.send_signal(signal.SIGTERM)
            em_server_process.wait()
            return "em-server stopped successfully."
        except Exception as e:
            return f"Failed to stop em-server: {str(e)}"
    else:
        return "em-server is not running."

def get_em_status():
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


# thread func
def start_handle_start_em_timeout():
    logging_main.info("start_handle_start_em_timeout...")
    global em_server_rpc_called

    while True:
        with var_lock:  # 加锁检查
            time_since_last_mod = time.time() - process_start_time

            # 如果超过em_server_start_timeout 且 em_server 未被启动, 则自行启动
            # 只调用一次
            if time_since_last_mod >= em_server_start_timeout and not em_server_rpc_called:
                logging_main.warning("start_em_timeout, ready to start em_server by myself...")
                start_em_server_internal()
                em_server_rpc_called = True

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



def main():
    import argparse
    parser = argparse.ArgumentParser(
        description="slave_em_server",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
            slave_em_server.py <host> <port>
        '''
    )

    parser.add_argument("host", help="远程主机IP地址")
    parser.add_argument("port", type=int, help="port")

    args = parser.parse_args()
    global rpc_host
    global rpc_port
    rpc_host = args.host
    rpc_port = args.port

    global logging_main
    global logging_ping
    ensure_log_directory()
    logging_main = create_log_file(LOG_FILE_NAME)
    logging_ping = create_log_file(PING_LOG_FILE_NAME)

    # Warning! 这里不能忽略任何信号, 否则模块进程内部捕获子进程的逻辑就会出问题, 忽略信号会传递
    # signal.signal(signal.SIGCHLD, signal.SIG_IGN)

    # 读取版本信息
    read_package_info()
    
    # TZ网卡经常第20s被重新up
    time.sleep(30)

    logging_main.info(f"ready start SimpleXMLRPCServer, host:{rpc_host}, port:{rpc_port}...")

    em_master_host = "192.168.100.110"
    ping_host(em_master_host, logging_ping)

    # 创建 XML-RPC 服务器
    server = xmlrpc.server.SimpleXMLRPCServer((rpc_host, rpc_port))
    # 注册接口
    server.register_function(get_current_time, "get_current_time")
    server.register_function(get_em_status, "get_em_status")
    server.register_function(start_em_server, "start_em_server")
    server.register_function(stop_em_server, "stop_em_server")
    server.register_function(get_seconds_since_boot, "get_seconds_since_boot")

    # 启动监控线程
    global process_start_time
    process_start_time = time.time()
    monitor_thread = threading.Thread(target=start_handle_start_em_timeout, daemon=True)
    monitor_thread.start()

    # 启动服务器
    server.serve_forever()


if __name__ == "__main__":
    main()
