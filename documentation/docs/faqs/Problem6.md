# Troubleshooting Bitcoin deposit (Mint)


## Problem 
Bitcoin mint workflow is completed, but the wrapped test btc does not show up in the ethereum wallet.


## Cause
 During the mint workflow, in step 3, the bitcoin outpoint confirmation was not successful. When signing pending transfers, the bitcoin outpoint confirmation is not included, since it failed. The desired transaction confirmation is not included for the rest of the workflow and wrapped btc is not minted to the ethereum wallet.

## Solution
- Check if the bitcoin outpoint confirmation succeeded. See the Extra Commands document and find `Query the State of a Bitcoin Deposit Transaction`
```bash
axelard q bitcoin deposit-status [txID:vout]
```
- If the state is not `confirmed` then there was likely a typo in step 3. Double check the values of txID:vout, amount btc, and deposit address, then try to confirm the bitcoin outpoint again
```bash
axelard tx bitcoin confirmTxOut "{txID:vout}" "{amount}btc" "{deposit address}" --from validator -y -b block
```
- Complete the rest of the mint workflow

