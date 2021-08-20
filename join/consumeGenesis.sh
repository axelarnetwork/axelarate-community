#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"

axelard keys add validator
axelard keys show validator -a --bech val > "/root/shared/validator.bech"

cp "/root/shared/genesis.json" "/root/.axelar/config/genesis.json"
