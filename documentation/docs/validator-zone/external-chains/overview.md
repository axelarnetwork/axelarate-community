---
id: external-chains
sidebar_position: 1
sidebar_label: Overview
slug: /validator-zone/external-chains
---

# Overview

As a validator for the Axelar network, your Axelar node will vote on the status of external blockchains such as Bitcoin, EVM, Cosmos. Specifically:

1. Select which external chains your Axelar node will support.  Set up and configure your own nodes for the chains you selected.
2. Provide RPC endpoints for these nodes to your Axelar validator node and register as a maintainer for these chains on the Axelar network.

## External chains you can support on Axelar

Chain-specific details for the above steps are linked below:

* Bitcoin (coming soon)
* [Ethereum and EVM-compatible chains](/validator-zone/external-chains/evm)
* Cosmos chains (coming soon)

## [TODO fix] Connect your external chain node to your Axelar validator

Stop your Axelar node. _[TODO is it necessary to stop `validator`?  That's validator downtime!]_ In a new terminal run

```bash
docker stop validator vald tofnd
```

Edit the file `~/axelarate-community/join/config.toml`: find the `rpc_addr` line corresponding to the external chain you wish to connect (example: Ethereum) and replace the default RPC URL with the URL of your external chain node node.

Start your Axelar node:
```
./join/launch-validator.sh
```

## Register as a maintainer of external chains

For each external blockchain you selected earlier you must inform the Axelar network of your intent to maintain that chain.  This is accomplished via the `register-chain-maintainer` command:

Example: register your Axlear validator node as a chain maintainer for the Ethereum blockchain:

```bash
axelard tx nexus register-chain-maintainer ethereum --from broadcaster --node "$VALIDATOR_HOST" # eg VALIDATOR_HOST=http://127.0.0.1:26657
```