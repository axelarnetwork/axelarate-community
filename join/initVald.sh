#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"
shared_dir=/root/shared

if [ -f "$AXELAR_MNEMONIC" ]; then
  axelard keys add broadcaster --recover <"$AXELAR_MNEMONIC"
else
  axelard keys add broadcaster
fi

axelard keys show broadcaster -a > "/root/shared/broadcaster.bech"
cp "/root/shared/genesis.json" "/root/.axelar/config/genesis.json"

