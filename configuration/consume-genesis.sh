#!/bin/sh
export NODE_MONIKER=${NODE_MONIKER:-"$(hostname)"}
export AXELARD_CHAIN_ID=${AXELARD_CHAIN_ID:-"axelar"}

set -x

ACCOUNTS=$(echo "${KEYRING_PASSWORD}" | axelard keys list -n 2>&1)
HAS_VALIDATOR=""
for ACCOUNT in $ACCOUNTS; do
    if [ "$ACCOUNT" = "validator" ]; then
        HAS_VALIDATOR=true
    fi
done

echo "HAS_VALIDATOR: $HAS_VALIDATOR"
if [ -z "$HAS_VALIDATOR" ]; then
  if [ -f "$AXELAR_MNEMONIC_PATH" ]; then
    echo "recovering validator account from mnemonic"
    (cat "${AXELAR_MNEMONIC_PATH}"; echo "${KEYRING_PASSWORD}"; echo "$KEYRING_PASSWORD") | axelard keys add validator --recover
  else
    if [ -n "${AXELAR_MNEMONIC_PATH}" ]; then
      echo ""
      echo "FAILED to recover validator account from mnemonic. File ${AXELAR_MNEMONIC_PATH} does not exist"
      echo "Creating new validator account instead"
      echo ""
    fi

    echo "adding validator"
    (echo "${KEYRING_PASSWORD}"; echo "$KEYRING_PASSWORD") | axelard keys add validator > "/home/axelard/shared/validator.txt" 2>&1
  fi
fi

echo "${KEYRING_PASSWORD}" | axelard keys show validator -a --bech val > "/home/axelard/shared/validator.bech"

if [ ! -f "/home/axelard/.axelar/config/genesis.json" ]; then
  axelard init "$NODE_MONIKER" --chain-id "$AXELARD_CHAIN_ID"
  if [ -f "$TENDERMINT_KEY_PATH" ]; then
    cp -f "$TENDERMINT_KEY_PATH" "/home/axelard/.axelar/config/priv_validator_key.json"
  elif [ -n "${TENDERMINT_KEY_PATH}" ]; then
    echo ""
    echo "FAILED to recover Tendermint key from mnemonic. File ${TENDERMINT_KEY_PATH} does not exist"
    echo "Creating new validator account instead"
    echo ""
  fi

  cp "/home/axelard/shared/genesis.json" "/home/axelard/.axelar/config/genesis.json"
fi
