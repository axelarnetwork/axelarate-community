#!/bin/sh
set -e

GIT_ROOT=$(git rev-parse --show-toplevel)
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}
C2D2_VERSION=""
IMAGE="axelarnet/c2d2"
RESET_C2D2=false

reset_c2d2 () {
  echo "Resetting c2d2 config. Your keys will not be deleted."
  rm -rf $config_dir/data
  rm $config_dir/config.toml
}

usage () {
  echo "Usage:  c2d2cli.sh --version vX.Y.Z [--reset,--image]"
  echo ""
  echo "Options:"
  printf "  --reset\treset store (clear persisted transfer jobs)\n"
  printf "  --version\tc2d2 image version tag\n"
  printf "  --image\tc2d2 image\n"
  echo "" 1>&2; exit 1;
}

for arg in "$@"; do
  case $arg in
    --reset)
    RESET_C2D2=true
    shift
    ;;
    --version)
      C2D2_VERSION="$2"
    shift
    ;;
    --image)
      IMAGE="$2"
    shift
    ;;
    *)
    shift
    ;;
  esac
done

if [ $RESET_C2D2 = true ]; then
  reset_c2d2
fi

if [ -z "$C2D2_VERSION" ]; then
  echo "Flag '--version vX.Y.Z' is required"
  usage
fi

sh "${GIT_ROOT}"/c2d2/config.sh
docker run -it \
  --entrypoint="bash"  \
  -v "${config_dir}":/root/.c2d2cli \
  --net=host --add-host=host.docker.internal:host-gateway \
  "${IMAGE}":"${C2D2_VERSION}"
