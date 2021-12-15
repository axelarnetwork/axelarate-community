---
id: join-as-validator-binaries
sidebar_position: 3
sidebar_label: Joining as Validator using Binaries
slug: /join-as-validator-binaries
---
# Running a Validator on the Axelar Network (Binaries)
Join and leave the Axelar Network as a validator node.

Convert an existing Axelar Network node into a validator by attaching Bitcoin and Ethereum nodes and staking tokens. A validator participates in block creation, transaction signing, and voting.

The exercise can be completed using a docker based setup as well as using a binary setup. It is important that you remain consistent. i.e if you setup node using binary, complete the exercise following the binary instructions and if you setup the node using docker, complete this exercise following instructions for docker.

## Level
Advanced

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup with Binaries](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/docs/setup-with-binaries.md)
- While the network is in development, check in and receive an 'okay' from a testnet moderator or Axelar team member before starting
- Ensure you have the right tag checked out for the axelarate-community repo, check in the testnet-releases.md
- Minimum validator hardware requirements: 16 cores, 16GB RAM, 1.5 TB drive. Recommended 32 cores, 32 GB RAM, 2 TB+ drive


## Useful links
- [Extra commands to query Axelar Network state](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/docs/extra-commands.md)

## Joining the Axelar testnet
Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account.

## Set up Bitcoin and Ethereum nodes
As an Axelar Network validator, your Axelar node will vote on the status of Bitcoin and Ethereum transactions. To do so, you must first set up and configure your Bitcoin and Ethereum testnet nodes, and then provide the RPC endpoints to Axelar.

If you do not already have a Bitcoin testnet node and Ethereum Ropsten testnet node running, you can follow the [instructions](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/eth-btc-node-setup.md) to set up and configure them, then skip to the next section `Connect Bitcoin and Ethereum nodes to Axelar`. You can also set up an alternative configuration of your choice.

Bitcoin and Ethereum node configuration will vary for different systems. Detailed configuration instructions for a local machine running `macOS` `Bitcoin Core` and `Geth` can be found [here](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/eth-btc-node-setup.md) and used as a reference.

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

Use `localhost` for IP since the node is running on your local machine
eg)

```bash
http://jacky:mypassword@localhost:18332
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

Use `localhost`as the `IPADDRESS` since your node is running on your local machine.
eg)

```bash
http://localhost:8332
```

4. OPTIONAL: Test your Ethereum node.

To test your setup, you can send an RPC request to your Ethereum node using cURL. Use the following and replace the RPC endpoint.

```bash
curl -X POST http://localhost:8545 \
-H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```


## Connect Bitcoin and Ethereum nodes to Axelar


1. Have an Axelar node fully caught up and running by completing the steps in `README.md`. Ensure you have some testnet coins on your validator address. Make sure you have the environment variables `CHAIN_ID` and `AXELARD_CHAIN_ID` set to `axelar-testnet-toronto`.

```bash
export CHAIN_ID=axelar-testnet-toronto
export AXELARD_CHAIN_ID=axelar-testnet-toronto
```

2. Stop the Axelar node. Open a new terminal and run

```bash
killall -9 axelard
```

3. Go to your home directory and open `~/axelarate-community/join/config.toml`.

4. Scroll to the bottom of the file, and look for `##### bitcoin bridge options #####` and `##### EVM bridges options #####`.

5. Find the `rpc_addr` line and replace the default RPC URL with the URL of your node, for both Bitcoin and Ethereum. Save the file. This RPC URL was found and written down during the Bitcoin and Ethereum node setup section.

6. Start your Axelar node for the changes to take effect. Run the `./join/join-testnet-with-binaries.sh` script again using the same parameters as before. Do NOT use the `--reset-chain` flag or your node will have to sync again from the beginning.

## Joining the Network as a Validator

