### Overview

This document describes the steps necessary to ensure that a validator node can backup keys in order to be able to recover their state in the future. The following data is needed to be backed up safely:

* Tendermint validator key
* Axelar validator mnemonic
* Axelar proxy mnemonic
* Tofnd mnemonic

For recover instructions, please see [recover](./validator_recover.md).

### Tendermint validator key

The Tendermint validator key is created when a node is launched for the first time.
It can be found within the node's container at `/root/.axelar/config/priv_validator_key.json` (or on the host at `$HOME/.axelar_testnet/.core/config/priv_validator_key.json`).

#### Key backup 

The content of the `priv_validator_key` file should look something like:

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

**Attention:** Be sure to store the content of this file at a safe, offline place.

### Axelar mnemonics

The Axelar mnemonics are created when an node/validator is launched for the first time and subsequently outputed to the terminal.
The output looks something like:

```
**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

range elder logic subject never utility dutch novel sail vacuum model robust coin upper egg trophy track chimney garlic random fury laundry kiss sight
```

#### Mnemonic backup 

There should be one mnemonic for the Axelar validator key and another for the Axelar proxy key. 
The former should be displayed after running `join/joinTestnet.sh` with a clean slate, while the latter should be displayed by `join/launchValidator.sh`.

**Attention:** Be sure to store this mnemonic at a safe, offline place.

### Tofnd mnemonic

The tofnd mnemonic is created when a validator is launched for the first time.
It can be found within the tofnd container at `/.tofnd/export` (or on the host at `$HOME/.axelar_testnet/.tofnd/export`).

Its contents should look something like:

```
purchase arrow sword basic gasp category hundred town layer snow mother roast digital fragile repeat monitor wrong combine awful nature damage rib skull chalk
```

**Attention:** Be sure to store this mnemonic at a safe, offline place.

#### Mnemonic backup

Tofnd can be executed with a mnemonic option as a command-line argument:
```
cargo run -- -m <option>
```

Currently, the following mnemonic options are supported for backup:

* `create` (default): Creates a new mnemonic if there exists none, otherwise does nothing. The new passphrase is written into the file *./tofnd/export*.

* `export`: Writes the existing mnemonic to file *.tofnd/export*; Succeeds when there is an existing mnemonic, fails otherwise.

All tofnd mnemonic options can be displayed by running
```
cargo run -- -h
```

#### Using tofnd binaries

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

    **Attention:** Be sure you save your mnemonic at a safe offline place. If it's lost, you will not be able to recover your shares.
