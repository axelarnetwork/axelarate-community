---
id: useful-commands
sidebar_position: 4
sidebar_label: Useful Commands
slug: /useful-commands
---
# Extra Commands
Extra commands to query Axelar network's internal state. For those interested in learning more.

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)
- Attempted or completed [Excercise 1](/exercises/e1) and have a basic understanding of the asset transfer workflow

## Commands
This document lists out additional commands that can be run at different points during the [Excercise 1](/exercises/e1) workflow. The commands are not neccesary to complete the asset transfer, but display additional information about the current network state, and can be useful for debugging or learning more about the network.

### Query Bitcoin Master Address
```bash
axelard q bitcoin master-address
```

Returns the bitcoin address associated with the Bitcoin Master Key.


### Query Ethereum Gateway Address
```bash
axelard q evm gateway-address ethereum
```

Returns the ethereum address of the deployed Axelar Gateway contract. The Gateway acts as the Axelar hub on ethereum. It manages and deploys ERC20 token contracts which represents assets from other chains, such as bitcoin.


### Query Ethereum Token Address
```bash
axelard q evm token-address ethereum [symbol]
```
eg)

```bash
axelard q evm token-address ethereum satoshi
```

Returns the ethereum address of the deployed ERC20 token contract, which represents an asset from another chain.


### Query Bitcoin Minimum Withdraw Balance
```bash
axelard q bitcoin minWithdraw
```

Returns the minimum amount that can be withdrawn on Bitcoin, denominated in satoshi. Withdraw refers to the process of depositing the ERC20 wBTC token on ethereum, and getting BTC back on a bitcoin recipient address. If a Bitcoin outpoint value is below Bitcoin's dust amount the transaction is not going to be mined, therefore we enforce this minimum.


### Query the Last Consolidation Transaction
```bash
axelard q bitcoin rawTx
```

Returns the signed bitcoin consolidation transaction. It can then be submitted to bitcoin network. This transaction consolidates all current deposits on the axelar network and pays out any outstanding withdrawal requests.


### Query the State of the Last Consolidation Transaction
```bash
axelard q bitcoin consolidationTxState
```

Returns the state of the consolidation transaction (whether its been confirmed on bitcoin) as seen by Axelar network.


### Query the Deposit Address for a Linked Recipient Address
For a bitcoin deposit address and ethereum recipient address:
```bash
axelard q bitcoin deposit-address [chain] [recipient address]
```
eg)

```bash
axelard q bitcoin deposit-address ethereum 0xc1c0c8D2131cC866834C6382096EaDFEf1af2F52
```

For an ethereum deposit address and bitcoin recipient address:
```bash
axelard q evm deposit-address ethereum [chain] [recipient address] [symbol]
```
eg)

```bash
axelard q evm deposit-address ethereum bitcoin tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln satoshi
```

Returns the native chain deposit address for a linked, cross chain recipient adress. Axelar must have previously linked the two addresses.


### Query the State of a Bitcoin Deposit Transaction
```bash
axelard q bitcoin txState [txID:vout]
```
eg)

```bash
axelard q bitcoin txState 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0
```

Returns the state of the deposit transaction (whether its been confirmed on bitcoin) as seen by Axelar network.
