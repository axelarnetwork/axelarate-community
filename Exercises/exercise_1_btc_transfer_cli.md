# Exercise 1
Transfer BTC to Ethereum (as a wrapped asset) and back via Axelar Network CLI.

## Level
Intermediate 

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.

## Prerequisites
- Complete all steps from `README.md`

## Useful links
- Axelar faucet: http://faucet.testnet.axelar.network/
- Latest docker images: https://hub.docker.com/repository/docker/axelarnet/axelar-core,
  https://hub.docker.com/repository/docker/axelarnet/tofnd

## What you need
- Bitcoin testnet faucet to send some test BTC: https://testnet-faucet.mempool.co/
- Metamask
- Ethereum Ropsten address (generate via Metamask)


## Joining the Axelar testnet

Follow the instructions in `README.md` to make sure your node is up to date and you received some test coins to your validator account.

## Instructions to mint and burn tokens
These instructions are a step by step guide to run commands to move an asset from a source to a destination chain and back. The assets are minted as wrapped ERC-20 assets on the destination chain. The commands are submitted to the Axelar Network that's responsible for (a) generating deposit/withdrawal addresses, (b) routing and finalizing transactions, and (c) minting/burning the corresponding assets.

To perform these tests, you'll need some test Bitcoins on the Bitcoin testnet, and a destination Ethereum address on the Ethereum Ropsten Testnet.

### Mint ERC20 Bitcoin tokens on Ethereum

