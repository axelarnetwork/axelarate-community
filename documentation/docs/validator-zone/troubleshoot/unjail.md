---
id: unjail
sidebar_position: 4
sidebar_label: Unjail
slug: /validator-zone/troubleshoot/unjail
---
# How to unjail your validator

"Jail" is a Tendermint/Cosmos concept---it is not specific to Axelar.  If your validator misses 6 or more of the last 100 blocks then your tendermint status becomes `jailed` and your [health check](/validator-zone/setup/health-check) prints something like:

```
tofnd check: passed
broadcaster check: passed
operator check: failed (health check to operator MY_VALIDATOR_ADDRESS failed due to the following issues: {"missed_too_many_blocks":true})
```

You can also see your 'jailed' status via the Cosmos command `axelard q staking validators`.

:::tip
Axelar-core currently uses the word "jail" to describe a different Axelar-specific status in the context of eligibility to participate in keygen/sign protocols.  This terminology can be confusing and we intend to change it in future versions of axelar-core.  To see whether your validator's has this Axelar-specific jail status use `axelard q snapshot validators`.
:::

You can restore your validator to healthy status by posting a transaction to the Axelar blockchain as follows.

## Docker

In the `axelar-core` container:
```
axelard tx slashing unjail --from validator
```

## Binaries

```
~/.axelar_testnet/bin/axelard tx slashing unjail --from validator --home ~/.axelar_testnet/.core --chain-id axelar-testnet-barcelona
```