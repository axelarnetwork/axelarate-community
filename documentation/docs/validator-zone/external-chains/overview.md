---
id: external-chains
sidebar_position: 1
sidebar_label: Overview
slug: /validator-zone/external-chains
---

# Overview

As a validator for the Axelar network, your Axelar node will vote on the status of external blockchains such as Ethereum, Cosmos, etc. Specifically:

1. Select which external chains your Axelar node will support.  Set up and configure your own nodes for the chains you selected.
2. Provide RPC endpoints for these nodes to your Axelar validator node and register as a maintainer for these chains on the Axelar network.

## External chains you can support on Axelar

* EVM-compatible chains
    * [Ethereum](/validator-zone/external-chains/ethereum)
    * Avalanche
    * Fantom (coming soon)
    * Polygon (coming soon)
* Cosmos chains
    * Nothing to do.  All Cosmos chains are automatically supported by default.
* Bitcoin (inactive)

## Add external chain info to your validator's configuration

You may skip this step if you already did it earlier.

Edit the file `~/axelarate-community/join/config.toml`: set the `rpc_addr` and `start-with-bridge` entries corresponding to the external chain you wish to connect.

### Example: Ethereum

Your `config.toml` file should already contain a snippet like the following:

```toml
##### EVM bridges options #####
[[axelar_bridge_evm]]

# Chain name
name = "Ethereum"

# Address of the ethereum RPC server
# chain maintainers must set their own rpc endpoint
rpc_addr    = "my_ethereum_host"

# chain maintainers should set start-with-bridge to true
start-with-bridge = true
```

Substitute your Ethereum RPC address for `my_ethereum_host`.  Be sure to set `start-with-bridge` to `true`.

### Example: Avalanche

Add an additional new section `[[axelar_bridge_evm]]` to your `config.toml`:

```toml
[[axelar_bridge_evm]]

# Chain name
name = "Avalanche"

# Address of the avalanche RPC server
# chain maintainers must set their own rpc endpoint
rpc_addr    = "my_avalanche_host"

# chain maintainers should set start-with-bridge to true
start-with-bridge = true
```

Substitute your Avalanche RPC address for `my_avalanche_host`.  Be sure to specify the Avalanche C-chain RPC endpoint---that's the EVM-compatible Avalanche chain.  Example:
```toml
rpc_addr    = "https://my.avalance.rpc/ext/bc/C/rpc"
```

## Restart your companion processes

Stop your companion processes `vald`, `tofnd` and then restart them.

:::warning
Do not stop the `axelar-core` container.  If you stop `axelar-core` then you risk downtime for Tendermint consensus, which can result in penalties.
:::

:::warning
If `vald`, `tofnd` are stopped for too long then your validator might fail to produce a heartbeat transaction when needed.  The risk of this event can be reduced to near-zero if you promptly restart these processes shortly after a recent round of heartbeat transactions.
:::

:::tip
Heartbeat events are emitted every 50 blocks.  Your validator typically responds to heartbeat events within 1-2 blocks.  It should be safe to restart `vald`, `tofnd` at block heights that are 5-10 mod 50.
:::

In a host terminal:

```bash
docker stop vald tofnd
```

Immediately resume your companion processes `vald`, `tofnd`:
```
./join/launch-validator-tools.sh
```

## Register as a maintainer of external chains

For each external blockchain you selected earlier you must inform the Axelar network of your intent to maintain that chain.  This is accomplished via the `register-chain-maintainer` command.

In the `vald` container:
```bash
axelard tx nexus register-chain-maintainer [chains] --from [broadcaster] --node [axelar-core host]
```

### Example: Ethereum

```
axelard tx nexus register-chain-maintainer ethereum --from broadcaster --node http://axelar-core:26657
```

Output should be something like:

```
{"height":"2397","txhash":"65DA177E1F674E1F11AAA9DFBA2D522BA80E82EFD5271F95E7FDCE990544BA9D","codespace":"","code":0,"data":"0A2F0A2D2F6E657875732E763162657461312E5265676973746572436861696E4D61696E7461696E657252657175657374","raw_log":"[{\"events\":[{\"type\":\"chainMaintainer\",\"attributes\":[{\"key\":\"module\",\"value\":\"nexus\"},{\"key\":\"action\",\"value\":\"register\"},{\"key\":\"chain\",\"value\":\"ethereum\"},{\"key\":\"chainMaintainerAddress\",\"value\":\"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5\"}]},{\"type\":\"message\",\"attributes\":[{\"key\":\"action\",\"value\":\"RegisterChainMaintainer\"}]}]}]","logs":[{"msg_index":0,"log":"","events":[{"type":"chainMaintainer","attributes":[{"key":"module","value":"nexus"},{"key":"action","value":"register"},{"key":"chain","value":"ethereum"},{"key":"chainMaintainerAddress","value":"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5"}]},{"type":"message","attributes":[{"key":"action","value":"RegisterChainMaintainer"}]}]}],"info":"","gas_wanted":"200000","gas_used":"61475","tx":null,"timestamp":""}
```

### Example: Both Ethereum and Avalanche

You can register as a maintainer for multiple chains in a single command:
```
axelard tx nexus register-chain-maintainer ethereum avalanche --from broadcaster --node http://axelar-core:26657
```
