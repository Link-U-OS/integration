import os
import subprocess
import json
import yaml
import sys
import re
import time

# JSON 路径（修改为 home 目录）
user_dir = os.path.expanduser('~')
JSON_PATH = os.path.join(user_dir, 'devices.json')

# YAML 输出路径
YAML_OUTPUT_PATH = "/agibot/data/param/hal/aimrte_hal_index.yaml"

# brand 映射表（除 xinying 外）
BRAND_MAPPING = {
    "realsense": "realsense_d415_head_front",
    "orbbec": "dcw2_waist_front",
    "livox": "mid360_top"
}

def extract_serial_number_number_part(serial: str):
    matches = re.findall(r'\d+', serial)
    if not matches:
        return -1
    return int(matches[-1])

def find_app_path(root_dir="/agibot/software/v0/", target_filename="aima-hal-app-detect_devices"):
    find_cmd = ["find", root_dir, "-type", "f", "-name", target_filename, "-print", "-quit"]
    print(f"[DEBUG] 查找序列号配置程序: {' '.join(find_cmd)}")

    try:
        result = subprocess.run(
            find_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding='utf-8',
            check=True
        )
        path = result.stdout.strip()
        if path:
            return path
        else:
            return None
    except subprocess.CalledProcessError as e:
        print(f"[WARNING] find 命令执行失败: {e}")
        return None

def reset_usb_power(bus_gpio: int):
    print(f"正在重启 Realsense D415 相机 usb 电源: gpio=usb3_p{bus_gpio}_en")
    gpio_path = f"/sys/class/tz_gpio/usb3_p{bus_gpio}_en/value"

    if not os.path.exists(gpio_path):
        print(f"[Error]: GPIO 控制路径不存在: {gpio_path}")
        return False

    try:
        with open(gpio_path, 'w') as f:
            f.write('0')
        print(f"[Success]: Disabled USB3_P{bus_gpio}_EN")
    except Exception as e:
        print(f"[Failed]: Failed to disable USB3_P{bus_gpio}_EN: {e}")

    time.sleep(2)

    try:
        with open(gpio_path, 'w') as f:
            f.write('1')
        print(f"[Success]: Enabled USB3_P{bus_gpio}_EN")
    except Exception as e:
        print(f"[Failed]: Failed to enable USB3_P{bus_gpio}_EN: {e}")

    time.sleep(2)
    print(f"完成重启 Realsense D415 相机 usb 电源 (gpio=usb3_p{bus_gpio}_en)")
    return True

def reset_by_bus_number(bus_str: str):
    if bus_str == "001":
        reset_usb_power(3)
    elif bus_str in ("003", "005"):
        reset_usb_power(6)
    else:
        print(f"[Warning]: 未知 Bus{bus_str}，尝试全部重启")
        reset_usb_power(3)
        reset_usb_power(6)

def check_usb_speed():
    try:
        device_info = subprocess.check_output(["lsusb"], encoding='utf-8')
        match_line = next((line for line in device_info.splitlines() if "415" in line), None)
        if not match_line:
            print("错误：未找到包含 Realsense D415 的 USB 设备")
            reset_usb_power(3)
            reset_usb_power(6)
            return False

        bus_str = match_line.split()[1]
        bus_num = str(int(bus_str))  # 去除前导0

        lsusb_t_output = subprocess.check_output(["lsusb", "-t"], encoding="utf-8")
        speed_line = next((line for line in lsusb_t_output.splitlines() if f"Bus 0{bus_num}" in line), "")
        match = re.search(r'(\d+[MG])', speed_line)
        speed = match.group(1) if match else None

        print(f"Realsense D415 相机挂载在 Bus{bus_str}，速率为: {speed}")

        if speed in ("10000M", "5000M"):
            print(f"✅ 相机连接速率正常 ({speed})")
            return True
        elif speed == "480M":
            print(f"❌ 检测到 USB2.0 ({speed})，执行电源重启")
            reset_by_bus_number(bus_str)
            return False
        else:
            print(f"❌ 未知速率 ({speed})，执行电源重启")
            reset_by_bus_number(bus_str)
            return False
    except Exception as e:
        print(f"[ERROR] 检查 USB 速率失败: {e}")
        reset_usb_power(3)
        reset_usb_power(6)
        return False

