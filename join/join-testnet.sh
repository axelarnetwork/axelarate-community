#!/usr/bin/env bash

AXELAR_CORE_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep axelar-core | cut -d \` -f 4)"
TOFND_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep tofnd | cut -d \` -f 4)"
RESET_CHAIN=false
STOP_ME=true
ROOT_DIRECTORY=~/.axelar_testnet
GIT_ROOT="$(git rev-parse --show-toplevel)"
TENDERMINT_KEY_PATH=""
AXELAR_MNEMONIC_PATH=""
DOCKER_NETWORK="axelarate_default"

for arg in "$@"; do
  case $arg in
    --dev)
    STOP_ME=false
    shift
    ;;
    --validator-mnemonic)
    AXELAR_MNEMONIC_PATH="$2"
    shift
    ;;
    --tendermint-key)
    TENDERMINT_KEY_PATH="$2"
    shift
    ;;
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
    *)
    shift
    ;;
  esac
done

if [ "$(git rev-parse --abbrev-ref HEAD)" == "main" ] && $STOP_ME; then
  echo "Please checkout the correct version tag. See README for instructions."
  exit 1
fi

if [ -z "$AXELAR_CORE_VERSION" ]; then
  echo "'--axelar-core vX.Y.Z' is required"
  exit 1
fi

NODE_UP="$(docker ps --format '{{.Names}}' | grep -w 'axelar-core')"
if [ -n "$NODE_UP" ]; then
  echo "Node is already running"
  exit 1
fi

NETWORK_PRESENT="$(docker network ls --format '{{.Name}}' | grep -w $DOCKER_NETWORK)"
if [ -z "$NETWORK_PRESENT" ]; then
  docker network create "$DOCKER_NETWORK" --driver=bridge --scope=local
fi

if $RESET_CHAIN; then
  echo
  echo "WARNING! This will erase all previously stored data. Your node will catch up from the beginning"
  printf "Do you wish to proceed \"y/n\" ?  "
  read -r REPLY
  if [ $REPLY = "y" ]; then
    echo "Resetting state"
    rm -rf "$ROOT_DIRECTORY"
  else
    echo "Proceeding without resetting state"
  fi
fi


mkdir -p "$ROOT_DIRECTORY"

SHARED_DIRECTORY="${ROOT_DIRECTORY}/shared"
mkdir -p "$SHARED_DIRECTORY"

CORE_DIRECTORY="${ROOT_DIRECTORY}/.core"
mkdir -p "$CORE_DIRECTORY"

if [ ! -f "${SHARED_DIRECTORY}/genesis.json" ]; then
  curl -s https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o "${SHARED_DIRECTORY}/genesis.json"
fi

if [ ! -f "${SHARED_DIRECTORY}/seeds.txt" ]; then
  curl https://axelar-testnet.s3.us-east-2.amazonaws.com/seeds.txt -o "${SHARED_DIRECTORY}/seeds.txt"
fi

echo "Overwriting stale config.toml to config directory with latest seeds"
cp "${GIT_ROOT}/join/config.toml" "${SHARED_DIRECTORY}/config.toml"

if [ ! -f "${SHARED_DIRECTORY}/app.toml" ]; then
  cp "${GIT_ROOT}/join/app.toml" "${SHARED_DIRECTORY}/app.toml"
fi

if [ ! -f "${SHARED_DIRECTORY}/consumeGenesis.sh" ]; then
  cp "${GIT_ROOT}/join/consumeGenesis.sh" "${SHARED_DIRECTORY}/consumeGenesis.sh"
fi

set -e

docker run                                             \
  -d                                                   \
  --rm                                                 \
  --name axelar-core                                   \
  --network "$DOCKER_NETWORK"                          \
  -p 1317:1317                                         \
  -p 26656-26658:26656-26658                           \
  -p 26660:26660                                       \
  -p 9090:9090                                         \
  --env START_REST=true                                \
  --env PRESTART_SCRIPT=/root/shared/consumeGenesis.sh \
  --env CONFIG_PATH=/root/shared/                      \
  --env AXELAR_MNEMONIC_PATH=$AXELAR_MNEMONIC_PATH     \
  --env TENDERMINT_KEY_PATH=$TENDERMINT_KEY_PATH       \
  --env PEERS_FILE=/root/shared/seeds.txt              \
  -v "${CORE_DIRECTORY}/:/root/.axelar"                \
  -v "${SHARED_DIRECTORY}:/root/shared"                \
  "axelarnet/axelar-core:${AXELAR_CORE_VERSION}" startNodeProc

sleep 5

VALIDATOR=$(docker exec axelar-core sh -c "axelard keys show validator -a --bech val")

echo
echo "Axelar node running."
echo
echo "Validator address: $VALIDATOR"
echo
docker exec axelar-core sh -c "cat /validator.txt"
docker exec axelar-core sh -c "rm -f /validator.txt"
echo
echo "Do not forget to also backup the tendermint key (${CORE_DIRECTORY}/config/priv_validator_key.json)"
echo
echo "To follow execution, run 'docker logs -f axelar-core'"
echo "To stop the node, run 'docker stop axelar-core'"
echo
