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

## Joining the Axelar testnet

Follow the instructions in [Setup](/setup.md) to make sure your node is up to date and you received some test coins to your validator account.

## Connect to the Cosmos Hub testnet 
### Setup gaia cli
#### Install by downloading
####Clone gaia
Clone the repository from Github:
```
git clone https://github.com/cosmos/gaia.git
```
####Build and Install
Run the make command to build and install gaiad
```
cd gaia
git checkout v5.0.5
make install
```
verify it was properly installed:
```
gaiad version 
```
initialize
```
gaiad init [moniker]
```
use any text editor to open `$HOME/.gaia/config/client.toml`, edit `chain-id` and `node`
```
chain-id = "cosmoshub-testnet"
node = "https://rpc.testnet.cosmos.network:443"
```
verify you have access to the testnet
```
gaiad q block
```
create a key pair
```
gaiad keys add [key name]
```
request tokens from the faucet
```
curl -X POST -d '{"address": "address"}' https://faucet.testnet.cosmos.network
```
When the tokens are sent, you see the following response:
```
{"transfers":[{"coin":"100000000uphoton","status":"ok"}]}
```
check tokens arrived
```

```
### Instructions to send token from Cosmoshub testnet to Axelar Network
1. ibc transfer
```
gaiad tx ibc-transfer transfer transfer channel-23 [axelar address] 1000000uphoton --from [key name] 
```
2. On Axelar Node, check you received the funds
```
axelard q bank balances $(axelard keys show validator -a)
```

You should see a balance with denomination starts with `ibc` e.g.

```
balances:
- amount: "100000"
  denom: ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A
```
3. Check the denomination trace
```
axelard q ibc-transfer denom-traces
```
### Instructions to send IBC transferred tokens from Axelar Network to Ethereum
1. Create a deposit address on Axelar Network (to which you'll deposit coins later)
```
axelard tx axelarnet link ethereum [receipent address] uphoton --from validator
```
2.  send the IBC token on Axelar Network to the deposit address specific above
```
axelard tx bank send $(axelard keys show validator -a) [linked address]  [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A"  --from validator
```
3. Confirm the deposit transaction
```
axelard tx axelarnet confirm-deposit [txID] [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A" [deposit addr] --from validator
```
4. Create transfers on Ethereum
```
axelard tx evm create-pending-transfers ethereum --from validator
```
5. Trigger signing of the transfer on Ethereum
```
axelard tx evm sign-commands ethereum --from validator
```
6. Get the command data that needs to be sent in an Ethereum transaction in order to execute the mint
```
axelard q evm latest-batched-commands ethereum
```
7. Send the Ethereum transaction wrapping the command data to execute the mint
   
Open your Metamask wallet, go to Settings -> Advanced, then find Show HEX data and enable that option. This way you can send a data transaction directly with the Metamask wallet. Keep in mind not to transfer any tokens, you just need to input the data from the above `commandID` and send it to the Gateway smart contract (see [Testnet Release](/testnet-releases)). While doing this please make sure the gas price in Metamask is updated once you paste in the data.

(Note that the "To Address" is the address of Axelar Gateway smart contract, which you can find under [Testnet Release](/testnet-releases), and the "Add Data" field is the command data you got from the previous step)

You can now open Metamask, select "Assets" then "Add Token" then "Custom Token" and then paste the token contract address (see `axelarate-community/TESTNET RELEASE.md` and look for  `Ethereum token contract address` field).
