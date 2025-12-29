#!/bin/sh

cd $(dirname $0)

(cd ./replace_data/ && bash run_init_info.sh)

echo "success"

exit 0