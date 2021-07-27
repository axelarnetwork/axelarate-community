---
id: e3
sidebar_position: 3
sidebar_label: Exercise 3
slug: /exercises/e3
---
# Exercise 3
Join and leave the Axelar Network as a validator node.

Convert an existing Axelar Network node into a validator by attaching Bitcoin and Ethereum nodes and staking tokens. A validator participates in block creation, transaction signing, and voting.

## Level
Advanced

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)

## Useful links
- [Extra commands to query Axelar Network state](/useful-commands)

## Joining the Axelar testnet
Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account.

## Set up Bitcoin and Ethereum nodes
As an Axelar Network validator, your Axelar node will vote on the status of Bitcoin and Ethereum transactions. To do so, you must first set up and configure your Bitcoin and Ethereum testnet nodes, and then provide the RPC endpoints to Axelar.

If you do not already have a Bitcoin testnet node and Ethereum Ropsten testnet node running, you can follow the [instructions](https://github.com/axelarnetwork/axelarate-community/blob/main/BTC%20ETH%20NODE%20SETUP.md) to set up and configure them, then skip to the next section `Connect Bitcoin and Ethereum nodes to Axelar`. You can also set up an alternative configuration of your choice.

Bitcoin and Ethereum node configuration will vary for different systems. Detailed configuration instructions for a local machine running `macOS` `Bitcoin Core` and `Geth` can be found [here](https://github.com/axelarnetwork/axelarate-community/blob/main/BTC%20ETH%20NODE%20SETUP.md) and used as a reference.

### Bitcoin testnet node configuration

1. Ensure your Bitcoin testnet node is up to date. Stop the node before making any configuration changes.

2. Enable the following configurations.

* Enable the `RPC Server`.
* Generate the `RPC Auth` value by supplying a username and password (make sure to save the username and password somewhere, you will need it later). An example `RPC Auth` value is 
```bash
rpcauth=jacky:a8e51174a095fe52491f4f487d41053a$9336f388b175ef3a8a63b248446aa3ccd0c8644bbb85ab005d447e164b7e9712
```
* Set `RPC Allow IP Address` as `0.0.0.0/0`.

3. Find the RPC endpoint of your Bitcoin node for Axelar to connect to.

Your Bitcoin testnet node's RPC endpoint should be

```bash
http://{USERNAME}:{PASSWORD}@{IPADDRESS}:{PORT}
```

If your node is running on `localhost`, use `host.docker.internal` as the `IPADDRESS` since Axelar runs in a docker container.
eg)

```bash
http://jacky:mypassword@host.docker.internal:18332
```

The `username` and `password` fields are the values you provided to the `RPC Auth` setting earlier. Write down the Bitcoin RPC endpoint as you will need it later.

4. OPTIONAL: Test your Bitcoin node.

To test your setup, you can send an RPC request to your Bitcoin node using cURL. Use the following and replace the RPC endpoint.

```bash
curl -X POST http://jacky:mypassword@localhost:8332 \
-H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"getblockchaininfo","params":[],"id":1}'
```


### Ethereum Ropsten testnet node configuration

1. Ensure your Ropsten testnet node is up to date. Stop the node before making any configuration changes.

2. Enable the following configurations.

* Enable the `HTTP-RPC Server` for RPC communication.
* Set `HTTP-RPC virtual address` as `*`
* Set `HTTP-RPC listening address` as `0.0.0.0`.

3. Find the RPC endpoint of your Bitcoin node for Axelar to connect to.

Your Ethereum Ropsten testnet node's RPC endpoint should be

```bash
http://{IPADDRESS}:{PORT}
```

If your node is running on `localhost`, use `host.docker.internal` as the `IPADDRESS` since Axelar runs in a docker container.
eg)

```bash
http://host.docker.internal:8332
```

4. OPTIONAL: Test your Ethereum node.

To test your setup, you can send an RPC request to your Ethereum node using cURL. Use the following and replace the RPC endpoint.

```bash
curl -X POST http://localhost:8545 \
-H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```


## Connect Bitcoin and Ethereum nodes to Axelar

1. Have an Axelar node fully caught up and running by completing the steps in `README.md`. Ensure you have some testnet coins on your validator address.

2. Stop the Axelar node. Open a new terminal and run

```bash
docker stop $(docker ps -a -q)
```
```bash
docker rm $(docker ps -a -q)
```

3. Go to your home directory and open `~/.axelar_testnet/shared/config.toml`.

4. Scroll to the bottom of the file, and look for `##### bitcoin bridge options #####` and `##### EVM bridges options #####`.

5. Find the `rpc_addr` line and replace the default RPC URL with the URL of your node, for both Bitcoin and Ethereum. Save the file. This RPC URL was found and written down during the Bitcoin and Ethereum node setup section.

6. Start your Axelar node for the changes to take effect. Run the `join/joinTestnet.sh` script again, with the same `--axelar-core`, `--tofnd` (and optionally `--root`) parameters as before. Do NOT use the `--reset-chain` flag or your node will have to sync again from the beginning.


## Joining the Network as a Validator

1. Enter Axelar node CLI
```bash
docker exec -it axelar-core sh
```

2. Load funds onto your `broadcaster` account, which you will use later.

Find the address with

```bash
axelard keys show broadcaster -a
```

Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and get some coins on your broadcaster address.

Check that you received the funds

```bash
axelard q bank balances {broadcaster address}
```

eg)

```bash
axelard q bank balances axelar1p5nl00z6h5fuzyzfylhf8w7g3qj6lmlyryqmhg
```

