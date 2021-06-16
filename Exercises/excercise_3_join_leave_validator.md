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

## Joining the Axelar testnet
Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account.

## Set up Bitcoin and Ethereum RPC nodes
As an Axelar Network validator, your Axelar node will vote on the status of Bitcoin and Ethereum transactions. To do so, it needs to be configured with your Bitcoin and Ethereum nodes using the RPC endpoint.


1. Have an Axelar node fully caught up and running by completing the steps in `README.md`.

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

3. Make your `validator` account a validator by staking some coins.

  ```
  axelard tx staking create-validator --yes \
    --amount "600000axltest" \
    --moniker "testvalidator1" \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1" \
    --pubkey "$(axelard tendermint show-validator)" \
    --from validator \
    -b block
  ```

  Here `amount` refers to the amount of coins to stake, with a minimum of 500,000 axltest. You can change the amount, but leave some coins on the account to fund commands.
  `moniker` refers to the nickname of your validator. You can give it any nickname you like.

4. Search through the output from the previous step and find the address beginning with `axelarvaloper`. Copy this address and save it as it is needed later.

  eg)

  ```
  axelarvaloper1e3wky8ypx2yx5wmatvhdq9m2088j76k7s62n6p 
  ```

5. Register the broadcaster account as a proxy for your validator.

  ```
  axelard tx broadcast registerProxy broadcaster --from validator --yes
  ```

Your node is now a validator! If you wish to stop being a validator, follow the instructions in the next section.


## Leaving the Network as a Validator

1. Deregister your account from the validator pool.
  ```
  axelard tx tss deregister --from validator -y -b block
  ```

2. Wait until the next key rotation for the changes to take place. In this release, we're triggering key rotation about once a day. So come back in 24 hours, and continue to the next step. If you still get an error after 24 hours, reach out to a team member.

3. Release your staked coins
  ```
  axelard tx staking unbond {axelarvaloper address} {amount} --from validator -y -b block
  ```

  eg)

  ```
  axelard tx staking unbond axelarvaloper1e3wky8ypx2yx5wmatvhdq9m2088j76k7s62n6p "600000axltest" --from validator -y -b block
  ```

  The `axelarvaloper address` refers to the address saved from step 5 during the join workflow.
  `amount` refers to how many coins you wish to remove from the stake. You can change the amount.

  To preserve network stability, the staked coins are held for 21 days starting from the unbond request before being unlocked and returned to the `validator` account.
