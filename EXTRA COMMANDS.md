# Extra Commands
Extra commands to query Axelar network's internal state. For those interested in learning more.

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Prerequisites
- Complete all steps from `README.md`
- Attempted or completed `Excercise 1` and have a basic understanding of the asset transfer workflow

## Commands
This document lists out additional commands that can be run at different points during the `Excercise 1` workflow. The commands are not neccesary to complete the asset transfer, but display additional information about the current network state, and can be useful for debugging or learning more about the network.

### Query Bitcoin Master Address
```
axelard q bitcoin master-addr
```

Returns the bitcoin address associated with the Bitcoin Master Key.


### Query Ethereum Gateway Address
```
axelard q evm master-addr ethereum
```

Returns the ethereum address of the deployed Axelar Gateway contract. The Gateway acts as the Axelar hub on ethereum. It manages and deploys ERC20 token contracts which represents assets from other chains, such as bitcoin.


### Query Ethereum Token Address
```
axelard q evm token-address ethereum [symbol]
```
```
axelard q evm token-address ethereum satoshi
```

Returns the ethereum address of the deployed ERC20 token contract, which represents an asset from another chain.


### Query Bitcoin Minimum Withdraw Balance
```
axelard q bitcoin minWithdraw
```

Returns the minimum amount of bitcoin required for a withdraw transaction, denominated in satoshi.

During the workflow, withdraw refers to the process of depositing the ERC20 wBTC token on ethereum, and getting BTC back on a bitcoin recipient address. The minimum withdraw balance is used by Axelar to pay for bitcoin transaction fees, and is deducted from the total amount returned to the bitcoin recipient address.


### Query the Last Consolidation Transaction
```
axelard q bitcoin rawTx
```

Returns the signed bitcoin consolidation transaction. The transaction can then be submitted to bitcoin network.


### Query the State of the Last Consolidation Transaction
```
axelard q bitcoin consolidationTxState
```

Returns the state of the consolidation transaction (whether its been confirmed on bitcoin) as seen by Axelar network.


### Query the Deposit Address for a Linked Recipient Address
For a bitcoin deposit address and ethereum recipient address:
```
axelard q bitcoin deposit-addr [chain] [recipient address]
```
```
axelard q bitcoin deposit-addr ethereum 0xc1c0c8D2131cC866834C6382096EaDFEf1af2F52
```

For an ethereum deposit address and bitcoin recipient address:
```
axelard q evm deposit-addr ethereum [chain] [recipient address] [symbol]
```
```
axelard q evm deposit-addr ethereum bitcoin tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln satoshi
```

Returns the native chain deposit address for a linked, cross chain recipient adress. Axelar must have previously linked the two addresses.


### Query the State of a Bitcoin Deposit Transaction
```
axelard q bitcoin txState [txID:vout]
```
```
axelard q bitcoin txState 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0
```

Returns the state of the deposit transaction (whether its been confirmed on bitcoin) as seen by Axelar network.