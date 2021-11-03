---
id: setup-with-docker
sidebar_position: 2
sidebar_label: Setup with Docker
slug: /setup-docker
---

# Testnet Node Setup
Tools to join the axelar network using docker images. For binaries checkout [Setup with Binaries](/setup-binaries).

This tutorial will take 30-60 minutes of dev time and 2-4 hours of waiting for blockchain sync. The tutorial includes steps for joining the axelar network using two ways. A docker based setup and a setup using binaries. As per your preference, follow the steps for one of the two options.

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites

- Mac OS or Ubuntu (tested on 18.04)
- [Docker](https://docs.docker.com/engine/install/)
- JQ command line tool (`apt-get install jq` on Ubuntu, `brew install jq` on Mac OS)
- Minimum hardware requirements: 4 cores, 8-16GB RAM, 512 GB drive. Recommended 6-8 cores, 16-32 GB RAM, 1 TB+ drive.


## Useful links
- [Axelar faucet](http://faucet.testnet.axelar.network/)
- Latest docker images:
  + https://hub.docker.com/repository/docker/axelarnet/axelar-core
  + https://hub.docker.com/repository/docker/axelarnet/tofnd
- Node setup [walkthrough video](https://youtu.be/QC7Gx-ydTtw) using Docker
  + Completed on Axelar core version v0.7.6, be careful of potential differences in the workflow

## Useful commands

Axelar nodes run up to three docker containers (`axelar-core` for the core consensus engine, `vald` for broadcasting transactions according to chain events, and `tofnd` for threshold crypto operations).
If you are not running a validator node, only the `axelar-core` container is needed.

You can stop/remove these containers using:
```bash
docker stop axelar-core vald tofnd
```

If you see an error related to insufficient gas at any point during the workflow, add the flags
```bash
--gas=auto --gas-adjustment 1.2
```

## Joining the Axelar testnet

Clone the repository to use the scripts and configs:

```bash
git clone https://github.com/axelarnetwork/axelarate-community.git
cd axelarate-community
```

Checkout the correct tag so the scripts work with the deployment. Find the right tag at [Testnet Releases](/testnet-releases).
```bash
git checkout <release-tag>
```

Determine your public IP address. [This Website can help](https://whatismyipaddress.com/). Change the `external_address` field in the `join/config.toml` file and append the rpc port.
```bash
external_address = "123.123.123.123:26656"
```

You should have port forwarding setup with your router. We recommend forwarding ports 1317, 26656-26658 and 26660.
Run the script `join/join-testnet.sh`
```bash
Usage: join-testnet.sh [flags]

Optional flags:
--axelar-core        Version of axelar-core docker image to run (Format: vX.Y.Z) (Default: scraped from https://axelardocs.vercel.app/testnet-releases)
-r, --root           Local directory to store testnet data in (IMPORTANT: this directory is removed and recreated if --reset-chain is set)
--tendermint-key     Path to the tendermint private key file. Used for recovering a node.
--validator-mnemonic Path to the Axelar validator key. Used for recovering a node.
--reset-chain        Delete local data to do a clean connect to the testnet (If you participated in an older version of the testnet)

```
See [Testnet Releases](/testnet-releases) for the latest available versions of the docker images.

You can get the latest version and save it to variables:
```bash
AXELAR_CORE_VERSION=$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep axelar-core | cut -d \` -f 4)
echo ${AXELAR_CORE_VERSION}
```

Run `join/join-testnet.sh`.  On a fresh install (or after `--reset-chain`) you should see the following output:

```bash
Axelar node running.

Validator address: axelarvaloper1hk3xagjvl4ee8lpdd736h6wcwsudrv0f59t0uk


- name: validator
  type: local
  address: axelar1hk3xagjvl4ee8lpdd736h6wcwsudrv0f5ya2we
  pubkey: axelarpub1addwnpepqf7m2d6rc00gq3dvn8wnxkv8ylx5swrrddclh23wdhtjurjmux0ucs33a0c
  mnemonic: ""
  threshold: 0
  pubkeys: []


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

empower clinic rapid sibling chase measure satoshi search enable accuse drip small warrior visa grab only salute sound fun announce snap chuckle public heavy

Do not forget to also backup the tendermint key (/Users/joaosousa/.axelar_testnet/.core/config/priv_validator_key.json)

To follow execution, run 'docker logs -f axelar-core'
To stop the node, run 'docker stop axelar-core'
```
 Wait for your node to catch up with the network before proceeding.
 Use `docker logs -f axelar-core` to keep an eye on the node's progress (this can take a while).

 You can check the sync status by running:
 ```bash
curl localhost:26657/status | jq '.result.sync_info'
```

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
By default, docker logs output to stdout and stderr. You could redirect logs to a file for debugging and error reporting:
```bash
docker logs -f axelar-core 2&> testnet.log
```
On a new terminal window, you could monitor the log file in real time:
```bash
tail -f testnet.log
```
If you find the log containing too much noise and hard to find useful information, you can filter it as following
```bash
docker logs -f axelar-core 2>&1 | grep -a -e threshold -e num_txs -e proxies
```

## Ethereum account on testnet
Axelar signs meta transactions for Ethereum, meaning that any Ethereum account can send transaction executing commands so long as the commands are signed by Axelar's key. In the exercises, all of the Ethereum-related transactions are sent from address `0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A` on Ropsten testnet.

## Generate a key on Axelar and get test tokens
1. On a new terminal window, enter Axelar node:
```bash
docker exec -it axelar-core sh
```
2. By default, the node has an account named validator. Find its address:
```bash
axelard keys show validator -a
```
3. Go to axelar faucet and get some coins on your validator's address (Your node is not yet a validator for the purpose of this ceremony; it's just the name of the account). http://faucet.testnet.axelar.network/

4. Check that you received the funds
```bash
axelard q bank balances {output_addr_from_step_2}
```
e.g.
```bash
axelard q bank balances axelar1hk3xagjvl4ee8lpdd736h6wcwsudrv0f5ya2we
```
:::tip
Balance will appear only after you are fully synced with the network
:::

## Stop and restart testnet
To leave the Axelar node CLI, type `exit` or Control D.
To stop the node, open a new CLI terminal and run
```bash
docker stop $(docker ps -a -q)
```

To restart the node, run the `join/join-testnet.sh` script again, with the same `--axelar-core` version (and optionally `--root`) parameters as before. Do NOT use the `--reset-chain` flag or your node will have to sync again from the beginning (and if you haven't backed up your keys, they will be lost).

To enter Axelar node CLI again
```bash
docker exec -it axelar-core sh
```
