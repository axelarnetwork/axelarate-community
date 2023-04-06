#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# shellcheck disable=SC1091
. "${script_dir}/utils.sh"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-r] -n testnet arg1 [arg2...]

Set up configs and download binaries for vald and tofnd.

Available options:

-h, --help                    Print this help and exit
-v, --verbose                 Print script debug info
-a, --axelar-core-version     Version of axelar core to checkout
-q, --tofnd-version           Version of tofnd to checkout
-d, --root-directory          Directory for data. [default: $HOME/.axelar_testnet]
-n, --network                 Core Network to connect to [mainnet|testnet]
-e, --environment             Environment to run in [host only]
--skip-download               Skip download of binaries. Do this if you want to build them yourself.
EOF
    exit
}

parse_params() {
    # default values of variables set from params
    axelar_core_version=""
    tofnd_version=""
    root_directory=""
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
        -a | --axelar-core-version)
            axelar_core_version="${2-}"
            shift
            ;;
        -t | -q | --tofnd-version)
            tofnd_version="${2-}"
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
        msg "Invalid network provided: ${network}"
        die "Specify an appropriate network with -n flag"
    fi

    if [ -z "${axelar_core_version}" ]; then
        axelar_core_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelar-docs/main/pages/resources/"${network}".md | grep axelar-core | cut -d \` -f 4)"
    fi

    if [ -z "${tofnd_version}" ]; then
        tofnd_version="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelar-docs/main/pages/resources/"${network}".md | grep tofnd | cut -d \` -f 4)"
    fi

    # check required params and arguments
    [[ -z "${axelar_core_version-}" ]] && die "Missing required parameter: axelar-core-version"
    [[ -z "${tofnd_version-}" ]] && die "Missing required parameter: tofnd-version"
    [[ -z "${root_directory-}" ]] && die "Missing required parameter: root-directory"
    [[ -z "${network-}" ]] && die "Missing required parameter: network"
    # { [[ -z "${environment-}" ]] || { [ "$environment" != "docker" ] && [ "$environment" != "host" ]; } } && die "Missing or incorrect required parameter: environment"
    # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

    vald_directory="${root_directory}/vald"
    tofnd_directory="${root_directory}/tofnd"
    axelar_core_image="axelarnet/axelar-core:${axelar_core_version}"
    tofnd_image="axelarnet/tofnd:${tofnd_version}"
    bin_directory="$root_directory/bin"
    logs_directory="$root_directory/logs"
    config_directory="$root_directory/config"
    resources="${git_root}"/resources/"${network}"
    axelard_binary_signature_path="$bin_directory/axelard-${axelar_core_version}.asc"
    axelard_binary_path="$bin_directory/axelard-${axelar_core_version}"
    axelard_binary_symlink="$bin_directory/axelard"
    tofnd_binary_path="$bin_directory/tofnd-${tofnd_version}"
    tofnd_binary_signature_path="$bin_directory/tofnd-${tofnd_version}.asc"
    tofnd_binary_symlink="$bin_directory/tofnd"
    os="$(uname | awk '{print tolower($0)}')"
    arch="$(uname -m)"
    if [[ "$arch" == "x86_64" ]]; then arch="amd64"; fi

    if [ "${environment}" != "host" ]; then
        die "Only host environment supported"
    fi

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
    if [[ ! -d "$root_directory" ]]; then mkdir -p "$root_directory"; fi
    if [[ ! -d "$vald_directory" ]]; then mkdir -p "$vald_directory"; fi
    if [[ ! -d "$tofnd_directory" ]]; then mkdir -p "$tofnd_directory"; fi
    if [[ ! -d "$config_directory" ]]; then mkdir -p "$config_directory"; fi
    if [[ ! -d "$bin_directory" ]]; then mkdir -p "$bin_directory"; fi
}

download_dependencies() {
    if [ "${skip_download}" = true ]; then
        msg "Skipping binary download"
        return
    fi

    msg "\ndownloading required dependencies"
    local axelard_binary
    axelard_binary="axelard-${os}-${arch}-${axelar_core_version}"
    msg "downloading axelard binary $axelard_binary"
    if [[ ! -f "${axelard_binary_path}" ]]; then
        local axelard_binary_url
        local axelard_binary_signature_url
        axelard_binary_url="https://axelar-releases.s3.us-east-2.amazonaws.com/axelard/${axelar_core_version}/${axelard_binary}"
        axelard_binary_signature_url="https://axelar-releases.s3.us-east-2.amazonaws.com/axelard/${axelar_core_version}/${axelard_binary}.asc"

        curl -s --fail "${axelard_binary_url}" -o "${axelard_binary_path}" && chmod +x "${axelard_binary_path}"

        check_signature "${axelard_binary_signature_url}" "${axelard_binary_signature_path}" "${axelard_binary_path}"
    else
        msg "binary already downloaded"
    fi

    msg "symlinking axelard binary"
    rm -f "${axelard_binary_symlink}"
    ln -s "${axelard_binary_path}" "${axelard_binary_symlink}"

    local tofnd_binary
    tofnd_binary="tofnd-${os}-${arch}-${tofnd_version}"
    if [ ! -f "${tofnd_binary_path}" ] && { [ "${arch}" != "amd64" ]; }; then
        msg "tofnd pre-built binary is only available for amd64 arch"
        die "For other platforms, build your own from the tofnd repo and place it at: ${tofnd_binary_path} Then, run the script again."
    fi

    msg "downloading tofnd binary $tofnd_binary"
    if [[ ! -f "${tofnd_binary_path}" ]]; then
        local tofnd_binary_url
        local tofnd_binary_signature_url
        tofnd_binary_url="https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/${tofnd_version}/${tofnd_binary}"
        tofnd_binary_signature_url="https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/${tofnd_version}/${tofnd_binary}.asc"
        curl -s --fail "${tofnd_binary_url}" -o "${tofnd_binary_path}" && chmod +x "${tofnd_binary_path}"

        check_signature "${tofnd_binary_signature_url}" "${tofnd_binary_signature_path}" "${tofnd_binary_path}"
    else
        msg "binary already downloaded"
    fi

    msg "symlinking tofnd binary"
    rm -f "${tofnd_binary_symlink}"
    ln -s "${tofnd_binary_path}" "${tofnd_binary_symlink}"
}

check_environment() {
    if [ "$(pgrep -f "${tofnd_binary_path}")" != "" ]; then
        # shellcheck disable=SC2016
        die 'tofnd already running. Run "pkill -f tofnd" to kill tofnd.'
    fi

    if [ "$(pgrep -f 'axelard vald-start')" != "" ]; then
        # shellcheck disable=SC2016
        die 'vald already running. Run "pkill -f vald" to kill vald.'
    fi
}

post_run_message() {
    msg "vald/tofnd setup completed"
    msg
    msg "SUCCESS"
    msg
    msg "To become a validator get some AXL tokens from the faucet (testnet only) and stake them"
    msg
    msg "To follow tofnd execution, run 'tail -f ${logs_directory}/tofnd.log'"
    msg "To follow vald execution, run 'tail -f ${logs_directory}/vald.log'"
    # shellcheck disable=SC2016
    msg 'To stop tofnd, run "pkill -f tofnd"'
    # shellcheck disable=SC2016
    msg 'To stop vald, run "pkill -9 -f vald"'
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
msg "- network: ${network}"
msg "- environment: ${environment}"
msg "- script_dir: ${script_dir}"
msg "- chain-id: ${chain_id}"
msg "- skip-download: ${skip_download}"
msg "- arguments: ${args[*]-}"
msg "\n"

msg "WAIT to run this until your node has started processing the first block"
msg "\n"

verify

# Create all required directories common to docker and host mode
create_directories

# Configuration files
copy_configuration_files

download_dependencies # download dependencies specific to mode

post_run_message # print message post run
