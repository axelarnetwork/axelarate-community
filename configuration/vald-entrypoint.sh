#!/bin/sh
set -e

trap stop_gracefully TERM INT

if [ -z "${AXELARD_CHAIN_ID}" ]; then
  echo "AXELARD_CHAIN_ID env var not set for docker container"
  exit 1
fi

stop_gracefully(){
  echo "stopping all processes"
  killall "axelard"
  sleep 10
  echo "all processes stopped"
}

HOME_DIR=${HOME_DIR:?home directory not set}

addSeeds() {
  sed "s/^seeds =.*/seeds = \"$1\"/g" "$D_HOME_DIR/config/config.toml" >"$D_HOME_DIR/config/config.toml.tmp" &&
  mv "$D_HOME_DIR/config/config.toml.tmp" "$D_HOME_DIR/config/config.toml"
}

startValdProc() {
  DURATION=${SLEEP_TIME:-"10s"}
  sleep "$DURATION"
  RECOVERY=""

  if [ -n "$RECOVERY_FILE" ] && [ -f "$RECOVERY_FILE" ]; then
    RECOVERY="--tofnd-recovery=$RECOVERY_FILE"
  fi

  echo "$KEYRING_PASSWORD" | axelard vald-start ${TOFND_HOST:+--tofnd-host "$TOFND_HOST"} ${VALIDATOR_HOST:+--node "$VALIDATOR_HOST"} \
    --validator-addr "${VALIDATOR_ADDR:-$(axelard keys show validator -a --bech val)}" "$RECOVERY"
}

startNodeProc() {
  axelard start
}

D_HOME_DIR="$HOME_DIR/.axelar"

  if [ -n "$PRESTART_SCRIPT" ] && [ -f "$PRESTART_SCRIPT" ]; then
    echo "Running pre-start script at $PRESTART_SCRIPT"
    # shellcheck source=/dev/null
    . "$PRESTART_SCRIPT"
  fi

if [ -n "$CONFIG_PATH" ] && [ -d "$CONFIG_PATH" ]; then
  if [ -f "$CONFIG_PATH/config.toml" ]; then
    cp "$CONFIG_PATH/config.toml" "$D_HOME_DIR/config/config.toml"
  fi
  if [ -f "$CONFIG_PATH/app.toml" ]; then
    cp "$CONFIG_PATH/app.toml" "$D_HOME_DIR/config/app.toml"
  fi
  if [ -f "$CONFIG_PATH/vald.toml" ]; then
    cp "$CONFIG_PATH/vald.toml" "$D_HOME_DIR/config/vald.toml"
  fi
fi

if [ -n "$PEERS_FILE" ]; then
  SEEDS=$(cat "$PEERS_FILE")
  addSeeds "$SEEDS"
fi

startValdProc &
wait
