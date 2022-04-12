# Network Upgrade

Instructions for 2022-mar-08 testnet chain id `axelar-testnet-lisbon-3` upgrade.

1. Validators please vote for the upgrade proposal via

```bash
axelard tx gov vote 4 yes --from validator
```

2. Wait for the proposed upgrade block (1060850). Your node will panic at that block height. Stop your node after chain halt.

```bash
pkill -f 'axelard start'
pkill -f 'axelard vald-start'
pkill -f tofnd
```

3. Backup the state and keys. **The following assumes you use the default path `~/.axelar_testnet`.**

```bash
cp -r ~/.axelar_testnet ~/.axelar_testnet-lisbon-3-upgrade-0.15
```

4. Restart your node with the new v0.15.0 build. Remember you need to run both the `node.sh` and `validator-tools-host.sh` scripts

```bash
KEYRING_PASSWORD="pw-1" ./scripts/node.sh
KEYRING_PASSWORD="pw-1" TOFND_PASSWORD="pw-2" ./scripts/validator-tools-host.sh
```

Pull the latest main branch of this repo (axelarate-community).
Follow instructions at [README](README.md) to start your node.
The join scripts should automatically pull the new binary from [Testnet releases](https://docs.axelar.dev/resources/testnet). Or you can add the flag `-a v0.15.0` to force a specific version.
