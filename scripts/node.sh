#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail
trap failure SIGINT SIGTERM ERR
trap cleanup EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

Script description here.
Required Environment Variables:
  - KEYRING_PASSWORD
      used by the file keyring backend for cosmos
  - TOFND_PASSWORD
      used for tofnd

Available options:

-h, --help                    Print this help and exit
-v, --verbose                 Print script debug info
-r, --reset-chain             Reset all chain data (erases current state including secrets)
-a, --axelar-core-version     Version of axelar core to checkout
-d, --root-directory          Directory for data. [default: ~/.axelar_testnet]
-n, --network                 Network to join [testnet|mainnet] [default: testnet]
-t, --tendermint-key-path     Path to tendermint key
-m, --axelar-mnemonic-path    Path to axelar mnemonic key
-e, --environment             Environment to run in [host|docker] [default: host]
-c, --chain-id                Axelard Chain ID [default: axelar-testnet-lisbon-2]
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
  reset_chain=0
  root_directory=''
  git_root="$(git rev-parse --show-toplevel)"
  network="testnet"
  tendermint_key_path='unset'
  axelar_mnemonic_path='unset'
  environment='host'
  chain_id=''
  docker_network='axelarate_default'
  node_moniker="$(hostname | tr '[:upper:]' '[:lower:]')"

  # Set the appropriate chain_id
  if [ "$network" == "mainnet" ]; then
    chain_id=axelar-dojo-1
    root_directory="$HOME/.axelar"
  elif [ "$network" == "testnet" ]; then
    chain_id=axelar-testnet-lisbon-2
    root_directory="$HOME/.axelar_testnet"
  else
    echo "Invalid network provided: ${network}"
    exit 1
  fi

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -r | --reset-chain) reset_chain=1 ;;
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
    -t | --tendermint-key-path)
      tendermint_key_path="${2-}"
      shift
      ;;
    -m | --axelar-mnemonic-path)
      axelar_mnemonic_path="${2-}"
      shift
      ;;
    -e | --environment)
      environment="${2-}"
      shift
      ;;
    -c | --chain-id)
      chain_id="${2-}"
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

  if [ -z "${axelar_core_version}" ]; then
    axelar_core_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/webdocs/main/docs/resources/"${network}"-releases.md  | grep axelar-core | cut -d \` -f 4)"
  fi

  # check required params and arguments
  [[ -z "${axelar_core_version-}" ]] && die "Missing required parameter: axelar-core-version"
  [[ -z "${root_directory-}" ]] && die "Missing required parameter: root-directory"
  [[ -z "${network-}" ]] && die "Missing required parameter: network"
  { [[ -z "${environment-}" ]] || { [ "$environment" != "docker" ] && [ "$environment" != "host" ]; } } && die "Missing or incorrect required parameter: environment"
  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  shared_directory="${root_directory}/shared"
  core_directory="${root_directory}/.core"
  axelar_core_image="axelarnet/axelar-core:${axelar_core_version}"
  bin_directory="$root_directory/bin"
  logs_directory="$root_directory/logs"
  config_directory="$core_directory/config"
  axelard_binary_path="$bin_directory/axelard-${axelar_core_version}"
  axelard_binary_symlink="$bin_directory/axelard"
  os="$(uname | awk '{print tolower($0)}')"
  arch="$(uname -m)"
  if [[ "$arch" == "x86_64" ]]; then arch="amd64"; fi

  return 0
}

print_warning() {
  msg "
  ${RED}
██     ██  █████  ██████  ███    ██ ██ ███    ██  ██████  ██
██     ██ ██   ██ ██   ██ ████   ██ ██ ████   ██ ██       ██
██  █  ██ ███████ ██████  ██ ██  ██ ██ ██ ██  ██ ██   ███ ██
██ ███ ██ ██   ██ ██   ██ ██  ██ ██ ██ ██  ██ ██ ██    ██
 ███ ███  ██   ██ ██   ██ ██   ████ ██ ██   ████  ██████  ██
  ${NOFORMAT}
  "
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

reset_chain() {
  print_warning
  msg "${RED}RESET CHAIN FLAG USED!!!${NOFORMAT}"
  local directories
  local reply
  if [[ ! -d $root_directory ]]; then msg "root directory $root_directory doesn't exist"; return; fi
  directories="$(ls -ah $root_directory)"
  msg "list of files/folders in root directory:"
  msg "$directories"
  msg "${RED}WARNING! You are about to reset the entire chain state${NOFORMAT}"
  msg "${RED}your current state will be backed up to $root_directory.bak${NOFORMAT}"
  msg "${RED}you can manually delete the backed state by running 'rm -rf $root_directory.bak'${NOFORMAT}"
  msg "${RED}to proceed type 'understood'${NOFORMAT}"
  read -r reply
  if [[ "$reply" = "understood" ]]; then
    msg "moving previous state from $root_directory to $root_directory.bak"
    rm -rf "$root_directory.bak"
    mv "$root_directory" "$root_directory.bak"
  else
    msg "invalid input. Exiting..."
    exit 1
  fi
}

create_directories() {
  msg "creating required directories"
  if [[ ! -d "$root_directory" ]]; then mkdir -p "$root_directory"; fi
  if [[ ! -d "$shared_directory" ]]; then mkdir -p "$shared_directory"; fi
  if [[ ! -d "$core_directory" ]]; then mkdir -p "$core_directory"; fi
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

  ip_address=$(grep "^external_address" < "${shared_directory}/config.toml" | cut -c 20-)

  if [ "${ip_address}" == "\"\"" ]; then
    echo "NOTE: external_address has not been set in ${git_root}/configuration/config.toml. You might not need it."
  fi

  if [ ! -f "${shared_directory}/app.toml" ]; then
    msg "copying app.toml"
    cp "${git_root}/configuration/app.toml" "${shared_directory}/app.toml"
  else
    msg "app.toml already exists"
  fi
}

import_functions() {
  msg "importing functions"
  if [[ "$environment" == "docker" ]]; then
    msg "importing docker functions"
    # shellcheck source=/dev/null
    . "$script_dir/docker.sh"
  elif [[ "$environment" == "host" ]]; then
    msg "importing host mode functions"
    # shellcheck source=/dev/null
    . "$script_dir/host.sh"
  fi
}

parse_params "$@"
setup_colors

# Print params
msg "${RED}Read parameters:${NOFORMAT}"
msg "- reset-chain: ${reset_chain}"
msg "- axelar-core-version: ${axelar_core_version}"
msg "- root-directory: ${root_directory}"
msg "- tendermint-key-path: ${tendermint_key_path}"
msg "- axelar-mnemonic-path: ${axelar_mnemonic_path}"
msg "- network: ${network}"
msg "- environment: ${environment}"
msg "- node-moniker: ${node_moniker}"
msg "- script_dir: ${script_dir}"
msg "- chain-id: ${chain_id}"
msg "- arguments: ${args[*]-}"
msg "\n"

msg "Please VERIFY that the above parameters are correct.  Continue? [y/n]"
read -r value
if [[ "$value" != "y" ]]; then
  msg "You did not type 'y'. Exiting..."
  exit 1
fi
msg "\n"

# import the functions
import_functions

msg

check_environment

# Reset chain if flag set
if [[ "$reset_chain" -eq 1 ]]; then reset_chain; fi

# Create all required directories common to docker and host mode
create_directories

# Download the genesis and seeds files
download_genesis_and_seeds

# Configuration files
copy_configuration_files

download_dependencies # download dependencies specific to mode
prepare # any other configuration/preparation specific to mode
run_node # run the node in the right mode [docker|host]
post_run_message # print message post run
