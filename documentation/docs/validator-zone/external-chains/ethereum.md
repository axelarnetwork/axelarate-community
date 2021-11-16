---
id: ethereum
sidebar_position: 2
sidebar_label: Ethereum
slug: /validator-zone/external-chains/ethereum
---

# [TODO revise] Set up your Ethereum Ropsten testnet node

Set up an Ethereum Ropsten testnet node using `Geth`.

1. [Install Geth](https://geth.ethereum.org/docs/install-and-build/installing-geth).

2. Start downloading the Ethereum Ropsten testnet chain. This may take many hours.

```bash
geth --ropsten --syncmode "snap" --http --http.vhosts "*"
```

First, the majority of the blocks will be downloaded. Then your node will synchronize as the last few blocks catch up. This second part may take a long time. 

To stop the node from downloading, press `Control C`.

3. Check the status of your node.

First find the path to your node's `ipc` which is located in 
```bash
{Path to Default Ethereum Data Storage}/ropsten/geth.ipc
```

eg) on macOS

```bash
/Users/jacky/Library/Ethereum/ropsten/geth.ipc
```

Open a new terminal and run the following. Replace the `ipc` path with your own.
```bash
geth attach ipc:/Users/jacky/Library/Ethereum/ropsten/geth.ipc
```

Check the status of your Ethereum node.
```bash
eth.syncing
```

4. Find the RPC endpoint for Axelar to connect.

If you used the above settings, your RPC endpoint should be 

```bash
http://host.docker.internal:8545
```

Write down the RPC endpoint, you will need it later.

5. OPTIONAL: Test your Ethereum node.

After your Ethereum node is fully synced, you can send an RPC request to it using cURL. 

```bash
curl -X POST http://localhost:8545 \
-H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

## Ethereum Ropsten testnet node configuration

1. Ensure your Ropsten testnet node is up to date. Stop the node before making any configuration changes.

2. Enable the following configurations.

* Enable the `HTTP-RPC Server` for RPC communication.
* Set `HTTP-RPC virtual address` as `*`
* Set `HTTP-RPC listening address` as `0.0.0.0`.

3. Find the RPC endpoint of your Ethereum node for Axelar to connect to.

Your Ethereum Ropsten testnet node's RPC endpoint should be

```bash
http://{IPADDRESS}:{PORT}
```

If your node is running using docker, use `host.docker.internal` as the `IPADDRESS`.
eg)

```bash
http://host.docker.internal:8332
```


