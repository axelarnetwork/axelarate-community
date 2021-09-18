---
id: p10
sidebar_position: 10
sidebar_label: Troubleshooting Bitcoin withdraw (Burn) 
slug: /faq/p8
---

# Troubleshooting Bitcoin withdraw (Burn)


## Problem 
Bitcoin burn workflow is completed, but the test btc does not show up in the bitcoin wallet.


## Solution
- Check that the user waited at least 24 hours after completing the last step (step 3) in the burn btc workflow. This is because our automated consolidation service runs once a day to process pending bitcoin transfers.
- Check that the Ethereum deposit transaction confirmation (step 3) was successful. Ask the user to run step 3 again with the same parameters
```bash
axelard tx evm confirm-erc20-deposit ethereum {txID} {amount} {deposit addr} --from validator -y -b block
```
They should see an error that the transaction is `already confirmed`. If they do not see this error, it means their first confirmation was not successful, most likely because there was a typo in the txID, amount, or deposit addr fields. Double check the values, and run step 3 again with the correct parameters. Run step 3 a final time to see the `already confirmed` error message, which proves the deposit transaction confirmation was successful. Wait 24 hours from now then check the bitcoin wallet.
Check that the daily bitcoin consolidation transaction was successful. See the Extra Commands document for `Query the State of the Last Consolidation Transaction`
axelard q bitcoin consolidationTxState
- The state should be `confirmed` or `ready to sign`. If needed, reach out to the team for more information on the last bitcoin consolidation.

