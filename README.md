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

Once you join, at the terminal you should see blocks produced:

```
2:00PM DBG indexed block txs height=2803 module=txindex num_txs=0
2:00PM INF finalizing commit of block hash=CF38DD7953FC55492D8A2E7B85AFF0C897AD45F456332A1D474D13760628514E height=2804 module=consensus num_txs=0 root=3433AECFC589D7BB139492B8D2DA7119312270C58DFF9CBB15352342FA9178DF
2:00PM INF committed state app_hash=AB9304858D45E9C2E3A922B93684B8B13E4FEA90D1406737A42C085A3A06EBC3 height=2804 module=state num_txs=0
2:00PM DBG indexed block txs height=2804 module=txindex num_txs=0
2:01PM INF finalizing commit of block hash=6098B3E6A4E1E74C69B37DD0C23A2009A08DED8AD8787FDCFE6A4FE84B517457 height=2805 module=consensus num_txs=0 root=AB9304858D45E9C2E3A922B93684B8B13E4FEA90D1406737A42C085A3A06EBC3
2:01PM INF committed state app_hash=D55A2D71A5DC4C14FA3B1813C5C283EC2AEA404F442D95629239F3A4BECFA40A height=2805 module=state num_txs=0
...
```
By default, logs output to stdout and stderr. You could redirect logs to a file for debugging and error reporting:
```
join/joinTestnet.sh --axelar-core CORE_VERSION --tofnd TOFND_VERSION &>> testnet.log
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
    axelarcli keys show validator -a
    ```
3. Go to axelar faucet and get some coins on your validator's address (Your node is not yet a validator for the purpose of this ceremony; it's just the name of the account). http://faucet.testnet.axelar.network/

4. Check that you received the funds
    ```
    axelarcli q account {validator_addr}
    ```

