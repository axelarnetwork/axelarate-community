---
id: btc-consolidation-tx
sidebar_position: 1
sidebar_label: Bitcoin Consolidation Transaction
slug: /btc-consolidation-tx
---
# Master-Key Consolidation Transaction

```
Master Key Consolidation is the process of moving funds from primary/master to secondary
```

In order to perform master-key consolidation transaction on the Bitcoin network, we need to make sure

1. There are some master-key UTXOs to spend
2. All external keys are registered

In order to send some coin from the secondary key to the master key, we need to use the `--master-key-amount` flag when
performing `create-pending-transfers-tx`.

Next, we'll need to generate and register external keys.

Generation can be handled by KMS -- the following command will write a WIF-encoded private key to disk (to be used by
the signing process) and print a hex-encoded public key to stdout (to register with Axelar).

NOTE: Be sure to preserve private keys produced by each iteration so they can be used during key signing.

```
axelar-kms bitcoin keygen --force
```

In order to register external keys, we need to use command

```
axelard tx bitcoin register-external-keys \
  --key {external key name}:{external pubkey in hex} \
  --key {external key name}:{external pubkey in hex} \
  --key {external key name}:{external pubkey in hex} \
  --key {external key name}:{external pubkey in hex} \
  --key {external key name}:{external pubkey in hex} \
  --key {external key name}:{external pubkey in hex} \
  --from validator -y -b block --gas auto --gas-adjustment 1.2
```

After above setup, we can run commands `create-master-tx`, `sign-tx`, and `submit-external-signature`, then submit the
signed transaction to the Bitcoin network to complete the consolidation. A query command `latest-tx` is also available
to check the status of the transaction, and it's ready to be sent when the status field is set to `TX_STATUS_SIGNED`.

1. To calculate the amount to retain in new secondary key,first look for the current secondary key.
   ```
   axelard q bitcoin consolidation-address --key-role secondary
   ```

   Get the address and check the balance in the most recent transaction on bitcoin explorer like blockstream.info.

   We want to send a very small amount (e.g 0.0001) to the master key and the rest will remain with the secondary key. So subtract 0.0001 from the balance on the secondary key to determine the value for the param `--secondary-key-amount`

   First create a new key. The key id should be a sequence considering the output of the consolidation-address query above. So for example, the key_id from that query is `btc-primary-2`, you would choose `btc-primary-3` for the new key id.

   ```
   axelard tx tss start-keygen --id {key ID} --from validator --gas auto --gas-adjustment 1.2
   ```

   Check that the status of the key
   ```
   axelard q tss key <key_id>
   ```

   Create a master-key transaction and use the flag  `--secondary-key-amount` to send most coins back to the
   secondary key.

   Note that you need to specify which key to use for sending the change output. If the key specified
   does not match the current master key, a key assignment will occur at transaction creation and key rotation will
   occur after signing is finished. The command would fail if such a transaction is already created and is waiting to be
   signed. In such case, please wait until the system is available again.
    ```
    axelard tx bitcoin create-master-tx {a key ID} --from validator --gas auto --gas-adjustment 1.2
    ```
2. Generate external signatures for the transaction we just created.

    1. #### Get TX json from axelard
       _We currently hold at least 3 of 6 multisig keys so there is no need to collect signatures from external parties
       at this time._
       ```
       axelard q bitcoin latest-tx --output json master
       ```

    2. #### Sign TX json with KMS using $HOME/.axelar/private.key
       _Repeat the following for each multisig key that we are holding (only 3 are necessary), substituting the private
       key as necessary._

       ```
       axelar-kms bitcoin sign {tx-json}
       ```
4. Submit external signatures for the transaction we just created.
    ```
    axelard tx bitcoin submit-external-signature {external key name} {external signature in hex} {sighash in hex} --from validator --gas auto --gas-adjustment 1.2
    ```
   Note that this needs to be done for 3 external keys by default.

5. Trigger signing of the master-key transaction we just created.

  ```
  axelard tx bitcoin sign-tx master --from validator --gas auto --gas-adjustment 1.2
  ```

3. Wait until the transaction is signed. This would typically take ~10 Axelar blocks.

  ```
  axelard q bitcoin latest-tx master
  ```

- If the above query returns `TX_STATUS_SIGNED` as `status`, the transaction is ready to be broadcast to the Bitcoin
  network.
- If the above query returns `TX_STATUS_ABORTED` as `status`, signing must have failed for some reason. Possible reasons
  include, but not limited to
    - Signing timed out due to various validator issues
    - Signing could not start due to validator(s) failing to claim TSS availability

In all cases, the signing can be re-tried by calling `sign-tx` again as in step 2 again.

4. Submit the signed transaction to Bitcoin network

  ```
  axelard q bitcoin latest-tx master
  -> the tx field contains a hex-encoded representation of the signed Bitcoin transaction
  ```

You can then copy the `tx` field and send it to the Bitcoin testnet with bitcoin's JSON-RPC API, or a web interface such
as https://live.blockcypher.com/btc/pushtx/. Note to select Bitcoin testnet as the chain, if you are using the
Blockcypher interface.

# Secondary-Key Consolidation Transaction (Withdrawal)

In order to handle user withdrawals on the Bitcoin network, we need to trigger the secondary-key consolidation
transaction. To to so, we need to use commands `create-pending-transfers-tx`and `sign-tx`, and then submit the signed
transaction to the Bitcoin network. A query command `latest-tx` is also available to check the status of the
transaction, and it's ready to be sent when the status field is set to `TX_STATUS_SIGNED`.

1. Create a secondary-key transaction to handle all pending transfers to Bitcoin. Note that you need to specify which
   key to use for sending the change output. If the key specified does not match the current secondary key, a key
   assignment will occur at transaction creation and key rotation will occur after signing is finished. The command
   would fail if such a transaction is already created and is waiting to be signed. In such case, please wait until the
   system is avaiable again.

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

- If the above query returns `TX_STATUS_SIGNED` as `status`, the transaction is ready to be broadcast to the Bitcoin
  network.
- If the above query returns `TX_STATUS_ABORTED` as `status`, signing must have failed for some reason. Possible reasons
  include, but not limited to
    - Signing timed out due to various validator issues
    - Signing could not start due to validator(s) failing to claim TSS availability

In all cases, the signing can be re-tried by calling `sign-tx` again as in step 2 again.

4. Submit the signed transaction to Bitcoin network

  ```
  axelard q bitcoin latest-tx secondary
  -> the tx field contains a hex-encoded representation of the signed Bitcoin transaction
  ```

You can then copy the `tx` field and send it to the Bitcoin testnet with bitcoin's JSON-RPC API, or a web interface such
as https://live.blockcypher.com/btc/pushtx/. Note to select Bitcoin testnet as the chain, if you are using the
Blockcypher interface.
