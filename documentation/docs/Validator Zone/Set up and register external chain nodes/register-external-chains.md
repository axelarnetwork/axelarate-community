---
id: register-external-chains
sidebar_position: 1
sidebar_label: Set up and register external chain nodes
slug: /validator-zone/external-chains
---

# Set up and register external chain nodes

As an Axelar Network validator, your Axelar node will vote on the status of external blockchains such as Bitcoin, EVM, Cosmos. Specifically:

1. Select which external chains your Axelar node will support.  Set up and configure your own nodes for the chains you selected.
2. Provide RPC endpoints for these nodes to your Axelar validator node and register as a maintainer for these chains on the Axelar network.

## External chains you can support on Axelar

Chain-specific details for the above steps are linked below:

* Bitcoin (coming soon)
* [link] Ethereum and EVM-compatible chains
* [link] Cosmos chains

## Connect your external chain node to your Axelar validator

Stop your Axelar node. In a new terminal run

```bash
docker stop validator vald tofnd
```

_[TODO won't this cause a loss of validator uptime?  Maybe external chain connections should happen BEFORE staking.  But don't you need to be a staked validator to run `register-chain-maintainer`?  If so then these two steps must be separated by the staking step, which is inconvenient for this doc.]_

Edit the file `~/axelarate-community/join/config.toml`: find the `rpc_addr` line corresponding to the external chain you wish to connect and replace the default RPC URL with the URL of your external chain node node.

Start your Axelar node for the changes to take effect. Run the `./join/launch-validator.sh` script with the same arguments you used when you ran `./join/join-testnet.sh`. (Do NOT use the `--reset-chain` flag or your node will have to sync again from the beginning.)

## Register as a chain maintainer

Example: register your Axlear validator node as a chain maintainer for the Ethereum blockchain:

```bash
axelard tx nexus register-chain-maintainer ethereum --from broadcaster --node "$VALIDATOR_HOST" # eg VALIDATOR_HOST=http://127.0.0.1:26657
```
