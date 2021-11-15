#!/bin/sh
shared_dir=/root/shared

ACCOUNTS=$(axelard keys list -n 2>&1)
for ACCOUNT in $ACCOUNTS; do
  if [ "$ACCOUNT" == "broadcaster" ]; then
    HAS_BROADCASTER=true
  fi
done

touch "/broadcaster.txt"
if [ -z "$HAS_BROADCASTER" ]; then
  if [ -f "$AXELAR_MNEMONIC" ]; then
    axelard keys add broadcaster --recover <"$AXELAR_MNEMONIC"
  else
    axelard keys add broadcaster > "/broadcaster.txt" 2>&1
  fi
fi

axelard keys show broadcaster -a > "${shared_dir}/broadcaster.bech"


if [ -z "$VALIDATOR_ADDR" ]; then
  until [ -f "${shared_dir}/validator.bech" ] ; do
    echo "Waiting for validator address to be accessible in $shared_dir"
    sleep 5
  done
  
  export VALIDATOR_ADDR=$(cat "${shared_dir}/validator.bech")
fi
