#!/usr/bin/env bash
# shellcheck disable=SC2154

add_seeds() {
  seeds="$(cat "${config_directory}"/seeds.txt)"
  sed "s/^seeds =.*/seeds = \"$seeds\"/g" "${config_directory}/config.toml" >"${config_directory}/config.toml.tmp"
  mv "${config_directory}/config.toml.tmp" "${config_directory}/config.toml"
}

create_directories_host_mode() {
    msg "\npreparing directories for host mode"
    if [[ ! -d "$bin_directory" ]]; then mkdir -p "$bin_directory"; fi
    if [[ ! -d "$logs_directory" ]]; then mkdir -p "$logs_directory"; fi
    if [[ ! -d "$core_directory" ]]; then mkdir -p "$core_directory"; fi
    if [[ ! -d "$config_directory" ]]; then mkdir -p "$config_directory"; fi
}

check_environment() {
    msg "\nenvironment host [binaries] functions imported"
    if [ "$(pgrep -f "${axelard_binary_path}")" != "" ]; then
        # shellcheck disable=SC2016
        msg 'FAILED: Node already running. Run "kill -9 $(pgrep -f "axelard")" to kill node.';
        exit 1
    fi

    if [[ -z "$KEYRING_PASSWORD" ]]; then msg "FAILED: env var KEYRING_PASSWORD missing"; exit 1; fi

    if [[ "${#KEYRING_PASSWORD}" -lt 8 ]]; then msg "FAILED: KEYRING_PASSWORD must have length at least 8"; exit 1; fi

    if [ "$(ulimit -n)" -lt 2048 ]; then
        echo "Number of allowed open files is too low. 'ulimit -n' is below 2048. Run 'ulimit -n 2048' to increase it."
        exit 1
    fi
}

download_dependencies() {
    msg "\ndownloading required dependencies"
    create_directories_host_mode
    local axelard_binary
    axelard_binary="axelard-${os}-${arch}-${axelar_core_version}"
    msg "downloading axelard binary $axelard_binary"
    if [[ ! -f "${axelard_binary_path}" ]]; then
        curl -s --fail "https://axelar-releases.s3.us-east-2.amazonaws.com/axelard/${axelar_core_version}/${axelard_binary}" -o "${axelard_binary_path}" && chmod +x "${axelard_binary_path}"
    else
        msg "binary already downloaded"
    fi

    msg "symlinking axelard binary"
    rm -f "${axelard_binary_symlink}"
    ln -s "${axelard_binary_path}" "${axelard_binary_symlink}"

    msg "copying genesis to configuration directory"
    cp "${shared_directory}/genesis.json" "${config_directory}/genesis.json"

    msg "copying seeds to configuration directory"
    cp "${shared_directory}/seeds.txt" "${config_directory}/seeds.txt"

    msg "copying config.toml to configuration directory and adding seeds"
    cp "${shared_directory}/config.toml" "${config_directory}/config.toml"
    add_seeds

    msg "copying app.toml to configuration directory"
    cp "${shared_directory}/app.toml" "${config_directory}/app.toml"
}

prepare() {
    msg "\npreparing for binary deployment"
    local accounts
    local has_validator
    accounts="$(echo "$KEYRING_PASSWORD" | "${axelard_binary_path}" keys list -n --home "${core_directory}" 2>&1)"

    has_validator=""
    for account in $accounts; do
        if [ "$account" = "validator" ]; then
            has_validator=true
        fi
    done

    if [[ -z "$has_validator" ]]; then
        if [[ "${axelar_mnemonic_path}" != 'unset' ]] && [[ -f "$axelar_mnemonic_path" ]]; then
            msg "recovering validator keys"
            (cat "${axelar_mnemonic_path}"; echo "$KEYRING_PASSWORD"; echo "$KEYRING_PASSWORD") | "${axelard_binary_path}" keys add validator --recover --home "${core_directory}"
        else
            msg "creating validator keys"
            (echo "$KEYRING_PASSWORD"; echo "$KEYRING_PASSWORD") | "${axelard_binary_path}" keys add validator --home "${core_directory}" > "${root_directory}/validator.txt" 2>&1
        fi
    fi

    echo "$KEYRING_PASSWORD" | "${axelard_binary_path}" keys show validator -a --bech val --home "${core_directory}" > "${root_directory}/validator.bech" 2>&1

    if [[ "${tendermint_key_path}" != 'unset' ]] && [[ -f "${tendermint_key_path}" ]]; then
        cp -f "${tendermint_key_path}" "${config_directory}/priv_validator_key.json"
    fi
}

run_node() {
    msg "\nrunning node"
    "${axelard_binary_symlink}" start --home "${core_directory}" --moniker "${node_moniker}" > "${logs_directory}/axelard.log" 2>&1 &
}

post_run_message() {
    local validator_address
    print_axelar
    validator_address="$(cat "${root_directory}/validator.bech")"
    msg "Validator address: ${validator_address}"
    msg
    msg "To follow execution, run 'tail -f ${logs_directory}/axelard.log'"
    # shellcheck disable=SC2016
    msg 'To stop the node, run "kill -9 $(pgrep -f "axelard start")"'
    msg
    msg "SUCCESS"
    msg
    msg "CHECK the logs to verify that the process is running as expected"
    msg
    msg "BACKUP and DELETE the validator account mnemonic:"
    msg "Validator mnemonic: ${root_directory}/validator.txt"
    msg
    msg "BACKUP but do NOT DELETE the Tendermint consensus key (this is needed on node restarts):"
    msg "Tendermint consensus key: ${config_directory}/priv_validator_key.json"
}
