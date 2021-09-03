---
id: validator-commands
sidebar_position: 4
sidebar_label: Validator Extra Commands
slug: /validator-extra-commands
---
# Validator Extra Commands
Useful commands to query Axelar network's internal state for validators.

## Disclaimer
:::warning
Axelar Network is a work in progress. At no point in time should you transfer any real assets using Axelar. Only use testnet tokens that you're not afraid to lose. Axelar is not responsible for any assets lost, frozen, or unrecoverable in any state or condition. If you find a problem, please submit an issue to this repository following the template.
:::

## Prerequisites
- Complete all steps from [Setup](/setup.md)
- Attempted or completed [Excercise 3](/exercises/e3) to join the network as a validator, and have a basic understanding of the workflow

## Commands
This document lists out additional commands providing information of interest for validator nodes. The commands expose the state of validators in the network and can be useful for troubleshooting.

When running outside of docker, you will have to specify the home directory using the `--home` flag. Specially during the exercises.

### Query Your Validator Address
```bash
axelard keys show validator --bech val -a
```

Returns the validator address of your node. The validator address begins with `axelarvaloper` and is used in many validator related commands.


### Query Validator Key Shares
```bash
axelard q tss key-shares-by-validator [validator address]
```
eg)

```bash
axelard q tss key-shares-by-validator "$(axelard keys show validator --bech val -a)"
```

Returns information on a list of axelar network threshold keys that the validator currently holds shares of. A validator must not hold any active key shares when they attempt to unbond and stop being a validator.


### Query Deregistered Validators
```bash
axelard q tss deactivated-operators
```

Returns a list of validators who are currently deregistered. Useful for confirming the success of a deregister command. Deregistered validators will not participate in future key generation events, and will not hold shares of future keys, allowing them to unbond at a later time.


### Query Snapshot
```bash
axelard q snapshot info [snapshot counter]
```
eg)

```bash
axelard q snapshot info latest
```
```bash
axelard q snapshot info 2
```

Returns information about a snapshot given the snapshot counter number. A snapshot is taken during each keygen event to capture the state of the network's validators and how many shares of the key each validator will hold. The `latest` keyword fetches the snapshot of the most recent keygen.


### Query All Validators
```bash
axelard q snapshot validators
```

Returns information on the status of all validators in the network.
