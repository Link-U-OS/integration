import datetime
import os
import re
import subprocess
import time
from pathlib import Path

import yaml

"""
实际负责升级 mcu 和 xml 的脚本
@chengweiyuan 维护
"""


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


def get_read_xml_tool_path():
    return os.path.join(get_current_script_path(), "../../tools/hal_ethercat/slaveinfo")


def get_ota_firm_tools_path():
    return os.path.join(
        get_current_script_path(), "../../bin/firm_ota"
    )

def get_ota_elink_tools_path():
    return os.path.join(
        get_current_script_path(), "../../bin/multiplex_link_a2_ota"
    )

def get_ethercat_config_path():
    return os.path.join(get_current_script_path(), "../../entry/bin/cfg/ecat_net.yaml")


def get_mcu_update_dir_path():
    return os.path.join(get_current_script_path(), "../../mcu_upgrade")


def get_mcu_version(net_card, mcu_number):
    firm_path = get_ota_firm_tools_path()
    firm_path = Path(firm_path).resolve()
    code, _ = execute_bash_command(f"chmod +x {firm_path}")
    if code != 0:
        logger("无法设置权限，无法执行脚本")
        return [-1, None]

    code, info = execute_bash_command(
        f"{firm_path} query major_mcu_software_version {net_card} {mcu_number}"
    )
    logger(f"{firm_path} query major_mcu_software_version {net_card} {mcu_number}")
    if code != 0:
        logger("无法获取版本号")
        return [-1, None]

    version = ""
    parts = info.split(":")
    if len(parts) > 1:
        version = parts[1].strip()
    return [0, version]

def get_power_board_software_version(net_card, mcu_number):
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
    retry_count = 3
    count = 1
    current_version = ""
    while count <= retry_count:
        ret, current_version = get_power_board_software_version(net_card, mcu_number)
        if ret != 0:
            logger(f"获取 {mcu_number} 副板的版本号失败{count}次")
            count+=1
            time.sleep(3)
        else:
            break
    if count >= retry_count:
        return -1
    parts = current_version.split("0.7",1)
    if len(parts) <= 1:
        return -1
    return 0

def check_is_t3_by_software_version():
    net_card = "eno1"
    mcu_number = 1
    retry_count = 3
    count = 1
    current_version = ""
    while count <= retry_count:
        ret, current_version = get_power_board_software_version(net_card, mcu_number)
        if ret != 0:
            logger(f"获取 {mcu_number} 副板的版本号失败{count}次")
            count+=1
            time.sleep(3)
        else:
            break
    if count >= retry_count:
        return -1
    parts = current_version.split("0.6",1)
    if len(parts) <= 1:
        return -1
    return 0

def get_mcu_version_by_elink(device_addr):
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


def update_mcu_version(net_card, mcu_number, code, bin_path):
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

def update_mcu_version_by_elink(device_addr, bin_path):
    elink_path = get_ota_elink_tools_path()
    elink_path = Path(elink_path).resolve()
    code, _ = execute_bash_command(f"chmod +x {elink_path}")
    if code != 0:
        logger("无法设置权限，无法执行脚本")
        return -1
    ### 测试环境使用，实际生产环境，应该取消注释
    ret, _ = execute_bash_command(
        f"{elink_path} update {device_addr} {bin_path}"
    )
    logger(f"{elink_path} update {device_addr} {bin_path}")
    if ret != 0:
        logger("无法升级版本号")
        return -1
    return 0

