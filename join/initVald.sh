#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"
shared_dir=/root/shared

if [ -f "$AXELAR_MNEMONIC" ]; then
  axelard keys add broadcaster --recover <"$AXELAR_MNEMONIC"
    touch "/broadcaster.txt"
else
  axelard keys add broadcaster >"/broadcaster.txt" 2>&1
fi

axelard keys show broadcaster -a > "/root/shared/broadcaster.bech"
cp "/root/shared/genesis.json" "/root/.axelar/config/genesis.json"

