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

Release information can be found at [`resources/testnet-releases`](./resources/testnet-releases.md). See section below on *Catching up from Scratch* if you are starting a fresh node.

## Joining as a Node

When joining for the first time, delete your existing `~/.axelar_testnet` folder.

### Example for Docker
```bash
KEYRING_PASSWORD=.. ./scripts/node.sh -e docker
```
⚠️ **Process inside container runs with root user. See note below**

> **RootLess Docker Note**
>
> On some linux systems the permissions for bind mounted directories do not propagate to the container. i.e the axelar root directory, for e.g. ~/.axelar_testnet will not have the correct permissions for the axelard user inside the container to be able to modify it with.
>
> In this case, you have two options.
>
> One option is to create the directory in advance and change the ownership to 1000:1001, where 1000 is axelard user inside container and 1001 is the axelard group inside the container. This requires root permission on the host machine.
>
> The second option is to build the container image from source. Checkout the correct tag in axelar-core. Modify the Dockerfile in axelar-core to reflect your user and group. You will also have to modify the image name in the scripts here to deploy the image you just created.

### Example for Host Mode (Binaries)
```bash
KEYRING_PASSWORD=.. ./scripts/node.sh -e host
```

To recover from mnemonics, use `-t path_to_tendermint_key -m path_to_validator_mnemonic -r` (`-r` is to reset the chain).


### Catching up from Scratch
In case you are starting a node from scratch, you will have to run the correct binaries to catch up. The details are mentioned in the *Upgrade Section* of the [`testnet-releases document`](./resources/testnet-releases.md). Let's walk through an example for the following details:
> Core Version  | Start Height | End Height
> ------------- | ------------- | -------------
> v0.10.7 | 0 | 14700
> v0.13.0 | 14701 | N/A
>
This means that you have to catch up to block 14700 with axelar-core version v0.10.7. And then use v0.13.0 to continue. \
\
So you would run the following command (for docker):
`KEYRING_PASSWORD=.. ./scripts/node.sh -e docker -a v0.10.7` \
\
Once the node catches up to height 1470, you will see a panic in the logs: \

`panic: UPGRADE "v0.13" NEEDED at height: 14700: ` \

At this point, you will have to re-run the process with a new version of the core. When using binaries in host mode, you can simply run: \
`KEYRING_PASSWORD=.. ./scripts/node.sh -e host -a v0.13.0` \

This will resume the node and it will catch up. \
\
For docker, you have one extra step. Run the following command: \
`docker stop axelar-core && docker rm axelar-core` \
\
After this simply run:
`KEYRING_PASSWORD=.. ./scripts/node.sh -e docker -a v0.13.0` \
This will resume the node and it will start catching up to the latest height or the height of the next upgrade.

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
