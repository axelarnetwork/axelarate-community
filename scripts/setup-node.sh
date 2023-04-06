#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# shellcheck disable=SC1091
. "${script_dir}/utils.sh"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

Set up the appropriate configs and download binaries to run an axelard node

Available options:

-h, --help                    Print this help and exit
-v, --verbose                 Print script debug info
-r, --reset-chain             Reset all chain data (erases current state including secrets)
-a, --axelar-core-version     Version of axelar core to checkout
-d, --root-directory          Directory for data.
-n, --network                 Network to join [mainnet|testnet]
-e, --environment             Environment to run in [host only] [default: host]
--skip-download               Skip download of binaries. Do this if you want to build them yourself.
EOF
    exit
}

parse_params() {
    # default values of variables set from params
    axelar_core_version=""
    reset_chain=0
    root_directory=''
    git_root="$(git rev-parse --show-toplevel)"
    network=""
    environment='host'
    chain_id=''
    docker_network='axelarate_default'
    skip_download=false

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
        -e | --environment)
            environment="${2-}"
            shift
            ;;
        --skip-download)
            skip_download=true
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
        msg "Invalid network provided: '${network}'"
        die "Use -n flag to provide an appropriate network"
    fi

    if [ -z "${axelar_core_version}" ]; then
        axelar_core_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelar-docs/main/pages/resources/"${network}".md | grep axelar-core | cut -d \` -f 4)"
    fi

    # check required params and arguments
    [[ -z "${axelar_core_version-}" ]] && die "Missing required parameter: axelar-core-version"
    [[ -z "${root_directory-}" ]] && die "Missing required parameter: root-directory"
    [[ -z "${network-}" ]] && die "Missing required parameter: network"
    { [[ -z "${environment-}" ]] || { [ "$environment" != "docker" ] && [ "$environment" != "host" ]; }; } && die "Missing or incorrect required parameter: environment"
    # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

    axelar_core_image="axelarnet/axelar-core:${axelar_core_version}"
    bin_directory="$root_directory/bin"
    logs_directory="$root_directory/logs"
    config_directory="$root_directory/config"
    resources="${git_root}"/resources/"${network}"
    axelard_binary_signature_path="$bin_directory/axelard-${axelar_core_version}.asc"
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
    if [[ ! -d $root_directory ]]; then
        msg "root directory $root_directory doesn't exist"
        return
    fi
    directories="$(ls -ah "$root_directory")"
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
    if [[ ! -d "$config_directory" ]]; then mkdir -p "$config_directory"; fi
}

import_functions() {
    msg "importing functions"
    if [[ "$environment" == "docker" ]]; then
        die "docker is not supported"
    elif [[ "$environment" == "host" ]]; then
        msg "importing host mode functions"
        # shellcheck source=/dev/null
        . "$script_dir/setup-host.sh"
    fi
}

parse_params "$@"
setup_colors

# Print params
msg "${RED}Read parameters:${NOFORMAT}"
msg "- reset-chain: ${reset_chain}"
msg "- axelar-core-version: ${axelar_core_version}"
msg "- root-directory: ${root_directory}"
msg "- network: ${network}"
msg "- environment: ${environment}"
msg "- script_dir: ${script_dir}"
msg "- chain-id: ${chain_id}"
msg "- skip-download: ${skip_download}"
msg "- arguments: ${args[*]-}"
msg "\n"

if [ "${reset_chain}" -eq 0 ]; then
    if [ -d "${root_directory}" ]; then
        msg "Found existing data dir: ${root_directory}"
    else
        msg "No existing data dir, creating new: ${root_directory}"
    fi
    msg "\n"
fi

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

# Configuration files
copy_configuration_files

download_dependencies # download dependencies specific to mode

post_run_message # print message post run
