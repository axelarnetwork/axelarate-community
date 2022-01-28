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
> **OPTION 1** is to create the directory in advance and change the ownership to 1000:1001, where 1000 is axelard user inside container and 1001 is the axelard group inside the container. This requires root permission on the host machine.
>
> **OPTION 2** is to build the container image from source. Checkout the correct tag in axelar-core. To create an image run:
>
> `make docker-image-local-user`
>
> This will create an image with the a tag `<version>-local`. For example, for `v0.0.0` the tag will be `v0.0.0-local`. This image will now use the same user id and group id for the axelard user inside the container as the user used to build it on your host and hence will have the same permissions.
>
> Now to run the node/vald processes, you just need to add `--user USER_ID:GROUP_ID` to the docker run commands in `docker.sh` and `validator-tools-docker.sh`(only for vald). Here USER_ID is your user id and GROUP_ID is your group id. You can use `id -u` and `id -g` to determine these respectively.
>
> When running the binary, specify the image you just created using the `-a` flag like `-a v0.0.0-local`.
>
> Note that the alpine base image already has some users and groups created and if there is a collision with one of the existing user id or group id in the base image, you have no option but to create a new user with different ids, unique from the ones in the base image.

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


## Bug bounty and disclosure of vulnerabilities

See the [Axelar documentation website](https://docs.axelar.dev/#/bug-bounty).
