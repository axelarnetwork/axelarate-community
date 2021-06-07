#!/usr/bin/env bash
GIT_ROOT=$(git rev-parse --show-toplevel)

config_file=${GIT_ROOT}/c2d2/config.toml
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}

mkdir -p $config_dir

if [ -e "${config_dir}"/config.toml ]; then
  echo "Moving existing config.toml to ${config_dir}/config.old.toml"
  mv ${config_dir}/config.toml ${config_dir}/config.old.toml
fi

if [ ! -e "${config_dir}"/config.toml ]; then
  echo "Copying config.toml to $config_dir"
  cp $config_file $config_dir/
fi
