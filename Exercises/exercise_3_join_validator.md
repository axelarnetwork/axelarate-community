# Exercise 3
Join and leave the Axelar Network as a validator node.

Convert an existing Axelar Network node into a validator by attaching Bitcoin and Ethereum nodes and staking tokens. A validator participates in block creation, transaction signing, and voting.

## Level
Advanced

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Prerequisites
- Complete all steps from `README.md`

## Useful links
- Extra commands to query Axelar Network state: https://github.com/axelarnetwork/axelarate-community/blob/main/EXTRA%20COMMANDS.md

## Joining the Axelar testnet
Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account.

## Set up Bitcoin and Ethereum nodes
As an Axelar Network validator, your Axelar node will vote on the status of Bitcoin and Ethereum transactions. To do so, you must first set up your Bitcoin and Ethereum testnet nodes, and then provide the RPC endpoints to Axelar.

### Bitcoin testnet node
We suggest running your bitcoin testnet node using the `bitcoind` CLI command from `Bitcoin Core`.

1. Download Bitcoin Core.

  Find the installation guide for your machine from the [Github Repo](https://github.com/bitcoin/bitcoin/tree/master/doc). Follow the instructions to download the binary executable commands, including `bitcoind`. Do not use the `bitcoind` command to start downloading the blockchain until later.

2. Find the directory where the `bitcoind` command executable is located. This is typically in the cloned bitcoin repo, under the `src` folder. `cd` into the directory so you can use the `bitcoind` command.

3. Check that `bitcoind` is installed properly

  ```
  ./bitcoind --help
  ```

4. [Find the default data directory](https://en.bitcoin.it/wiki/Data_directory) of your Bitcoin node. Create a file called `bitcoin.conf` inside this directory.

  eg) For macOS

  ```
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

  Copy the contents of the generated `bitcoin.conf` file and paste it into the file you created in the last step.

  Under `# Options only for testnet [test]` add the following two lines, then save.

  ```
  # Listen for JSON-RPC connections on this port
  rpcport=8332
  ```

6. Start downloading the bitcoin testnet chain. Go back to the directory where the `bitcoind` binary is located to run the following.

  ```
  ./bitcoind -testnet
  ```

  You should see a message `Bitcoin Core starting`. Wait for the Bitcoin testnet chain to download, this could take a few hours.
  If you want to look at the progress, find the `debug.log` file within the default Bitcoin data directory.

  eg) For macOS, you can run
  ```
  tail -10 ~/Library/Application\ Support/Bitcoin/testnet3/debug.log
  ```

  To stop the Bitcoin testnet node from downloading and syncing
  ```
  ./bitcoin-cli -testnet stop
  ```

7. Find the RPC endpoint for Axelar to connect.

  If you used the above settings, your RPC endpoint should be 

  ```
  http://{USERNAME}:{PASSWORD}@host.docker.internal:8332
  ```

  eg)

  ```
  http://jacky:mypassword@host.docker.internal:8332
  ```

  The `username` and `password` fields are the values you provided to the `RPC Auth` setting in step 5. Write down the Bitcoin RPC endpoint as you will need it later.

8. OPTIONAL: Test your Bitcoin node.

  After your Bitcoin node is fully synced, you can send an RPC request to it using cURL. Use the following and replace the RPC endpoint username and password.

  ```
  curl -X POST http://jacky:mypassword@localhost:8332 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"getblockchaininfo","params":[],"id":1}'
  ```


### Ethereum Ropsten testnet node
We suggest running your Ethereum Ropsten testnet node using `geth`. Alternatively, you can use `infura` if it is configured properly.

1. [Install Geth](https://geth.ethereum.org/docs/install-and-build/installing-geth).

2. Start downloading the Ethereum Ropsten testnet chain. This may take many hours.

  ```
  geth --ropsten --syncmode "snap" --http --http.vhosts "*"
  ```

  First, the majority of the blocks will be downloaded. Then your node will synchronize as the last few blocks catch up. This second part may take a long time. 

  To stop the node from downloading, press `Control C`.
  
3. Check the status of your node.

  First find the path to your node's `ipc` which is located in 
  ```
  {Path to Default Ethereum Data Storage}/ropsten/geth.ipc
  ```

  eg) on macOS

  ```
  /Users/jacky/Library/Ethereum/ropsten/geth.ipc
  ```

  Open a new terminal and run the following. Replace the `ipc` path with your own.
  ```
  geth attach ipc:/Users/jacky/Library/Ethereum/ropsten/geth.ipc
  ```

  Check the status of your Ethereum node.
  ```
  eth.syncing
  ```

4. Find the RPC endpoint for Axelar to connect.

  If you used the above settings, your RPC endpoint should be 

  ```
  http://host.docker.internal:8545
  ```

  Write down the RPC endpoint, you will need it later.

