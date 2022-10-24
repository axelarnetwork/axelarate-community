#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail
trap failure SIGINT SIGTERM ERR
trap cleanup EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

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
  root_directory="$HOME/.axelar_testnet"
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
    -e | --environment)
      environment="${2-}"
      shift
      ;;
    # -o | --recover-info-path)
    #   recovery_info_path="${2-}"
    #   shift
    #   ;;
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
    chain_id=axelar-dojo-1
  elif [ "$network" == "testnet" ]; then
    chain_id=axelar-testnet-lisbon-3
  else
    echo "Invalid network provided: ${network}"
    exit 1
  fi

  if [ -z "${axelar_core_version}" ]; then
    axelar_core_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelar-docs/main/pages/resources/"${network}".md  | grep axelar-core | cut -d \` -f 4)"
  fi

  if [ -z "${tofnd_version}" ]; then
    tofnd_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelar-docs/main/pages/resources/"${network}".md  | grep tofnd | cut -d \` -f 4)"
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
  axelard_binary_signature_path="$bin_directory/axelard-${axelar_core_version}.asc"
  axelard_binary_path="$bin_directory/axelard-${axelar_core_version}"
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
  if [[ ! -d "$shared_directory" ]]; then mkdir -p "$shared_directory"; fi

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

  if [ -f "${shared_directory}/app.toml" ]; then
    msg "backing up existing app.toml and overwriting it"
    cp "${shared_directory}/app.toml" "${shared_directory}/app.toml.backup"
  fi

  msg "copying app.toml"
  cp "${git_root}/configuration/app.toml" "${shared_directory}/app.toml"
}

check_environment() {
    msg "environment docker functions imported"
    local node_up_vald
    local node_up_tofnd
    node_up_vald="$(docker ps --format '{{.Names}}' | (grep -w 'vald' || true))"
    if [ -n "${node_up_vald}" ]; then
        msg "FAILED: Node is already running. Terminate current container with 'docker stop vald' and try again"
        exit 1
    fi
    node_up_tofnd="$(docker ps --format '{{.Names}}' | (grep -w 'tofnd' || true))"
    if [ -n "${node_up_tofnd}" ]; then
        msg "FAILED: Node is already running. Terminate current container with 'docker stop tofnd' and try again"
        exit 1
    fi

    if [ -n "$(docker container ls --filter name=vald -a -q)" ]; then
        msg "Existing vald container found."
        msg "Either DELETE the existing container with 'docker rm vald' and rerun the script to recreate another container with the updated scripts and the existing chain data"
        msg "(the above will delete any container data in non-mounted folders)"
        msg "OR if you simply want to restart the container, do 'docker start vald'"
        exit 1
    fi

    if [ -n "$(docker container ls --filter name=tofnd -a -q)" ]; then
        msg "Existing tofnd container found."
        msg "Either DELETE the existing container with 'docker rm tofnd' and rerun the script to recreate another container with the updated scripts and the existing chain data"
        msg "(the above will delete any container data in non-mounted folders)"
        msg "OR if you simply want to restart the container, do 'docker start tofnd'"
        exit 1
    fi

    if [[ -z "$KEYRING_PASSWORD" ]]; then msg "FAILED: env var KEYRING_PASSWORD missing"; exit 1; fi
    if [[ "${#KEYRING_PASSWORD}" -lt 8 ]]; then msg "FAILED: KEYRING_PASSWORD must have length at least 8"; exit 1; fi

    if [[ -z "$TOFND_PASSWORD" ]]; then msg "FAILED: env var TOFND_PASSWORD missing"; exit 1; fi
    if [[ "${#TOFND_PASSWORD}" -lt 8 ]]; then msg "FAILED: TOFND_PASSWORD must have length at least 8"; exit 1; fi
}

download_dependencies() {
    msg "downloading required dependencies"
    msg "downloading container for tofnd $tofnd_image"
    docker pull "$tofnd_image"
}

prepare() {
  if [[ "${tofnd_mnemonic_path}" != 'unset' ]] && [[ -f "${tofnd_mnemonic_path}" ]]; then
    cp -f "${tofnd_mnemonic_path}" "${tofnd_directory}/import"
  fi

  if [[ "${recovery_info_path}" != 'unset' ]] && [[ -f "${recovery_info_path}" ]]; then
    cp -f "${recovery_info_path}" "$vald_directory/recovery.json"
  fi

  if [[ "${proxy_mnemonic_path}" != 'unset' ]] && [[ -f "$proxy_mnemonic_path" ]]; then
      msg "copying proxy mnemonic"
      cp "${proxy_mnemonic_path}" "${shared_directory}/broadcaster.txt"
  else
      msg "no mnemonic to recover"
  fi

  if [ ! -f "${shared_directory}/init-vald.sh" ]; then
      msg "copying init-vald script"
      cp "${git_root}/configuration/init-vald.sh" "${shared_directory}/init-vald.sh"
  else
      msg "init-vald already exists"
  fi

  if [ ! -f "${shared_directory}/vald-entrypoint.sh" ]; then
      msg "copying init-vald script"
      cp "${git_root}/configuration/vald-entrypoint.sh" "${shared_directory}/vald-entrypoint.sh"
  else
      msg "vald-entrypoint already exists"
  fi

}

run_processes() {
  if [ -n "$(docker container ls --filter name=vald -a -q)" ]; then
      echo "Updating existing vald container"
      docker rm vald
  fi

  if [ -n "$(docker container ls --filter name=tofnd -a -q)" ]; then
      echo "Updating existing tofnd container"
      docker rm tofnd
  fi

  msg "/nbringing up tofnd container"
  local validator
  docker run                              \
    -d                                    \
    --user 0:0                            \
    --restart unless-stopped              \
    --name tofnd                          \
    --network "$docker_network"           \
    --env MNEMONIC_CMD="auto"             \
    --env PASSWORD="${TOFND_PASSWORD}"    \
    -v "${tofnd_directory}/:/.tofnd"      \
    "axelarnet/tofnd:${tofnd_version}"

  validator=$(docker exec axelar-core sh -c 'echo $KEYRING_PASSWORD | axelard keys show validator -a --bech val' 2>&1)
  echo "Retrieved validator address: ${validator}"

  # Temporarily adding root user and HOME env var here to allow users with linux x86
  # to connect using docker without running into file permission issues
  docker run                                                  \
    -d                                                        \
    --name vald                                               \
    --network "${docker_network}"                             \
    --user 0:0                                                \
    --restart unless-stopped                                  \
    --env TOFND_HOST=tofnd                                    \
    --env HOME=/home/axelard                                  \
    --env VALIDATOR_HOST=http://axelar-core:26657             \
    --env PRESTART_SCRIPT=/home/axelard/shared/init-vald.sh   \
    --env CONFIG_PATH=/home/axelard/shared/                   \
    --env SLEEP_TIME=2s                                       \
    --env VALIDATOR_ADDR="${validator}"                       \
    --env RECOVERY_FILE=/home/axelard/.axelar/recovery.json   \
    --env KEYRING_PASSWORD="${KEYRING_PASSWORD}"              \
    --env AXELAR_MNEMONIC_PATH=/home/axelard/shared/broadcaster.txt  \
    --env AXELARD_CHAIN_ID="${chain_id}"                      \
    --entrypoint /home/axelard/shared/vald-entrypoint.sh      \
    -v "${vald_directory}/:/home/axelard/.axelar"             \
    -v "${shared_directory}/:/home/axelard/shared"            \
    "axelarnet/axelar-core:${axelar_core_version}" startValdProc

    echo "wait 5 seconds for vald to start..."
    sleep 5
}

post_run_message() {
  msg
  msg "Tofnd & Vald running."
  proxy_address="$(cat "${shared_directory}/broadcaster.address")"
  msg "Broadcaster address: ${proxy_address}"
  msg
  msg "To become a validator get some uaxl tokens and stake them"
  msg
  msg
  msg "To follow tofnd execution, run 'docker logs -f tofnd'"
  msg "To follow vald execution, run 'docker logs -f vald'"
  msg "To stop tofnd, run 'docker stop tofnd'"
  msg "To stop vald, run 'docker stop vald'"
  msg
  msg "SUCCESS"
  msg
  msg "CHECK the logs to verify that the containers are running as expected"
  msg
  msg "BACKUP and DELETE the following mnemonics:"
  msg "Tofnd mnemonic: ${tofnd_directory}/import"
  msg "Broadcaster mnemonic: ${shared_directory}/broadcaster.txt"
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
msg "- network: ${network}"
msg "- environment: ${environment}"
msg "- node-moniker: ${node_moniker}"
#msg "- recovery-info-path: ${recovery_info_path}"
msg "- script_dir: ${script_dir}"
msg "- chain-id: ${chain_id}"
msg "- arguments: ${args[*]-}"
msg "\n"

msg "WAIT to run this until your node has processed the first block"
msg "\n"

msg "Please VERIFY that the above parameters are correct, and then press Enter..."
read -r value
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
