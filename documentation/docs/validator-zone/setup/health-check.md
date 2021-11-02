---
id: health-check
sidebar_position: 6
sidebar_label: Health check
slug: /validator-zone/health-check
---

# Health check

Check that your node's `vald` and `tofnd` are connected properly. As a validator, your `axelar-core` will talk with your `tofnd` through `vald`. This is important when events such as key rotation happens on the network.

## Check: vald, tofnd containers running

In a new terminal:

```bash
docker ps --format '{{.Names}}'
```

Should see output like:
```
vald
tofnd
validator
```

## Check: vald can communicate with tofnd

Etner the `vald` CLI:

```bash
docker exec -ti vald sh
```

From inside the `vald` container run
```bash
axelard tofnd-ping --tofnd-host tofnd
```

You should see
```
PONG!
```
