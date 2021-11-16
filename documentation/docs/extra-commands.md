---
id: extra-commands
sidebar_position: 6
sidebar_label: Extra Commands
slug: /extra-commands
---
# Extra Commands
Extra commands to query Axelar network's internal state. For those interested in learning more.

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries)
- Attempted or completed Excercise 1 (coming soon) and have a basic understanding of the asset transfer workflow

## Commands
This document lists out additional commands that can be run at different points during the Excercise 1 (coming soon) workflow. The commands are not neccesary to complete the asset transfer, but display additional information about the current network state, and can be useful for debugging or learning more about the network.

Note: If you setup your node using the binaries, you should always include `--home $ROOT_DIRECTORY/.core` param in your `axelard` commands, where `ROOT_DIRECTORY` is whatever you chose when setting up the node. The default value for this is `$HOME/.axelar_testnet/.core`. e.g
```bash
axelard q bank balances <addr>
```

becomes
```bash
axelard q bank balances <addr> --home $HOME/.axelar_testnet/.core
```


### Query Ethereum Gateway Address
```bash
axelard q evm gateway-address ethereum
```

Returns the ethereum address of the deployed Axelar Gateway contract. The Gateway acts as the Axelar hub on ethereum. It manages and deploys ERC20 token contracts which represents assets from other chains, such as bitcoin.


### Query Ethereum Token Address
```bash
axelard q evm token-address ethereum [asset denomination]
```
eg)

```bash
axelard q evm token-address ethereum satoshi
```

Returns the ethereum address of the deployed ERC20 token contract, which represents an asset from another chain.


### Query Bitcoin Minimum Withdraw Balance
```bash
axelard q bitcoin min-output-amount
```

Returns the minimum amount of bitcoin that can be withdrawn, denominated in satoshi. Withdraw refers to the process of depositing the ERC20 axelarBTC token on ethereum, and getting BTC back on a bitcoin recipient address. If a Bitcoin outpoint value is below Bitcoin's dust amount the transaction is not going to be mined, therefore we enforce this minimum.


### Query the Last Consolidation Transaction
```bash
axelard q bitcoin latest-tx [key role]
```
eg)

```bash
axelard q bitcoin latest-tx master
```

Returns the latest consolidation transaction for the given key role. This transaction consolidates all deposits on the axelar network and pays out any outstanding withdrawal requests.


### Query the Deposit Address for a Linked Recipient Address
For a bitcoin deposit address and ethereum recipient address:
```bash
axelard q bitcoin deposit-address [recipient chain] [recipient address]
```
eg)

```bash
axelard q bitcoin deposit-address ethereum 0xc1c0c8D2131cC866834C6382096EaDFEf1af2F52
```

For an ethereum deposit address and bitcoin recipient address:
```bash
axelard q evm deposit-address ethereum [recipient chain] [recipient address] [asset denomination]
```
eg)

```bash
axelard q evm deposit-address ethereum bitcoin tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln satoshi
```

Returns the native chain deposit address for a linked, cross chain recipient adress. Axelar must have previously linked the two addresses.


### Query the State of a Bitcoin Deposit Transaction
```bash
axelard q bitcoin deposit-status [txID:vout]
```
eg)

```bash
axelard q bitcoin deposit-status 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0
```

Returns the state of the deposit transaction (whether its been confirmed on bitcoin) as seen by Axelar network.
