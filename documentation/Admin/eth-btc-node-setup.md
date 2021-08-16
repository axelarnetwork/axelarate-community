---
id: eth-btc
sidebar_position: 7
sidebar_label: Eth Btc Node Setup
slug: /eth-btc
---
# Set up Bitcoin and Ethereum nodes
This tutorial helps you set up a `Bitcoin testnet` and `Ethereum Ropsten testnet` node on your local machine using `Bitcoin Core` and `Geth`. In particular, this is useful for completing `Exercise 3` when you do not have existing testnet nodes, or as a reference for how to configure your nodes running on a different setup.

## Bitcoin testnet node
Set up a Bitcoin testnet node using `bitcoind` from `Bitcoin Core`.

1. Download Bitcoin Core.

Find the installation guide for your machine from the [Github Repo](https://github.com/bitcoin/bitcoin/tree/master/doc). Follow the instructions to download the binary executable commands, including `bitcoind`. Do not use the `bitcoind` command to start downloading the blockchain until later.

2. Find the directory where the `bitcoind` command executable is located. This is typically in the cloned bitcoin repo, under the `src` folder. `cd` into the directory so you can use the `bitcoind` command.

3. Check that `bitcoind` is installed properly

```bash
./bitcoind --help
```

4. [Find the default data directory](https://en.bitcoin.it/wiki/Data_directory) of your Bitcoin node. Create a file called `bitcoin.conf` inside this directory.

eg) For macOS

```bash
mkdir -p "/Users/jacky/Library/Application Support/Bitcoin"
touch "/Users/jacky/Library/Application Support/Bitcoin/bitcoin.conf"
chmod 600 "/Users/jacky/Library/Application Support/Bitcoin/bitcoin.conf"
```

Use the above commands and change the folder path to be the data directory of your system.

5. Generate the Bitcoin node configuration file used by `bitcoind`.

Use [this tool](https://jlopp.github.io/bitcoin-core-config-generator/) to create the contents of your `bitcoin.conf` file.
Note: The following settings are general guidelines that work for most setups. Your setup may require some changes.

Set the following:
* At the top, set your operating system.
* Under `Bitcoin Core`, enable `Daemon Mode`.
* Under `RPC API`, enable `RPC Server`.
* Under `RPC API`, look for `RPC Auth`. Follow the link and provide a username and password. Write down the username and password as you will need it later. Copy the generated value and paste it back into the `RPC Auth` field.
* Under `RPC API`, set `RPC Allow IP Address` as `0.0.0.0/0`.
* Under `RPC API`, set `Bind RPC Address` as the public IP address of the bitcoin node.

Copy the contents of the generated `bitcoin.conf` file and paste it into the file you created in the last step.

Under `# Options only for testnet [test]` add the following two lines, then save.

```bash
# Listen for JSON-RPC connections on this port
rpcport=8332
```

6. Start downloading the bitcoin testnet chain. Go back to the directory where the `bitcoind` binary is located to run the following.

```bash
./bitcoind -testnet
```

You should see a message `Bitcoin Core starting`. Wait for the Bitcoin testnet chain to download, this could take a few hours.
If you want to look at the progress, find the `debug.log` file within the default Bitcoin data directory.

eg) For macOS, you can run
```bash
tail -10 ~/Library/Application\ Support/Bitcoin/testnet3/debug.log
```

To stop the Bitcoin testnet node from downloading and syncing
```bash
./bitcoin-cli -testnet stop
```

7. Find the RPC endpoint for Axelar to connect.

If you used the above settings, your RPC endpoint should be 

```bash
http://{USERNAME}:{PASSWORD}@host.docker.internal:8332
```

eg)

```bash
http://jacky:mypassword@host.docker.internal:8332
```

The `username` and `password` fields are the values you provided to the `RPC Auth` setting in step 5. Write down the Bitcoin RPC endpoint as you will need it later.

8. OPTIONAL: Test your Bitcoin node.

After your Bitcoin node is fully synced, you can send an RPC request to it using cURL. Use the following and replace the RPC endpoint username and password.

```bash
curl -X POST http://jacky:mypassword@localhost:8332 \
-H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"getblockchaininfo","params":[],"id":1}'
```


## Ethereum Ropsten testnet node
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
