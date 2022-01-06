# axelarate-community
Tools to join the axelar network

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Get Started
Visit [our website](https://docs.axelar.dev) for instructions to join the network and complete exercises.

# Configuration Notes
In `configuration/config.toml`
- Set your node's IP address in the field: `external_address`.

See the usage of the scripts using the `--help` flag.

The `file` keyring backend is used by default for `axelard` account storage.
The password is supplied via a `KEYRING_PASSWORD` env var to the scripts.
**Password must be at least 8 characters.**
Password management is left to the user. They can use the OS keyring, a secrets management service,
store it in a file, or switch to using the `test` unencrypted keyring backend if they wish to.

`tofnd` also encrypts it's storage using `TOFND_PASSWORD`.

# Joining Testnet

Release information can be found at [`resources/testnet-releases`](./resources/testnet-releases.md).

## Joining as a Node

When joining for the first time, delete your existing `~/.axelar_testnet` folder.

### Example for Docker
```bash
KEYRING_PASSWORD=.. ./scripts/node.sh -e docker
```

### Example for Host Mode (Binaries)
```bash
KEYRING_PASSWORD=.. ./scripts/node.sh -e host
```

To recover from mnemonics, use `-t path_to_tendermint_key -m path_to_validator_mnemonic -r` (`-r` is to reset the chain).

## Setting up validator tools

### Example for Docker
```bash
KEYRING_PASSWORD=.. TOFND_PASSWORD=.. ./scripts/validator-tools-docker.sh
```

### Example for Host Mode (Binaries)
```bash
KEYRING_PASSWORD=.. TOFND_PASSWORD=.. ./scripts/validator-tools-host.sh
```

To recover from mnemonics, use `-z path_to_tofnd_mnemonic -p path_to_proxy_mnemonic`.
