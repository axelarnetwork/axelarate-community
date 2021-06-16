# Perform manual key rotation via c2d2
### Pull and enter the `c2d2cli controller` container
Check [TESTNET RELEASE.md](../TESTNET%20RELEASE.md) for the latest available C2D2 controller version of the docker images.

On a new terminal window, enter the `c2d2cli` container by running:
```

```

### Generate keys and fund account
Follow [exercise_2_btc_transfer_with_c2d2.md](../Exercises/exercise_2_btc_transfer_with_c2d2.md) `Generate a key on Axelar and get some test tokens` and `Fund your ethereum sender account` section to get test tokens for Axelar and Ethereum Ropsten.

### Key rotation command 
```
c2d2cli tss rotate [chain] [role]
```

### Rotate Bitcoin Key
```
// Bitcoin master key
c2d2cli tss rotate bitcoin master

// Bitcoin secondary key
c2d2cli tss rotate bitcoin secondary

// Rotate both keys
c2d2cli tss rotate bitcoin all
```
C2D2 automates the key rotation process. You will see logs printed in the terminal for each step.
1. Generate key
    ```
    info:    Generating bitcoin master key
    info:    bitcoin master key btc-master-4818082670 decided
    ```
2. Assign key
    ```
    info:    bitcoin master key btc-master-4818082670 assigned
    ```
3. Consolidate transaction to the newly assigned key
    ```
    info:    Consolidating bitcoin withdrawals (sending pending transfers to recipients)
      | Signing bitcoin consolidation tx
      | ✓ Waiting for TSS signing to complete with poll ID tss_ea6f1d408f9569c8c5ad96be53d9b11cebf4ef455367c4c19318dbc99c6cfce3
      | Waiting for bitcoin consolidation tx to be assembled
    info:    Assembled consolidation tx with hash f742c1c5df21d48d56e128ed1dc7d38bd8edd76265074eb091c2cfce949e0673
    info:    Sending bitcoin consolidation transaction txID f742c1c5df21d48d56e128ed1dc7d38bd8edd76265074eb091c2cfce949e0673
      | Waiting for bitcoin consolidation transaction to have 6 confirmations
    ```
4. Rotate key
    ```
    info:    bitcoin master key btc-master-4818082670 rotated
    ```
