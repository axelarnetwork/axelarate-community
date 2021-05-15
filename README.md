# axelarate-community
Tools to join the axelar network

This tutorial will take 30-60 minutes of dev time and 2-4 hours of waiting for blockchain sync.

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.


## Prerequisites
- Mac OS or Ubuntu (tested on 18.04)
- Docker (https://docs.docker.com/engine/install/)

## Useful links
- Axelar faucet: http://faucet.testnet.axelar.network/
- Latest docker images:
  + https://hub.docker.com/repository/docker/axelarnet/axelar-core
  + https://hub.docker.com/repository/docker/axelarnet/tofnd

## Useful commands
Axelar node runs in two containers (one with the core consensus engine and another with threshold crypto process). You can stop/remove all your containers using:
```
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```
If you did not add the `docker` user to the `sudo` group, you will have to prepend `sudo` to the previous commands.

## Joining the Axelar testnet

Clone the repository to use the script and configs:

```
git clone https://github.com/axelarnetwork/axelarate-community.git
cd axelarate-community
```

Run the script `join/joinTestnet.sh`.
```
Usage: joinTestnet.sh [flags]

Mandatory flags:

--axelar-core       Version of axelar-core docker image to run (Format: vX.Y.Z)
--tofnd             Version of tofnd docker image to run (Format: vX.Y.Z)

Optional flags:
-r, --root          Local directory to store testnet data in (IMPORTANT: this directory is removed and recreated if --reset-chain is set)

--reset-chain       Delete local data to do a clean connect to the testnet

```
See https://hub.docker.com/repository/docker/axelarnet/axelar-core and https://hub.docker.com/repository/docker/axelarnet/tofnd for the latest available versions of the docker images.

You can get the latest version and save it to variables:
```
TOFND_VERSION=`curl -s https://registry.hub.docker.com/v1/repositories/axelarnet/tofnd/tags | jq -r ".[-1].name"`
CORE_VERSION=`curl -s https://registry.hub.docker.com/v1/repositories/axelarnet/axelar-core/tags | jq -r ".[-1].name"`
echo ${TOFND_VERSION} ${CORE_VERSION}
```

Once you join, at the terminal you should see blocks produced quickly. Wait for your node to catch up with the network before proceeding (When block production slows down to every 10 seconds). This can take a while.

```
9:13PM INF commit is for a block we do not know about; set ProposalBlock=nil commit=EF5F5089BC255CEA54707AF1A67E7056551B0EBF4440D0A3095217BF119346DA commit_round=0 height=33 module=consensus proposal=
9:13PM INF received complete proposal block hash=EF5F5089BC255CEA54707AF1A67E7056551B0EBF4440D0A3095217BF119346DA height=33 module=consensus
9:13PM INF finalizing commit of block hash=EF5F5089BC255CEA54707AF1A67E7056551B0EBF4440D0A3095217BF119346DA height=33 module=consensus num_txs=0 root=006CFAB3CC04E2196D06671ACCF4374C1D282393C302CC394F3124A7594295FF
9:13PM INF minted coins from module account amount=2061stake from=mint module=x/bank
9:13PM INF executed block height=33 module=state num_invalid_txs=0 num_valid_txs=0
9:13PM INF commit synced commit=436F6D6D697449447B5B3135372031383420323030203934203832203734203233
...
```
By default, logs output to stdout and stderr. You could redirect logs to a file for debugging and error reporting:
```
join/joinTestnet.sh --axelar-core ${CORE_VERSION} --tofnd ${TOFND_VERSION} &>> testnet.log
```
On a new terminal window, you could monitor the log file in real time:
```
tail -f testnet.log
```
If you find the log containing too much noise and hard to find useful information, you can filter it as following
```
docker logs -f axelar-core 2>&1 | grep -e threshold -e num_txs -e proxies
```

## Ethereum account on testnet
Axelar signs meta transactions for Ethereum, meaning that any Ethereum account can send transaction executing commands so long as the commands are signed by Axelar's key. In the exercises, all of the Ethereum-related transactions are sent from address `0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A` on Ropsten testnet.

### Generate a key on Axelar and get test tokens
1. On a new terminal window, enter Axelar node:
    ```
    docker exec -it axelar-core sh
    ```
2. By default, the node has an account named validator. Find its address:
    ```
    axelard keys show validator -a
    ```
3. Go to axelar faucet and get some coins on your validator's address (Your node is not yet a validator for the purpose of this ceremony; it's just the name of the account). http://faucet.testnet.axelar.network/

4. Check that you received the funds
    ```
    axelard q bank balances {validator_addr}
    ```
    e.g.,
    ```
    axelard q bank balances axelar1p5nl00z6h5fuzyzfylhf8w7g3qj6lmlyryqmhg
    ```
