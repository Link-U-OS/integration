#! /bin/bash

echo "run_iox_roudi.sh"

export LD_LIBRARY_PATH=/agibot/software/v0/bin:$LD_LIBRARY_PATH
taskset -c 11 /agibot/software/v0/bin/iox-roudi --config-file=${AGIBOT_HOME}/agibot/software/v0/entry/bin/cfg/roudi_config.toml -m on