def parse_mcu_config(file_path):
    """
    解析 MCU 配置的 YAML 文件，返回结构化数据。

    参数:
        file_path (str): YAML 文件路径。

    返回:
        dict: 包含解析结果的字典，包括 order, map 和 code。
    """
    try:
        # 从文件中加载 YAML 内容
        with open(file_path, "r") as file:
            config = yaml.safe_load(file)

        # 提取 mcu 的内容
        mcu_config = config.get("mcu", {})
        order = mcu_config.get("order", [])
        map_info = {item["name"]: item["bin"] for item in mcu_config.get("map", [])}
        code_info = {item["name"]: item["id"] for item in mcu_config.get("code", [])}
        map_version = mcu_config.get("version", {})

        # 返回解析后的数据
        return {
            "order": order,
            "map": map_info,
            "code": code_info,
            "version": map_version,
        }
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        return None
    except yaml.YAMLError as e:
        print(f"YAML 解析错误: {e}")
        return None


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

def parse_multiplex_link_config(file_path):
    try:
        # 从文件中加载 YAML 内容
        with open(file_path, "r") as file:
            config = yaml.safe_load(file)

        # 提取 mcu 的内容
        mcu_config = config.get("multiplex_link_p1", {})
        order = mcu_config.get("order", [])
        map_info = {item["dev_addr"]: item["bin"] for item in mcu_config.get("map", [])}
        map_version = mcu_config.get("version", {})

        # 返回解析后的数据
        return {
            "order": order,
            "map": map_info,
            "version": map_version,
        }
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        return None
    except yaml.YAMLError as e:
        print(f"YAML 解析错误: {e}")
        return None

def upgrade_mcus():
    try:
        if not os.path.exists(get_mcu_update_dir_path()):
            logger("mcu 升级目录不存在，因此不对 MCU 升级")
            return 0

        ethercat_map = parse_ethercat_config(get_ethercat_config_path())
        if ethercat_map is None:
            logger("无法解析 ethercat 配置文件，请检查文件格式是否正确。")
            return -1
        get_map = parse_mcu_config(get_mcu_update_dir_path() + "/info.yaml")
        mcu_order = get_map.get("order", [])
        mcu_map = get_map.get("map", [])
        mcu_code = get_map.get("code", [])
        map_version = get_map.get("version", None)

        for mcu_name in mcu_order:
            logger(f"正在升级 {mcu_name}")
            if mcu_name not in ethercat_map:
                logger(f"{mcu_name} 不在 ethercat 配置文件中，无法升级。")
                return -1

            logger(mcu_map)
            bin_name = mcu_map.get(mcu_name, None)
            if bin_name is None:
                logger(f"{mcu_name} 在配置文件中没有找到对应的 bin 文件，无法升级。")
                return -1

            logger(mcu_code)
            code = mcu_code.get(mcu_name, None)
            if code is None:
                logger(f"{mcu_name} 在配置文件中没有找到对应的升级代码，无法升级。")
                return -1

            logger(ethercat_map)
            net_card = ethercat_map.get(mcu_name, None)
            if net_card is None:
                logger(
                    f"{mcu_name} 在 ethercat 配置文件中没有找到对应的网卡，无法升级。"
                )
                return -1
            net_card = " ".join(net_card)

            logger(map_version)
            if not mcu_name.startswith("mcu"):
                logger(f"{mcu_name} 不是mcu，无法升级。")
                return -1
            retry_count = 3
            count = 1
            current_version = ""
            while count <= retry_count:
                ret, current_version = get_mcu_version(net_card, mcu_name[3:])
                if ret != 0:
                    logger(f"获取 {mcu_name} 的版本号失败{count}次")
                    count+=1
                    time.sleep(3)
                else:
                    break
            if count >= retry_count:
                logger(f"获取 {mcu_name} 的版本号失败")
                return -1
            install_mcu_version = map_version.get(mcu_name, "")
            if install_mcu_version != "" and install_mcu_version == current_version:
                logger(f"{mcu_name} 的版本号与升级文件一致，无需升级。")
                continue

            logger(f"已安装版本：{current_version}，升级版本：{install_mcu_version}")

            logger(f"升级 {mcu_name}")
            if not mcu_name.startswith("mcu"):
                logger(f"{mcu_name} 升级失败。")
                return -1

            count = 1
            while count <= retry_count:
                if update_mcu_version(net_card,mcu_name[3:],code,get_mcu_update_dir_path() + f"/{bin_name}") != 0:
                    logger(f"{mcu_name} 升级失败{count}次")
                    count+=1
                    time.sleep(3)
                else:
                    break
            if count >= retry_count:
                logger(f"{mcu_name}升级失败")
                return -1

            logger(f"{mcu_name} 升级成功，睡眠30s")
            time.sleep(30)

        logger("升级完成")
        return 0
    except Exception as e:
        logger(f"无法解析 ethercat 配置文件，请检查文件格式是否正确, {e}")
        return -1


