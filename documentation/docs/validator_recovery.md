### Overview

This document describes the steps necessary to ensure that a validator node can be restored in case its state is lots. In order to achieve this, it is necessary that the following data is safely backed up:

* Tendermint validator key
* Axelar validator mnemonic
* Axelar proxy mnemonic
* Tofnd mnemonic

Besides the data described above, it will also be necessary to retrieve the *recovery data* associated to all the key shares that the validator was responsible for maintaining.

### Tendermint validator key

The Tendermint validator key is created when a node is launched for the first time.
It can be found within the node's container at `/root/.axelar/config/priv_validator_key.json` (or from the node's root directory at `$ROOT_DIRECTORY/.core/config/priv_validator_key.json`).
Its contents should look something like:

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

### Axelar mnemonics

The Axelar mnemonics are created when an node/validator is launched for the first time and subsequently outputed to the terminal.
The output looks something like:

```
**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

range elder logic subject never utility dutch novel sail vacuum model robust coin upper egg trophy track chimney garlic random fury laundry kiss sight
```

There should be one mnemonic for the Axelar validator key and other for the Axelar proxy key. 
The former should be displayed by the node container, while the later should be displayed by vald container.

### Tofnd mnemonic

The tofnd mnemonic is created when a validator is launched for the first time.
It can be found within the tofnd container at `/.tofnd/export` (or from the node's root directory at `$ROOT_DIRECTORY/.tofnd/export`).
Its contents should look something like:

```
purchase arrow sword basic gasp category hundred town layer snow mother roast digital fragile repeat monitor wrong combine awful nature damage rib skull chalk
```

### Recovery data

The recovery data is stored on chain, and enables a validator to recover the shares for the keys that it took part on generating and uses to sign data.
In order to obtain this data, first it is necessary to determine which keys the validator helped generate.
If you do not know which keys the validator is associatef with, attach a terminal to the node's container and perform the command:

```
~/scripts # axelard q tss keySharesValidator $(axelard keys show validator --bech val -a)
- key_chain: Bitcoin
  key_id: btc-master
  key_role: KEY_ROLE_MASTER_KEY
  num_total_shares: "5"
  num_validator_shares: "1"
  snapshot_block_number: "23"
  validator_address: axelarvaloper1mx627hm02xa8m57s0xutgjchp3fjhrjwp2dw42
- key_chain: Bitcoin
  key_id: btc-secondary
  key_role: KEY_ROLE_SECONDARY_KEY
  num_total_shares: "5"
  num_validator_shares: "1"
  snapshot_block_number: "56"
  validator_address: axelarvaloper1mx627hm02xa8m57s0xutgjchp3fjhrjwp2dw4
```

You can now levarage the information provided by the command to retrieve the recovery data for keys `btc-master` and `btc-secondary` as follows:

```
axelard q tss recover $(axelard keys show validator --bech val -a) testkey btc-secondary --output json > recovery.json
```

The command above will fetch the recovery info for the aforementioned keys and store it to the `recovery.json` file.
This file will contain the data necessary to perform share recovery.
