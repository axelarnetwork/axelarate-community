#!/bin/sh

TOFND_MNEMONIC_PATH=""
AXELAR_MNEMONIC_PATH=""
RECOVERY_INFO_PATH=""
AXELAR_CORE_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep axelar-core | cut -d \` -f 4)"
TOFND_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep tofnd | cut -d \` -f 4)"
ROOT_DIRECTORY="$HOME/.axelar_testnet"
GIT_ROOT="$(git rev-parse --show-toplevel)"
BIN_DIRECTORY="$ROOT_DIRECTORY/bin"
AXELARD="$BIN_DIRECTORY/axelard"
TOFND="$BIN_DIRECTORY/tofnd"
OS="$(uname | awk '{print tolower($0)}')"
ARCH="$(uname -m)"


set -e
for arg in "$@"; do
  case $arg in
    --proxy-mnemonic)
    AXELAR_MNEMONIC_PATH="$2"
    shift
    ;;
    --tofnd-mnemonic)
    TOFND_MNEMONIC_PATH="$2"
    shift
    ;;
    --recovery-info)
    RECOVERY_INFO_PATH="$2"
    shift
    ;;
    -r|--root)
    ROOT_DIRECTORY="$2"
    shift
    ;;
    --axelar-core)
    AXELAR_CORE_VERSION="$2"
    shift
    ;;
    --tofnd)
    TOFND_VERSION="$2"
    shift
    ;;
    *)
    shift
    ;;
  esac
done

if [ "$(ps aux | grep -c '[a]xelard vald-start')" -gt "0" ]; then
  echo "Vald already running. ps aux | grep vald-start and kill process";
  exit 1;
fi

if [ "$(ps aux | grep -c '[t]ofnd -m ')" -gt "0" ]; then
  echo "Tofnd already running. ps aux | grep tofnd and kill process";
  exit 1;
fi

if [ -z "$AXELAR_CORE_VERSION" ]; then
  echo "'--axelar-core vX.Y.Z' is required"
  exit 1
fi

if [ -z "$TOFND_VERSION" ]; then
  echo "'--tofnd vX.Y.Z' is required"
  exit 1
fi

# override ARCH with amd64 for x86 arch
if [ "x86_64" =  "$ARCH" ]; then
  ARCH=amd64
fi

echo "TOFND Version: ${TOFND_VERSION}"
echo "Axelar Core Version: ${AXELAR_CORE_VERSION}"
echo "OS: ${OS}"
echo "Architecture: ${ARCH}"

if [ ! -d "$ROOT_DIRECTORY" ]; then
  echo "Root directory does not exist"
  exit 1
fi
echo "Root Directory: ${ROOT_DIRECTORY}"
LOGS_DIRECTORY="${ROOT_DIRECTORY}/logs"
mkdir -p "$LOGS_DIRECTORY"
echo "Logs Directory: $LOGS_DIRECTORY"

VALD_DIRECTORY="$ROOT_DIRECTORY/.vald"
mkdir -p "$VALD_DIRECTORY"

CONFIG_DIRECTORY="${VALD_DIRECTORY}/config"
mkdir -p "$CONFIG_DIRECTORY"

TOFND_BINARY="tofnd-${OS}-${ARCH}-${TOFND_VERSION}"
if [ ! -f "${TOFND}" ]; then
  echo "Downloading tofnd binary $TOFND_BINARY"
  curl -s --fail https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/${TOFND_VERSION}/${TOFND_BINARY} -o "${TOFND}" && chmod +x "${TOFND}"
fi

if [ ! -f "${CONFIG_DIRECTORY}/config.toml" ]; then
  echo "Moving config.toml to config directory"
  cp "${GIT_ROOT}/join/config.toml" "${CONFIG_DIRECTORY}/config.toml"
fi

if [ ! -f "${CONFIG_DIRECTORY}/app.toml" ]; then
  echo "Moving app.toml to config directory"
  cp "${GIT_ROOT}/join/app.toml" "${CONFIG_DIRECTORY}/app.toml"
fi

NODE_UP="$(ps aux | grep '[a]xelard start --home')"
if [ -z "$NODE_UP" ]; then
  echo "No node running"
  exit 1
fi



CORE_DIRECTORY="${ROOT_DIRECTORY}/.core"

TOFND_DIRECTORY="$HOME/.tofnd"
mkdir -p "$TOFND_DIRECTORY"

if [ -f "$RECOVERY_INFO_PATH" ]; then
  cp -f "$RECOVERY_INFO_PATH" "$VALD_DIRECTORY/recovery.json"
fi

MNEMONIC_CMD=create
if [ -f "$TOFND_MNEMONIC_PATH" ]; then
  cp -f "$TOFND_MNEMONIC_PATH" "$TOFND_MNEMONIC_PATH/import"
  MNEMONIC_CMD=import
fi

ACCOUNTS=$($AXELARD keys list -n --home $VALD_DIRECTORY)
for ACCOUNT in $ACCOUNTS; do
  if [ "$ACCOUNT" == "broadcaster" ]; then
    HAS_BROADCASTER=true
  fi
done

touch "$ROOT_DIRECTORY/broadcaster.txt"
if [ -z "$HAS_BROADCASTER" ]; then
  if [ -f "$AXELAR_MNEMONIC_PATH" ]; then
    $AXELARD keys add broadcaster --recover --home $VALD_DIRECTORY < "$AXELAR_MNEMONIC_PATH"
  else
    $AXELARD keys add broadcaster --home $VALD_DIRECTORY > "$ROOT_DIRECTORY/broadcaster.txt" 2>&1
  fi
fi

$AXELARD keys show broadcaster -a --home $VALD_DIRECTORY > "$ROOT_DIRECTORY/broadcaster.bech"

VALIDATOR_ADDR=$($AXELARD keys show validator -a --bech val --home $CORE_DIRECTORY)
if [ -z "$VALIDATOR_ADDR" ]; then
  until [ -f "$ROOT_DIRECTORY/validator.bech" ] ; do
    echo "Waiting for validator address to be accessible in $shared_dir"
    sleep 5
  done
  export VALIDATOR_ADDR=$(cat "$ROOT_DIRECTORY/validator.bech")
fi


"$TOFND" -m "$MNEMONIC_CMD" > "$LOGS_DIRECTORY/tofnd.log" 2>&1 &

sleep 5

export VALIDATOR_HOST=http://localhost:26657
export SLEEP_TIME=2
export TOFND_HOST=localhost
export RECOVERY_FILE="$ROOT_DIRECTORY"/recovery.json
export AXELAR_MNEMONIC_PATH=$AXELAR_MNEMONIC_PATH

sleep "$SLEEP_TIME"
RECOVERY=""
if [ -n "$RECOVERY_FILE" ] && [ -f "$RECOVERY_FILE" ]; then
    RECOVERY="--tofnd-recovery=$RECOVERY_FILE"
fi

export KEYRING_BACKEND=test

"$AXELARD" vald-start ${TOFND_HOST:+--tofnd-host "$TOFND_HOST"} \
    ${VALIDATOR_HOST:+--node "$VALIDATOR_HOST"} \
    --home "${VALD_DIRECTORY}" \
    --validator-addr "${VALIDATOR_ADDR}" \
    --log_level debug \
    "$RECOVERY" > "$LOGS_DIRECTORY/vald.log" 2>&1 &

BROADCASTER=$($AXELARD keys show broadcaster -a --home $VALD_DIRECTORY)

echo
echo "Tofnd & Vald running."
echo
echo "Proxy address: $BROADCASTER"
echo
echo "To become a validator get some uaxl tokens from the faucet and stake them"
echo

cat "$ROOT_DIRECTORY/broadcaster.txt"
rm -rf "$ROOT_DIRECTORY/broadcaster.txt"
echo "Do not forget to also backup the tofnd mnemonic (${TOFND_DIRECTORY}/export)"
echo
echo "To follow tofnd execution, run 'tail -f ${LOGS_DIRECTORY}/tofnd.logs'"
echo "To follow vald execution, run 'tail -f ${LOGS_DIRECTORY}/vald.logs'"
echo "To stop tofnd, run 'killall -9 tofnd'"
echo "To stop vald, run 'killall -9 vald'"
echo