5. OPTIONAL: Test your Ethereum node.

  After your Ethereum node is fully synced, you can send an RPC request to it using cURL. 

  ```
  curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
  ```


## Connect Bitcoin and Ethereum RPC nodes

1. Have an Axelar node fully caught up and running by completing the steps in `README.md`. Ensure you have some testnet coins on your validator address.

2. Go to the command line where the Axelar node is syncing and stop it with `Control + C`.

  Stop the container.
  ```
  docker stop $(docker ps -a -q)
  ```

3. Go to your home directory and open `~/.axelar_testnet/shared/config.toml`.

4. Scroll to the bottom of the file, and look for `##### bitcoin bridge options #####` and `##### EVM bridges options #####`.

5. Find the `rpc_addr` line and replace the default RPC URL with the URL of your node, for both Bitcoin and Ethereum. Save the file. This RPC URL was found and written down during the Bitcoin and Ethereum node setup section.

6. Start your Axelar node for the changes to take effect. Run each command in a separate terminal.

  ```
  docker start axelar-core -a
  ```
  ```
  docker start tofnd -a
  ```


## Joining the Network as a Validator

1. Enter Axelar node CLI
  ```
  docker exec -it axelar-core sh
  ```

2. Load funds onto your `broadcaster` account, which you will use later.

  Find the address with

  ```
  axelard keys show broadcaster -a
  ```

  Go to [Axelar faucet](http://faucet.testnet.axelar.network/) and get some coins on your broadcaster address.

  Check that you received the funds

  ```
  axelard q bank balances {broadcaster address}
  ```

  eg)

  ```
  axelard q bank balances axelar1p5nl00z6h5fuzyzfylhf8w7g3qj6lmlyryqmhg
  ```

3. Find the minimum amount of coins you need to stake. 

  To become a full fledged validator that participates in threshold multi-party signatures, your validator needs to stake at least 0.5% or 1/200 of the total staking pool.

  Go into the Axelar discord server and find the `testnet` channel. Open up the `pinned` messages at the top right corner and scroll down to the very first pinned message, which contains many links. Find the link for `Monitoring` as well as the testnet user login credentials and use it to sign in.

  Once you are signed in to the monitoring dashboard, look for an entry called `Bonded Tokens`. This is the total pool of staked tokens in the network, denominated in `axltest`. However, later when you use the CLI, it actually accepts denominations in micro `axltest` where 1 `axltest` = 1,000,000 micro `axltest`. 

  So to find the minimum amount of coins you need to stake in the next step, calculate `{total pool} * 1000000 / 200`.

  eg)
  If the dashboard displays `3k` `Bonded Tokens`, the minimum amount is `3000 * 1000000 / 200 = 15000000`.

  To be safe, stake more than the minimum amount, in case the total staking pool increases in the future. Remember to still leave some coins in your account to fund commands.

4. Make your `validator` account a validator by staking some coins.

  Use the following command, but change the `amount` to be larger than the minimum stake amount calculated in the last step. Remember that this is actually denominated in micro `axltest`. Also change the `moniker` to be a descriptive nickname for your validator.

  ```
  axelard tx staking create-validator --yes \
    --amount "6000000axltest" \
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
  ```
  axelard q staking validator "$(axelard keys show validator --bech val -a)" | grep tokens
  ```

  If you wish to stake more coins after the initial validator creation.
  ```
  axelard tx staking delegate {axelarvaloper address} {amount} --from validator -y
  ```

  eg)

  ```
  axelard tx staking delegate "$(axelard keys show validator --bech val -a)" "6000000axltest" --from validator -y
  ```

5. Register the broadcaster account as a proxy for your validator. Axelar network propagates messages from threshold multi-party computation protocols via the underlying consensus. The messages are signed and delivered via the blockchain.

  ```
  axelard tx broadcast registerProxy broadcaster --from validator -y
  ```

Your node is now a validator! If you wish to stop being a validator, follow the instructions in the next section.


## Leaving the Network as a Validator

1. Deregister your account from the validator pool.
  ```
  axelard tx tss deregister --from validator -y -b block
  ```

2. Wait until the next key rotation for the changes to take place. In this release, we're triggering key rotation about once a day. So come back in 24 hours, and continue to the next step. If you still get an error after 24 hours, reach out to a team member.

3. Release your staked coins.
  ```
  axelard tx staking unbond {axelarvaloper address} {amount} --from validator -y -b block
  ```

  eg)

  ```
  axelard tx staking unbond "$(axelard keys show validator --bech val -a)" "6000000axltest" --from validator -y -b block
  ```

  `amount` refers to how many coins you wish to remove from the stake. You can change the amount.

  To preserve network stability, the staked coins are held for 21 days starting from the unbond request before being unlocked and returned to the `validator` account.
