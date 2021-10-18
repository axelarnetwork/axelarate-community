#!/usr/bin/env bash

AXELAR_CORE_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep axelar-core | cut -d \` -f 4)"
TOFND_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep tofnd | cut -d \` -f 4)"
RESET_CHAIN=false
ROOT_DIRECTORY=~/.axelar_testnet
GIT_ROOT="$(git rev-parse --show-toplevel)"
TENDERMINT_KEY_PATH=""
AXELAR_MNEMONIC_PATH=""
DOCKER_NETWORK="axelarate_default"

for arg in "$@"; do
  case $arg in
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

addPersistentPeers() {
  persistent_peers="$(cat $SHARED_DIRECTORY/persistent-peers.txt)"
  sed "s/^persistent_peers =.*/persistent_peers = \"$persistent_peers\"/g" "${SHARED_DIRECTORY}/config.toml" > "${SHARED_DIRECTORY}/config.toml.tmp"
  mv "${SHARED_DIRECTORY}/config.toml.tmp" "${SHARED_DIRECTORY}/config.toml"
}

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
  rm -rf "$ROOT_DIRECTORY"
fi

mkdir -p "$ROOT_DIRECTORY"

SHARED_DIRECTORY="${ROOT_DIRECTORY}/shared"
mkdir -p "$SHARED_DIRECTORY"

CORE_DIRECTORY="${ROOT_DIRECTORY}/.core"
mkdir -p "$CORE_DIRECTORY"

if [ ! -f "${SHARED_DIRECTORY}/genesis.json" ]; then
  curl --silent https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o "${SHARED_DIRECTORY}/genesis.json"
fi

echo "Downloading latest persistent peers"
curl --silent https://axelar-testnet.s3.us-east-2.amazonaws.com/persistent-peers.txt -o "${SHARED_DIRECTORY}/persistent-peers.txt"

echo "Overwriting stale config.toml to config directory"
cp "${GIT_ROOT}/join/config.toml" "${SHARED_DIRECTORY}/config.toml"

echo "Adding persistent peers to config"
addPersistentPeers

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
  --env START_REST=true                                \
  --env PRESTART_SCRIPT=/root/shared/consumeGenesis.sh \
  --env CONFIG_PATH=/root/shared/                      \
  --env AXELAR_MNEMONIC_PATH=$AXELAR_MNEMONIC_PATH     \
  --env TENDERMINT_KEY_PATH=$TENDERMINT_KEY_PATH       \
  -v "${CORE_DIRECTORY}/:/root/.axelar"                \
  -v "${SHARED_DIRECTORY}:/root/shared"                \
  "axelarnet/axelar-core:${AXELAR_CORE_VERSION}" startNodeProc

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
