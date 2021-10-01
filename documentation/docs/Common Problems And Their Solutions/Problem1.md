---
id: p1
sidebar_position: 3
sidebar_label: Axelar core container fails to start
slug: /faq/p1
---

# Axelar core container fails to start

## Problem 
```
Axelar core container fails to start. Post "[<http://127.0.0.1:7545>](<http://127.0.0.1:7545/>)": dial tcp 127.0.0.1:7545: connect: connection refused
```
## Cause
If the `/home/.axelar_testnet` folder contains old data from a previous version of testnet, and then `joinTestnet.sh` is run using the new axelar-core version.

## Solution
Run `joinTestnet.sh` with the `--reset-chain` flag to delete the old chain data.
