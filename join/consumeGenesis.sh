#!/bin/sh
set -e

axelard init "$1" --chain-id "$2"

axelarcli keys add validator
axelarcli keys add broadcaster

cp "/root/shared/genesis.json" /root/.axelard/config/genesis.json
