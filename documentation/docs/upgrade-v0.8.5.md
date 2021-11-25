---
id: upgrace-v0.8.5
sidebar_position: 10
sidebar_label: Upgrade to v0.8.5
slug: /upgrade-v0.8.5
---

# How to upgrade your node to v0.8.5

Please perform this process sometime before 14:30 UTC on Friday, 2021-nov-26.

## Ordinary (non-validator) nodes: Docker

TL;DR
```
docker stop axelar-core
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet.sh --axelar-core v0.8.5
```

Upgrade is very simple---just restart your node.  The `cp` command above creates a backup copy of your testnet data.  If something goes wrong then you can restore your node's state from the backup.

## Validator nodes: Docker

TL;DR
```
docker stop axelar-core vald tofnd
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet.sh --axelar-core v0.8.5
./join/launch-validator-tools.sh --axelar-core v0.8.5
```

Like upgrading a non-validator node---just restart your node.  As above, the `cp` command creates a backup copy of your testnet data in case something goes wrong.