1. Create a deposit address on Bitcoin (to which you'll deposit coins later)

  ```
  axelard tx bitcoin link ethereum {ethereum Ropsten dst addr} --from validator -y -b block
-> returns deposit address
  ```

  e.g.,

  ```
  axelard tx bitcoin link ethereum 0xc1c0c8D2131cC866834C6382096EaDFEf1af2F52 --from validator -y -b block
  ```

  Look for `chain: Bitcoin, address: {btcaddress}`

2. External: send a TEST BTC on Bitcoin testnet to the deposit address specific above, and wait for 6 confirmations (i.e. the transaction is 6 blocks deep in the Bitcoin chain).
  - ALERT: DO NOT SEND ANY REAL ASSETS
  - https://bitcoinfaucet.uo1.net/
  - You can monitor the status of your deposit using the testnet explorer: https://blockstream.info/testnet/


3. Confirm the Bitcoin outpoint

  ```
  axelard tx bitcoin confirmTxOut "{txID:vout}" "{amount}btc" "{deposit address}" --from validator -y -b block
  ```

  e.g.,

  ```
  axelard tx bitcoin confirmTxOut 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0 0.00088btc tb1qlteveekr7u2qf8faa22gkde37epngsx9d7vgk98ujtzw77c27k7qk2qvup --from validator -y -b block
  ```

  Wait for transaction to be confirmed (~10 Axelar blocks, ~50 secs).
  Eventually, you'll see something like this in the node terminal:

  `threshold of 2/3 has been met for bitcoin_7d097730bbeba835e21dc0d953d4b1c3e42a6bf0da03e70f01a6bb0c1b71183c:1_1 for 4/5`

You can search it using `docker logs -f axelar-core 2>&1 | grep -e threshold`. 

4. Trigger signing of the transfers to Ethereum

  ```
  axelard tx ethereum sign-pending-transfers --from validator -y -b block
  -> returns commandID of signed tx
  -> wait for sign protocol to complete (~10 blocks)
  ```

  Look for commandID and its value in the output: `"key": "commandID",
    "value": "d5e993e407ff399cf2770a1d42bc2baf5308f46632fcbe209318acb09776599f"`

  You can search it using `docker logs -f axelar-core 2>&1 | grep -e command`. 
    
5. Send the previous command to Ethereum
  ```
  axelard q ethereum sendCommand {commandID} {address of account that should send this tx}
  ```
  e.g., for the testnet, we allow you to use our address as the sender = `0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A`
  ```
  axelard q ethereum sendCommand 96c8dba428dbb0ce94ebd49eb342a13e8844630d28f80b8d8708324f0642cb3d 0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A
  ```
  So use the above command, and just replace the `commandID` with your own.

You can now open Metamask, select "Assets" then "Add Token" then "Custom Token" and then paste the token contract address (see `axelarate-community/TESTNET RELEASE.md` and look for  `Ethereum token contract address` field).

### Burn ERC20 wrapped Bitcoin tokens and obtain native Satoshi

To send wrapped Bitcoin back to Bitcoin, run the following commands:

1. Create a deposit address on Ethereum

  ```
  axelard tx ethereum link bitcoin {destination bitcoin addr} satoshi --from validator -y -b block
  -> returns deposit address
  ```

  e.g.,
  ```
  axelard tx ethereum link bitcoin tb1qg2z5jatp22zg7wyhpthhgwvn0un05mdwmqgjln satoshi --from validator -y -b block
  ```

  Look for the Ethereum deposit address as the first output in this line (`0x5CFE...`):

  ```
  "successfully linked {0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E} and {tb1qq8wnre6rzctec9wycrl2dq00m3avravslahc8v}"
  ```
**Side note: Make sure to link a Bitcoin address that is controlled by you, e.g. if you link it to an address controlled by Axelar your withdrawal will be considered a donation and added to the pool of funds**

2. External: send wrapped tokens to deposit address (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send transactions. Wait for 30 Ethereum block confirmations. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Confirm the Ethereum transaction

  ```
  axelard tx ethereum confirm-erc20-deposit {txID} {amount} {deposit addr} --from validator -y -b block
  -> wait for transaction to be confirmed (~10 Axelar blocks)
  ```

  Here, amount should be specific in Satoshi. (For instance, 0.0001BTC = 10000)
  e.g.,

  ```
  axelard tx ethereum confirm-erc20-deposit 0x01b00d7ed8f66d558e749daf377ca30ed45f747bbf64f2fd268a6d1ea84f916a 10000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator -y -b block
  -> wait for transaction to be confirmed (~10 Axelar blocks)
  ```

4. Trigger signing of all pending transfers to Bitcoin

  ```
  axelard tx bitcoin sign-pending-transfers {tx fee} --from validator -b block -y
  -> wait for sign protocol to complete (~10 Axelar blocks)
  ```

 e.g.,

  ```
  axelard tx bitcoin sign-pending-transfers 0.0001btc --from validator -b block -y
  ```
5. Submit the transfer to Bitcoin

  ```
  axelard q bitcoin rawTx
  -> Return raw transaction in hex encoding
  ```
  You can then copy the raw transaction and send it to bitcoin testnet with bitcoin's JSON-RPC API, or a web interface such as https://live.blockcypher.com/btc/pushtx/. Note to select Bitcoin testnet as the chain, if you are using the Blockcypher interface.

6. Confirm the Bitcoin outpoint

In this step, you will try to confirm all outpoints of the transfer transaction. Be sure to wait until the transaction is 6 blocks deep in the Bitcoin network.

  ```
  axelard tx bitcoin confirmTxOut "{txID:vout}" "{amount}btc" "{deposit address}" --from validator -y -b block
  ```
e.g.,
  ```
  axelard tx bitcoin confirmTxOut 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0 0.00088btc tb1qlteveekr7u2qf8faa22gkde37epngsx9d7vgk98ujtzw77c27k7qk2qvup --from validator -y -b block
  ```

Most of the confirmations will fail, and you will see:
```
failed to execute message; message index: 0: outpoint address unknown
```
as a response. This is normal. However, at least one of the confirmations should succeed. Among those is the outpoint that returns the remaining balance back to the Axelar network key.

🛑 **IMPORTANT: Without this step, other users of the testnet will be unable to withdraw their wrapped tokens. Be a good citizen and confirm the outpoints!**
