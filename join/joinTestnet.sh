#!/usr/bin/env bash

set -e

AXELAR_CORE_VERSION=""
TOFND_VERSION=""
RESET_CHAIN=false
ROOT_DIRECTORY=~/.axelar_testnet
GIT_ROOT="$(git rev-parse --show-toplevel)"
TENDERMINT_KEY=""
AXELAR_MNEMONIC=""

for arg in "$@"; do
  case $arg in
    --validator-mnemonic)
    AXELAR_MNEMONIC="$2"
    shift
    ;;
    --tendermint-key)
    TENDERMINT_KEY="$2"
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

CORE_DIRECTORY="${ROOT_DIRECTORY}/.core"
mkdir -p "$CORE_DIRECTORY"

if [ ! -f "${SHARED_DIRECTORY}/genesis.json" ]; then
  curl https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o "${SHARED_DIRECTORY}/genesis.json"
fi

if [ ! -f "${SHARED_DIRECTORY}/peers.txt" ]; then
  curl https://axelar-testnet.s3.us-east-2.amazonaws.com/peers.txt -o "${SHARED_DIRECTORY}/peers.txt"
fi

if [ ! -f "${SHARED_DIRECTORY}/config.toml" ]; then
  cp "${GIT_ROOT}/join/config.toml" "${SHARED_DIRECTORY}/config.toml"
fi

if [ ! -f "${SHARED_DIRECTORY}/app.toml" ]; then
  cp "${GIT_ROOT}/join/app.toml" "${SHARED_DIRECTORY}/app.toml"
fi

if [ ! -f "${SHARED_DIRECTORY}/consumeGenesis.sh" ]; then
  cp "${GIT_ROOT}/join/consumeGenesis.sh" "${SHARED_DIRECTORY}/consumeGenesis.sh"
fi

docker run                                           \
  -d                                                 \
  --rm                                               \
  --name axelar-core                                 \
  -p 1317:1317                                       \
  -p 26656-26658:26656-26658                         \
  -p 26660:26660                                     \
  --env START_REST=true                              \
  --env PEERS_FILE=/root/shared/peers.txt            \
  --env INIT_SCRIPT=/root/shared/consumeGenesis.sh   \
  --env CONFIG_PATH=/root/shared/                    \
  --env AXELAR_MNEMONIC=$AXELAR_MNEMONIC             \
  --env TENDERMINT_KEY=$TENDERMINT_KEY               \
  -v "${CORE_DIRECTORY}/:/root/.axelar"              \
  -v "${SHARED_DIRECTORY}:/root/shared"              \
  "axelarnet/axelar-core:${AXELAR_CORE_VERSION}"

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
