---
id: validator-zone
sidebar_position: 1
sidebar_label: Overview
slug: /validator-zone/setup
---

# Overview

An Axelar network validator participates in block creation, multi-party cryptography protocols, and voting.

Convert your existing Axelar network node into a validator by staking AXL tokens and attaching external blockchains (such as Bitcoin, EVM chains, Cosmos chains).

:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## [TODO revise] Prerequisites

- Set up an ordinary (non-validator) Axelar node as per one of:
    * [Setup with Docker](../../setup-docker)
    * [Setup with Binaries](../../setup-binaries)
- Your Axelar node currently has an account named `validator` but so far that's just a name.  You've already funded your `validator` account with some AXL tokens from the [Axelar faucet](http://faucet.testnet.axelar.network/).
- While the network is in development, check in and receive an 'okay' from a testnet moderator or Axelar team member before starting
- Ensure you have the right tag checked out for the axelarate-community repo, check in the testnet-releases.md
- Minimum validator hardware requirements: 16 cores, 16GB RAM, 1.5 TB drive. Recommended 32 cores, 32 GB RAM, 2 TB+ drive

## Steps to become a validator

1. [Stake AXL tokens on the Axelar network](/validator-zone/setup/stake)
2. [Register broadcaster proxy](/validator-zone/setup/register-proxy)
3. [Health check](/validator-zone/setup/health-check)
4. [Back-up your validator mnemonics and secret keys](/validator-zone/setup/backup)
5. [Set up external chains](/validator-zone/external-chains)

## Other setup-related tasks

* [Troubleshoot start-up](/validator-zone/troubleshoot)
* [Recover validator from mnemonic or secret keys](/validator-zone/troubleshoot/recovery)
* [Leave as a validator](/validator-zone/troubleshoot/leave)
# TODO

* This draft covers only validator set up, not common tasks like key rotation, consolidation, etc.
* Merge docker/binaries into a single doc?
    * If not then refactor repeated docs in docker/binaries into separate pages.  link to those pages from both docker and binaries instructions.
    * Is it possible to toggle which of docker/binary terminal commands are visible in the doc?  That way we have only 1 doc to maintain and yet docker/binary redundancy is eliminated.
* New stuff:
    * validators now need to explicitly say their broadcaster is ready
    * Validators will send heartbeat that contains keys they have per X blocks.