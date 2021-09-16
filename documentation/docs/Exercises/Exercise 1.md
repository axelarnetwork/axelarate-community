---
id: e1
sidebar_position: 1
sidebar_label: Exercise 1
slug: /exercises/e1
---
# Exercise 1
Transfer BTC to Ethereum (as a wrapped asset) and back via Axelar Network CLI.

## Level
Intermediate

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)
- Have a Ethereum wallet setup with [MEW](https://www.myetherwallet.com/) and have an Ethereum address funded with some Ether (You can also choose to use the [Chrome plugin](https://chrome.google.com/webstore/detail/mew-cx/nlbmnnijcnlegkjjpcfjclmcfggfefdm?hl=en))

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.network/)
- Latest docker images:
- https://hub.docker.com/repository/docker/axelarnet/axelar-core,
- https://hub.docker.com/repository/docker/axelarnet/tofnd
- [Extra commands to query Axelar Network state](/extra-commands)

## What you need
- Bitcoin testnet faucet to send some test BTC: https://testnet-faucet.mempool.co/
- Metamask
- Ethereum Ropsten address (generate via Metamask)


## Joining the Axelar testnet

Follow the instructions in [Setup](/setup.md) to make sure your node is up to date and you received some test coins to your validator account.

## Instructions to mint and burn tokens
These instructions are a step by step guide to run commands to move an asset from a source to a destination chain and back. The assets are minted as wrapped ERC-20 assets on the destination chain. The commands are submitted to the Axelar Network that's responsible for (a) generating deposit/withdrawal addresses, (b) routing and finalizing transactions, and (c) minting/burning the corresponding assets.

To perform these tests, you'll need some test Bitcoins on the Bitcoin testnet, and a destination Ethereum address on the Ethereum Ropsten Testnet.

### Mint ERC20 Bitcoin tokens on Ethereum

1. Create a deposit address on Bitcoin (to which you'll deposit coins later)

```bash
axelard tx bitcoin link ethereum {ethereum Ropsten dst addr} --from validator
-> returns bitcoin deposit address
```

e.g.,

```bash
axelard tx bitcoin link ethereum 0xc1c0c8D2131cC866834C6382096EaDFEf1af2F52 --from validator
```

Look for `successfully linked {bitcoin deposit address} and {ethereum Ropsten dst addr}`

2. External: send some TEST BTC on Bitcoin testnet to the bitcoin deposit address specified above, and wait for 6 confirmations (i.e. the transaction is 6 blocks deep in the Bitcoin chain).
- ALERT: DO NOT SEND ANY REAL ASSETS
- You can use a bitcoin faucet such as https://bitcoinfaucet.uo1.net/ to send TEST BTC to the deposit address
- You can monitor the status of your deposit using the testnet explorer: https://blockstream.info/testnet/


3. Confirm the Bitcoin outpoint

```bash
axelard tx bitcoin confirm-tx-out "{txID:vout}" "{amount}btc" "{deposit address}" --from validator
```

e.g.,

```bash
axelard tx bitcoin confirm-tx-out 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0 0.00088btc tb1qlteveekr7u2qf8faa22gkde37epngsx9d7vgk98ujtzw77c27k7qk2qvup --from validator
```

Wait for transaction to be confirmed (~10 Axelar blocks, ~50 secs).
Eventually, you'll see something like this in the node terminal:

```bash
bitcoin outpoint confirmation result is
```

You can search it using `docker logs -f axelar-core 2>&1 | grep -a -e outpoint`.

4. Trigger signing of the transfers to Ethereum. First create the pending transfers, then sign it.

```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2 && axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Look for `successfully started signing batched commands with ID {batched commands ID}` and wait for sign protocol to complete (~10 Axelar blocks).

5. Get the command data that needs to be sent in an Ethereum transaction in order to execute the mint

```bash
axelard q evm batched-commands {batched commands ID from step 4}
```
Look for the command data listed under `execute_data`. Copy and save it to use in the next step.

6. Send the Ethereum transaction wrapping the command data to execute the mint

Open your Metamask wallet, go to Settings -> Advanced, then find Show HEX data and enable that option. This way you can send a data transaction directly with the Metamask wallet. Keep in mind not to transfer any tokens, you just need to input the data from the above `execute_data` and send it to the Gateway smart contract (see [Testnet Release](/testnet-releases)). While doing this please make sure the gas price in Metamask is updated once you paste in the data.

Alternatively you can open your MEW wallet, and navigate to the "Send Transaction" page, with the advanced options open, too. Now, you need to send a transaction to the Gateway smart contract with **0** Ether, and with data field being the command data you retrieved in the previous step. Your screen should look similar to following and you can just send the transaction to execute and mint your tokens.

![](https://user-images.githubusercontent.com/1995809/118490096-2753c480-b750-11eb-9c9d-5eb478194ae4.png)

(Note that the "To Address" is the address of Axelar Gateway smart contract, which you can find under [Testnet Release](/testnet-releases), and the "Add Data" field is the command data you got from the previous step)

You can now open Metamask, select "Assets" then "Add Token" then "Custom Token" and then paste the token contract address (see [Testnet Release](/testnet-releases) and look for  `Ethereum token contract address` field).

### Burn ERC20 wrapped Bitcoin tokens and obtain native Satoshi

To send wrapped Bitcoin back to Bitcoin, run the following commands:

1. Create a deposit address on Ethereum

```bash
axelard tx evm link ethereum bitcoin {destination bitcoin addr} satoshi --from validator
```

e.g.,
```bash
axelard tx evm link ethereum bitcoin tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln satoshi --from validator
```

Look for the Ethereum deposit address as the first output in this line (`0x5CFE...`):

```bash
"successfully linked {0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E} and {tb1qq8wnre6rzctec9wycrl2dq00m3avravslahc8v}"
```
:::note
Make sure to link a Bitcoin address that is controlled by you, e.g. if you link it to an address controlled by Axelar your withdrawal will be considered a donation and added to the pool of funds
:::

2. External: send wrapped tokens to deposit address (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send transactions. Wait for 30 Ethereum block confirmations. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Confirm the Ethereum transaction

```bash
axelard tx evm confirm-erc20-deposit ethereum {txID} {amount} {deposit addr} --from validator
```

Here, amount should be specific in Satoshi. (For instance, 0.0001BTC = 10000)
e.g.,

```bash
axelard tx evm confirm-erc20-deposit ethereum 0x01b00d7ed8f66d558e749daf377ca30ed45f747bbf64f2fd268a6d1ea84f916a 10000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```
Verify that the Ethereum deposit transaction confirmation was successful.

```bash
axelard q evm deposit-state ethereum {txID} {deposit addr}
```

e.g.,

```bash
axelard q evm deposit-state ethereum 0xa959623013b5355de5f023fb3044dae02bf915d57b9440460ca59a98663741a8 0x7c5578F5cC4c9253F1E5495240785DD477843D80
```
You should see `deposit transaction is confirmed`.

:::tip
In this release, we're triggering these commands about once a day. So come back in 24 hours, and check the balance on the Bitcoin testnet address to which you submitted the withdrawal.
:::