3. Find the minimum amount of coins you need to stake. 

To become a full fledged validator that participates in threshold multi-party signatures, your validator needs to stake at least 0.5% or 1/200 of the total staking pool.

Go into the Axelar discord server and find the `testnet` channel. Open up the `pinned` messages at the top right corner and scroll down to the very first pinned message, which contains many links. Find the link for `Monitoring` as well as the testnet user login credentials and use it to sign in.

Once you are signed in to the monitoring dashboard, look for an entry called `Bonded Tokens`. This is the total pool of staked tokens in the network, denominated in `axltest`. However, later when you use the CLI, it actually accepts denominations in micro `axltest` where 1 `axltest` = 1,000,000 micro `axltest`. 

So to find the minimum amount of coins you need to stake in the next step, calculate `{total pool} * 1000000 / 200`.

eg)
If the dashboard displays `3k` `Bonded Tokens`, the minimum amount is `3000 * 1000000 / 200 = 15000000`.

:warning: **Important:** Key shares for signing transactions on other chains are distributed proportionally to the validators' stakes on Axelar. In order to keep the number of key shares low for now, please delegate a similar amount of stake as existing validators have, i.e. `100000000axltest`.

4. Make your `validator` account a validator by staking some coins.

Use the following command, but change the `amount` to be larger than the minimum stake amount calculated in the last step. Remember that this is actually denominated in micro `axltest`. Also change the `moniker` to be a descriptive nickname for your validator.

```bash
axelard tx staking create-validator --yes \
--amount "100000000axltest" \
--moniker "testvalidator1" \
--commission-rate="0.10" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--pubkey "$(axelard tendermint show-validator)" \
--from validator \
-b block
```

To check how many coins your validator has currently staked.
```bash
axelard q staking validator "$(axelard keys show validator --bech val -a)" | grep tokens
```

If you wish to stake more coins after the initial validator creation.
```bash
axelard tx staking delegate {axelarvaloper address} {amount} --from validator -y
```

eg)

```bash
axelard tx staking delegate "$(axelard keys show validator --bech val -a)" "100000000axltest" --from validator -y
```

5. Register the broadcaster account as a proxy for your validator. Axelar network propagates messages from threshold multi-party computation protocols via the underlying consensus. The messages are signed and delivered via the blockchain.

```bash
axelard tx snapshot registerProxy broadcaster --from validator -y
```

6. Check that your node's `vald` and `tofnd` are connected properly. As a validator, your `axelar-core` container will talk with your `tofnd` container through the `vald` module. This is important when events such as key rotation happens on the network.

First, check that the vald process is running. Run the following commands in a new terminal.

```bash
docker exec axelar-core ps
```

Look for a process called `vald-start`. If you see it, then your `vald` module has successfully started and connected with `tofnd`. You're good to go! 

### Start-up troubleshoot

If the process was missing, check if `tofnd` is running. Install the `nmap` command if you do not have it, and check the tofnd port

```bash
nmap -p 50051 localhost
```

Look for the `STATE` of the port, which should be `open` or `closed`. If the port is `closed`, restart your node and ensure tofnd is running. If the port is `open`, then there is a connection issue between vald and tofnd.

To fix the connectivity issue, find the `tofnd` container address manually and provide it to `vald`.
Find the `tofnd` address.

```bash
docker inspect tofnd
```

Near the bottom of the JSON output, look for `Networks`, then `bridge`, `IPAddress`, and copy the address listed.
Next, ping the IP Address from inside `Axelar Core` to see if it works. Install the `ping` command if it does not exist already.

```bash
docker exec axelar-core ping {your tofnd IP Address}
```

eg)

```bash
docker exec axelar-core ping 172.17.0.2
```

You should see entries starting to appear one by one if the connection succeeded. Stop the ping with `Control + C`.
Save this IP address.

Next, query your validator address with
 
```bash
docker exec axelar-core axelard keys show validator --bech val -a
```
:::caution
Make sure the validator address that is returned starts with `axelarvaloper`
:::

Now, start `vald`, providing the IP address and validator address:

```bash
docker exec axelar-core axelard vald-start --tofnd-host {your tofnd IP Address} --validator-addr {your validator address} 
```
eg)
```bash
docker exec axelar-core axelard vald-start --tofnd-host 172.17.0.2 --validator-addr axelarvaloper1y4vplrpdaqplje8q4p4j32t3cqqmea9830umwl
```



Your vald should be connected properly. Confirm this by running the following and looking for an `vald-start` entry.
```bash
docker exec axelar-core ps
```


Your node is now a validator! Stay as a validator and keep your node running for at least a day. If you wish to stop being a validator, follow the instructions in the next section.


## Leaving the Network as a Validator

1. Deactivate your broadcaster account.
```bash
axelard tx snapshot deactivateProxy --from validator -y -b block
```

2. Wait until the next key rotation for the changes to take place. In this release, we're triggering key rotation about once a day. So come back in 24 hours, and continue to the next step. If you still get an error after 24 hours, reach out to a team member.

3. Release your staked coins.
```bash
axelard tx staking unbond {axelarvaloper address} {amount} --from validator -y -b block
```

eg)

```bash
axelard tx staking unbond "$(axelard keys show validator --bech val -a)" "100000000axltest" --from validator -y -b block
```

`amount` refers to how many coins you wish to remove from the stake. You can change the amount.

To preserve network stability, the staked coins are held for roughly 1 day starting from the unbond request before being unlocked and returned to the `validator` account.
