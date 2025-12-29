#! /usr/bin/env python3
# -*- coding: utf-8 -*-


# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

import sys
import os
import re


class ROS2TypeSupportGenerator(object):
    t_one_get_type_support: str = r"""
  ::aimrt::GetRos2MessageTypeSupport<::{{message_namespace}}::msg::{{message_type}}>(),
"""

    t_one_include_file: str = r"""
#include <{{message_namespace}}/msg/{{file_name}}.hpp>
"""

    t_type_support_main: str = """/**
 * @brief 此文件由protoc_plugin_gen_aimrt_cc_type_support_ros2.py自动生成，请勿手动修改！
 */

#include "src/interface/aimrt_type_support_pkg_c_interface/type_support_pkg_main.h"
#include "src/interface/aimrt_module_ros2_interface/util/ros2_type_support.h"

{{include_files}}

static const aimrt_type_support_base_t* type_support_array[]{
  {{get_type_supports}}
};

extern "C"
{
size_t AimRTDynlibGetTypeSupportArrayLength()
{
  return sizeof(type_support_array) / sizeof(type_support_array[0]);
}

const aimrt_type_support_base_t** AimRTDynlibGetTypeSupportArray()
{
  return type_support_array;
}
}
"""

    def generate_type_support(self, msg_files, package_name):
        """生成ROS2类型支持代码"""
        get_type_supports = ""
        include_files = ""

        for msg_file in msg_files:
            # 生成include语句
            base_name = os.path.splitext(os.path.basename(msg_file))[0]
            include_files += self.t_one_include_file \
                .replace("{{file_name}}", self.include_file_trans(base_name)) \
                .replace("{{message_namespace}}", package_name)

            # 生成类型支持
            one_type_support = self.t_one_get_type_support \
                .replace("{{message_namespace}}", package_name) \
                .replace("{{message_type}}", base_name)
            get_type_supports += one_type_support

        # 生成完整的输出文件内容
        content = self.t_type_support_main \
            .replace("{{get_type_supports}}", get_type_supports) \
            .replace("{{include_files}}", include_files)

        return content

    def include_file_trans(self, file_name):
        name, ext = os.path.splitext(file_name)

        s1 = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', name)
        s2 = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1_\2', s1)

        return s2.lower() + ext


def main():
    if len(sys.argv) < 4:
        print("用法: ros2_type_support_generator.py --pkg_name=<包名> --msg_files=<消息文件列表> --output=<输出路径>")
        sys.exit(1)

    package_name = ""
    msg_files = []
    output_path = ""

    for arg in sys.argv[1:]:
        key, value = arg.split('=')
        if key == '--pkg_name':
            package_name = value
        elif key == '--msg_files':
            msg_files = value.split(',')
        elif key == '--output':
            output_path = value
    generator = ROS2TypeSupportGenerator()
    content = generator.generate_type_support(msg_files, package_name)

    # 写入输出文件
    output_file = os.path.join(output_path, "type_support_main.cpp")
    with open(output_file, 'w') as f:
        f.write(content)


if __name__ == '__main__':
    main()
