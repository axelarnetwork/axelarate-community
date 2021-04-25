#!/usr/bin/env bash

set -e

AXELAR_CORE_VERSION=""
TOFND_VERSION=""
RESET_CHAIN=false
ROOT_DIRECTORY=~/.axelar
GIT_ROOT="$(git rev-parse --show-toplevel)"

for arg in "$@"; do
  case $arg in
    --reset-chain)
    RESET_CHAIN=true
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

if $RESET_CHAIN; then
  rm -rf "$ROOT_DIRECTORY"
fi

mkdir -p "$ROOT_DIRECTORY"

SHARED_DIRECTORY="${ROOT_DIRECTORY}/shared"
mkdir -p "$SHARED_DIRECTORY"

if [ ! -f "${SHARED_DIRECTORY}/genesis.json" ]; then
  curl https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o "${SHARED_DIRECTORY}/genesis.json"
fi

if [ ! -f "${SHARED_DIRECTORY}/peers.txt" ]; then
  curl https://axelar-testnet.s3.us-east-2.amazonaws.com/peers.txt -o "${SHARED_DIRECTORY}/peers.txt"
fi

if [ ! -f "${SHARED_DIRECTORY}/config.toml" ]; then
  cp "${GIT_ROOT}/join/config.toml" "${SHARED_DIRECTORY}/config.toml"
fi

if [ ! -f "${SHARED_DIRECTORY}/consumeGenesis.sh" ]; then
  cp "${GIT_ROOT}/join/consumeGenesis.sh" "${SHARED_DIRECTORY}/consumeGenesis.sh"
fi

docker run       \
  --name tofnd   \
  -d             \
  -p 50051:50051 \
  "axelarnet/tofnd:${TOFND_VERSION}"

docker run                                           \
  --name axelar-core                                 \
  -p 1317:1317                                       \
  -p 26656-26658:26656-26658                         \
  -p 26660:26660                                     \
  --env TOFND_HOST=host.docker.internal              \
  --env START_REST=true                              \
  --env PEERS_FILE=/root/shared/peers.txt            \
  --env INIT_SCRIPT=/root/shared/consumeGenesis.sh   \
  --env CONFIG_PATH=/root/shared/config.toml         \
  -v "${ROOT_DIRECTORY}/.axelard:/root/.axelard"     \
  -v "${ROOT_DIRECTORY}/.axelarcli:/root/.axelarcli" \
  -v "${SHARED_DIRECTORY}:/root/shared"              \
  "axelarnet/axelar-core:${AXELAR_CORE_VERSION}"