Here we assume you have a node running using the `./join/join-testnet-with-binaries.sh`script. Use the `--home ~/.axelar_testnet/.core` for every command accessing validator process and `--home ~/.axelar_testnet/.vald` for broadcaster process. If you set a different root directory by using the `--root` flag with the init script then change home to `--home $ROOT_DIRECTORY/.core` and ``--home $ROOT_DIRECTORY/.vald` where `ROOT_DIRECTORY` is whatever you set. The rest of the instructions assume you are using the default `ROOT_DIRECTORY` which is `$HOME/.axelar_testnet/`

1. For ease of use, create an alias to the correct axelard binary.
```bash
alias axelard=$HOME/.axelar_testnet/bin/axelard
```

2. Load funds onto your `validator` account, which you will use later.

Find the address with

```bash
axelard keys show validator -a --home ~/.axelar_testnet/.core
```

Go to [Axelar faucet](http://faucet.testnet.axelar.dev/) and get some coins on your validator address.

Check that you received the funds

```bash
axelard q bank balances {validator address} --home ~/.axelar_testnet/.core
```

eg)

```bash
axelard q bank balances axelar1p5nl00z6h5fuzyzfylhf8w7g3qj6lmlyryqmhg --home ~/.axelar_testnet/.core
```

3. Bring up vald and tofnd and fund broadcaster account.
Run the `./join/launch-validator-with-binaries.sh` script to bring up vald and tofnd processes. The output should be something like this.

```bash
Tofnd & Vald running.

Proxy address: axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs

To become a validator get some uaxl tokens from the faucet and stake them


- name: broadcaster
  type: local
  address: axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs
  pubkey: axelarpub1addwnpepqg648uzk668g0e93y9sekaufgdp96fksjugk6e6c3eddypzc8qm525yhx2m
  mnemonic: ""
  threshold: 0
  pubkeys: []


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

admit come proud swear view stomach industry elephant extend bracket reveal dinner july absorb beef stick say pact sick
Do not forget to also backup the tofnd mnemonic (/Users/talalashraf/.tofnd/export)

