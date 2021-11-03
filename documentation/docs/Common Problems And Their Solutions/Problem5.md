---
id: p5
sidebar_position: 7
sidebar_label: TRANSACTION OUT OF GAS
slug: /faq/p5
---

# Transaction out of gas

## Problem 
```bash
raw_log: 'out of gas in location: ReadFlat; gasWanted: 200000, gasUsed: 200568: outof gas'
```

## Cause
During execution, the axelar transaction ran out of gas and could not complete

## Solution
Please add the following flags to your command:
```bash
--gas=auto --gas-adjustment=1.4
```
