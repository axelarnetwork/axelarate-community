#!/usr/bin/env bash
SRC=$(git rev-parse --show-toplevel)

config_file=${SRC}/c2d2/config.toml
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}

echo "Setting up c2d2 configuration in $config_dir"
mkdir -p $config_dir

if [[ -e ${config_dir}/config.toml ]]; then
  echo "Moving existing config.toml to ${config_dir}/config.old.toml"
  mv ${config_dir}/config.toml ${config_dir}/config.old.toml
fi

cp $config_file $config_dir/
