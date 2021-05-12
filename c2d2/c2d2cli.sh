#!/bin/sh
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}
GIT_ROOT=$(git rev-parse --show-toplevel)
sh "${GIT_ROOT}"/c2d2/config.sh
docker run -it --entrypoint=""  -v "${config_dir}":/root/.c2d2cli --net=host --add-host=host.docker.internal:host-gateway axelarnet/c2d2:v0.1.0 bash