def main():
    # Step 1: 检查检测程序是否存在
    app_path = find_app_path()
    if not app_path:
        print("[WARNING] 未找到序列号配置程序，跳过序列号配置")
        sys.exit(0)


    # Step 1-1: 执行reset脚本解决部署时未识别到相机的问题
    print("[INFO] 正在检查 Realsense D415 相机 USB 接口速率...")
    for i in range(3):
        if check_usb_speed():
            print("✅ Realsense D415 相机 USB 接口速率检查通过")
            break
        else:
            print(f"⚠️ 第 {i+1} 次检测失败，等待重试...")
            time.sleep(3)
    else:
        print("❌ 多次检查失败，Realsense D415 相机连接异常")

    # Step 1-2: 打印系统信息
    try:
        print("\n[INFO] 当前 USB 设备 (lsusb):")
        lsusb_output = subprocess.check_output(["lsusb"], encoding='utf-8')
        print(lsusb_output)
    except Exception as e:
        print(f"[WARNING] 执行 lsusb 失败: {e}")

    try:
        print("\n[INFO] 当前网络接口状态 (ifconfig):")
        ifconfig_output = subprocess.check_output(["ifconfig"], encoding='utf-8')
        print(ifconfig_output)
    except Exception as e:
        print(f"[WARNING] 执行 ifconfig 失败: {e}")

    # Step 2: 执行检测程序
    try:
        print(f"[INFO] 正在以 sudo 权限运行: {app_path}")
        subprocess.run(["sudo", app_path], check=True,cwd=user_dir)
    except subprocess.CalledProcessError as e:
        print(f"[WARNING] 程序运行失败: {e}")
        sys.exit(0)

    # Step 3: 检查 JSON 是否生成
    if not os.path.exists(JSON_PATH):
        print(f"[WARNING] JSON 文件未生成: {JSON_PATH}")
        sys.exit(0)
    else:
        print(f"[INFO] JSON 文件已找到: {JSON_PATH}")

    # Step 4: 解析 JSON
    try:
        with open(JSON_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"[WARNING] JSON 解析失败: {e}")
        sys.exit(0)

    result = {}

    # Step 5: 处理非 xinying 设备
    for category in ['cameras', 'lidars']:
        devices = data.get(category, [])
        for device in devices:
            brand = device.get("brand")
            serial = device.get("serialNumber")
            if not brand or not serial:
                continue

            if brand == "xinying":
                continue
            if brand in BRAND_MAPPING:
                key = BRAND_MAPPING[brand]
                result[key] = serial

    # Step 6: 处理 xinying
    xinying_serials = []
    for device in data.get("cameras", []):
        if device.get("brand") == "xinying":
            serial = device.get("serialNumber")
            if serial:
                num = extract_serial_number_number_part(serial)
                xinying_serials.append((num, serial))

    if len(xinying_serials) == 2:
        xinying_serials.sort(key=lambda x: x[0])
        result["xinying_chest_left"] = xinying_serials[0][1]
        result["xinying_chest_right"] = xinying_serials[1][1]
    elif len(xinying_serials) == 1:
        result["xinying_chest_left"] = xinying_serials[0][1]
    elif len(xinying_serials) > 2:
        print("[WARNING] 检测到超过 2 个 xinying 设备，仅使用其中两个")

    # Step 7: 写入 YAML
    try:
        os.makedirs(os.path.dirname(YAML_OUTPUT_PATH), exist_ok=True)
        with open(YAML_OUTPUT_PATH, 'w', encoding='utf-8') as f:
            yaml.dump(result, f, allow_unicode=True, default_flow_style=False)
        print(f"[INFO] 成功写入 YAML: {YAML_OUTPUT_PATH}，成功配置传感器序列号")
    except Exception as e:
        print(f"[WARNING] 写入 YAML 文件失败: {e}")
        sys.exit(0)

if __name__ == "__main__":
    main()
