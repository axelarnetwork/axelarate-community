# Network Upgrade

1. If you are running a validator, you will need to vote for the upgrade proposal beforehand. You can do so by running
```bash
axelard tx gov vote 1 yes --from validator --gas auto --gas-adjustment 1.5
```

2. Wait for the proposed upgrade block. Your node will panic once the block is reached. Stop your node after chain halt.
For user runs in docker
```bash
docker stop axelar-core vald tofnd
docker rm axelar-core vald tofnd
```
For user runs in binary
```bash
pkill -f 'axelard start'
pkill -f 'axelard vald-start'
pkill -f tofnd
```

**Note that you will need to add the --home flag set to $HOME/.axelar_testnet/.core for binaries. You will also need to use the binary from $HOME/.axelar_testnet/bin/ (may be different depending on how you setup)**

3. Backup the state and keys.  If you used the default path then do this in the host (outside the container):
```bash
cp -r ~/.axelar_testnet ~/.axelar_testnet_upgrade-v0.12_backup
```
**Note that your state folder may exist at a different path if you are running your node with the binaries or if you used a non-default path.**

4. Reset blockchain state

If running in a docker environment, its best to open a shell with the axelar root mounted. Modify the following command so that it mounts the correct directory for your machine and uses the correct version of axelar-core.
```bash
docker run -ti --entrypoint /bin/sh -v $HOME/.axelar_testnet/.core:/home/axelard/.axelar axelarnet/axelar-core:v0.10.7
```

Once you have a shell open, reset the chain:
```bash
axelard unsafe-reset-all
```
**Note that similar to step 1, when running binaries you will have to provide path to axelard binary and run with --home $HOME/.axelar_testnet/.core flag**

5. Reset Vald State.
The vald state reset does not require the axelard binary. It is a simple file removal. So it can be done without mounting a volume inside a container.

```bash
rm $HOME/.axelar_testnet/.vald/vald/state.json
```


6. Wait for the Axelar team to publish the new genesis file for the new chain. The genesis files can be found at https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json
remove both genesis files, the start script will fetch the new genesis file automatically.
```
rm $HOME/.axelar_testnet/shared/genesis.json
rm $HOME/.axelar_testnet/.core/config/genesis.json
```

**Note that the path may be different if you are running your node with the binaries.**

7. Restart your node. Make sure you have pulled the latest main branch of the repo. The join scripts should automatically pull the new binary based on information at [testnet-releases.md](https://github.com/axelarnetwork/axelarate-community/blob/main/resources/testnet-releases.md).  Or you can add the flag `-a v0.12.0` to force a specific version.
