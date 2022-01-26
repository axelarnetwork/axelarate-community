# axelarate-community

Tools to join the Axelar network

## Disclaimer
The Axelar network is under active development.  Use at your own risk with funds you're comfortable using.  See [Terms of use](https://docs.axelar.dev/#/terms-of-use).

## Join as a node

See [Setup instructions](https://docs.axelar.dev/#/parent-pages/setup).

This document covers scenarios not addressed at https://docs.axelar.dev/
# Join with docker

Run your Axelar node inside a docker container by adding the `-e docker` flag to the `node.sh` script described in [Setup instructions](https://docs.axelar.dev/#/parent-pages/setup).

Example:
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

To recover from mnemonics, use `-t path_to_tendermint_key -m path_to_validator_mnemonic -r` (`-r` is to reset the chain).

## Set up validator tools

### Example for Docker
```bash
KEYRING_PASSWORD=.. TOFND_PASSWORD=.. ./scripts/validator-tools-docker.sh
```

### Example for Host Mode (Binaries)
```bash
KEYRING_PASSWORD=.. TOFND_PASSWORD=.. ./scripts/validator-tools-host.sh
```

To recover from mnemonics, use `-z path_to_tofnd_mnemonic -p path_to_proxy_mnemonic`.
