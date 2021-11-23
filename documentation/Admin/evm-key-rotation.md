---
id: evm-key-rotation
sidebar_position: 1
sidebar_label: EVM Key Rotation
slug: /evm-key-rotation
---
# Master Key Rotation
1. Decide on the new key ID.
```
axelard q tss key-id ethereum master
```
Convention: the first key should have name `eth-master-genesis`.  Subsequent keys have names `eth-master-1`, `eth-master-2`, etc.  If you screw up a key then generate a new key with the same number but append a letter: `eth-master-1a`, `eth-master-1b`, etc.

2. Generate the new master key to be rotated to.
```
axelard tx tss start-keygen --id {key ID} --from validator --gas auto --gas-adjustment 1.2
```
Wait until the new key is generated.
The new key is successfully generated if the following query gives the key role `KEY_ROLE_MASTER_KEY`.
```
axelard q tss key {key ID}
```

3. Create the EVM command to transfer the ownership of AxelarGateway contract.
```
axelard tx evm transfer-ownership {chain name} {key ID} --from validator --gas auto --gas-adjustment 1.2
```

4. Sign the ownership-transfer command we just created.
```
axelard tx evm sign-commands {chain name} --from validator --gas auto --gas-adjustment 1.2
```
Wait until the signature is available.
The command is successfully signed if the following query gives the batched commands status `BATCHED_COMMANDS_STATUS_SIGNED`. If for any reason the status shown is `BATCHED_COMMANDS_STATUS_ABORTED`, signing can be re-tried.
```
axelard q evm latest-batched-commands {chain name}
```

5. First find the EVM chain gateway address. Use Metamask to send a transaction to this address.
```
axelard q evm gateway-address {chain name}
```

Send the signed command to the EVM chain.
```
axelard q evm latest-batched-commands {chain name}
```
Copy the `execute_data` field from the query above, pasted into the `data` field of an EVM transaction and send it out. You can use Metamask to do this. Make sure you manually increase the `gas limit` of the transaction before sending it. Use at least 2,000,000 gas to be safe.

6. Confirm the ownership transfer.
Before triggering the confirmation, make sure you've already waited for enough confirmations (currently 30) on the transaction. Once the ownership transfer is successfully confirmed, the system would rotate to the new key. Note that the confirmation can be re-triggered if you failed to wait for enough confirmations.
```
axelard tx evm confirm-transfer-ownership {chain name} {tx ID} {key ID} --from validator --gas auto --gas-adjustment 1.2
```
Wait until the voting is finished.
The confirmation and key rotation is successfully finished if the following query gives the expected key ID.
```
axelard q evm address {chain name} --key-role master
```

# Secondary Key Rotation
1. Generate the new secondary key to be rotated to.
```
axelard tx tss start-keygen --id {key ID} --key-role secondary --from validator --gas auto --gas-adjustment 1.2
-> Wait until the new key is generated
```
The new key is successfully generated if the following query gives the key role `KEY_ROLE_SECONDARY_KEY`.
```
axelard q tss key {key ID}
```

2. Create the EVM command to transfer the operatorship of AxelarGateway contract.
```
axelard tx evm transfer-operatorship {chain name} {key ID} --from validator --gas auto --gas-adjustment 1.2
```

3. Sign the operatorship-transfer command we just created.
```
axelard tx evm sign-commands {chain name} --from validator --gas auto --gas-adjustment 1.2
-> Wait until the signature is available
```
The command is successfully signed if the following query gives the batched commands status `BATCHED_COMMANDS_STATUS_SIGNED`. If for any reason the status shown is `BATCHED_COMMANDS_STATUS_ABORTED`, signing can be re-tried.
```
axelard q evm latest-batched-commands {chain name}
```

4. First find the EVM chain gateway address. Use Metamask to send a transaction to this address.
```
axelard q evm gateway-address {chain name}
```

Send the signed command to the EVM chain.
```
axelard q evm latest-batched-commands {chain name}
```
Copy the `execute_data` field from the query above, pasted into the `data` field of an EVM transaction and send it out. You can use Metamask to do this. Make sure you manually increase the `gas limit` of the transaction before sending it. Use at least 2,000,000 gas to be safe.

5. Confirm the operatorship transfer
Before triggering the confirmation, make sure you've already waited for enough confirmations on the transaction. Once the operatorship transfer is successfully confirmed, the system would rotate to the new key. Note that the confirmation can be re-triggered if you failed to wait for enough confirmations.
```
axelard tx evm confirm-transfer-operatorship {chain name} {tx ID} {key ID} --from validator --gas auto --gas-adjustment 1.2
-> Wait until the voting is finished
```
The confirmation and key rotation is successfully finished if the following query gives the expected key ID.
```
axelard q evm address ethereum --key-role secondary
```
