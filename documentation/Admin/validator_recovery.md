---
id: validator_recovery
sidebar_position: 9
sidebar_label: Validator Recovery
slug: /validator_recovery
---

### Overview

This document describes the steps necessary to ensure that a validator node can be restored in case its state is lost. In order to achieve this, it is necessary that the following data is safely backed up:

* Tendermint validator key
* Axelar validator mnemonic
* Axelar proxy mnemonic
* Tofnd mnemonic

Besides the data described above, it will also be necessary to retrieve the *recovery data* associated to all the key shares that the validator was responsible for maintaining.

### Tendermint validator key

The Tendermint validator key is created when a node is launched for the first time.
It can be found within the node's container at `/root/.axelar/config/priv_validator_key.json` (or from the node's directory at `$NODE_DIRECTORY/.core/config/priv_validator_key.json`).
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
The former should be displayed after running `join/jointestnet.sh` with a clean slate, while the later should be displayed by `join/launchValidator.sh`.

### Tofnd mnemonic

The tofnd mnemonic is created when a validator is launched for the first time.
It can be found within the tofnd container at `/.tofnd/export` (or from the node's directory at `$NODE_DIRECTORY/.tofnd/export`).
Its contents should look something like:

```
purchase arrow sword basic gasp category hundred town layer snow mother roast digital fragile repeat monitor wrong combine awful nature damage rib skull chalk
```

#### Mnemonic options

Tofnd can be executed with a mnemonic option as a command-line argument:
```
cargo run -- -m <option>
```

Currently, the following mnemonic options are supported:

* `create` (default): Creates a new mnemonic if there none exists, otherwise does nothing. The new passphrase is written under the file *./tofnd/export*.

* `import`: Adds a new mnemonic from file *.tofnd/import*; Succeeds when there is no other mnemonic already imported, fails otherwise.

* `export`: Writes the existing mnemonic to file *.tofnd/export*; Succeeds when there is an existing mnemonic, fails otherwise.

* `update`: Updates existing mnemonic from file *./tofnd/import*; Succeeds when there is an existing mnemonic, fails otherwise. The old passphrase is written to file *.tofnd/export*.

### Backup mnemonic for tofnd binaries

An exercise for creating your mnemonic using tofnd binary is the following:
1. Start tofnd and produce a mnemonic
    ```
    # cargo run is equivilent to cargo run -- -m create
    cargo run
    ```
    The output should be something similar to the following:
    ```
    tofnd listen addr 0.0.0.0:50051, use ctrl+c to shutdown
    Creating mnemonic
    kv_manager cannot open existing db [.tofnd/kvstore/shares]. creating new db
    kv_manager cannot open existing db [.tofnd/kvstore/mnemonic]. creating new db
    Mnemonic successfully added in kv store
    Mnemonic written in file .tofnd/export
    ```

2. Store the mnemonic which has been created in *./tofnd/export*. Remember to delete the *./tofnd/export* file after you have safely stored the mnemonic.

    **Attention:** Be sure you save your mnemonic at an offline safe place. If it's lost, you will not be able to recover your shares.
3. Delete your *.tofnd* folder. This will delete your mnemonic and all your shares.
    ```
    rm -rf .tofnd
    ```

### Restore mnemonic for tofnd binaries

An exercise for restoring your tofnd key using your mnemonic is the following:
1. Create an new empty *.tofnd* folder, and write your mnemonic into a file under the name *import*. Put this file in *./tofnd/import*. 
    ```
    mkdir .tofnd && cd .tofnd
    touch import
    # write your mnemonic at the `import` file
    ```
2. Start tofnd using the *import* option
    ```
    cargo run -- -m import
    ```
    The output should be something similar to the following:
    ```
    tofnd listen addr 0.0.0.0:50051, use ctrl+c to shutdown
    Importing mnemonic
    kv_manager cannot open existing db [.tofnd/kvstore/mnemonic]. creating new db
    kv_manager cannot open existing db [.tofnd/kvstore/shares]. creating new db
    Mnemonic successfully added in kv store
    Mnemonic written in file .tofnd/export
    ```
3. Delete your mnemonic import and export file
    ```
    rm .tofnd/export ./tofnd/import
    ```

### Recovery data

The recovery data is stored on chain, and enables a validator to recover key shares it created.
To obtain the recovery data for those key shares, you need to find out the corresponding key IDs first.
To query the blockchain for these key IDs, attach a terminal to the node's container and perform the command:

```
~/scripts # axelard q tss key-shares-validator $(axelard keys show validator --bech val -a)
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

In this example, the validator participated in generating the keys with ID `btc-master` and `btc-secondary`.
With the help of the key IDs, you can now retrieve the recovery data for the keys:

```
axelard q tss recover $(axelard keys show validator --bech val -a) btc-master btc-secondary --output json > recovery.json
```

The command above will fetch the recovery info for the aforementioned keys and store it to a `recovery.json` file.
This file will contain the data necessary to perform share recovery.

### Recovering an Axelar node

In order to restore the Tendermint key and/or the Axelar validator key used by an Axelard node, you can use the `--tendermint-key` and `--validator-mnemonic` flags with `join/joinTestnet.sh` as follows:

```
./join/joinTestnet.sh --tendermint-key /path/to/tendermint/key/ --validator-mnemonic /path/to/axelar/mnemonic/
```

### Recovering the Vald process

In order to restore the Axelar proxy key used by the Vald process, you can use the `--validator-mnemonic` flag with `join/launchValidator.sh` as follows:

```
./join/joinTestnet.sh --proxy-mnemonic /path/to/axelar/mnemonic/
```

### Recovering Tofnd state

In order to restore the Tofnd mnemonic and/or key shares, you can use the `--tofnd-mnemonic` and `--recovery-info` flags with `join/launchValidator.sh` as follows:

```
./join/joinTestnet.sh --tofnd-mnemonic /path/to/tofnd/mnemonic/ --recovery-info /path/to/recovery/file/
```
