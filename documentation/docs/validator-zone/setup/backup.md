---
id: backup
sidebar_position: 5
sidebar_label: Backup
slug: /validator-zone/setup/backup
---

# Back-up your validator mnemonics and secret keys

This document describes the steps necessary to ensure that a validator node can backup keys in order to be able to recover their state in the future. The following data is needed to be backed up safely:

* Tendermint validator key
* Axelar validator mnemonic
* Axelar proxy mnemonic
* Tofnd mnemonic

## Tendermint validator key

The Tendermint validator key is created when a node is launched for the first time.
It can be found within the node's container at `c` (or on the host at `$HOME/.axelar_testnet/.core/config/priv_validator_key.json`).

### Key backup

The content of the `priv_validator_key` file should look something like:

```bash
{
  "address": "98AF6E5D52BBB62BE6717DE8C55F16F5C013D7BE",
  "pub_key": {
    "type": "tendermint/PubKeyEd25519",
    "value": "CcspC1QDG8vz7kIW/7nPvqQ35XFJ5JLn5+li2WshP+o="
  },
  "priv_key": {
    "type": "tendermint/PrivKeyEd25519",
    "value": "VCG8TTeOSv+n9TOyy465CnUQALnoD/WJG9bloPGX0XUJyykLVAMby/PuQhb/uc++pDflcUnkkufn6WLZayE/6g=="
  }
}
```

**Attention:** Be sure to store the content of this file at a safe, offline place.

## Axelar mnemonics

The Axelar mnemonics are created when an node/validator is launched for the first time and subsequently outputed to the terminal.
The output looks something like:

```bash
**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

range elder logic subject never utility dutch novel sail vacuum model robust coin upper egg trophy track chimney garlic random fury laundry kiss sight
```

### Mnemonic backup

There should be one mnemonic for the Axelar validator key and another for the Axelar proxy key.
The former should be displayed after running `join/join-testnet.sh` with a clean slate, while the latter should be displayed by `join/launch-validator.sh`.

**Attention:** Be sure to store this mnemonic at a safe, offline place.

## Tofnd mnemonic

Tofnd needs to be provided with a mnemonic the first time it operates. From this mnemonic, a private key is derived and stored in tofnd's internal database. The private key is used to encrypt and decrypt the recovery information of the user.

By default, a mnemonic is created when tofnd is launched for the first time. Users can use this mnenonic to recover their information in case of data loss. Once a private key is created and stored at tofnd's internal database, the mnemonic file is no longer needed.

If you are running tofnd in a **containerized environment**, the mnemonic can be found within the tofnd container at `/.tofnd/export`, or on the mounted volume on the host machine at `$HOME/.axelar_testnet/.tofnd/export`.

If you are running tofnd as a **binary**, the mnemonic can be found under the directory from which you ran the executable, at `$TOFND_PATH/.tofnd/export`.

The mnemonic file should look something like:
```bash
purchase arrow sword basic gasp category hundred town layer snow mother roast digital fragile repeat monitor wrong combine awful nature damage rib skull chalk
```

**Attention:** Be sure to store your mnemonic at a safe, offline place. After storing it, be sure it is deleted from tofnd's container or tofnd's host machine.
