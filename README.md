# axelarate-community
Tools to join the axelar network

## Prerequisites
- Docker (https://docs.docker.com/engine/install/)

## Joining the Axelar testnet

Run the script `join/joinTestnet.sh`. 
```
Usage: joinTestnet.sh [flags]

Mandatory flags:

-r, --root          Local directory to store testnet data in (IMPORTANT: this directory is removed and recreated if --reset-chain is set)
--axelar-core       Version of axelar-core docker image to run (Format: vX.Y.Z)
--tofnd             Version of tofnd docker image to run (Format: vX.Y.Z)

Optional flags:

--reset-chain       Delete local data to do a clean connect to the testnet

```
