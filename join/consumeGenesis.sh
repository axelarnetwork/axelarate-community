#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"

axelard keys add validator
axelard keys add broadcaster

cp "/root/shared/genesis.json" /root/.axelar/config/genesis.json
