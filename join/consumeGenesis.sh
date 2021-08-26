#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"
if [ -f "$TENDERMINT_KEY" ]; then
  cp -f "$TENDERMINT_KEY" "/root/.axelar/config/priv_validator_key.json"
fi

if [ -f "$AXELAR_MNEMONIC" ]; then
  axelard keys add validator --recover <"$AXELAR_MNEMONIC"
  touch "/validator.txt"
else
  axelard keys add validator >"/validator.txt" 2>&1
fi

axelard keys show validator -a --bech val > "/root/shared/validator.bech"
cp "/root/shared/genesis.json" "/root/.axelar/config/genesis.json"
