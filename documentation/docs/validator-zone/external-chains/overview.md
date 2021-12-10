# Overview
-----------

As a validator for the Axelar network, your Axelar node will vote on the status of external blockchains such as Ethereum, Cosmos, etc. Specifically:

1. Select which external chains your Axelar node will support.  Set up and configure your own nodes for the chains you selected.
2. Provide RPC endpoints for these nodes to your Axelar validator node and register as a maintainer for these chains on the Axelar network.

## External chains you can support on Axelar

* EVM-compatible chains
    * [Ethereum](/validator-zone/external-chains/ethereum)
    * Avalanche
    * Fantom
    * Moonbeam
    * Polygon
* Cosmos chains
    * Nothing to do. All Cosmos chains are automatically supported by default.

## Add external chain info to your validator's configuration

Edit the file `~/axelarate-community/join/config.toml`: set the `rpc_addr` and `start-with-bridge` entries corresponding to the external chain you wish to connect.

Your `config.toml` file should already contain a snippet like the following:

```toml
##### EVM bridges options #####
# Each EVM chain needs the following
# 1. `[[axelar_bridge_evm]]` # header
# 2. `name`                  # chain name (eg. "Ethereum")
# 3. 'rpc_addr'              # EVM RPC endpoint URL; chain maintainers set their own endpoint
# 4. `start-with-bridge`     # `true` to support this chain
#
# see https://docs.axelar.dev/#/validator-zone/external-chains/overview

[[axelar_bridge_evm]]
name = "Ethereum"
rpc_addr = ""
start-with-bridge = false

[[axelar_bridge_evm]]
name = "Avalanche"
rpc_addr = ""
start-with-bridge = false

[[axelar_bridge_evm]]
name = "Fantom"
rpc_addr = ""
start-with-bridge = false

[[axelar_bridge_evm]]
name = "Moonbeam"
rpc_addr = ""
start-with-bridge = false

[[axelar_bridge_evm]]
name = "Polygon"
rpc_addr = ""
start-with-bridge = false
```

### Example: Ethereum

Edit the `Ethereum` entry::

```toml
[[axelar_bridge_evm]]
name = "Ethereum"
rpc_addr = "my_ethereum_host"
start-with-bridge = true
```

Substitute your Ethereum RPC address for `my_ethereum_host`.  Be sure to set `start-with-bridge` to `true`.

## Restart your companion processes

Stop your companion processes `vald`, `tofnd` and then restart them.

!> :fire: Do not stop the `axelar-core` container.  If you stop `axelar-core` then you risk downtime for Tendermint consensus, which can result in penalties.

!> :fire: If `vald`, `tofnd` are stopped for too long then your validator might fail to produce a heartbeat transaction when needed.  The risk of this event can be reduced to near-zero if you promptly restart these processes shortly after a recent round of heartbeat transactions.

> Heartbeat events are emitted every 50 blocks.  Your validator typically responds to heartbeat events within 1-2 blocks.  It should be safe to restart `vald`, `tofnd` at block heights that are 5-10 mod 50.

> :bookmark: These instructions are for docker only.  Instructions for binaries are similar.

In a host terminal:

```bash
docker stop vald tofnd
```

Immediately resume your companion processes `vald`, `tofnd`:
```bash
./join/launch-validator-tools.sh
```

## Check your connections to new chains in vald

Check your `vald` logs to see that your validator node has successfully connected to the new EVM chains you added.

In docker:
```bash
docker logs -f vald 2>&1 | grep "EVM bridge for chain"
```
You should see something like:
```log
2021-11-25T01:25:54Z INF Successfully connected to EVM bridge for chain Ethereum module=vald
2021-11-25T01:25:54Z INF Successfully connected to EVM bridge for chain Avalanche module=vald
2021-11-25T01:25:54Z INF Successfully connected to EVM bridge for chain Fantom module=vald
2021-11-25T01:25:54Z INF Successfully connected to EVM bridge for chain Moonbeam module=vald
2021-11-25T01:25:54Z INF Successfully connected to EVM bridge for chain Polygon module=vald
```

## Register as a maintainer of external chains

For each external blockchain you selected earlier you must inform the Axelar network of your intent to maintain that chain.  This is accomplished via the `register-chain-maintainer` command.


> You only need to register as a chain maintainer once.  If you've already done it for chain C then you do not need to do it again for chain C.


In the `vald` container:
```bash
axelard tx nexus register-chain-maintainer [chains] --from [broadcaster] --node [axelar-core host]
```

### Example: Ethereum

```bash
axelard tx nexus register-chain-maintainer ethereum --from broadcaster --node http://axelar-core:26657
```

Output should be something like:

```json5
{"height":"2397","txhash":"65DA177E1F674E1F11AAA9DFBA2D522BA80E82EFD5271F95E7FDCE990544BA9D","codespace":"","code":0,"data":"0A2F0A2D2F6E657875732E763162657461312E5265676973746572436861696E4D61696E7461696E657252657175657374","raw_log":"[{\"events\":[{\"type\":\"chainMaintainer\",\"attributes\":[{\"key\":\"module\",\"value\":\"nexus\"},{\"key\":\"action\",\"value\":\"register\"},{\"key\":\"chain\",\"value\":\"ethereum\"},{\"key\":\"chainMaintainerAddress\",\"value\":\"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5\"}]},{\"type\":\"message\",\"attributes\":[{\"key\":\"action\",\"value\":\"RegisterChainMaintainer\"}]}]}]","logs":[{"msg_index":0,"log":"","events":[{"type":"chainMaintainer","attributes":[{"key":"module","value":"nexus"},{"key":"action","value":"register"},{"key":"chain","value":"ethereum"},{"key":"chainMaintainerAddress","value":"axelarvaloper1ylmsql3xc7t3qvgqjq44ntragzqn07p70j06j5"}]},{"type":"message","attributes":[{"key":"action","value":"RegisterChainMaintainer"}]}]}],"info":"","gas_wanted":"200000","gas_used":"61475","tx":null,"timestamp":""}
```
