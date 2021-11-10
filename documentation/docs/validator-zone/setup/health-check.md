---
id: health-check
sidebar_position: 6
sidebar_label: Health check
slug: /validator-zone/setup/health-check
---

# Health check

Check the status of your validator.

* `vald` and `tofnd` companion processes are alive and properly connected.
* Your `broadcaster` address is registered and adequately funded.
* Your validator has recently posted a `heartbeat` transaction to the Axelar network

In a new terminal:

```bash
axelard health-check
```

You should see output like:

```
TODO
```

:::tip
If instead you see output like:

```
TODO
```

then wait 50 blocks and try again.

### Explanation
Your validator node automatically posts a `heartbeat` transaction to the Axelar network every 50 blocks.  If you do `axelard health-check` within 50 blocks after first becoming a validator then your validator will not yet post a `heartbeat` transaction, yielding the above output.
:::