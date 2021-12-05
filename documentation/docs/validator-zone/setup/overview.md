# Overview
-----------
An Axelar network validator participates in block creation, multi-party cryptography protocols, and voting.

Convert your existing Axelar network node into a validator by staking AXL tokens and attaching external blockchains (such as Bitcoin, EVM chains, Cosmos chains).

!> :fire: Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.


## Prerequisites

- Set up an ordinary (non-validator) Axelar node as per one of:
    * [Setup with Docker](/setup/setup-with-docker.md)
    * [Setup with Binaries](/setup/setup-with-binaries.md)
- Your Axelar node currently has an account named `validator` but so far that's just a name.  You've already funded your `validator` account with some AXL tokens from the [Axelar faucet](http://faucet.testnet.axelar.network/).
- Ensure you have the right tag checked out for the axelarate-community repo, check in the testnet-releases.md
- Minimum validator hardware requirements: 16 cores, 16GB RAM, 1.5 TB drive. Recommended 32 cores, 32 GB RAM, 2 TB+ drive

## Steps to become a validator

1. [Launch companion processes for the first time](/validator-zone/setup/vald-tofnd.md)
2. [Back-up your validator mnemonics and secret keys](/validator-zone/setup/backup.md)
3. [Register broadcaster proxy](/validator-zone/setup/register-proxy.md)
4. [Stake AXL tokens on the Axelar network](/validator-zone/setup/stake-axl-tokens.md)
5. [Health check](/validator-zone/setup/health-check.md)
6. [Set up external chains](/validator-zone/external-chains/overview.md)

## Other setup-related tasks

* [Troubleshoot start-up](/validator-zone/troubleshoot/troubleshoot.md)
* [Recover validator from mnemonic or secret keys](/validator-zone/troubleshoot/recovery.md)
* [Leave as a validator](/validator-zone/troubleshoot/leave.md)
* [Missed too many blocks](/validator-zone/troubleshoot/missed-too-many-blocks.md)
