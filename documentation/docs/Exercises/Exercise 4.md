---
id: e4
sidebar_position: 4
sidebar_label: Exercise 4
slug: /exercises/e4
---
# Exercise 4
Transfer UST from Terra to EVM compatible chains via Terra CLI and Axelar Network CLI

## Level
Intermediate

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries)
- Golang (Follow the [official docs](https://golang.org/doc/install) to install)
- For Ubuntu/Debian systems: install build-essential with `apt-get install build-essential`

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.dev/)
- Latest docker image: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Extra commands to query Axelar Network state](/extra-commands)

## Joining the Axelar testnet

Follow the instructions in [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries) to make sure your node is up to date, and you received some test coins to your account.

## Connect to the Terra testnet

1. On a new terminal window, clone terra repository from Github:
```bash
git clone https://github.com/terra-money/core/
cd core
git checkout v0.5.11
```
2. Build from source
```bash
make install
```
3. Verify it is properly installed:
```bash
terrad version --long
```
:::tip
If you get `-bash: terrad: command not found`, make sure you do the following:
```bash
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
source .profile
```
:::

4. Initialize the node

[moniker] can be any name you like
```bash
terrad init [moniker]
```
5. Use any text editor to open `$HOME/.terra/config/client.toml`, edit `chain-id` and `node` fields
```bash
chain-id = "bombay-12"
node = "tcp://adc1043f1d76249009c417dcad0bc807-1055950820.us-east-2.elb.amazonaws.com:26657"
```
Verify you have access to the testnet, you will see the latest block info
```bash
terrad status
```
6. Create a key pair

[terra-key-name] can be any name you like
```bash
terrad keys add [terra-key-name]
```
7. Request tokens from the faucet
Go to terra testnet faucet and get some UST for your newly created address https://faucet.terra.money/

Verify that tokens have arrived

[address] is the address you created in step 6, associated with the [terra-key-name]
```bash
terrad q bank balances [address]
```

## Instructions to send UST from Terra testnet to EVM compatible chains
The flow works for any EVM compatible chains that Axelar supports. We use Ethereum Ropsten as example.

:::note
### Docker vs. binaries

For the following `axelard` terminal commands:

* **Docker:** Commands should be entered into a shell attached to the `axelar-core` container via
  ```
  docker exec -it axelar-core sh
  ```
* **Binaries:** Commands must specify the path to the `axelard` binary and the `--home` flag.  Example: Instead of `axelard keys show validator -a` use
  ```
  ~/.axelar_testnet/bin/axelard keys show validator -a --home ~/.axelar_testnet/.core
  ```
:::

