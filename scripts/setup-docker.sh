#!/usr/bin/env bash
# shellcheck disable=SC2154

check_environment() {
    msg "environment docker functions imported"
    local node_up
    node_up="$(docker ps --format '{{.Names}}' | (grep -w 'axelar-core' || true))"
    if [ -n "${node_up}" ]; then
        msg "FAILED: Node is already running. Terminate current container with 'docker stop axelar-core' and try again"
        exit 1
    fi

    if [ -n "$(docker container ls --filter name=axelar-core -a -q)" ]; then
        msg "Existing axelar-core container found."
        msg "Either DELETE the existing container with 'docker rm axelar-core' and rerun the script to recreate another container with the updated scripts and the existing chain data"
        msg "(the above will delete any container data in non-mounted folders)"
        msg "OR if you simply want to restart the container, do 'docker start axelar-core'"
        exit 1
    fi

    if [[ -z "$KEYRING_PASSWORD" ]]; then msg "FAILED: env var KEYRING_PASSWORD missing"; exit 1; fi

    if [[ "${#KEYRING_PASSWORD}" -lt 8 ]]; then msg "FAILED: KEYRING_PASSWORD must have length at least 8"; exit 1; fi
}

download_dependencies() {
    msg "downloading required dependencies"
    msg "downloading container for axelar-core $axelar_core_image"
    docker pull "$axelar_core_image"
}

docker_mnemonic_path=""
docker_tendermint_key=""

prepare() {
    msg "preparing for docker deployment. ensure network $docker_network"
    local network_present
    network_present="$(docker network ls --format '{{.Name}}' | { grep "$docker_network" || :; })"
    if [ -z "$network_present" ]; then
        msg "creating docker network $docker_network"
        docker network create "$docker_network" --driver=bridge --scope=local
    else
        msg "docker network $docker_network already exists"
    fi
    if [ ! -f "${shared_directory}/consume-genesis.sh" ]; then
        msg "copying consume genesis script"
        cp "${git_root}/configuration/consume-genesis.sh" "${shared_directory}/consume-genesis.sh"
    else
        msg "consume genesis script already exists"
    fi

    if [[ "${axelar_mnemonic_path}" != 'unset' ]] && [[ -f "$axelar_mnemonic_path" ]]; then
        msg "copying validator mnemonic"
        cp "${axelar_mnemonic_path}" "${shared_directory}/validator.txt"
        docker_mnemonic_path="/home/axelard/shared/validator.txt"
    else
        msg "no mnemonic to recover"
    fi

    if [[ "${tendermint_key_path}" != 'unset' ]] && [[ -f "${tendermint_key_path}" ]]; then
        cp -f "${tendermint_key_path}" "${shared_directory}/tendermint.json"
        docker_tendermint_key="/home/axelard/shared/tendermint.json"
    fi
}

run_node() {
    if [ -n "$(docker container ls --filter name=axelar-core -a -q)" ]; then
        echo "Updating existing axelar-core container"
        docker rm axelar-core
    fi

    msg "running node"
    docker run                                                      \
      -d                                                            \
      --name axelar-core                                            \
      --network "$docker_network"                                   \
      -p 1317:1317                                                  \
      -p 26656-26658:26656-26658                                    \
      -p 26660:26660                                                \
      -p 9090:9090                                                  \
      --user 0:0                                                    \
      --restart unless-stopped                                      \
      --env HOME=/home/axelard                                      \
      --env START_REST=true                                         \
      --env PRESTART_SCRIPT=/home/axelard/shared/consume-genesis.sh \
      --env CONFIG_PATH=/home/axelard/shared/                       \
      --env NODE_MONIKER="${node_moniker}"                          \
      --env KEYRING_PASSWORD="${KEYRING_PASSWORD}"                  \
      --env AXELAR_MNEMONIC_PATH="${docker_mnemonic_path}"          \
      --env AXELARD_CHAIN_ID="${chain_id}"                          \
      --env TENDERMINT_KEY_PATH="${docker_tendermint_key}"          \
      --env PEERS_FILE=/home/axelard/shared/seeds.txt                   \
      -v "${core_directory}/:/home/axelard/.axelar"                     \
      -v "${shared_directory}:/home/axelard/shared"                     \
      "axelarnet/axelar-core:${axelar_core_version}" startNodeProc
    echo "wait 5 seconds for axelar-core to start..."
    sleep 5
}

post_run_message() {
    print_axelar
    validator_address="$(cat "${shared_directory}/validator.bech")"
    msg "Validator address: ${validator_address}"
    msg
    msg "To follow execution, run 'docker logs -f axelar-core'"
    msg "To stop the node, run 'docker stop axelar-core'"
    msg
    msg "SUCCESS"
    msg
    msg "CHECK the logs to verify that the container is running as expected"
    msg
    msg "BACKUP and DELETE the validator account mnemonic:"
    msg "Validator mnemonic: ${shared_directory}/validator.txt"
    msg
    msg "BACKUP but do NOT DELETE the Tendermint consensus key (this is needed on node restarts):"
    msg "Tendermint consensus key: ${core_directory}/config/priv_validator_key.json"

    if [ -n "$docker_tendermint_key" ]; then
        rm -f "${shared_directory}/tendermint.json"
    fi
}




