---
id: upgrade-v0.8.5
sidebar_position: 10
sidebar_label: Upgrade to v0.8.5
slug: /upgrade-v0.8.5
---

# How to upgrade your node to v0.8.5

:::warning
Please perform this upgrade process sometime before 14:30 UTC on Friday, 2021-nov-26.

After that time, nodes running any version of axelar-core prior to v0.8.5 will fall out of consensus with testnet.
:::

Checkout verion 0.7.7 of axelarate-community.  In your local axelarate-community repo:
```
git pull
git checkout v0.7.7
```

:::note
All terminal commands in this document should be run in your local axelarate-community repo.
:::
## Docker

### Ordinary (non-validator) nodes

TL;DR
```
docker stop axelar-core
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet.sh --axelar-core v0.8.5
```

Upgrade is very simple---just restart your node.  The `cp` command above creates a backup copy of your testnet data.  If something goes wrong then you can restore your node's state from the backup.

### Validator nodes

TL;DR
```
docker stop axelar-core vald tofnd
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet.sh --axelar-core v0.8.5
./join/launch-validator-tools.sh --axelar-core v0.8.5
```

Like upgrading a non-validator node---just restart your node.  As above, the `cp` command creates a backup copy of your testnet data in case something goes wrong.

## Binaries

### Ordinary (non-validator) nodes

TL;DR
```
kill -9 $(pgrep -f "axelard start")
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet-with-binaries.sh --axelar-core v0.8.5
```

As with docker, the `cp` command creates a backup copy of your testnet data in case something goes wrong.

### Validator nodes

TL;DR
```
kill -9 $(pgrep tofnd)
kill -9 $(pgrep -f "axelard vald-start")
kill -9 $(pgrep -f "axelard start")
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet-with-binaries.sh --axelar-core v0.8.5
./join/launch-validator-tools-with-binaries.sh --axelar-core v0.8.5
```

As with docker, the `cp` command creates a backup copy of your testnet data in case something goes wrong.

## Get out of jail

It is likely that your validator node will acquire Tendermint `jail` status after the above process.  If this happens then see [Unjail](/validator-zone/troubleshoot/unjail) for instructions on how to fix this condition.