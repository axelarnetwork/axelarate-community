---
id: p2
sidebar_position: 4
sidebar_label: /home/.axelar_testnet folder missing
slug: /faq/p2
---

# /home/.axelar_testnet folder missing

## Problem
After running `join-testnet.sh`, the `/home/.axelar_testnet` folder is missing. (Or the folder contents are out of date and unresponsive to changes)

## Cause
`join-testnet.sh` was run with sudo and the `.axelar_testnet` folder was placed under the home directory of the root user profile

## Solution
Run `join-testnet.sh` with the `--root` flag to specify the `.axelar_testnet` directory.


