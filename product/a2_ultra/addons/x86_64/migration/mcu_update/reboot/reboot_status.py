import datetime
import os
import subprocess
import time
from pathlib import Path

import yaml


def logger(message, level="INFO"):
    """
    简单的日志函数，打印带时间戳的日志消息。

    参数:
        message (str): 要打印的日志消息。
        level (str): 日志级别，例如 "INFO", "ERROR", "WARNING"。
    """
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [{level}] {message}")


def execute_bash_command(command):
    """
    执行本地 Bash 命令，打印 stdout 和 stderr，并返回命令的执行结果码。

    参数:
        command (str): 完整的 Bash 命令字符串，包含所有参数。

    返回:
        int: 命令的返回码（0 表示成功，非 0 表示失败）。
    """
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
            logger(result.stdout.strip())
        if result.stderr:
            logger(result.stderr.strip())

        # 把 stdout 和 stderr 转换为字符串
        stdout_str = result.stdout.decode("utf-8", errors="ignore")
        stderr_str = result.stderr.decode("utf-8", errors="ignore")
        logger(f"stdout_str: {stdout_str}")
        logger(f"stderr_str: {stderr_str}")

        return [result.returncode, stdout_str]
    except subprocess.CalledProcessError as e:
        # 打印错误输出
        if e.stdout:
            logger(e.stdout.strip())
        if e.stderr:
            logger(e.stderr.strip())
        return [e.returncode, None]


def get_current_script_path():
    return os.path.dirname(os.path.abspath(__file__))


def get_ota_firm_tools_path():
    return os.path.join(
        get_current_script_path(), "../../../bin/firm_ota"
    )

def get_ota_elink_tools_path():
    return os.path.join(
        get_current_script_path(), "../../../bin/multiplex_link_a2_ota"
    )


def get_ethercat_config_path():
    return os.path.join(
        get_current_script_path(), "../../../entry/bin/cfg/ecat_net.yaml"
    )


def get_mcu_update_dir_path():
    return os.path.join(get_current_script_path(), "../../../mcu_upgrade")


def get_power_board_version(net_card, mcu_number):
    firm_path = get_ota_firm_tools_path()
    firm_path = Path(firm_path).resolve()
    code, _ = execute_bash_command(f"chmod +x {firm_path}")
    if code != 0:
        logger("无法设置权限，无法执行脚本")
        return [-1, None]

    code, info = execute_bash_command(
        f"{firm_path} query minor_mcu_software_version {net_card} {mcu_number}"
    )
    logger(f"{firm_path} query minor_mcu_software_version {net_card} {mcu_number}")
    if code != 0:
        logger("无法获取版本号")
        return [-1, None]

    version = ""
    parts = info.split(":")
    if len(parts) > 1:
        version = parts[1].strip()
    return [0, version]

def get_power_board_hardware_version(net_card, mcu_number):
    firm_path = get_ota_firm_tools_path()
    firm_path = Path(firm_path).resolve()
    code, _ = execute_bash_command(f"chmod +x {firm_path}")
    if code != 0:
        logger("无法设置权限，无法执行脚本")
        return [-1, None]

    code, info = execute_bash_command(
        f"{firm_path} query minor_mcu_hardware_version {net_card} {mcu_number}"
    )
    logger(f"{firm_path} query minor_mcu_hardware_version {net_card} {mcu_number}")
    if code != 0:
        logger("无法获取版本号")
        return [-1, None]

    version = ""
    parts = info.split(":")
    if len(parts) > 1:
        version = parts[1].strip()
    return [0, version]

def check_is_p1_by_software_version(net_card):
    mcu_number = 1
    ret, current_version = get_power_board_version(net_card, mcu_number)
    if ret != 0:
        logger(f"获取 {mcu_number} 副板的版本号失败")
        return -1
    parts = current_version.split("0.7",1)
    if len(parts) <= 1:
        return -1
    return 0

def check_is_t3_by_software_version():
    net_card = "eno1"
    mcu_number = 1
    ret, current_version = get_power_board_version(net_card, mcu_number)
    if ret != 0:
        logger(f"获取 {mcu_number} 副板的版本号失败")
        return -1
    parts = current_version.split("0.6",1)
    if len(parts) <= 1:
        return -1
    return 0