To follow tofnd execution, run 'tail -f /Users/talalashraf/.axelar_testnet/logs/tofnd.logs'
To follow vald execution, run 'tail -f /Users/talalashraf/.axelar_testnet/logs/vald.logs'
To stop tofnd, run 'killall -9 tofnd'
To stop vald, run 'killall -9 vald'
```
Find the address with

```bash
axelard keys show broadcaster -a --home ~/.axelar_testnet/.vald
```

Then go to [Axelar faucet](http://faucet.testnet.axelar.dev/) and get some coins on your `broadcaster` address.

Check that you received the funds:

```bash
axelard q bank balances {broadcaster address} --home ~/.axelar_testnet/.vald
```
eg)

```bash
axelard q bank balances axelar1xg93jnefgz3gsnuyqrmq2q288z8st3cf43jecs --home ~/.axelar_testnet/.vald
```

4. Make your `validator` account a validator by staking some coins.

Use the following command, but change the `amount` to whatever balance you have. Remember that this is actually denominated in `uaxl`. Also change the `moniker` to be a descriptive nickname for your validator.

```bash
axelard tx staking create-validator --yes \
--amount "1000000uaxl" \
--moniker "<some-unique-nickname>" \
--commission-rate="0.10" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--pubkey "$(axelard tendermint show-validator  --home ~/.axelar_testnet/.core)" \
--home ~/.axelar_testnet/.core \
--chain-id axelar-testnet-toronto \
--from validator \
-b block
```

To check how many coins your validator has currently staked.
```bash
# Get validator address
axelard keys show validator --bech val -a --home ~/.axelar_testnet/.core
axelard q staking validator <address-in-last-command> --home ~/.axelar_testnet/.core | grep tokens
```

If you wish to stake more coins after the initial validator creation.
```bash
axelard tx staking delegate {axelarvaloper address} {amount} --chain-id axelar-testnet-toronto --from validator -y --home ~/.axelar_testnet/.core
```

eg)

```bash
axelard tx staking delegate "$(axelard keys show validator --bech val -a --home ~/.axelar_testnet/.core)" "100000000uaxl" --chain-id axelar-testnet-toronto --from validator -y --home ~/.axelar_testnet/.core
```

5. Register the broadcaster account as a proxy for your validator. Axelar network propagates messages from threshold multi-party computation protocols via the underlying consensus. The messages are signed and delivered via the blockchain.

```bash
axelard tx snapshot register-proxy "$(cat ~/.axelar_testnet/broadcaster.bech)" --from validator -y --home ~/.axelar_testnet/.core
```

6. Check that your node's `vald` and `tofnd` are connected properly. As a validator, your `axelar-core` will talk with your `tofnd` through `vald`. This is important when events such as key rotation happens on the network.

First, check that the vald process is running

```bash
ps aux | grep vald-start
```

Now run this command.
```bash
axelard tofnd-ping --tofnd-host localhost --home ~/.axelar_testnet/.vald
```

If you see a response like `PONG!` , then your `vald` process has successfully started and is connected with `tofnd`.


7. Find the minimum amount of coins you need to stake.

To become a full-fledged validator that participates in threshold multi-party signatures, your validator needs to stake at least 2% or 1/50 of the total staking pool.

Go into the Axelar discord server and find the `testnet` channel. Open up the `pinned` messages at the top right corner and scroll down to the very first pinned message, which contains many links. Find the link for `Monitoring` as well as the testnet user login credentials and use it to sign in.

Once you are signed in to the monitoring dashboard, look for an entry called `Bonded Tokens`. This is the total pool of staked tokens in the network, denominated in `axl`. However, later when you use the CLI, it actually accepts denominations in micro `axl` (`uaxl`) where 1 `axl` = 1,000,000 `uaxl`.

So to find the minimum amount of coins you need to stake in the next step, calculate `{total pool} * 1000000 / 50`.

eg)
If the dashboard displays `3k` `Bonded Tokens`, the minimum amount is `3000 * 1000000 / 50 = 60000000`.

:warning: **Important:** Key shares for signing transactions on other chains are distributed proportionally to the validators' stakes on Axelar. In order to keep the number of key shares low for now, please delegate a similar amount of stake as existing validators have, i.e. `100000000uaxl`.

8. Ping the Axelar team in the testnet channel to ask for more tokens. The Faucet will not be able to give you the required amount of tokens so the team will manually send them to your address. The team will want to verify that your validator is setup correctly and will send additional funds to your wallet. Once you have confirmation from the team that you have additional funds to stake, check that they are in your wallet and stake them.

```bash
axelard tx staking delegate {axelarvaloper address} {amount} --from validator -y --home ~/.axelar_testnet/.core
```

eg)

```bash
axelard tx staking delegate "$(axelard keys show validator --bech val -a)" "100000000uaxl" --from validator -y --home ~/.axelar_testnet/.core
```

### **Important: Post-Setup Checklist**

Check that:

1. All three processes are running (`axelar-core`, `vald`, and `tofnd`).
2. You can ping (see `tofnd-ping` above) `tofnd` from `vald` container.
3. Your external nodes (Bitcoin, Ethereum, etc) are running and correctly expose the endpoints.
4. You backed-up your mnemonics following [this manual](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/validator-backup.md)
5. After the team gives you enough stake and confirms that rotations are complete, you can explore various shares you hold following [this](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/validator-extra-commands.md).
6. A reminder that you need at least `1 axl` to participate in consensus, and at least `2\%` of total bonded stake to participate in threshold MPC.
7. Check that you have some `uaxl` on your `broadcaster` address. Use [Axelar faucet](http://faucet.testnet.axelar.dev/) to get some coins if it is not funded.
8. After that, you're an active validator and should guard your node and all keys with care.


## Leaving the Network as a Validator

### Using Binary
1. Deactivate your broadcaster account.
```bash
axelard tx snapshot deactivate-proxy --from validator -y -b block --home ~/.axelar_testnet/.core
```

2. Wait until the next key rotation for the changes to take place. In this release, we're triggering key rotation about once a day. So come back in 24 hours, and continue to the next step. If you still get an error after 24 hours, reach out to a team member.

3. Release your staked coins.
```bash
axelard tx staking unbond {axelarvaloper address} {amount} --from validator -y -b block --home ~/.axelar_testnet/.core
```

eg)

```bash
axelard tx staking unbond "$(axelard keys show validator --bech val -a)" "100000000uaxl" --from validator -y -b block
```

`amount` refers to how many coins you wish to remove from the stake. You can change the amount.

To preserve network stability, the staked coins are held for roughly 1 day starting from the unbond request before being unlocked and returned to the `validator` account.
