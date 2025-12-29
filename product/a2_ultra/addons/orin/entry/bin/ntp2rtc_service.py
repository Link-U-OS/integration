import os
import sys
import time
import signal
import logging
import socket
import struct
import multiprocessing
import queue
from datetime import datetime
from typing import Optional

# NTP相关常量
NTP_SERVERS = [
    "ntp.aliyun.com",           # 阿里云
    "ntp1.aliyun.com",
    "ntp2.aliyun.com",
    "ntp3.aliyun.com",
    "ntp4.aliyun.com",
    "ntp5.aliyun.com",
    "ntp6.aliyun.com",
    "ntp7.aliyun.com",
    "time1.cloud.tencent.com",  # 腾讯云
    "time2.cloud.tencent.com",
    "time3.cloud.tencent.com",
    "time4.cloud.tencent.com",
    "time5.cloud.tencent.com",
    "time.nist.gov",            # 美国国家标准与技术研究院
    "time.windows.com",         # 微软时间服务器
    "pool.ntp.org",            # NTP全球服务器池
    "europe.pool.ntp.org",     # 欧洲NTP服务器池
    "asia.pool.ntp.org",       # 亚洲NTP服务器池
    "time.google.com",         # 谷歌时间服务器
    "ntp.ubuntu.com",          # Ubuntu时间服务器
    "time.apple.com",          # 苹果时间服务器
]

NTP_TIMESTAMP_DELTA = 2208988800  # NTP时间戳起始点(1900年)到Unix时间戳(1970年)的秒数

# 日志配置
LOG_DIR = "/agibot/log/tsync"
LOG_FILE = f"{LOG_DIR}/ntp2rtc.log"

# 全局变量用于控制服务运行
running = True

def setup_logging():
    """配置日志系统"""
    if not os.path.exists(LOG_DIR):
        os.makedirs(LOG_DIR)
    
    # 以 'w' 模式打开日志文件，这会清空原有内容
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(LOG_FILE, mode='w'),
            logging.StreamHandler()
        ]
    )

def get_ntp_time(server: str) -> Optional[float]:
    """从NTP服务器获取时间"""
    try:
        client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client.settimeout(2)
        msg = b'\x1b' + 47 * b'\0'
        client.sendto(msg, (server, 123))
        msg, _ = client.recvfrom(48)
        client.close()

        t = struct.unpack("!12I", msg)[10]
        return t - NTP_TIMESTAMP_DELTA
    except Exception as e:
        return None

def set_rtc_time(timestamp: float):
    """仅设置RTC时间"""
    try:
        # 直接将时间写入RTC
        os.system(f"sudo hwclock --rtc=/dev/rtc_agibot --set --date='{datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')}'")
        logging.info(f"RTC时间已更新: {datetime.fromtimestamp(timestamp).isoformat()}")
        return True
    except Exception as e:
        logging.error(f"设置RTC时间失败: {e}")
    return False

def get_network_time() -> Optional[float]:
    """并发从多个NTP服务器获取时间，失败时进行重试"""
    max_retries = 3
    retry_delay = 5  # 重试间隔秒数
    
    for attempt in range(max_retries):
        if not running:  # 检查是否需要退出
            return None
            
        def _get_time_from_server(server: str, result_queue: multiprocessing.Queue):
            # 子进程中重置信号处理器
            signal.signal(signal.SIGTERM, signal.SIG_DFL)
            signal.signal(signal.SIGINT, signal.SIG_DFL)
            
            try:
                ntp_time = get_ntp_time(server)
                if ntp_time is not None:
                    result_queue.put((server, ntp_time))
            except Exception as e:
                logging.error(f"从服务器 {server} 获取时间失败: {e}")

        result_queue = multiprocessing.Queue()
        processes = []
        
        # 启动所有进程
        for server in NTP_SERVERS:
            p = multiprocessing.Process(
                target=_get_time_from_server,
                args=(server, result_queue)
            )
            p.start()
            processes.append(p)

        try:
            # 等待第一个成功的结果
            server, network_time = result_queue.get(timeout=3)
            logging.info(f"成功从服务器 {server} 获取时间")
            return network_time
        except queue.Empty:
            logging.error("获取NTP时间超时")
            return None
        finally:
            # 确保所有进程都被终止
            for p in processes:
                p.terminate()
                p.join(timeout=0.1)

        if network_time is not None:
            return network_time
            
        if attempt < max_retries - 1:  # 如果不是最后一次尝试
            logging.warning(f"第 {attempt + 1} 次获取时间失败，{retry_delay}秒后重试...")
            time.sleep(retry_delay)
    
    return None

def signal_handler(signum, frame):
    """信号处理函数"""
    global running
    logging.info(f"收到信号 {signum}，准备退出服务...")
    running = False

def main():
    if os.geteuid() != 0:
        print("请使用sudo运行此服务")
        sys.exit(1)

    import argparse
    parser = argparse.ArgumentParser(description="NTP到RTC时间同步服务")
    parser.add_argument("-s", "--sync-interval", type=int, default=900,
                       help="成功同步后的等待间隔(秒)，默认900秒(15分钟)")
    parser.add_argument("-r", "--retry-interval", type=int, default=5,
                       help="同步失败后的重试间隔(秒)，默认5秒")
    args = parser.parse_args()

    setup_logging()
    logging.info("NTP到RTC时间同步服务启动")

    # 注册信号处理
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    sync_interval = args.sync_interval
    retry_interval = args.retry_interval

    while running:
        network_time = get_network_time()
        if network_time is not None:
            if set_rtc_time(network_time):
                # 成功同步后等待设定的同步间隔
                logging.info(f"等待{sync_interval}秒({sync_interval/60}分钟)后进行下一次同步...")
                wait_interval = sync_interval
            else:
                # 设置RTC失败后等待重试间隔
                logging.warning(f"设置RTC失败，{retry_interval}秒=后重试...")
                wait_interval = retry_interval
        else:
            # 获取网络时间失败后等待重试间隔
            logging.warning(f"获取网络时间失败，{retry_interval}秒后重试...")
            wait_interval = retry_interval
            
        # 分段睡眠，确保可以及时响应退出信号
        for _ in range(wait_interval):
            if not running:
                break
            time.sleep(1)

    logging.info("服务正常退出")
if __name__ == "__main__":
    main()