def get_power_board_version_by_elink(device_addr):
    elink_path = get_ota_elink_tools_path()
    elink_path = Path(elink_path).resolve()
    code, _ = execute_bash_command(f"chmod +x {elink_path}")
    if code != 0:
        logger("无法设置权限，无法执行脚本")
        return [-1, None]

    code, info = execute_bash_command(
        f"{elink_path} version {device_addr}"
    )
    logger(f"{elink_path} version {device_addr}")
    if code != 0:
        logger("无法获取版本号")
        return [-1, None]

    version = ""
    parts = info.split(":")
    if len(parts) > 1:
        version = parts[1].strip()
    return [0, version]

def update_power_board_version(net_card, mcu_number, code, bin_path):
    firm_path = get_ota_firm_tools_path()
    firm_path = Path(firm_path).resolve()
    bin_path = Path(bin_path).resolve()
    ret, _ = execute_bash_command(f"chmod +x {firm_path}")
    if ret != 0:
        logger("无法设置权限，无法执行脚本")
        return -1

    ### 测试环境使用，实际生产环境，应该取消注释
    ret, _ = execute_bash_command(
        f"{firm_path} update {net_card} {mcu_number} {code} {bin_path}"
    )
    logger(f"{firm_path} update {net_card} {mcu_number} {code} {bin_path}")
    if ret != 0:
        logger("无法升级版本号")
        return -1

    return 0

def parse_multiplex_link_power_board_config(file_path):
    """
    解析 MCU 配置的 YAML 文件，返回结构化数据。

    参数:
        file_path (str): YAML 文件路径。

    返回:
        ret, is_upgrade, dev_addr,bin_name, version
    """
    try:
        # 从文件中加载 YAML 内容
        with open(file_path, "r") as file:
            config = yaml.safe_load(file)

        # 提取 power_board 的内容
        multiplex_link_config = config.get("multiplex_link_p1",{})
        power_board_config = multiplex_link_config.get("power_board_p1", {})
        is_upgrade = power_board_config.get("is_upgrade", False)
        dev_addr = power_board_config.get("dev_addr", None)
        bin_name = power_board_config.get("bin", None)
        version = power_board_config.get("version", None)

        # 返回解析后的数据
        return [0, is_upgrade, dev_addr,bin_name, version]
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        return [-1, False, None, None, None]
    except yaml.YAMLError as e:
        print(f"YAML 解析错误: {e}")
        return [-1, False, None,None, None]

def query_mcu_transfer_status(net_card, master_id, slave_id):
    firm_path = get_ota_firm_tools_path()
    firm_path = Path(firm_path).resolve()
    while True:
        time.sleep(2)
        ret, result = execute_bash_command(
            f"{firm_path} query minor_mcu_operation_mode {net_card} {master_id} {slave_id}"
        )
        logger(
            f"{firm_path} query minor_mcu_operation_mode {net_card} {master_id} {slave_id}"
        )
        if ret != 0:
            logger("无法查询升级状态")
            return -1
        if "current mcu firmware state: 6" in result:
            break
    return 0


def reboot_power_board(net_card, master_id, slave_id):
    firm_path = get_ota_firm_tools_path()
    firm_path = Path(firm_path).resolve()
    ret, _ = execute_bash_command(
        f"{firm_path} config minor_mcu_operation_mode {net_card} {master_id} {slave_id}"
    )
    if ret != 0:
        logger("重启电源板失败。")
        return -1
    return 0


def parse_power_board_config(file_path):
    """
    解析 MCU 配置的 YAML 文件，返回结构化数据。

    参数:
        file_path (str): YAML 文件路径。

    返回:
        ret, is_upgrade, master_id, slave_id, code, bin_name, version
    """
    try:
        # 从文件中加载 YAML 内容
        with open(file_path, "r") as file:
            config = yaml.safe_load(file)

        # 提取 power_board 的内容
        power_board_config = config.get("power_board_t3", {})
        is_upgrade = power_board_config.get("is_upgrade", False)
        master_id = power_board_config.get("master_id", None)
        slave_id = power_board_config.get("slave_id", None)
        code = power_board_config.get("code", None)
        bin_name = power_board_config.get("bin", None)
        version = power_board_config.get("version", None)

        # 返回解析后的数据
        return [0, is_upgrade, master_id, slave_id, code, bin_name, version]
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        return [-1, False, None, None, None, None, None]
    except yaml.YAMLError as e:
        print(f"YAML 解析错误: {e}")
        return [-1, False, None, None, None, None, None]


