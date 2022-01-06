# Network Upgrade

1. Wait for the proposed upgrade block. Your node will panic and stop once the block is reached. If you are running a validator, you will need to vote for the upgrade proposal beforehand. You can do so by running
```bash
axelard tx gov vote 1 yes --from validator --gas auto --gas-adjustment 1.5
```

2. Backup the state and keys.  If you used the default path then do this in the host (outside the container):
```bash
cp ~/.axelar_testnet ~/.axelar_testnet_upgrade-v0.12_backup
```
**Note that your state folder may exist at a different path if you are running your node with the binaries or if you used a non-default path.**

3. Clear `vald` state.  In the host (outside the container):
```bash
rm ~/.axelar_testnet/.vald/vald/state.json
```

4. Reset blockchain state

If running in a docker environment, its best to open a shell with the axelar root mounted. Modify the following command so that it mounts the correct directory for your machine and uses the correct version of axelar-core.
```bash
docker run -ti --entrypoint /bin/sh -v /Users/myuser/.axelar_testnet/.core:/home/axelard/.axelar axelarnet/axelar-core:v0.10.7
```

Once you have a shell open, reset the chain:
```bash
axelard unsafe-reset-all
```

5. Wait for the Axelar team to publish the new genesis file for the new chain. The genesis files can be found at https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json

Once the new genesis file is published, place it in `/home/axelard/.axelar/config/`.

**Note that the path may be different if you are running your node with the binaries.**

6. Restart your node.  The join scripts should automatically pull the new binary based on information at [testnet-releases.md](https://github.com/axelarnetwork/axelarate-community/blob/main/resources/testnet-releases.md).  Or you can add the flag `-a v0.12.0` to force a specific version.
