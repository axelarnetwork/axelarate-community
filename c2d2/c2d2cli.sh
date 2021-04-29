#!/bin/sh
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}
SRC=$(git rev-parse --show-toplevel)
sh ${src}/c2d2/install.sh
docker run -it --entrypoint=""  -v "$config_dir":/root/.c2d2cli --add-host=host.docker.internal:host-gateway axelar/c2d2cli:latest bash
