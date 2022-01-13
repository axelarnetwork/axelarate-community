# Network Upgrade

Instructions for 2022-jan-13 testnet chain id `axlear-testnet-lisbon-2` upgrade.

1. Validators please vote for the upgrade proposal via
```bash
axelard tx gov vote 1 yes --from validator
```

2. Wait for the proposed upgrade block (14700). Your node will panic at that block height. Stop your node after chain halt.

Docker:
```bash
docker stop axelar-core vald tofnd
docker rm axelar-core vald tofnd
```
Binary:
```bash
pkill -f 'axelard start'
pkill -f 'axelard vald-start'
pkill -f tofnd
```

**Note that you will need to add the --home flag set to $HOME/.axelar_testnet/.core for binaries. You will also need to use the binary from $HOME/.axelar_testnet/bin/ (may be different depending on how you setup)**

3. Backup the state and keys.  If you used the default path then do this in the host (outside the container):
```bash
cp -r ~/.axelar_testnet ~/.axelar_testnet_lisbon-2-upgrade-backup
```
**Note that your state folder may exist at a different path if you are running your node with the binaries or if you used a non-default path.**

4. Restart your node with the new v0.13.0 build

Pull the latest main branch of this repo (axelarate-community).
Follow instructions at [README](README.md) to start your node.
The join scripts should automatically pull the new binary based on information at [testnet-releases.md](resources/testnet-releases.md).  Or you can add the flag `-a v0.13.0` to force a specific version.
