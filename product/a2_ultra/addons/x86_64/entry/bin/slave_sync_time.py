import json
import time
import logging
import os
import sys
import paramiko
from datetime import datetime
from typing import Optional, Dict

# 配置常量
LOG_DIR = "/agibot/log/tsync"
LOG_FILE = f"{LOG_DIR}/slave_sync_time.log"
REMOTE_STATUS_FILE = "/agibot/log/tsync/sync_status.json"


def ensure_log_directory():
    """确保日志目录存在"""
    try:
        if not os.path.exists(str(LOG_DIR)):
            os.makedirs(str(LOG_DIR))
            print(f"创建日志目录: {LOG_DIR}")
    except Exception as e:
        print(f"创建日志目录失败: {e}")
        sys.exit(1)


def setup_logging():
    """配置日志系统"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(LOG_FILE, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )


def clear_log_file():
    """清空日志文件"""
    try:
        if os.path.exists(LOG_FILE):
            with open(LOG_FILE, 'w', encoding='utf-8') as f:
                f.truncate(0)
    except Exception as e:
        print(f"清空日志文件失败: {e}")


def check_sync_status(ssh: paramiko.SSHClient) -> Optional[Dict]:
    """
    通过SSH检查远程主机的时间同步状态文件

    Args:
        ssh: SSH客户端连接

    Returns:
        同步状态信息或None（如果检查失败）
    """
    try:
        # 使用cat命令读取远程文件内容
        logging.info(f"正在读取远程状态文件: {REMOTE_STATUS_FILE}")
        stdin, stdout, stderr = ssh.exec_command(f"cat {REMOTE_STATUS_FILE}")
        content = stdout.read().decode('utf-8')
        error = stderr.read().decode('utf-8')
        
        if error:
            logging.warning(f"读取状态文件出错: {error}")
            return None
            
        if not content:
            logging.warning("状态文件为空")
            return None
            
        try:
            status_data = json.loads(content)
            logging.debug(f"读取到的状态数据: {status_data}")
            
            # 删除远程状态文件
            logging.info(f"删除远程状态文件: {REMOTE_STATUS_FILE}")
            ssh.exec_command(f"rm {REMOTE_STATUS_FILE}")
            
            return status_data
        except json.JSONDecodeError as je:
            logging.error(f"JSON解析失败: {je}")
            logging.error(f"原始内容: {content}")
            return None
            
    except Exception as e:
        logging.error(f"获取同步状态失败: {str(e)}")
        logging.exception("详细错误信息:")
        return None


def monitor_sync_status(host: str, username: str, password: str,
                        check_interval: float = 1.0,
                        max_attempts: int = 0,
                        connect_timeout: int = 600) -> bool:
    """
    持续监控远程主机的时间同步状态

    Args:
        host: 远程主机IP
        username: SSH用户名
        password: SSH密码
        check_interval: 检查间隔（秒）
        max_attempts: 最大尝试次数（0表示无限尝试）
        connect_timeout: SSH连接超时时间（秒）

    Returns:
        同步成功返回True，失败返回False
    """
    ensure_log_directory()
    setup_logging()
    clear_log_file()

    logging.info("=" * 50)
    logging.info(f"开始监控远程主机 {host} 的时间同步状态")
    logging.info(f"检查间隔: {check_interval}秒")
    if max_attempts > 0:
        logging.info(f"最大尝试次数: {max_attempts}")
    logging.info("=" * 50)

    # 建立SSH连接
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # 使用重试机制建立SSH连接
    start_time = time.time()
    while time.time() - start_time < connect_timeout:
        try:
            logging.info(f"正在连接到远程主机 {host}...")
            ssh.connect(host, username=username, password=password, timeout=10)
            logging.info("SSH连接建立成功")
            break
        except Exception as e:
            remaining_time = int(connect_timeout - (time.time() - start_time))
            if remaining_time <= 0:
                logging.error(f"SSH连接失败，超过最大等待时间（{connect_timeout}秒）")
                return False
            logging.warning(f"SSH连接失败: {str(e)}")
            logging.info(f"将在2秒后重试... (剩余等待时间: {remaining_time}秒)")
            time.sleep(2)

    try:
        attempt = 0
        while True:
            if max_attempts > 0:
                if attempt >= max_attempts:
                    logging.error(f"达到最大尝试次数 {max_attempts}，监控结束")
                    return False
                attempt += 1
                logging.info(f"当前尝试次数: {attempt}/{max_attempts}")

            status = check_sync_status(ssh)
            if status is None:
                logging.warning("本次检查未获取到有效状态，将在下次继续尝试")
                time.sleep(check_interval)
                continue

            logging.info("-" * 30)
            logging.info(f"检查时间: {datetime.now().isoformat()}")
            
            # 处理初始化状态
            if "status" in status and status["status"] == "initializing":
                logging.info("远程主机正在初始化时间同步...")
                time.sleep(check_interval)
                continue
            
            # 处理完整的同步状态信息
            if all(key in status for key in ['local_time', 'remote_time', 'time_difference', 'threshold', 'success']):
                logging.info(f"本地时间: {status['local_time']['datetime']}")
                logging.info(f"远程时间: {status['remote_time']['datetime']}")
                logging.info(f"时间差: {status['time_difference']:.3f}秒")
                logging.info(f"阈值: {status['threshold']}秒")
                logging.info(f"同步状态: {'成功' if status['success'] else '失败'}")

                if abs(time.time() - status['local_time']['timestamp']) > 5:
                    logging.warning("时间同步验证结果与本地时间不一致，继续监控...")
                    time.sleep(check_interval)
                    continue

                if status['success']:
                    logging.info("时间同步验证成功！")
                    return True
                else:
                    logging.warning("时间同步验证失败，继续监控...")
            else:
                logging.warning(f"状态文件格式不完整，等待更新... 当前状态: {status}")

            time.sleep(check_interval)
    except Exception as e:
        logging.error(f"监控过程发生异常: {str(e)}")
        logging.exception("详细错误信息:")
        return False
    finally:
        logging.info("关闭SSH连接...")
        ssh.close()


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description="监控远程主机的时间同步状态",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
使用示例:
    1. 基本用法（持续监控）:
       %(prog)s 192.168.1.100 root password

    2. 自定义参数:
       %(prog)s 192.168.1.100 root password -i 2 -m 300 -c 300
       含义: 每2秒检查一次，最多检查300次，连接超时5分钟

注意事项:
    1. 需要确保远程主机开启了SSH服务
    2. 需要有读取状态文件的权限
    3. 日志文件保存在 /agibot/log/tsync/monitor_sync.log
    4. 远程状态文件路径: /agibot/log/tsync/sync_status.json
    5. 返回值: 0-检测到同步成功, 1-监控失败
        '''
    )

    parser.add_argument("host", help="远程主机IP")
    parser.add_argument("username", help="SSH用户名")
    parser.add_argument("password", help="SSH密码")
    parser.add_argument("-i", "--interval", type=float, default=1.0,
                        help="检查间隔时间(秒) (默认: 1.0)")
    parser.add_argument("-m", "--max-attempts", type=int, default=360,
                        help="最大尝试次数 (默认: 360)")
    parser.add_argument("-c", "--connect-timeout", type=int, default=600,
                        help="SSH连接超时时间(秒) (默认: 600)")

    args = parser.parse_args()

    success = monitor_sync_status(
        args.host,
        args.username,
        args.password,
        check_interval=args.interval,
        max_attempts=args.max_attempts,
        connect_timeout=args.connect_timeout
    )

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
