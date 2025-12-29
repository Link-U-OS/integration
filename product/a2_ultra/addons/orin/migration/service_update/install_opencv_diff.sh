#!/bin/bash

cd $(dirname $0)

echo -e "\033[32m install opencv diff \033[0m"

cp -rp ./opencv_diff/* /lib/

echo -e "\033[32m install opencv diff success \033[0m"
