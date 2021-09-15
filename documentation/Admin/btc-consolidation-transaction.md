---
id: btc-consolidation-tx
sidebar_position: 1
sidebar_label: Bitcoin Consolidation Transaction
slug: /btc-consolidation-tx
---
# Master-Key Consolidation Transaction
TBD

# Secondary-Key Consolidation Transaction (Withdrawal)

In order to handle user withdrawals on the Bitcoin network, we need to trigger the secondary-key consolidation transaction. To to so, we need to use commands `create-pending-transfers-tx`and `sign-tx`, and then submit the signed transaction to the Bitcoin network. A query command `latest-tx` is also available to check the status of the transaction, and it's ready to be sent when the status field is set to `TX_STATUS_SIGNED`.

1. Create a secondary-key transaction to handle all pending transfers to Bitcoin. Note that you need to specify which key to use for sending the change output. If the key specified does not match the current secondary key, a key assignment will occur at transaction creation and key rotation will occur after signing is finished. The command would fail if such a transaction is already created and is waiting to be signed. In such case, please wait until the system is avaiable again.
  ```
  axelard tx bitcoin create-pending-transfers-tx {a key ID} --from validator --gas auto --gas-adjustment 1.2
  ```

2. Trigger signing of the secondary-key transaction we just created.
  ```
  axelard tx bitcoin sign-tx secondary --from validator --gas auto --gas-adjustment 1.2
  ```

3. Wait until the transaction is signed. This would typically take ~10 Axelar blocks.
  ```
  axelard q bitcoin latest-tx secondary
  ```
  - If the above query returns `TX_STATUS_SIGNED` as `status`, the transaction is ready to be broadcast to the Bitcoin network.
  - If the above query returns `TX_STATUS_ABORTED` as `status`, signing must have failed for some reason. Possible reasons include, but not limited to
    - Signing timed out due to various validator issues
    - Signing could not start due to validator(s) failing to claim TSS availability

  In all cases, the signing can be re-tried by calling `sign-tx` again as in step 2 again.

4. Submit the signed transaction to Bitcoin network

  ```
  axelard q bitcoin latest-tx secondary
  -> the tx field contains a hex-encoded representation of the signed Bitcoin transaction
  ```
  You can then copy the `tx` field and send it to the Bitcoin testnet with bitcoin's JSON-RPC API, or a web interface such as https://live.blockcypher.com/btc/pushtx/. Note to select Bitcoin testnet as the chain, if you are using the Blockcypher interface.
