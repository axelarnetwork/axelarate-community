#!/usr/bin/env bash
GIT_ROOT=$(git rev-parse --show-toplevel)

config_file=${GIT_ROOT}/c2d2/config.toml
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}

mkdir -p $config_dir

if [[ ! -e ${config_dir}/config.toml ]]; then
  echo "Setting up c2d2 configuration in $config_dir"
  cp $config_file $config_dir/
fi
