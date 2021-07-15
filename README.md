# axelarate-community
Tools to join the axelar network

This tutorial will take 30-60 minutes of dev time and 2-4 hours of waiting for blockchain sync.

## Disclaimer
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.


## Prerequisites

- Mac OS or Ubuntu (tested on 18.04)
- Docker (https://docs.docker.com/engine/install/)
- Minimum hardware requirements: 4 cores, 8-16GB RAM, 512 GB drive. Recommended 6-8 cores, 16-32 GB RAM, 1 TB+ drive.


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


If you see an error related to insufficient gas at any point during the workflow, add the flags
```
--gas=auto --gas-adjustment 1.2
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

--reset-chain       Delete local data to do a clean connect to the testnet (If you participated in an older version of the testnet)

```
See TESTNET RELEASE.md for the latest available versions of the docker images.

You can get the latest version and save it to variables:
```
TOFND_VERSION=$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/TESTNET%20RELEASE.md | grep tofnd | cut -d \` -f 4)
CORE_VERSION=$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/TESTNET%20RELEASE.md | grep axelar-core | cut -d \` -f 4)
echo ${TOFND_VERSION} ${CORE_VERSION}
```

Once you join, at the terminal you should see blocks produced quickly.

```
2021-05-21T20:22:10Z INF received proposal module=consensus proposal={"Type":32,"block_id":{"hash":"EFC59CDAF641E5C12FC85B352B06F8E1188D57D6CF5E4C629B6D5E51FEB9A675","parts":{"hash":"2B0E54FA353D22606BF526E4341F1698C7495FA448E28E62E40679793B289D6D","total":1}},"height":229885,"pol_round":-1,"round":0,"signature":"Cqepe/A+mxHNySEMRuAqi97Ah8TiuJNQvMpmQaVrcgA11p5kzt+Fein3A8XZ2TDH4fy6Qv8XBxmrI2HT1cEUBg==","timestamp":"2021-05-21T20:22:10.854851854Z"}
2021-05-21T20:22:10Z INF received complete proposal block hash=EFC59CDAF641E5C12FC85B352B06F8E1188D57D6CF5E4C629B6D5E51FEB9A675 height=229885 module=consensus
2021-05-21T20:22:11Z INF finalizing commit of block hash=EFC59CDAF641E5C12FC85B352B06F8E1188D57D6CF5E4C629B6D5E51FEB9A675 height=229885 module=consensus num_txs=0 root=34060CC7B7A742F051AA8C7940C431BD1A761AAD8700FB400067F83431E0D4E9
2021-05-21T20:22:11Z INF minted coins from module account amount=2136stake from=mint module=x/bank
2021-05-21T20:22:11Z INF executed block height=229885 module=state num_invalid_txs=0 num_valid_txs=0
2021-05-21T20:22:11Z INF commit synced commit=436F6D6D697449447B5B31313120323039203235302031323220323035203133382032303520313734203220313132203532203137322032303620313334203532203139302031393720313132203233332031333120313535203131312031353420313234203130392031393420312032372032313420323320313238203230375D3A33383146447D
2021-05-21T20:22:11Z INF committed state app_hash=6FD1FA7ACD8ACDAE027034ACCE8634BEC570E9839B6F9A7C6DC2011BD61780CF height=229885 module=state num_txs
...
```
 Wait for your node to catch up with the network before proceeding. This can take a while. 
 You can check the sync status by running:
 ```shell script
curl localhost:26657/status | jq '.result.sync_info'
```
Note: Install `jq` for json processing, on Ubuntu you can install it by running: `sudo apt-get install jq`

**Output:**
 ```json
{
  "latest_block_hash": "0B64D2A0EDAB6CEF229510E52F137130134D94AAD64EACB553D51D01B0D1A446",
  "latest_app_hash": "FA3730F49F491DCFF38687F2603CF154563AFA9C77331AF75340C554CB555EFC",
  "latest_block_height": "17051",
  "latest_block_time": "2021-06-01T23:41:43.161261874Z",
  "earliest_block_hash": "080E6B9FC64778F3E0671E046575D3460984F5B1F584E1F2D467341061C7627A",
  "earliest_app_hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
  "earliest_block_height": "1",
  "earliest_block_time": "2021-05-31T21:05:12.032466392Z",
  "catching_up": true
}
```
Wait for `catching_up` to become `false`

## Logging to file
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
docker logs -f axelar-core 2>&1 | grep -a -e threshold -e num_txs -e proxies
```

## Ethereum account on testnet
Axelar signs meta transactions for Ethereum, meaning that any Ethereum account can send transaction executing commands so long as the commands are signed by Axelar's key. In the exercises, all of the Ethereum-related transactions are sent from address `0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A` on Ropsten testnet.

## Generate a key on Axelar and get test tokens
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
    axelard q bank balances $(axelard keys show validator -a)
    ```
    e.g.,
    ```
    axelard q bank balances axelar1p5nl00z6h5fuzyzfylhf8w7g3qj6lmlyryqmhg
    ```
**Note:** Balance will appear only after you are fully synced with the network

## Stop and restart testnet
To leave the Axelar node CLI, type `exit`.
To stop the node, open a new CLI terminal and run
    ```
    docker stop $(docker ps -a -q)
    ```
    ```
    docker rm $(docker ps -a -q)
    ```

To restart the node, run the `join/joinTestnet.sh` script again, with the same `--axelar-core`, `--tofnd` (and optionally `--root`) parameters as before. Do NOT use the `--reset-chain` flag or your node will have to sync again from the beginning.

To enter Axelar node CLI again
    ```
    docker exec -it axelar-core sh
    ```
