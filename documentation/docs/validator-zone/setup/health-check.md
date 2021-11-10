---
id: health-check
sidebar_position: 6
sidebar_label: Health check
slug: /validator-zone/setup/health-check
---

# Health check

Check the status of your validator.

* `vald` and `tofnd` companion processes are properly connected.
* Your `broadcaster` address is registered and adequately funded.

In a new terminal:

```bash
axelard health-check
```

You should see output like:

```
tofnd check: passed
broadcaster check: failed (no operator address specified)
```
