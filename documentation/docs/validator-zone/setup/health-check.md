---
id: health-check
sidebar_position: 6
sidebar_label: Health check
slug: /validator-zone/setup/health-check
---

# Health check

Check the status of your validator.

* tofnd check: `tofnd` companion process is alive and accessible from `vald`.
* broadcaster: Your `broadcaster` address is registered and adequately funded.
* operator check: Your operator address is indeed an Axelar validator in good status. (Possible bad status includes: missed too many blocks, jail status, etc.)

This step is not mandatory but it is good practice to help you detect and diagnose problems with your validator.

In the `vald` container::

```bash
axelard health-check --tofnd-host TOFND_HOST_NAME --operator-addr YOUR_VALIDATOR_ADDRESS --node AXELAR_CORE_HOST_NAME
```

For example

```bash
axelard health-check --tofnd-host tofnd --operator-addr $(cat /root/shared/validator.bech) --node http://axelar-core:26657
```

You should see output like:

```
tofnd check: passed
broadcaster check: passed
operator check: passed
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