1. Create a deposit address on Axelar Network (to which you'll deposit coins later)
using a sufficiently funded [axelar-key-name] address.
[receipent address] is an address you control on the recipient EVM chain.
This is where your UST will ultimately be sent.
```bash
axelard tx axelarnet link [evm chain] [receipent address] uusd --from [axelar-key-name]
```
e.g.,
```bash
axelard tx axelarnet link ethereum 0x4c14944e080FbE711D29D5B261F14fE4E754f939 uusd --from validator
```
Look for `successfully linked [Axelar Network deposit address] and [receipent address]`

:::tip
If you get `Error: rpc error: ... not found: key not found`, verify that
[axelar-key-name] address is correct and sufficiently funded:
```bash
axelard q bank balances [axelar-key-name]
```
:::

2. Send an IBC transfer from Terra testnet to Axelar Network
Switch back to terminal with terrad installed

```bash
terrad tx ibc-transfer transfer transfer [Terra channel id] [Axelar Network deposit address] --packet-timeout-timestamp 0 --packet-timeout-height "0-20000" [amount]uusd --gas-prices 0.15uusd --from [terra-key-name] -y -b block
```
You can find `Terra channel id` under [Testnet Release](/testnet-releases)

[terra-key-name] is the one you generated in step 6 above

Wait ~30-60 secs for the relayer to relay your transaction.

:::tip
If your transfer is taking a long time, you can check if it
timed out and was refunded on an [explorer](https://finder.terra.money/)
by entering your terra address and retry the transfer.
:::

3. Switch to axelard terminal, check that you received the funds
```bash
axelard q bank balances [Axelar Network deposit address]
```
You should see balance with denomination starting with `ibc` e.g.:
```bash
balances:
- amount: "1000000"
 denom: ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F
```

4. Confirm the deposit transaction

[txhash] is from the step 2

[amount] and [token] are the same as in step 2 above

[Axelar Network deposit address] is the address above you deposited to

```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]"[token]" [Axelar Network deposit address] --from [axelar-key-name]
```
e.g.,
```bash
axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752  1000000"ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F" axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
```

5. Create transfers on evm compatibale chain and Sign
```bash
axelard tx evm create-pending-transfers [chain] --from [key-name] --gas auto --gas-adjustment 1.2
axelard tx evm sign-commands [chain] --from [key-name] --gas auto --gas-adjustment 1.2
```
e.g.
```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Look for `successfully started signing batched commands with ID {batched commands ID}`.

6. Get the command data that needs to be sent in an transaction in order to execute the mint
```bash
axelard q evm batched-commands [chain] {batched commands ID from step 5}
```
e.g.
```bash
axelard q evm batched-commands ethereum 1d097247c283cfaca76ad1de4f3a2e5d4d075d99664e5d87aa187a331e8546e7
```
Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`

7. Send the transaction wrapping the command data to execute the mint

- Open your Metamask wallet, go to Settings -> Advanced, then find Show HEX data and enable that option. This way you can send a data transaction directly with the Metamask wallet.

- Go to metamask, send a transaction to `Gateway smart contract address`, paste hex from `execute_data` above into Hex Data field

  Keep in mind not to transfer any tokens! To reduce the chance of out of gas errors when executing the contract, we recommend
  setting a higher gas limit, such as 1000000, by selecting Edit on the confirmation screen.

  (Note that the "To Address" is the address of Axelar Gateway smart contract, which you can find under [Testnet Release](/testnet-releases))

You can now open Metamask, select "Assets", then "Import tokens", then "Custom Token",
and paste the axelarUST token contract address (see [Testnet Release](/testnet-releases) and look for the corresponding token address).

:::tip
If you don't see the tokens in MetaMask yet,
then verify if the transaction has succeeded on the [Ropsten explorer](https://ropsten.etherscan.io) for your [recipient address].
Also, check that the contract executed without any errors (look under the `To:` field on the explorer for that transaction).
:::

## Send back to Terra
1. Create a deposit address on evm compatible chain
```bash
axelard tx evm link [chain] terra [terra address] uusd --from [key-name]
```
e.g.
```bash
axelard tx evm link ethereum terra terra1syhner2ldmm7vqzkskcflaxl6wy9vn7m873vqu uusd --from validator
```
Look for `successfully linked [Ethereum Ropsten deposit address] and [Terra address]`

2. External: send wrapped tokens to [Ethereum Ropsten deposit address] (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send the transaction. Wait for 30 block confirmations. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Confirm the transaction
```bash
axelard tx evm confirm-erc20-deposit [chain] [txID] [amount] [deposit address] --from [key-name]
```
Here, amount should be specific in uusd, 1UST = 1000000uusd
e.g.,
```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```

Wait for transaction to be confirmed.
You can search it using:
- If using docker, `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`
- If using the binary, `tail -f $HOME/.axelar_testnet/logs/axelard.log | grep -a -e "deposit confirmation"`

4. Route pending IBC transfer on Axelar Network
```bash
axelard tx axelarnet route-ibc-transfers --from [key-name] --gas auto --gas-adjustment 1.2
```
Wait ~30-60 secs for the relayer to relay your transaction.

5. Switch back to terminal with terrad installed, verify you received ust

[terra-address] is the address you used above
```bash
terrad q bank balances [terra-address]
```