def get_xml_executable_path(executable_name: str):
    return os.path.join(get_mcu_update_dir_path(), f"{executable_name}")


def parse_xml_config(file_path):
    """
    解析 xml 配置的 YAML 文件，返回结构化数据。

    参数:
        file_path (str): YAML 文件路径。

    返回:
        dict: 包含解析结果的字典，ret, exe_name, xml_name: {bin_name, version}。
    """
    try:
        # 从文件中加载 YAML 内容
        with open(file_path, "r") as file:
            config = yaml.safe_load(file)

        # 提取 xml 的内容
        xml_config = config.get("xml_upgrade", None)
        if xml_config is None:
            logger("xml_upgrade 配置为空")
            return [0, None, None]

        exe_name = xml_config.get("exe_name", None)
        if exe_name is None:
            logger("exe_name 配置为空, 因此不升级")
            return [0, None, None]

        order = xml_config.get("order", [])
        vec_info = xml_config.get("map", {})

        map_info = {}
        for xml_name in order:
            is_find = False
            for name, bin_name, version in vec_info:
                if name == xml_name:
                    map_info[xml_name] = [bin_name, version]
                    is_find = True
                    break
            if not is_find:
                logger(f"{xml_name} 在配置文件中没有找到对应的 xml 文件，无法升级。")
                return [-1, None, None]
        return [0, exe_name, map_info]
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        return None
    except yaml.YAMLError as e:
        print(f"YAML 解析错误: {e}")
        return None


def get_robot_xml_version(tool_path: str, net_card: str) -> dict:
    logger(f"tool_path: {tool_path}, net_card: {net_card}")
    if not Path(tool_path).exists():
        logger(f"mcu 工具 {tool_path} 不存在")
        return {}

    execute_bash_command(f"sudo chmod +x {tool_path}")
    logger(f"执行命令: sudo {tool_path} {net_card} --map")
    xml_map = {}
    while xml_map == {}:
        try:
            logger(f"执行命令: sudo {tool_path} {net_card} --map")
            file_content = execute_bash_command(f"sudo {tool_path} {net_card} --map")
            if file_content[0] != 0:
                logger(f"执行命令失败: {file_content[1]}")
                return {}

            file_content = " ".join(file_content[1:])
            logger(f"file_content: {file_content}")
            matches = re.findall(r"Slave:\d+.*?Rev:\s+(\w+)", file_content, re.S)
            logger(f"matches: {matches}")
            # 输出结果
            if matches:
                for i, rev_value in enumerate(matches, start=1):
                    logger(f"xml:{i} 版本: {rev_value}")
                    xml_map[f"xml{i}"] = rev_value
            else:
                logger("未找到任何 xml 版本")
                break
        except Exception as e:
            logger(f"读取 xml 版本失败, 原因: {e}, 请检查遥控器状态是否正常")
            time.sleep(10)
    logger(f"xml_map: {xml_map}")
    return xml_map


def is_reboot(device_addr):
    retry_count=0
    flag = False
    while retry_count<5:
        time.sleep(5)
        ret, result = get_mcu_version_by_elink(device_addr)
        if ret == 0:
            flag = True
            break
        retry_count+=1

    if flag != True:
        logger(f"{device_addr}重启失败")
        return -1
    logger(f"{device_addr}重启成功")
    return 0

