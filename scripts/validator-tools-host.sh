#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail
trap failure SIGINT SIGTERM ERR
trap cleanup EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

MAX_OPEN_FILES=16384

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-r] -n testnet arg1 [arg2...]

Script description here.
Required Environment Variables:
  - KEYRING_PASSWORD
      used by the file keyring backend for cosmos
  - TOFND_PASSWORD
      used for tofnd

Available options:

-h, --help                    Print this help and exit
-v, --verbose                 Print script debug info
-a, --axelar-core-version     Version of axelar core to checkout
-q, --tofnd-version           Version of tofnd to checkout
-d, --root-directory          Directory for data. [default: $HOME/.axelar_testnet]
-n, --network                 Core Network to connect to [testnet|mainnet]
-p, --proxy-mnemonic-path     Path to broadcaster mnemonic
-z, --tofnd-mnemonic-path     Path to tofnd mnemonic
-e, --environment             Environment to run in [docker|host] (host uses release binaries)
-c, --chain-id                Axelard Chain ID [default: axelar-testnet-lisbon-3]
-k, --node-moniker            Node Moniker [default: hostname]
EOF
  exit
}

cleanup() {
  trap - EXIT
  msg
  msg "script cleanup running"
  # script cleanup here
}

failure() {
  trap - SIGINT SIGTERM ERR

  msg "FAILED to run the last command"
  cleanup
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  axelar_core_version=""
  tofnd_version=""
  root_directory=""
  git_root="$(git rev-parse --show-toplevel)"
  network="testnet"
  proxy_mnemonic_path='unset'
  tofnd_mnemonic_path='unset'
  recovery_info_path="unset"
  environment=''
  chain_id=''
  docker_network='axelarate_default'
  node_moniker="$(hostname | tr '[:upper:]' '[:lower:]')"

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -a | --axelar-core-version)
      axelar_core_version="${2-}"
      shift
      ;;
    -d | --root-directory)
      root_directory="${2-}"
      shift
      ;;
    -n | --network)
      network="${2-}"
      shift
      ;;
    -p | --proxy-mnemonic-path)
      proxy_mnemonic_path="${2-}"
      shift
      ;;
    -z | --tofnd-mnemonic-path)
      tofnd_mnemonic_path="${2-}"
      shift
      ;;
    # -o | --recover-info-path)
    #   recovery_info_path="${2-}"
    #   shift
    #   ;;
    -e | --environment)
      environment="${2-}"
      shift
      ;;
    -c | --chain-id)
      chain_id="${2-}"
      shift
      ;;
    -q | --tofnd-version)
      tofnd_version="${2-}"
      shift
      ;;
    -k | --node-moniker)
      node_moniker="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # Set the appropriate chain_id
  if [ "$network" == "mainnet" ]; then
    if [ -z "${chain_id}" ]; then
      chain_id=axelar-dojo-1
    fi
    if [ -z "${root_directory}" ]; then
      root_directory="$HOME/.axelar"
    fi
  elif [ "$network" == "testnet" ]; then
    if [ -z "${chain_id}" ]; then
      chain_id=axelar-testnet-lisbon-3
    fi
    if [ -z "${root_directory}" ]; then
      root_directory="$HOME/.axelar_testnet"
    fi
  else
    echo "Invalid network provided: ${network}"
    exit 1
  fi

  if [ -z "${axelar_core_version}" ]; then
    axelar_core_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/webdocs/main/docs/resources/"${network}"-releases.md  | grep axelar-core | cut -d \` -f 4)"
  fi

  if [ -z "${tofnd_version}" ]; then
    tofnd_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/webdocs/main/docs/resources/"${network}"-releases.md  | grep tofnd | cut -d \` -f 4)"
  fi

  # check required params and arguments
  [[ -z "${axelar_core_version-}" ]] && die "Missing required parameter: axelar-core-version"
  [[ -z "${tofnd_version-}" ]] && die "Missing required parameter: tofnd-version"
  [[ -z "${root_directory-}" ]] && die "Missing required parameter: root-directory"
  [[ -z "${network-}" ]] && die "Missing required parameter: network"
  # { [[ -z "${environment-}" ]] || { [ "$environment" != "docker" ] && [ "$environment" != "host" ]; } } && die "Missing or incorrect required parameter: environment"
  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  shared_directory="${root_directory}/shared"
  core_directory="${root_directory}/.core"
  vald_directory="${root_directory}/.vald"
  tofnd_directory="${root_directory}/.tofnd"
  axelar_core_image="axelarnet/axelar-core:${axelar_core_version}"
  tofnd_image="axelarnet/tofnd:${tofnd_version}"
  bin_directory="$root_directory/bin"
  logs_directory="$root_directory/logs"
  config_directory="$vald_directory/config"
  axelard_binary_path="$bin_directory/axelard"
  tofnd_binary_path="$bin_directory/tofnd-${tofnd_version}"
  tofnd_binary_symlink="$bin_directory/tofnd"
  os="$(uname | awk '{print tolower($0)}')"
  arch="$(uname -m)"
  if [[ "$arch" == "x86_64" ]]; then arch="amd64"; fi

  return 0
}

print_axelar() {
  msg "
  ${GREEN}
 █████  ██   ██ ███████ ██       █████  ██████
██   ██  ██ ██  ██      ██      ██   ██ ██   ██
███████   ███   █████   ██      ███████ ██████
██   ██  ██ ██  ██      ██      ██   ██ ██   ██
██   ██ ██   ██ ███████ ███████ ██   ██ ██   ██
  ${NOFORMAT}
  "
}

create_directories() {
  msg "creating required directories"
  if [[ ! -d "$vald_directory" ]]; then mkdir -p "$vald_directory"; fi
  if [[ ! -d "$tofnd_directory" ]]; then mkdir -p "$tofnd_directory"; fi
  if [[ ! -d "$config_directory" ]]; then mkdir -p "$config_directory"; fi
}

download_genesis_and_seeds() {
  msg "downloading Genesis and Seeds files"
  local genesis_url
  local seeds_url

  genesis_url="https://axelar-$network.s3.us-east-2.amazonaws.com/genesis.json"
  seeds_url="https://axelar-$network.s3.us-east-2.amazonaws.com/seeds.txt"

  msg "downloading genesis from $genesis_url"
  msg "downloading seeds from $seeds_url"

  if [ ! -f "${shared_directory}/genesis.json" ]; then
    curl -s "$genesis_url" -o "${shared_directory}/genesis.json"
  else
    msg "genesis file already exists"
  fi

  if [ ! -f "${shared_directory}/seeds.txt" ]; then
    curl -s "$seeds_url" -o "${shared_directory}/seeds.txt"
  else
    msg "seeds file already exists"
  fi
}

copy_configuration_files() {
  echo "overwriting configuration file"
  cp "${git_root}/configuration/config.toml" "${shared_directory}/config.toml"

  if [[ ! -f "${shared_directory}/app.toml" ]]; then
    msg "copying app.toml"
    cp "${git_root}/configuration/app.toml" "${shared_directory}/app.toml"
  else
    msg "app.toml already exists"
  fi
}

download_dependencies() {
    msg "\ndownloading required dependencies"
    local tofnd_binary
    tofnd_binary="tofnd-${os}-${arch}-${tofnd_version}"
    if [ ! -f "${tofnd_binary_path}" ] && { [ "${os}" != "linux" ] || [ "${arch}" != "amd64" ]; }; then
      msg "tofnd binary release is only available for linux-amd64"
      msg "For other platforms, build your own from the tofnd repo and place it at: ${tofnd_binary_path}."
      exit 1
    fi

    msg "downloading tofnd binary $tofnd_binary"
    if [[ ! -f "${tofnd_binary_path}" ]]; then
        curl -s --fail "https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/${tofnd_version}/${tofnd_binary}" -o "${tofnd_binary_path}" && chmod +x "${tofnd_binary_path}"
    else
        msg "binary already downloaded"
    fi

    msg "symlinking tofnd binary"
    rm -f "${tofnd_binary_symlink}"
    ln -s "${tofnd_binary_path}" "${tofnd_binary_symlink}"

    msg "copying genesis to configuration directory $config_directory"
    cp "${shared_directory}/genesis.json" "${config_directory}/genesis.json"

    msg "copying seeds to configuration directory $config_directory"
    cp "${shared_directory}/seeds.txt" "${config_directory}/seeds.txt"

    msg "copying config.toml to configuration directory $config_directory and adding seeds"
    cp "${shared_directory}/config.toml" "${config_directory}/config.toml"

    msg "copying app.toml to configuration directory $config_directory"
    cp "${shared_directory}/app.toml" "${config_directory}/app.toml"
}

check_environment() {
    if [ "$(pgrep -f "${tofnd_binary_path}")" != "" ]; then
      # shellcheck disable=SC2016
      msg 'FAILED: tofnd already running. Run "kill -9 $(pgrep -f "tofnd")" to kill tofnd.'
      exit 1
    fi
    
    if [ "$(pgrep -f 'axelard vald-start')" != "" ]; then
      # shellcheck disable=SC2016
      msg 'FAILED: vald already running. Run "kill -9 $(pgrep -f "axelard vald-start")" to kill vald.'
      exit 1
    fi

    if [[ -z "$KEYRING_PASSWORD" ]]; then msg "FAILED: env var KEYRING_PASSWORD missing"; exit 1; fi
    if [[ "${#KEYRING_PASSWORD}" -lt 8 ]]; then msg "FAILED: KEYRING_PASSWORD must have length at least 8"; exit 1; fi

    if [[ -z "$TOFND_PASSWORD" ]]; then msg "FAILED: env var TOFND_PASSWORD missing"; exit 1; fi
    if [[ "${#TOFND_PASSWORD}" -lt 8 ]]; then msg "FAILED: TOFND_PASSWORD must have length at least 8"; exit 1; fi

    if [ ! -f "${axelard_binary_path}" ]; then
      echo "Cannot find axelard binary at ${axelard_binary_path}. Did you launch the node correctly?"
      exit 1
    fi

    if [ "$(ulimit -n)" -lt "${MAX_OPEN_FILES}" ]; then
        echo "FAILED: Number of allowed open files is too low. 'ulimit -n' is below ${MAX_OPEN_FILES}. Run 'ulimit -n ${MAX_OPEN_FILES}' to increase it."
        exit 1
    fi
}

prepare() {
    if [[ "${recovery_info_path}" != 'unset' ]] && [[ -f "${recovery_info_path}" ]]; then
      cp -f "${recovery_info_path}" "$vald_directory/recovery.json"
    fi

    if [[ "${tofnd_mnemonic_path}" != 'unset' ]] && [[ -f "$tofnd_mnemonic_path" ]]; then
      echo "Importing mnemonic to tofnd"
      # run tofnd in "import" mode. This does not start the daemon
      (echo "$TOFND_PASSWORD" && cat "${tofnd_mnemonic_path}") | "${tofnd_binary_path}" -m import -d "${tofnd_directory}" > "${logs_directory}/tofnd.log" 2>&1
    elif [ ! -f "${tofnd_directory}/kvstore/kv/db" ]; then
      echo "Creating new mnemonic for tofnd"
      # run tofnd in "create" mode. This does not start the daemon
      # "create" automatically writes the mnemonic to `export`
      echo "$TOFND_PASSWORD" | "${tofnd_binary_path}" -m create -d "${tofnd_directory}" > "${logs_directory}/tofnd.log" 2>&1
      # rename `export` file to `import`
      mv -f "${tofnd_directory}/export" "${tofnd_directory}/import"
    fi

    local accounts
    local has_broadcaster
    accounts="$(echo "$KEYRING_PASSWORD" | "${axelard_binary_path}" keys list -n --home "${vald_directory}" 2>&1)"

    has_broadcaster=""
    for account in $accounts; do
        if [ "$account" = "broadcaster" ]; then
            has_broadcaster=true
        fi
    done

    if [[ -z "$has_broadcaster" ]]; then
        if [[ "${proxy_mnemonic_path}" != 'unset' ]] && [[ -f "$proxy_mnemonic_path" ]]; then
            msg "recovering broadcaster keys"
            (cat "${proxy_mnemonic_path}"; echo "$KEYRING_PASSWORD"; echo "$KEYRING_PASSWORD") | "${axelard_binary_path}" keys add broadcaster --recover --home "${vald_directory}"
        else
            msg "creating broadcaster keys"
            (echo "$KEYRING_PASSWORD"; echo "$KEYRING_PASSWORD") | "${axelard_binary_path}" keys add broadcaster --home "${vald_directory}"  > "${root_directory}/broadcaster.txt" 2>&1
        fi
    fi

    echo "$KEYRING_PASSWORD" | "${axelard_binary_path}" keys show broadcaster -a --home "${vald_directory}"  > "${root_directory}/broadcaster.address" 2>&1

    validator_address=$(echo "${KEYRING_PASSWORD}" | ${axelard_binary_path} keys show validator -a --bech val --home "${core_directory}")
    if [ -z "$validator_address" ]; then
      until [ -f "${root_directory}/validator.bech" ] ; do
        echo "Waiting for validator address to be accessible at ${root_directory}/validator.bech"
        sleep 5
      done
      validator_address=$(cat "${root_directory}/validator.bech")
    fi
}

run_processes() {
    echo "$TOFND_PASSWORD" | "${tofnd_binary_symlink}" -m existing -d "${tofnd_directory}" > "${logs_directory}/tofnd.log" 2>&1 &

    sleep 5

    validator_host=http://localhost:26657
    tofnd_host=localhost
    recovery_file="${root_directory}"/recovery.json

    # This recovery procedure is not relevant until TSS is enabled again
    recovery=""
    if [ -n "${recovery_file}" ] && [ -f "${recovery_file}" ]; then
        recovery="--tofnd-recovery=${recovery_file}"
    fi

    echo "${KEYRING_PASSWORD}" | "${axelard_binary_path}" vald-start ${tofnd_host:+--tofnd-host "${tofnd_host}"} \
        ${validator_host:+--node "${validator_host}"} \
        --home "${vald_directory}" \
        --validator-addr "${validator_address}" \
        --log_level debug \
        --chain-id "${chain_id}" \
        "$recovery" > "${logs_directory}/vald.log" 2>&1 &
}

post_run_message() {
  msg "Tofnd & Vald running."
  msg "To become a validator get some uaxl tokens from the faucet (testnet only) and stake them"
  msg
  proxy_address="$(cat "${root_directory}/broadcaster.address")"
  msg "Broadcaster address: ${proxy_address}"
  msg
  msg "To follow tofnd execution, run 'tail -f ${logs_directory}/tofnd.log'"
  msg "To follow vald execution, run 'tail -f ${logs_directory}/vald.log'"
  # shellcheck disable=SC2016
  msg 'To stop tofnd, run "kill -9 $(pgrep tofnd)"'
  # shellcheck disable=SC2016
  msg 'To stop vald, run "kill -9 $(pgrep -f "axelard vald-start")"'
  msg
  msg "SUCCESS"
  msg
  msg "CHECK the logs to verify that the processes are running as expected"
  msg
  msg "BACKUP and DELETE the following mnemonics:"
  msg "Tofnd mnemonic: ${tofnd_directory}/import"
  msg "Broadcaster mnemonic: ${root_directory}/broadcaster.txt"
}

parse_params "$@"
setup_colors

check_environment

# Print params
msg "${RED}Read parameters:${NOFORMAT}"
msg "- axelar-core-version: ${axelar_core_version}"
msg "- tofnd-version: ${tofnd_version}"
msg "- root-directory: ${root_directory}"
msg "- proxy-mnemonic-path: ${proxy_mnemonic_path}"
msg "- tofnd-mnemonic-path: ${tofnd_mnemonic_path}"
#msg "- recovery-info-path: ${recovery_info_path}"
msg "- network: ${network}"
msg "- environment: ${environment}"
msg "- node-moniker: ${node_moniker}"
msg "- script_dir: ${script_dir}"
msg "- chain-id: ${chain_id}"
msg "- arguments: ${args[*]-}"
msg "\n"

msg "WAIT to run this until your node has started processing the first block"
msg "\n"

msg "Please VERIFY that the above parameters are correct.  Continue? [y/n]"
read -r value
if [[ "$value" != "y" ]]; then
  msg "You did not type 'y'. Exiting..."
  exit 1
fi
msg "\n"

# Create all required directories common to docker and host mode
create_directories

# Download the genesis and seeds files
download_genesis_and_seeds

# Configuration files
copy_configuration_files

download_dependencies # download dependencies specific to mode
prepare # any other configuration/preparation specific to mode
run_processes # run the node in the right mode [docker|host]
post_run_message # print message post run
