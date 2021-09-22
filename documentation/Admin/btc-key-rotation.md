---
id: btc-key-rotation
sidebar_position: 1
sidebar_label: Bitcoin Key Rotation
slug: /btc-key-rotation
---
# Master/Secondary Key Rotation
In order to rotate to a new key, you basically need to trigger a consolidation transaction sending the change amount to a master/secondary key that is different than the current one. Check the steps at [Bitcoin Consolidation Transaction](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/btc-consolidation-transaction.md), and make sure to use a different master/secondary key ID at step 1.

Note that for axelar-core version <=0.7.x, manual key rotation has to be triggered after the bitcoin consolidation transaction is submitted.
```
axelard tx tss rotate bitcoin {key role, e.g. secondary or master} {a key ID} --from validator --gas auto --gas-adjustment 1.2
```
