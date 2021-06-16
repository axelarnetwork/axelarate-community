# Trigger Manual Consolidation / Withdrawal 

While doing exercise 1, testnet users will submit withdrawals on Ethereum back to Bitcoin. However, to trigger their withdrawals on the Bitcoin network, we need to `sign-pending-transfers`, submit the transaction to the Bitcoin, and then confirm it on the Axelar network. Since Bitcoin is slow, we don't want users to execute these steps concurrently and then have to resolve state transitions between them. So periodically, once a day, we'll trigger these admin commands. (In the next release, this task will be handled by automated service). 

1. Trigger signing of all pending transfers to Bitcoin. Note that you need to include an arbitrary Bitcoin fee in this transaction (e.g. 0.0001btc) so the command is properly parsed. The fee argument is required as input but ignored by Axelar. It is going to be removed with the next release.

  ```
  axelard tx bitcoin sign-pending-transfers {tx fee} --from validator -b block -y
  -> wait for sign protocol to complete (~10 Axelar blocks)
  ```

 e.g.,

  ```
  axelard tx bitcoin sign-pending-transfers 0.0001btc --from validator -b block -y
  ```
  If everything succedeed, go to Step 5. 

  If you got an error `failed to execute message; message index: 0: previous consolidation transaction must be confirmed first: btc bridge error`, then one of the following happened: 
  a) The previous withdrawal/consolidation transaction was signed but not submitted to the Bitcoin testnet, or
  b) The previous withdrawal/consolidation transaction was signed and submitted to the Bitcoin testnet, but it was *not* confirmed (either because it's not 6-blocks deep yet or another testnet participant didn't complete Step 6). 

  In any case, please try to complete Steps 5 and 6 below (you're doing it for someone else's withdrawal first) and come back and complete Step 4-6 for your own withdrawal. 
  
  (Note, while submitting the previous withdrawal transaction to Bitcoin testnet in Step 5, if you see an error similar to `hash [hash] already exists`, then the previous testnet user completed Step 5, but failed to complete Step 6. Regardless, make sure the transaction is 6-blocks deep, complete Step 6, and come back to complete Steps 4-6 for your own withdrawal). 

5. Submit the transfer to Bitcoin

  ```
  axelard q bitcoin rawTx
  -> Return raw transaction in hex encoding
  ```
  You can then copy the raw transaction and send it to bitcoin testnet with bitcoin's JSON-RPC API, or a web interface such as https://live.blockcypher.com/btc/pushtx/. Note to select Bitcoin testnet as the chain, if you are using the Blockcypher interface.

6. Confirm the Bitcoin outpoint

In this step, you will try to confirm all outpoints of the transfer transaction. Be sure to wait until the transaction is 6 blocks deep in the Bitcoin network.

  ```
  axelard tx bitcoin confirmTxOut "{txID:vout}" "{amount}btc" "{deposit address}" --from validator -y -b block
  ```
e.g.,
  ```
  axelard tx bitcoin confirmTxOut 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0 0.00088btc tb1qlteveekr7u2qf8faa22gkde37epngsx9d7vgk98ujtzw77c27k7qk2qvup --from validator -y -b block
  ```

Most of the confirmations will fail, and you will see:
```
failed to execute message; message index: 0: outpoint address unknown
```
as a response. This is normal. However, at least one of the confirmations should succeed. Among those is the outpoint that returns the remaining balance back to the Axelar network key.
(Note, technically, you only need to confirm the output that returns the balance back to the Axelar network key. If you know the address, you can just confirm that single output). 

🛑 **IMPORTANT: Without this step, other users of the testnet will be unable to withdraw their wrapped tokens. Be a good citizen and confirm the outpoints!**

