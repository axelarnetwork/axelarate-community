# axelarate-community
Tools to join the axelar network


## Disclaimer 
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template. 


## Prerequisites
- Docker (https://docs.docker.com/engine/install/)

## Useful links
- Axelar faucet: http://faucet.testnet.axelar.network/
- Latest docker images: https://hub.docker.com/repository/docker/axelarnet/axelar-core, 
  https://hub.docker.com/repository/docker/axelarnet/tofnd 

## Useful commands
Axelar node runs in two containers (one with the core consensus engine and another with threshold crypto process). You can stop/remove all your containers using: 
```
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

## Joining the Axelar testnet

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
I[2021-03-17|02:56:53.933] Executed block                               module=state height=2737 validTxs=0 invalidTxs=0 
I[2021-03-17|02:56:53.945] Committed state                              module=state height=2737 txs=0 appHash=DCFEB4C1574D6ADC1CC61CEBA8B119CBC0BBB87EB16B94507F19A10305D453CD
I[2021-03-17|02:56:59.682] Executed block                               module=state height=2738 validTxs=0 invalidTxs=0
I[2021-03-17|02:56:59.691] Committed state                              module=state height=2738 txs=0 appHash=5867EC297F83BB40F419EEBF7EB1FD4405
...
```

### Generate a key on Axelar and get test tokens
1. Enter Axelar node: 

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

