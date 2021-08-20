#!/bin/sh
set -e

AXELAR_CORE_VERSION=""
TOFND_VERSION=""
ROOT_DIRECTORY=~/.axelar_testnet

for arg in "$@"; do
  case $arg in
    -r|--root)
    ROOT_DIRECTORY="$2"
    shift
    ;;
    --axelar-core)
    AXELAR_CORE_VERSION="$2"
    shift
    ;;
    --tofnd)
    TOFND_VERSION="$2"
    shift
    ;;
    *)
    shift
    ;;
  esac
done

if [ -z "$AXELAR_CORE_VERSION" ]; then
  echo "'--axelar-core vX.Y.Z' is required"
  exit 1
fi

if [ -z "$TOFND_VERSION" ]; then
  echo "'--tofnd vX.Y.Z' is required"
  exit 1
fi

if [ ! -d "$ROOT_DIRECTORY" ]; then
  echo "Root directory does not exist"
  exit 1
fi

SHARED_DIRECTORY="${ROOT_DIRECTORY}/shared"
if [ ! -d "$SHARED_DIRECTORY" ]; then
  echo "Shared directory does not exist"
  exit 1
fi

NODE_UP="$(docker ps --format '{{.Names}}' | grep -w 'axelar-core')"
if [ -z "$NODE_UP" ]; then
  echo "No node running"
  exit 1
fi

VALD_DIRECTORY="${ROOT_DIRECTORY}/.vald"
mkdir -p "$VALD_DIRECTORY"

TOFND_DIRECTORY="${ROOT_DIRECTORY}/.tofnd"
mkdir -p "$TOFND_DIRECTORY"

docker run                              \
  -d                                    \
  --rm                                  \
  --name tofnd                          \
  -v "${TOFND_DIRECTORY}/:/root/.tofnd" \
  "axelarnet/tofnd:${TOFND_VERSION}"

VALIDATOR=$(cat "$SHARED_DIRECTORY/validator.bech")
BROADCASTER=$(cat "$SHARED_DIRECTORY/broadcaster.bech")

docker run                                       \
  -d                                             \
  --rm                                           \
  --name vald                                    \
  --env TOFND_HOST=tofnd                         \
  --env VALIDATOR_HOST=http://axelar-core:26657  \
  --env INIT_SCRIPT=/root/shared/initVald.sh     \
  --env CONFIG_PATH=/root/shared/                \
  --env SLEEP_TIME=20s                           \
  --env PEERS_FILE=/root/shared/peers.txt        \
  --env VALIDATOR_ADDR=$VALIDATOR                \
  --env RECOVERY_FILE=/root/shared/recovery.json \
  -v "${VALD_DIRECTORY}/.axelar:/root/.axelar"   \
  -v "${SHARED_DIRECTORY}:/root/shared"          \
  "axelarnet/axelar-core:${AXELAR_CORE_VERSION}"

echo
echo "Validator address: $VALIDATOR"
echo "Proxy address: $BROADCASTER"
echo
