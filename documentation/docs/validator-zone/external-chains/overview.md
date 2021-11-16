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

* EVM-compatible chains
    * [Ethereum](/validator-zone/external-chains/ethereum)
    * Avalanche (coming soon)
    * Fantom (coming soon)
    * Polygon (coming soon)
* Cosmos chains
    * Nothing to do.  All Cosmos chains are automatically supported by default.
* Bitcoin (inactive)

## Connect your external chain node to your Axelar validator

You may skip this step if you already did it earlier.

Stop your companion processes `vald`, `tofnd`.

:::warning
Do not stop the `axelar-core` container.  If you stop `axelar-core` then you risk downtime for Tendermint consensus, which can result in penalties.
:::

In a host terminal:

```bash
docker stop vald tofnd
```

Edit the file `~/axelarate-community/join/config.toml`: edit the `rpc_addr` and `start-with-bridge` entries corresponding to the external chain you wish to connect.  (See Ethereum example below.)

Resume your companion processes `vald`, `tofnd`:
```
./join/launch-validator-tools.sh
```

### Example: Ethereum

Your `config.toml` file should contain a snippet like the following:

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

Substitute your Ethereum RPC address for `my_ethereum_host`.

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
