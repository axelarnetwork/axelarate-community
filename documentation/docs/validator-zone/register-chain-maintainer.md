---
id: register-chain-maintainer
sidebar_position: 5
sidebar_label: Register as a maintainer of external chains
slug: /validator-zone/register-chain-maintainer
---

# Register as a maintainer of external chains

For each external blockchain you selected earlier in [Set up external chain nodes](/validator-zone/external-chains) you must inform the Axelar network of your intent to maintain that chain.  This is accomplished via the `register-chain-maintainer` command:

Example: register your Axlear validator node as a chain maintainer for the Ethereum blockchain:

```bash
axelard tx nexus register-chain-maintainer ethereum --from broadcaster --node "$VALIDATOR_HOST" # eg VALIDATOR_HOST=http://127.0.0.1:26657
```
