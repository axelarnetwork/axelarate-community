#!/usr/bin/env bash
# shellcheck disable=SC2154

MAX_OPEN_FILES=16384

create_directories_host_mode() {
    msg "\npreparing directories for host mode"
    if [[ ! -d "$bin_directory" ]]; then mkdir -p "$bin_directory"; fi
    if [[ ! -d "$logs_directory" ]]; then mkdir -p "$logs_directory"; fi
}

check_environment() {
    msg "\nenvironment host [binaries] functions imported"
    if [ "$(pgrep -f "${axelard_binary_path}")" != "" ]; then
        # shellcheck disable=SC2016
        die 'FAILED: Node already running. Run "kill -9 $(pgrep -f "axelard start")" to kill node.'
    fi

    if [ "$(ulimit -n)" -lt "${MAX_OPEN_FILES}" ]; then
        die "FAILED: Number of allowed open files is too low. 'ulimit -n' is below ${MAX_OPEN_FILES}. Run 'ulimit -n ${MAX_OPEN_FILES}' to increase it."
    fi

    ip_address=$(grep "^external_address" < "${git_root}/configuration/config.toml" | cut -c 20-)

    if [ "${ip_address}" == "\"\"" ]; then
        msg
        msg "NOTE: external_address has not been set in ${git_root}/configuration/config.toml. You might need it if your external IP address is different."
        msg
    fi

    local shared_lib_path
    local shared_lib_env_varible
    shared_lib_env_varible="LD_LIBRARY_PATH"
    shared_lib_path=${LD_LIBRARY_PATH:-}

    if [ "${os}" == "darwin" ]; then
        msg "NOTE: Due to System Integrity Protection from MacOS, dynamic linking variable DYLD_LIBRARY_PATH are purged when launching protected processes"
        msg "NOTE: Please compile axelard binary by staticially linking libwasmvm to run axelar node on MacOS or see Axelar docs on Manual setup"
        die "Script doesn't support MacOS"
    fi

    if [ -z "${shared_lib_path}" ]; then
        die "${shared_lib_env_varible} is not set. Run export ${shared_lib_env_varible}=\"${share_lib_directory}\""
    fi

    if [[ $shared_lib_path != *"${share_lib_directory}"* ]]; then
        die "FAILED: ${share_lib_directory} missing from ${shared_lib_env_varible}. Run export ${shared_lib_env_varible}=\"\${${shared_lib_env_varible}}:${share_lib_directory}\""
    fi
}

download_dependencies() {
    if [ "${skip_download}" = true ]; then
        msg "Skipping binary download"
        return
    fi

    msg "\ndownloading required dependencies"
    create_directories_host_mode
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

    local wasm_lib
    wasm_lib="libwasmvm.${arch}.so"
    if [[ "$arch" == "amd64" ]]; then wasm_lib="libwasmvm.x86_64.so"; fi

    wasm_lib_path="${share_lib_directory}/${wasm_lib}"
    WASMVM_VERSION="v1.3.1"
    msg "downloading wasm shared library ${WASMVM_VERSION}/${wasm_lib}"

    if [[ ! -f "${wasm_lib_path}" ]]; then
        local wasm_lib_url
        wasm_lib_url="https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}"
        wget "${wasm_lib_url}/${wasm_lib}" -O "${wasm_lib_path}" && chmod +r "${wasm_lib_path}"
        wget "${wasm_lib_url}/checksums.txt" -O /tmp/checksums.txt
        sha256sum "${wasm_lib_path}" | grep "$(< /tmp/checksums.txt grep "${wasm_lib}" | cut -d ' ' -f 1)"
    else
        msg "wasm library already downloaded"
    fi
}

post_run_message() {
    print_axelar

    msg "All configuration files have been set up"
    msg
    msg "SUCCESS"
    msg
    msg "Run the node via"
    msg
    msg "${axelard_binary_symlink} start [moniker] --home ${root_directory} >> ${logs_directory}/axelard.log 2>&1 &"
    msg
    msg "More detailed instructions can be found in our docs."
    msg
    msg "After the node is running,"
    msg "To follow execution, run 'tail -f ${logs_directory}/axelard.log'"
    # shellcheck disable=SC2016
    msg 'To stop the node, run "pkill -f "axelard start"'
    msg
    msg "CHECK the logs to verify that the process is running as expected"
    msg
    msg "BACKUP but do NOT DELETE the Tendermint consensus key (if running a validator node)"
    msg "Tendermint consensus key: ${config_directory}/priv_validator_key.json"
}
