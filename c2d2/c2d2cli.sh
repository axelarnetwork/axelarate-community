#!/bin/sh
set -e

GIT_ROOT=$(git rev-parse --show-toplevel)
config_dir=${C2D2_HOME:-"$HOME/.c2d2cli"}
clef_dir=${CLEF_HOME:-"$HOME/.c2d2clef"}
C2D2_VERSION=""
CHAIN_ID="3"
IMAGE="axelarnet/c2d2"
RESET_C2D2=false

reset_c2d2 () {
  echo "Resetting c2d2 config. Your keys will not be deleted."
  rm -rf $config_dir/data
  rm $config_dir/config.toml
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
    --chain-id)
      CHAIN_ID="$2"
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
  echo "'--version vX.Y.Z' is required"
  exit 1
fi

sh "${GIT_ROOT}"/c2d2/config.sh
docker run -it \
  --entrypoint="/entrypoint.sh"  \
  --env CLEF_CHAINID="$CHAIN_ID"             \
  -v "${config_dir}":/root/.c2d2cli \
  -v "${config_dir}":/root/.clef \
  --net=host --add-host=host.docker.internal:host-gateway \
  "${IMAGE}":"${C2D2_VERSION}" bash
