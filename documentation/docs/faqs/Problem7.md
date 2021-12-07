# No pending transfer for chain ethereum 


## Problem 
During sign-pending-transfers, you see error 
```bash
“raw_log: '[{"log":"no pending transfer for chain ethereum found","events":[{"type":"message","attributes":[{"key":"action","value":"SignPendingTransfers"}]}]}]'”
```

## Cause
You either didn’t confirm the transaction and there is nothing in the backlog (follow the above steps to verify), OR someone executed sign-pending-transfers concurrently.

## Solution
Assuming you properly confirmed the transaction and verified it, it’s added to a back-log of pending transactions. Then, anyone can execute the `sign-pending-transfers` command to process ALL transactions in the backlog. If you confirmed your transaction and someone executed `sign-pending-transfers` concurrently, you’ll see your coins in the wallet (assuming they also posted the transaction on Ethereum). 


