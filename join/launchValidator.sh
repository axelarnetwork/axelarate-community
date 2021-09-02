#!/bin/sh

AXELAR_CORE_VERSION=""
TOFND_VERSION=""
ROOT_DIRECTORY=~/.axelar_testnet
GIT_ROOT="$(git rev-parse --show-toplevel)"
TOFND_MNEMONIC_PATH=""
AXELAR_MNEMONIC_PATH=""
RECOVERY_INFO_PATH=""
DOCKER_NETWORK="axelarate_default"

for arg in "$@"; do
  case $arg in
    --proxy-mnemonic)
    AXELAR_MNEMONIC_PATH="$2"
    shift
    ;;
    --tofnd-mnemonic)
    TOFND_MNEMONIC_PATH="$2"
    shift
    ;;
    --recovery-info)
    RECOVERY_INFO_PATH="$2"
    shift
    ;;
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

if [ -f "$RECOVERY_INFO_PATH" ]; then
  cp -f "$RECOVERY_INFO_PATH" "$VALD_DIRECTORY/recovery.json"
fi

CMD=create
if [ -f "$TOFND_MNEMONIC_PATH" ]; then
  cp -f "$TOFND_MNEMONIC_PATH" "$TOFND_MNEMONIC_PATH/import"
  CMD=import
fi

if [ ! -f "${SHARED_DIRECTORY}/initVald.sh" ]; then
  cp "${GIT_ROOT}/join/initVald.sh" "${SHARED_DIRECTORY}/initVald.sh"
fi

set -e

docker run                              \
  -d                                    \
  --rm                                  \
  --name tofnd                          \
  --network "$DOCKER_NETWORK"           \
  --env MNEMONIC_CMD=$CMD               \
  -v "${TOFND_DIRECTORY}/:/root/.tofnd" \
  "axelarnet/tofnd:${TOFND_VERSION}"

VALIDATOR=$(docker exec axelar-core sh -c "axelard keys show validator -a --bech val")

docker run                                         \
  -d                                               \
  --rm                                             \
  --name vald                                      \
  --network "$DOCKER_NETWORK"                      \
  --env TOFND_HOST=tofnd                           \
  --env VALIDATOR_HOST=http://axelar-core:26657    \
  --env PRESTART_SCRIPT=/root/shared/initVald.sh   \
  --env CONFIG_PATH=/root/shared/                  \
  --env SLEEP_TIME=2s                              \
  --env VALIDATOR_ADDR=$VALIDATOR                  \
  --env RECOVERY_FILE=/root/.axelar/recovery.json  \
  --env AXELAR_MNEMONIC_PATH=$AXELAR_MNEMONIC_PATH \
  -v "${VALD_DIRECTORY}/:/root/.axelar"            \
  -v "${SHARED_DIRECTORY}/:/root/shared"           \
  "axelarnet/axelar-core:${AXELAR_CORE_VERSION}" startValdProc

sleep 2s
BROADCASTER=$(docker exec vald sh -c "axelard keys show broadcaster -a")

echo
echo "Tofnd & Vald running."
echo
echo "Proxy address: $BROADCASTER"
echo
echo "To become a validator get some uaxl tokens from the faucet and stake them"
echo

docker exec vald sh -c "cat /broadcaster.txt"
docker exec vald sh -c "rm -f /broadcaster.txt"
echo
echo "Do not forget to also backup the tofnd mnemonic (${TOFND_DIRECTORY}/export)"
echo
echo "To follow tofnd execution, run 'docker logs -f tofnd'"
echo "To follow vald execution, run 'docker logs -f vald'"
echo "To stop tofnd, run 'docker stop tofnd'"
echo "To stop vald, run 'docker stop vald'"
echo
