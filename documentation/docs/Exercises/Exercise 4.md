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
- Complete all steps from [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries)
- Golang (Follow the [official docs](https://golang.org/doc/install) to install)
- For Ubuntu/Debian systems: install build-essential with `apt-get install build-essential`

## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.network/)
- Latest docker image: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Extra commands to query Axelar Network state](/extra-commands)

## Joining the Axelar testnet

Follow the instructions in [Setup with Docker](/setup-docker) or [Setup with Binaries](/setup-binaries) to make sure your node is up to date, and you received some test coins to your account.

## Connect to the Cosmoshub testnet

### Setup gaia cli

1. On a new terminal window, clone gaia repository from Github:
```bash
git clone https://github.com/cosmos/gaia.git
```
2. Run the make command to build and install gaiad
```bash
cd gaia
git checkout v5.0.5
make install
```
3. Verify it is properly installed:
```bash
gaiad version
```
:::tip
If you get `-bash: gaiad: command not found`, make sure you do the following:
```bash
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
source .profile
```
:::

4. Initialize the node

[moniker] can be any name you like
```bash
gaiad init [moniker]
```
5. Use any text editor to open `$HOME/.gaia/config/client.toml`, edit `chain-id` and `node` fields
```bash
chain-id = "cosmoshub-testnet"
node = "https://rpc.testnet.cosmos.network:443"
```
Verify you have access to the testnet, you will see the latest block info
```bash
gaiad q block
```
5. Create a key pair

[cosmos-key-name] can be any name you like
```bash
gaiad keys add [cosmos-key-name]
```
6. Request tokens from the faucet
```bash
curl -X POST -d '{"address": "your newly created address"}' https://faucet.testnet.cosmos.network
```
When the tokens are sent, you will see the following response:
```json
{"transfers":[{"coin":"100000000uphoton","status":"ok"}]}
```
Check that tokens have arrived

[cosmoshub address] is the address you created in step 5, associated with the [cosmos-key-name]
```bash
gaiad q bank balances [cosmoshub address]
```
### Instructions to send tokens from Cosmoshub testnet to Axelar Network
1. Send an IBC transfer from Cosmoshub testnet to Axelar Network

You can find `Cosmoshub channel id` under [Testnet Release](../testnet-releases.md)

[axelar address] is the address you generated in Exercise 3

[cosmos-key-name] is the one you generated in step 5 above

```bash
gaiad tx ibc-transfer transfer transfer [Cosmoshub channel id] [axelar address] --packet-timeout-timestamp 0 [amount]uphoton --from [cosmos-key-name] -y -b block
```
Wait ~20 secs for the relayer to relay your transaction.
2. On a new terminal window, enter Axelar node:
```bash
docker exec -it axelar-core sh
```
3. Check that you received the funds

[axelar address] is the address you generated in Exercise 3, and used in step 1 above
```bash
axelard q bank balances [axelar address]
```
You should see balance with denomination starting with `ibc` e.g.:
```bash
balances:
- amount: "100000"
 denom: ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A
```

4. Check the denomination trace
```bash
axelard q ibc-transfer denom-traces
```
You should see the base_denom is `uphoton`

### Send back to Cosmoshub

1. Send IBC token back to Cosmoshub

[cosmoshub address] is the address you generated in section `Setup gaia cli` in step 5, associated with the [cosmos-key-name]

(You can check your cosmoshub address with command `gaiad keys list` in local terminal)

[key-name] is the name you used in Exercise 3

:::tip
Please do not send the whole amount, you will need some uphoton in Exercise 5
:::
```bash
axelard tx ibc-transfer transfer transfer channel-0 [cosmoshub address] [amount]"ibc/287EE075B7AADDEB240AFE74FA2108CDACA50A7CCD013FA4C1FCD142AFA9CA9A" --packet-timeout-timestamp 0 --from [key-name]
```

Wait ~20 secs for the relayer to relay your transaction

2. Go to your local terminal, verify you received uphoton

[cosmoshub address] is the address you used above
```bash
gaiad q bank balances [cosmoshub address]
```