def judge_p1_t3():
    net_card = "eth_ecat eth_ecat2"
    mcu_number = 1
    retry_count = 3
    count = 1
    current_version = ""
    while count <= retry_count:
        ret, current_version = get_power_board_hardware_version(net_card, mcu_number)
        if ret !=0:
            logger(f"获取电源板硬件版本号失败{count}次")
            count+=1
            time.sleep(3)
        else:
            break
    if count >= retry_count:
        return [-1,None]
    
    version ="3.0.0"
    if current_version != version:
        if check_is_p1_by_software_version(net_card) ==0:
            return [0,"P1"]
        else:
            return[0,"T3"]
    return[0,"P1"]

def reboot_multiple_board_by_elink(device_addr):
    elink_path = get_ota_elink_tools_path()
    elink_path = Path(elink_path).resolve()
    logger(
        f"执行命令: {elink_path} reboot {device_addr}"
    )
    ret, _ = execute_bash_command(
        f"{elink_path} reboot {device_addr}"
    )
    if ret != 0:
        logger("重启多功能复用板失败。")
        return -1
    return 0

def upgrade_multiple_board_by_elink(mcu_name,bin_name):
    is_ok=True
    if(update_mcu_version_by_elink(mcu_name,get_mcu_update_dir_path() + f"/{bin_name}") !=0):
        logger(f"{mcu_name} 升级失败。")
        is_ok = False

    if(is_ok != True):
        for i in range(3):
            if(reboot_multiple_board_by_elink(1003) !=0):
                logger(f"多功能复用板重启失败")
                is_ok = False
                break
            else:
                if is_reboot(mcu_name) != 0:
                    is_ok = False
                    break
                if(update_mcu_version_by_elink(mcu_name,get_mcu_update_dir_path() + f"/{bin_name}") !=0):
                    logger(f"{mcu_name} 升级失败。")
                else:
                    is_ok = True
    return is_ok


def upgrade_mcus_by_elink():    
    ret,current_model = judge_p1_t3()
    if ret!=0:
        logger("判断机器型号失败")
        return -1
    model = "P1"
    if current_model != model:
        logger("不包含P1,不通过elink升级电源板")
        return 0
    
    logger("开始通过elink升级 MCU")
    if not os.path.exists(get_mcu_update_dir_path()):
        logger("mcu 升级目录不存在，因此不对 MCU 升级")
        return 0
    
    get_map = parse_multiplex_link_config(get_mcu_update_dir_path() + "/info.yaml")
    mcu_order = get_map.get("order", [])
    logger(f"multiplex order:{mcu_order}")
    mcu_map = get_map.get("map", [])
    logger(f"multiplex map:{mcu_map}")
    map_version = get_map.get("version", None)
    logger(f"multiplex version:{map_version}")

    for mcu_name in mcu_order:        
        bin_name = mcu_map.get(mcu_name, None)
        if bin_name is None:
            logger(f"{mcu_name} 在配置文件中没有找到对应的 bin 文件，无法升级。")
            return -1

        retry_count = 3
        count = 1
        current_version =""
        while count <= retry_count:
            ret,current_version = get_mcu_version_by_elink(mcu_name)
            if ret != 0:
                logger(f"获取 {mcu_name} 的版本号失败{count}次")
                count+=1
                time.sleep(3)
            else:
                break
        if count >= retry_count:
            logger(f"获取 {mcu_name} 的版本号失败")
            return -1
        
        install_mcu_version = map_version.get(mcu_name, "")
        if install_mcu_version != "" and install_mcu_version == current_version:
            logger(f"已安装版本:{current_version}，升级版本:{install_mcu_version}")
            logger(f"{mcu_name} 的版本号与升级文件一致，无需升级。")
            continue
        logger(f"已安装版本:{current_version}，升级版本:{install_mcu_version}")
        
        logger(f"升级 {mcu_name}")
        count = 1
        while count <= retry_count:
            if(upgrade_multiple_board_by_elink(mcu_name,bin_name)!=True):
                logger(f"{mcu_name}通过elink升级失败{count}次")
                count+=1
                time.sleep(3)
            else:
                break
        if count >= retry_count:
            logger(f"{mcu_name}通过elink升级失败")
            return -1

        if is_reboot(mcu_name) != 0:
            return -1
            
        time.sleep(5)
        logger(f"{mcu_name} 升级完成")
    logger("elink mcu升级完成")
    return 0


