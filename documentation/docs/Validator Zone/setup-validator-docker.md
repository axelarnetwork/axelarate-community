---
id: setup-validator-with-docker
sidebar_position: 2
sidebar_label: Setup as Validator with Docker
slug: /validator-zone/setup-docker
---
# Running a validator on the Axelar network
Join and leave the Axelar network as a validator node.

Convert an existing Axelar network node into a validator by staking AXL tokens and attaching external blockchains (such as Bitcoin, EVM chains, Cosmos chains). A validator participates in block creation, transaction signing, and voting.

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites (TODO revise)
- Complete all steps from [Setup with Docker](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/docs/setup-with-docker.md) or [Setup with Binaries](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/docs/setup-with-binaries.md)
- While the network is in development, check in and receive an 'okay' from a testnet moderator or Axelar team member before starting
- Ensure you have the right tag checked out for the axelarate-community repo, check in the testnet-releases.md
- Minimum validator hardware requirements: 16 cores, 16GB RAM, 1.5 TB drive. Recommended 32 cores, 32 GB RAM, 2 TB+ drive




# Set up and register external chain nodes

As an Axelar Network validator, your Axelar node will vote on the status of external blockchains such as Bitcoin, EVM, Cosmos. Specifically:

1. Select which external chains your Axelar node will support.  Set up and configure your own nodes for the chains you selected.
2. Provide RPC endpoints for these nodes to your Axelar validator node and register as a maintainer for these chains on the Axelar network.
## External chains you can support on Axelar

Chain-specific details for the above steps are linked below:

* Bitcoin (coming soon)
* [link] Ethereum and EVM-compatible chains
* [link] Cosmos chains

## Register as a chain maintainer

Example: register your Axlear validator node as a chain maintainer for the Ethereum blockchain:

```bash
axelard tx nexus register-chain-maintainer ethereum --from broadcaster --node "$VALIDATOR_HOST" # eg VALIDATOR_HOST=http://127.0.0.1:26657
```


### Start-up troubleshoot

If the process was missing, check if `tofnd` is running. Install the `nmap` command if you do not have it, and check the tofnd port

```bash
nmap -p 50051 localhost
```

Look for the `STATE` of the port, which should be `open` or `closed`. If the port is `closed`, restart your node and ensure tofnd is running. If the port is `open`, then there is a connection issue between vald and tofnd.

To fix the connectivity issue, find the `tofnd` container address manually and provide it to `vald`.
Find the `tofnd` address.

```bash
docker inspect tofnd
```

Near the bottom of the JSON output, look for `Networks`, then `bridge`, `IPAddress`, and copy the address listed.
Next, ping the IP Address from inside `Axelar Core` to see if it works. Install the `ping` command if it does not exist already.

```bash
docker exec axelar-core ping {your tofnd IP Address}
```

eg)

```bash
docker exec axelar-core ping 172.17.0.2
```

You should see entries starting to appear one by one if the connection succeeded. Stop the ping with `Control + C`.
Save this IP address.

Next, query your validator address with

```bash
docker exec axelar-core axelard keys show validator --bech val -a
```
:::caution
Make sure the validator address that is returned starts with `axelarvaloper`
:::

Now, start `vald`, providing the IP address and validator address:

```bash
docker exec axelar-core axelard vald-start --tofnd-host {your tofnd IP Address} --validator-addr {your validator address} --node {your axelar-core IP address}
```
eg)
```bash
docker exec axelar-core axelard vald-start --tofnd-host 172.17.0.2 --validator-addr axelarvaloper1y4vplrpdaqplje8q4p4j32t3cqqmea9830umwl
```



Your vald should be connected properly. Confirm this by running the following and looking for an `vald-start` entry.
```bash
docker exec axelar-core ps
```


Your node is now a validator! Stay as a validator and keep your node running for at least a day. If you wish to stop being a validator, follow the instructions in the next section.


## Leaving the Network as a Validator

1. Deactivate your broadcaster account.
```bash
axelard tx snapshot deactivate-proxy --from validator -y -b block
```

2. Wait until the next key rotation for the changes to take place. In this release, we're triggering key rotation about once a day. So come back in 24 hours, and continue to the next step. If you still get an error after 24 hours, reach out to a team member.

3. Release your staked coins.
```bash
axelard tx staking unbond {axelarvaloper address} {amount} --from validator -y -b block
```

eg)

```bash
axelard tx staking unbond "$(axelard keys show validator --bech val -a)" "100000000uaxl" --from validator -y -b block
```

`amount` refers to how many coins you wish to remove from the stake. You can change the amount.

To preserve network stability, the staked coins are held for roughly 1 day starting from the unbond request before being unlocked and returned to the `validator` account.
