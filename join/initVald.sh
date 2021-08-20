#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"
shared_dir=/root/shared

axelard keys add broadcaster
axelard keys show broadcaster -a > "/root/shared/broadcaster.bech"

cp "/root/shared/genesis.json" "/root/.axelar/config/genesis.json"

