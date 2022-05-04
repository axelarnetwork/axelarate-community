#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail
trap failure SIGINT SIGTERM ERR
trap cleanup EXIT

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
    msg "FAILED: $msg"
    exit "$code"
}

verify() {
    msg "Please VERIFY that the above parameters are correct.  Continue? [y/n]"
    read -r value
    if [[ "$value" != "y" ]]; then
        msg "You did not type 'y'. Exiting..."
        exit 1
    fi
    msg "\n"
}

copy_configuration_files() {
    if [ ! -f "${config_directory}/genesis.json" ]; then
        msg "Copying genesis file to the config directory"
        cp "${resources}/genesis.json" "${config_directory}/genesis.json"
    else
        msg "genesis file already exists"
    fi

    if [ ! -f "${config_directory}/seeds.toml" ]; then
        msg "Copying seeds.toml to the config directory"
        cp "${resources}/seeds.toml" "${config_directory}/seeds.toml"
    else
        msg "seeds.toml file already exists"
    fi

    if [ ! -f "${config_directory}/config.toml" ]; then
        msg "Copying config.toml to the config directory"
        cp "${git_root}/configuration/config.toml" "${config_directory}/config.toml"
    else
        msg "config.toml file already exists"
    fi

    if [ ! -f "${config_directory}/app.toml" ]; then
        msg "Copying app.toml to the config directory"
        cp "${git_root}/configuration/app.toml" "${config_directory}/app.toml"
    else
        msg "app.toml file already exists"
    fi
}
