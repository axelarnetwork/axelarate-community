---
id: e4
sidebar_position: 4
sidebar_label: Exercise 4
slug: /exercises/e4
---
# Exercise 4
Transfer Asset from Cosmos Hub to Axelar Network via Gaia CLI and Axelar Network CLI

## Level
Intermediate

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)
- Golang (Follow the [office docs](https://golang.org/doc/install) to install)

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.network/)
- Latest docker image: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Extra commands to query Axelar Network state](/extra-commands)

## Joining the Axelar testnet

Follow the instructions in [Setup](/setup.md) to make sure your node is up to date, and you received some test coins to your account.

## Connect to the Cosmoshub testnet

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
   Verify it is properly installed:
   ```
   gaiad version 
   ```
4. Initialize the node
   
   [moniker] can be any name you like 
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
   
   [cosmos-key-name] can be any name you like
   ```
   gaiad keys add [cosmos-key-name]
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
   
   [cosmoshub address] is the address you created in step 5, associates with the [cosmos-key-name]
   ```
   gaiad q bank balances [cosmoshub address]
   ```
### Instructions to send token from Cosmoshub testnet to Axelar Network
1. Send an IBC transfer from Cosmoshub testnet to Axelar Network 
   
   You can find `Cosmoshub channel id` under [Testnet Release](/testnet-releases.md)
   
   [axelar address] is the address you generated in Exercise 3
   
   [cosmos-key-name] is the one you generated in setup 5 above.

   ```
   gaiad tx ibc-transfer transfer transfer [Cosmoshub channel id] [axelar address] [amount]uphoton --from [cosmos-key-name] -y -b block
   ```
   Wait ~10 secs for the relayer to relayer your transaction
2. On a new terminal window, enter Axelar node,
   ```
   docker exec -it axelar-core sh
   ```   
3. Check you received the funds

   [axelar address] is the address you generated in Exercise 3, and used in step 1 above
   ```
   axelard q bank balances [axelar address]
   ```
   You should see a balance with denomination starts with `ibc` e.g.
   ```
   balances:
   - amount: "100000"
     denom: ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A
   ```
   
4. Check the denomination trace
   ```
   axelard q ibc-transfer denom-traces
   ```
   You should see the base_denom is `uphoton`

### Send back to Cosmoshub 

1. Send IBC token back to Cosmoshub
 
   [cosmoshub address] is the address you generated in section `Setup gaia cli` step 5, associates with the [cosmos-key-name]
   
   (You can check your cosmoshub address use command `gaiad keys list` in local terminal)
   
   [key-name] is the name you used in Exercise 3
   ```
   axelard tx ibc-transfer transfer transfer channel-0 [cosmoshub address] [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A"  --from [key-name]
   ```

   Wait ~10 secs for the relayer to relayer your transaction
   
   :::tip
   Please do not send the whole amount, you will need some uphoton in Exercise 5
   :::
2. Go to your local terminal, verify you received uphoton
   
   [cosmoshub address] is the address you used above
   ```
   gaiad q bank balances [cosmoshub address]
   ```