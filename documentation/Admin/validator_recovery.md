### Overview

This document describes the steps necessary to ensure that a validator node can be restored in case its state is lost. In order to achieve this, it is necessary that the following data is safely backed up:

* Tendermint validator key
* Axelar validator mnemonic
* Axelar proxy mnemonic
* Tofnd mnemonic

Besides the data described above, it will also be necessary to retrieve the *recovery data* associated with all the key shares that the validator was responsible for maintaining.

For backup instructions, please see [backup](./validator_backup.md).

### Recovering an Axelar node

In order to restore the Tendermint key and/or the Axelar validator key used by an Axelard node, you can use the `--tendermint-key` and `--validator-mnemonic` flags with `join/joinTestnet.sh` as follows:

```
./join/joinTestnet.sh --tendermint-key /path/to/tendermint/key/ --validator-mnemonic /path/to/axelar/mnemonic/
```
### Recovery data

The recovery data is stored on chain, and enables a validator to recover key shares it created.
To obtain the recovery data for those key shares, you need to find out the corresponding key IDs first.
To query the blockchain for these key IDs - and assuming that the Axelar validator account has already been restored - attach a terminal to the node's container and perform the command:

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

### Recovering the vald process

In order to restore the Axelar proxy key used by the Vald process, you can use the `--validator-mnemonic` flag with `join/launchValidator.sh` as follows:

```
./join/joinTestnet.sh --proxy-mnemonic /path/to/axelar/mnemonic/
```

### Recovering Tofnd state

In order to restore the node's key shares, you can use the `--tofnd-mnemonic` and `--recovery-info` flags with `join/launchValidator.sh` as follows:

```
./join/joinTestnet.sh --tofnd-mnemonic /path/to/tofnd/mnemonic/ --recovery-info /path/to/recovery/file/
```

If you also need to 

### Recover with tofnd binary

In order to recover, you will need to execute tofnd in *import* mode. To do that, use the `import` command-line option:

* `import`: Adds a new mnemonic from file *.tofnd/import*; Succeeds when there is no other mnemonic already imported, fails otherwise.

All tofnd mnemonic options can be displayed by running
```
cargo run -- -h
```

#### Example
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
    **Note:** In order to successfully restore tofnd state, the validator you are running needs to have the `recover.json` file in place. For more information, see [Recovery Data](#RecoveryData).
3. Delete your mnemonic import and export file
    ```
    rm .tofnd/export ./tofnd/import
    ```