def upgrade_xml():
    try:
        if not os.path.exists(get_mcu_update_dir_path()):
            logger("mcu 升级目录不存在，因此不对 XML 升级")
            return 0

        ethercat_map = parse_ethercat_config(get_ethercat_config_path())
        if ethercat_map is None:
            logger("无法解析 ethercat 配置文件，请检查文件格式是否正确。")
            return -1

        logger(get_mcu_update_dir_path() + "/info.yaml")
        ret, exe_name, xml_map = parse_xml_config(
            get_mcu_update_dir_path() + "/info.yaml"
        )
        logger(f"ret: {ret}, exe_name: {exe_name}, xml_map: {xml_map}")
        if ret != 0:
            return -1

        if exe_name is None or xml_map is None:
            logger("exe_name 或 xml_map 为空，因此不升级")
            return 0

        logger(f"exe_name: {exe_name}")
        exe_path = get_xml_executable_path(exe_name)
        if not os.path.exists(exe_path):
            logger(f"{exe_name} 不存在，请检查文件是否存在")
            return -1

        logger(f"exe_path: {exe_path}")
        cmd = f"chmod +x {exe_path}"
        ret, _ = execute_bash_command(cmd)
        if ret != 0:
            logger(f"无法设置 {exe_path} 的权限，请检查文件是否存在")
            return -1

        robot_xml_version_map = get_robot_xml_version(
            get_read_xml_tool_path(), " ".join(ethercat_map.get("xml1"))
        )
        logger(f"robot_xml_version_map: {robot_xml_version_map}")
        logger(f"xml_map: {xml_map}")
        for key, value in xml_map.items():
            logger(f"正在升级 {key}")

            value = list(value)
            bin_path = get_mcu_update_dir_path() + f"/{value[0]}"
            version = value[1]
            robot_xml_version = robot_xml_version_map.get(key, "")
            if robot_xml_version == version:
                logger(f"{key} 的版本号与升级文件一致，无需升级。")
                continue

            if not os.path.exists(bin_path):
                logger(f"{bin_path} 不存在，请检查文件是否存在")
                return -1

            logger(ethercat_map)
            net_card = ethercat_map.get(key, None)
            if net_card is None:
                logger(f"{key} 在 ethercat 配置文件中没有找到对应的网卡，无法升级。")
                return -1
            net_card = " ".join(net_card)

            cmd = f"{exe_path} {net_card} {key[3:]} -wi {bin_path}"
            ret, _ = execute_bash_command(cmd)
            if ret != 0:
                logger(f"{cmd} 执行失败")
                return -1

            logger(f"{key} 升级成功，睡眠30s")
            time.sleep(30)

        logger("升级完成")
        return 0
    except Exception as e:
        logger(f"无法解析 ethercat 配置文件，请检查文件格式是否正确, {e}")
        return -1


if __name__ == "__main__":
    import sys

    logger("开始升级 MCU")
    if upgrade_mcus() != 0:
        logger("升级 MCU 失败")
        sys.exit(-1)

    logger("开始升级 XML")
    if upgrade_xml() != 0:
        logger("升级 XML 失败")
        sys.exit(-1)

    if upgrade_mcus_by_elink() != 0:
        logger("通过elink升级 MCU 失败")
        sys.exit(-1)

    logger("升级完成")
    sys.exit(0)