def parse_ethercat_config(file_path):
    """
    解析 EtherCAT 配置的 YAML 文件，返回结构化数据。

    参数:
        file_path (str): YAML 文件路径。

    返回:
        dict: 包含解析结果的字典。
    """
    try:
        # 从文件中加载 YAML 内容
        with open(file_path, "r") as file:
            config = yaml.safe_load(file)

        # 提取 ethercat 的内容
        ethercat_config = config.get("ethercat", {})

        # 返回解析后的数据
        return ethercat_config
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        return None
    except yaml.YAMLError as e:
        print(f"YAML 解析错误: {e}")
        return None

def judge_p1_t3():
    net_card = "eth_ecat eth_ecat2"
    mcu_number = 1
    ret, current_version = get_power_board_hardware_version(net_card, mcu_number)
    if ret !=0:
        return [-1,None]
    version ="3.0.0"
    if current_version != version:
        if check_is_p1_by_software_version(net_card) ==0:
            return [0,"P1"]
        else:
            return[0,"T3"]
    return[0,"P1"]

def query_power_board():
    try:
        ret,current_model = judge_p1_t3()
        if ret!=0:
            return -1
        model = "T3"
        if current_model != model:
            logger("不包含T3,不通过ethercat查询电源板状态")
            return 0   
        
        logger("开始通过ethercat查询电源板状态")
        if not os.path.exists(get_mcu_update_dir_path()):
            logger("mcu 升级目录不存在，因此不对电源板状态进行查询")
            return 0
        ethercat_map = parse_ethercat_config(get_ethercat_config_path())
        if ethercat_map is None:
            logger("无法解析 ethercat 配置文件，请检查文件格式是否正确。")
            return -1
        ret, is_upgrade, master_id, slave_id, code, bin_name, version = (
            parse_power_board_config(get_mcu_update_dir_path() + "/info.yaml")
        )
        if ret != 0:
            logger("无法解析 power_board 配置文件，请检查文件格式是否正确。")
            return -1

        if not is_upgrade:
            logger("电源板不需要升级")
            return 0

        if master_id is None or version is None:
            logger("power_board 配置文件格式不正确，请检查文件格式是否正确。")
            return -1

        net_card = ethercat_map.get(master_id, None)
        if net_card is None:
            logger(f"{master_id} 在 ethercat 配置文件中没有找到对应的网卡，无法升级。")
            return -1
        net_card = " ".join(net_card)

        ret, result = get_power_board_version(net_card, master_id[3:])
        if ret != 0:
            logger("无法获取电源板版本号")
            return -1

        if version in result:
            logger(f"集成包中的版本号为 {version}，电源板版本号为 {result}")
            return 0

        logger(
            f"集成包中的版本号为 {version}，电源板版本号为 {result}, 两者版本号不一致，请检查版本号是否正确。"
        )
        return -1

    except Exception as e:
        logger(f"无法解析 ethercat 配置文件，请检查文件格式是否正确, {e}")
        return -1

def query_power_board_by_elink():
    try:
        ret,current_model = judge_p1_t3()
        if ret!=0:
            return -1
        model = "P1"
        if current_model != model:
            logger("不包含P1,不通过elink查询电源板状态")
            return 0           
        logger("开始通过elink查询电源板状态")
        if not os.path.exists(get_mcu_update_dir_path()):
            logger("mcu 升级目录不存在，因此不对电源板状态进行查询")
            return 0
        ret, is_upgrade, device_addr,bin_name, version = (
            parse_multiplex_link_power_board_config(get_mcu_update_dir_path() + "/info.yaml")
        )
        if ret != 0:
            logger("无法解析 power_board 配置文件，请检查文件格式是否正确。")
            return -1

        if not is_upgrade:
            logger("电源板不需要升级")
            return 0

        if device_addr is None or version is None:
            logger("power_board 配置文件格式不正确，请检查文件格式是否正确。")
            return -1
        
        ret, result = get_power_board_version_by_elink(device_addr)
        if ret != 0:
            logger("无法获取电源板版本号")
            return -1

        if version in result:
            logger(f"集成包中的版本号为 {version}，电源板版本号为 {result}")
            return 0

        logger(
            f"集成包中的版本号为 {version}，电源板版本号为 {result}, 两者版本号不一致，请检查版本号是否正确。"
        )
        return -1

    except Exception as e:
        logger(f"无法解析 ethercat 配置文件，请检查文件格式是否正确, {e}")
        return -1

if __name__ == "__main__":
    import sys

    if query_power_board() != 0:
        logger("查询电源板状态失败")
        sys.exit(-1)

    if query_power_board_by_elink() !=0:
        logger("查询电源板状态失败")
        sys.exit(-1)


    logger("查询电源板状态完成")
    sys.exit(0)
