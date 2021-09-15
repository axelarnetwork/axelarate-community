---
id: evm-key-rotation
sidebar_position: 1
sidebar_label: EVM Key Rotation
slug: /evm-key-rotation
---
# Master Key Rotation
1. Generate the new master key to be rotated to.
```
axelard tx tss start-keygen --id {key ID} --from validator --gas auto --gas-adjustment 1.2
-> Wait until the new key is generated
```
The new key is successfully generated if the following query gives the key role `KEY_ROLE_MASTER_KEY`.
```
axelard q tss key {key ID}
```

2. Create the EVM command to transfer the ownership of AxelarGateway contract.
```
axelard tx evm transfer-ownership {chain name} {key ID} --from validator --gas auto --gas-adjustment 1.2
```

3. Sign the ownership-transfer command we just created.
```
axelard tx evm sign-commands {chain name} --from validator --gas auto --gas-adjustment 1.2
-> Wait until the signature is available
```
The command is successfully signed if the following query gives the batched commands status `BATCHED_COMMANDS_STATUS_SIGNED`. If for any reason the status shown is `BATCHED_COMMANDS_STATUS_ABORTED`, signing can be re-tried.
```
axelard q evm latest-batched-commands {chain name}
```

4. Send the signed command to the EVM chain.
```
axelard q evm latest-batched-commands {chain name}
```
Copy the `execute_data` field from the query above, pasted into the `data` field of an EVM transaction and send it out. You can use Metamask to do this.

5. Confirm the ownership transfer
Before triggering the confirmation, make sure you've already waited for enough confirmations on the transaction. Once the ownership transfer is successfully confirmed, the system would rotate to the new key. Note that the confirmation can be re-triggered if you failed to wait for enough confirmations.
```
axelard tx evm confirm-transfer-ownership {chain name} {tx ID} {key ID} --from validator --gas auto --gas-adjustment 1.2
-> Wait until the voting is finished
```
The confirmation and key rotation is successfully finished if the following query gives the expected key ID.
```
axelard q evm address ethereum --key-role master
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

4. Send the signed command to the EVM chain.
```
axelard q evm latest-batched-commands {chain name}
```
Copy the `execute_data` field from the query above, pasted into the `data` field of an EVM transaction and send it out. You can use Metamask to do this.

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
