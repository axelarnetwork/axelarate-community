# Exercise 3
Join and leave the Axelar Network as a validator node.

Convert an existing Axelar Network node into a validator by staking tokens. A validator participates in block creation, transaction signing, and voting.

## Level
Intermediate

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Prerequisites
- Complete all steps from `README.md`
- RPC endpoints for your Bitcoin and Ethereum nodes

## Useful links
- Extra commands to query Axelar Network state: https://github.com/axelarnetwork/axelarate-community/blob/main/EXTRA%20COMMANDS.md

## Joining the Axelar testnet
Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account.

## Set up Bitcoin and Ethereum RPC nodes
As an Axelar Network validator, your Axelar node will vote on the status of Bitcoin and Ethereum transactions. To do so, it needs to be configured with your Bitcoin and Ethereum nodes using the RPC endpoint.


1. Have an Axelar node fully caught up and running by completing the steps in `README.md`. Ensure you have some testnet coins on your validator address.

2. Go to the command line where the Axelar node is syncing and stop it with `Control + C`.

  Stop the container.
  ```
  docker stop $(docker ps -a -q)
  ```

3. Go to your home directory and open `~/.axelar_testnet/shared/config.toml`.

4. Scroll to the bottom of the file, and look for `##### bitcoin bridge options #####` and `##### EVM bridges options #####`.

5. Find the `rpc_addr` line and replace the default RPC URL with the URL of your node, for both Bitcoin and Ethereum. Save the file.

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
  axelard tx snapshot registerProxy broadcaster --from validator -y
  ```

Your node is now a validator! If you wish to stop being a validator, follow the instructions in the next section.


## Leaving the Network as a Validator

1. Deactivate your broadcaster account.
  ```
  axelard tx snapshot deactivateProxy --from validator -y -b block
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
