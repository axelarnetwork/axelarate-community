#!/bin/sh
shared_dir=/home/axelard/shared

HAS_BROADCASTER=""

ACCOUNTS=$(echo "${KEYRING_PASSWORD}" | axelard keys list -n 2>&1)
for ACCOUNT in $ACCOUNTS; do
  if [ "$ACCOUNT" = "broadcaster" ]; then
    HAS_BROADCASTER=true
  fi
done

if [ -z "$HAS_BROADCASTER" ]; then
  if [ -f "$AXELAR_MNEMONIC_PATH" ]; then
    (cat "${AXELAR_MNEMONIC_PATH}"; echo "${KEYRING_PASSWORD}"; echo "${KEYRING_PASSWORD}" ) | axelard keys add broadcaster --recover
  else
    (echo "${KEYRING_PASSWORD}"; echo "${KEYRING_PASSWORD}" ) | axelard keys add broadcaster > "${shared_dir}/broadcaster.txt" 2>&1
  fi
fi

echo "${KEYRING_PASSWORD}" | axelard keys show broadcaster -a > "${shared_dir}/broadcaster.bech"


if [ -z "$VALIDATOR_ADDR" ]; then
  until [ -f "${shared_dir}/validator.bech" ] ; do
    echo "Waiting for validator address to be accessible in $shared_dir"
    sleep 5
  done

  VALIDATOR_ADDR=$(cat "${shared_dir}/validator.bech")
  export VALIDATOR_ADDR
fi

echo "finished prestart script"
