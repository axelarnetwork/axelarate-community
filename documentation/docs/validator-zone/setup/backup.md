---
id: backup
sidebar_position: 3
sidebar_label: Backup
slug: /validator-zone/setup/backup
---

# Back-up your validator mnemonics and secret keys

:::warning
It is very important to backup your secret information in a safe place so that you can recover your tokens and state in the event of data loss.
:::

You must store backup copies of the following data in a safe place:

1. Axelar validator mnemonic
2. Axelar proxy mnemonic
3. Tendermint validator key
4. Tofnd mnemonic

## Axelar validator mnemonic

The Axelar `validator` account mnemonic is created when a node is launched for the first time using `join/join-testnet.sh`.  This mnemonic is printed to the terminal:

```
**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

range elder logic subject never utility dutch novel sail vacuum model robust coin upper egg trophy track chimney garlic random fury laundry kiss sight
```

## Axelar broadcaster mnemonic

The Axelar broadcaster mnemonic is created when an existing node becomes a validator for the first time using `join/launch-validator.sh`.  This mnemonic is printed to the terminal just like the validator mnemonic (above).

## Tendermint validator key

The Tendermint validator key is created when a node is launched for the first time.
This key is distinct from the validator mnemonic---it is used by your validator for signing network consensus messages.

It can be found within the node's container at `/root/.axelar/config/priv_validator_key.json` or on the host at `~/.axelar_testnet/.core/config/priv_validator_key.json`.  The content of the `priv_validator_key.json` file should look something like:

```
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

## Tofnd mnemonic

The tofnd mnemonic is distinct from Axelar mnemonics: it is stored and used only by tofnd to create and encrypt secret key material for validator multi-party cryptography protocols.

The tofnd mnemonic is created when tofnd is launched for the first time using `join/launch-validator.sh`.  This menmonic can be found here:

* **Docker:** In the tofnd container at `/.tofnd/import`, or on the mounted volume on the host machine at `~/.axelar_testnet/.tofnd/import`.
* **Binary:** In the directory from which you ran the executable.  Example: `$TOFND_PATH/.tofnd/import`.

The mnemonic file should look something like:
```bash
purchase arrow sword basic gasp category hundred town layer snow mother roast digital fragile repeat monitor wrong combine awful nature damage rib skull chalk
```
