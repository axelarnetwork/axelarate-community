---
id: e4
sidebar_position: 4
sidebar_label: Exercise 4
slug: /exercises/e4
---
# Exercise 4
Transfer Asset from Cosmos Hub to Ethereum via Axelar Network

## Level
Intermediate

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)
- GO (Follow the [office docs](https://golang.org/doc/install) to install)

## Joining the Axelar testnet

Follow the instructions in [Setup](/setup.md) to make sure your node is up to date, and you received some test coins to your validator account.

## Connect to the Cosmos Hub testnet
### Setup gaia cli

1. On a new terminal window, clone gaia repository from Github:

```
git clone https://github.com/cosmos/gaia.git
```
2. Run the make command to build and install gaiad
```
cd gaia
git checkout v5.0.5
make install
```
verify it is properly installed:
```
gaiad version 
```
4. Initialize the node
```
gaiad init [moniker]
```
5. Use any text editor to open `$HOME/.gaia/config/client.toml`, edit `chain-id` and `node` fields
```
chain-id = "cosmoshub-testnet"
node = "https://rpc.testnet.cosmos.network:443"
```
Verify you have access to the testnet, you will see the latest block info
```
gaiad q block
```
5. Create a key pair
```
gaiad keys add [key name]
```
6. Request tokens from the faucet
```
curl -X POST -d '{"address": "your newly created address"}' https://faucet.testnet.cosmos.network
```
When the tokens are sent, you see the following response:
```
{"transfers":[{"coin":"100000000uphoton","status":"ok"}]}
```
Check tokens are arrived
```
gaiad q bank balances [address]
```
### Instructions to send token from Cosmoshub testnet to Axelar Network
1. Send an IBC transfer from Cosmoshub testnet to Axelar Network 
   
   You can find `Cosmoshub channel id` under [Testnet Release](/../testnet-releases.md)
```
gaiad tx ibc-transfer transfer transfer [Cosmoshub channel id] [axelar address] 1000000uphoton --from [key name] -y -b block
```
2. On a new terminal window, enter Axelar node,
```
docker exec -it axelar-core sh
```   
3. Check you received the funds
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
You should see the base_denom is `uphoton`
### Instructions to send IBC transferred tokens from Axelar Network to Ethereum
1. Create a deposit address on Axelar Network (to which you'll deposit coins later)
```
axelard tx axelarnet link ethereum [receipent address] uphoton --from validator
```
Look for `successfully linked [Axelar Network deposit address] and [Ethereum Ropsten dst addr]`
2.  send the IBC token on Axelar Network to the deposit address specific above
```
axelard tx bank send $(axelard keys show validator -a) [Axelar Network deposit address] [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A"  --from validator
```

3. Confirm the deposit transaction
```
axelard tx axelarnet confirm-deposit [txhash] [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A" [deposit addr] --from validator
```
4. Create transfers on Ethereum
```
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
```
5. Trigger signing of the transfer on Ethereum
```
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
6. Get the command data that needs to be sent in an Ethereum transaction in order to execute the mint
```
axelard q evm latest-batched-commands ethereum
```
Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`
7. Send the Ethereum transaction wrapping the command data to execute the mint
   
Open your Metamask wallet, go to Settings -> Advanced, then find Show HEX data and enable that option. This way you can send a data transaction directly with the Metamask wallet. Keep in mind not to transfer any tokens, you just need to input the data from the above `commandID` and send it to the Gateway smart contract (see [Testnet Release](/testnet-releases)). While doing this please make sure the gas price in Metamask is updated once you paste in the data.

(Note that the "To Address" is the address of Axelar Gateway smart contract, which you can find under [Testnet Release](/testnet-releases), and the "Add Data" field is the command data you got from the previous step)

You can now open Metamask, select "Assets" then "Add Token" then "Custom Token" and then paste the Ethereum Phanton contract address (see `axelarate-community/TESTNET RELEASE.md` and look for  `Ethereum Phanton contract address` field).

###  Burn ERC20 wrapped Photon tokens and send back to Cosmoshub 
1. Create a deposit address on Ethereum

```
axelard tx evm link ethereum axelarnet $(axelard keys show validator -a) uphoton --from validator
```
Look for `successfully linked [Ethereum Ropsten deposit address] and [Axelar Network dst addr]`
2. External: send wrapped tokens to deposit address (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send transactions. Wait for 30 Ethereum block confirmations. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Confirm the Ethereum transaction

```bash
axelard tx evm confirm-erc20-deposit ethereum [txID] [amount] [deposit addr] --from validator
```
Here, amount should be specific in uphoton. (For instance, 1photon = 1000000uphoton)
e.g.,

```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```

Wait for transaction to be confirmed.
You can search it using `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`.
4. Execute pending deposit on Axelar Network
```
axelard tx axelarnet execute-pending-transfers --from validator --gas auto --gas-adjustment 1.2
```
5. Verify you revied the funds
```
axelard q bank balances $(axelard keys show validator -a)
```
You should see the deposited `ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A` token
6. Send IBC token back to Cosmoshub
```
axelard tx ibc-transfer transfer transfer channel-0 [cosmoshub address] [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A"  --from validator
```