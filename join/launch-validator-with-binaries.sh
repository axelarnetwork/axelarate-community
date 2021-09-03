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
AXELARD_CMD="$AXELARD"
TOFND="$BIN_DIRECTORY/tofnd"
TOFND_CMD="$TOFND"
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

if [ -z "$AXELAR_CORE_VERSION" ]; then
  echo "'--axelar-core vX.Y.Z' is required"
  exit 1
fi

if [ -z "$TOFND_VERSION" ]; then
  echo "'--tofnd vX.Y.Z' is required"
  exit 1
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

TOFND_BINARY="tofnd-${OS}-${ARCH}-${TOFND_VERSION}"
if [ ! -f "${TOFND}" ]; then
  echo "Downloading tofnd binary $TOFND_BINARY"
  curl -s https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/${TOFND_VERSION}/${TOFND_BINARY} -o "${TOFND}" && chmod +x "${TOFND}"
fi


NODE_UP="$(ps aux | grep '[a]xelard start --home')"
if [ -z "$NODE_UP" ]; then
  echo "No node running"
  exit 1
fi

VALD_DIRECTORY="$HOME/.vald"
mkdir -p "$VALD_DIRECTORY"

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

ACCOUNTS=$($AXELARD_CMD keys list -n --home $ROOT_DIRECTORY)
for ACCOUNT in $ACCOUNTS; do
  if [ "$ACCOUNT" == "broadcaster" ]; then
    HAS_BROADCASTER=true
  fi
done

touch "$ROOT_DIRECTORY/broadcaster.txt"
if [ -z "$HAS_BROADCASTER" ]; then
  if [ -f "$AXELAR_MNEMONIC_PATH" ]; then
    $AXELARD_CMD keys add broadcaster --recover --home $ROOT_DIRECTORY < "$AXELAR_MNEMONIC_PATH"
  else
    $AXELARD_CMD keys add broadcaster --home $ROOT_DIRECTORY > "$ROOT_DIRECTORY/broadcaster.txt" 2>&1
  fi
fi

$AXELARD_CMD keys show broadcaster -a --home $ROOT_DIRECTORY > "$ROOT_DIRECTORY/broadcaster.bech"

VALIDATOR_ADDR=$($AXELARD_CMD keys show validator -a --bech val --home $ROOT_DIRECTORY)
if [ -z "$VALIDATOR_ADDR" ]; then
  until [ -f "$ROOT_DIRECTORY/validator.bech" ] ; do
    echo "Waiting for validator address to be accessible in $shared_dir"
    sleep 5
  done
fi
export VALIDATOR_ADDR=$(cat "$ROOT_DIRECTORY/validator.bech")

"$BIN_DIRECTORY"/tofnd -m "$MNEMONIC_CMD" > "$LOGS_DIRECTORY/tofnd.log" 2>&1 &

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

set -x
"$AXELARD_CMD" vald-start ${TOFND_HOST:+--tofnd-host "$TOFND_HOST"} \
    ${VALIDATOR_HOST:+--node "$VALIDATOR_HOST"} \
    --home "${ROOT_DIRECTORY}" \
    --validator-addr "${VALIDATOR_ADDR}" \
    "$RECOVERY" > "$LOGS_DIRECTORY/vald.log" 2>&1 &
set +x

BROADCASTER=$($AXELARD_CMD keys show broadcaster -a --home $ROOT_DIRECTORY)

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
echo "To stop tofnd, run 'killall tofnd'"
echo "To stop vald, run 'killall vald'"
echo
