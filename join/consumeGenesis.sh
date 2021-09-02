#!/bin/sh
export NODE_MONIKER=${NODE_MONIKER:-"$(hostname)"}
export AXELARD_CHAIN_ID=${AXELARD_CHAIN_ID:-"axelar"}

ACCOUNTS=$(axelard keys list -n)
for ACCOUNT in $ACCOUNTS; do
    if [ "$ACCOUNT" == "validator" ]; then
        HAS_VALIDATOR=true
    fi
done

touch "/validator.txt"
if [ -z "$HAS_VALIDATOR" ]; then
  if [ -f "$AXELAR_MNEMONIC" ]; then
    axelard keys add validator --recover <"$AXELAR_MNEMONIC"
  else
    axelard keys add validator >"/validator.txt" 2>&1
  fi
fi

axelard keys show validator -a --bech val > "/root/shared/validator.bech"

if [ ! -f "/root/.axelar/config/genesis.json" ]; then
  axelard init "$NODE_MONIKER" --chain-id "$AXELARD_CHAIN_ID"
  if [ -f "$TENDERMINT_KEY" ]; then
    cp -f "$TENDERMINT_KEY" "/root/.axelar/config/priv_validator_key.json"
  fi

  cp "/root/shared/genesis.json" "/root/.axelar/config/genesis.json"
fi
